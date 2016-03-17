/*
 Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
 Framework mobile
 Author  : Maxime Lhoez
 Created : 15 Décembre 2014
*/
package com.ludofactory.mobile.core.avatar.maker.items
{
	
	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.common.utils.Utilities;
	import com.ludofactory.common.utils.roundUp;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.avatar.AvatarMakerAssets;
	import com.ludofactory.mobile.core.avatar.maker.CoinsAndBasket;
	import com.ludofactory.mobile.core.avatar.maker.TouchableItemRenderer;
	import com.ludofactory.mobile.core.avatar.maker.data.AvatarFrameData;
	import com.ludofactory.mobile.core.avatar.test.config.LudokadoBones;
	import com.ludofactory.mobile.core.avatar.test.events.LKAvatarMakerEventTypes;
	import com.ludofactory.mobile.core.config.GlobalConfig;
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
		
		private var _itemWidth:int;
		
		private var _itemHeight:int;
		
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
			
			_itemWidth = scaleAndRoundToDpi(GlobalConfig.isPhone ? 130 : 200);
			_itemHeight = scaleAndRoundToDpi(GlobalConfig.isPhone ? 160 : 230);
			
			this.width = _itemWidth;
			this.height = _itemHeight;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			_background = new Image(AvatarMakerAssets.expandTexture);
			_background.alpha = 0;
			addChild(_background);
			
			_iconBackground = new Image(AvatarMakerAssets.iconBehaviorBackgroundTexture);
			_iconBackground.scaleX = _iconBackground.scaleY = Utilities.getScaleToFill(_iconBackground.width, _iconBackground.height, (this.width * 0.9), (this.height * 0.65));
			_iconBackground.touchable = false;
			_iconBackground.alignPivot();
			addChild(_iconBackground);
			
			_itemIcon = new ImageLoader();
			_itemIcon.addEventListener(FeathersEventType.ERROR, onIOError);
			_itemIcon.addEventListener(Event.COMPLETE, onImageloaded);
			_itemIcon.snapToPixels = true;
			_itemIcon.maintainAspectRatio = true;
			_itemIcon.touchable = false;
			addChild(_itemIcon);
			
			_itemNameLabel = new TextField(10, (_itemHeight - _iconBackground.width) * 0.5, "", Theme.FONT_OSWALD, scaleAndRoundToDpi(26), AvatarItemRenderer.BUYABLE_BEHAVIOR_ITEM_COLOR);
			_itemNameLabel.autoScale = true;
			_itemNameLabel.touchable = false;
			addChild(_itemNameLabel);
			
			_itemPriceLabel = new TextField(10, (_itemHeight - _iconBackground.width) * 0.5, "", Theme.FONT_OSWALD, scaleAndRoundToDpi(26), AvatarItemRenderer.PRICE_BEHAVIOR_ITEM_COLOR);
			_itemPriceLabel.hAlign = HAlign.RIGHT;
			_itemPriceLabel.touchable = false;
			_itemPriceLabel.autoScale = true;
			addChild(_itemPriceLabel);
			
			_basket = new CoinsAndBasket();
			_basket.visible = false;
			_basket.scaleX = _basket.scaleY = 0.8;
			addChild(_basket);
			
			_isNewIcon = new Image(AvatarMakerAssets.newItemSmallIconTexture);
			_isNewIcon.scaleX = _isNewIcon.scaleY = GlobalConfig.dpiScale;
			_isNewIcon.touchable = false;
			_isNewIcon.visible = false;
			addChild(_isNewIcon);
			
			_vipIconBackground = new Image(AvatarMakerAssets.vip_locked_icon_rank_12);
			_vipIconBackground.scaleX = _vipIconBackground.scaleY = GlobalConfig.dpiScale;
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
				_background.width = this.width;
				_background.height = this.height;
				
				_iconBackground.x = roundUp(_itemWidth * 0.5);
				_iconBackground.y = roundUp(_itemHeight * 0.5);
				
				_itemIcon.validate();
				_itemIcon.alignPivot();
				_itemIcon.x = _iconBackground.x;
				_itemIcon.y = _iconBackground.y;
				
				// texts
				
				_itemNameLabel.width = _itemWidth;
				
				_itemPriceLabel.y = _itemHeight - _itemPriceLabel.height;
				_itemPriceLabel.width = _itemWidth * 0.9 - _itemPriceLabel.x - scaleAndRoundToDpi((_basket.visible ? 30 : 0));
				
				_basket.x = (_itemWidth * 0.9 - scaleAndRoundToDpi(30)); // 30 = largeur du basket icon
				_basket.y = _itemHeight - _basket.height - 7;
				
				// icons
				
				_isNewIcon.x = roundUp(_iconBackground.x - (_iconBackground.width * 0.5));
				_isNewIcon.y = roundUp(_iconBackground.y - (_iconBackground.height * 0.5));
				
				_vipIconBackground.x = _iconBackground.x + (_iconBackground.width * 0.5) - _vipIconBackground.width;
				_vipIconBackground.y = _iconBackground.y + (_iconBackground.height * 0.5) - _vipIconBackground.height;
			}
		}
		
		protected function commitData():void
		{
			if(this._owner && _data)
			{
				_iconBackground.texture = _data.isSelected ? AvatarMakerAssets.iconEquippedBackgroundTexture : (_data.isOwned ? AvatarMakerAssets.iconBoughtNotEquippedBackgroundTexture : AvatarMakerAssets.iconBehaviorBackgroundTexture);
				
				// the new icon is displayed when the behavior is a new one
				_isNewIcon.visible = _data.isNew || _data.isNewVip;
				
				_vipIconBackground.texture = _data.isLocked ? AvatarMakerAssets["vip_locked_icon_rank_" + _data.rank] : _vipIconBackground.texture;
				_vipIconBackground.visible = _data.isLocked;
				
				_itemNameLabel.visible = _itemPriceLabel.visible = true;
				_itemNameLabel.text = _data.name;
				_itemPriceLabel.text = _data.isLocked ? _("Rang insuffisant") : (_data.isSelected ? (_data.isOwned ? _("Equipé") : (_data.price == 0 ? _("GRATUIT") : Utilities.splitThousands(_data.price))) : (_data.isOwned ? _("Acquis") : (_data.price == 0 ? _("GRATUIT") : Utilities.splitThousands(_data.price))));
				_itemPriceLabel.color = _data.isLocked ? AvatarItemRenderer.LOCKED_ITEM_COLOR : AvatarItemRenderer.PRICE_ITEM_COLOR;
				
				_itemNameLabel.color = _data.isSelected ? AvatarItemRenderer.EQUIPPED_ITEM_COLOR : (_data.isOwned ? AvatarItemRenderer.OWNED_ITEM_COLOR : AvatarItemRenderer.BUYABLE_BEHAVIOR_ITEM_COLOR);
				
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
			if(_data.armatureSectionType == LudokadoBones.EYES_COLOR || _data.armatureSectionType == LudokadoBones.HAIR_COLOR
					|| _data.armatureSectionType == LudokadoBones.LIPS_COLOR || _data.armatureSectionType == LudokadoBones.SKIN_COLOR)
				_itemIcon.scaleX = _itemIcon.scaleY = _iconBackground.scaleX - (0.25 * GlobalConfig.dpiScale); //0.75;
			else if( _data.armatureSectionType == LudokadoBones.MOUSTACHE || _data.armatureSectionType == LudokadoBones.BEARD ||
					_data.armatureSectionType == LudokadoBones.EYEBROWS || _data.armatureSectionType == LudokadoBones.EYES ||
					_data.armatureSectionType == LudokadoBones.FACE_CUSTOM || _data.armatureSectionType == LudokadoBones.AGE )
				_itemIcon.scaleX = _itemIcon.scaleY = _iconBackground.scaleX - (0.5 * GlobalConfig.dpiScale); //0.5;
			else
				_itemIcon.scaleX = _itemIcon.scaleY = _iconBackground.scaleX - (0.4 * GlobalConfig.dpiScale); //0.6;
			
			_itemIcon.validate();
			_itemIcon.alignPivot();
			_itemIcon.x = _iconBackground.x;
			_itemIcon.y = _iconBackground.y;
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