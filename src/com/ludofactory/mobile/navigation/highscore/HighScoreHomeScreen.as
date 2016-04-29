/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 7 nov. 2013
*/
package com.ludofactory.mobile.navigation.highscore
{
	
	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.common.utils.Utilities;
	import com.ludofactory.common.utils.roundUp;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.AbstractGameInfo;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.controls.AdvancedScreen;
	import com.ludofactory.mobile.core.model.ScreenIds;
	import com.ludofactory.mobile.core.theme.Theme;
	import com.ludofactory.newClasses.Analytics;
	
	import feathers.controls.Button;
	import feathers.controls.Label;
	
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
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
		 * The international button. */		
		private var _internationalButton:Button;
		/**
		 * The national button. */		
		private var _nationalButton:Button;
		/**
		 * The friends button. */		
		private var _facebookButton:Button;
		
		public function HighScoreHomeScreen()
		{
			super();
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			_icon = new Image(AbstractEntryPoint.assets.getTexture("menu-icon-highscore"));
			_icon.scaleX = _icon.scaleY = Utilities.getScaleToFillWidth(_icon.width, (GlobalConfig.stageWidth * (AbstractGameInfo.LANDSCAPE ? 0.25: 0.35)));
			addChild(_icon);
			
			_message = new Label();
			_message.text = _("Serez-vous le meilleur\ndes meilleurs ?");
			addChild(_message);
			_message.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(AbstractGameInfo.LANDSCAPE ? (GlobalConfig.isPhone ? 38 : 48) : (GlobalConfig.isPhone ? 38 : 68)), Theme.COLOR_DARK_GREY, false, false, null, null, null, TextFormatAlign.CENTER);
			
			if( !AbstractGameInfo.LANDSCAPE )
			{
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
			}
			
			_internationalButton = new Button();
			_internationalButton.horizontalAlign = Button.HORIZONTAL_ALIGN_LEFT;
			_internationalButton.addEventListener(Event.TRIGGERED, onShowInternational);
			_internationalButton.label = _("International");
			addChild(_internationalButton);
			_internationalButton.gap = scaleAndRoundToDpi(40);
			_internationalButton.iconOffsetX = scaleAndRoundToDpi(20);
			
			_nationalButton = new Button();
			_nationalButton.horizontalAlign = Button.HORIZONTAL_ALIGN_LEFT;
			_nationalButton.addEventListener(Event.TRIGGERED, onShowNational);
			_nationalButton.label = _("National");
			addChild(_nationalButton);
			_nationalButton.gap = scaleAndRoundToDpi(40);
			_nationalButton.iconOffsetX = scaleAndRoundToDpi(20);
			
			_facebookButton = new Button();
			_facebookButton.horizontalAlign = Button.HORIZONTAL_ALIGN_LEFT;
			_facebookButton.addEventListener(Event.TRIGGERED, onShowFacebook);
			_facebookButton.label = _("Amis");
			addChild(_facebookButton);
			_facebookButton.gap = scaleAndRoundToDpi(40);
			_facebookButton.iconOffsetX = scaleAndRoundToDpi(20);
		}
		
		override protected function draw():void
		{
			if( isInvalid(INVALIDATION_FLAG_SIZE) )
			{
				var gap:int;
				var padding:int;
				var maxButtonHeight:int;
				if( AbstractGameInfo.LANDSCAPE )
				{
					_icon.x = (((actualWidth * 0.5) - _icon.width) * 0.5) << 0;
					
					_message.width = actualWidth * 0.8;
					_message.x = (((actualWidth * 0.5) - _message.width) * 0.5) << 0;
					_message.validate();
					
					_icon.y =  roundUp( (actualHeight - (_icon.height + _message.height + scaleAndRoundToDpi(GlobalConfig.isPhone ? 25 : 50))) * 0.5 );
					_message.y = _icon.y + _icon.height + scaleAndRoundToDpi( GlobalConfig.isPhone ? 25 : 50 );
					
					gap = scaleAndRoundToDpi(GlobalConfig.isPhone ? 10 : 30);
					padding = scaleAndRoundToDpi(GlobalConfig.isPhone ? 10 : 20);
					maxButtonHeight = (actualHeight - (padding * 2) - (gap * 2)) / 3;
					_internationalButton.width = _nationalButton.width = _facebookButton.width = actualWidth * 0.45;
					_internationalButton.height = _nationalButton.height = _facebookButton.height = scaleAndRoundToDpi(GlobalConfig.isPhone ? 118 : 138) > maxButtonHeight ? maxButtonHeight : scaleAndRoundToDpi(GlobalConfig.isPhone ? 118 : 138);
					_internationalButton.x = _nationalButton.x = _facebookButton.x = actualWidth * 0.5 + ((actualWidth * 0.5) - _internationalButton.width) * 0.5;
					
					_internationalButton.validate();
					gap = scaleAndRoundToDpi(GlobalConfig.isPhone ? 10 : 60);
					
					_internationalButton.y = padding + (actualHeight - (_internationalButton.height * 3) - (gap * 2) - (padding * 2)) * 0.5;
					
					_nationalButton.y = _internationalButton.y + _internationalButton.height + gap;
					_nationalButton.validate();
					
					_facebookButton.y = _nationalButton.y + _nationalButton.height + gap;
				}
				else
				{
					_icon.x = (actualWidth - _icon.width) * 0.5;
					_icon.y = scaleAndRoundToDpi( GlobalConfig.isPhone ? 10 : 60 );
					
					_message.y = _icon.y + _icon.height + scaleAndRoundToDpi( GlobalConfig.isPhone ? 10 : 20 );
					_message.width = actualWidth * 0.8;
					_message.x = (actualWidth - _message.width) * 0.5;
					_message.validate();
					
					_shadow.y = _message.y + _message.height + scaleAndRoundToDpi( GlobalConfig.isPhone ? 10 : 60 );
					_shadow.width = this.actualWidth;
					
					_background.y = _shadow.y + _shadow.height;
					_background.width = actualWidth;
					_background.height = actualHeight - _background.y;
					
					gap = scaleAndRoundToDpi(GlobalConfig.isPhone ? 10 : 50);
					padding = scaleAndRoundToDpi(GlobalConfig.isPhone ? 10 : 20);
					maxButtonHeight = (actualHeight - _background.y - (padding * 2) - (gap * 2)) / 3;
					_internationalButton.width = _nationalButton.width = _facebookButton.width = actualWidth * (GlobalConfig.isPhone ? 0.8 : 0.6);
					_internationalButton.height = _nationalButton.height = _facebookButton.height = scaleAndRoundToDpi(GlobalConfig.isPhone ? 118 : 148) > maxButtonHeight ? maxButtonHeight : scaleAndRoundToDpi(GlobalConfig.isPhone ? 118 : 138);
					_internationalButton.x = _nationalButton.x = _facebookButton.x = (actualWidth - _internationalButton.width) * 0.5;
					
					_internationalButton.y = _background.y + padding + (_background.height - (_internationalButton.height * 3) - (gap * 2) - (padding * 2)) * 0.5;
					_internationalButton.validate();
					
					_nationalButton.y = _internationalButton.y + _internationalButton.height + gap;
					_nationalButton.validate();
					
					_facebookButton.y = _nationalButton.y + _nationalButton.height + gap;
				}
			}
			
			super.draw();
		}
		
//------------------------------------------------------------------------------------------------------------
//	Handlers
		
		/**
		 * Show international ranking.
		 */		
		private function onShowInternational(event:Event):void
		{
			Analytics.trackEvent("HighScores", "Affichage du classement International");
			advancedOwner.replaceScreen( ScreenIds.HIGH_SCORE_LIST_SCREEN );
		}
		
		/**
		 * Show national ranking.
		 */		
		private function onShowNational(event:Event):void
		{
			Analytics.trackEvent("HighScores", "Affichage du classement National");
			advancedOwner.replaceScreen( ScreenIds.HIGH_SCORE_LIST_SCREEN );
		}
		
		/**
		 * Show Facebook friends ranking.
		 */		
		private function onShowFacebook(event:Event):void
		{
			Analytics.trackEvent("HighScores", "Affichage du classement des Amis Facebook");
			advancedOwner.replaceScreen( ScreenIds.HIGH_SCORE_LIST_SCREEN );
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
		
		override public function dispose():void
		{
			_icon.removeFromParent(true);
			_icon = null;
			
			_message.removeFromParent(true);
			_message = null;
			
			if( _shadow )
			{
				_shadow.removeFromParent(true);
				_shadow = null;
			}
			
			if( _background )
			{
				_background.removeFromParent(true);
				_background = null;
			}
			
			_internationalButton.removeEventListener(Event.TRIGGERED, onShowInternational);
			_internationalButton.removeFromParent(true);
			_internationalButton = null;
			
			_nationalButton.removeEventListener(Event.TRIGGERED, onShowNational);
			_nationalButton.removeFromParent(true);
			_nationalButton = null;
			
			_facebookButton.removeEventListener(Event.TRIGGERED, onShowFacebook);
			_facebookButton.removeFromParent(true);
			_facebookButton = null;
			
			super.dispose();
		}
		
	}
}