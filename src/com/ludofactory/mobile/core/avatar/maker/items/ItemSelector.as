/*
 Copyright © 2006-2015 Ludo Factory
 Avatar Maker - Ludokado
 Author  : Maxime Lhoez
 Created : 14 Décembre 2014
*/
package com.ludofactory.mobile.core.avatar.maker.items
{
	
	import com.greensock.TweenMax;
	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.common.utils.roundUp;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.avatar.AvatarMakerAssets;
	import com.ludofactory.mobile.core.avatar.maker.ColorListButton;
	import com.ludofactory.mobile.core.avatar.maker.CustomCheckBox;
	import com.ludofactory.mobile.core.avatar.maker.SectionListButton;
	import com.ludofactory.mobile.core.avatar.maker.data.AvatarItemData;
	import com.ludofactory.mobile.core.avatar.test.config.AvatarGenderType;
	import com.ludofactory.mobile.core.avatar.test.config.LudokadoBones;
	import com.ludofactory.mobile.core.avatar.test.events.LKAvatarMakerEventTypes;
	import com.ludofactory.mobile.core.avatar.test.manager.LKConfigManager;
	import com.ludofactory.mobile.core.avatar.test.manager.LudokadoBoneConfiguration;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	
	import feathers.controls.List;
	import feathers.controls.Scroller;
	import feathers.core.FeathersControl;
	import feathers.data.ListCollection;
	import feathers.display.Scale9Image;
	import feathers.layout.HorizontalLayout;
	
	import starling.display.Image;
	import starling.events.Event;
	import starling.utils.HAlign;
	import starling.utils.VAlign;
	import starling.utils.deg2rad;
	
	public class ItemSelector extends FeathersControl
	{
		
	// ---------- Constants
		
		/**
		 * Invalidation flag to indicate that the dimensions of the UI control have changed. */
		public static const INVALIDATION_FLAG_ITEMS:String = "items";
		/**
		 * Whether the filters are applied or reset on category change. */
		public static const KEEP_FILTERS_ON_CATEGORY_CHANGE:Boolean = true;
		/**
		 * hgjghjghu */
		public static var IS_OWNED_FILTER_SELECTED:Boolean = false;
		/**
		 * Whether we include the free items in the list when the isOwned check box is selected. */
		public static var INCLUDE_FREE_ITEMS_IN_OWNED_FILTER:Boolean = true;
		/**
		 * Helper value used by the AvatarItemRenderer in order to skip some non-needed animations when
		 * the user changes a category. */
		public static var hasChangedSection:Boolean = false;
		
	// ---------- Common properties
		
		/**
		 * The panel background. */
		private var _background:Scale9Image;
		
		/**
		 * The items list. */
		private var _itemsList:List;
		/**
		 * The list shadow. */
		private var _listTopShadow:Image;
		/**
		 * The list shadow. */
		private var _listBottomShadow:Image;
		/**
		 * Default data displayed in the list. */
		private var _currentDataList:Vector.<AvatarItemData>;
		/**
		 * The current armature section type displaying. */
		private var _currentArmatureSectionType:String;
		/**
		 * Check box used to filter owned items. */
		private var _checkBox:CustomCheckBox;
		
		/**
		 * Color button for section that can be color-customized. */
		private var _colorButton:ColorListButton;
		/**
		 * section button for section that can be color-customized. */
		private var _sectionButton:SectionListButton;
		
		public function ItemSelector()
		{
			super();
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			_background = new Scale9Image(AvatarMakerAssets.panelBackground);
			_background.touchable = false;
			addChild(_background);
			
			_colorButton = new ColorListButton(AvatarMakerAssets.listColorButton, "", AvatarMakerAssets.listColorSelectedButton);
			_colorButton.addEventListener(Event.TRIGGERED, onSideButtonTriggered);
			addChild(_colorButton);
			
			_sectionButton = new SectionListButton(AvatarMakerAssets.listSectionButton, "ddd", AvatarMakerAssets.listSectionSelectedButton);
			_sectionButton.addEventListener(Event.TRIGGERED, onSideButtonTriggered);
			addChild(_sectionButton);
			
			var layout:HorizontalLayout = new HorizontalLayout();
			HorizontalLayout(layout).verticalAlign = HorizontalLayout.VERTICAL_ALIGN_TOP;
			HorizontalLayout(layout).horizontalAlign = HorizontalLayout.VERTICAL_ALIGN_JUSTIFY;
			HorizontalLayout(layout).hasVariableItemDimensions = true;
			HorizontalLayout(layout).gap = scaleAndRoundToDpi(5);
			
			_itemsList = new List();
			_itemsList.isSelectable = false;
			_itemsList.layout = layout;
			_itemsList.itemRendererType = AvatarItemRenderer;
			addChild(_itemsList);
			_itemsList.verticalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			_itemsList.horizontalScrollPolicy = Scroller.SCROLL_POLICY_AUTO;
			_itemsList.addEventListener(Event.SCROLL, onScroll);
			_itemsList.addEventListener(LKAvatarMakerEventTypes.ITEM_SELECTED, onItemSelected);
			
			_listTopShadow = new Image(AvatarMakerAssets.listShadow);
			_listTopShadow.touchable = false;
			_listTopShadow.scaleX = _listTopShadow.scaleY = GlobalConfig.dpiScale;
			addChild(_listTopShadow);

			_listBottomShadow = new Image(AvatarMakerAssets.listShadow);
			_listBottomShadow.touchable = false;
			_listBottomShadow.alignPivot(HAlign.RIGHT, VAlign.BOTTOM);
			_listBottomShadow.rotation = deg2rad(180);
			_listBottomShadow.scaleX = _listBottomShadow.scaleY = GlobalConfig.dpiScale;
			addChild(_listBottomShadow);
			
			_checkBox = new CustomCheckBox();
			_checkBox.addEventListener(Event.TRIGGERED, onFilterSelected);
			_checkBox.visible = false;
			addChild(_checkBox);
		}
		
		override protected function draw():void
		{
			super.draw();
			
			if( isInvalid(INVALIDATION_FLAG_SIZE) )
			{
				
				_background.height = actualHeight;
				
				//_checkBox.x = -scaleAndRoundToDpi(50);
				//_checkBox.y = actualHeight - _checkBox.height;
				_colorButton.height = _sectionButton.height = _colorButton.width =_sectionButton.width = actualHeight * 0.5;
				_sectionButton.y = actualHeight * 0.5;
				
				
				_background.x = _itemsList.x = _colorButton.width;
				_background.width = _itemsList.width = roundUp(this.actualWidth - _itemsList.x);
				_itemsList.height = actualHeight;
				
				_listTopShadow.x = scaleAndRoundToDpi(16);
				_listTopShadow.y = _itemsList.y;
				
				_listBottomShadow.x = scaleAndRoundToDpi(16);
				_listBottomShadow.y = _itemsList.y + _itemsList.height - _listBottomShadow.height;
				
				
				this.invalidate(INVALIDATION_FLAG_ITEMS);
			}
			
			if( isInvalid(INVALIDATION_FLAG_ITEMS) )
			{
				_itemsList.validate();
				_listTopShadow.width = _listBottomShadow.width = _itemsList.width + scaleAndRoundToDpi(-8);

				if( _itemsList.dataProvider )
				{
					for (var j:int = 0; j < _itemsList.dataProvider.length; j++)
						_itemsList.dataProvider.updateItemAt(j);
				}

				hasChangedSection = false;
			}
		}

//------------------------------------------------------------------------------------------------------------
//	Handlers

		/**
		 * When we scroll on the list, we need to update the visibility of the list shadows
		 * according to the number of items displayed (so if we can scroll up/down or not).
		 */
		private function onScroll(event:Event):void
		{
			TweenMax.to(_listTopShadow, 0.15, { autoAlpha:(_itemsList.verticalScrollPosition > 0 ? 1 : 0) });
			TweenMax.to(_listBottomShadow, 0.15, { autoAlpha:((_itemsList.height < _itemsList.viewPort.height && _itemsList.verticalScrollPosition < (_itemsList.viewPort.height - _itemsList.height)) ? 1 : 0) });
		}
		
		/**
		 * When an item is selected in the list, we need to deselect the others.
		 * 
		 * As this event bubbles, it will also be catched by the AvatarMakerScreen in order to show / hide
		 * the basket icon on concerned Parts and the "Save" button. It will also update the list of currently
		 * selected items for purchase in order to display the basket pop up when the "Save" button will
		 * be clicked.
		 */
		private function onItemSelected(event:Event):void
		{
			var itemData:AvatarItemData = event.data.itemData;
			
			// we need to update the original list because the one in the data provider is just a clone
			var avatarItemData:AvatarItemData;
			for (var i:int = 0; i < _currentDataList.length; i++)
			{
				avatarItemData = _currentDataList[i];
				if( avatarItemData.id != itemData.id ) 
					avatarItemData.isSelected = false;
			}
			
			this.invalidate(INVALIDATION_FLAG_ITEMS);
			dispatchEventWith(LKAvatarMakerEventTypes.ITEM_SELECTED, false, event.data);
		}
		
		/**
		 * When a filter is selected, we need to update the list data provider according to the selected filter.
		 */
		private function onFilterSelected(event:Event = null):void
		{
			IS_OWNED_FILTER_SELECTED = _checkBox.isSelected;
			if( _itemsList.dataProvider )
				_itemsList.dataProvider = new ListCollection();

			hasChangedSection = true;
			var globbiesItemData:AvatarItemData;
			for (var i:int = 0; i < _currentDataList.length; i++)
			{
				globbiesItemData = _currentDataList[i];
				// if there is not filter or if the filter matches the type of the item
				if( !_checkBox.isSelected || (_checkBox.isSelected && (globbiesItemData.isOwned || globbiesItemData.behaviors.length > 0) || (INCLUDE_FREE_ITEMS_IN_OWNED_FILTER && globbiesItemData.price <= 0)) )
				{
					if( globbiesItemData.behaviors.length > 0 )
					{
						for (var j:int = 0; j < globbiesItemData.behaviors.length; j++)
						{
							if(!_checkBox.isSelected || ((_checkBox.isSelected && globbiesItemData.behaviors[j].isOwned) || (INCLUDE_FREE_ITEMS_IN_OWNED_FILTER && globbiesItemData.behaviors[j].price <= 0) ))
							{
								_itemsList.dataProvider.push(globbiesItemData);
								break;
							}
						}
					}
					else
					{
						_itemsList.dataProvider.push(globbiesItemData);
					}
				}
			}

			this.invalidate(INVALIDATION_FLAG_ITEMS);
		}

		/**
		 * Deselects all the items within the list after a element was removed from the basket and put back the original one.
		 */
		public function onItemRemovedFromBasket(armatureSectionType:String):void
		{
			// deselect all if it's the current section displaying, otherwise, no need to do anything
			if( _currentArmatureSectionType == armatureSectionType )
			{
				// TODO checker ça pour les behaviors car par sûr que ça marche
				for (var i:int = 0; i < _currentDataList.length; i++)
					_currentDataList[i].isSelected = _currentDataList[i].id == LudokadoBoneConfiguration(LKConfigManager.currentConfig[armatureSectionType]).id;

				this.invalidate(INVALIDATION_FLAG_ITEMS);
			}
		}

		/**
		 * When a random item have been selected, we need to update the list to select this item.
		 */
		public function onRandomItemSelected(itemData:AvatarItemData):void
		{
			if( _currentArmatureSectionType == itemData.armatureSectionType )
			{
				for (var i:int = 0; i < _currentDataList.length; i++)
					_currentDataList[i].isSelected = _currentDataList[i].id == itemData.id;

				this.invalidate(INVALIDATION_FLAG_ITEMS);
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Update
		
		/**
		 * 
		 */
		private function onSideButtonTriggered(event:Event):void
		{
			if(event.target == _colorButton)
			{
				_sectionButton.isSelected = false;
				updateItems(_colorButton.section, false);
			}
			else
			{
				updateItems(_sectionButton.section, false);
				_colorButton.isSelected = false;
			}
				
		}
		
		/**
		 * Updates the items list and 
		 */
		public function updateItems(armatureSectionGroup:String, forceUpdate:Boolean = true):void
		{
			var items:Vector.<AvatarItemData> = ItemManager.getInstance().items[armatureSectionGroup];
			
			if(forceUpdate)
			{
				switch (armatureSectionGroup)
				{
					case LudokadoBones.HAT:          { _sectionButton.setTextAndIcon(_("Chapeau"), armatureSectionGroup);             break; }
					case LudokadoBones.HAIR:         { _sectionButton.setTextAndIcon(_("Cheveux"), armatureSectionGroup);             break; }
					case LudokadoBones.EYEBROWS:     { _sectionButton.setTextAndIcon(_("Sourcils"), armatureSectionGroup);            break; }
					case LudokadoBones.EYES:         { _sectionButton.setTextAndIcon(_("Yeux"), armatureSectionGroup);                break; }
					case LudokadoBones.NOSE:         { _sectionButton.setTextAndIcon(_("Nez"), armatureSectionGroup);                 break; }
					case LudokadoBones.MOUTH:        { _sectionButton.setTextAndIcon(_("Bouche"), armatureSectionGroup);              break; }
					case LudokadoBones.FACE_CUSTOM:  { _sectionButton.setTextAndIcon(_("Visage"), armatureSectionGroup);              break; }
					case LudokadoBones.MOUSTACHE:    { _sectionButton.setTextAndIcon(_("Moustache"), armatureSectionGroup);           break; }
					case LudokadoBones.BEARD:        { _sectionButton.setTextAndIcon(_("Barbe"), armatureSectionGroup);               break; }
					case LudokadoBones.SHIRT:        { _sectionButton.setTextAndIcon(_("T-Shirt"), armatureSectionGroup);             break; }
					case LudokadoBones.EPAULET:      { _sectionButton.setTextAndIcon(_("Epaulettes"), armatureSectionGroup);          break; }
					case LudokadoBones.LEFT_HAND:    { _sectionButton.setTextAndIcon(_("Main gauche"), armatureSectionGroup);         break; }
					case LudokadoBones.RIGHT_HAND:   { _sectionButton.setTextAndIcon(_("Main droite"), armatureSectionGroup);         break; }
					case LudokadoBones.AGE:          { _sectionButton.setTextAndIcon(_("Age"), armatureSectionGroup);                 break; }
						
					case LudokadoBones.HAIR_COLOR:   { _sectionButton.setTextAndIcon(_("Cheveux"), LudokadoBones.HAIR); break; }
					case LudokadoBones.EYES_COLOR:   { _sectionButton.setTextAndIcon(_("Yeux"), LudokadoBones.EYES);    break; }
					case LudokadoBones.SKIN_COLOR:   { _sectionButton.setTextAndIcon(_("Age"), LudokadoBones.AGE);     break; }
					case LudokadoBones.LIPS_COLOR:   { _sectionButton.setTextAndIcon(_("Bouche"), LudokadoBones.MOUTH);  break; }
				}
				
				switch (armatureSectionGroup)
				{
					case LudokadoBones.HAT:
					case LudokadoBones.EYEBROWS:
					case LudokadoBones.NOSE:
					case LudokadoBones.FACE_CUSTOM:
					case LudokadoBones.MOUSTACHE:
					case LudokadoBones.BEARD:
					case LudokadoBones.SHIRT:
					case LudokadoBones.EPAULET:
					case LudokadoBones.LEFT_HAND:
					case LudokadoBones.RIGHT_HAND:  { _colorButton.disable(); break; }
					case LudokadoBones.HAIR:        { _colorButton.enableWithSection(LudokadoBones.HAIR_COLOR); break; }
					case LudokadoBones.EYES:        { _colorButton.enableWithSection(LudokadoBones.EYES_COLOR); break; }
					case LudokadoBones.MOUTH:       { LKConfigManager.currentGenderId == AvatarGenderType.GIRL ? _colorButton.enableWithSection(LudokadoBones.LIPS_COLOR) : _colorButton.disable(); break; }
					case LudokadoBones.AGE:         { _colorButton.enableWithSection(LudokadoBones.SKIN_COLOR); break; } // for boys and girls
				}
				
				if(armatureSectionGroup != LudokadoBones.LIPS_COLOR && armatureSectionGroup != LudokadoBones.HAIR_COLOR &&
						armatureSectionGroup != LudokadoBones.EYES_COLOR && armatureSectionGroup != LudokadoBones.SKIN_COLOR)
				{
					// deselect the color button and select he section button instead
					_colorButton.isSelected = false;
					_sectionButton.isSelected = true;
				}
			}
			
			if( !KEEP_FILTERS_ON_CATEGORY_CHANGE )
				_checkBox.isSelected = false;
			
			_currentArmatureSectionType = armatureSectionGroup;
			_currentDataList = items ? items : new Vector.<AvatarItemData>();
			
			hasChangedSection = true;
			if( !_itemsList.dataProvider )
				_itemsList.dataProvider = new ListCollection([]);
			onFilterSelected();
			
			this.invalidate(INVALIDATION_FLAG_ITEMS);
		}
		
		public function updateCurrentList():void
		{
			this.invalidate(INVALIDATION_FLAG_ITEMS);
		}
		
		public function onNewItemSelected(itemData:AvatarItemData):void
		{
			updateItems(itemData.armatureSectionType);
			// once updated, scroll to the item
			if(_itemsList.dataProvider)
			{
				for(var i:int = 0; i < _itemsList.dataProvider.length; i++)
				{
					if(AvatarItemData(_itemsList.dataProvider.getItemAt(i)).hasBehaviors)
					{
						// we can't rely on the database id as the item has behaviors, thus no proper database id
						// thus we check the flash id to find the item in the list
						if( AvatarItemData(_itemsList.dataProvider.getItemAt(i)).linkageName == itemData.linkageName)
						{
							_itemsList.scrollToDisplayIndex(i, 0);
							break;
						}
					}
					else
					{
						// check on the id directy, more trustable
						if( AvatarItemData(_itemsList.dataProvider.getItemAt(i)).id == itemData.id)
						{
							_itemsList.scrollToDisplayIndex(i, 0);
							break;
						}
					}
				}
			}
			
			this.invalidate(INVALIDATION_FLAG_ITEMS);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Disposal
		
		override public function dispose():void
		{
			_background.removeFromParent(true);
			_background = null;
			
			_itemsList.removeEventListener(Event.SCROLL, onScroll);
			_itemsList.removeEventListener(LKAvatarMakerEventTypes.ITEM_SELECTED, onItemSelected);
			_itemsList.removeFromParent(true);
			_itemsList = null;
			
			TweenMax.killTweensOf(_listTopShadow);
			_listTopShadow.removeFromParent(true);
			_listTopShadow = null;
			
			TweenMax.killTweensOf(_listBottomShadow);
			_listBottomShadow.removeFromParent(true);
			_listBottomShadow = null;
			
			_checkBox.removeEventListener(Event.TRIGGERED, onFilterSelected);
			_checkBox.removeFromParent(true);
			_checkBox = null;
			
			_currentDataList = new Vector.<AvatarItemData>();
			_currentDataList = null;
			
			_currentArmatureSectionType = "";
			
			_colorButton.removeEventListener(Event.TRIGGERED, onSideButtonTriggered);
			_colorButton.removeFromParent(true);
			_colorButton = null;
			
			_sectionButton.removeEventListener(Event.TRIGGERED, onSideButtonTriggered);
			_sectionButton.removeFromParent(true);
			_sectionButton = null;
			
			super.dispose();
		}
		
	}
}