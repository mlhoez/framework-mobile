/*
 Copyright © 2006-2015 Ludo Factory
 Avatar Maker - Ludokado
 Author  : Maxime Lhoez
 Created : 14 décembre 2014
*/
package com.ludofactory.mobile.core.avatar.maker.sections
{
	
	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.avatar.AvatarMakerAssets;
	import com.ludofactory.mobile.core.avatar.maker.CustomButton;
	import com.ludofactory.mobile.core.avatar.maker.LudokadoStarlingButton;
	import com.ludofactory.mobile.core.avatar.maker.items.ItemManager;
	import com.ludofactory.mobile.core.avatar.test.config.AvatarGenderType;
	import com.ludofactory.mobile.core.avatar.test.config.LudokadoBones;
	import com.ludofactory.mobile.core.avatar.test.events.LKAvatarMakerEventTypes;
	import com.ludofactory.mobile.core.avatar.test.manager.LKConfigManager;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import feathers.controls.GroupedList;
	import feathers.controls.Scroller;
	import feathers.core.FeathersControl;
	import feathers.data.HierarchicalCollection;
	import feathers.display.Scale9Image;
	import feathers.textures.Scale9Textures;
	
	import flash.geom.Rectangle;
	
	import starling.events.Event;
	
	/**
	 * Section selector container.
	 */
	public class SectionSelector extends FeathersControl
	{
		/**
		 * The panel background. */
		private var _background:Scale9Image;
		/**
		 * Catgory list. */
		private var _categoryList:GroupedList;
		/**
		 * Age button. */
		private var _ageButton:CustomButton;
		/**
		 * Color selector. */
		private var _colorSelector:ColorSelector;
		
		public function SectionSelector()
		{
			super();
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			_background = new Scale9Image(new Scale9Textures(AvatarMakerAssets.panelBackground, new Rectangle(10, 10, 12, 12)));
			_background.touchable = false;
			_background.alpha = 0.5;
			addChild(_background);
			
			_categoryList = new GroupedList();
			_categoryList.headerRendererType = CategoryHeaderItemRenderer;
			_categoryList.itemRendererType = CategoryItemRenderer;
			_categoryList.horizontalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			_categoryList.verticalScrollPolicy = Scroller.SCROLL_POLICY_AUTO;
			addChild(_categoryList);
			
			_ageButton = new CustomButton(AvatarMakerAssets.ageSelector, _("Age"), AvatarMakerAssets.ageSelectorSelected);
			_ageButton.isToggle = true;
			_ageButton.fontName = Theme.FONT_OSWALD;
			_ageButton.fontColor = 0xffffff;
			_ageButton.fontSize = scaleAndRoundToDpi(20);
			_ageButton.addEventListener(Event.TRIGGERED, onAgeSelected);
			addChild(_ageButton);
			
			_colorSelector = new ColorSelector();
			addChild(_colorSelector);
			
			addEventListener(LKAvatarMakerEventTypes.PART_SELECTED, onPartSelected);
		}
		
		override protected function draw():void
		{
			super.draw();
			
			if( isInvalid(INVALIDATION_FLAG_SIZE) )
			{
				_background.width = actualWidth;
				_background.height = actualHeight;
				
				_categoryList.x = 0;
				_categoryList.width = actualWidth - (_categoryList.x * 2);
				_categoryList.height = actualHeight - _categoryList.y - scaleAndRoundToDpi(5);
				
				_ageButton.x = scaleAndRoundToDpi(-55);
				_ageButton.y = scaleAndRoundToDpi(10);
				
				_colorSelector.x = scaleAndRoundToDpi(-55);
				_colorSelector.y = scaleAndRoundToDpi(10);
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Handlers
		
		/**
		 * When a part is selected.
		 */
		private function onPartSelected(event:Event):void
		{
			var oneSelected:Boolean = false;
			var object:Object;
			for (var i:int = 0; i < _categoryList.dataProvider.data.length; i++)
			{
				// this object contains two properties : header & children
				object = _categoryList.dataProvider.data[i];
				for (var j:int = 0; j < object.children[0].length; j++)
				{
					SectionData(object.children[0][j]).isChoosed = event.data == SectionData(object.children[0][j]).asociatedBone;
					oneSelected = SectionData(object.children[0][j]).isChoosed ? true : oneSelected;
				}
				_categoryList.dataProvider.updateItemAt(i);
			}
			
			if(oneSelected || event.data == LudokadoBones.AGE)
				_colorSelector.deselectAll();
			
			if(oneSelected || event.target == _colorSelector)
				_ageButton.isSelected = false;
		}
		
		/**
		 * Sets the data at the first launch or when the avatar is changed.
		 * 
		 * Selects at the same time the first section from the selector so that some items are loaded within the list.
		 */
		public function setData():void
		{
			_categoryList.dataProvider = new HierarchicalCollection(ItemManager.getInstance().selectorData.concat());
			SectionData(_categoryList.dataProvider.data[0].children[0][0]).forceTrigger = true;
			_categoryList.dataProvider.updateItemAt(0);
			_colorSelector.onAvatarChanged();
			if(LKConfigManager.currentGenderId != AvatarGenderType.POTATO)
			{
				_ageButton.visible = true;
				_colorSelector.y = _ageButton.y + _ageButton.height - scaleAndRoundToDpi(10);
			}
			else
			{
				_ageButton.visible = false;
				_colorSelector.y = 10;
			}
		}
		
		private function onAgeSelected(event:Event):void
		{
			dispatchEventWith(LKAvatarMakerEventTypes.PART_SELECTED, true, LudokadoBones.AGE);
		}

		/**
		 * When the basket is updated, we need to check here if we have to display / hide the basket icon
		 * above the concerned section button.
		 * 
		 * @param armatureSectionType The ArmatureSectionType used to update the right section.
		 */
		public function onBasketUpdated(armatureSectionType:String):void
		{
			//_sections.onCartUpdated(armatureSectionType);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Public API
		
		/**
		 * When a item is added to the cart, we need to update the selector here so that sections that are in the cart
		 * are highlighted in green.
		 */
		/*override public function onCartUpdated(armatureSectionType:String):void
		{
			switch (armatureSectionType)
			{
				case LudokadoBones.HAT:
				case LudokadoBones.HAIR:       { _hatPart.isBasketVisible = (CartManager.getInstance().hasHatInCart() || CartManager.getInstance().hasHairInCart()); break; }
				case LudokadoBones.EYES:       { _eyesPart.isBasketVisible = CartManager.getInstance().hasEyesInCart(); break; }
				case LudokadoBones.SHIRT:      { _shirtPart.isBasketVisible = CartManager.getInstance().hasShirtInCart(); break; }
				case LudokadoBones.NOSE:       { _nosePart.isBasketVisible = CartManager.getInstance().hasNoseInCart(); break; }
				case LudokadoBones.MOUTH:      { _mouthPart.isBasketVisible = CartManager.getInstance().hasMouthInCart(); break; }
				case LudokadoBones.LEFT_HAND:  { _leftHand.isBasketVisible = CartManager.getInstance().hasLeftHandInCart(); break; }
				case LudokadoBones.RIGHT_HAND: { _rightHand.isBasketVisible = CartManager.getInstance().hasRightHandInCart(); break; }
				case LudokadoBones.SKIN_COLOR: { _skinColorButton.isBasketVisible = CartManager.getInstance().hasSkinColorInCart(); break; }
				case LudokadoBones.EYES_COLOR: { _eyesColorButton.isBasketVisible = CartManager.getInstance().hasEyesColorInCart(); break; }
				case LudokadoBones.HAIR_COLOR: { _hairColorButton.isBasketVisible = CartManager.getInstance().hasHairColorInCart(); break; }
			}
		}*/
		
		/**
		 * When a part of the selector is selected by clicking on the avatar itself, we need to manually select
		 * the appropriate section here.
		 */
		/*override public function onSelectPartFromAvatar(partName:String):void
		{
			switch (partName)
			{
				case LudokadoBones.HAIR:       { _hatPart.isSelected = true;   break; }
				case LudokadoBones.EYES:       { _eyesPart.isSelected = true;  break; }
				case LudokadoBones.SHIRT:      { _shirtPart.isSelected = true; break; }
				case LudokadoBones.NOSE:       { _nosePart.isSelected = true;  break; }
				case LudokadoBones.MOUTH:      { _mouthPart.isSelected = true; break; }
				case LudokadoBones.LEFT_HAND:  { _leftHand.isSelected = true;  break; }
				case LudokadoBones.RIGHT_HAND: { _rightHand.isSelected = true; break; }
			}
		}*/
		
		/**
		 *
		 */
		/*override public function onPartHoveredFromAvatar(partName:String, state:String = ButtonState.OVER):void
		{
			switch (partName)
			{
				case LudokadoBones.HAIR:       { _hatPart.state = state;   break; }
				case LudokadoBones.EYES:       { _eyesPart.state = state;  break; }
				case LudokadoBones.SHIRT:      { _shirtPart.state = state; break; }
				case LudokadoBones.NOSE:       { _nosePart.state = state;  break; }
				case LudokadoBones.MOUTH:      { _mouthPart.state = state; break; }
				case LudokadoBones.LEFT_HAND:  { _leftHand.state = state;  break; }
				case LudokadoBones.RIGHT_HAND: { _rightHand.state = state; break; }
			}
		}*/
		
		/**
		 * Removes all the basket icons from the buttons.
		 */
		/*override public function emptyAll():void
		{
			_hatPart.isBasketVisible = false;
			_eyesPart.isBasketVisible = false;
			_shirtPart.isBasketVisible = false;
			_nosePart.isBasketVisible = false;
			_mouthPart.isBasketVisible = false;
			_leftHand.isBasketVisible = false;
			_rightHand.isBasketVisible = false;
			_skinColorButton.isBasketVisible = false;
			_eyesColorButton.isBasketVisible = false;
			_hairColorButton.isBasketVisible = false;
		}*/

//------------------------------------------------------------------------------------------------------------
//	Dispose
		
		override public function dispose():void
		{
			removeEventListener(LKAvatarMakerEventTypes.PART_SELECTED, onPartSelected);
			
			_background.removeFromParent(true);
			_background = null;
			
			_categoryList.removeFromParent(true);
			_categoryList = null;
			
			_colorSelector.removeFromParent(true);
			_colorSelector = null;
			
			super.dispose();
		}
		
	}
}