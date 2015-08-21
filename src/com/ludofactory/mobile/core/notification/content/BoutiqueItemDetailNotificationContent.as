/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 28 août 2013
*/
package com.ludofactory.mobile.core.notification.content
{
	
	import com.freshplanet.nativeExtensions.AirNetworkInfo;
	import com.greensock.TweenMax;
	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.common.utils.Utilities;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.manager.InfoContent;
	import com.ludofactory.mobile.core.manager.InfoManager;
	import com.ludofactory.mobile.core.manager.MemberManager;
	import com.ludofactory.mobile.core.notification.content.AbstractPopupContent;
	import com.ludofactory.mobile.core.notification.NotificationPopupManager;
	import com.ludofactory.mobile.core.remoting.Remote;
	import com.ludofactory.mobile.core.theme.Theme;
	import com.ludofactory.mobile.navigation.shop.vip.*;
	
	import feathers.controls.Button;
	import feathers.controls.ImageLoader;
	import feathers.controls.Label;
	import feathers.events.FeathersEventType;
	import feathers.layout.VerticalLayout;
	
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import starling.core.Starling;
	import starling.display.MovieClip;
	import starling.events.Event;
	
	public class BoutiqueItemDetailNotificationContent extends AbstractPopupContent
	{
		/**
		 * The gift image. */		
		private var _image:ImageLoader;
		
		/**
		 * The gift name. */		
		private var _giftPoints:Label;
		
		/**
		 * The gift name. */		
		private var _giftName:Label;
		
		/**
		 * The order button */		
		private var _orderButton:Button;
		
		/**
		 * The result message. */		
		private var _resultMessage:Label;
		
		/**
		 * The gift description. */		
		private var _giftDescription:Label;
		
		/**
		 * The item data */		
		private var _boutiqueItemData:BoutiqueItemData;
		
		/**
		 * If we need to resize the notification */		
		private var _needResize:Boolean = false;
		
		/**
		 * Loader used while the image is loading. */		
		private var _imageLoader:MovieClip;
		
		public function BoutiqueItemDetailNotificationContent(boutiqueItemData:BoutiqueItemData)
		{
			super();
			
			_boutiqueItemData = boutiqueItemData;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			const vlayout:VerticalLayout = new VerticalLayout();
			vlayout.horizontalAlign = VerticalLayout.HORIZONTAL_ALIGN_CENTER;
			vlayout.verticalAlign = VerticalLayout.VERTICAL_ALIGN_TOP;
			vlayout.gap = scaleAndRoundToDpi( GlobalConfig.isPhone ? 20:40 );
			this.layout = vlayout;
			
			_giftName = new Label();
			_giftName.text = Utilities.replaceCurrency(_boutiqueItemData.title);
			addChild(_giftName);
			_giftName.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(40), Theme.COLOR_DARK_GREY, false, false, null, null, null, TextFormatAlign.CENTER);
			
			_image = new ImageLoader();
			_image.addEventListener(Event.COMPLETE, onImageLoaded);
			_image.addEventListener(FeathersEventType.ERROR, onImageError);
			_image.source = _boutiqueItemData.imageUrl;
			addChild(_image);
			
			_imageLoader = new MovieClip( Theme.blackLoaderTextures );
			_imageLoader.scaleX = _imageLoader.scaleY = GlobalConfig.dpiScale;
			addChild(_imageLoader);
			Starling.juggler.add(_imageLoader);
			
			_giftPoints = new Label();
			_giftPoints.text = _boutiqueItemData.points;
			addChild(_giftPoints);
			_giftPoints.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(32), Theme.COLOR_DARK_GREY, false, false, null, null, null, TextFormatAlign.CENTER);
			
			_orderButton = new Button();
			_orderButton.label = _("Commander");
			_orderButton.addEventListener(Event.TRIGGERED, onOrder);
			addChild(_orderButton);
			
			_giftDescription = new Label();
			_giftDescription.text = Utilities.replaceCurrency(_boutiqueItemData.description);
			addChild(_giftDescription);
			_giftDescription.textRendererProperties.textFormat = new TextFormat(Theme.FONT_ARIAL, scaleAndRoundToDpi(26), Theme.COLOR_DARK_GREY, true, true);
			
		}
		
		override protected function draw():void
		{
			_giftDescription.width = _giftName.width = _giftPoints.width = this.actualWidth - scaleAndRoundToDpi( GlobalConfig.isPhone ? 40:60 );
			
			if( _orderButton )
				_orderButton.width = this.actualWidth * 0.8;
			
			if( _resultMessage )
				_resultMessage.width = this.actualWidth;
			
			if( _image.isLoaded )
			{
				_image.validate();
				if( _image.height > GlobalConfig.stageHeight * 0.4 )
					_image.height = GlobalConfig.stageHeight * 0.4;
					
				if( _image.width > this.actualWidth )
					_image.width = this.actualWidth;
			}
			
			super.draw();
			
			if( _needResize )
			{
				_needResize = false;
				NotificationPopupManager.adjustCurrentNotification();
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Handlers
//------------------------------------------------------------------------------------------------------------
		
		private function onOrder(event:Event):void
		{
			if( !MemberManager.getInstance().isLoggedIn() )
			{
				//NotificationManager.addNotification( new MarketingRegisterNotification(AbstractEntryPoint.screenNavigator.activeScreenID) );
				NotificationPopupManager.addNotification( new MarketingRegisterNotificationContent(AbstractEntryPoint.screenNavigator.activeScreenID) );
			}
			else
			{
				if( AirNetworkInfo.networkInfo.isConnected() )
				{
					this.touchable = false;
					InfoManager.show(_("Chargement..."));
					Remote.getInstance().order( this._boutiqueItemData.id, _boutiqueItemData.title, onOrderSuccess, onOrderFailure, onOrderFailure, 2, AbstractEntryPoint.screenNavigator.activeScreenID);
				}
				else
				{
					InfoManager.showTimed(_("Aucune connexion Internet."), InfoManager.DEFAULT_DISPLAY_TIME, InfoContent.ICON_CROSS);
				}
			}
			
		}
		
		private function onOrderSuccess(result:Object):void
		{
			this.touchable = true;
			
			switch(result.code)
			{
				case 0: // error
				{
					InfoManager.hide(result.txt, InfoContent.ICON_CROSS);
					break;
				}
				case 1: // success
				{
					InfoManager.hide("", InfoContent.ICON_NOTHING, 0);
					//NotificationManager.addNotification( new OrderCompleteNotification(true, result.txt_titre, result.txt_texte) );
					
					_orderButton.removeEventListener(Event.TRIGGERED, onOrder);
					_orderButton.removeFromParent(true);
					_orderButton = null;
					
					_giftDescription.removeFromParent();
					
					_resultMessage = new Label();
					_resultMessage.text = result.txt;
					addChild(_resultMessage);
					_resultMessage.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(32), Theme.COLOR_ORANGE, false, false, null, null, null, TextFormatAlign.CENTER);
					
					addChild(_giftDescription);
					
					_needResize = true;

					this.invalidate(INVALIDATION_FLAG_SIZE);
					invalidate(INVALIDATION_FLAG_SIZE); // necessary to layout the _resultMessage
					break;
				}
				default:
				{
					// just in case
					onOrderFailure();
					break;
				}
			}
		}
		
		private function onOrderFailure(error:Object = null):void
		{
			this.touchable = true;
			InfoManager.hide(_("Une erreur est survenue, veuillez réessayer."), InfoContent.ICON_CHECK, InfoManager.DEFAULT_DISPLAY_TIME);
		}
		
		/**
		 * When the image have correctly been loaded.
		 */		
		protected function onImageLoaded(event:Event):void
		{
			Starling.juggler.remove(_imageLoader);
			_imageLoader.removeFromParent(true);
			_imageLoader = null;
			
			_image.alpha = 0;
			TweenMax.to(_image, 0.75, {alpha:1});
			_needResize = true;
			this.invalidate(INVALIDATION_FLAG_SIZE);
			this.invalidate(INVALIDATION_FLAG_SIZE);
		}
		
		/**
		 * When the image could not be loaded.
		 */		
		protected function onImageError(event:Event):void
		{
			// FIXME Logguer l'erreur pour pouvoir corriger l'url si besoin.
			this.invalidate(INVALIDATION_FLAG_SIZE);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
//------------------------------------------------------------------------------------------------------------
		
		override public function dispose():void
		{
			_image.removeEventListener(Event.COMPLETE, onImageLoaded);
			_image.removeEventListener(FeathersEventType.ERROR, onImageError);
			_image.removeFromParent(true);
			_image = null;
			
			_giftName.removeFromParent(true);
			_giftName = null;
			
			_giftPoints.removeFromParent(true);
			_giftPoints = null;
			
			if( _orderButton )
			{
				_orderButton.removeEventListener(Event.TRIGGERED, onOrder);
				_orderButton.removeFromParent(true);
				_orderButton = null;
			}
			
			if( _resultMessage )
			{
				_resultMessage.removeFromParent(true);
				_resultMessage = null;
			}
			
			if( _imageLoader )
			{
				Starling.juggler.remove(_imageLoader);
				_imageLoader.removeFromParent(true);
				_imageLoader = null;
			}
			
			_giftDescription.removeFromParent(true);
			_giftDescription = null;
			
			_boutiqueItemData = null;
			
			super.dispose();
		}
	}
}