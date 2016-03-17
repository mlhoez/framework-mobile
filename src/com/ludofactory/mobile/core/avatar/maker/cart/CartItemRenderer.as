/*
 Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
 Framework mobile
 Author  : Maxime Lhoez
 Created : 15 Décembre 2014
*/
package com.ludofactory.mobile.core.avatar.maker.cart
{
	
	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.common.utils.Utilities;
	import com.ludofactory.common.utils.roundUp;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.avatar.AvatarMakerAssets;
	import com.ludofactory.mobile.core.avatar.maker.TouchableItemRenderer;
	import com.ludofactory.mobile.core.avatar.test.events.LKAvatarMakerEventTypes;
	import com.ludofactory.mobile.core.avatar.test.manager.LKConfigManager;
	import com.ludofactory.mobile.core.avatar.test.manager.LudokadoBoneConfiguration;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.notification.NotificationPopupManager;
	import com.ludofactory.mobile.core.notification.content.FaqNotificationContent;
	import com.ludofactory.mobile.core.theme.Theme;
	import com.ludofactory.mobile.navigation.faq.FaqQuestionAnswerData;
	
	import feathers.controls.ImageLoader;
	import feathers.events.FeathersEventType;
	
	import starling.display.Button;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.events.Event;
	import starling.text.TextField;
	import starling.text.TextFieldAutoSize;
	import starling.utils.HAlign;
	import starling.utils.formatString;
	
	/**
	 * Globbies items list renderer.
	 */	
	public class CartItemRenderer extends TouchableItemRenderer
	{
		
	// ---------- Placement properties
		
		/**
		 * Maximum height of an item in the list. */		
		public var MAX_ITEM_HEIGHT:int = 60;

	// ---------- Properties

		/**
		 * The renderer background. */
		private var _background:Quad;
		/**
		 * Item image background. */
		private var _itemImageBackground:Image;
		/**
		 * Item image. */
		private var _itemImage:ImageLoader;
 		/**
		 * Item name. */		
		private var _itemNameLabel:TextField;
		/**
		 * Item price (or "Select" if already owned). */
		private var _itemPriceLabel:TextField;
		/**
		 * Cookie icon (displayed when an item is buyable). */
		private var _pointsIcon:Image;
		/**
		 * Information button (when the user does not have the rank). */
		private var _infoButton:Button;
		/**
		 * The check box. */
		private var _checkbox:CartCheckBox;
		
		public function CartItemRenderer()
		{
			super();
			
			this.height = MAX_ITEM_HEIGHT = scaleAndRoundToDpi(MAX_ITEM_HEIGHT);
			
			// act as a single container for touch events (improves performances)
			touchGroup = true;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			
			_background = new Quad(10, this.height, 0xdddddd);
			addChild(_background);
			
			_itemImageBackground = new Image(AvatarMakerAssets.cartItemIconBackgroundTexture);
			_itemImageBackground.scaleX = _itemImageBackground.scaleY = Utilities.getScaleToFillHeight(_itemImageBackground.height, (this.height * 0.9));
			addChild(_itemImageBackground);
			
			_itemImage = new ImageLoader();
			_itemImage.snapToPixels = true;
			_itemImage.maintainAspectRatio = true;
			_itemImage.touchable = false;
			_itemImage.addEventListener(FeathersEventType.ERROR, onIOError);
			_itemImage.addEventListener(Event.COMPLETE, onImageloaded);
			addChild(_itemImage);
			
			_pointsIcon = new Image(AvatarMakerAssets.cartPointBigIconTexture);
			_pointsIcon.scaleX = _pointsIcon.scaleY = GlobalConfig.dpiScale;
			addChild(_pointsIcon);
			
			_checkbox = new CartCheckBox();
			_checkbox.isSelected = true;
			addChild(_checkbox);
			
			_itemNameLabel = new TextField(scaleAndRoundToDpi(100), MAX_ITEM_HEIGHT, "", Theme.FONT_OSWALD, scaleAndRoundToDpi(GlobalConfig.isPhone ? 20 : 24), 0x676462);
			_itemNameLabel.hAlign = HAlign.LEFT;
			_itemNameLabel.autoScale = true;
			//_itemNameLabel.border = true;
			addChild(_itemNameLabel);
			
			_itemPriceLabel = new TextField(scaleAndRoundToDpi(100), MAX_ITEM_HEIGHT, "", Theme.FONT_OSWALD, scaleAndRoundToDpi(GlobalConfig.isPhone ? 20 : 24), 0x676462);
			_itemPriceLabel.autoSize = TextFieldAutoSize.HORIZONTAL;
			//_itemPriceLabel.hAlign = HAlign.RIGHT;
			//_itemPriceLabel.border = true;
			addChild(_itemPriceLabel);
			
			_infoButton = new Button(AbstractEntryPoint.assets.getTexture("info-icon"));
			_infoButton.scaleX = _infoButton.scaleY = GlobalConfig.dpiScale;
			addChild(_infoButton);
		}
		
		override protected function draw():void
		{
			const dataInvalid:Boolean = this.isInvalid(INVALIDATION_FLAG_DATA);
			var sizeInvalid:Boolean = this.isInvalid(INVALIDATION_FLAG_SIZE);
			
			if(dataInvalid)
				this.commitData();
			
			if(dataInvalid || sizeInvalid)
			{
				_background.width = actualWidth;
				_background.height = MAX_ITEM_HEIGHT - scaleAndRoundToDpi(3);
				
				_itemImage.validate();
				_itemImage.alignPivot();
				_itemImage.x = roundUp(_itemImageBackground.x + (_itemImageBackground.width * 0.5));
				_itemImage.y = roundUp(_itemImageBackground.y + (_itemImageBackground.height * 0.5));
				
				_checkbox.x = roundUp(actualWidth - _checkbox.width - scaleAndRoundToDpi(10));
				_checkbox.y = roundUp((actualHeight - _checkbox.height) * 0.5);
				
				_pointsIcon.x = _checkbox.x - _pointsIcon.width - scaleAndRoundToDpi(3) - scaleAndRoundToDpi(5);
				_pointsIcon.y = roundUp((MAX_ITEM_HEIGHT - _pointsIcon.height) * 0.5) - scaleAndRoundToDpi(2);
				
				_infoButton.x = actualWidth - _infoButton.width;
				_infoButton.y = roundUp((MAX_ITEM_HEIGHT - _infoButton.height) * 0.5);
				
				_itemPriceLabel.x = _data.isLocked ? (_infoButton.x - _itemPriceLabel.width + scaleAndRoundToDpi(5)) : (_pointsIcon.x - _itemPriceLabel.width - scaleAndRoundToDpi(5));
				_itemPriceLabel.width = _data.isLocked ? (_infoButton.x - _infoButton.width) : (_pointsIcon.x - _itemImageBackground.width - scaleAndRoundToDpi(6)); // 3 + 3
				
				_itemNameLabel.x = _itemImageBackground.width + scaleAndRoundToDpi(10);
				_itemNameLabel.width = _itemPriceLabel.x - _itemNameLabel.x;
			}
		}
		
		protected function commitData():void
		{
			if(this._owner && _data)
			{
				_itemNameLabel.text = _data.name;
				_itemPriceLabel.text = _data.isOwned ? _("Acquis") : ((_data.isLocked ? _("Rang insuffisant") : (_data.price == 0 ? _("GRATUIT") : Utilities.splitThousands(_data.price))));
				_itemImage.source = _data.imageUrl;
				
				_checkbox.isSelected = _data.isChecked;
				
				_infoButton.visible = _data.isLocked;
				
				_background.color = _index % 2 == 0 ? 0xe7e7e7 : 0xffffff;
				_itemPriceLabel.color = _data.isLocked ? 0xee0000 : 0x676462;
				_pointsIcon.visible = !_data.isLocked;
				_checkbox.visible = !_data.isLocked;
			}
		}

//------------------------------------------------------------------------------------------------------------
//	Handlers

		/**
		 * Removes this item from the basket.
		 */
		override protected function onTriggered():void
		{
			if(!_data.isLocked)
			{
				_data.isChecked = !_data.isChecked;
				_checkbox.isSelected = _data.isChecked;
				LudokadoBoneConfiguration(LKConfigManager.currentConfig[_data.armatureSectionType]).isCheckedInCart = _data.isChecked;
				owner.dispatchEventWith(LKAvatarMakerEventTypes.ITEM_SELECTED_OR_DESELECTED, true, _data);
			}
			else
			{
				// TODO afficher un truc plus spécifique et poussant à l'achat
				NotificationPopupManager.addNotification( new FaqNotificationContent(new FaqQuestionAnswerData({question:_("Pourquoi cet objet est bloqué ?"), reponse:formatString(_("Vous devez avoir le rang {0} pour pouvoir acheter cet objet."), _data.rankName)})));
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Image
		
		/**
		 * The image have been loaded.
		 */
		private function onImageloaded(event:Event):void
		{
			_itemImage.scaleX = _itemImage.scaleY = 1;
			_itemImage.validate();
			_itemImage.scaleX = _itemImage.scaleY = Utilities.getScaleToFillHeight(_itemImage.height, _itemImageBackground.height * 0.9);
			
			_itemImage.validate();
			_itemImage.alignPivot();
			_itemImage.x = roundUp(_itemImageBackground.x + (_itemImageBackground.width * 0.5));
			_itemImage.y = roundUp(_itemImageBackground.y + (_itemImageBackground.height * 0.5));
		}
		
		/**
		 * The image could not be loaded.
		 */
		private function onIOError(event:Event):void
		{
			
		}

//------------------------------------------------------------------------------------------------------------
//	Get - Set

		protected var _data:CartData;

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
			this._data = CartData(value);
			this.invalidate(INVALIDATION_FLAG_DATA);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
		
		override public function dispose():void
		{
			_background.removeFromParent(true);
			_background = null;
			
			_itemImageBackground.removeFromParent(true);
			_itemImageBackground = null;
			
			_itemImage.removeEventListener(FeathersEventType.ERROR, onIOError);
			_itemImage.removeEventListener(Event.COMPLETE, onImageloaded);
			_itemImage.removeFromParent(true);
			_itemImage = null;
			
			_itemNameLabel.removeFromParent(true);
			_itemNameLabel = null;
			
			_itemPriceLabel.removeFromParent(true);
			_itemPriceLabel = null;
			
			_pointsIcon.removeFromParent(true);
			_pointsIcon = null;
			
			_infoButton.removeFromParent(true);
			_infoButton = null;
			
			_checkbox.removeFromParent(true);
			_checkbox = null;
			
			_data = null;
			
			super.dispose();
		}
		
	}
}