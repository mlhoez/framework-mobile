/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 11 oct. 2013
*/
package com.ludofactory.mobile.navigation.event
{
	
	import com.freshplanet.nativeExtensions.AirNetworkInfo;
	import com.greensock.TweenMax;
	import com.greensock.easing.Quad;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.manager.MemberManager;
	import com.ludofactory.mobile.core.notification.CustomPopupManager;
	import com.ludofactory.mobile.core.notification.content.EventPushNotificationContent;
	import com.ludofactory.mobile.core.notification.content.RateNotificationContent;
	import com.ludofactory.mobile.core.remoting.Remote;
	
	import starling.core.Starling;
	import starling.events.Event;
	
	/**
	 * The event manager.                                                                                                                                                                                                                                                                                                                                                              
	 */	
	public class EventManager
	{
		/**
		 * Whether the user is currently already fetching events.
		 * Avoids multiple calls. */		
		private var _isFetchingEvent:Boolean = false;
		
		/**
		 * Full screen event object. */
		private var _fullScreenEvent:AbstractFullScreenEvent;
		
		public function EventManager()
		{
			
		}
		
//------------------------------------------------------------------------------------------------------------
//	
		
		/**
		 * Checks if there is an event to display for this player.
		 */		
		/*public function getEvent():void
		{
			if( !_isFetchingEvent && AirNetworkInfo.networkInfo.isConnected() )
			{
				_isFetchingEvent = true;
				Remote.getInstance().getEvent(onGetEventSuccess, onGetEventFailure, onGetEventFailure, 1);
			}
		}*/
		
		/**
		 * The event have been retreived successfully.
		 */		
		private function onGetEventSuccess(result:Object):void
		{
			_isFetchingEvent = false;
			
			if(int(result.code) == 1)
			{
				switch(int(result.type))
				{
					case AppEventType.COMMON_EVENT:
					{
						if( result.full_screen == 1 )
						{
							_fullScreenEvent = new FullScreenEvent( new EventData(result) );
							_fullScreenEvent.width = GlobalConfig.stageWidth;
							_fullScreenEvent.height = GlobalConfig.stageHeight;
							_fullScreenEvent.addEventListener(Event.COMPLETE, onEventLoaded);
							_fullScreenEvent.addEventListener(Event.CLOSE, onCloseFullScreenEvent);
							(Starling.current.root as AbstractEntryPoint).addChild( _fullScreenEvent );
							_fullScreenEvent.alignPivot();
							_fullScreenEvent.x = _fullScreenEvent.width * 0.5;
							_fullScreenEvent.y = _fullScreenEvent.height * 0.5;
							_fullScreenEvent.alpha = 0;
							_fullScreenEvent.scaleX = _fullScreenEvent.scaleY = 1.2;
						}
						else
						{
							// TODO maybe use the new popup system do display a non-full screen event ?
							//NotificationManager.addNotification( new EventNotification( new EventData(result) ) );
						}
						
						break;
					}
					case AppEventType.RATE_EVENT:
					{
						CustomPopupManager.addPopup( new RateNotificationContent( new EventData(result) ) );
						break;
					}
					case AppEventType.PUSH_EVENT:
					{
						CustomPopupManager.addPopup( new EventPushNotificationContent(AbstractEntryPoint.screenNavigator.activeScreenID) );
						break;
					}
					case AppEventType.FACEBOOK_EVENT:
					{
						_fullScreenEvent = new FullScreenFacebookEvent( new EventData(result) );
						_fullScreenEvent.width = GlobalConfig.stageWidth;
						_fullScreenEvent.height = GlobalConfig.stageHeight;
						_fullScreenEvent.addEventListener(Event.COMPLETE, onEventLoaded);
						_fullScreenEvent.addEventListener(Event.CLOSE, onCloseFullScreenEvent);
						(Starling.current.root as AbstractEntryPoint).addChild( _fullScreenEvent );
						_fullScreenEvent.alignPivot();
						_fullScreenEvent.x = _fullScreenEvent.width * 0.5;
						_fullScreenEvent.y = _fullScreenEvent.height * 0.5;
						_fullScreenEvent.alpha = 0;
						_fullScreenEvent.scaleX = _fullScreenEvent.scaleY = 1.2;
						
						break;
					}
				}
			}
		}
		
		/**
		 * The event could not be retreived.
		 */
		private function onGetEventFailure(error:Object = null):void
		{
			_isFetchingEvent = false;
		}
		
//------------------------------------------------------------------------------------------------------------
//	Event loading handlers
		
		/**
		 * When the content of the event have been fully loaded, we can display it.
		 * 
		 * @param event
		 */
		private function onEventLoaded(event:Event):void
		{
			_fullScreenEvent.removeEventListener(Event.COMPLETE, onEventLoaded);
			TweenMax.to(_fullScreenEvent, 0.15, { delay:0.1, autoAlpha:1 });
			TweenMax.to(_fullScreenEvent, 0.4, { delay:0.1, scaleX:1, scaleY:1, ease:Quad.easeOut });
			TweenMax.delayedCall(1.5, _fullScreenEvent.enableEvent);
		}
		
		/**
		 * When the full screen event is closed, we hide and dispose it.
		 * 
		 * @param event
		 */
		private function onCloseFullScreenEvent(event:Event):void
		{
			// just in case
			_isFetchingEvent = false;
			
			_fullScreenEvent.removeEventListener(Event.COMPLETE, onEventLoaded);
			_fullScreenEvent.removeEventListener(Event.CLOSE, onCloseFullScreenEvent);
			TweenMax.to(_fullScreenEvent, 0.25, { alpha:0, onComplete:disposeFullScreenEvent });
		}
		
		/**
		 * Disposes the full screen event.
		 */
		private function disposeFullScreenEvent():void
		{
			_fullScreenEvent.removeFromParent(true);
			_fullScreenEvent = null;
		}
		
//------------------------------------------------------------------------------------------------------------
//	
		
		/**
		 * When the user logs out, we need to tall the app that we are not fetching an event anymore.
		 * 
		 * This way we avoid a special case where the EventManager could be stuck (we fetch an event,
		 * and before we are done we switch user : this way all the remote calls are killed, thus no
		 * callback function is called here and the property _isFetchingEvent is never updated and set
		 * back to false = we are stuck).
		 */
		public function onUserLoggedOut():void
		{
			// just in case the user quickly switch account while we are getting the events, in this special case
			// the boolean is never set back to false, so unless the user restarts the app, he won't be able to
			// retrieve the events
			_isFetchingEvent = false;
		}
		
	}
}