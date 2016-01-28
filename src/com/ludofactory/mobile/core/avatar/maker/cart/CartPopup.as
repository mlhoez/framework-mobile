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
	import com.ludofactory.common.utils.logs.log;
	import com.ludofactory.common.utils.roundUp;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.ButtonFactory;
	import com.ludofactory.mobile.MobileButton;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.avatar.AvatarMakerAssets;
	import com.ludofactory.mobile.core.avatar.test.events.LKAvatarMakerEventTypes;
	import com.ludofactory.mobile.core.avatar.test.manager.AvatarManager;
	import com.ludofactory.mobile.core.avatar.test.manager.LKConfigManager;
	import com.ludofactory.mobile.core.config.GlobalConfig;
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
			_background.scaleX = _background.scaleY = GlobalConfig.dpiScale;
			addChild(_background);

			_title = new TextField(_background.width, scaleAndRoundToDpi(50), _("RECAPITULATIF"), Theme.FONT_OSWALD, scaleAndRoundToDpi(40), 0xffffff);
			_title.y = scaleAndRoundToDpi(16);
			_title.autoScale = true;
			_title.batchable = true;
			//_title.border = true;
			addChild(_title);
			
			// first part
			
			_itemsTitleLabel = new TextField(scaleAndRoundToDpi(496), scaleAndRoundToDpi(50), _("Votre liste d'achats"), Theme.FONT_OSWALD, scaleAndRoundToDpi(40), 0x676462);
			_itemsTitleLabel.x = scaleAndRoundToDpi(9);
			_itemsTitleLabel.y = scaleAndRoundToDpi(76);
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
			_itemsList.x = _itemsTitleLabel.x;
			_itemsList.y = _itemsTitleLabel.y + _itemsTitleLabel.height;
			_itemsList.width = _itemsTitleLabel.width;
			_itemsList.height = scaleAndRoundToDpi(332);
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
			_listTopShadow.width = _listBottomShadow.width = _itemsTitleLabel.width; /*+ (_itemsList.viewPort.height <= _itemsList.height ? 0 : -16);*/
			
			// second part
			
			// total
			_purchaseTotalTitleLabel = new TextField(scaleAndRoundToDpi(200), scaleAndRoundToDpi(53), _("Total du panier :"), Theme.FONT_OSWALD, scaleAndRoundToDpi(28), 0xff6600);
			_purchaseTotalTitleLabel.touchable = false;
			_purchaseTotalTitleLabel.batchable = true;
			_purchaseTotalTitleLabel.autoScale = true;
			//_purchaseTotalTitleLabel.border = true;
			_purchaseTotalTitleLabel.hAlign = HAlign.LEFT;
			_purchaseTotalTitleLabel.x = _itemsList.x + _itemsList.width + scaleAndRoundToDpi(5);
			_purchaseTotalTitleLabel.y = _itemsList.y;
			addChild(_purchaseTotalTitleLabel);
			
			_purchaseTotalPointsIcon = new Image(AvatarMakerAssets.cartPointBigIconTexture);
			_purchaseTotalPointsIcon.scaleX = _purchaseTotalPointsIcon.scaleY = GlobalConfig.dpiScale;
			
			_purchaseTotalValueLabel = new TextField(scaleAndRoundToDpi(100), scaleAndRoundToDpi(53), Utilities.splitThousands(9999999), Theme.FONT_OSWALD, scaleAndRoundToDpi(26), 0xff6600);
			_purchaseTotalValueLabel.touchable = false;
			_purchaseTotalValueLabel.batchable = true;
			_purchaseTotalValueLabel.autoScale = true;
			//_purchaseTotalValueLabel.border = true;
			_purchaseTotalValueLabel.hAlign = HAlign.RIGHT;
			_purchaseTotalValueLabel.x = _background.width - _purchaseTotalValueLabel.width - _purchaseTotalPointsIcon.width - scaleAndRoundToDpi(5) - scaleAndRoundToDpi(15);
			_purchaseTotalValueLabel.y = _itemsList.y;
			addChild(_purchaseTotalValueLabel);
			
			_purchaseTotalPointsIcon.x = _purchaseTotalValueLabel.x + _purchaseTotalValueLabel.width + scaleAndRoundToDpi(5);
			_purchaseTotalPointsIcon.y = _purchaseTotalValueLabel.y + scaleAndRoundToDpi(8);
			addChild(_purchaseTotalPointsIcon);
			
			// current
			_currentPointsTitleLabel = new TextField(scaleAndRoundToDpi(200), scaleAndRoundToDpi(53), _("Vos Points"), Theme.FONT_OSWALD, scaleAndRoundToDpi(30), 0x676462);
			_currentPointsTitleLabel.touchable = false;
			_currentPointsTitleLabel.batchable = true;
			_currentPointsTitleLabel.autoScale = true;
			//_currentPointsTitleLabel.border = true;
			_currentPointsTitleLabel.hAlign = HAlign.LEFT;
			_currentPointsTitleLabel.x = _itemsList.x + _itemsList.width + scaleAndRoundToDpi(5);
			_currentPointsTitleLabel.y = scaleAndRoundToDpi(212);
			addChild(_currentPointsTitleLabel);
			
			_currentPointsIcon = new Image(AvatarMakerAssets.cartPointBigIconTexture);
			_currentPointsIcon.scaleX = _currentPointsIcon.scaleY = GlobalConfig.dpiScale //- (0.2 * GlobalConfig.dpiScale);
			
			_currentPointsValueLabel = new TextField(scaleAndRoundToDpi(100), scaleAndRoundToDpi(53), Utilities.splitThousands(9999999), Theme.FONT_OSWALD, scaleAndRoundToDpi(30), 0x676462);
			_currentPointsValueLabel.touchable = false;
			_currentPointsValueLabel.batchable = true;
			_currentPointsValueLabel.autoScale = true;
			//_currentPointsValueLabel.border = true;
			_currentPointsValueLabel.hAlign = HAlign.RIGHT;
			_currentPointsValueLabel.x = _background.width - _purchaseTotalValueLabel.width - _currentPointsIcon.width - scaleAndRoundToDpi(8) - scaleAndRoundToDpi(15);
			_currentPointsValueLabel.y = scaleAndRoundToDpi(212);
			addChild(_currentPointsValueLabel);

			_currentPointsIcon.x = _currentPointsValueLabel.x + _currentPointsValueLabel.width + scaleAndRoundToDpi(8);
			_currentPointsIcon.y = _currentPointsValueLabel.y + scaleAndRoundToDpi(10);
			addChild(_currentPointsIcon);
			
			// remaining
			_remainingCookiesTitleLabel = new TextField(scaleAndRoundToDpi(200), scaleAndRoundToDpi(53), _("Points restants"), Theme.FONT_OSWALD, scaleAndRoundToDpi(30), 0x676462);
			_remainingCookiesTitleLabel.touchable = false;
			_remainingCookiesTitleLabel.batchable = true;
			_remainingCookiesTitleLabel.autoScale = true;
			//_remainingCookiesTitleLabel.border = true;
			_remainingCookiesTitleLabel.hAlign = HAlign.LEFT;
			_remainingCookiesTitleLabel.x = _itemsList.x + _itemsList.width + scaleAndRoundToDpi(5);
			_remainingCookiesTitleLabel.y = scaleAndRoundToDpi(282);
			addChild(_remainingCookiesTitleLabel);

			_remainingPointsIcon = new Image(AvatarMakerAssets.cartPointBigIconTexture);
			_remainingPointsIcon.scaleX = _remainingPointsIcon.scaleY = GlobalConfig.dpiScale //- (0.2 * GlobalConfig.dpiScale);
			
			_remainingCookiesValueLabel = new TextField(scaleAndRoundToDpi(100), scaleAndRoundToDpi(53), Utilities.splitThousands(-99999999), Theme.FONT_OSWALD, scaleAndRoundToDpi(30), 0x676462);
			_remainingCookiesValueLabel.touchable = false;
			_remainingCookiesValueLabel.batchable = true;
			_remainingCookiesValueLabel.autoScale = true;
			//_remainingCookiesValueLabel.border = true;
			_remainingCookiesValueLabel.hAlign = HAlign.RIGHT;
			_remainingCookiesValueLabel.x = _background.width - _purchaseTotalValueLabel.width - _remainingPointsIcon.width - scaleAndRoundToDpi(8) - scaleAndRoundToDpi(15);
			_remainingCookiesValueLabel.y = scaleAndRoundToDpi(282);
			addChild(_remainingCookiesValueLabel);

			_remainingPointsIcon.x = _remainingCookiesValueLabel.x + _remainingCookiesValueLabel.width + scaleAndRoundToDpi(8);
			_remainingPointsIcon.y = _remainingCookiesValueLabel.y + scaleAndRoundToDpi(10);
			addChild(_remainingPointsIcon);
			
			// buttons
			
			_closeButton = new Button(AvatarMakerAssets.closeButton);
			_closeButton.scaleX = _closeButton.scaleY = GlobalConfig.dpiScale;
			_closeButton.addEventListener(Event.TRIGGERED, onClose);
			_closeButton.x = _background.width - _closeButton.width - scaleAndRoundToDpi(16);
			_closeButton.y = scaleAndRoundToDpi(34);
			_closeButton.scaleWhenDown = GlobalConfig.dpiScale - (0.1*GlobalConfig.dpiScale);
			addChild(_closeButton);
			
			_validateButton = ButtonFactory.getButton(_("VALIDER"), ButtonFactory.GREEN);
			_validateButton.addEventListener(Event.TRIGGERED, onValidate);
			_validateButton.x = roundUp(_itemsList.x + _itemsList.width + ((_background.width - _itemsList.x - _itemsList.width) - _validateButton.width) * 0.5);
			_validateButton.y = _remainingCookiesTitleLabel.y + _remainingCookiesTitleLabel.height + roundUp(((_background.height - _remainingCookiesTitleLabel.y - _remainingCookiesTitleLabel.height) - _validateButton.height) * 0.5);
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
			
			//_listTopShadow.width = _listBottomShadow.width = _itemsList.width + (_itemsList.viewPort.height <= _itemsList.height ? 0 : -16);
			
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
			
			// FIXME A remettre comme avant (sans le true ||)
			if(true || (MemberManager.getInstance().points - CartManager.getInstance().getTotal()) < 0)
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
			
			_closeButton.removeEventListener(Event.TRIGGERED, onClose);
			_closeButton.removeFromParent(true);
			_closeButton = null;
			
			_validateButton.removeEventListener(Event.TRIGGERED, onValidate);
			_validateButton.removeFromParent(true);
			_validateButton = null;
			
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
			
			super.dispose();
		}

		
	}
}