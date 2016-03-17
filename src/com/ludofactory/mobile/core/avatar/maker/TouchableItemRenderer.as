/*
Copyright © 2006-2014 Ludo Factory
Framework mobile - Globbies
Author  : Maxime Lhoez
Created : 15 Décembre 2014
*/
package com.ludofactory.mobile.core.avatar.maker
{
	
	import com.ludofactory.common.utils.logs.log;
	
	import flash.geom.Rectangle;
	
	import starling.display.ButtonState;
	import starling.display.DisplayObject;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	
	/**
	 * Globbies items list renderer.
	 */	
	public class TouchableItemRenderer extends CustomDefaultListItemRenderer
	{

	// ---------- Touch

		/**
		 * Max drag distance after the touch is released. */
		private static const MAX_DRAG_DIST:Number = 50;
		/**
		 * Current touch state. */
		protected var _currentTouchState:String;
		/**
		 * Whether the user is over this item renderer. */
		protected var _isOver:Boolean = false;
		
		private var _targetTouch:DisplayObject;
		
		public function TouchableItemRenderer()
		{
			super();
			
			// act as a single container for touch events (improves performances)
			//touchGroup = true;
			useHandCursor = true;
			targetTouch = this;
		}
		
		override protected function initialize():void
		{
			super.initialize();
		}
		
		public function set targetTouch(value:DisplayObject):void
		{
			if(value == null)
			{
				if(_targetTouch)
					_targetTouch.removeEventListener(TouchEvent.TOUCH, onTouch);
				_targetTouch = null;
			}
			else
			{
				if(_targetTouch)
					_targetTouch.removeEventListener(TouchEvent.TOUCH, onTouch);
				_targetTouch = value;
				_targetTouch.addEventListener(TouchEvent.TOUCH, onTouch);
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Touch handler

		/**
		 * Touch handler.
		 */
		protected function onTouch(event:TouchEvent):void
		{
			var touch:Touch = event.getTouch(_targetTouch);
			if (touch == null)
			{
				state = ButtonState.UP;
			}
			else if (touch.phase == TouchPhase.HOVER)
			{
				state = ButtonState.OVER;
			}
			else if (touch.phase == TouchPhase.BEGAN && _currentTouchState != ButtonState.DOWN)
			{
				state = ButtonState.DOWN;
			}
			else if (touch.phase == TouchPhase.MOVED && _currentTouchState == ButtonState.DOWN)
			{
				// reset button when user dragged too far away after pushing
				var buttonRect:Rectangle = getBounds(stage);
				if (touch.globalX < buttonRect.x - MAX_DRAG_DIST || touch.globalY < buttonRect.y - MAX_DRAG_DIST ||
						touch.globalX > buttonRect.x + buttonRect.width + MAX_DRAG_DIST ||
						touch.globalY > buttonRect.y + buttonRect.height + MAX_DRAG_DIST)
				{
					state = ButtonState.UP;
				}
			}
			else if (touch.phase == TouchPhase.ENDED && _currentTouchState == ButtonState.DOWN)
			{
				onTriggered();
			}
		}
		
		protected function onTriggered():void
		{
			
		}
	    
		/**
		 * Updates the current touch state.
		 */
		public function set state(value:String):void
		{
			_currentTouchState = value;
			
			switch (_currentTouchState)
			{
				case ButtonState.DOWN: { break; }
				case ButtonState.DISABLED: { break; }
				case ButtonState.UP:
				{
					if(_isOver)
					{
						_isOver = false;
						onRollOut(); 
					}
					break;
				}
				case ButtonState.OVER:
				{
					if(!_isOver)
					{
						_isOver = true;
						onRollOver();
					}
					break;
				}
				default: { throw new ArgumentError("Invalid button state: " + _currentTouchState); }
			}
		}
		
		protected function onRollOver():void
		{
			
		}
		
		protected function onRollOut():void
		{
			
		}
		
		override public function onScroll(event:Event = null):void
		{
			state = ButtonState.UP;
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
		
		override public function dispose():void
		{
			targetTouch = null;
			
			super.dispose();
		}
	}
}