package com.ludofactory.mobile.application.ios
{
	import com.demonsters.debugger.MonsterDebugger;
	import com.ludofactory.common.utils.log;
	
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.RemoteNotificationEvent;
	import flash.events.StatusEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestDefaults;
	import flash.net.URLRequestMethod;
	import flash.notifications.NotificationStyle;
	import flash.notifications.RemoteNotifier;
	import flash.notifications.RemoteNotifierSubscribeOptions;

	/*_________________________________________________________________________________________
	|
	| Auteur      : Maxime Lhoez
	| Création    : 3 oct. 2012
	| Description : 
	|________________________________________________________________________________________*/
	
	public class RemoteNotifierManager
	{
		private static const URBAN_AIRSHIP_API:String    = "https://go.urbanairship.com/api/device_tokens/";
		private static const URBAN_AIRSHIP_SERVER:String = "go.urbanairship.com";
		private static const APP_KEY:String              = "GhdXe60yTqukqnRMndtJBQ";
		private static const APP_SECRET:String           = "5mqDijuESOy0Gfsa9smqsQ";
		
		private static var _instance:RemoteNotifierManager;
		
		private var _preferredStyles:Vector.<String>;
		private var _subscribeOptions:RemoteNotifierSubscribeOptions;
		private var _remoteNotifier:RemoteNotifier;
		
		public function RemoteNotifierManager(sk:securityKey)
		{
			// Subscribe to all three styles of push notifications : ALERT, BADGE, and SOUND.
			_preferredStyles = new Vector.<String>();
			_preferredStyles.push(NotificationStyle.ALERT, NotificationStyle.BADGE, NotificationStyle.SOUND);
			
			_subscribeOptions = new RemoteNotifierSubscribeOptions();
			_subscribeOptions.notificationStyles = _preferredStyles; 
			
			_remoteNotifier = new RemoteNotifier();
			_remoteNotifier.addEventListener(RemoteNotificationEvent.TOKEN, onSubscriptionSuccess); 
			_remoteNotifier.addEventListener(RemoteNotificationEvent.NOTIFICATION, onNotificationReceived); 
			_remoteNotifier.addEventListener(StatusEvent.STATUS, onSubscriptionFail);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Singleton
//------------------------------------------------------------------------------------------------------------
		
		/**
		 * Subscribes if possible to Apple Push Notifications.
		 * 
		 * Apple recommends that each time an app activates, it subscribes for push notifications.
		 * Before subscribing to push notifications, ensure the device supports it by checking the
		 * <code>supportedNotificationStyles</code>. It returns the types of notifications that
		 * the OS platform supports.
		 */		
		public function subscribe():void
		{
			if(RemoteNotifier.supportedNotificationStyles.toString() != "")
			{
				_remoteNotifier.subscribe(_subscribeOptions);
			}
			else
			{
				log("Remote Notifications are not supported on this platform !");
			}
		}
		
		/**
		 * Unsubscribe from push notifications.
		 */		
		public function unsubscribe():void
		{
			log("Unsubscribe.");
			_remoteNotifier.unsubscribe();
		}
		
//------------------------------------------------------------------------------------------------------------
//	Subscribe Handlers
//------------------------------------------------------------------------------------------------------------
		
		/**
		 * If the <code>subscribe()</code> request succeeds, a RemoteNotificationEvent of type <code>TOKEN</code>
		 * is received, from which we can retrieve the token id (evt.tokenId). This one will be used to register
		 * with the server provider such as Urban Airship.
		 * 
		 * @param evt
		 */		
		private function onSubscriptionSuccess(evt:RemoteNotificationEvent):void 
		{ 
			log("Subscribe succeeded - token id is "+ evt.tokenId);
			
			// send the token id to the server
			var urlreq:URLRequest = new URLRequest( new String(URBAN_AIRSHIP_API + evt.tokenId) );
			urlreq.authenticate = true;
			urlreq.method = URLRequestMethod.PUT;
			URLRequestDefaults.setLoginCredentialsForHost(URBAN_AIRSHIP_SERVER, APP_KEY, APP_SECRET);
			
			var urlLoad:URLLoader = new URLLoader();
			urlLoad.load(urlreq);
			urlLoad.addEventListener(IOErrorEvent.IO_ERROR, iohandler);
			urlLoad.addEventListener(Event.COMPLETE, compHandler);
			urlLoad.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpHandler);
		}
		
		/**
		 * If the subscription request fails.
		 * 
		 * @param evt
		 */		
		private function onSubscriptionFail(evt:StatusEvent):void
		{
			log("Subscription failed, level :" + evt.level +" - event code : " + evt.code + "currentTarget : " + evt.currentTarget.toString()); 
		} 
		
		/**
		 * A notification payload data is received by the application.
		 * Use it in the application.
		 * 
		 * @param evt
		 */		
		private function onNotificationReceived(evt:RemoteNotificationEvent):void
		{
			log("Notification received.");
			
			for(var x:String in evt.data)
			{
				log(x + ": " + evt.data[x]);
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Registration Handlers
//------------------------------------------------------------------------------------------------------------
		
		/**
		 * When an error occurs while sending registering token id to the server.
		 * 
		 * @param evt
		 */		
		private function iohandler(evt:IOErrorEvent):void 
		{
			log("IOError : " + evt.errorID + " - " + evt.type);
		}
		
		/**
		 * When the registration of the token id on the server is complete.
		 * 
		 * @param evt
		 */		
		private function compHandler(evt:Event):void
		{
			log("Token id registration complete - status : " + evt.type);
		}
		
		/**
		 * HTTP Status
		 * 
		 * @param evt
		 */		
		private function httpHandler(evt:HTTPStatusEvent):void
		{
			log("HTTP Status : " + evt.status);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Singleton
//------------------------------------------------------------------------------------------------------------
		
		/**
		 * Returns RemoteNotifierManager instance.
		 * 
		 * @return 
		 */		
		public static function getInstance():RemoteNotifierManager
		{			
			if(_instance == null)
				_instance = new RemoteNotifierManager(new securityKey());			
			return _instance;
		}
	}
}

internal class securityKey{};