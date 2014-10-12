/*
Copyright © 2006-2014 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 17 Août 2013
*/
package com.ludofactory.mobile.core.navigation.game
{

	import com.gamua.flox.Flox;
	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.common.gettext.aliases._n;
	import com.ludofactory.common.utils.log;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.AbstractGameInfo;
	import com.ludofactory.mobile.core.GameSessionTimer;
	import com.ludofactory.mobile.core.authentication.MemberManager;
	import com.ludofactory.mobile.core.authentication.MemberManager;
	import com.ludofactory.mobile.core.events.LudoEventType;
	import com.ludofactory.mobile.core.remoting.Remote;
	import com.ludofactory.mobile.core.storage.Storage;
	import com.ludofactory.mobile.core.storage.StorageConfig;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.push.GameSession;
	import com.ludofactory.mobile.core.theme.Theme;
	import com.vidcoin.vidcoincontroller.VidCoinController;
	import com.vidcoin.vidcoincontroller.events.VidCoinEvent;

	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import feathers.controls.Callout;
	import feathers.controls.Label;
	
	import starling.display.Image;
	import starling.events.Event;
	import starling.utils.formatString;
	
	public class StakeButtonFree extends StakeButton
	{
		public static var IS_TIMER_OVER_AND_REQUEST_FAILED:Boolean = false;
		
		/**
		 * The free icon. */		
		private var _icon:Image;
		/**
		 * The free disabled icon. */ 		
		private var _iconDisabled:Image;
		/**
		 * The main label */		
		private var _label:Label;
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
		private var _gameType:String;
		
		public function StakeButtonFree(gameType:String)
		{
			super();
			
			_gameType = gameType;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			_label = new Label();
			_container.addChild(_label);
			
			_icon = new Image( AbstractEntryPoint.assets.getTexture("GameTypeSelectionFreeIcon") );
			_icon.scaleX = _icon.scaleY = GlobalConfig.dpiScale;
			_container.addChild(_icon);
			
			_iconDisabled = new Image( AbstractEntryPoint.assets.getTexture("GameTypeSelectionFreeIconDisabled") );
			_iconDisabled.scaleX = _iconDisabled.scaleY = GlobalConfig.dpiScale;
			_container.addChild(_iconDisabled);
			
			_iconClock = new Image( AbstractEntryPoint.assets.getTexture("GameTypeSelectionClockIcon") );
			_iconClock.scaleX = _iconClock.scaleY = GlobalConfig.dpiScale;
			_iconClock.alignPivot();
			_container.addChild(_iconClock);
			
			onUpdateData();
			MemberManager.getInstance().addEventListener(LudoEventType.UPDATE_SUMMARY, onUpdateData);
		}
		
		override protected function draw():void
		{
			super.draw();
			
			if( _iconClock )
			{
				_iconClock.x = _shadowThickness;
				_iconClock.y = this.actualHeight - _shadowThickness;
			}
			
			_backgroundSkin.width = _backgroundDisabledSkin.width = this.actualWidth;
			_backgroundSkin.height = _backgroundDisabledSkin.height = this.actualHeight;
			
			_icon.x = _iconDisabled.x = scaleAndRoundToDpi(40);
			_icon.y = _iconDisabled.y = (this.actualHeight - _icon.height) * 0.5;
			
			_label.width = actualWidth - _icon.x - _icon.width - _shadowThickness - scaleAndRoundToDpi(20);
			_label.validate();
			_label.x = _icon.x + _icon.width + scaleAndRoundToDpi(20);
			_label.y = (actualHeight - _label.height) * 0.5;
		}
		
		/**
		 * Update data.
		 */		
		private function onUpdateData(event:Event = null):void
		{
			_isEnabled = MemberManager.getInstance().getNumFreeGameSessions() >= Storage.getInstance().getProperty( AbstractEntryPoint.screenNavigator.screenData.gameType == GameSession.TYPE_CLASSIC ? StorageConfig.PROPERTY_NUM_FREE_IN_FREE_MODE:StorageConfig.PROPERTY_NUM_FREE_IN_TOURNAMENT_MODE ) ? true:false;
			
			_iconClock.visible = false;
			_icon.visible = _isEnabled;
			_iconDisabled.visible = !_icon.visible;
			_backgroundSkin.visible = _isEnabled;
			_backgroundDisabledSkin.visible = !_backgroundSkin.visible;
			
			if( _isEnabled )
			{
				_label.text = formatString( _n("{0} partie gratuite", "{0} parties gratuites", Storage.getInstance().getProperty( _gameType == GameSession.TYPE_CLASSIC ? StorageConfig.PROPERTY_NUM_FREE_IN_FREE_MODE:StorageConfig.PROPERTY_NUM_FREE_IN_TOURNAMENT_MODE)),
					Storage.getInstance().getProperty( _gameType == GameSession.TYPE_CLASSIC ? StorageConfig.PROPERTY_NUM_FREE_IN_FREE_MODE:StorageConfig.PROPERTY_NUM_FREE_IN_TOURNAMENT_MODE ));
				_label.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(42), 0x0d2701);
			}
			else
			{
				if( MemberManager.getInstance().getNumFreeGameSessions() != 0 || !MemberManager.getInstance().isLoggedIn() )
				{
					_label.text = formatString( _n("{0} partie gratuite", "{0} parties gratuites", Storage.getInstance().getProperty( _gameType == GameSession.TYPE_CLASSIC ? StorageConfig.PROPERTY_NUM_FREE_IN_FREE_MODE:StorageConfig.PROPERTY_NUM_FREE_IN_TOURNAMENT_MODE)),
						Storage.getInstance().getProperty( _gameType == GameSession.TYPE_CLASSIC ? StorageConfig.PROPERTY_NUM_FREE_IN_FREE_MODE:StorageConfig.PROPERTY_NUM_FREE_IN_TOURNAMENT_MODE ));
					_label.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(42), 0x2d2d2d);
				}
				else
				{
					if( GameSessionTimer.IS_TIMER_OVER_AND_REQUEST_FAILED )
					{
						_label.text = _("???");
						_label.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(56), Theme.COLOR_WHITE);
					}
					else
					{
						if( MemberManager.getInstance().getCanWatchVideo() && AbstractEntryPoint.vidCoin.videoIsAvailableForPlacement(AbstractGameInfo.VID_COIN_PLACEMENT_ID) )
						{
							AbstractEntryPoint.vidCoin.addEventListener(VidCoinEvent.VIDCOIN, handleVidCoinEvent);
							AbstractEntryPoint.vidCoin.playAdForPlacement(AbstractGameInfo.VID_COIN_PLACEMENT_ID);
							Flox.logEvent("Affichages d'une vidéo VidCoin", {Total:"Total"});
							
							_label.text = formatString(_("Regarder une vidéo pour jouer gratuitement."));
							_label.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(42), Theme.COLOR_WHITE);
						}
						else
						{
							// mettre texte normal + timer
							_label.text = formatString(_("{0} parties dans "), MemberManager.getInstance().getNumFreeGameSessionsTotal()) + "--:--:--";
							_label.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(42), Theme.COLOR_WHITE);

							GameSessionTimer.registerFunction(setText);
						}
					}
					_iconClock.visible = true;
				}
			}
		}

		public function handleVidCoinEvent(event:VidCoinEvent):void
		{
			AbstractEntryPoint.vidCoin.removeEventListener(VidCoinEvent.VIDCOIN, handleVidCoinEvent);
			
			// TODO Gérer les erreurs :
			
			// TODO : si status = true (donc vidéo validée), je fais appel à Remote.getInstance().updateMises()
			// puis je met à jour le texte du bouton en fonction
			
			// URL de call back = paiement/valide_vidcoin.php (voir si on utilise le même compte que Ludokado mais
			// avec des emplacements différents).
			
			
			
			
			if(event.code == "vidcoinViewWillAppear")
			{
				// the video appears, here we need to insert a line in the database, stop sounds, etc.
				Remote.getInstance().logVidCoin(null, null, null, 2);
			}
			else if(event.code == "vidcoinViewDidDisappearWithInformation")
			{
				// the video left the screen, here we can resume audio and refresh the stakes
				// depending on the state 
				if(event.viewInfo["statusCode"] == VidCoinController.VCStatusCodeSuccess)
				{
					
					log(event.viewInfo["status"]); // success
					// log(event.viewInfo["reward"]); not used
				}
				else if(event.viewInfo["statusCode"] == VidCoinController.VCStatusCodeError)
				{
					
					log(event.viewInfo["status"]); // error
				}
				else if(event.viewInfo["statusCode"] == VidCoinController.VCStatusCodeCancel)
				{
					
					log(event.viewInfo["status"]); // cancel
				}
			}
			else if(event.code == "vidcoinDidValidateView")
			{
				// always called after the delegate method "vidcoinViewDidDisappearWithInformation"
				if(event.viewInfo["statusCode"] == VidCoinController.VCStatusCodeSuccess)
				{
					// TODO upfate mise ici : Remote.getInstance()....
					Flox.logEvent("Affichages popup marketing inscription", {Visionnage:"Validé"});
					log(event.viewInfo["status"]); // success
					log(event.viewInfo["reward"]);
				}
				else if(event.viewInfo["statusCode"] == VidCoinController.VCStatusCodeError)
				{
					Flox.logEvent("Affichages popup marketing inscription", {Visionnage:"Erreur"});
					log(event.viewInfo["status"]); // error
				}
				else if(event.viewInfo["statusCode"] == VidCoinController.VCStatusCodeCancel)
				{
					Flox.logEvent("Affichages popup marketing inscription", {Visionnage:"Annulée"});
					log(event.viewInfo["status"]); // cancel
				}
			}
		}
		
		private function setText(val:String):void
		{
			_label.text = formatString(_("{0} parties dans "), MemberManager.getInstance().getNumFreeGameSessionsTotal()) + val;
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
							_calloutLabel.text = formatString(_("Reconnectez-vous pour récupérer vos {0} parties gratuites."), MemberManager.getInstance().getNumFreeGameSessionsTotal());
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
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
		
		override public function dispose():void
		{
			MemberManager.getInstance().removeEventListener(LudoEventType.UPDATE_SUMMARY, onUpdateData);
			GameSessionTimer.unregisterFunction(setText);
			
			_label.removeFromParent(true);
			_label = null;
			
			_icon.removeFromParent(true);
			_icon = null;
			
			_iconDisabled.removeFromParent(true);
			_iconDisabled = null;
			
			if( _iconClock )
			{
				_iconClock.removeFromParent(true);
				_iconClock = null;
			}
			
			super.dispose();
		}
		
	}
}