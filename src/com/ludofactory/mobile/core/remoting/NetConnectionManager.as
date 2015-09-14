/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Olivier Chevarin - Maxime Lhoez
Created : 11 Décembre 2012
*/
package com.ludofactory.mobile.core.remoting
{
	import com.freshplanet.nativeExtensions.AirNetworkInfo;
	import com.gamua.flox.Flox;
	import com.ludofactory.common.encryption.Encryption;
	import com.ludofactory.common.utils.log;
	import com.ludofactory.mobile.core.HeartBeat;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	
	import flash.display.MovieClip;
	import flash.events.NetStatusEvent;
	import flash.events.StatusEvent;
	import flash.net.NetConnection;
	import flash.net.ObjectEncoding;
	import flash.utils.Dictionary;
	
	import air.net.SocketMonitor;
	
	/**
	 * NetConnectionManager
	 * 
	 * <p>It is possible to check the <code>connected</code> variable of the
	 * netConnection. Note that it is useless to check this variable if this
	 * is a http connection, because <code>connected</code> will always be
	 * set to false.</p>
	 * 
	 * <p>The <code>AsyncErrorEvent.ASYNC_ERROR</code> is apparently never
	 * called in our case when we cannot connect to the gateway. It is
	 * apparently the case when we are connected through a http so I removed
	 * this handler for the mobile.
	 * 
	 * <listing version="3.0">
	 * private function onConnectError(event:AsyncErrorEvent):void 
	 * {
	 * 		log("[NetConnectionManager] onConnectError() - " + event);
	 * }</listing></p>
	 * 
	 * <p>The events IOErrorEvent.IO_ERROR, IOErrorEvent.VERIFY_ERROR
	 * IOErrorEvent.DISK_ERROR and IOErrorEvent.NETWORK_ERROR have also
	 * been removed as they seems to never be called.
	 * 
	 * <listing version="3.0">
	 * private function IOErrorHandler(event:IOErrorEvent):void 
	 * {
	 * 		log("[NetConnectionManager] IOErrorHandler() - " + event);
	 * }</listing></p>
	 * 
	 * <p>The handler SecurityErrorEvent.SECURITY_ERROR have been removed
	 * ad it seems the never be called.
	 * 
	 * <listing version="3.0">
	 * private function securityErrorHandler(event:SecurityErrorEvent):void 
	 * {
	 * 		log("[NetConnectionManager] - securityErrorHandler() - " + event);
	 * }</listing></p>
	 */	
	public class NetConnectionManager extends MovieClip
	{
		/**
		 * Dictionary of active calls (containing responders). It
		 * is used to avoid multiple calls for a same command. */		
		private var _activeCalls:Dictionary;
		
		/**
		 * Dictionary of active calls (containing responders) by screen.
		 * It is used in order to simplify the disposal process. This
		 * way we can avoid callbacks to be called while the parent screen
		 * is already disposed. */		
		private var _callsByScreen:Dictionary;
		
//------------------------------------------------------------------------------------------------------------
//	Encryption
		
		/**
		 * Whether data encryption is enabled. */		
		private var _encrypt:Boolean;
		
		/**
		 * Name of the bridge service in AmfPhp + the function to call when data
		 * encryption is enabled (ex : LudomobileEncryption.callAction). It is
		 * used to decrypt the data in php side so that the parameters are readable
		 * by the real targetted service (ex : LudoMobile). */		
		private var _encryptionBridge:String;
		
		private var _reportErrorFunctionName:String;
		
		/**
		 * Static encryption key.
		 * 
		 * <p>This key is used to decrypt the first parameter (the object with
		 * the name of the service, the function to call and the parameters).</p>
		 * 
		 * <p>It must be the exact same key as the one stored in the server as
		 * a default parameter of the Encryption.php class.</p>
		 */		
		private var _cryptageDef:Encryption;
		
		/**
		 * Dynamic encryption key
		 * 
		 * <p>This key is updated at each call in order to encrypt a second
		 * time the data.</p>
		 */		
		private var _cryptageDyn:Encryption;
		
//------------------------------------------------------------------------------------------------------------
//	NetConnection
		
		/**
		 * Net connection */		
		private var _nc:NetConnection;
		
		/**
		 * The complete gateway url. */		
		private var _completeGatewayUrl:String;
		
		/**
		 * Base url of the gateway */		
		private var _baseGatewayUrl:String;
		
		/**
		 * Gateway port (default is 80 for http connection and 443 for https) */		
		private var _gatewayPortNumber:int;
		
		/**
		 * Amf path */		
		private var _amfPath:String = "";
		
		/**
		 * Name of the service in AmfPhp */		
		private var _serviceName:String;
		
		/**
		 * SocketMonitor used to check the availability of
		 * the host / server. */		
		private var _socketMonitor:SocketMonitor;
		
		/**
		 * Whether the host is available. */		
		private var _hostAvailable:Boolean = false;
		
		/**
		 * A generic success callback */		
		private var _genericSuccessCallback:Function;
		/**
		 * A generic failure callback */		
		private var _genericFailureCallback:Function;
		
		/**
		 * Default value of the relaunch timer. */		
		private const TIMER_BASE_VALUE:int = 2000;
		
		/**
		 * Timer used to restart connection or calls after a closure */		
		private var _timerRestart:int;
		/**
		 * If the timer is running */		
		private var _isTimerRunning:Boolean;
		
		public function NetConnectionManager()
		{
			encrypt = true;
			_isTimerRunning = false;
			
			_callsByScreen = new Dictionary();
			_activeCalls = new Dictionary();
			
			_nc = new NetConnection();
			_nc.objectEncoding = ObjectEncoding.AMF3;
			_nc.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Connection
		
		/**
		 * Connects to the gateway.
		 * 
		 * <p>The gateway url must be defined before attempting a connection.</p>
		 * 
		 * <p><strong>Important</strong> : when we connect with a http connection
		 * (this is the case with amfphp) we won't get the status event closed or
		 * success. Moreover, the variable <code>connected</code> will <strong>always
		 * </strong> be set to false.</p>
		 * 
		 * <p>Check the net status event handler for more informations about how the
		 * reconnection is handled here.</p>
		 * 
		 * @throws ArgumentError if the gateway have not been defined before.
		 */		
		public function connect():void
		{
			if( !_baseGatewayUrl || _baseGatewayUrl == "" )
				throw new ArgumentError("[NetConnectionManager] The gateway url is not defined.");
			
			_completeGatewayUrl = _baseGatewayUrl + (_gatewayPortNumber ? (":" + _gatewayPortNumber) : "") + _amfPath;
			
			if( _socketMonitor != null )
			{
				_socketMonitor.removeEventListener(StatusEvent.STATUS, announceSocket);
				_socketMonitor.stop();
				_socketMonitor = null;
			}
			_socketMonitor = new SocketMonitor(_baseGatewayUrl, _gatewayPortNumber);
			_socketMonitor.addEventListener(StatusEvent.STATUS, announceSocket);
			_socketMonitor.start();
		}
		
		/**
		 * Ths function is called whenever a change is detected with
		 * the host (i.e. the <code>_baseGatewayUrl</code>). Beware
		 * that it is not called when the network change on the device !
		 * 
		 * <p>If the host is available, then we try to connect (or reconnect)
		 * to the gateway url, otherwise, nothing is done and all responders
		 * are forced to fail.</p>
		 */		
		private function announceSocket(event:StatusEvent):void
		{
			log("[NetConnectionManager] Host " + (_baseGatewayUrl + (_gatewayPortNumber ? (":" + _gatewayPortNumber) : "")) + " available : " + _socketMonitor.available);
			
			/*if( _socketMonitor.available || GlobalConfig.DEBUG )
			{*/
				// if the host is available or if we are in debug mode
				_hostAvailable = true;
				_nc.connect( _completeGatewayUrl );
			/*}
			else
			{
				_hostAvailable = false;
				failAndClearAllResponders();
			}*/
		}
		
//------------------------------------------------------------------------------------------------------------
//	Calls
		
		/**
		 * Call a function in the service.
		 * 
		 * <p>Note that in the case of a mobile application, the parameter "functionToCallName" will always
		 * be the same for each call. The reason is because we use a kind of dispatcher whose name is
		 * <code>LudoMobile.php</code> in which we call a unique function called "useClass". This function
		 * will automatically call the controller and its function defined respectively in args[0] and args[1]
		 * with the parameters defined in args[2].</p>
		 * 
		 * @param functionToCallName The function to call in the service
		 * @param callbacks Array of callbacks - [0] is the success callback, [1] the ma attempts callback and [2] the error callback
		 * @param screenName The screen associated to this call (used to cancel the calls when the screen is disposed)
		 * @param maxAttempts How many attempts until we get successful callback
		 * @param args The arguments to pass to the function to call.
		 */		
		public function call(functionToCallName:String, callbacks:Array, screenName:String, maxAttempts:int, ...args):void
		{
			var commandName:String = _serviceName + "." + functionToCallName + "." + args[0] + "." + args[1];
			
			if( args[1] == "pushPartie" )
			{
				// when we want to push a game, we add the timestamp to the command
				// so that we can push several game at once
				commandName += args[2].id_partie;
			}
			else if( args[1] == "saveCoupe" )
			{
				// in order to be able to push several trophies at the same time, we
				// add to the command the id of the trophy
				commandName += args[2].num_coupe;
			}
			
			// avoid multiple calls of the same request
			if( commandName in _activeCalls )
				return;
			
			if( CONFIG::DEBUG )
			{
				log("[NetConnectionManager] Calling " + commandName + " with parameters : " + JSON.stringify( args[2] ));
			}
			else
			{
				log("[NetConnectionManager] Calling " + commandName + (args[1] == "pushPartie" ? " with parameters : " + _cryptageDef.encrypt(JSON.stringify(args[2])) : "") );
			}
			
			var responderManager:NetResponder = createResponder(callbacks, commandName, maxAttempts, screenName, args);
			
			if( !_hostAvailable )
			{
				if( _genericFailureCallback )
				{
					try
					{
						_genericFailureCallback( null, functionToCallName, callbacks[2] );
					} 
					catch(error:Error) 
					{
						Flox.logWarning("[NetConnectionManager] Try/Catch du call du NetConnectionManager");
						if( CONFIG::DEBUG ) throw error;
					}
				}
				else
				{
					if( responderManager.failCallback )
					{
						try
						{
							responderManager.failCallback( null );
						} 
						catch(error:Error) 
						{
							Flox.logWarning("[NetConnectionManager] Try/Catch du call du NetConnectionManager");
							if( CONFIG::DEBUG ) throw error;
						}
					}
				}
				responderManager = null;
				return;
			}
			
			_activeCalls[ commandName ] = responderManager;
			if( !(screenName in _callsByScreen) )
				_callsByScreen[ screenName ] = new Dictionary();
			_callsByScreen[ screenName ][ commandName ] = responderManager;
			
			if( _encrypt )
			{
				// create parameters
				var parameters:Object = { serviceName:_serviceName, functionName:functionToCallName, parameters:args };
				// create a new dynamic key and update the dynamic encryption with it
				responderManager.dynamicEncryptionKey = _cryptageDyn.createNewKey();
				_cryptageDyn.updateKey(responderManager.dynamicEncryptionKey);
				// encrypt the whole object whith the dynamic key
				var encryptedParameters:String =  _cryptageDyn.encrypt( JSON.stringify(parameters) );
				// then insert the new dynamic key in the middle of the result
				var strTemp:String = encryptedParameters.substring(0, int(encryptedParameters.length) / 2) + responderManager.dynamicEncryptionKey + encryptedParameters.substring(int(encryptedParameters.length) / 2);
				// encrypt the new string with the static encryption key
				responderManager.encryptedParams = _cryptageDef.encrypt(strTemp);
				
				// remote call
				_nc.call(_encryptionBridge, responderManager, responderManager.encryptedParams);
			}
			else
			{
				// create parameters
				responderManager.params = [(_serviceName + "." + functionToCallName), responderManager].concat(args);
				
				// remote call
				_nc.call.apply(null, responderManager.params);
			}
		}
		
		public function reportError(data:Object, callbacks:Array, screenName:String, maxAttempts:int):void
		{
			var responderManager:NetResponder = createResponder(callbacks, "", maxAttempts, screenName, [data]);
			_nc.call(_reportErrorFunctionName, responderManager, data);
		}
		
		/**
		 * Retry all pending calls that previously failed. Each call have a maximum
		 * attempts value which will be incremented each time this function is
		 * ran. When the maximum is reach, the <code>maxAttemptsCallback</code>
		 * is called.
		 */		
		private function reCall(responderManager:NetResponder):void 
		{
			responderManager.numAttempts++;
			if( (responderManager.maxAttempts != -1 && responderManager.numAttempts >= responderManager.maxAttempts) || !_hostAvailable )
			{
				// PushPartie should not be called here because the condition is not strict ( >= maxAttempts )
				// so no need to do something special for this case I guess because the function should be called
				// only once
				delete _activeCalls[ responderManager.command ];
				delete _callsByScreen[ responderManager.associatedScreenName ][ responderManager.command ];
				
				if( responderManager.maxAttemptsCallback )
				{
					try
					{
						responderManager.maxAttemptsCallback( { queryName:responderManager.command } );
					} 
					catch(error:Error) 
					{
						Flox.logWarning("[NetConnectionManager] Try/Catch du reCall du NetConnectionManager");
						if( CONFIG::DEBUG ) throw error;
					}
				}
			}
			else
			{
				if (_encrypt)
					_nc.call(_encryptionBridge, responderManager, responderManager.encryptedParams);
				else
					_nc.call.apply(null, responderManager.params);
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Callback functions
		
		/**
		 * The call is a success, this function will remove the corresponding responder
		 * from the dictionnaries, decrypt and deserialize (if necessary) the result
		 * returned by php and then call the success callback.
		 * 
		 * @param result The result returned by AmfPHP. This result is encrypted or not
		 * 				 depending on the value of <code>_encrypt</code>.
		 * @param res The ResponderManager associated to this call.
		 */		
		private function onValidCall(result:Object, responderManager:NetResponder):void
		{
			// the call have been deleted, then we have nothing to do
			if( !(responderManager.command in _activeCalls) )
				return;
			
			delete _activeCalls[ responderManager.command ];
			delete _callsByScreen[ responderManager.associatedScreenName ][ responderManager.command ];
			
			// if we have a result object and if it is encrypted, we
			// decrypt and deserialize it
			if( result )
			{
				if( _encrypt )
				{
					if( _cryptageDyn.KK != responderManager.dynamicEncryptionKey )
						_cryptageDyn.updateKey( responderManager.dynamicEncryptionKey );
					result = JSON.parse( _cryptageDyn.decrypt(result.toString()) );
					
					// a null object can be encrypted apparently, so when we decrypt the
					// "result" which is not null, the result can be a null object that
					// will create a bug later
					if( result == null ) result = {};
				}
			}
			else
			{
				result = {};
			}
			
			// then call the success callback function
			if( _genericSuccessCallback )
			{
				try
				{
					_genericSuccessCallback(result, responderManager.command, responderManager.successCallback);
				} 
				catch(error:Error) 
				{
					Flox.logWarning("[NetConnectionManager] Try/Catch of onValidCall.");
					if( CONFIG::DEBUG ) throw error;
				}
			}
			else
			{
				if( responderManager.successCallback )
				{
					try
					{
						result.queryName = responderManager.command;
						responderManager.successCallback(result);
					} 
					catch(error:Error) 
					{
						Flox.logWarning("[NetConnectionManager] Try/Catch of onValidCall.");
						if( CONFIG::DEBUG ) throw error;
					}
				}
			}
		}
		
		/**
		 * Callback function called whenever an error occurs when we run a function in the
		 * remote class.
		 * 
		 * <p>Most of time, this occurs when the function is not defined remotely (deleted,
		 * renamed, etc.) or when there is a fatal error, sql error and when the error handler
		 * plugin is set up in AmfPhp.</p>
		 * 
		 * @param result The error object
		 * @param responder The associated ResponderManager
		 */		
		private function onErrorCall(error:Object, responderManager:NetResponder):void
		{
			log("[NetConnectionManager] Error calling " + responderManager.command + " : " + error.faultString);
			
			// the call have been deleted, then we have nothing to do
			if( !(responderManager.command in _activeCalls) )
				return;
			
			delete _activeCalls[ responderManager.command ];
			delete _callsByScreen[ responderManager.associatedScreenName ][ responderManager.command ];
			
			if( _genericFailureCallback )
			{
				try
				{
					_genericFailureCallback(error, responderManager.command, responderManager.failCallback);
				} 
				catch(error:Error) 
				{
					Flox.logWarning("[NetConnectionManager] Try/Catch of onErrorCall.");
					if( CONFIG::DEBUG ) throw error;
				}
			}
			else
			{
				if( responderManager.failCallback )
				{
					try
					{
						error.queryName = responderManager.command;
						responderManager.failCallback(error);
					} 
					catch(error:Error) 
					{
						Flox.logWarning("[NetConnectionManager] Try/Catch of onErrorCall.");
						if( CONFIG::DEBUG ) throw error;
					}
				}
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Handlers
		
		/**
		 * Status handler.
		 * 
		 * 
		 */		
		private function netStatusHandler(event:NetStatusEvent, responderManager:NetResponder = null):void 
		{
			log("[NetConnectionManager] NetStatusHandler : " + event.info.code);
			switch (event.info.code)
			{
				case "NetConnection.Call.Failed":
				{
					// we get into this case when we try to run a request but the net
					// connection is not connected to the gateway (wrong url or maybe
					// the server is down). That's why we need to try to reconnect here.
					log("[NetConnectionManager] Could not connect to " + _completeGatewayUrl + ". Retry...");
					connect();
					
					break;
				}
				case "NetConnection.Connect.Closed": 
				case "NetConnection.Call.BadVersion":
				{
					// Failure executing a request due to a fatal error, a php error or some spaces /
					// at the end of the php file (after "?>") or maybe a static method the is called
					// (which works on the backoffice but not in the application, method that calls
					// functions of another php file in which we do one or more "require_once" whithin
					// the constructor (which never gets called then)
					
					// if the net connection is not connected to the gateway, when we try to send a
					// request, the event will never be NetConnection.Call.BadVersion but
					// NetConnection.Connect.Closed and NetConnection.Call.Failed instead.
					// The problem is that we need to try to reconnect first (this is done in
					// the NetConnection.Call.Failed) and then, re-run the request through the
					// NetConnection.Connect.Closed case so that the number of tries can be
					// decremented and stopped after the maximum number is reached.That's why we
					// cannot seperate both cases.
					
					/*
						Requete -> attente sur l'appli -> retour : ok
						Requete -> quitter l'appli -> revenir -> retour : ok
						Requete -> quitter et ne pas revenir -> retour ok même si en tâche de fond
						Requete -> perte de connexion -> nouvelle connexion -> pas de retour
					*/
					
					if( !_isTimerRunning )
					{
						// launch the timer with the start value (TIMER_BASE_VALUE = 2000)
						_isTimerRunning = true;
						_timerRestart = TIMER_BASE_VALUE;
						HeartBeat.registerFunction( updateTimer );
					}
					
					break;
				}
				case "NetConnection.Connect.NetworkChange":
				{
					// we get into this case when a network change is detected (whether when a
					// connection is back or lost).
					
					if( _isTimerRunning && AirNetworkInfo.networkInfo.isConnected() )
					{
						// stop everything
						HeartBeat.unregisterFunction(updateTimer);
						
						for each(var respMa:NetResponder in _activeCalls )
							reCall( respMa );
						
						_isTimerRunning = false;
					}
					
					break;
				}
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Responder
		
		/**
		 * Creates a ResponderManager.
		 * 
		 * @param callbacks An array of callback functions.
		 * @param commandName
		 * @param maxAttempts
		 * @param screenName
		 * 
		 * @return A ResponderManager.
		 */		
		private function createResponder(callbacks:Array, commandName:String, maxAttempts:int, screenName:String, params:Array):NetResponder
		{
			var responderManager:NetResponder = new NetResponder
			(
				function(result:*):void      { onValidCall(result, responderManager); },
				function(result:Object):void { onErrorCall(result, responderManager); }
			);
			
			responderManager.successCallback = callbacks[0] as Function;
			responderManager.maxAttemptsCallback = callbacks[1] as Function;
			responderManager.failCallback = callbacks[2] as Function;
			responderManager.command = commandName;
			responderManager.maxAttempts = maxAttempts;
			responderManager.associatedScreenName = screenName;
			responderManager.params = params;
			
			return responderManager;
		}
		
//------------------------------------------------------------------------------------------------------------
//	Internal update
		
		private function updateTimer(frameElapsedTime:int, totalElapsedTime:int):void
		{
			_timerRestart -= frameElapsedTime;
			if( _timerRestart <= 0 )
			{
				if( AirNetworkInfo.networkInfo.isConnected() )
				{
					log("[NetConnectionManager] Relaunching timer.");
					// start a new call
					HeartBeat.unregisterFunction(updateTimer);
					
					for each(var responderManager:NetResponder in _activeCalls )
						reCall( responderManager );
						
					_isTimerRunning = false;
				}
				else
				{
					log("[NetConnectionManager] Cannot relaunch timer.");
					_timerRestart = TIMER_BASE_VALUE;
				}
				
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Clear
		
		/**
		 * Clears all responders associated to a screen.
		 * 
		 * @param screenName The associated screen id.
		 */		
		public function clearAllRespondersOfScreen(screenName:String):void
		{
			if( screenName in _callsByScreen )
			{
				// there are active calls associated to this screen to remove
				for each( var responderManager:NetResponder in _callsByScreen[ screenName ] )
				{
					// removing the command from both active calls and for this screen
					delete _activeCalls[ responderManager.command ];
					delete _callsByScreen[ screenName ][ responderManager.command ];
				}
			}
			delete _callsByScreen[ screenName ];
		}
		
		/**
		 * Clears all responders.
		 */		
		public function clearAllResponders():void
		{
			var deleteScreen:Boolean = true;
			for each( var responderManager:NetResponder in _activeCalls )
			{
				// clears the responder "responderManager.command" for screen "responderManager.associatedScreenName"
				delete _activeCalls[ responderManager.command ];
				delete _callsByScreen[ responderManager.associatedScreenName ][ responderManager.command ];
				
				for each( var responderManagerForScreen:NetResponder in _callsByScreen[ responderManager.associatedScreenName ] )
					deleteScreen = false;
				
				if( deleteScreen )
					delete _callsByScreen[ responderManager.associatedScreenName ]
			}
		}
		
		public function failAndClearAllResponders():void
		{
			log("[NetConnectionManager] failAllResponders");
			
			var deleteScreen:Boolean = true;
			for each( var responderManager:NetResponder in _activeCalls )
			{
				log("[NetConnectionManager] Failing and clearing responder '" + responderManager.command + "' for screen " + responderManager.associatedScreenName);
				
				if( _genericFailureCallback )
				{
					_genericFailureCallback( null, responderManager.command, responderManager.failCallback );
				}
				else
				{
					if( responderManager.failCallback )
						responderManager.failCallback( null ); // TODO A checker
				}
				return;
				
				delete _activeCalls[ responderManager.command ];
				delete _callsByScreen[ responderManager.associatedScreenName ][ responderManager.command ];
				
				for each( var responderManagerForScreen:NetResponder in _callsByScreen[ responderManager.associatedScreenName ] )
					deleteScreen = false;
				
				if( deleteScreen )
					delete _callsByScreen[ responderManager.associatedScreenName ]
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	GET - SET
		
		public function get appName():String { return _serviceName; }
		public function set appName(value:String):void { _serviceName = value; }
		
		public function get bridgeName():String { return _encryptionBridge; }
		public function set bridgeName(value:String):void { _encryptionBridge = value; }
		
		public function get reportErrorFunctionName():String { return _reportErrorFunctionName; }
		public function set reportErrorFunctionName(value:String):void { _reportErrorFunctionName = value; }
		
		public function set baseGatewayUrl(value:String):void { _baseGatewayUrl = value; }
		public function get baseGatewayUrl():String { return _baseGatewayUrl; }
		
		public function set genericSuccessCallback(value:Function):void { _genericSuccessCallback = value; }
		public function get genericSuccessCallback():Function { return _genericSuccessCallback; }
		
		public function set genericFailureCallback(value:Function):void { _genericFailureCallback = value; }
		public function get genericFailureCallback():Function { return _genericFailureCallback; }
		
		public function set amfPath(value:String):void { _amfPath = value; }
		public function get amfPath():String { return _amfPath; }
		
		public function set gatewayPortNumber(value:int):void { _gatewayPortNumber = value; }
		public function get gatewayPortNumber():int { return _gatewayPortNumber; }
		
		public function get hostAvailable():Boolean { return _hostAvailable; }
		
		public function get isTimerRunning():Boolean { return _isTimerRunning; }
		
		public function set encrypt(value:Boolean):void
		{
			_encrypt = value;
			if (_encrypt)
			{
				_cryptageDef = new Encryption('9Bfu4dUi');
				_cryptageDyn = new Encryption('9Bfu4dUi');
			}
		}
		
		private var _isSecuredHttpConnection:Boolean = false;
		
		public function get useSecureConnection():Boolean { return _isSecuredHttpConnection }
		public function set useSecureConnection(value:Boolean):void
		{
			if( value )
			{
				baseGatewayUrl.replace("http", "https");
				_isSecuredHttpConnection = true;
			}
			else
			{
				baseGatewayUrl.replace("https", "http");
				_isSecuredHttpConnection = false;
			}
		}
		
	}
}