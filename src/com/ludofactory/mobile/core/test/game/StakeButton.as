/*
Copyright © 2006-2014 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 17 Août 2013
*/
package com.ludofactory.mobile.core.test.game
{
	import flash.geom.Point;
	
	import feathers.controls.LayoutGroup;
	import feathers.core.FeathersControl;
	import feathers.display.Scale9Image;
	
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	
	public class StakeButton extends FeathersControl
	{
		/**
		 * @private
		 */
		private static const HELPER_POINT:Point = new Point();
		
		/**
		 * The saved ID of the currently active touch. The value will be
		 * <code>-1</code> if there is no currently active touch.
		 *
		 * <p>For internal use in subclasses.</p>
		 */
		protected var touchPointID:int = -1;
		
		protected var _container:LayoutGroup;
		
		protected var _backgroundSkin:Scale9Image;
		protected var _backgroundDisabledSkin:Scale9Image;
		protected var _shadowThickness:int;
		
		protected var _scaleWhenDownValue:Number = 0.95;
		
		public function StakeButton()
		{
			super();
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			_container = new LayoutGroup();
			addChild(_container);
			
			_container.addChild(_backgroundSkin);
			_container.addChild(_backgroundDisabledSkin);
			
			addEventListener(TouchEvent.TOUCH, button_touchHandler);
		}
		
		public function set backgroundSkin(val:Scale9Image):void
		{
			_backgroundSkin = val;
		}
		
		public function set backgroundDisabledSkin(val:Scale9Image):void
		{
			_backgroundDisabledSkin = val;
		}
		
		public function set shadowThickness(val:int):void
		{
			_shadowThickness = val;
		}
		
//------------------------------------------------------------------------------------------------------------
//	Handlers
//------------------------------------------------------------------------------------------------------------
		
		protected function button_touchHandler(event:TouchEvent):void
		{
			/*if( !this._isEnabled )
			{
				this.touchPointID = -1;
				return;
			}*/
			
			if(this.touchPointID >= 0)
			{
				var touch:Touch = event.getTouch(this, null, this.touchPointID);
				if(!touch)
				{
					//this should never happen
					return;
				}
				
				touch.getLocation(this.stage, HELPER_POINT);
				const isInBounds:Boolean = this.contains(this.stage.hitTest(HELPER_POINT, true));
				if(touch.phase == TouchPhase.MOVED)
				{
					if(isInBounds)
					{
						_container.scaleX = _container.scaleY = _scaleWhenDownValue;
						_container.x = ((1.0 - _scaleWhenDownValue) / 2.0 * _container.width) << 0;
						_container.y = ((1.0 - _scaleWhenDownValue) / 2.0 * _container.height) << 0;
					}
					else
					{
						_container.scaleX = _container.scaleY = 1;
						_container.x = 0;
						_container.y = 0;
					}
				}
				else if(touch.phase == TouchPhase.ENDED)
				{
					this.touchPointID = -1;
					//we we dispatched a long press, then triggered and change
					//won't be able to happen until the next touch begins
					if(isInBounds)
					{
						triggerButton();
					}
				}
				return;
			}
			else //if we get here, we don't have a saved touch ID yet
			{
				touch = event.getTouch(this, TouchPhase.BEGAN);
				if(touch)
				{
					_container.scaleX = _container.scaleY = _scaleWhenDownValue;
					_container.x = ((1.0 - _scaleWhenDownValue) / 2.0 * _container.width) << 0;
					_container.y = ((1.0 - _scaleWhenDownValue) / 2.0 * _container.height) << 0;
					
					this.touchPointID = touch.id;
					return;
				}
				
				//end of hover
				_container.scaleX = _container.scaleY = 1;
				_container.x = 0;
				_container.y = 0;
			}
		}
		
		/**
		 * When the button is triggered.
		 */		
		protected function triggerButton():void
		{
			throw new Error("[GamePriceSelectionButton] triggerButton must be overridden."); 
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
//------------------------------------------------------------------------------------------------------------
		
		override public function dispose():void
		{
			removeEventListener(TouchEvent.TOUCH, button_touchHandler);
			
			_backgroundSkin.removeFromParent(true);
			_backgroundSkin = null;
			
			_backgroundDisabledSkin.removeFromParent(true);
			_backgroundDisabledSkin = null;
			
			_container.removeFromParent(true);
			_container = null;
			
			super.dispose();
		}
	}
}