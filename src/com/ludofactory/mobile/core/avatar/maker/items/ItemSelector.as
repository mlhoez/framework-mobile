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
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.avatar.AvatarAssets;
	import com.ludofactory.mobile.core.avatar.maker.CustomCheckBox;
	import com.ludofactory.mobile.core.avatar.maker.data.AvatarItemData;
	import com.ludofactory.mobile.core.avatar.test.config.LudokadoBones;
	import com.ludofactory.mobile.core.avatar.test.events.LKAvatarMakerEventTypes;
	import com.ludofactory.mobile.core.avatar.test.manager.LKConfigManager;
	import com.ludofactory.mobile.core.avatar.test.manager.LudokadoBoneConfiguration;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import feathers.controls.List;
	import feathers.controls.Scroller;
	import feathers.core.FeathersControl;
	import feathers.data.ListCollection;
	import feathers.display.Scale9Image;
	import feathers.layout.HorizontalLayout;
	import feathers.layout.VerticalLayout;
	import feathers.textures.Scale9Textures;
	
	import flash.geom.Rectangle;
	import flash.utils.unescapeMultiByte;
	
	import starling.display.Image;
	import starling.display.Quad;
	import starling.events.Event;
	import starling.text.TextField;
	import starling.utils.HAlign;
	import starling.utils.VAlign;
	import starling.utils.deg2rad;
	
	public class ItemSelector extends FeathersControl
	{
		
	// ---------- Textures
		
		//private static const 
		
	// ---------- Constants
		
		/**
		 * Invalidation flag to indicate that the dimensions of the UI control have changed. */
		public static const INVALIDATION_FLAG_ITEMS:String = "items";
		/**
		 * Maximum list height (8 items * 54 height). */
		private static var MAXIMUM_LIST_HEIGHT:int = 475;
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
		
		public function ItemSelector()
		{
			super();
			
			MAXIMUM_LIST_HEIGHT = scaleAndRoundToDpi(MAXIMUM_LIST_HEIGHT);
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			_background = new Scale9Image(new Scale9Textures(AvatarAssets.panelBackground, new Rectangle(10, 10, 12, 12)));
			_background.touchable = false;
			addChild(_background);

			const layout:HorizontalLayout = new HorizontalLayout();
			layout.verticalAlign = VerticalLayout.VERTICAL_ALIGN_TOP;
			layout.horizontalAlign = VerticalLayout.HORIZONTAL_ALIGN_JUSTIFY;
			layout.gap = scaleAndRoundToDpi(5);
			layout.hasVariableItemDimensions = true;
			
			_itemsList = new List();
			_itemsList.isSelectable = false;
			_itemsList.layout = layout;
			_itemsList.itemRendererType = AvatarItemRenderer;
			addChild(_itemsList);
			_itemsList.verticalScrollPolicy = Scroller.SCROLL_POLICY_AUTO;
			_itemsList.horizontalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			_itemsList.addEventListener(Event.SCROLL, onScroll);
			_itemsList.addEventListener(LKAvatarMakerEventTypes.ITEM_SELECTED, onItemSelected);
			
			_listTopShadow = new Image(AbstractEntryPoint.assets.getTexture("list-shadow"));
			_listTopShadow.touchable = false;
			_listTopShadow.scaleX = _listTopShadow.scaleY = GlobalConfig.dpiScale;
			addChild(_listTopShadow);

			_listBottomShadow = new Image(AbstractEntryPoint.assets.getTexture("list-shadow"));
			_listBottomShadow.touchable = false;
			_listBottomShadow.alignPivot(HAlign.RIGHT, VAlign.BOTTOM);
			_listBottomShadow.rotation = deg2rad(180);
			_listBottomShadow.scaleX = _listBottomShadow.scaleY = GlobalConfig.dpiScale;
			addChild(_listBottomShadow);
			
			_checkBox = new CustomCheckBox();
			_checkBox.addEventListener(Event.TRIGGERED, onFilterSelected);
			addChild(_checkBox);
		}
		
		override protected function draw():void
		{
			super.draw();
			
			if( isInvalid(INVALIDATION_FLAG_SIZE) )
			{
				_background.width = actualWidth;
				_background.height = actualHeight;
				
				_itemsList.x = scaleAndRoundToDpi(10);
				_itemsList.y = scaleAndRoundToDpi(5);
				_itemsList.width = roundUp(this.actualWidth - (_itemsList.x * 2));
				_itemsList.height = MAXIMUM_LIST_HEIGHT;
				
				_checkBox.x = -scaleAndRoundToDpi(50);
				_checkBox.y = _itemsList.y + _itemsList.height + scaleAndRoundToDpi(5);
				
				_listTopShadow.x = scaleAndRoundToDpi(10);
				_listTopShadow.y = _itemsList.y;
				
				_listBottomShadow.x = scaleAndRoundToDpi(10);
				_listBottomShadow.y = _itemsList.y + _itemsList.height - _listBottomShadow.height;
				
				this.invalidate(INVALIDATION_FLAG_ITEMS);
			}
			
			if( isInvalid(INVALIDATION_FLAG_ITEMS) )
			{
				_itemsList.validate();
				_listTopShadow.width = _listBottomShadow.width = _itemsList.width + (_itemsList.viewPort.height <= MAXIMUM_LIST_HEIGHT ? 0 : scaleAndRoundToDpi(-14));

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
		 * Updates the items list and 
		 */
		public function updateItems(items:Vector.<AvatarItemData>, armatureSectionGroup:String):void
		{
			/*switch (armatureSectionGroup)
			{
				case LudokadoBones.HAT:          { _titleLabel.text = _("Chapeau");             break; }
				case LudokadoBones.HAIR:         { _titleLabel.text = _("Cheveux");             break; }
				case LudokadoBones.EYEBROWS:     { _titleLabel.text = _("Sourcils");            break; }
				case LudokadoBones.EYES:         { _titleLabel.text = _("Yeux");                break; }
				case LudokadoBones.NOSE:         { _titleLabel.text = _("Nez");                 break; }
				case LudokadoBones.MOUTH:        { _titleLabel.text = _("Bouche");              break; }
				case LudokadoBones.FACE_CUSTOM:  { _titleLabel.text = _("Visage");              break; }
				case LudokadoBones.MOUSTACHE:    { _titleLabel.text = _("Moustache");           break; }
				case LudokadoBones.BEARD:        { _titleLabel.text = _("Barbe");               break; }
				case LudokadoBones.SHIRT:        { _titleLabel.text = _("T-Shirt");             break; }
				case LudokadoBones.EPAULET:      { _titleLabel.text = _("Epaulettes");          break; }
				case LudokadoBones.LEFT_HAND:    { _titleLabel.text = _("Main gauche");         break; }
				case LudokadoBones.RIGHT_HAND:   { _titleLabel.text = _("Main droite");         break; }
				case LudokadoBones.HAIR_COLOR:   { _titleLabel.text = _("Couleur des cheveux"); break; }
				case LudokadoBones.EYES_COLOR:   { _titleLabel.text = _("Couleur des yeux");    break; }
				case LudokadoBones.SKIN_COLOR:   { _titleLabel.text = _("Couleur de peau");     break; }
				case LudokadoBones.LIPS_COLOR:   { _titleLabel.text = _("Couleur des lèvres");  break; }
			}*/
			
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
			updateItems(ItemManager.getInstance().items[itemData.armatureSectionType], itemData.armatureSectionType);
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
			
			TweenMax.killTweensOf(_listTopShadow);
			_listTopShadow.removeFromParent(true);
			_listTopShadow = null;
			
			TweenMax.killTweensOf(_listBottomShadow);
			_listBottomShadow.removeFromParent(true);
			_listBottomShadow = null;
			
			_itemsList.removeEventListener(Event.SCROLL, onScroll);
			_itemsList.removeEventListener(LKAvatarMakerEventTypes.ITEM_SELECTED, onItemSelected);
			_itemsList.removeFromParent(true);
			_itemsList = null;
			
			_checkBox.removeEventListener(Event.TRIGGERED, onFilterSelected);
			_checkBox.removeFromParent(true);
			_checkBox = null;
			
			_currentDataList = new Vector.<AvatarItemData>();
			_currentDataList = null;
			
			_currentArmatureSectionType = "";
			
			super.dispose();
		}
		
	}
}