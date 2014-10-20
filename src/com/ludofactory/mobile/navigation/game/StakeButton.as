/*
Copyright © 2006-2014 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 17 Août 2013
*/
package com.ludofactory.mobile.navigation.game
{

	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.theme.Theme;

	import feathers.controls.LayoutGroup;
	import feathers.core.FeathersControl;
	import feathers.display.Scale9Image;

	import flash.geom.Point;

	import starling.display.Image;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.text.TextField;

	public class StakeButton extends FeathersControl
	{
		/**
		 * Helper point. */
		private static const HELPER_POINT:Point = new Point();
		
		/**
		 * The saved ID of the currently active touch. The value will be
		 * <code>-1</code> if there is no currently active touch.
		 *
		 * <p>For internal use in subclasses.</p>
		 */
		protected var touchPointID:int = -1;

		/**
		 * The shadow thickness, used to layout some elements. */
		protected var _shadowThickness:int;

		/**
		 * The scale value when the button is pressed. */
		protected var _scaleWhenDownValue:Number = 0.95;

		/**
		 * The container. */
		protected var _container:LayoutGroup;
		
		/**
		 * The background skin. */
		protected var _backgroundSkin:Scale9Image;
		
		/**
		 * The icon. */
		protected var _icon:Image;
		
		/**
		 * The main label */
		protected var _label:TextField;
		
		public function StakeButton()
		{
			super();

			shadowThickness = 17 * GlobalConfig.dpiScale;
			minWidth = 60 * GlobalConfig.dpiScale;
			minHeight = 140 * GlobalConfig.dpiScale;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			_container = new LayoutGroup();
			addChild(_container);
			
			_backgroundSkin = new Scale9Image(Theme.buttonDisabledSkinTextures, GlobalConfig.dpiScale);
			_container.addChild(_backgroundSkin);
			
			_icon = new Image( AbstractEntryPoint.assets.getTexture("GameTypeSelectionPointsIcon") );
			_icon.scaleX = _icon.scaleY = GlobalConfig.dpiScale;
			_container.addChild(_icon);

			_label = new TextField(5, 5, "", Theme.FONT_SANSITA, scaleAndRoundToDpi(42), 0x002432);
			_label.autoScale = true;
			_container.addChild(_label);
			
			addEventListener(TouchEvent.TOUCH, button_touchHandler);
		}
		
		override protected function draw():void
		{
			super.draw();
			
			_backgroundSkin.width = this.actualWidth;
			_backgroundSkin.height = this.actualHeight;

			_icon.x = scaleAndRoundToDpi(40);
			_icon.y = (this.actualHeight - _icon.height) * 0.5;

			_label.width = actualWidth - _icon.x - _icon.width - _shadowThickness - scaleAndRoundToDpi(20);
			_label.height = this.actualHeight - (_shadowThickness * 2);
			_label.x = _icon.x + _icon.width + scaleAndRoundToDpi(10);
			_label.y = (actualHeight - _label.height) * 0.5;
		}
		
		public function set backgroundSkin(val:Scale9Image):void
		{
			_backgroundSkin = val;
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

			_label.removeFromParent(true);
			_label = null;

			_icon.removeFromParent(true);
			_icon = null;
			
			_container.removeFromParent(true);
			_container = null;
			
			super.dispose();
		}
	}
}