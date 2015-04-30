/*
Copyright © 2006-2015 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 28 août 2013
*/
package com.ludofactory.mobile.core.notification.content
{

	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.common.utils.Utilities;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.events.LudoEventType;
	import com.ludofactory.mobile.core.manager.InfoContent;
	import com.ludofactory.mobile.core.manager.InfoManager;
	import com.ludofactory.mobile.core.notification.AbstractNotificationPopupContent;
	import com.ludofactory.mobile.core.remoting.Remote;
	import com.ludofactory.mobile.navigation.shop.bid.pending.*;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.theme.Theme;

	import feathers.controls.Button;
	import feathers.controls.ImageLoader;
	import feathers.controls.Label;
	import feathers.controls.Scroller;
	import feathers.controls.TextInput;
	import feathers.events.FeathersEventType;
	import feathers.layout.VerticalLayout;

	import flash.text.ReturnKeyLabel;
	import flash.text.SoftKeyboardType;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	import starling.core.Starling;
	import starling.display.MovieClip;
	import starling.events.Event;
	import starling.utils.formatString;

	public class PendingBidDetailNotificationContent extends AbstractNotificationPopupContent
	{
		/**
		 * The title */		
		private var _notificationTitle:Label;
		
		/**
		 * The gift image. */		
		private var _image:ImageLoader;
		
		/**
		 * The gift name. */		
		private var _giftName:Label;
		
		/**
		 * The gift description. */		
		private var _giftDescription:Label;
		
		/**
		 * The gift description. */		
		private var _infoMessage:Label;
		
		/**
		 * Message displayed when the user is the actual winner, if the
		 * bid is finished or if he is not logged in. */		
		private var _message:Label;
		
		/**
		 * Bid input. */		
		private var _bidInput:TextInput;
		
		/**
		 * Validate button. */		
		private var _validateButton:Button;
		
		/**
		 * Pending bid item data. */		
		private var _pendingBidItemData:PendingBidItemData;
		
		/**
		 * If we need to resize the notification */		
		private var _needResize:Boolean = false;
		
		/**
		 * Loader used while the image is loading. */		
		private var _imageLoader:MovieClip;
		
		public function PendingBidDetailNotificationContent(pendingBidItemData:PendingBidItemData)
		{
			super();
			
			_pendingBidItemData = pendingBidItemData;
			isRefreshable = true;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			const vlayout:VerticalLayout = new VerticalLayout();
			vlayout.horizontalAlign = VerticalLayout.HORIZONTAL_ALIGN_CENTER;
			vlayout.verticalAlign = VerticalLayout.VERTICAL_ALIGN_TOP;
			vlayout.gap = scaleAndRoundToDpi(GlobalConfig.isPhone ? 20:40);
			
			this.layout = vlayout;
			//this.isRefreshable = true;
			this.verticalScrollPolicy = Scroller.SCROLL_POLICY_ON;
			this.horizontalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			this.addEventListener(LudoEventType.REFRESH_TOP, onRefreshPendingBid);
			
			_notificationTitle = new Label();
			_notificationTitle.text = _("Enchère");
			addChild(_notificationTitle);
			_notificationTitle.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(40), Theme.COLOR_DARK_GREY, false, false, null, null, null, TextFormatAlign.CENTER);
			
			_image = new ImageLoader();
			_image.addEventListener(Event.COMPLETE, onImageLoaded);
			_image.addEventListener(FeathersEventType.ERROR, onImageError);
			_image.source = _pendingBidItemData.imageUrl;
			addChild(_image);
			
			_imageLoader = new MovieClip( Theme.blackLoaderTextures );
			_imageLoader.scaleX = _imageLoader.scaleY = GlobalConfig.dpiScale;
			addChild(_imageLoader);
			Starling.juggler.add(_imageLoader);
			
			_giftName = new Label();
			_giftName.text = Utilities.replaceCurrency(_pendingBidItemData.name);
			addChild(_giftName);
			_giftName.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(32), Theme.COLOR_DARK_GREY, false, false, null, null, null, TextFormatAlign.CENTER) ;
			
			_infoMessage = new Label();
			_infoMessage.text = _("Information : vos Points seront débités uniquement si vous remportez l'enchère.");
			addChild(_infoMessage);
			_infoMessage.textRendererProperties.textFormat = new TextFormat(Theme.FONT_ARIAL, scaleAndRoundToDpi(26), Theme.COLOR_DARK_GREY, true, true);
			
			if( _pendingBidItemData.lastBidder != null && _pendingBidItemData.lastBidder != "" )
				_infoMessage.text += "\n\n" + _pendingBidItemData.lastBidder;
			
			_message = new Label();
			addChild(_message);
			_message.textRendererProperties.textFormat = new TextFormat(Theme.FONT_ARIAL, scaleAndRoundToDpi(32), Theme.COLOR_LIGHT_GREY, true, false, null, null, null, TextFormatAlign.CENTER);
			
			switch(_pendingBidItemData.state)
			{
				case PendingBidItemData.STATE_NOT_CONNECTED: { _message.text = _("Vous devez être identifié pour pouvoir enchérir."); break; }
				case PendingBidItemData.STATE_ACTUAL_WINNER: { _message.text = _("Bravo !\n\nVous êtes provisoirement le gagnant de cette enchère !");         break; }
				case PendingBidItemData.STATE_FINISHED:      { _message.text = _("Cette enchère est terminée.");          break; }
			}
			
			_bidInput = new TextInput();
			_bidInput.prompt = formatString( _("Enchère minimum : {0}."), _pendingBidItemData.minimumBid );
			_bidInput.textEditorProperties.softKeyboardType = SoftKeyboardType.NUMBER;
			_bidInput.textEditorProperties.returnKeyLabel = ReturnKeyLabel.DONE;
			_bidInput.textEditorProperties.restrict = "0-9";
			_bidInput.addEventListener(FeathersEventType.ENTER, onValidate);
			addChild(_bidInput);
			
			_validateButton = new Button();
			_validateButton.addEventListener(Event.TRIGGERED, onValidate);
			_validateButton.label = _("Enchérir");
			addChild(_validateButton);
			
			if( _pendingBidItemData.state == PendingBidItemData.STATE_NOT_CONNECTED ||
				_pendingBidItemData.state == PendingBidItemData.STATE_ACTUAL_WINNER ||
				_pendingBidItemData.state == PendingBidItemData.STATE_FINISHED )
			{
				removeChild(_bidInput);
				removeChild(_validateButton);
				removeChild(_infoMessage);
			}
			else
			{
				removeChild(_message);
			}
			
			_giftDescription = new Label();
			_giftDescription.text = _pendingBidItemData.description;
			addChild(_giftDescription);
			_giftDescription.textRendererProperties.textFormat = new TextFormat(Theme.FONT_ARIAL, scaleAndRoundToDpi(26), Theme.COLOR_DARK_GREY, true, true);
			
		}
		
		override protected function draw():void
		{
			if( _image.isLoaded )
			{
				_image.validate();
				if( _image.height > GlobalConfig.stageHeight * 0.4 )
					_image.height = GlobalConfig.stageHeight * 0.4;
				
				if( _image.width > this.actualWidth )
					_image.width = this.actualWidth;
			}
			
			_notificationTitle.width = this.actualWidth;
			
			if( _infoMessage )
				_infoMessage.width = this.actualWidth;
			
			if( _message )
				_message.width = this.actualWidth;
			
			if( _bidInput )
				_bidInput.width = this.actualWidth;
			
			if( _validateButton)
				_validateButton.width = this.actualWidth * 0.8;
			
			_giftDescription.width = _giftName.width = this.actualWidth;
			
			super.draw();
			
			if( _needResize )
			{
				_needResize = false;
				//NotificationManager.replaceNotification(); // FIXME A remettre ?
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Handlers
//------------------------------------------------------------------------------------------------------------
		
		private function onValidate(event:Event):void
		{
			if( !Utilities.isNumberOnly( _bidInput.text ) )
			{
				InfoManager.showTimed( _("La valeur de l'enchère ne peut être qu'un chiffre."), InfoManager.DEFAULT_DISPLAY_TIME, InfoContent.ICON_CROSS );
				return;
			}
			
			if( int(_bidInput.text) < _pendingBidItemData.minimumBid )
			{
				InfoManager.showTimed( formatString(_("Votre enchère doit être supérieure à l'enchère minimum de {0}."), _pendingBidItemData.minimumBid), InfoManager.DEFAULT_DISPLAY_TIME, InfoContent.ICON_CROSS );
				return;
			}
			
			// validate
			this.isEnabled = false;
			InfoManager.show( _("Chargement...") );
			Remote.getInstance().bid(_pendingBidItemData.id, int(_bidInput.text), _pendingBidItemData.minimumBid, onBidSuccess, onBidFailure, onBidFailure, 2, AbstractEntryPoint.screenNavigator.activeScreenID);
		}
		
		/**
		 * The user made a bid successfully.
		 */		
		private function onBidSuccess(result:Object):void
		{
			switch(result.code)
			{
				case 0: // issue
				{
					this.isEnabled = true;
					InfoManager.hide(result.txt, InfoContent.ICON_CROSS, 8);
					break;
				}
				case 1: // success
				{
					_bidInput.text = "";
					data = true;
					InfoManager.hide(result.txt, InfoContent.ICON_CHECK, 8, onRefreshBidSuccess, [result.enchere]);
					break;
				}
					
				default:
				{
					onBidFailure();
					break;
				}
			}
		}
		
		/**
		 * An error occurred.
		 */		
		private function onBidFailure(error:Object = null):void
		{
			this.isEnabled = true;
			InfoManager.hide(_("Une erreur est survenue, veuillez réessayer."), InfoContent.ICON_CROSS, InfoManager.DEFAULT_DISPLAY_TIME);
		}
		
		/**
		 * The user has requested an update by pulling the list down.
		 */		
		private function onRefreshPendingBid(event:Event = null):void
		{
			this.isEnabled = false;
			InfoManager.show(_("Chargement..."));
			Remote.getInstance().getSpecificBid(_pendingBidItemData.id, onRefreshBidSuccess, onBidFailure, onBidFailure, 1, AbstractEntryPoint.screenNavigator.activeScreenID);
		}
		
		/**
		 * The bid have been successfully refreshed.
		 */		
		private function onRefreshBidSuccess(result:Object):void
		{
			this.isEnabled = true;
			//AlertManager.hide("", ProgressPopup.SUCCESS_ICON_NOTHING, 0);
			this.onRefreshComplete();
			_pendingBidItemData = new PendingBidItemData(result);
			
			_bidInput.removeFromParent();
			_validateButton.removeFromParent();
			_giftDescription.removeFromParent();
			_message.removeFromParent();
			_giftDescription.removeFromParent();
			
			if( _pendingBidItemData.state == PendingBidItemData.STATE_NOT_CONNECTED ||
				_pendingBidItemData.state == PendingBidItemData.STATE_ACTUAL_WINNER ||
				_pendingBidItemData.state == PendingBidItemData.STATE_FINISHED )
			{
				switch(_pendingBidItemData.state)
				{
					case PendingBidItemData.STATE_NOT_CONNECTED: { _message.text = _("Aucune connexion Internet."); break; }
					case PendingBidItemData.STATE_ACTUAL_WINNER: { _message.text = _("Bravo !\n\nVous êtes provisoirement le gagnant de cette enchère !");         break; }
					case PendingBidItemData.STATE_FINISHED:      { _message.text = _("Cette enchère est terminée.");          break; }
				}
				
				addChild(_message);
				addChild(_giftDescription);
			}
			else
			{
				_bidInput.prompt = formatString( _("Enchère minimum : {0}."), _pendingBidItemData.minimumBid );
				
				addChild(_bidInput);
				addChild(_validateButton);
				addChild(_giftDescription);
			}
			
			_needResize = true;
			this.invalidate(INVALIDATION_FLAG_SIZE);
			
			InfoManager.hide("", InfoContent.ICON_NOTHING, 0);
			//invalidate(INVALIDATION_FLAG_SIZE);
		}
		
		/**
		 * An error occurred while refreshing the current bid.
		 */		
		private function onRefreshBidFailure(error:Object = null):void
		{
			this.isEnabled = true;
			InfoManager.hide(_("Une erreur est survenue, veuillez réessayer."), InfoContent.ICON_CROSS, InfoManager.DEFAULT_DISPLAY_TIME);
			this.onRefreshComplete();
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
			Starling.juggler.tween(_image, 0.75, { alpha:1 });
			
			_needResize = true;
			this.invalidate(INVALIDATION_FLAG_SIZE);
			this.invalidate(INVALIDATION_FLAG_SIZE);
		}
		
		/**
		 * When the image could not be loaded.
		 */		
		protected function onImageError(event:Event):void
		{
			this.invalidate(INVALIDATION_FLAG_SIZE);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
//------------------------------------------------------------------------------------------------------------
		
		override public function dispose():void
		{
			_notificationTitle.removeFromParent(true);
			_notificationTitle = null;
			
			_image.removeEventListener(Event.COMPLETE, onImageLoaded);
			_image.removeEventListener(FeathersEventType.ERROR, onImageError);
			_image.removeFromParent(true);
			_image = null;
			
			_giftName.removeFromParent(true);
			_giftName = null;
			
			_giftDescription.removeFromParent(true);
			_giftDescription = null;
			
			if( _message )
			{
				_message.removeFromParent(true);
				_message = null;
			}
			
			if( _bidInput )
			{
				_bidInput.removeEventListener(FeathersEventType.ENTER, onValidate);
				_bidInput.removeFromParent(true);
				_bidInput = null;
			}
			
			if( _validateButton )
			{
				_validateButton.removeEventListener(Event.TRIGGERED, onValidate);
				_validateButton.removeFromParent(true);
				_validateButton = null;
			}
			
			if( _imageLoader )
			{
				Starling.juggler.remove(_imageLoader);
				_imageLoader.removeFromParent(true);
				_imageLoader = null;
			}
			
			_pendingBidItemData = null;

			this.removeEventListener(LudoEventType.REFRESH_TOP, onRefreshPendingBid);
			
			super.dispose();
		}
	}
}