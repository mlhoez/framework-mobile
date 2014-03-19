/*
LudoFactory
Framework mobile
Author  : Maxime Lhoez
Created : 11 oct. 2013
*/
package com.ludofactory.mobile.core.test.event
{
	import com.freshplanet.nativeExtensions.AirNetworkInfo;
	import com.greensock.TweenMax;
	import com.greensock.easing.Back;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.authentication.MemberManager;
	import com.ludofactory.mobile.core.notification.NotificationManager;
	import com.ludofactory.mobile.core.remoting.Remote;
	import com.ludofactory.mobile.core.test.EventNotification;
	import com.ludofactory.mobile.core.test.RateNotification;
	import com.ludofactory.mobile.core.test.config.GlobalConfig;
	import com.ludofactory.mobile.core.test.engine.EventPushNotification;
	
	import app.AppEntryPoint;
	
	import starling.core.Starling;
	import starling.events.Event;

	/**
	 * The event manager.                                                                                                                                                                                                                                                                                                                                                              
	 */	
	public class EventManager
	{
		/**
		 * Whether the user is already getting an event.
		 * Avoids multiple calls. */		
		private var _isGettingEvent:Boolean = false;
		
		public function EventManager()
		{
			
		}
		
		/**
		 * Checks if there is an event to display for this player.
		 */		
		public function getEvent():void
		{
			if( !_isGettingEvent && AirNetworkInfo.networkInfo.isConnected() && MemberManager.getInstance().isLoggedIn() )
			{
				_isGettingEvent = true;
				Remote.getInstance().getEvent(onGetEventSuccess, onGetEventFailure, onGetEventFailure, 2);
			}
		}
		
		private var _fullScreenEvent:*; // FIXME Mettre un type ici
		
		/**
		 * The event have been retreived successfully.
		 */		
		private function onGetEventSuccess(result:Object):void
		{
			_isGettingEvent = false;
			
			switch(result.code)
			{
				case 1: // common event
				{
					switch( int(result.type) )
					{
						case 1: // event
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
								_fullScreenEvent.scaleX = _fullScreenEvent.scaleY = 0;
							}
							else
							{
								NotificationManager.addNotification( new EventNotification( new EventData(result) ) );
							}
							
							break;
						}
						case 2: // rate
						{
							NotificationManager.addNotification( new RateNotification( new EventData(result) ) );
							break;
						}
						case 3: // push
						{
							NotificationManager.addNotification( new EventPushNotification(AbstractEntryPoint.screenNavigator.activeScreenID) );
							break;
						}
						case 4: // evenementiel Facebook (association de compte) - en full screen
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
							_fullScreenEvent.scaleX = _fullScreenEvent.scaleY = 0;
								
							break;
						}
					}
					break;
				}
			}
		}
		
		private function onEventLoaded(event:Event):void
		{
			_fullScreenEvent.removeEventListener(Event.COMPLETE, onEventLoaded);
			TweenMax.to(_fullScreenEvent, 0.75, { scaleX:1, scaleY:1, ease:Back.easeOut });
		}
		
		private function onCloseFullScreenEvent(event:Event):void
		{
			_fullScreenEvent.removeEventListener(Event.COMPLETE, onEventLoaded);
			_fullScreenEvent.removeEventListener(Event.CLOSE, onCloseFullScreenEvent);
			TweenMax.to(_fullScreenEvent, 0.55, { scaleX:0, scaleY:0, ease:Back.easeIn, onComplete:disposeFullScreenEvent });
		}
		
		private function disposeFullScreenEvent():void
		{
			_fullScreenEvent.removeFromParent(true);
			_fullScreenEvent = null;
		}
		
		/**
		 * The event could not be retreived.
		 */		
		private function onGetEventFailure(error:Object = null):void
		{
			_isGettingEvent = false;
		}
	}
}