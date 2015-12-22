/*
 Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
 Framework mobile
 Author  : Maxime Lhoez
 Created : 17 sept. 2013
 */
package com.ludofactory.mobile.core.avatar.maker.sections
{
	
	import com.ludofactory.desktop.core.StarlingRoot;
	import com.ludofactory.globbies.events.AvatarMakerEventTypes;
	import com.ludofactory.ludokado.config.AvatarGenderType;
	import com.ludofactory.ludokado.config.LudokadoBones;
	import com.ludofactory.ludokado.manager.LKConfigManager;
	import com.ludofactory.server.CustomDefaultListItemRenderer;
	import com.ludofactory.server.starling.theme.Theme;
	import com.ludofactory.server.starling.theme.Theme;
	
	import feathers.controls.Callout;
	
	import flash.geom.Rectangle;
	
	import starling.display.ButtonState;
	import starling.display.Image;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.text.TextField;
	import starling.text.TextFieldAutoSize;
	import starling.textures.Texture;
	import starling.utils.VAlign;
	
	/**
	 * Item renderer used to display the customer service messages.
	 */
	public class SectionItemRenderer extends CustomDefaultListItemRenderer
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
		/**
		 * Item baclground. */
		private var _background:Image;
		
		private var _sectionImage:Image;
		
		public function SectionItemRenderer()
		{
			super();
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			this.useHandCursor = true;
			
			_background = new Image(Theme.sectionButtonIdleBackground);
			addChild(_background);
			
			this.width = _background.width;
			this.height = _background.height;
			
			//_sectionImage = new Image(StarlingRoot.assets.getTexture("TEMP-section-icon"));
			//addChild(_sectionImage);
			
			_calloutLabel = new TextField(125, 5, "", Theme.FONT_OSWALD, 12, 0xffffff);
			_calloutLabel.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
			_calloutLabel.touchable = false;
			
			addEventListener(TouchEvent.TOUCH, onTouch);
		}
		
		override protected function draw():void
		{
			var dataInvalid:Boolean = this.isInvalid(INVALIDATION_FLAG_DATA);
			var sizeInvalid:Boolean = this.isInvalid(INVALIDATION_FLAG_SIZE);
			
			if(dataInvalid)
			{
				this.commitData();
			}
			
			if(dataInvalid || sizeInvalid)
			{
				
			}
		}
		
		private function getImage(boneName:String):Texture
		{
			switch (boneName)
			{
				case LudokadoBones.BEARD: { return StarlingRoot.assets.getTexture("selector-beard-human"); }
				case LudokadoBones.EYEBROWS: { return StarlingRoot.assets.getTexture("selector-eyebrows"); }
				case LudokadoBones.EYES: { return LKConfigManager.currentGenderId == AvatarGenderType.POTATO ? StarlingRoot.assets.getTexture("selector-eyes-potato") : StarlingRoot.assets.getTexture("selector-eyes-human"); }
				case LudokadoBones.FACE_CUSTOM: { return StarlingRoot.assets.getTexture("selector-faceCustom-human"); }
				case LudokadoBones.HAIR: { return StarlingRoot.assets.getTexture("selector-hair-human"); }
				case LudokadoBones.HAT: { return StarlingRoot.assets.getTexture("selector-hat"); }
				case LudokadoBones.LEFT_HAND: { return StarlingRoot.assets.getTexture("selector-leftHand"); }
				case LudokadoBones.RIGHT_HAND: { return StarlingRoot.assets.getTexture("selector-rightHand"); }
				case LudokadoBones.MOUSTACHE: { return StarlingRoot.assets.getTexture("selector-moustache"); }
				case LudokadoBones.MOUTH: { return StarlingRoot.assets.getTexture("selector-mouth"); }
				case LudokadoBones.NOSE: { return LKConfigManager.currentGenderId == AvatarGenderType.POTATO ? StarlingRoot.assets.getTexture("selector-nose-potato") : StarlingRoot.assets.getTexture("selector-nose-human"); }
				case LudokadoBones.SHIRT: { return StarlingRoot.assets.getTexture("selector-shirt"); }
				case LudokadoBones.EPAULET: { return StarlingRoot.assets.getTexture("selector-epaulet"); }
				default: { throw new Error("Missing section icon : " + boneName); }
			}
		}
		
		protected function commitData():void
		{
			if(this._owner && _data)
			{
				// _data.title; // TODO callout
				if(!_sectionImage)
				{
					_sectionImage = new Image(getImage(_data.asociatedBone));
					addChild(_sectionImage);
				}
				else
					_sectionImage.texture = getImage(_data.asociatedBone);
				
				if(_data.forceTrigger)
				{
					_data.forceTrigger = false;
					onTriggered();
				}
				
				_background.texture = (!_isChoosed && _data.isChoosed) ? Theme.sectionButtonSelectedBackground : Theme.sectionButtonIdleBackground;
			}
		}
		
		private var _isChoosed:Boolean = false;
		
//------------------------------------------------------------------------------------------------------------
//	Handlers
		
		/**
		 * Touch handler.
		 */
		protected function onTouch(event:TouchEvent):void
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
		}
		
		/**
		 * The item is triggered.
		 */
		protected function onTriggered():void
		{
			dispatchEventWith(AvatarMakerEventTypes.PART_SELECTED, true, _data.asociatedBone);
		}
		
		private var _callout:Callout;
		/**
		 * Whether the callout is displaying. */
		private var _isCalloutDisplaying:Boolean = false;
		/**
		 * Callout label. */
		private var _calloutLabel:TextField;
		
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
					_background.texture = _data.isChoosed ? Theme.sectionButtonSelectedBackground : Theme.sectionButtonIdleBackground;
					_isOver = false;
					
					if(_callout)
					{
						_isCalloutDisplaying = false;
						_callout.close(true);
						_callout = null;
					}
					
					break;
				}
				case ButtonState.OVER:
				{
					_background.texture = _data.isChoosed ? Theme.sectionButtonSelectedBackground : Theme.sectionButtonOverBackground;
					
					_isOver = true;
					
					if(!_isCalloutDisplaying)
					{
						_isCalloutDisplaying = true;
						_calloutLabel.text = _data.title;
						_callout = Callout.show(_calloutLabel, this, Callout.DIRECTION_UP, false);
						//_callout.minWidth = 125;
						_callout.focusPaddingTop = 20;
						_callout.disposeContent = false;
						_callout.touchable = false;
					}
					
					break;
				}
				default: { throw new ArgumentError("Invalid button state: " + _currentTouchState); }
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Get - Set
		
		/**
		 * Data is an array of SectionData items used to build the sublist. */
		protected var _data:SectionData;
		
		override public function get data():Object
		{
			return this._data;
		}
		
		override public function set data(value:Object):void
		{
			if(this._data == value)
				return;
			
			this._data = SectionData(value);
			this.invalidate(INVALIDATION_FLAG_DATA);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
		
		override public function dispose():void
		{
			owner = null;
			
			removeEventListener(TouchEvent.TOUCH, onTouch);
			
			_background.removeFromParent(true);
			_background = null;
			
			_calloutLabel.removeFromParent(true);
			_calloutLabel = null;
			
			if(_callout)
			{
				_isCalloutDisplaying = false;
				_callout.close(true);
				_callout = null;
			}
			
			_data = null;
			
			super.dispose();
		}
		
	}
}