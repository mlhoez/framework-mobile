/*
 Copyright © 2006-2015 Ludo Factory
 Avatar Maker - Ludokado
 Author  : Maxime Lhoez
 Created : 18 Décembre 2014
*/
package com.ludofactory.mobile.core.avatar.maker.cart
{
	
	import com.greensock.TweenMax;
	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.common.utils.Utilities;
	import com.ludofactory.common.utils.Utilities;
	import com.ludofactory.common.utils.Utilities;
	import com.ludofactory.common.utils.Utilities;
	import com.ludofactory.common.utils.logs.log;
	import com.ludofactory.mobile.ButtonFactory;
	import com.ludofactory.mobile.MobileButton;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.avatar.AvatarMakerAssets;
	import com.ludofactory.mobile.core.avatar.test.events.LKAvatarMakerEventTypes;
	import com.ludofactory.mobile.core.avatar.test.manager.AvatarManager;
	import com.ludofactory.mobile.core.avatar.test.manager.LKConfigManager;
	import com.ludofactory.mobile.core.manager.InfoContent;
	import com.ludofactory.mobile.core.manager.InfoManager;
	import com.ludofactory.mobile.core.manager.MemberManager;
	import com.ludofactory.mobile.core.remoting.Remote;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import feathers.controls.List;
	import feathers.controls.Scroller;
	import feathers.data.ListCollection;
	import feathers.layout.VerticalLayout;
	
	import starling.display.Button;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.text.TextField;
	import starling.utils.HAlign;
	import starling.utils.VAlign;
	import starling.utils.deg2rad;
	
	/**
	 * Basket confiration popup.
	 */
	public class CartPopup extends Sprite
	{

	// ---------- Starter properties
		
		/**
		 * The popup background. */
		private var _background:Image;
		/**
		 * The popup title. */
		private var _title:TextField;
		/**
		 * The items list title. */
		private var _itemsTitleLabel:TextField;
		/**
		 * List of items in the basket. */
		private var _itemsList:List;
		/**
		 * The list shadow. */
		private var _listTopShadow:Image;
		/**
		 * The list shadow. */
		private var _listBottomShadow:Image;
		/**
		 * The close button. */
		private var _closeButton:Button;
		/**
		 * The validation button. */
		private var _validateButton:MobileButton;

	// ---------- Second part

		// purchase total
		
		private var _purchaseTotalTitleLabel:TextField;
		private var _purchaseTotalValueLabel:TextField;
		private var _purchaseTotalPointsIcon:Image;
		
		// current points
		
		private var _currentPointsTitleLabel:TextField;
		private var _currentPointsValueLabel:TextField;
		private var _currentPointsIcon:Image;
		
		// remaining point
		
		private var _remainingCookiesTitleLabel:TextField;
		private var _remainingCookiesValueLabel:TextField;
		private var _remainingPointsIcon:Image;
		
		public function CartPopup()
		{
			super();
			
			_background = new Image(AvatarMakerAssets.cartConfirmationPopupBackgroundTexture);
			addChild(_background);

			_title = new TextField(430, 50, _("RECAPITULATIF"), Theme.FONT_OSWALD, 40, 0xffffff);
			_title.x = 120;
			_title.y = 18;
			_title.autoScale = true;
			_title.batchable = true;
			addChild(_title);
			
			// first part
			
			_itemsTitleLabel = new TextField(354, 30, _("Votre liste d'achats"), Theme.FONT_OSWALD, 28, 0x676462);
			_itemsTitleLabel.x = 9;
			_itemsTitleLabel.y = 76;
			_itemsTitleLabel.autoScale = true;
			_itemsTitleLabel.batchable = true;
			//_itemsTitleLabel.border = true;
			addChild(_itemsTitleLabel);

			const layout:VerticalLayout = new VerticalLayout();
			layout.verticalAlign = VerticalLayout.VERTICAL_ALIGN_TOP;
			layout.horizontalAlign = VerticalLayout.HORIZONTAL_ALIGN_JUSTIFY;

			_itemsList = new List();
			_itemsList.isSelectable = false;
			_itemsList.layout = layout;
			_itemsList.itemRendererType = CartItemRenderer;
			_itemsList.dataProvider = new ListCollection(CartManager.getInstance().generateDataProvider());
			_itemsList.verticalScrollPolicy = Scroller.SCROLL_POLICY_ON;
			_itemsList.horizontalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			//_itemsList.customVerticalScrollBarStyleName = Theme.SCROLL_BAR_CART_STYLE_NAME;
			_itemsList.x = 9;
			_itemsList.y = 105;
			_itemsList.width = 354;
			_itemsList.height = 236;
			addChild(_itemsList);
			_itemsList.addEventListener(Event.SCROLL, onScroll);
			_itemsList.addEventListener(LKAvatarMakerEventTypes.ITEM_SELECTED_OR_DESELECTED, onBasketItemSelectedOrDeselected);

			_listTopShadow = new Image(AvatarMakerAssets.listShadow);
			_listTopShadow.touchable = false;
			_listTopShadow.x = _itemsList.x;
			_listTopShadow.y = _itemsList.y;
			addChild(_listTopShadow);

			_listBottomShadow = new Image(AvatarMakerAssets.listShadow);
			_listBottomShadow.touchable = false;
			_listBottomShadow.alignPivot(HAlign.RIGHT, VAlign.BOTTOM);
			_listBottomShadow.rotation = deg2rad(180);
			_listBottomShadow.x = _itemsList.x;
			_listBottomShadow.y = _itemsList.y + _itemsList.height - _listBottomShadow.height;
			addChild(_listBottomShadow);

			_itemsList.validate();
			_listTopShadow.width = _listBottomShadow.width = _itemsList.width + (_itemsList.viewPort.height <= _itemsList.height ? 0 : -16);
			
			// second part
			
			// total
			_purchaseTotalTitleLabel = new TextField(200, 40, _("Total du panier :"), Theme.FONT_OSWALD, 28, 0xff6600);
			_purchaseTotalTitleLabel.touchable = false;
			_purchaseTotalTitleLabel.batchable = true;
			//_purchaseTotalTitleLabel.border = true;
			_purchaseTotalTitleLabel.hAlign = HAlign.LEFT;
			_purchaseTotalTitleLabel.x = 385;
			_purchaseTotalTitleLabel.y = 127;
			addChild(_purchaseTotalTitleLabel);
			
			_purchaseTotalValueLabel = new TextField(90, 40, Utilities.splitThousands(9999999), Theme.FONT_OSWALD, 26, 0xff6600);
			_purchaseTotalValueLabel.touchable = false;
			_purchaseTotalValueLabel.batchable = true;
			//_purchaseTotalValueLabel.border = true;
			_purchaseTotalValueLabel.hAlign = HAlign.RIGHT;
			_purchaseTotalValueLabel.x = 515;
			_purchaseTotalValueLabel.y = 127;
			addChild(_purchaseTotalValueLabel);
			
			_purchaseTotalPointsIcon = new Image(AvatarMakerAssets.cartPointBigIconTexture);
			_purchaseTotalPointsIcon.x = _purchaseTotalValueLabel.x + _purchaseTotalValueLabel.width + 5;
			_purchaseTotalPointsIcon.y = _purchaseTotalValueLabel.y + 8;
			addChild(_purchaseTotalPointsIcon);
			
			// current
			_currentPointsTitleLabel = new TextField(200, 41, _("Vos Points"), Theme.FONT_OSWALD, 16, 0x676462);
			_currentPointsTitleLabel.touchable = false;
			_currentPointsTitleLabel.batchable = true;
			//_currentPointsTitleLabel.border = true;
			_currentPointsTitleLabel.hAlign = HAlign.LEFT;
			_currentPointsTitleLabel.x = 385;
			_currentPointsTitleLabel.y = 180;
			addChild(_currentPointsTitleLabel);
			
			_currentPointsValueLabel = new TextField(90, 41, Utilities.splitThousands(9999999), Theme.FONT_OSWALD, 16, 0x676462);
			_currentPointsValueLabel.touchable = false;
			_currentPointsValueLabel.batchable = true;
			//_currentPointsValueLabel.border = true;
			_currentPointsValueLabel.hAlign = HAlign.RIGHT;
			_currentPointsValueLabel.x = 515;
			_currentPointsValueLabel.y = 180;
			addChild(_currentPointsValueLabel);

			_currentPointsIcon = new Image(AvatarMakerAssets.cartPointBigIconTexture);
			_currentPointsIcon.scaleX = _currentPointsIcon.scaleY = 0.8;
			_currentPointsIcon.x = _currentPointsValueLabel.x + _currentPointsValueLabel.width + 8;
			_currentPointsIcon.y = _currentPointsValueLabel.y + 10;
			addChild(_currentPointsIcon);
			
			// remaining
			_remainingCookiesTitleLabel = new TextField(300, 41, _("Points restants"), Theme.FONT_OSWALD, 16, 0x676462);
			_remainingCookiesTitleLabel.touchable = false;
			_remainingCookiesTitleLabel.batchable = true;
			_remainingCookiesTitleLabel.hAlign = HAlign.LEFT;
			_remainingCookiesTitleLabel.x = 385;
			_remainingCookiesTitleLabel.y = 228;
			addChild(_remainingCookiesTitleLabel);

			_remainingCookiesValueLabel = new TextField(90, 41, Utilities.splitThousands(-99999999), Theme.FONT_OSWALD, 16, 0x676462);
			_remainingCookiesValueLabel.touchable = false;
			_remainingCookiesValueLabel.batchable = true;
			_remainingCookiesValueLabel.hAlign = HAlign.RIGHT;
			_remainingCookiesValueLabel.x = 515;
			_remainingCookiesValueLabel.y = 228;
			addChild(_remainingCookiesValueLabel);

			_remainingPointsIcon = new Image(AvatarMakerAssets.cartPointBigIconTexture);
			_remainingPointsIcon.scaleX = _remainingPointsIcon.scaleY = 0.8;
			_remainingPointsIcon.x = _remainingCookiesValueLabel.x + _remainingCookiesValueLabel.width + 8;
			_remainingPointsIcon.y = _remainingCookiesValueLabel.y + 10;
			addChild(_remainingPointsIcon);
			
			// buttons
			
			_closeButton = new Button(AvatarMakerAssets.closeButton);
			_closeButton.addEventListener(Event.TRIGGERED, onClose);
			_closeButton.x = _background.width - _closeButton.width - 16;
			_closeButton.y = 34;
			_closeButton.scaleWhenDown = 0.9;
			addChild(_closeButton);
			
			_validateButton = ButtonFactory.getButton(_("VALIDER"), ButtonFactory.GREEN);
			_validateButton.addEventListener(Event.TRIGGERED, onValidate);
			_validateButton.x = 415;
			_validateButton.y = 291;
			addChild(_validateButton);
		}

//------------------------------------------------------------------------------------------------------------
//	Handlers

		/**
		 * Updates the basket.
		 * 
		 * This is called by the AvatarMakerScreen when an item is selected.
		 */
		public function updateBasket():void
		{
			// TODO remove all ?
			_itemsList.dataProvider = new ListCollection();
			_itemsList.dataProvider = new ListCollection(CartManager.getInstance().generateDataProvider());
			_itemsList.validate();
			
			_listTopShadow.width = _listBottomShadow.width = _itemsList.width + (_itemsList.viewPort.height <= _itemsList.height ? 0 : -16);
			
			_validateButton.enabled = CartManager.getInstance().hasCheckedItem();
			
			calculateBill();
		}
		
		/**
		 * Calculates the bill.
		 */
		private function calculateBill():void
		{
			_purchaseTotalValueLabel.text = Utilities.splitThousands(CartManager.getInstance().getTotal());
			_currentPointsValueLabel.text = Utilities.splitThousands(MemberManager.getInstance().points);
			_remainingCookiesValueLabel.text = Utilities.splitThousands(MemberManager.getInstance().points - CartManager.getInstance().getTotal());
			_remainingCookiesValueLabel.color = ((MemberManager.getInstance().points - CartManager.getInstance().getTotal()) < 0) ? 0xff0000 : 0x676462;
		}
		
		/**
		 * Whithin the list, the items can be selected / deselected for puchase.
		 * 
		 * When it happens, we need to update the bill accordingly.
		 */
		private function onBasketItemSelectedOrDeselected(event:Event):void
		{
			calculateBill();
			_validateButton.enabled = CartManager.getInstance().hasCheckedItem();
			
			CartManager.getInstance().updateTemporaryConfigurationAfterItemSelectedOrSDeselected(CartData(event.data));
			
			dispatchEventWith(LKAvatarMakerEventTypes.ITEM_SELECTED_OR_DESELECTED, false, CartData(event.data));
		}
		
//------------------------------------------------------------------------------------------------------------
//	Purchase flow
		
		/**
		 * When the validate button have been triggered.
		 */
		private function onValidate(event:Event):void
		{
			log("[BasketConfirmationPopup] Purchasing items...");
			
			if((MemberManager.getInstance().points - CartManager.getInstance().getTotal()) < 0)
			{
				// the user does not have enought points, we let him click the button but we display an information popup
				dispatchEventWith(LKAvatarMakerEventTypes.CLOSE_BASKET_POPUP, false, LKAvatarMakerEventTypes.CONFIRM_NOT_ENOUGH_COOKIES);
			}
			else
			{
				// the user have enough points, we make a request on the server side
				log("[CartPopup] User have enough points, purchasing items...");
				InfoManager.show(_("Traitement de votre demande en cours...\nVeuillez patienter quelques instants."));
				
				CartManager.getInstance().resetConfigForLockedItems();
				
				AvatarManager.getInstance().addEventListener(LKAvatarMakerEventTypes.AVATAR_IMAGE_CREATED, onImageCreated);
				AvatarManager.getInstance().getPng(LKConfigManager.currentGenderId, true);
			}
		}
		
		private function onImageCreated(event:Event):void
		{
			AvatarManager.getInstance().removeEventListener(LKAvatarMakerEventTypes.AVATAR_IMAGE_CREATED, onImageCreated);
			Remote.getInstance().saveAvatar(String(event.data), onAvatarSaved, onAvatarSaveFail, onAvatarSaveFail, 1, AbstractEntryPoint.screenNavigator.activeScreenID);
		}
		
		/**
		 * The current configuration was successfully saved and the items purchased.
		 */
		private function onAvatarSaved(result:Object):void
		{
			CartManager.getInstance().bringBackConfigForLockedItem();
			
			if(result.code == 1)
			{
				// then parse the configuration (it will validate what have been bought)
				LKConfigManager.parseData(result["avatarConfiguration"]);
				// hide the loader
				InfoManager.hide(_("Votre personnage a bien été sauvegardé !"), InfoContent.ICON_CHECK);
				
				dispatchEventWith(LKAvatarMakerEventTypes.CLOSE_BASKET_POPUP, false, true);
			}
			else
			{
				InfoManager.hide(_("Une erreur est survenue lors de l'enregistrement de votre avatar.\n\n Merci de réessayer."), InfoContent.ICON_CROSS);
			}
		}
		
		private function onAvatarSaveFail(error:Object):void
		{
			// TODO afficher une popup
			InfoManager.hide(_("Une erreur est survenue lors de l'enregistrement de votre avatar.\n\n Merci de réessayer."), InfoContent.ICON_CROSS);
		}
		
//------------------------------------------------------------------------------------------------------------
//

		/**
		 * When we scroll on the list, we need to update the visibility of the list shadows
		 * according to the number of items displayed (so if we can scroll up/down or not).
		 */
		private function onScroll(event:Event):void
		{
			TweenMax.to(_listTopShadow, 0.15, { autoAlpha:(_itemsList.verticalScrollPosition > 0 ? 1 : 0) });
			TweenMax.to(_listBottomShadow, 0.15, { autoAlpha:((_itemsList.height < _itemsList.viewPort.height && _itemsList.verticalScrollPosition < (_itemsList.viewPort.height - _itemsList.height)) ? 1 : 0) });
		}
		
		private function onClose(event:Event):void
		{
			dispatchEventWith(LKAvatarMakerEventTypes.CLOSE_BASKET_POPUP, false, false);
		}

//------------------------------------------------------------------------------------------------------------
//	Dispose
		
		override public function dispose():void
		{
			_background.removeFromParent(true);
			_background = null;
			
			_title.removeFromParent(true);
			_title = null;
			
			_itemsTitleLabel.removeFromParent(true);
			_itemsTitleLabel = null;
			
			_itemsList.removeEventListener(LKAvatarMakerEventTypes.ITEM_SELECTED_OR_DESELECTED, onBasketItemSelectedOrDeselected);
			_itemsList.removeEventListener(Event.SCROLL, onScroll);
			_itemsList.removeFromParent(true);
			_itemsList = null;
			
			_listTopShadow.removeFromParent(true);
			_listTopShadow = null;
			
			_listBottomShadow.removeFromParent(true);
			_listBottomShadow = null;
			
			_purchaseTotalTitleLabel.removeFromParent(true);
			_purchaseTotalTitleLabel = null;
			
			_purchaseTotalValueLabel.removeFromParent(true);
			_purchaseTotalValueLabel = null;
			
			_purchaseTotalPointsIcon.removeFromParent(true);
			_purchaseTotalPointsIcon = null;
			
			_currentPointsTitleLabel.removeFromParent(true);
			_currentPointsTitleLabel = null;
			
			_currentPointsValueLabel.removeFromParent(true);
			_currentPointsValueLabel = null;
			
			_currentPointsIcon.removeFromParent(true);
			_currentPointsIcon = null;
			
			_remainingCookiesTitleLabel.removeFromParent(true);
			_remainingCookiesTitleLabel = null;
			
			_remainingCookiesValueLabel.removeFromParent(true);
			_remainingCookiesValueLabel = null;
			
			_remainingPointsIcon.removeFromParent(true);
			_remainingPointsIcon = null;
			
			_closeButton.removeEventListener(Event.TRIGGERED, onClose);
			_closeButton.removeFromParent(true);
			_closeButton = null;
			
			_validateButton.removeEventListener(Event.TRIGGERED, onValidate);
			_validateButton.removeFromParent(true);
			_validateButton = null;
			
			super.dispose();
		}

		
	}
}