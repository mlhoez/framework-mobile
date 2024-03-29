/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 8 septembre 2013
*/
package com.ludofactory.mobile.navigation.sponsor
{
	
	import com.freshplanet.nativeExtensions.AirNetworkInfo;
	import com.greensock.TweenMax;
	import com.greensock.easing.Linear;
	import com.ludofactory.common.gettext.LanguageManager;
	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.ButtonFactory;
	import com.ludofactory.mobile.FacebookButton;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.AbstractGameInfo;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.controls.AdvancedScreen;
	import com.ludofactory.mobile.core.manager.MemberManager;
	import com.ludofactory.mobile.core.model.ScreenIds;
	import com.ludofactory.mobile.core.notification.NotificationPopupManager;
	import com.ludofactory.mobile.core.notification.content.SponsorNotificationContent;
	import com.ludofactory.mobile.core.remoting.Remote;
	import com.ludofactory.mobile.core.storage.Storage;
	import com.ludofactory.mobile.core.storage.StorageConfig;
	import com.ludofactory.mobile.core.theme.Theme;
	import com.ludofactory.mobile.navigation.FacebookManagerEventType;
	import com.ludofactory.mobile.navigation.sponsor.invite.SponsorTypes;
	import com.milkmangames.nativeextensions.GAnalytics;
	
	import feathers.controls.Button;
	import feathers.controls.Label;
	import feathers.controls.LayoutGroup;
	import feathers.layout.HorizontalLayout;
	import feathers.layout.VerticalLayout;
	
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import starling.display.Image;
	import starling.events.Event;
	import starling.utils.deg2rad;
	import starling.utils.formatString;
	
	public class SponsorHomeScreen extends AdvancedScreen
	{
		/**
		 * The big glow. */		
		private var _glow:Image;
		
		/**
		 * The main container. */		
		private var _mainContainer:LayoutGroup;
		
		/**
		 * The introduction message. */		
		private var _titleLabel:Label;
		/**
		 * The title. */		
		private var _rewardValueLabel:Label;
		/**
		 *  */		
		private var _byFilleulLabel:Label;
		
		/**
		 * The know more button. */		
		private var _knowMoreButton:Button;
		
		/**
		 * The email button. */		
		private var _emailButton:Button;
		
		/**
		 * The friends image. */		
		private var _friendsImage:Image;
		/**
		 * The my filleuls button. */		
		private var _myFriendsButton:Button;
		
		/**
		 * Facebook button that will associate the account or directly publish, depending on the actual state. */
		private var _facebookButton:FacebookButton;
		
		public function SponsorHomeScreen()
		{
			super();
			
			_blueBackground = true;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			_glow = new Image( AbstractEntryPoint.assets.getTexture("HighScoreGlow") );
			_glow.scaleX = _glow.scaleY = GlobalConfig.dpiScale + 0.5;
			_glow.alpha = 0.4;
			_glow.alignPivot();
			addChild(_glow);
			
			_mainContainer = new LayoutGroup();
			_mainContainer.layout = new VerticalLayout();
			(_mainContainer.layout as VerticalLayout).gap = scaleAndRoundToDpi(GlobalConfig.isPhone ? 10 : 20);
			(_mainContainer.layout as VerticalLayout).horizontalAlign = HorizontalLayout.HORIZONTAL_ALIGN_CENTER;
			_mainContainer.clipContent = false;
			addChild(_mainContainer);
			
			_titleLabel = new Label();
			_titleLabel.touchable = false;
			_titleLabel.text = _("Parrainez\net gagnez jusqu'à");
			_mainContainer.addChild(_titleLabel);
			_titleLabel.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(GlobalConfig.isPhone ? 52 : 72), Theme.COLOR_WHITE, false, false, null, null, null, TextFormatAlign.CENTER);
			_titleLabel.textRendererProperties.wordWrap = false;
			_titleLabel.textRendererProperties.nativeFilters = [ new DropShadowFilter(0, 75, 0x000000, 0.75, scaleAndRoundToDpi(5), scaleAndRoundToDpi(5)) ];
			
			_rewardValueLabel = new Label();
			_rewardValueLabel.touchable = false;
			_rewardValueLabel.text = Storage.getInstance().getProperty(StorageConfig.PROPERTY_SPONSOR_REWARD_VALUE); // always a String well formatted : whether "30 €" or "100 000"
			_mainContainer.addChild(_rewardValueLabel);
			_rewardValueLabel.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(GlobalConfig.isPhone ? 110 : 140), 0xffe900, false, false, null, null, null, TextFormatAlign.CENTER);
			_rewardValueLabel.textRendererProperties.nativeFilters = [ new GlowFilter(0x006173, 1, scaleAndRoundToDpi(12), scaleAndRoundToDpi(12), scaleAndRoundToDpi(10)) ];
			
			_byFilleulLabel = new Label();
			_byFilleulLabel.touchable = false;
			_byFilleulLabel.text = Storage.getInstance().getProperty(StorageConfig.PROPERTY_SPONSOR_REWARD_TYPE) == 1 ? _("POINTS PAR FILLEUL") : _("PAR FILLEUL");
			_mainContainer.addChild(_byFilleulLabel);
			_byFilleulLabel.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(GlobalConfig.isPhone ? 52 : 82), 0xffe900, false, false, null, null, null, TextFormatAlign.CENTER);
			_byFilleulLabel.textRendererProperties.nativeFilters = [ new GlowFilter(0x006173, 1, scaleAndRoundToDpi(12), scaleAndRoundToDpi(12), scaleAndRoundToDpi(10)) ];
			
			_knowMoreButton = new Button();
			_knowMoreButton.addEventListener(Event.TRIGGERED, onKnowMoreSelected);
			_knowMoreButton.styleName = Theme.BUTTON_TRANSPARENT_WHITE;
			_knowMoreButton.label = _("Comment ça marche ?");
			_mainContainer.addChild(_knowMoreButton);
			_knowMoreButton.defaultLabelProperties.textFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(26), Theme.COLOR_WHITE);
			
			
			_emailButton = new Button();
			_emailButton.addEventListener(Event.TRIGGERED, onEmailSelected);
			_emailButton.label = _("Inviter");
			addChild(_emailButton);
			_emailButton.gap = GlobalConfig.isPhone ? 0 : 20;
			_emailButton.minHeight = scaleAndRoundToDpi(GlobalConfig.isPhone ? 118 : 128);
			
			_friendsImage = new Image(AbstractEntryPoint.assets.getTexture("friends"));
			_friendsImage.touchable = false;
			_friendsImage.scaleX = _friendsImage.scaleY = GlobalConfig.dpiScale;
			addChild(_friendsImage);
			
			_myFriendsButton = new Button();
			_myFriendsButton.addEventListener(Event.TRIGGERED, onMyFriendsSelected);
			_myFriendsButton.styleName = Theme.BUTTON_GREEN;
			_myFriendsButton.label = _("Mes filleuls");
			addChild(_myFriendsButton);
			_myFriendsButton.minHeight = scaleAndRoundToDpi(GlobalConfig.isPhone ? 118 : 128);
			
			_facebookButton = ButtonFactory.getFacebookButton(_("Partager"), ButtonFactory.FACEBOOK_TYPE_SHARE, formatString(_("Mon code parrain : {0} !"), MemberManager.getInstance().id),
					"",
					_("Devenez mes filleuls en vous inscrivant avec ce code et gagnez des tas de bonus !"),
					_("http://www.ludokado.com/"),
					formatString(_("http://img.ludokado.com/img/frontoffice/{0}/mobile/publication/pyramid.jpg"), LanguageManager.getInstance().lang));
			_facebookButton.addEventListener(FacebookManagerEventType.REFRESH_PUBLICAION_DATA, onRefreshPublicationData);
			addChild(_facebookButton);
			
			if( MemberManager.getInstance().isLoggedIn() )
			{
				if( AirNetworkInfo.networkInfo.isConnected() )
					Remote.getInstance().initParrainage(onParrainageInitSuccess, null, null, 1, advancedOwner.activeScreenID);
			}
		}
		
		override protected function draw():void
		{
			if( isInvalid(INVALIDATION_FLAG_SIZE) )
			{
				if( AbstractGameInfo.LANDSCAPE )
				{
					_mainContainer.width = _rewardValueLabel.width = _titleLabel.width = _byFilleulLabel.width = actualWidth * 0.5;
					_mainContainer.validate();
					_mainContainer.x = scaleAndRoundToDpi(20);
					_mainContainer.y = (actualHeight - _mainContainer.height) * 0.5;
					
					_glow.x = _mainContainer.x + (_mainContainer.width * 0.5);
					_glow.y = _mainContainer.y + (_mainContainer.height * 0.35);
					
					_myFriendsButton.width = _emailButton.width = _facebookButton.width = actualWidth * 0.4;
					
					_emailButton.validate();
					_friendsImage.y = ( actualHeight - (_emailButton.height * 2 + _friendsImage.height * 0.4 + _facebookButton.height + scaleAndRoundToDpi(GlobalConfig.isPhone ? 40 : 100)) ) * 0.5;
					_myFriendsButton.x = _emailButton.x = _facebookButton.x = actualWidth * 0.5 + ((actualWidth * 0.5) - _myFriendsButton.width) * 0.5;
					_myFriendsButton.validate();
					_myFriendsButton.y = _friendsImage.y + _friendsImage.height * 0.6;
					
					_facebookButton.height = _emailButton.height;
					
					_friendsImage.x = _myFriendsButton.x + (_myFriendsButton.width - _friendsImage.width) * 0.5;
					
					_emailButton.y = _myFriendsButton.y + _myFriendsButton.height + scaleAndRoundToDpi(GlobalConfig.isPhone ? 20 : 50);
					_facebookButton.y = _emailButton.y + _emailButton.height + scaleAndRoundToDpi(GlobalConfig.isPhone ? 20 : 50);
					
					
					
					TweenMax.to(_glow, 1.25, { alpha:0.1, repeat:-1, yoyo:true, ease:Linear.easeNone });
					TweenMax.to(_glow, 25, { rotation:deg2rad(360), repeat:-1, ease:Linear.easeNone });
				}
				else
				{
					_mainContainer.width = _rewardValueLabel.width = _titleLabel.width = _byFilleulLabel.width = actualWidth;
					_mainContainer.validate();
					_mainContainer.y = (actualHeight - _mainContainer.height) * 0.1;
					
					_emailButton.width = actualWidth * 0.7;
					_emailButton.x = (actualWidth - _emailButton.width) * 0.5;
					
					_glow.x = _mainContainer.x + (_mainContainer.width * 0.5);
					_glow.y = _mainContainer.y + (_mainContainer.height * 0.35);
					
					_myFriendsButton.width = actualWidth * 0.7;
					
					_emailButton.validate();
					_friendsImage.y = _knowMoreButton.y + _knowMoreButton.height + ((actualHeight - _knowMoreButton.y - _knowMoreButton.height) - (_emailButton.height * 2 + _friendsImage.height * 0.4 + scaleAndRoundToDpi(GlobalConfig.isPhone ? 20 : 50)) ) * 0.5;
					_myFriendsButton.x = _emailButton.x = (actualWidth - _myFriendsButton.width) * 0.5;
					_myFriendsButton.validate();
					_myFriendsButton.y = _friendsImage.y + _friendsImage.height * 0.6;
					
					_friendsImage.x = _myFriendsButton.x + (_myFriendsButton.width - _friendsImage.width) * 0.5;
					
					_emailButton.y = _myFriendsButton.y + _myFriendsButton.height + scaleAndRoundToDpi(GlobalConfig.isPhone ? 20 : 50);
					
					TweenMax.to(_glow, 1.25, { alpha:0.1, repeat:-1, yoyo:true, ease:Linear.easeNone });
					TweenMax.to(_glow, 25, { rotation:deg2rad(360), repeat:-1, ease:Linear.easeNone });
				}
				
				_knowMoreButton.width += scaleAndRoundToDpi(GlobalConfig.isPhone ? 20 : 60);
			}
			
			super.draw();
		}
		
//------------------------------------------------------------------------------------------------------------
//	Handlers
		
		private function onParrainageInitSuccess(result:Object):void
		{
			if( MemberManager.getInstance().isLoggedIn() )
			{
				if( result.hasOwnProperty("parrainage_gain_max") && result.parrainage_gain_max )
					Storage.getInstance().setProperty(StorageConfig.PROPERTY_SPONSOR_REWARD_VALUE, result.parrainage_gain_max);
				if( result.hasOwnProperty("parrainage_gain_type") && result.parrainage_gain_type )
					Storage.getInstance().setProperty(StorageConfig.PROPERTY_SPONSOR_REWARD_TYPE, result.parrainage_gain_type);
				
				_byFilleulLabel.text = Storage.getInstance().getProperty(StorageConfig.PROPERTY_SPONSOR_REWARD_TYPE) == 1 ? _("POINTS PAR FILLEUL") : _("PAR FILLEUL");
				_rewardValueLabel.text = Storage.getInstance().getProperty(StorageConfig.PROPERTY_SPONSOR_REWARD_VALUE);
			}
		}
		
		private function onSmsSelected(event:Event):void
		{
			if( MemberManager.getInstance().isLoggedIn() )
			{
				this.advancedOwner.screenData.sponsorType = SponsorTypes.SMS;
				this.advancedOwner.showScreen( ScreenIds.SPONSOR_INVITE_SCREEN );
			}
			else
			{
				advancedOwner.showScreen( ScreenIds.REGISTER_SCREEN );
			}
		}
		
		private function onEmailSelected(event:Event):void
		{
			if( MemberManager.getInstance().isLoggedIn() )
			{
				this.advancedOwner.screenData.sponsorType = SponsorTypes.EMAIL;
				this.advancedOwner.showScreen( ScreenIds.SPONSOR_INVITE_SCREEN );
			}
			else
			{
				advancedOwner.showScreen( ScreenIds.REGISTER_SCREEN );
			}
		}
		
		private function onMyFriendsSelected(event:Event):void
		{
			if( MemberManager.getInstance().isLoggedIn() )
			{
				this.advancedOwner.showScreen( ScreenIds.SPONSOR_FRIENDS_SCREEN );
			}
			else
			{
				advancedOwner.showScreen( ScreenIds.REGISTER_SCREEN );
			}
		}
		
		private function onKnowMoreSelected(event:Event):void
		{
			if( GAnalytics.isSupported() )
				GAnalytics.analytics.defaultTracker.trackEvent("Accueil parrainage", "Popup de plus d'informations", null, NaN, MemberManager.getInstance().id);
			NotificationPopupManager.addNotification( new SponsorNotificationContent() );
		}
		
//------------------------------------------------------------------------------------------------------------
//	Facebook
		
		private function onRefreshPublicationData(event:Event):void
		{
			// no need to listen again
			_facebookButton.removeEventListener(FacebookManagerEventType.REFRESH_PUBLICAION_DATA, onRefreshPublicationData);
			
			_facebookButton.refreshPublicationData(formatString(_("Mon code parrain : {0} !"), MemberManager.getInstance().id),
					"",
					_("Devenez mes filleuls en vous inscrivant avec ce code et gagnez des tas de bonus !"),
					_("http://www.ludokado.com/"),
					formatString(_("http://img.ludokado.com/img/frontoffice/{0}/mobile/publication/pyramid.jpg"), LanguageManager.getInstance().lang));
			_facebookButton.publish();
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
		
		override public function dispose():void
		{
			TweenMax.killTweensOf(_glow);
			_glow.removeFromParent(true);
			_glow = null;
			
			_rewardValueLabel.removeFromParent(true);
			_rewardValueLabel = null;
			
			_titleLabel.removeFromParent(true);
			_titleLabel = null;
			
			_knowMoreButton.removeEventListener(Event.TRIGGERED, onKnowMoreSelected);
			_knowMoreButton.removeFromParent(true);
			_knowMoreButton = null;
			
			_emailButton.removeEventListener(Event.TRIGGERED, onEmailSelected);
			_emailButton.removeFromParent(true);
			_emailButton = null;
			
			_myFriendsButton.removeEventListener(Event.TRIGGERED, onMyFriendsSelected);
			_myFriendsButton.removeFromParent(true);
			_myFriendsButton = null;
			
			_facebookButton.removeEventListener(FacebookManagerEventType.REFRESH_PUBLICAION_DATA, onRefreshPublicationData);
			_facebookButton.removeFromParent(true);
			_facebookButton = null;
			
			_friendsImage.removeFromParent(true);
			_friendsImage = null;
			
			_mainContainer.removeFromParent(true);
			_mainContainer = null;
			
			super.dispose();
		}
	}
}