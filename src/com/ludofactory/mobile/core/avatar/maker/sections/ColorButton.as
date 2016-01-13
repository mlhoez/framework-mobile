/**
 * Created by Maxime on 29/09/15.
 */
package com.ludofactory.mobile.core.avatar.maker.sections
{
	
	import com.greensock.TweenMax;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.avatar.AvatarMakerAssets;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	
	import flash.geom.Rectangle;
	
	import starling.display.ButtonState;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	
	public class ColorButton extends Sprite
	{
		/**
		 * Max drag distance after the touch is released. */
		private static const MAX_DRAG_DIST:Number = 50;
		/**
		 * Current touch state. */
		protected var _currentTouchState:String;
		/**
		 * Whether the user is over this item renderer. */
		protected var _isOver:Boolean = false;
		
		/**
		 * Button background. */
		private var _background:Image;
		/**
		 * Palette. */
		private var _palette:Image;
		/**
		 * Red color. */
		private var _redColor:Image;
		/**
		 * Yellow color. */
		private var _yellowColor:Image;
		/**
		 * Blue color. */
		private var _blueColor:Image;
		/**
		 * Green color. */
		private var _greenColor:Image;
		
		public function ColorButton()
		{
			super();
			
			_background = new Image(AvatarMakerAssets.paletteBackground);
			_background.scaleX = _background.scaleY = GlobalConfig.dpiScale;
			addChild(_background);
			
			_palette = new Image(AvatarMakerAssets.paletteIcon);
			_palette.scaleX = _palette.scaleY = GlobalConfig.dpiScale;
			addChild(_palette);
			
			_redColor = new Image(AvatarMakerAssets.paletteColorRed);
			_redColor.scaleX = _redColor.scaleY = GlobalConfig.dpiScale;
			addChild(_redColor);
			
			_yellowColor = new Image(AvatarMakerAssets.paletteColorYellow);
			_yellowColor.scaleX = _yellowColor.scaleY = GlobalConfig.dpiScale;
			addChild(_yellowColor);
			
			_blueColor = new Image(AvatarMakerAssets.paletteColorBlue);
			_blueColor.scaleX = _blueColor.scaleY = GlobalConfig.dpiScale;
			addChild(_blueColor);
			
			_greenColor = new Image(AvatarMakerAssets.paletteColorGreen);
			_greenColor.scaleX = _greenColor.scaleY = GlobalConfig.dpiScale;
			addChild(_greenColor);
			
			//addEventListener(TouchEvent.TOUCH, onTouch);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Touch events
		
		/**
		 * Touch handler.
		 */
		/*protected function onTouch(event:TouchEvent):void
		{
			var touch:Touch = event.getTouch(this);
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
		}*/
		
		/*protected function onTriggered():void
		{
			//dispatchEventWith(AvatarMakerEventTypes.PART_SELECTED, true, _data.asociatedBone);
		}*/
		
		/**
		 * Updates the current touch state.
		 */
		/*public function set state(value:String):void
		{
			_currentTouchState = value;
			
			switch (_currentTouchState)
			{
				case ButtonState.DOWN: { break; }
				case ButtonState.DISABLED: { break; }
				case ButtonState.UP:{ _isOver = false; break; }
				case ButtonState.OVER:
				{
					if(!_isOver)
					{
						_isOver = true;
						animate();
					}
					
					break;
				}
				default: { throw new ArgumentError("Invalid button state: " + _currentTouchState); }
			}
		}*/
		
//------------------------------------------------------------------------------------------------------------
//	Animation
		
		private var _isAnimating:Boolean = false;
		
		public function animate():void
		{
			if(!_isAnimating)
			{
				_isAnimating = true;
				
				_palette.y = 0;
				_palette.scaleX = _palette.scaleY = GlobalConfig.dpiScale;
				TweenMax.killTweensOf(_palette);
				TweenMax.to(_palette, 0.18, { y:scaleAndRoundToDpi(-10), yoyo:true, repeat:1, scaleX:(GlobalConfig.dpiScale + (0.1 * GlobalConfig.dpiScale)), scaleY:(GlobalConfig.dpiScale + (0.1 * GlobalConfig.dpiScale)) });
				
				_redColor.y = 0;
				_redColor.scaleX = _redColor.scaleY = GlobalConfig.dpiScale;
				TweenMax.killTweensOf(_redColor);
				TweenMax.to(_redColor, 0.22, { y:-16, yoyo:true, repeat:1, scaleX:(GlobalConfig.dpiScale + (0.2 * GlobalConfig.dpiScale)), scaleY:(GlobalConfig.dpiScale + (0.2 * GlobalConfig.dpiScale)) });
				
				_yellowColor.y = 0;
				_yellowColor.scaleX = _yellowColor.scaleY = GlobalConfig.dpiScale;
				TweenMax.killTweensOf(_yellowColor);
				TweenMax.to(_yellowColor, 0.25, { y:-15, yoyo:true, repeat:1, scaleX:(GlobalConfig.dpiScale + (0.2 * GlobalConfig.dpiScale)), scaleY:(GlobalConfig.dpiScale + (0.2 * GlobalConfig.dpiScale)) });
				
				_blueColor.y = 0;
				_blueColor.scaleX = _blueColor.scaleY = GlobalConfig.dpiScale;
				TweenMax.killTweensOf(_blueColor);
				TweenMax.to(_blueColor, 0.28, { y:-12, yoyo:true, repeat:1, scaleX:(GlobalConfig.dpiScale + (0.2 * GlobalConfig.dpiScale)), scaleY:(GlobalConfig.dpiScale + (0.2 * GlobalConfig.dpiScale)) });
				
				_greenColor.y = 0;
				_greenColor.scaleX = _greenColor.scaleY = GlobalConfig.dpiScale;
				TweenMax.killTweensOf(_greenColor);
				TweenMax.to(_greenColor, 0.31, { y:-12, yoyo:true, repeat:1, scaleX:(GlobalConfig.dpiScale + (0.2 * GlobalConfig.dpiScale)), scaleY:(GlobalConfig.dpiScale + (0.2 * GlobalConfig.dpiScale)), onComplete:function():void{ _isAnimating = false; } });
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
		
		override public function dispose():void
		{
			//removeEventListener(TouchEvent.TOUCH, onTouch);
			
			_background.removeFromParent(true);
			_background = null;
			
			_palette.removeFromParent(true);
			_palette = null;
			
			_redColor.removeFromParent(true);
			_redColor = null;
			
			_yellowColor.removeFromParent(true);
			_yellowColor = null;
			
			_blueColor.removeFromParent(true);
			_blueColor = null;
			
			_greenColor.removeFromParent(true);
			_greenColor = null;
			
			super.dispose();
		}
		
	}
}