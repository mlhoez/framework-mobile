/**
 * Created by Maxime on 29/09/15.
 */
package com.ludofactory.mobile.core.avatar.maker.sections
{
	
	import com.greensock.TweenMax;
	import com.greensock.easing.Back;
	import com.greensock.easing.Linear;
	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.avatar.AvatarMakerAssets;
	import com.ludofactory.mobile.core.avatar.maker.LudokadoStarlingButton;
	import com.ludofactory.mobile.core.avatar.test.config.AvatarGenderType;
	import com.ludofactory.mobile.core.avatar.test.config.LudokadoBones;
	import com.ludofactory.mobile.core.avatar.test.events.LKAvatarMakerEventTypes;
	import com.ludofactory.mobile.core.avatar.test.manager.LKConfigManager;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	
	import feathers.controls.Callout;
	import feathers.core.FeathersControl;
	
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.extensions.pixelmask.PixelMaskDisplayObject;
	
	public class ColorSelector extends FeathersControl
	{
		
	// ---------- Layout properties
		
		/**
		 * Icons Y start position. */
		private static const ICONS_START_Y:int = 60;
		/**
		 * Icons X position. */
		private static const ICONS_POSITION_X:int = 12;
		/**
		 * Icons gap. */
		private static const ICONS_GAP:int = 5;
		
	// ---------- Common properties
		
		/**
		 * Color button. */
		private var _colorButton:ColorButton;
		
		/**
		 * Mask containing the icons. */
		private var _iconsMaskedContainer:PixelMaskDisplayObject;
		/**
		 * The mask used for the container. */
		private var _iconsMask:Image;
		
		/**
		 * Icons container. */
		private var _iconsContainer:Sprite;
		/**
		 * Icons background. */
		private var _iconsBackground:Image;
		/**
		 * Lips color icon. */
		private var _lipsColorButton:LudokadoStarlingButton;
		/**
		 * Skin color icon. */
		private var _skinColorButton:LudokadoStarlingButton;
		/**
		 * Eyes color icon. */
		private var _eyesColorButton:LudokadoStarlingButton;
		/**
		 * Hair color icon. */
		private var _hairColorButton:LudokadoStarlingButton;
		
		private var _allButtons:Vector.<LudokadoStarlingButton>;
		
		public function ColorSelector()
		{
			super();
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			_iconsMask = new Image(AvatarMakerAssets.iconsMask);
			_iconsMask.scaleX = _iconsMask.scaleY = GlobalConfig.dpiScale;
			_iconsMask.touchable = false;
			
			_iconsMaskedContainer = new PixelMaskDisplayObject(1, true);
			_iconsMaskedContainer.maskk = _iconsMask;
			addChild(_iconsMaskedContainer);
			
			_iconsContainer = new Sprite();
			_iconsBackground = new Image(AvatarMakerAssets.iconsBackground);
			_iconsBackground.scaleX = _iconsBackground.scaleY = GlobalConfig.dpiScale;
			_iconsBackground.touchable = false;
			// lips color
			_lipsColorButton = new LudokadoStarlingButton(AvatarMakerAssets.lipsColor, "", AvatarMakerAssets.lipsColorSelected);
			_lipsColorButton.isToolTipEnabled = true;
			_lipsColorButton.isToggle = true;
			_lipsColorButton.calloutText = _("Couleur des lèvres");
			_lipsColorButton.calloutDirection = Callout.DIRECTION_LEFT;
			_lipsColorButton.addEventListener(Event.TRIGGERED, onButtonTouched);
			_iconsContainer.addChild(_lipsColorButton);
			// skin color
			_skinColorButton = new LudokadoStarlingButton(AvatarMakerAssets.skinColor, "", AvatarMakerAssets.skinColorSelected);
			_skinColorButton.isToolTipEnabled = true;
			_skinColorButton.isToggle = true;
			_skinColorButton.calloutText = _("Couleur de peau");
			_skinColorButton.calloutDirection = Callout.DIRECTION_LEFT;
			_skinColorButton.addEventListener(Event.TRIGGERED, onButtonTouched);
			_iconsContainer.addChild(_skinColorButton);
			// eyes color
			_eyesColorButton = new LudokadoStarlingButton(AvatarMakerAssets.eyesColor, "", AvatarMakerAssets.eyesColorSelected);
			_eyesColorButton.isToolTipEnabled = true;
			_eyesColorButton.isToggle = true;
			_eyesColorButton.calloutText = _("Couleur des yeux");
			_eyesColorButton.calloutDirection = Callout.DIRECTION_LEFT;
			_eyesColorButton.addEventListener(Event.TRIGGERED, onButtonTouched);
			_iconsContainer.addChild(_eyesColorButton);
			// hair color
			_hairColorButton = new LudokadoStarlingButton(AvatarMakerAssets.hairColor, "", AvatarMakerAssets.hairColorSelected);
			_hairColorButton.isToolTipEnabled = true;
			_hairColorButton.isToggle = true;
			_hairColorButton.calloutText = _("Couleur des cheveux");
			_hairColorButton.calloutDirection = Callout.DIRECTION_LEFT;
			_hairColorButton.addEventListener(Event.TRIGGERED, onButtonTouched);
			_iconsContainer.addChild(_hairColorButton);
			// background above
			_iconsContainer.addChild(_iconsBackground);
			
			_allButtons = new Vector.<LudokadoStarlingButton>(4, true);
			_allButtons[0] = _lipsColorButton;
			_allButtons[1] = _skinColorButton;
			_allButtons[2] = _eyesColorButton;
			_allButtons[3] = _hairColorButton;
			
			_iconsMaskedContainer.addChild(_iconsContainer);
			
			_colorButton = new ColorButton();
			addChild(_colorButton);
		}
		
		override protected function draw():void
		{
			super.draw();
			
			if(isInvalid(INVALIDATION_FLAG_SIZE))
			{
				// place icons
				_lipsColorButton.x = _skinColorButton.x = _eyesColorButton.x = _hairColorButton.x = scaleAndRoundToDpi(ICONS_POSITION_X);
				_lipsColorButton.y = scaleAndRoundToDpi(ICONS_START_Y);
				_skinColorButton.y = _lipsColorButton.y + _lipsColorButton.height + scaleAndRoundToDpi(ICONS_GAP);
				_eyesColorButton.y = _skinColorButton.y + _skinColorButton.height + scaleAndRoundToDpi(ICONS_GAP);
				_hairColorButton.y = _eyesColorButton.y + _eyesColorButton.height + scaleAndRoundToDpi(ICONS_GAP);
				
				// then hide the container and animate its arrival (done once)
				_iconsContainer.y = -_iconsContainer.height;
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Animation
		
		/**
		 * When the avatar changes, we need to replace the container depending on the gender.
		 */
		public function onAvatarChanged():void
		{
			if(_iconsContainer.y == -_iconsContainer.height)
				TweenMax.to(_iconsContainer, 0.5, { delay:1, y:(LKConfigManager.currentConfig.gender == AvatarGenderType.GIRL ? 0 : scaleAndRoundToDpi(-47)), ease:Back.easeOut });
			else
				TweenMax.to(_iconsContainer, 0.5, { delay:1, y:(LKConfigManager.currentConfig.gender == AvatarGenderType.GIRL ? 0 : scaleAndRoundToDpi(-47)), ease:Linear.easeNone });
		}
		
//------------------------------------------------------------------------------------------------------------
//	Handlers
		
		/**
		 * When a button have been touched.
		 * 
		 * 
		 */
		private function onButtonTouched(event:Event):void
		{
			switch (event.target)
			{
				case _lipsColorButton:
				{
					dispatchEventWith(LKAvatarMakerEventTypes.PART_SELECTED, true, LudokadoBones.LIPS_COLOR);
					break;
				}
				
				case _skinColorButton:
				{
					dispatchEventWith(LKAvatarMakerEventTypes.PART_SELECTED, true, LudokadoBones.SKIN_COLOR);
					break;
				}
				
				case _eyesColorButton:
				{
					dispatchEventWith(LKAvatarMakerEventTypes.PART_SELECTED, true, LudokadoBones.EYES_COLOR);
					
					break;
				}
				
				case _hairColorButton:
				{
					dispatchEventWith(LKAvatarMakerEventTypes.PART_SELECTED, true, LudokadoBones.HAIR_COLOR);
					break;
				}
			}
			
			for (var i:int = 0; i < _allButtons.length; i++)
				_allButtons[i].isSelected = event.target == _allButtons[i];
			
			_colorButton.animate();
		}
		
		public function deselectAll():void
		{
			for (var i:int = 0; i < _allButtons.length; i++)
				_allButtons[i].isSelected = false;
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
		
		override public function dispose():void
		{
			_colorButton.removeFromParent(true);
			_colorButton = null;
			
			if(_allButtons)
				_allButtons.length = 0;
			_allButtons = null;
			
			_lipsColorButton.removeEventListener(Event.TRIGGERED, onButtonTouched);
			_lipsColorButton.removeFromParent(true);
			_lipsColorButton = null;
			
			_skinColorButton.removeEventListener(Event.TRIGGERED, onButtonTouched);
			_skinColorButton.removeFromParent(true);
			_skinColorButton = null;
			
			_eyesColorButton.removeEventListener(Event.TRIGGERED, onButtonTouched);
			_eyesColorButton.removeFromParent(true);
			_eyesColorButton = null;
			
			_hairColorButton.removeEventListener(Event.TRIGGERED, onButtonTouched);
			_hairColorButton.removeFromParent(true);
			_hairColorButton = null;
			
			_iconsBackground.removeFromParent(true);
			_iconsBackground = null;
			
			_iconsContainer.removeFromParent(true);
			_iconsContainer = null;
			
			_iconsMask.removeFromParent(true);
			_iconsMask = null;
			
			_iconsMaskedContainer.removeFromParent(true);
			_iconsMaskedContainer = null;
			
			super.dispose();
		}
	}
}