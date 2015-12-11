/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 17 Août 2013
*/
package com.ludofactory.mobile.navigation.game
{

	import com.gamua.flox.Flox;
	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.common.gettext.aliases._n;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.AbstractGameInfo;
	import com.ludofactory.mobile.core.GameSessionTimer;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.events.MobileEventTypes;
	import com.ludofactory.mobile.core.manager.MemberManager;
	import com.ludofactory.mobile.core.model.GameMode;
	import com.ludofactory.mobile.core.model.ScreenIds;
	import com.ludofactory.mobile.core.notification.NotificationPopupManager;
	import com.ludofactory.mobile.core.notification.content.MarketingRegisterNotificationContent;
	import com.ludofactory.mobile.core.remoting.Remote;
	import com.ludofactory.mobile.core.storage.Storage;
	import com.ludofactory.mobile.core.storage.StorageConfig;
	import com.ludofactory.mobile.core.theme.Theme;
	import com.vidcoin.extension.ane.VidCoinController;
	import com.vidcoin.extension.ane.events.VidCoinEvents;

	import feathers.controls.Callout;
	import feathers.controls.Label;

	import flash.filters.BitmapFilterQuality;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	import starling.display.Image;
	import starling.events.Event;
	import starling.utils.formatString;

	public class StakeButtonToken extends StakeButton
	{
		/**
		 * The clock icon. */		
		private var _iconClock:Image;
		/**
		 * Whether the callout is dislaying. */		
		private var _isCalloutDisplaying:Boolean = false;
		/**
		 * Callout label. */		
		private var _calloutLabel:Label;
		
		/**
		 *  The game type. */		
		private var _gameType:int;

		/**
		 * Whether VidCoin is enabled. */
		private var _vidCoinEnabled:Boolean = false;
		
		public function StakeButtonToken(gameType:int)
		{
			super();
			
			_gameType = gameType;
		}
		
		override protected function initialize():void
		{
			super.initialize();

			_label.color = 0xffffff;
			_label.nativeFilters = [ new GlowFilter(0x1a7602, 1, scaleAndRoundToDpi(1.0), scaleAndRoundToDpi(1.0), scaleAndRoundToDpi(5), BitmapFilterQuality.LOW),
				new DropShadowFilter(2, 75, 0x1a7602, 0.6, scaleAndRoundToDpi(1), scaleAndRoundToDpi(1), scaleAndRoundToDpi(1), BitmapFilterQuality.LOW) ];
			
			_iconClock = new Image( AbstractEntryPoint.assets.getTexture("GameTypeSelectionClockIcon") );
			_iconClock.scaleX = _iconClock.scaleY = GlobalConfig.dpiScale;
			_iconClock.alignPivot();
			_container.addChild(_iconClock);
			
			onUpdateData();
			MemberManager.getInstance().addEventListener(MobileEventTypes.MEMBER_UPDATED, onUpdateData);
		}
		
		override protected function draw():void
		{
			super.draw();
			
			if( _iconClock )
			{
				_iconClock.x = _shadowThickness;
				_iconClock.y = _shadowThickness;
			}
		}
		
		/**
		 * Update data.
		 */		
		private function onUpdateData(event:Event = null):void
		{
			var numTokensRequiredToPlay:int = Storage.getInstance().getProperty(_gameType == GameMode.SOLO ? StorageConfig.NUM_TOKENS_IN_SOLO_MODE:StorageConfig.NUM_TOKENS_IN_TOURNAMENT_MODE);
			
			_isEnabled = MemberManager.getInstance().tokens >= numTokensRequiredToPlay;
			
			_iconClock.visible = false;

			_icon.texture = AbstractEntryPoint.assets.getTexture( (_isEnabled || !MemberManager.getInstance().isLoggedIn()) ? "stake-choice-token-icon" : "stake-choice-token-icon-disabled" );
			_backgroundSkin.textures = (_isEnabled || !MemberManager.getInstance().isLoggedIn()) ? Theme.buttonGreenSkinTextures : Theme.buttonDisabledSkinTextures;

			GameSessionTimer.unregisterFunction(setText);
			
			if( _isEnabled )
			{
				_label.text = formatString(_n("{0} Jeton", "{0} Jetons", numTokensRequiredToPlay), numTokensRequiredToPlay);
			}
			else
			{
				if( MemberManager.getInstance().tokens >= numTokensRequiredToPlay || !MemberManager.getInstance().isLoggedIn() )
				{
					_label.text = formatString(_n("{0} Jeton", "{0} Jetons", numTokensRequiredToPlay), numTokensRequiredToPlay);
				}
				else
				{
					if( GameSessionTimer.IS_TIMER_OVER_AND_REQUEST_FAILED )
					{
						_label.text = _("???");
					}
					else
					{
						if( MemberManager.getInstance().getCanWatchVideo() && AbstractEntryPoint.vidCoin.videoIsAvailableForPlacement(AbstractGameInfo.VID_COIN_PLACEMENT_ID) )
						{
							_label.text = formatString(_("Regarder une vidéo pour jouer gratuitement."));

							_vidCoinEnabled = true;

							_icon.texture = AbstractEntryPoint.assets.getTexture("stake-choice-token-icon");
							_backgroundSkin.textures = Theme.buttonGreenSkinTextures;
						}
						else
						{
							if(MemberManager.getInstance().tokens == 0)
							{
								// mettre texte normal + timer
								_label.text = formatString(_("{0} Jetons dans \n"), MemberManager.getInstance().totalTokensADay) + "--:--:--";
								
								_vidCoinEnabled = false;
	
								GameSessionTimer.registerFunction(setText);
							}
							else
							{
								_label.text = formatString(_n("{0} Jeton", "{0} Jetons", numTokensRequiredToPlay), numTokensRequiredToPlay);
							}
						}
					}
					_iconClock.visible = true;
				}
			}
		}

		public function handleVidCoinEvent(event:VidCoinEvents):void
		{
			var eventCode:String = event.code;
			switch (eventCode)
			{
				case "vidcoinViewWillAppear":
				case "vidCoinViewWillAppear":
				{
					// the video appears, here we need to insert a line in the database, stop sounds, etc.
					Remote.getInstance().logVidCoin(null, null, null, 2, AbstractEntryPoint.screenNavigator.activeScreenID);
					break;
				}
				case "vidcoinViewDidDisappearWithInformation":
				case "vidCoinViewDidDisappearWithViewInformation":
				{
					// the video left the screen, here we can resume audio and refresh the stakes if necessary
					if(event.viewInfo["statusCode"] == VidCoinController.VCStatusCodeSuccess)
					{
						Remote.getInstance().updateMises(null, null, null, 1, AbstractEntryPoint.screenNavigator.activeScreenID);
					}
					else if(event.viewInfo["statusCode"] == VidCoinController.VCStatusCodeError)
					{
						
					}
					else if(event.viewInfo["statusCode"] == VidCoinController.VCStatusCodeCancel)
					{
						
					}
					break;
				}
					
				case "vidcoinDidValidateView":
				case "vidCoinDidValidateView":
				{
					// always called after the delegate method "vidcoinViewDidDisappearWithInformation"
					if(event.viewInfo["statusCode"] == VidCoinController.VCStatusCodeSuccess)
					{
						
						Flox.logEvent("Affichages d'une vidéo VidCoin", {Visionnage:"Validé"});
					}
					else if(event.viewInfo["statusCode"] == VidCoinController.VCStatusCodeError)
					{
						Flox.logEvent("Affichages d'une vidéo VidCoin", {Visionnage:"Erreur"});
					}
					else if(event.viewInfo["statusCode"] == VidCoinController.VCStatusCodeCancel)
					{
						Flox.logEvent("Affichages d'une vidéo VidCoin", {Visionnage:"Annulée"});
					}
					
					break;
				}
				case "vidcoinCampaignsUpdate":
				case "vidCoinCampaignsUpdate":
				{
					// maybe a new video available
					onUpdateData();
					
					break;
				}
			}
		}
		
		private function setText(val:String):void
		{
			_label.text = formatString(_("{0} Jetons dans \n"), MemberManager.getInstance().totalTokensADay) + val;
		}
		
		private function onCalloutRemoved(event:Event):void
		{
			event.target.removeEventListener(Event.REMOVED_FROM_STAGE, onCalloutRemoved);
			_isCalloutDisplaying = false;
		}
		
		override protected function triggerButton():void
		{
			if( _isEnabled )
			{
				dispatchEventWith(Event.TRIGGERED);
			}
			else
			{
				if( GameSessionTimer.IS_TIMER_OVER_AND_REQUEST_FAILED )
				{
					if( !_isCalloutDisplaying )
					{
						if( !_calloutLabel )
						{
							_calloutLabel = new Label();
							_calloutLabel.text = formatString(_("Reconnectez-vous pour récupérer vos {0} Jetons."), MemberManager.getInstance().totalTokensADay);
							_calloutLabel.width = actualWidth * 0.9;
							_calloutLabel.validate();
						}
						_isCalloutDisplaying = true;
						var callout:Callout = Callout.show(_calloutLabel, this, Callout.DIRECTION_UP, false);
						callout.disposeContent = false;
						callout.touchable = false;
						callout.addEventListener(Event.REMOVED_FROM_STAGE, onCalloutRemoved);
						_calloutLabel.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(26), Theme.COLOR_DARK_GREY, false, false, null, null, null, TextFormatAlign.CENTER);
					}
				}
				else if( _vidCoinEnabled )
				{
					Flox.logEvent("Affichages d'une vidéo VidCoin", {Total:"Total"});
					AbstractEntryPoint.vidCoin.addEventListener(VidCoinEvents.VIDCOIN, handleVidCoinEvent);
					AbstractEntryPoint.vidCoin.playAdForPlacement(AbstractGameInfo.VID_COIN_PLACEMENT_ID);
				}
				else
				{
					if(!MemberManager.getInstance().isLoggedIn())
						NotificationPopupManager.addNotification( new MarketingRegisterNotificationContent(_("Vous n'avez plus assez de Jetons."), ScreenIds.GAME_TYPE_SELECTION_SCREEN) );
				}
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
		
		override public function dispose():void
		{
			MemberManager.getInstance().removeEventListener(MobileEventTypes.MEMBER_UPDATED, onUpdateData);
			GameSessionTimer.unregisterFunction(setText);

			AbstractEntryPoint.vidCoin.removeEventListener(VidCoinEvents.VIDCOIN, handleVidCoinEvent);
			
			if( _iconClock )
			{
				_iconClock.removeFromParent(true);
				_iconClock = null;
			}
			
			super.dispose();
		}
		
	}
}