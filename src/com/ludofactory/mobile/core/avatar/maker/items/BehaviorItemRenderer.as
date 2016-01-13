/*
Copyright © 2006-2014 Ludo Factory
Framework mobile - Globbies
Author  : Maxime Lhoez
Created : 15 Décembre 2014
*/
package com.ludofactory.mobile.core.avatar.maker.items
{
	
	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.common.utils.Utilities;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.avatar.AvatarMakerAssets;
	import com.ludofactory.mobile.core.avatar.maker.CoinsAndBasket;
	import com.ludofactory.mobile.core.avatar.maker.TouchableItemRenderer;
	import com.ludofactory.mobile.core.avatar.maker.data.AvatarFrameData;
	import com.ludofactory.mobile.core.avatar.test.events.LKAvatarMakerEventTypes;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import feathers.controls.ImageLoader;
	import feathers.events.FeathersEventType;
	
	import starling.display.ButtonState;
	import starling.display.Image;
	import starling.events.Event;
	import starling.text.TextField;
	import starling.textures.TextureSmoothing;
	import starling.utils.HAlign;
	import starling.utils.VAlign;
	
	/**
	 * Globbies items list renderer.
	 */	
	public class BehaviorItemRenderer extends TouchableItemRenderer
	{
		
	// ---------- Layout properties
		
		/**
		 * Maximum height of an item in the list. */
		public static const MAX_ITEM_HEIGHT:int = 50;
		
	// ---------- Common properties
		
		/**
		 * The item renderer background. */
		private var _background:Image;
		/**
		 * The icon background. */
		private var _iconBackground:Image;
		/**
		 * Item icon. */
		private var _itemIcon:ImageLoader;
		/**
		 * Item name. */
		private var _itemNameLabel:TextField;
		/**
		 * Item price (if not already owned). */
		private var _itemPriceLabel:TextField;
		/**
		 * The basket used to animate the basket and cookie when selected and not owned. */
		private var _basket:CoinsAndBasket;
		/**
		 * New icon displayed when it's a new item or when one of the behaviors is new. */
		private var _isNewIcon:Image;
		
		/**
		 * Vip icon background displayed when the item is locked. */
		private var _vipIconBackground:Image;
		
		public function BehaviorItemRenderer()
		{
			super();
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			this.height = MAX_ITEM_HEIGHT;
			
			_background = new Image(AvatarMakerAssets.expandTexture);
			_background.alpha = 0;
			addChild(_background);
			
			_itemNameLabel = new TextField(100, MAX_ITEM_HEIGHT, "", Theme.FONT_OSWALD, 14, AvatarItemRenderer.BUYABLE_ITEM_COLOR);
			_itemNameLabel.autoScale = true;
			_itemNameLabel.hAlign = HAlign.LEFT;
			_itemNameLabel.vAlign = VAlign.CENTER;
			_itemNameLabel.touchable = false;
			//_itemNameLabel.border = true;
			addChild(_itemNameLabel);
			
			_itemPriceLabel = new TextField(100, MAX_ITEM_HEIGHT, "", Theme.FONT_OSWALD, 13, AvatarItemRenderer.PRICE_ITEM_COLOR);
			_itemPriceLabel.hAlign = HAlign.RIGHT;
			_itemPriceLabel.touchable = false;
			_itemPriceLabel.autoScale = true;
			//_itemPriceLabel.border = true;
			addChild(_itemPriceLabel);
			
			_iconBackground = new Image(AvatarMakerAssets.iconBuyableBackgroundTexture);
			_iconBackground.touchable = false;
			_iconBackground.alignPivot();
			_iconBackground.scaleX = _iconBackground.scaleY = Utilities.getScaleToFill(_iconBackground.width, _iconBackground.height, NaN, (MAX_ITEM_HEIGHT - 10));
			addChild(_iconBackground);
			
			_itemIcon = new ImageLoader();
			_itemIcon.addEventListener(FeathersEventType.ERROR, onIOError);
			_itemIcon.addEventListener(Event.COMPLETE, onImageloaded);
			_itemIcon.snapToPixels = true;
			_itemIcon.maintainAspectRatio = true;
			_itemIcon.touchable = false;
			_itemIcon.smoothing = TextureSmoothing.TRILINEAR;
			_itemIcon.width = _itemIcon.height = 80;
			addChild(_itemIcon);
			
			_basket = new CoinsAndBasket();
			_basket.visible = false;
			_basket.scaleX = _basket.scaleY = 0.8;
			addChild(_basket);
			
			_isNewIcon = new Image(AvatarMakerAssets.newItemSmallIconTexture);
			_isNewIcon.touchable = false;
			_isNewIcon.visible = false;
			addChild(_isNewIcon);
			
			_vipIconBackground = new Image(AbstractEntryPoint.assets.getTexture("Rank-12"));
			_vipIconBackground.touchable = false;
			_vipIconBackground.visible = false;
			addChild(_vipIconBackground);
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
				_background.width = actualWidth;
				
				_iconBackground.x = (_iconBackground.width * 0.5) + 5;
				_iconBackground.y = (_iconBackground.height * 0.5) + 5;
				
				_isNewIcon.x = 5;
				_isNewIcon.y = 5;
				
				_itemIcon.validate();
				_itemIcon.scaleX = _itemIcon.scaleY = 1;
				_itemIcon.scaleX = _itemIcon.scaleY = Utilities.getScaleToFill(_itemIcon.width, _itemIcon.height, NaN, MAX_ITEM_HEIGHT);
				_itemIcon.alignPivot();
				_itemIcon.x = _iconBackground.x;
				_itemIcon.y = _iconBackground.y;
				
				_itemPriceLabel.x = _iconBackground.x + (_iconBackground.width * 0.5) + 5 + 50;
				_itemPriceLabel.width = actualWidth - _itemPriceLabel.x - (_basket.visible ? 30 : 5);
				
				_basket.x = (actualWidth - 29); // 21 = largeur du basket icon
				_basket.y = (MAX_ITEM_HEIGHT - _basket.height) * 0.5 - 1;
				
				_itemNameLabel.x = _iconBackground.x + (_iconBackground.width * 0.5) + 5;
				_itemNameLabel.width = _itemPriceLabel.x - _itemNameLabel.x;
				
				_vipIconBackground.x = _iconBackground.x + (_iconBackground.width * 0.5) - _vipIconBackground.width;
				_vipIconBackground.y = _iconBackground.y + (_iconBackground.height * 0.5) - _vipIconBackground.height;
			}
		}
		
		protected function commitData():void
		{
			if(this._owner && _data)
			{
				_iconBackground.texture = _data.isSelected ? AvatarMakerAssets.iconEquippedBackgroundTexture : (_data.isOwned ? AvatarMakerAssets.iconBoughtNotEquippedBackgroundTexture : AvatarMakerAssets.iconBuyableBackgroundTexture);
				
				// the new icon is displayed when the behavior is a new one
				_isNewIcon.visible = _data.isNew || _data.isNewVip;
				
				_vipIconBackground.texture = _data.isLocked ? AvatarMakerAssets["vip_locked_small_icon_rank_" + _data.rank] : _vipIconBackground.texture;
				_vipIconBackground.visible = _data.isLocked;
				
				_itemNameLabel.visible = _itemPriceLabel.visible = true;
				_itemNameLabel.text = _data.name;
				_itemPriceLabel.text = _data.isLocked ? _("Rang insuffisant") : (_data.isSelected ? (_data.isOwned ? _("Equipé") : (_data.price == 0 ? _("GRATUIT") : Utilities.splitThousands(_data.price))) : (_data.isOwned ? _("Acquis") : (_data.price == 0 ? _("GRATUIT") : Utilities.splitThousands(_data.price))));
				_itemPriceLabel.color = _data.isLocked ? AvatarItemRenderer.LOCKED_ITEM_COLOR : AvatarItemRenderer.PRICE_ITEM_COLOR;
				
				_itemNameLabel.color = _data.isSelected ? AvatarItemRenderer.EQUIPPED_ITEM_COLOR : (_data.isOwned ? AvatarItemRenderer.OWNED_ITEM_COLOR : AvatarItemRenderer.BUYABLE_ITEM_COLOR);
				
				_itemIcon.source = _data.imageUrl;
				
				_basket.visible = !_data.isOwned && !_data.isLocked && _data.price != 0;

				if( !_data.isOwned )
				{
					// the item is not owned so we can animate the basket here
					if( _data.isSelected ) _basket.animateInBasket( ItemSelector.hasChangedSection || AvatarItemRenderer(owner.parent).owner.isScrolling);
					else _basket.animateOutBasket( ItemSelector.hasChangedSection || AvatarItemRenderer(owner.parent).owner.isScrolling);
				}
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Touch handler
		
		override protected function onTriggered():void
		{
			if(!_data.isSelected)
			{
				state = ButtonState.UP;
				_data.isSelected = !_data.isSelected;
				dispatchEventWith(LKAvatarMakerEventTypes.BEHAVIOR_SELECTED, true, _data);
			}
		}

		/**
		 * Updates the current touch state.
		 */
		override public function set state(value:String):void
		{
			super.state = value;

			switch (_currentTouchState)
			{
				case ButtonState.DOWN: { break; }
				case ButtonState.DISABLED: { break; }
				case ButtonState.UP: { _isOver = false; break; }
				case ButtonState.OVER:
				{
					if( _data.isSelected )
						return;
					_isOver = true;
					break;
				}
				default: { throw new ArgumentError("Invalid button state: " + _currentTouchState); }
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Image handlers
		
		/**
		 * The image have been loaded.
		 */
		private function onImageloaded(event:Event):void
		{
			//invalidate(INVALIDATION_FLAG_SIZE);
		}
		
		/**
		 * The image could not be loaded.
		 */
		private function onIOError(event:Event):void
		{
			//_itemIcon.source = Theme["defaultIconForSection_" + _data.armatureSectionType];
		}
		
//------------------------------------------------------------------------------------------------------------
//	Get - Set

		protected var _data:AvatarFrameData;

		override public function get data():Object
		{
			return this._data;
		}

		override public function set data(value:Object):void
		{
			if(this._data == value)
			{
				return;
			}
			this._data = AvatarFrameData(value);
			this.invalidate(INVALIDATION_FLAG_DATA);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
		
		override public function dispose():void
		{
			targetTouch = null;
			
			_itemIcon.removeEventListener(FeathersEventType.ERROR, onIOError);
			_itemIcon.removeEventListener(Event.COMPLETE, onImageloaded);
			_itemIcon.removeFromParent(true);
			_itemIcon = null;
			
			_itemNameLabel.removeFromParent(true);
			_itemNameLabel = null;
			
			_itemPriceLabel.removeFromParent(true);
			_itemPriceLabel = null;
			
			_isNewIcon.removeFromParent(true);
			_isNewIcon = null;
			
			_data = null;
			
			super.dispose();
		}
		
	}
}