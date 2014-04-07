/*
LudoFactory
Framework mobile
Author  : Maxime Lhoez
Created : 7 nov. 2013
*/
package com.ludofactory.mobile.core.test.highscore
{
	import com.gamua.flox.Flox;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.Localizer;
	import com.ludofactory.mobile.core.authentication.MemberManager;
	import com.ludofactory.mobile.core.controls.AdvancedScreen;
	import com.ludofactory.mobile.core.controls.ScreenIds;
	import com.ludofactory.mobile.core.test.config.GlobalConfig;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import feathers.controls.Button;
	import feathers.controls.ImageLoader;
	import feathers.controls.Label;
	
	import starling.display.Image;
	import starling.display.Quad;
	import starling.events.Event;
	
	public class HighScoreHomeScreen extends AdvancedScreen
	{
		/**
		 * The icon. */		
		private var _icon:Image;
		
		/**
		 * The message. */		
		private var _message:Label;
		
		/**
		 * The shadow. */		
		private var _shadow:Quad;
		
		/**
		 * The white background. */		
		private var _background:Quad;
		
		/**
		 * The international icon. */		
		private var _internationalIcon:ImageLoader;
		/**
		 * The international button. */		
		private var _internationalButton:Button;
		
		/**
		 * The national icon. */		
		private var _nationalIcon:ImageLoader;
		/**
		 * The national button. */		
		private var _nationalButton:Button;
		
		/**
		 * The Facebook icon. */		
		private var _facebookIcon:ImageLoader;
		/**
		 * The friends button. */		
		private var _facebookButton:Button;
		
		public function HighScoreHomeScreen()
		{
			super();
			
			_whiteBackground = true;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			_headerTitle = Localizer.getInstance().translate("HIGH_SCORE_HOME.HEADER_TITLE");
			
			_icon = new Image(AbstractEntryPoint.assets.getTexture("menu-icon-highscore"));
			_icon.scaleX = _icon.scaleY = GlobalConfig.dpiScale;
			addChild(_icon);
			
			_message = new Label();
			_message.text = Localizer.getInstance().translate("HIGH_SCORE_HOME.MESSAGE");
			addChild(_message);
			_message.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(GlobalConfig.isPhone ? 38 : 48), Theme.COLOR_DARK_GREY, false, false, null, null, null, TextFormatAlign.CENTER);
			
			_shadow = new Quad(50, scaleAndRoundToDpi(12), 0x000000);
			_shadow.setVertexColor(0, 0xffffff);
			_shadow.setVertexAlpha(0, 0);
			_shadow.setVertexColor(1, 0xffffff);
			_shadow.setVertexAlpha(1, 0);
			_shadow.setVertexAlpha(2, 0.1);
			_shadow.setVertexAlpha(3, 0.1);
			addChild(_shadow);
			
			_background = new Quad(5, 5);
			addChild(_background);
			
			_internationalIcon = new ImageLoader();
			_internationalIcon.source = AbstractEntryPoint.assets.getTexture("flag-international");
			_internationalIcon.snapToPixels = true;
			_internationalIcon.textureScale = GlobalConfig.dpiScale;
			
			_internationalButton = new Button();
			_internationalButton.horizontalAlign = Button.HORIZONTAL_ALIGN_LEFT;
			_internationalButton.addEventListener(Event.TRIGGERED, onShowInternational);
			_internationalButton.label = Localizer.getInstance().translate("HIGH_SCORE_HOME.INTERNATIONAL_BUTTON_LABEL");
			_internationalButton.defaultIcon = _internationalIcon;
			addChild(_internationalButton);
			_internationalButton.gap = scaleAndRoundToDpi(40);
			_internationalButton.iconOffsetX = scaleAndRoundToDpi(20);
			
			var nationalTextureName:String;
			var countryData:CountryData;
			if( MemberManager.getInstance().isLoggedIn() )
			{
				for(var i:int = 0; i < GlobalConfig.COUNTRIES.length; i++)
				{
					countryData = GlobalConfig.COUNTRIES[i];
					if( countryData.id == MemberManager.getInstance().getCountryId() )
					{
						nationalTextureName = countryData.textureName;
						break;
					}
				}
			}
			else
			{
				nationalTextureName = "flag-france";
			}
			
			_nationalIcon = new ImageLoader();
			_nationalIcon.source = AbstractEntryPoint.assets.getTexture( nationalTextureName );
			_nationalIcon.snapToPixels = true;
			_nationalIcon.textureScale = GlobalConfig.dpiScale;
			
			_nationalButton = new Button();
			_nationalButton.horizontalAlign = Button.HORIZONTAL_ALIGN_LEFT;
			_nationalButton.addEventListener(Event.TRIGGERED, onShowNational);
			_nationalButton.label = Localizer.getInstance().translate("HIGH_SCORE_HOME.NATIONAL_BUTTON_LABEL");
			_nationalButton.defaultIcon = _nationalIcon;
			addChild(_nationalButton);
			_nationalButton.gap = scaleAndRoundToDpi(40);
			_nationalButton.iconOffsetX = scaleAndRoundToDpi(20);
			
			_facebookIcon = new ImageLoader();
			_facebookIcon.source = AbstractEntryPoint.assets.getTexture("facebook-icon");
			_facebookIcon.snapToPixels = true;
			_facebookIcon.textureScale = GlobalConfig.dpiScale;
			
			_facebookButton = new Button();
			_facebookButton.horizontalAlign = Button.HORIZONTAL_ALIGN_LEFT;
			_facebookButton.addEventListener(Event.TRIGGERED, onShowFacebook);
			_facebookButton.label = Localizer.getInstance().translate("HIGH_SCORE_HOME.FACEBOOK_BUTTON_LABEL");
			_facebookButton.defaultIcon = _facebookIcon;
			addChild(_facebookButton);
			_facebookButton.gap = scaleAndRoundToDpi(40);
			_facebookButton.iconOffsetX = scaleAndRoundToDpi(20);
		}
		
		override protected function draw():void
		{
			if( isInvalid(INVALIDATION_FLAG_SIZE) )
			{
				_icon.x = (actualWidth - _icon.width) * 0.5;
				_icon.y = scaleAndRoundToDpi( GlobalConfig.isPhone ? 10 : 20 );
				
				_message.y = _icon.y + _icon.height + scaleAndRoundToDpi( GlobalConfig.isPhone ? 10 : 20 );
				_message.width = actualWidth * 0.8;
				_message.x = (actualWidth - _message.width) * 0.5;
				_message.validate();
				
				_shadow.y = _message.y + _message.height + scaleAndRoundToDpi( GlobalConfig.isPhone ? 10 : 20 );
				_shadow.width = this.actualWidth;
				
				_background.y = _shadow.y + _shadow.height;
				_background.width = actualWidth;
				_background.height = actualHeight - _background.y;
				
				var gap:int = (actualHeight - _shadow.y - _shadow.y) / 4;
				
				_internationalButton.width = _nationalButton.width = _facebookButton.width = actualWidth * (GlobalConfig.isPhone ? 0.8 : 0.6);
				_internationalButton.x = _nationalButton.x = _facebookButton.x = (actualWidth - _internationalButton.width) * 0.5;
				
				_internationalButton.y = _background.y + gap;
				_internationalButton.validate();
				
				_nationalButton.y = _internationalButton.y + _internationalButton.height + gap;
				_nationalButton.validate();
				
				_facebookButton.y = _nationalButton.y + _nationalButton.height + gap;
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Handlers
//------------------------------------------------------------------------------------------------------------
		
		/**
		 * Show international ranking.
		 */		
		private function onShowInternational(event:Event):void
		{
			Flox.logInfo("\t\tClic sur le bouton classement International");
			advancedOwner.screenData.highscoreRankingType = 0;
			advancedOwner.showScreen( ScreenIds.HIGH_SCORE_LIST_SCREEN );
		}
		
		/**
		 * Show national ranking.
		 */		
		private function onShowNational(event:Event):void
		{
			Flox.logInfo("\t\tClic sur le bouton classement National");
			advancedOwner.screenData.highscoreRankingType = MemberManager.getInstance().isLoggedIn() ? MemberManager.getInstance().getCountryId() : 1;
			advancedOwner.showScreen( ScreenIds.HIGH_SCORE_LIST_SCREEN );
		}
		
		/**
		 * Show Facebook friends ranking.
		 */		
		private function onShowFacebook(event:Event):void
		{
			Flox.logInfo("\t\tClic sur le bouton classement Amis Facebook");
			advancedOwner.screenData.highscoreRankingType = -1;
			advancedOwner.showScreen( ScreenIds.HIGH_SCORE_LIST_SCREEN );
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
//------------------------------------------------------------------------------------------------------------
		
		override public function dispose():void
		{
			
			super.dispose();
		}
		
	}
}