/*
Copyright © 2006-2014 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 24 juil. 2013
*/
package com.ludofactory.mobile.core.authentication
{
	import com.freshplanet.nativeExtensions.AirNetworkInfo;
	import com.ludofactory.common.utils.Utilities;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.Localizer;
	import com.ludofactory.mobile.core.controls.AdvancedScreen;
	import com.ludofactory.mobile.core.controls.ScreenIds;
	import com.ludofactory.mobile.core.manager.InfoContent;
	import com.ludofactory.mobile.core.manager.InfoManager;
	import com.ludofactory.mobile.core.remoting.Remote;
	import com.ludofactory.mobile.core.test.config.GlobalConfig;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import flash.text.ReturnKeyLabel;
	import flash.text.SoftKeyboardType;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import feathers.controls.Button;
	import feathers.controls.ImageLoader;
	import feathers.controls.Label;
	import feathers.controls.TextInput;
	import feathers.events.FeathersEventType;
	
	import starling.events.Event;
	
	/**
	 * This is the screen displayed when the user needs to retreive his password.
	 * He is asked to fill in his account email so that we can send the credentials.
	 */	
	public class ForgotPasswordScreen extends AdvancedScreen
	{
		/**
		 * The logo */		
		private var _logo:ImageLoader;
		
		/**
		 * The message */		
		private var _message:Label;
		
		/**
		 * The mail input */		
		private var _mailInput:TextInput;
		
		/**
		 * Validate button */		
		private var _validateButton:Button;
		
		public function ForgotPasswordScreen()
		{
			super();
			
			_whiteBackground = true;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			_headerTitle = Localizer.getInstance().translate("FORGOT_PASSWORD.HEADER_TITLE");
			
			_logo = new ImageLoader();
			_logo.source = Theme.ludokadoLogoTexture;
			_logo.textureScale = GlobalConfig.dpiScale;
			_logo.snapToPixels = true;
			_logo.touchable = false;
			addChild( _logo );
			
			_message = new Label();
			_message.touchable = false;
			_message.text = Localizer.getInstance().translate("FORGOT_PASSWORD.MESSAGE");
			addChild(_message);
			_message.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(28), Theme.COLOR_DARK_GREY, false, false, null, null, null, TextFormatAlign.CENTER);
			
			_mailInput = new TextInput();
			_mailInput.prompt = Localizer.getInstance().translate("FORGOT_PASSWORD.MAIL_INPUT_HINT");
			_mailInput.textEditorProperties.returnKeyLabel = ReturnKeyLabel.GO;
			_mailInput.textEditorProperties.softKeyboardType = SoftKeyboardType.EMAIL;
			_mailInput.addEventListener(FeathersEventType.ENTER, onValidate);
			addChild(_mailInput);
			
			_validateButton = new Button();
			_validateButton.label = Localizer.getInstance().translate("COMMON.VALIDATE");
			_validateButton.addEventListener(Event.TRIGGERED, onValidate);
			addChild( _validateButton );
		}
		
		override protected function draw():void
		{
			super.draw();
			
			if( isInvalid(INVALIDATION_FLAG_SIZE) )
			{
				_logo.width = actualWidth * (GlobalConfig.isPhone ? 0.65 : 0.75);
				_logo.validate();
				_logo.y = scaleAndRoundToDpi( GlobalConfig.isPhone ? 15 : 30 );
				_logo.x = ((actualWidth - _logo.width) * 0.5) << 0;
				
				_message.width = _validateButton.width = _mailInput.width = actualWidth * (GlobalConfig.isPhone ? 0.8 : 0.6);
				_message.validate();
				_validateButton.validate();
				_mailInput.validate();
				_message.x = _validateButton.x = _mailInput.x = (actualWidth - (actualWidth * (GlobalConfig.isPhone ? 0.8 : 0.6))) * 0.5;
				_message.y = (_logo.y + _logo.height) + ( ((actualHeight - _logo.x - _logo.height) - (_message.height + _validateButton.height + _mailInput.height + scaleAndRoundToDpi(GlobalConfig.isPhone ? 40 : 80))) * 0.5) << 0;
				
				_mailInput.y = _message.y + _message.height + scaleAndRoundToDpi(GlobalConfig.isPhone ? 20 : 40);
				_validateButton.y = _mailInput.y + _mailInput.height + scaleAndRoundToDpi(GlobalConfig.isPhone ? 20 : 40);
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Handlers
		
		/**
		 * Validate form.
		 */		
		private function onValidate(event:Event = null):void
		{
			if( _mailInput.text == "" || !Utilities.isValidMail(_mailInput.text) )
			{
				InfoManager.showTimed( Localizer.getInstance().translate("FORGOT_PASSWORD.INVALID_MAIL"), InfoManager.DEFAULT_DISPLAY_TIME, InfoContent.ICON_CROSS );
				return;
			}
			
			if( AirNetworkInfo.networkInfo.isConnected() )
			{
				this.isEnabled = false;
				InfoManager.show(Localizer.getInstance().translate("COMMON.LOADING"));
				_mailInput.clearFocus();
				Remote.getInstance().retreivePassword( _mailInput.text, onRetreivePasswordSuccess, onRetreivePasswordFailure, onRetreivePasswordFailure, 2, advancedOwner.activeScreenID);
			}
			else
			{
				InfoManager.showTimed(Localizer.getInstance().translate("COMMON.NOT_CONNECTED"), InfoManager.DEFAULT_DISPLAY_TIME, InfoContent.ICON_CROSS);
			}
		}
		
		/**
		 * On retreive password success.
		 */		
		private function onRetreivePasswordSuccess(result:Object):void
		{
			switch(result.code)
			{
				case 0:
				case 2:
				case 3:
				{
					this.isEnabled = true;
					InfoManager.hide(result.txt, InfoContent.ICON_CROSS, InfoManager.DEFAULT_DISPLAY_TIME);
					break;
				}
				case 1:
				{
					InfoManager.hide(result.txt, InfoContent.ICON_CHECK, 2, this.advancedOwner.showScreen, [ ScreenIds.AUTHENTICATION_SCREEN ]);
					break;
				}
					
				default:
				{
					onRetreivePasswordFailure();
					break;
				}
			}
		}
		
		/**
		 * On retreive password failure.
		 */		
		private function onRetreivePasswordFailure(error:Object = null):void
		{
			this.isEnabled = true;
			InfoManager.hide(Localizer.getInstance().translate("COMMON.QUERY_FAILURE"), InfoContent.ICON_CROSS, InfoManager.DEFAULT_DISPLAY_TIME);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
		
		override public function dispose():void
		{
			_logo.removeFromParent(true);
			_logo = null;
			
			_message.removeFromParent(true);
			_message = null;
			
			_mailInput.removeEventListener(FeathersEventType.ENTER, onValidate);
			_mailInput.removeFromParent(true);
			_mailInput = null;
			
			_validateButton.removeEventListener(Event.TRIGGERED, onValidate);
			_validateButton.removeFromParent(true);
			_validateButton = null;
			
			super.dispose();
		}
		
	}
}