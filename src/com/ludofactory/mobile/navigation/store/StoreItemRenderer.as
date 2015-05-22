/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 25 oct. 2013
*/
package com.ludofactory.mobile.navigation.store
{
	
	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.common.gettext.aliases._n;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.AbstractGameInfo;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.controls.AbstractListItemRenderer;
	import com.ludofactory.mobile.core.events.LudoEventType;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import feathers.controls.Button;
	import feathers.controls.Label;
	import feathers.display.Scale3Image;
	import feathers.display.Scale9Image;
	import feathers.skins.IStyleProvider;
	
	import flash.filters.DropShadowFilter;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import starling.display.Image;
	import starling.utils.formatString;
	
	/**
	 * Item renderer used in the store screen to display
	 * the offers.
	 */	
	public class StoreItemRenderer extends AbstractListItemRenderer
	{
		/**
		 * How many credits the user will get. */		
		private var _gainLabel:Label;
		
		/**
		 * Promo label (if there is one). */		
		private var _promoLabel:Label;
		
		/**
		 * The credits icon. */		
		private var _icon:Image;
		
		/**
		 * The price button. */		
		private var _priceButton:Button;
		
		/**
		 * The text displayed above the special offer image.
		 */		
		private var _specialOfferLabel:Label;
		
		public function StoreItemRenderer()
		{
			super();
			isQuickHitAreaEnabled = true;
		}
		
		override protected function initialize():void
		{
			_paddingLeft = scaleAndRoundToDpi(18);
			_paddingRight = scaleAndRoundToDpi(18);
			_paddingBottom = scaleAndRoundToDpi(20);
			_headerHeight = scaleAndRoundToDpi(54);
			
			_backgroundSkin = new Scale9Image(Theme.storeBackgroundSkinTextures, GlobalConfig.dpiScale);
			addChild( _backgroundSkin );
			
			_gainLabel = new Label();
			addChild(_gainLabel);
			_gainLabel.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(40), Theme.COLOR_WHITE, false, false, null, null, null, TextFormatAlign.CENTER);
			_gainLabel.textRendererProperties.nativeFilters = [ new DropShadowFilter(0, 75, 0x000000, 0.75, 5, 5) ];
			_gainLabel.textRendererProperties.wordWrap = false;
			
			_promoLabel = new Label();
			addChild(_promoLabel);
			_promoLabel.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(24), 0xC33028, false, false, null, null, null, TextFormatAlign.CENTER);
			_promoLabel.textRendererProperties.wordWrap = false;
			
			_priceButton = new Button();
			_priceButton.styleName = Theme.BUTTON_GREEN;
			addChild(_priceButton);
			
			_topOfferImage =  new Scale3Image(Theme.storeTopOfferTexture, GlobalConfig.dpiScale);
			addChild(_topOfferImage);
			_topOfferImage.visible = false;
			
			_playersChoiceImage = new Scale3Image(Theme.storePlayersChoiceTexture, GlobalConfig.dpiScale);
			addChild(_playersChoiceImage);
			_playersChoiceImage.visible = false;
			
			_specialOfferLabel = new Label();
			_specialOfferLabel.visible = false;
			addChild(_specialOfferLabel);
			_specialOfferLabel.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(26), Theme.COLOR_WHITE, false, false, null, null, null, TextFormatAlign.CENTER);
			_specialOfferLabel.textRendererProperties.wordWrap = false;
		}
		
		override protected function commitData():void
		{
			if(this._owner)
			{
				if(this._data)
				{
					_gainLabel.text = formatString(_("{0} crédits"), _data.gain);
					_promoLabel.text = _data.promo > 0 ? formatString(_n("+{0} crédit offert", "+{0} crédits offerts", _data.promo), _data.promo) : "";
					
					if( !_icon )
					{
						_icon = new Image( AbstractEntryPoint.assets.getTexture("offer" + _data.id) );
						_icon.scaleX = _icon.scaleY = GlobalConfig.dpiScale;
						addChildAt(_icon, getChildIndex(_priceButton));
					}
					
					_priceButton.label = _data.localizedPrice;
					
					_topOfferImage.visible = _data.isTopOffer;
					_playersChoiceImage.visible = _data.isPlayersChoice;
					
					if( _data.isTopOffer )
						_specialOfferLabel.text = _("Top\nOFFRE");
					else if( _data.isPlayersChoice )
						_specialOfferLabel.text = _("Choix\nJOUEUR");
					_specialOfferLabel.visible = _data.isPlayersChoice || _data.isTopOffer;
				}
			}
		}
		
		override protected function layout():void
		{
			width = owner.width / ( GlobalConfig.isPhone ? (AbstractGameInfo.LANDSCAPE ? 3 : 2) : 3);
			height = scaleAndRoundToDpi(270);
			
			_backgroundSkin.width = actualWidth - _paddingLeft - _paddingRight;
			_backgroundSkin.height = actualHeight - _paddingBottom;
			_backgroundSkin.x = _paddingLeft;
			
			_gainLabel.width = actualWidth;
			_gainLabel.validate();
			_gainLabel.y = (Math.max(_headerHeight, _gainLabel.height) - Math.min(_headerHeight, _gainLabel.height)) * 0.5;
			
			_promoLabel.width = actualWidth;
			_promoLabel.validate();
			_promoLabel.y = actualHeight - _paddingBottom - _promoLabel.height - scaleAndRoundToDpi(10);
			
			_icon.y = _headerHeight + scaleAndRoundToDpi(10);
			_icon.x = (actualWidth - _icon.width) * 0.5;
			
			if( _specialOfferLabel.visible )
			{
				_specialOfferLabel.validate();
				_specialOfferLabel.y = _headerHeight + scaleAndRoundToDpi(5);
				_specialOfferLabel.x = actualWidth - _specialOfferLabel.width - scaleAndRoundToDpi(10);
				
				if( _data.isTopOffer )
				{
					_topOfferImage.y = _specialOfferLabel.y - scaleAndRoundToDpi(5);
					_topOfferImage.width = _specialOfferLabel.width + scaleAndRoundToDpi(30);
					_topOfferImage.x = actualWidth - _topOfferImage.width; 
				}
				else
				{
					_playersChoiceImage.y = _specialOfferLabel.y - scaleAndRoundToDpi(5);
					_playersChoiceImage.width = _specialOfferLabel.width + scaleAndRoundToDpi(36);
					_playersChoiceImage.x = actualWidth - _playersChoiceImage.width; 
				}
			}
			
			_priceButton.width = actualWidth * 0.8;
			_priceButton.height = scaleAndRoundToDpi(76);
			_priceButton.x = (actualWidth - _priceButton.width) * 0.5;
			_priceButton.y = _icon.y + _icon.height + ((_promoLabel.y - _icon.y - _icon.height) - _priceButton.height) * 0.5;
		}
		
		protected var _data:StoreData;
		
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
			this._data = StoreData(value);
			this.invalidate(INVALIDATION_FLAG_DATA);
		}
		
		/**
		 * Item renderer have been touched.
		 */		
		override protected function onTouched():void
		{
			owner.dispatchEventWith(LudoEventType.PURCHASE_ITEM, false, _data);
		}
		
//------------------------------------------------------------------------------------------------------------
//	GET / SET
//------------------------------------------------------------------------------------------------------------
		
		/**
		 * The main background skin.
		 */		
		private var _backgroundSkin:Scale9Image;
		
		public function set backgroundSkin(val:Scale9Image):void
		{
			_backgroundSkin = val;
		}
		
		/**
		 * The "Top Offer" image.
		 */		
		private var _topOfferImage:Scale3Image;
		
		public function set topOfferTexture(val:Scale3Image):void
		{
			_topOfferImage = val;
		}
		
		/**
		 * The "Players Choice" image.
		 */		
		private var _playersChoiceImage:Scale3Image;
		
		public function set playersChoiceTexture(val:Scale3Image):void
		{
			_playersChoiceImage = val;
		}
		
		/**
		 * Padding left.
		 */		
		private var _paddingLeft:int;
		
		public function set paddingLeft(val:int):void
		{
			_paddingLeft = val;
		}
		
		/**
		 * Padding right
		 */		
		private var _paddingRight:int;
		
		public function set paddingRight(val:int):void
		{
			_paddingRight = val;
		}
		
		/**
		 * Padding bottom.
		 */		
		private var _paddingBottom:int;
		
		public function set paddingBottom(val:int):void
		{
			_paddingBottom = val;
		}
		
		/**
		 * Height of the header in the main background.
		 */		
		private var _headerHeight:int;
		
		public function set headerHeight(val:int):void
		{
			_headerHeight = val;
		}
		
		/**
		 * Required for the new Theme. */
		public static var globalStyleProvider:IStyleProvider;
		override protected function get defaultStyleProvider():IStyleProvider
		{
			return StoreItemRenderer.globalStyleProvider;
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
//------------------------------------------------------------------------------------------------------------
		
		override public function dispose():void
		{
			_backgroundSkin.removeFromParent(true);
			_backgroundSkin = null;
			
			_gainLabel.removeFromParent(true);
			_gainLabel = null;
			
			_promoLabel.removeFromParent(true);
			_promoLabel = null;
			
			_icon.removeFromParent(true);
			_icon = null;
			
			_priceButton.removeFromParent(true);
			_priceButton = null;
			
			_topOfferImage.removeFromParent(true);
			_topOfferImage = null;
			
			_playersChoiceImage.removeFromParent(true);
			_playersChoiceImage = null;
			
			_specialOfferLabel.removeFromParent(true);
			_specialOfferLabel = null;
			
			_data = null;
			
			super.dispose();
		}
	}
}