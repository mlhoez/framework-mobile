/*
Copyright © 2006-2015 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 6 janv. 2013
*/
package com.ludofactory.mobile.core.manager
{
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	
	/**
	 * Adds a <code>InfoContent</code> above everything.
	 * 
	 * <p>This component will show a message with an optional
	 * icon / loader / component.</p>
	 * 
	 * @see com.ludofactory.mobile.core.manager.InfoContent
	 */
	public class InfoManager
	{
		/**
		 * The default display time. */		
		public static const DEFAULT_DISPLAY_TIME:Number = 2.25;
		/**
		 * The content to display. */		
		private static var _content:InfoContent = new InfoContent();
		/**
		 * Whether the popup is displaying or not. */		
		private static var _isDisplaying:Boolean = false;
		
		/**
		 * Callback associated to the message displayed.  */		
		private static var _currentCallback:Function;
		/**
		 * Parameters associated to the current callbakc. */		
		private static var _callbackParams:Array;
		
//------------------------------------------------------------------------------------------------------------
//	Static functions
		
		/**
		 * Shows a full screen overlay containing a custom message and a loader
		 * and cannot be closed manually by the user.
		 * 
		 * @param message The message to display
		 */		
		public static function show(message:String):void
		{
			if( _isDisplaying )
				return;
			
			_isDisplaying = true;
			
			_content.alpha = 0;
			Starling.current.stage.addChild(_content);
			_content.message = message;
			_content.closable = false;
			
			Starling.juggler.tween(_content, 0.25, { alpha:1 });
		}
		
		/**
		 * Shows a timed popup containing a custom message and an icon (whether
		 * a loader / image or nothing). It can be closed at any time by the user.
		 * 
		 * @param message The message to display
		 * @param timeToDisplay The time the message will be shown
		 * @param iconId The icon to display
		 * 
		 * @see com.ludofactory.mobile.core.manager.InfoContent
		 */		
		public static function showTimed(message:String, timeToDisplay:Number = DEFAULT_DISPLAY_TIME, iconId:int = InfoContent.ICON_CHECK):void
		{
			if( _isDisplaying )
				return;
			
			_isDisplaying = true;
			
			_content.alpha = 0;
			_content.addEventListener(TouchEvent.TOUCH, onTouchPopup);
			Starling.current.stage.addChild(_content);
			_content.message = message;
			_content.closable = true;
			_content.icon = iconId;
			
			Starling.juggler.tween(_content, 0.25, { alpha:1 });
			Starling.juggler.tween(_content, 0.25, { delay:timeToDisplay, alpha:0, onComplete:removeContent } );
		}
		
		/**
		 * Hides the message, updating the text and icon displayed.
		 * 
		 * @param message The message to display
		 * @param iconId The icon to display
		 * @param delay The delay before the message automatically closes
		 * @param callback (Optional) A callback function called when the message is closed
		 * @param callbackParams (Optional) The callbakc parameters
		 * @param component (Optional) Closes the message with a custom component (replacing the default content)
		 */		
		public static function hide(message:String, iconId:int = InfoContent.ICON_CHECK, delay:Number = DEFAULT_DISPLAY_TIME, callback:Function = null, callbackParams:Array = null, component:DisplayObject = null):void
		{
			_currentCallback = callback;
			_callbackParams = callbackParams;
			
			if( !_isDisplaying )
			{
				// in case the message was not displaying, we directly
				// call the callback function here and the return.
				exectueCallback();
				return;
			}
			
			if( component )
			{
				// we need to close the message with a custom component
				_content.component = component;
			}
			else
			{
				// simply close the message
				_content.message = message;
				_content.icon = iconId;
			}
			
			_content.closable = true;
			_content.addEventListener(TouchEvent.TOUCH, onTouchPopup);
			
			Starling.juggler.tween(_content, 0.25, { delay:delay, alpha:0, onComplete:removeContent } );
		}
		
//------------------------------------------------------------------------------------------------------------
//	Handlers
		
		/**
		 * Closes the message when the user touch it.
		 */		
		public static function onTouchPopup(event:TouchEvent):void
		{
			var touch:Touch = event.getTouch(_content, TouchPhase.ENDED);
			if( touch )
			{
				_content.removeEventListener(TouchEvent.TOUCH, onTouchPopup);
				Starling.juggler.removeTweens(_content);
				exectueCallback();
				hide("", InfoContent.ICON_NOTHING, 0);
			}
			touch = null;
		}
		
		/**
		 * Removes the message from the stage.
		 */
		public static function removeContent(callback:Function = null, callbackParams:Array = null):void
		{
			if( !_isDisplaying )
				return;
			
			_content.removeEventListener(TouchEvent.TOUCH, onTouchPopup);
			_content.removeFromParent();
			
			_isDisplaying = false;
			
			exectueCallback();
		}
		
		/**
		 * Executes the callback function.
		 */		
		private static function exectueCallback():void
		{
			if( _currentCallback )
			{
				if( _callbackParams )
					_currentCallback.apply(null, _callbackParams);
				else
					_currentCallback();
			}
			
			_currentCallback = null;
			_callbackParams = null;
		}
		
//------------------------------------------------------------------------------------------------------------
//	Get / Set
		
		/**
		 * Whether the message is displaying.
		 */		
		public static function get isDisplaying():Boolean { return _isDisplaying; }
	}
}