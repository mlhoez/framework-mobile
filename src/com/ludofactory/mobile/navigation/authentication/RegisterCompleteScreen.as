/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 14 Juin 2013
*/
package com.ludofactory.mobile.navigation.authentication
{
	
	import com.gamua.flox.Flox;
	import com.hasoffers.nativeExtensions.MobileAppTracker;
	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractGameInfo;
	import com.ludofactory.mobile.core.model.ScreenIds;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.controls.AdvancedScreen;
	import com.ludofactory.mobile.core.manager.MemberManager;
	import com.ludofactory.mobile.core.theme.Theme;
	import com.milkmangames.nativeextensions.GAnalytics;
	
	import feathers.controls.Button;
	import feathers.controls.ImageLoader;
	import feathers.controls.Label;
	
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import starling.events.Event;
	
	/**
	 * This is the screen displayed when the user has successfully registered
	 * a new account.
	 */	
	public class RegisterCompleteScreen extends AdvancedScreen
	{
		/**
		 * The logo */		
		private var _logo:ImageLoader;
		/**
		 * The message */		
		private var _title:Label;
		/**
		 * The message */		
		private var _message:Label;
		/**
		 * Validate button */		
		private var _validateButton:Button;
		
		public function RegisterCompleteScreen()
		{
			super();
			
			_whiteBackground = true;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			_headerTitle = _("Inscription terminée");
			
			_logo = new ImageLoader();
			_logo.source = Theme.ludokadoLogoTexture;
			_logo.textureScale = GlobalConfig.dpiScale;
			_logo.snapToPixels = true;
			_logo.touchable = false;
			addChild( _logo );
			
			_title = new Label();
			_title.touchable = false;
			_title.text = _("Encore plus d'avantages ?");
			addChild(_title);
			_title.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(GlobalConfig.isPhone ? 40 : 44), Theme.COLOR_DARK_GREY, false, false, null, null, null, TextFormatAlign.CENTER);
			
			_message = new Label();
			_message.touchable = false;
			_message.text = _("Validez votre compte en cliquant sur le lien présent dans le mail de confirmation d'inscription que vous allez recevoir.");
			addChild(_message);
			_message.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(GlobalConfig.isPhone ? 32 : 38), Theme.COLOR_LIGHT_GREY, false, false, null, null, null, TextFormatAlign.CENTER);
			
			_validateButton = new Button();
			_validateButton.label = _("Continuer");
			_validateButton.addEventListener(Event.TRIGGERED, onValidate);
			addChild( _validateButton );
			
			// Track registration
			if( GAnalytics.isSupported() )
				GAnalytics.analytics.defaultTracker.trackEvent("Inscription", "Inscription", null, NaN, MemberManager.getInstance().getId());
			
			// Track registration
			try
			{
				//MobileAppTracker.instance.trackAction("registration");
			} 
			catch(error:Error) 
			{
				
			}
			
			Flox.logWarning("Nouvelle inscription du membre : (" + MemberManager.getInstance().getId() + ")");
			Flox.logEvent("Inscriptions", { Type:"Normale" });
		}
		
		override protected function draw():void
		{
			if( isInvalid(INVALIDATION_FLAG_SIZE) )
			{
				if( AbstractGameInfo.LANDSCAPE )
				{
					_logo.visible = false;
					_logo.y = 0;
					_logo.height = 0;
					
					//FIXME Faire un validate sur le message après avoir mis le width, car sinonl e height est pas bon !!!! à modifier sur les autres écrans aussi
					_validateButton.width = actualWidth * (GlobalConfig.isPhone ? 0.8 : 0.6);
					_title.width = _message.width = actualWidth * (GlobalConfig.isPhone ? 0.8 : 0.8);
					_message.validate();
					_title.validate();
					_validateButton.validate();
					_validateButton.x = (actualWidth - (actualWidth * (GlobalConfig.isPhone ? 0.8 : 0.6))) * 0.5;
					_message.x = _title.x = (actualWidth - (actualWidth * (GlobalConfig.isPhone ? 0.8 : 0.8))) * 0.5;
					_title.y = (_logo.y + _logo.height) + ( ((actualHeight - _logo.x - _logo.height) - (_message.height + _title.height + _validateButton.height + scaleAndRoundToDpi(GlobalConfig.isPhone ? 60 : 100))) * 0.5) << 0;
					
					_message.y = _title.y + _title.height + scaleAndRoundToDpi(GlobalConfig.isPhone ? 30 : 50);
					_validateButton.y = _message.y + _message.height + scaleAndRoundToDpi(GlobalConfig.isPhone ? 30 : 50);
				}
				else
				{
					_logo.width = actualWidth * (GlobalConfig.isPhone ? 0.65 : 0.75);
					_logo.validate();
					_logo.y = scaleAndRoundToDpi( GlobalConfig.isPhone ? 15 : 30 );
					_logo.x = ((actualWidth - _logo.width) * 0.5) << 0;
					
					//FIXME Faire un validate sur le message après avoir mis le width, car sinonl e height est pas bon !!!! à modifier sur les autres écrans aussi
					_validateButton.width = actualWidth * (GlobalConfig.isPhone ? 0.8 : 0.6);
					_title.width = _message.width = actualWidth * (GlobalConfig.isPhone ? 0.8 : 0.8);
					_message.validate();
					_title.validate();
					_validateButton.validate();
					_validateButton.x = (actualWidth - (actualWidth * (GlobalConfig.isPhone ? 0.8 : 0.6))) * 0.5;
					_message.x = _title.x = (actualWidth - (actualWidth * (GlobalConfig.isPhone ? 0.8 : 0.8))) * 0.5;
					_title.y = (_logo.y + _logo.height) + ( ((actualHeight - _logo.x - _logo.height) - (_message.height + _title.height + _validateButton.height + scaleAndRoundToDpi(GlobalConfig.isPhone ? 60 : 100))) * 0.5) << 0;
					
					_message.y = _title.y + _title.height + scaleAndRoundToDpi(GlobalConfig.isPhone ? 30 : 50);
					_validateButton.y = _message.y + _message.height + scaleAndRoundToDpi(GlobalConfig.isPhone ? 30 : 50);
				}
			}
			
			super.draw();
		}
		
		override public function onBack():void
		{
			this.advancedOwner.showScreen( ScreenIds.HOME_SCREEN );
		}
		
//------------------------------------------------------------------------------------------------------------
//	Handlers
		
		/**
		 * Validate.
		 */		
		private function onValidate(event:Event):void
		{
			onBack();
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
		
		override public function dispose():void
		{
			_logo.removeFromParent(true);
			_logo = null;
			
			_title.removeFromParent(true);
			_title = null;
			
			_message.removeFromParent(true);
			_message = null;
			
			_validateButton.removeEventListener(Event.TRIGGERED, onValidate);
			_validateButton.removeFromParent(true);
			_validateButton = null;
			
			super.dispose();
		}
	}
}