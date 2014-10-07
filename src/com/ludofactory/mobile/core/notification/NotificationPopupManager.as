/**
 * Created by Max on 27/09/2014.
 */
package com.ludofactory.mobile.core.notification
{

	import com.greensock.TweenMax;
	import com.ludofactory.mobile.core.events.LudoEventType;
	import com.ludofactory.mobile.core.test.config.GlobalConfig;

	import feathers.controls.ScrollContainer;

	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.display.Quad;
	import starling.events.Event;

	public class NotificationPopupManager
	{
		/**
		 * The overlay.
		 */
		private static var _overlay:DisplayObject;
		
		/**
		 * The currently displayed notification.
		 */
		private static var _currentNotification:NotificationPopup;
		
		/**
		 * Determines if a notification is currently displaying.
		 */
		public static var isNotificationDisplaying:Boolean = false;

		/**
		 * Initializes the popup.
		 * 
		 * <p>I did this because at the first call of addNotification, the content
		 * was not well placed.</p>
		 */
		public static function initializeNotification():void
		{
			if( !_currentNotification )
			{
				_currentNotification = new NotificationPopup();
				_currentNotification.x = GlobalConfig.stageWidth * 0.025;
				_currentNotification.y = GlobalConfig.stageWidth * 0.02;
				_currentNotification.width = GlobalConfig.stageWidth * 0.95;
				_currentNotification.height = GlobalConfig.stageHeight * 0.95;
				Starling.current.stage.addChild(_currentNotification);
				Starling.current.stage.removeChild(_currentNotification);

				_overlay = new Quad(GlobalConfig.stageWidth, GlobalConfig.stageHeight, 0x000000);
				_overlay.alpha = 0;
				_overlay.visible = false;
			}
		}

//------------------------------------------------------------------------------------------------------------
//	API

		/**
		 * Adds a notification on the screen.
		 */
		public static function addNotification(content:AbstractNotificationPopupContent, callback:Function = null):void
		{
			if( isNotificationDisplaying )
			{
				closeNotification();
				TweenMax.delayedCall(0.75, addNotification, [content]);
				return;
			}
			
			Starling.current.stage.addChild(_overlay);
			TweenMax.to(_overlay, 0.5, { autoAlpha:0.75 });

			Starling.current.stage.addChild(_currentNotification);
			_currentNotification.addEventListener(LudoEventType.CLOSE_NOTIFICATION, onNotificationClosed);
			_currentNotification.setContentAndCallBack(content, callback);
			_currentNotification.animateIn();
			
			isNotificationDisplaying = true;
		}

		/**
		 * Tihs function is meant to be called whenever we need to close a notification.
		 */
		public static function closeNotification():void
		{
			if( isNotificationDisplaying )
				_currentNotification.close();
		}

//------------------------------------------------------------------------------------------------------------
//	Handlers

		/**
		 * When the notification have been closed, whether when the user touches the close
		 * button or when we explicitly request it from the closeNotification function.
		 */
		private static function onNotificationClosed(event:Event):void
		{
			isNotificationDisplaying = false;
			_currentNotification.removeEventListener(LudoEventType.CLOSE_NOTIFICATION, onNotificationClosed);
			TweenMax.to(_overlay, 0.5, { autoAlpha:0 });
			_currentNotification.animateOut();
		}
		
	}
}
