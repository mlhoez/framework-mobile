package com.ludofactory.mobile.core.notification
{
	import com.greensock.TweenMax;
	import com.ludofactory.mobile.core.events.MobileEventTypes;
	import AbstractNotification;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.display.DisplayObjectContainer;
	import starling.display.Quad;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	
	/**
	 * This is a custom notification manager.
	 * 
	 * <p>It will add some content to a predefined notification container, which is
	 * a <code>NotificationContainer</code>. The notification will slide from the
	 * bottom above a blurred black overlay.</p>
	 * 
	 * @see com.ludofactory.mobile.core.notification.NotificationContainer
	 */	
	public class NotificationManager
	{
		/**
		 * The currently displayed notification.
		 */		
		private static var _currentNotification:AbstractNotification;
		
		/**
		 * The close callback associated to the currently displayed
		 * notification.
		 */		
		private static var _currentNotificationCloseCallback:Function;
		
		/**
		 * The overlay.
		 */
		private static var _overlay:DisplayObject;
		
		/**
		 * Determines if a notification is currently displaying.
		 */		
		public static var isNotificationDisplaying:Boolean = false;
		
		/**
		 * Adds a notification to the stage.
		 */
		public static function addNotification(notificationContent:AbstractNotification, closeCallback:Function = null, flatten:Boolean = true):void
		{
			if( isNotificationDisplaying )
			{
				closeNotification();
				TweenMax.delayedCall(0.75, addNotification, [notificationContent, closeCallback, flatten]);
				return;
			}
			
			const calculatedRoot:DisplayObjectContainer = Starling.current.stage;
			
			_overlay = defaultOverlayFactory();
			_overlay.width = GlobalConfig.stageWidth;
			_overlay.height = GlobalConfig.stageHeight;
			calculatedRoot.addChild(_overlay);
			
			_currentNotification = notificationContent;
			_currentNotification.visible = true;
			_currentNotification.touchable = false;
			_currentNotification.width = GlobalConfig.stageWidth;
			_currentNotification.addEventListener(MobileEventTypes.CLOSE_NOTIFICATION, removeNotification);
			calculatedRoot.addChild(_currentNotification);
			_currentNotification.validate();
			_currentNotification.y = GlobalConfig.stageHeight;
			if( flatten )
				_currentNotification.flatten();
			
			_currentNotificationCloseCallback = closeCallback;
			
			TweenMax.to(_overlay, 0.5, { delay:0.1, alpha:0.75, onComplete:_overlay.addEventListener, onCompleteParams:[TouchEvent.TOUCH, onCloseNotification] });
			TweenMax.to(_currentNotification, 0.5, { delay:0.1, y:(calculatedRoot.stage.stageHeight - _currentNotification.height), onComplete:function():void{ _currentNotification.unflatten(); _currentNotification.touchable = true; } });
			
			isNotificationDisplaying = true;
		}
		
		/**
		 * Replace the notification on the stage.
		 * 
		 * <p>This is generally called when a notification content have
		 * changed and the notification size is different.</p>
		 */		
		public static function replaceNotification():void
		{
			const correctNotificationY:Number = GlobalConfig.stageHeight - _currentNotification.height;
			if( _currentNotification.y != correctNotificationY )
			{
				//TweenMax.killTweensOf(_currentNotification); // lag
				TweenMax.to(_currentNotification, 0.5, { delay:0.1, y:correctNotificationY, onComplete:function():void{ _currentNotification.unflatten(); _currentNotification.touchable = true; } });
			}
		}
		
		/**
		 * This function is meant to be called wherever in the
		 * application when we need to close a currently displaying
		 * notification.
		 */		
		public static function closeNotification():void
		{
			if( isNotificationDisplaying && _currentNotification )
				_currentNotification.onClose();
		}
		
//------------------------------------------------------------------------------------------------------------
//	Handlers
//------------------------------------------------------------------------------------------------------------
		
		/**
		 * This function is called when the black overlay is touched.
		 * 
		 * <p>It will call the <code>onClose</code> function of the
		 * AbstractNotification so that an event of type <code>
		 * LudoEventType.CLOSE_NOTIFICATION</code> is dispatched
		 * and the notification manager know it has to close the
		 * current notification.</p>
		 */		
		private static function onCloseNotification(event:TouchEvent):void
		{
			var touch:Touch = event.getTouch(DisplayObject(event.target));
			if( touch && touch.phase == TouchPhase.BEGAN )
				_currentNotification.onClose();
			touch = null;
		}
		
		/**
		 * Removes a pop-up from the stage.
		 * 
		 * <p>This function is called when the close button or the overlay
		 * have been touched. In both cases, the onClose function of the
		 * AbstractNotification is called, which will dispatch an event
		 * of type LudoEventType.CLOSE_NOTIFICATION that will trigger this
		 * callback function.</p>
		 */
		private static function removeNotification(data:Object):void
		{
			if( !_currentNotification )
				return;
			
			// doing this will avoid a bug where the onComplete function of replaceNotification()
			// is called after the tweened popup have been removed
			TweenMax.killTweensOf(_currentNotification);
			
			_overlay.removeEventListener(TouchEvent.TOUCH, onCloseNotification);
			
			_currentNotification.removeEventListener(MobileEventTypes.CLOSE_NOTIFICATION, removeNotification);
			_currentNotification.touchable = false;
			_currentNotification.flatten();
			
			TweenMax.to(_overlay, 0.25, { alpha:0 });
			TweenMax.to(_currentNotification, 0.25, { y:GlobalConfig.stageHeight, onComplete:clearPopup });
			
			if( _currentNotificationCloseCallback )
				_currentNotificationCloseCallback(data);
		}
		
		/**
		 * When the close animation of the current notification is over,
		 * this function will destroy both the overlay and the notification
		 * to free memory space.
		 */		
		private static function clearPopup():void
		{
			if( _currentNotification )
			{
				_currentNotification.unflatten();
				_currentNotification.visible = false;
				_currentNotification.removeFromParent(true);
				_currentNotification = null;
			}
			
			if( _overlay )
			{
				_overlay.removeFromParent(true);
				_overlay = null;
			}
			
			_currentNotificationCloseCallback = null;
			
			isNotificationDisplaying = false;
		}
		
		/**
		 * The default factory that creates overlays for modal pop-ups.
		 */
		public static function defaultOverlayFactory():DisplayObject
		{
			const quad:Quad = new Quad(100, 100, 0x000000);
			quad.alpha = 0;
			return quad;
		}
	}
}