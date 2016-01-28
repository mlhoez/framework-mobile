/**
 * Created by Maxime on 14/01/16.
 */
package com.ludofactory.mobile.core.avatar.test
{
	
	import com.greensock.TweenMax;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.avatar.AvatarMakerAssets;
	import com.ludofactory.mobile.core.avatar.test.events.LKAvatarMakerEventTypes;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	
	import flash.geom.Point;
	
	import starling.display.Button;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	
	public class NewSectionGroupButton extends Sprite
	{
		
	// ---------- Constants
		
		/**
		 * Instad of using the sections .length value, I use this constant to keep a common layout no matter how many
		 * items to build (but while the length is < 9) */
		private static const BASE_LAYOUT:int = 9;
		
	// ---------- Other properties
		
		/**
		 * Glow displayed behind. */
		private var _glow:Image;
		/**
		 * The stripe. */
		private var _stripe:Image;
		/**
		 * Plus button. */
		private var _openCloseButton:Button;
		/**
		 * All the surrounding buttons. */
		private var _allButtons:Vector.<NewSectionButton>;
		
		/**
		 * Whether it is opened or not. */
		private var _isOpened:Boolean = false;
		
		/**
		 * References to build a round menu
		 * 
		 * ref : http://stackoverflow.com/questions/10782890/create-objects-in-a-circle-around-a-point
		 * 
		 * // place the buttons
		 * var rotation:Number = deg2rad(360 / numSections); // or in degree converted in radians
		 * for(var door:int = 0; door < numSections; door++)
		 * {
		 *      button = _allButtons[door];
		 *      qd.rotation = door * rotation; // à utiliser si pas align pivot
		 *      var rot:Number = door * rotation;
		 *      button.x = ; // * X (x = distance we need from the center
		 *      button.y = ;
		 * }
		 * 
		 * @param sectionsToBuild Array of section names to add
		 * @param direction use "left" or "right"
		 */
		public function NewSectionGroupButton(sectionsToBuild:Array, direction:String)
		{
			super();
			
			_glow = new Image(AvatarMakerAssets.sectionGlow);
			_glow.scaleX = _glow.scaleY = GlobalConfig.dpiScale;
			_glow.alignPivot();
			_glow.alpha = 0;
			_glow.visible = false;
			_glow.touchable = false;
			addChild(_glow);
			
			_stripe = new Image(AvatarMakerAssets.sectionStripe);
			_stripe.scaleX = _stripe.scaleY = GlobalConfig.dpiScale * (direction == "right" ? -1 : 1);
			_stripe.touchable = false;
			addChild(_stripe);
			
			_openCloseButton = new Button(AvatarMakerAssets.sectionPlusButton);
			_openCloseButton.scaleX = _openCloseButton.scaleY = GlobalConfig.dpiScale;
			_openCloseButton.addEventListener(Event.TRIGGERED, onButtonTouched);
			_openCloseButton.alignPivot();
			addChild(_openCloseButton);
			
			_allButtons = new Vector.<NewSectionButton>();
			var button:NewSectionButton;
			var numSections:int = sectionsToBuild.length;
			var rotation:Number = 2 * Math.PI / BASE_LAYOUT; // directly in radians
			var delay:Number = 0;
			for (var i:int = 0; i < numSections; i++)
			{
				button = new NewSectionButton(sectionsToBuild[i],
						new Point(Math.cos(i * rotation - rotation) * scaleAndRoundToDpi(GlobalConfig.isPhone ? 115 : 135), Math.sin(i * rotation - rotation) * scaleAndRoundToDpi(GlobalConfig.isPhone ? 115 : 135)),
						delay);
				button.alignPivot();
				addChild(button);
				_allButtons.push(button);
				
				delay += 0.03;
			}
			
		}
		
//------------------------------------------------------------------------------------------------------------
//	Handlers
		
		/**
		 * When the button is triggered.
		 */
		private function onButtonTouched(event:Event = null):void
		{
			_isOpened = !_isOpened;
			for (var i:int = 0; i < _allButtons.length; i++)
				 _isOpened ? _allButtons[i].animateIn() : _allButtons[i].animateOut();
			
			_openCloseButton.upState = _isOpened ? AvatarMakerAssets.sectionMinusButton : AvatarMakerAssets.sectionPlusButton;
			TweenMax.to(_glow, 0.25, { autoAlpha:(_isOpened ? 1 : 0) });
		}
		
		/**
		 * When a section is selected, we need to deselect the other and close the menu.
		 * 
		 * @param sectionName The section that was selected.
		 */
		public function onSectionSelected(sectionName:String):void
		{
			if(_isOpened) // close it
				onButtonTouched();
			
			for (var i:int = 0; i < _allButtons.length; i++)
				_allButtons[i].isSelected = _allButtons[i].sectionName == sectionName;
		}
		
		/**
		 * Called when the avatar maker screen is initialized, to set up a defautl section.
		 */
		public function setData():void
		{
			_allButtons[0].forceTrigger();
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
		
		override public function dispose():void
		{
			TweenMax.killTweensOf(_glow);
			_glow.removeFromParent(true);
			_glow = null;
			
			_stripe.removeFromParent(true);
			_stripe = null;
			
			_openCloseButton.removeEventListener(Event.TRIGGERED, onButtonTouched);
			_openCloseButton.removeFromParent(true);
			_openCloseButton = null;
			
			var button:NewSectionButton;
			for (var i:int = 0; i < _allButtons.length; i++)
			{
				button = _allButtons[i];
				button.removeFromParent(true);
				button = null;
			}
			
			_isOpened = false;
			
			super.dispose();
		}
		
	}
}