/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 1 oct. 2013
*/
package com.ludofactory.mobile.core.push
{
	
	import com.freshplanet.nativeExtensions.AirNetworkInfo;
	import com.ludofactory.common.utils.logs.log;
	import com.ludofactory.mobile.core.HeartBeat;
	import com.ludofactory.mobile.core.events.MobileEventTypes;
	import com.ludofactory.mobile.core.manager.MemberManager;
	import com.ludofactory.mobile.core.remoting.Remote;
	
	import starling.events.EventDispatcher;
	
	/**
	 * The PushManager handles the possibility to store some data in order to push
	 * it later when an Internet connection is available.
	 * 
	 * <p>The items are processed one by one, in a chrocologic way so that we can
	 * keep the correct order, so we push the next only if the previous one have
	 * successfully been pushed.</p>
	 */	
	public class PushManager extends EventDispatcher
	{
		/**
		 * The base update time (3000 = 3 sec) */		
		private static const BASE_TIME:int = 3000;
		/**
		 * The current time */		
		private var _currentTime:Number;
		
		/**
		 * Whether the push manager's timer is running. */		
		private var _isRunning:Boolean = false;
		/**
		 * Whether we are pushing an element. */		
		private var _isPushing:Boolean = false;
		/**
		 * Whether the manager is enabled. */		
		private var _isEnabled:Boolean = true;
		/**
		 * If true, when a push is done, the push manager will be stopped.
		 * It is mainly called when a user wants to disconnect so that
		 * we can wait for the push to finish, and then allow the user to
		 * do something else. */		
		private var _needsLock:Boolean = false;
		
		/**
		 * The elements to push. */		
		private var _elementsToPush:Vector.<AbstractElementToPush> = new Vector.<AbstractElementToPush>();
		
		/**
		 * The callback function called when we requested a needsLock (when
		 * a push is done, whether it is a success or not, we will call this
		 * callback and then stop the manager. This is called from the class
		 * MemberManager when the user wants to disconnect */		
		private var _callback:Function;
		
		/**
		 * The type of the element which is currently being pushed. it is used
		 * in order to know which element have been pushed and thus, which function
		 * to call to handle the result. */		
		private var _currentElementToPushType:String = "";
		
		/**
		 * Whether the PushManager is initialized. */		
		private var _isInitialized:Boolean = false;
		
		/**
		 * When the PushManager is created and if the user is currently logged in,
		 * we check if there are some elements to push. If so, we start the manager,
		 * otherwise, nothing is done here and the manager will be wainting for elements
		 * to push.
		 * 
		 * <p>If the user is currently not logged in, we reset the badge number so that
		 * an anonymous member won't see a badge in the icon when finally at the launch
		 * of the application he won't see anything.</p>
		 * 
		 * <p>Every element added and / or removed from the <code>_elementsToPush</code>
		 * list is relative to a user. For security reason, before a user can log out, we
		 * lock the game if a push is pending so that when we receive the callback, we make
		 * sure that the <code>obj_membre_mobile</code> data won't be parsed to a wrong user.</p>
		 */		
		public function PushManager()
		{
			
		}
		
		public function initialize():void
		{
			log("[PushManager] initializing....");
			if( MemberManager.getInstance().isLoggedIn() )
			{
				_elementsToPush = MemberManager.getInstance().elementsToPush;
				
				if( _elementsToPush.length > 0 )
				{
					log("[PushManager] The user is logged in and there are " + _elementsToPush.length + " elements to push.");
					start();
				}
				else
				{
					log("[PushManager] The user is logged in but there is no element to push.");
				}
			}
			else
			{
				log("[PushManager] The user is NOT logged in.");
				
				_elementsToPush = new Vector.<AbstractElementToPush>();
			}
			
			dispatchEventWith(MobileEventTypes.UPDATE_HEADER);
			_isInitialized = true;
		}
		
		/**
		 * Starts the PushManager.
		 * 
		 * <p>The PushManager will be started only if it is not already pushing
		 * something, if it is not already running and if the user is logged in
		 * (another check just in case).</p>
		 * 
		 * <p>This function is called only when a user just logged in, so that we
		 * know that we can start to check if he has some elements to push.</p>
		 */		
		public function start():void
		{
			if( _isEnabled && !_isPushing && !_isRunning && MemberManager.getInstance().isLoggedIn() )
			{
				log("[PushManager] Starting timer - next push in " + (BASE_TIME / 1000) + " seconds.");
				
				_isRunning = true;
				_currentTime = BASE_TIME;
				HeartBeat.registerFunction(onTimerUpdate);
			}
		}
		
		/**
		 * Stops the PushManager if it was running.
		 */		
		private function stop():void
		{
			if( _isRunning )
			{
				_isRunning = false;
				HeartBeat.unregisterFunction(onTimerUpdate);
			}
		}
		
		/**
		 * When a user log out, we need to stop the manager (i.e the timer),
		 * clean the <code>_elementsToPush</code> array and reset the badge
		 * number.
		 */		
		public function onUserLoggedOut():void
		{
			stop();
			_elementsToPush = new Vector.<AbstractElementToPush>();
			dispatchEventWith(MobileEventTypes.UPDATE_HEADER);
		}
		
		/**
		 * When the user logged in, we retreive the elements to push and then
		 * if there are some, we start the timer. */		
		public function onUserLoggedIn():void
		{
			stop();
			
			_elementsToPush = MemberManager.getInstance().elementsToPush;
			
			if( _elementsToPush.length > 0 )
			{
				log("[PushManager] The user is logged in and there are " + _elementsToPush.length + " elements to push.");
				start();
			}
			else
			{
				log("[PushManager] The user is logged in but there is no element to push.");
			}
			
			dispatchEventWith(MobileEventTypes.UPDATE_HEADER);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Add / remove elements
//------------------------------------------------------------------------------------------------------------
		
		/**
		 * Adds an element to list and updates the <code>elementsToPush</code>
		 * list of the current user in the EncryptedLocalStore.
		 * 
		 * <p>Then, if the timer is not running, we start it so that
		 * elements can be pushed after a few seconds. We won't try to
		 * push the element right away because it would be stupid since
		 * we added an element because we couldn't push it.</p>
		 * 
		 * <p>In order to work, the element to push must extend the class
		 * <code>AbstractElementToPush</code>.</p>
		 * 
		 * @param elementToPush The element to push.
		 * 
		 * @see com.ludofactory.mobile.push.AbstractElementToPush
		 */		
		public function addElementToPush(elementToPush:AbstractElementToPush):void
		{
			if( MemberManager.getInstance().isLoggedIn() )
			{
				log("[PushManager] an element was added to the list : " + elementToPush);
				
				_elementsToPush.push( elementToPush );
				MemberManager.getInstance().elementsToPush = _elementsToPush;
				
				// this check is done in start() but just to make sure...
				if( !_isPushing && !_isRunning )
					start();
				
				dispatchEventWith(MobileEventTypes.UPDATE_HEADER);
			}
		}
		
		/**
		 * This function is called only when the user has finished playing a game
		 * and the game session have been pushed successfully.
		 * 
		 * <p>Because the user can leave the application at any time, we need to store
		 * the game session at the start of the game (the score will be set to -1 so
		 * that we know that the game was aborted), then if he leaves, we know that
		 * we need to push it next time.</p>
		 */		
		public function removeLastGameSession(gameSession:GameSession):void
		{
			if( MemberManager.getInstance().isLoggedIn() )
			{
				_elementsToPush.splice( _elementsToPush.indexOf(gameSession), 1 );
				MemberManager.getInstance().elementsToPush = _elementsToPush;
				dispatchEventWith(MobileEventTypes.UPDATE_HEADER);
			}
		}
		
		/**
		 * This function is called internally whenever a element have been pushed. Because
		 * each element have been added in a chronologic way and because we push the elements
		 * one by one, we are sure that when this function is called, the first element we 
		 * want to remove is the one that have been pushed.
		 * 
		 * <p>Because the user can't log out while a push is pending, we are sure that when
		 * we try to remove the element from the list, it is the correct one associated to
		 * the current player.</p>
		 */		
		private function removeFirstElement():void
		{
			if( MemberManager.getInstance().isLoggedIn() )
			{
				var elementToRemove:AbstractElementToPush = _elementsToPush.shift();
				log("[PushManager] removing first element because it have been pushed : " + elementToRemove);
				MemberManager.getInstance().elementsToPush = _elementsToPush;
				
				dispatchEventWith(MobileEventTypes.UPDATE_HEADER);
			}
		}
		
		/**
		 * The function is called when the drawer (i.e when the AlertContainer)
		 * is hidden.
		 * 
		 * <p>Each element with state PUSHED will be remove from the list so that
		 * wo won't show them again to the user.</p>
		 */		
		public function removeAllPushedElementsAfterBeeingSeen():void
		{
			if( MemberManager.getInstance().isLoggedIn() )
			{
				var elementsToRemove:Array = [];
				var element:AbstractElementToPush;
				var len:int = _elementsToPush.length;
				var change:Boolean = false;
				for(var i:int = 0; i < len; i++)
				{
					element = _elementsToPush[i];
					if( element.state == PushState.PUSHED )
						elementsToRemove.push( element );
				}
				
				while ( elementsToRemove.length != 0 )
				{
					change = true;
					element = elementsToRemove.shift();
					_elementsToPush.splice( _elementsToPush.indexOf( element ), 1 );
				}
				elementsToRemove = null;
				
				if( change )
				{
					MemberManager.getInstance().elementsToPush = _elementsToPush;
					dispatchEventWith(MobileEventTypes.UPDATE_HEADER);
				}
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Main push
//------------------------------------------------------------------------------------------------------------
		
		/**
		 * This is the main push function.
		 * 
		 * <p>Because each element to push extends <code>AbstractElementToPush</code>,
		 * we can know what type of element we need to push (thanks to the <code>type
		 * </code> property), thus which remote function to call.</p>
		 * 
		 * <p>In case a pushed have been sent and the user left the application before
		 * the callback was called, we need to check the current state of the push to
		 * know if we need to push it again or not.</p>
		 * 
		 * <p>If the device is connected, we set the <code>_isPushing</code> property
		 * to true to indicate that a push is pending. This way, nothing else can be
		 * pushed at the same time while the current is not over. Note that the disconnect
		 * function of the <code>MemberManager</code> will also be locked while the push
		 * is not done (for security reason).</p>
		 * 
		 * @see com.ludofactory.mobile.push.AbstractElementToPush
		 */		
		private function push():void
		{
			// just for security reason...
			if( MemberManager.getInstance().isLoggedIn() )
			{
				if( _elementsToPush.length > 0 )
				{
					if( AirNetworkInfo.networkInfo.isConnected() && !Remote.getInstance().isTimerRunning ) // 
					{
						_isPushing = true;
						stop();
						
						var len:int = _elementsToPush.length;
						var elementToPush:AbstractElementToPush;
						var canStop:Boolean = true;
						for(var i:int = 0; i < len; i++)
						{
							elementToPush = _elementsToPush[i];
							
							if( elementToPush.state == PushState.PENDING )
							{
								// this element have been sent but the user probably left before
								// receiving the callback. In this case we can remove this element
								// and launch a push again
								_elementsToPush.splice(i, 1);
								MemberManager.getInstance().elementsToPush = _elementsToPush;
								dispatchEventWith(MobileEventTypes.UPDATE_HEADER);
								push();
								return;
							}
							
							if( elementToPush.state == PushState.WAITING )
							{
								canStop = false;
								
								// update the state
								elementToPush.state = PushState.PENDING;
								MemberManager.getInstance().elementsToPush = _elementsToPush;
								_currentElementToPushType = elementToPush.pushType;
								
								// then we can push
								switch(elementToPush.pushType)
								{
									case PushType.GAME_SESSION:
									{
										Remote.getInstance().pushGame( GameSession(elementToPush), onPushSuccess, onPushFailure, onPushFailure, 1);
										break;
									}
										
									case PushType.TROPHY:
									{
										Remote.getInstance().pushTrophy( PushTrophy(elementToPush).trophyId, onPushSuccess, onPushFailure, onPushFailure, 2 );
										break;
									}
								}
								break;
							}
						}
						
						if( canStop )
						{
							// no elements to push, (probably all with state PUSHED), stop the manager
							_isPushing = false;
							stop();
						}
					}
					else
					{
						// try again later
						_isPushing = false;
						start();
					}
				}
				else
				{
					// no elements to push, stop the manager
					_isPushing = false;
					stop();
				}
			}
			else
			{
				// not logged in, stop the manager
				_isPushing = false;
				stop();
			}
		}
		
		/**
		 * The element have been successfully pushed.
		 * 
		 * <p>In this case and if everything is fine (resut.code => 1), this
		 * means that we can remove the element from the user's elementsToPush
		 * list and update the badge number accordingly.</p>
		 * 
		 * <p>IMPORTANT : if the property <code>_needsLock</code> is set to true
		 * and if there are still some elements to push pending, we must stop the
		 * manager anyway and then call the callback function (is there is one set).
		 * This is mainly called by the <code>MemberManager</code> class when a user
		 * wants to disconnect but there is a push pending.</p>
		 * 
		 * <p>Since there are possibly many codes to handle, we simply check if the
		 * push was ok (code 1). Otherwise, we  will log an error with the code and
		 * message.</p>
		 */		
		private function onPushSuccess(result:Object):void
		{
			_isPushing = false;
			
			log("[PushManager] The first element could be pushed [code " + result.code + " => " + result.txt + "].");
			
			// handle specific behavior here
			switch(_currentElementToPushType)
			{
				case PushType.GAME_SESSION:
				{
					break;
				}
				case PushType.TROPHY:
				{
					
					break;
				}
			}
			
			var len:int = _elementsToPush.length;
			var element:AbstractElementToPush;
			for(var i:int = 0; i < len; i++)
			{
				element = _elementsToPush[i];
				if( element.state == PushState.PENDING && element.pushType == _currentElementToPushType )
				{
					// we know that pushes are made from the begining to the end
					// of the list, thus, we are sure that the first element we
					// will get here (if the state is not already 'pushed" is the
					// element that have just been pushed.
					element.state = PushState.PUSHED;
					element.pushSuccessMessage = result.txt;
					
					// Case 1 : we don't store the returns
					_elementsToPush.splice( i, 1);
					MemberManager.getInstance().elementsToPush = _elementsToPush;
					dispatchEventWith(MobileEventTypes.UPDATE_HEADER);
					
					// Case 2 : we store the returns
					//MemberManager.getInstance().setElementToPush( _elementsToPush );
					//dispatchEventWith(LudoEventType.UPDATE_ALERT_CONTAINER_LIST);
					
					break; // don't update all elements !
				}
			}
			
			_currentElementToPushType = "";
			
			if( !_needsLock )
			{
				push();
			}
			else
			{
				_needsLock = false;
				if( _callback )
					_callback();
				_callback = null;
			}
		}
		
		/**
		 * The element could not be pushed, in this case we need to start again the
		 * manager to try again in a few seconds.
		 * 
		 * <p>If we need a lock, the manager will remain stopped and if there is one,
		 * the callback function will me called.</p>
		 */		
		private function onPushFailure(error:Object = null):void
		{
			log("[PushManager] The first element could not be pushed.");
			log(error);
			
			_isPushing = false;
			_currentElementToPushType = "";
			
			if( !_needsLock )
			{
				push();
			}
			else
			{
				_needsLock = false;
				if( _callback )
					_callback();
				_callback = null;
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Timer function
//------------------------------------------------------------------------------------------------------------
		
		/**
		 * The main timer update function.
		 */		
		private function onTimerUpdate(frameElapsedTime:int, totalElapsedTime:int):void
		{
			_currentTime -= totalElapsedTime;
			
			if( _currentTime <= 0 )
			{
				_currentTime = BASE_TIME;
				push(); // all the checks are done inside push()
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Get / Set
//------------------------------------------------------------------------------------------------------------
		
		/**
		 * Returns the number of elements to push for the current player.
		 * 
		 * This function is called from the Main class when the app is deactivated.
		 */		
		public function get numElementsToPush():int
		{
			return MemberManager.getInstance().isLoggedIn() ? _elementsToPush.length : 0;
		}
		
		public function get numGameSessionsToPush():int
		{
			if( MemberManager.getInstance().isLoggedIn() )
			{
				var len:int = _elementsToPush.length;
				var count:int = 0;
				for(var i:int = 0; i < len; i++)
				{
					if( AbstractElementToPush( _elementsToPush[i] ).state == PushState.WAITING && AbstractElementToPush( _elementsToPush[i] ).pushType == PushType.GAME_SESSION )
						count++;
				}
				return count;
			}
			else
			{
				return 0;
			}
		}
		
		public function get numTrophiesToPush():int
		{
			if( MemberManager.getInstance().isLoggedIn() )
			{
				var len:int = _elementsToPush.length;
				var count:int = 0;
				for(var i:int = 0; i < len; i++)
				{
					if( AbstractElementToPush( _elementsToPush[i] ).state == PushState.WAITING && AbstractElementToPush( _elementsToPush[i] ).pushType == PushType.TROPHY )
						count++;
				}
				return count;
			}
			else
			{
				return 0;
			}
		}
		
		public function get elementsToPush():Vector.<AbstractElementToPush> { return _elementsToPush; }
		
		public function get callback():Function { return _callback; }
		public function set callback(val:Function):void { _callback = val; }
		
		public function get needsLock():Boolean { return _needsLock; }
		public function set needsLock(val:Boolean):void { _needsLock = val; }
		
		public function get isPushing():Boolean { return _isPushing; }
		
		public function get isInitialized():Boolean { return _isInitialized; }
		
		public function get isEnabled():Boolean { return _isEnabled; }
		public function set isEnabled(val:Boolean):void
		{
			if( _isEnabled == val )
				return;
			
			_isEnabled = val;
			
			if( _isEnabled )
			{
				start();
			}
			else
			{
				stop();
			}
		}
		
	}
}