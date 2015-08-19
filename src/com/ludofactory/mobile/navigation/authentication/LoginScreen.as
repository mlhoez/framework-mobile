/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 7 Juin 2013
*/
package com.ludofactory.mobile.navigation.authentication
{
	import com.freshplanet.nativeExtensions.AirNetworkInfo;
	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.common.utils.Utilities;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractGameInfo;
	import com.ludofactory.mobile.core.controls.AdvancedScreen;
	import com.ludofactory.mobile.core.ScreenIds;
	import com.ludofactory.mobile.core.manager.InfoContent;
	import com.ludofactory.mobile.core.manager.InfoManager;
	import com.ludofactory.mobile.core.manager.NavigationManager;
	import com.ludofactory.mobile.core.remoting.Remote;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import flash.text.ReturnKeyLabel;
	import flash.text.SoftKeyboardType;
	import flash.text.TextFormat;
	
	import feathers.controls.Button;
	import feathers.controls.ImageLoader;
	import feathers.controls.LayoutGroup;
	import feathers.controls.TextInput;
	import feathers.events.FeathersEventType;
	import feathers.layout.VerticalLayout;
	
	import starling.core.Starling;
	
	import starling.events.Event;
	import starling.events.TouchEvent;
	
	/**
	 * This is the screen displayed when the user needs to log in the application.
	 * From here, he can log in, retreive his password or register a new account.
	 */	
	public class LoginScreen extends AdvancedScreen
	{
		/**
		 * The logo */		
		private var _logo:ImageLoader;
		
		/**
		 * TextInputs container */		
		private var _textInputsContainer:LayoutGroup;
		
		/**
		 * The mail input */		
		private var _mailInput:TextInput;
		
		/**
		 * The password input */		
		private var _passwordInput:TextInput;
		
		/**
		 * Validate button */		
		private var _validateButton:Button;
		
		/**
		 * Retreive password label link */		
		private var _retreivePasswordLink:Button;
		
		public function LoginScreen()
		{
			super();
			
			_whiteBackground = true;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			_headerTitle = _("Connexion");
			
			_logo = new ImageLoader();
			_logo.source = Theme.ludokadoLogoTexture;
			_logo.textureScale = GlobalConfig.dpiScale;
			_logo.snapToPixels = true;
			_logo.touchable = false;
			addChild( _logo );
			
			_textInputsContainer = new LayoutGroup();
			_textInputsContainer.layout = new VerticalLayout();
			addChild( _textInputsContainer );
			
			_mailInput = new TextInput();
			_mailInput.styleName = Theme.TEXTINPUT_FIRST;
			_mailInput.prompt = _("Email...");
			_mailInput.textEditorProperties.returnKeyLabel = ReturnKeyLabel.NEXT;
			_mailInput.textEditorProperties.softKeyboardType = SoftKeyboardType.EMAIL;
			_mailInput.addEventListener(FeathersEventType.ENTER, onEnterKeyPressed);
			_textInputsContainer.addChild(_mailInput);
			
			_passwordInput = new TextInput();
			_passwordInput.styleName = Theme.TEXTINPUT_LAST;
			_passwordInput.prompt = _("Mot de passe...");
			_passwordInput.textEditorProperties.displayAsPassword = true;
			_passwordInput.textEditorProperties.returnKeyLabel = ReturnKeyLabel.GO;
			_passwordInput.addEventListener(FeathersEventType.ENTER, onEnterKeyPressed);
			_textInputsContainer.addChild(_passwordInput);
			
			_retreivePasswordLink = new Button();
			_retreivePasswordLink.label = _("J'ai oublié mon mot de passe...");
			_retreivePasswordLink.styleName = Theme.BUTTON_EMPTY;
			_retreivePasswordLink.addEventListener(Event.TRIGGERED, onForgotPasswordTouched);
			addChild(_retreivePasswordLink);
			_retreivePasswordLink.minHeight = _retreivePasswordLink.minTouchHeight = scaleAndRoundToDpi(60);
			_retreivePasswordLink.defaultLabelProperties.textFormat = new TextFormat(Theme.FONT_ARIAL, scaleAndRoundToDpi(24), Theme.COLOR_DARK_GREY, true, true);
			
			_validateButton = new Button();
			_validateButton.label = _("Confirmer");
			_validateButton.addEventListener(Event.TRIGGERED, onValidate);
			addChild( _validateButton );
		}
		
		override protected function draw():void
		{
			if( isInvalid(INVALIDATION_FLAG_SIZE) )
			{
				super.draw();
				
				if( AbstractGameInfo.LANDSCAPE )
				{
					_logo.visible = false;
					_logo.y = 0;
					_logo.height = 0;
					
					_textInputsContainer.validate();
					_retreivePasswordLink.validate();
					_validateButton.validate();
					
					_textInputsContainer.width = _mailInput.width = _passwordInput.width = _validateButton.width = actualWidth * (GlobalConfig.isPhone ? 0.8 : 0.6);
					_textInputsContainer.x = _retreivePasswordLink.x = _validateButton.x = (actualWidth - (actualWidth * (GlobalConfig.isPhone ? 0.8 : 0.6))) * 0.5;
					_retreivePasswordLink.x = _textInputsContainer.x;
					_textInputsContainer.y = (_logo.y + _logo.height) + scaleAndRoundToDpi(GlobalConfig.isPhone ? 10 : 20) + ( ((actualHeight - _logo.y - _logo.height) - (_textInputsContainer.height + _retreivePasswordLink.height + _validateButton.height + scaleAndRoundToDpi(GlobalConfig.isPhone ? 20 : 40))) * 0.5) << 0;
					
					_retreivePasswordLink.y = _textInputsContainer.y + _textInputsContainer.height + scaleAndRoundToDpi(GlobalConfig.isPhone ? 10 : 20);
					_validateButton.y = _retreivePasswordLink.y + _retreivePasswordLink.height + scaleAndRoundToDpi(GlobalConfig.isPhone ? 10 : 20);
				}
				else
				{
					_logo.width = actualWidth * (GlobalConfig.isPhone ? 0.65 : 0.75);
					_logo.validate();
					_logo.y = scaleAndRoundToDpi( GlobalConfig.isPhone ? 15 : 30 );
					_logo.x = ((actualWidth - _logo.width) * 0.5) << 0;
					
					_textInputsContainer.validate();
					_retreivePasswordLink.validate();
					_validateButton.validate();
					
					_textInputsContainer.width = _mailInput.width = _passwordInput.width = _validateButton.width = actualWidth * (GlobalConfig.isPhone ? 0.8 : 0.6);
					_textInputsContainer.x = _retreivePasswordLink.x = _validateButton.x = (actualWidth - (actualWidth * (GlobalConfig.isPhone ? 0.8 : 0.6))) * 0.5;
					_retreivePasswordLink.x = _textInputsContainer.x;
					_textInputsContainer.y = (_logo.y + _logo.height) + scaleAndRoundToDpi(GlobalConfig.isPhone ? 10 : 20) + ( ((actualHeight - _logo.y - _logo.height) - (_textInputsContainer.height + _retreivePasswordLink.height + _validateButton.height + scaleAndRoundToDpi(GlobalConfig.isPhone ? 30 : 60))) * 0.5) << 0;
					
					_retreivePasswordLink.y = _textInputsContainer.y + _textInputsContainer.height + scaleAndRoundToDpi(GlobalConfig.isPhone ? 10 : 20);
					_validateButton.y = _retreivePasswordLink.y + _retreivePasswordLink.height + scaleAndRoundToDpi(GlobalConfig.isPhone ? 10 : 20);
				}
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Validation
		
		/**
		 * The user touched the "Enter" / "Next" key, so we validate the form or simply go to
		 * the next input depending on the current input.
		 */		
		private function onEnterKeyPressed(event:Event):void
		{
			if( event.target == _mailInput )
				_passwordInput.setFocus();
			else
				onValidate();
		}
		
		/**
		 * Validate form.
		 */		
		private function onValidate(event:Event = null):void
		{
			if(_mailInput.text == "" || (!Utilities.isValidMail(_mailInput.text) && !CONFIG::DEBUG))
			{
				InfoManager.showTimed( _("Email invalide."), InfoManager.DEFAULT_DISPLAY_TIME, InfoContent.ICON_CROSS );
				Starling.current.nativeStage.focus = null;
				return;
			}
			
			if(_passwordInput.text == "")
			{
				InfoManager.showTimed( _("Mot de passe invalide."), InfoManager.DEFAULT_DISPLAY_TIME, InfoContent.ICON_CROSS );
				Starling.current.nativeStage.focus = null;
				return;
			}
			
			if( AirNetworkInfo.networkInfo.isConnected() )
			{
				this.isEnabled = false;
				InfoManager.show(_("Chargement..."));
				_mailInput.clearFocus();
				_passwordInput.clearFocus();
				Starling.current.nativeStage.focus = null;
				Remote.getInstance().logIn(_mailInput.text, _passwordInput.text, onLoginSuccess, onLoginFailure, onLoginFailure, 2, advancedOwner.activeScreenID);
			}
			else
			{
				InfoManager.showTimed(_("Aucune connexion Internet."), InfoManager.DEFAULT_DISPLAY_TIME, InfoContent.ICON_CROSS);
			}
		}
		
		/**
		 * On login success.
		 */		
		private function onLoginSuccess(result:Object):void
		{
			if( result.code == 4 ) // wrong login or password
			{
				this.isEnabled = true;
				InfoManager.hide(result.txt, InfoContent.ICON_CROSS, InfoManager.DEFAULT_DISPLAY_TIME);
				return;
			}
			else if( result.code == 6 ) // pseudo not completed
			{
				InfoManager.hide("", InfoContent.ICON_CHECK, 0);
				this.advancedOwner.screenData.defaultPseudo = result.pseudo_defaut;
				// we don't need te define a previous screen because in the pseudo selection screen
				// the user cannot go back for obious reason
				this.advancedOwner.showScreen( ScreenIds.PSEUDO_CHOICE_SCREEN );
				return;
			}
			
			NavigationManager.resetNavigation(false);
			InfoManager.hide(result.txt, InfoContent.ICON_CHECK, InfoManager.DEFAULT_DISPLAY_TIME, this.advancedOwner.showScreen, [ /*this.advancedOwner.screenData.completeScreenId*/ ScreenIds.HOME_SCREEN ]);
		}
		
		/**
		 * On login failure.
		 */		
		private function onLoginFailure(error:Object = null):void
		{
			this.isEnabled = true;
			InfoManager.hide(_("Une erreur est survenue, veuillez réessayer."), InfoContent.ICON_CROSS, InfoManager.DEFAULT_DISPLAY_TIME);
		}
		
		/**
		 * The user touched the "not subscribed yet" link. He is redirected
		 * the the RegisterScreen.
		 */		
		private function onRegister(event:Event):void
		{
			this.advancedOwner.showScreen( ScreenIds.REGISTER_SCREEN );
		}
		
		/**
		 * The user touched the "forgot password" link. He is redirected
		 * to the ForgotPasswordScreen so that he can retreive it.
		 */		
		private function onForgotPasswordTouched(event:Event):void
		{
			this.advancedOwner.showScreen( ScreenIds.FORGOT_PASSWORD_SCREEN );
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
		
		override public function dispose():void
		{
			_logo.removeFromParent(true);
			_logo = null;
			
			_mailInput.removeEventListener(FeathersEventType.ENTER, onEnterKeyPressed);
			_mailInput.removeFromParent(true);
			_mailInput = null;
			
			_passwordInput.removeEventListener(FeathersEventType.ENTER, onEnterKeyPressed);
			_passwordInput.removeFromParent(true);
			_passwordInput = null;
			
			_textInputsContainer.removeFromParent(true);
			_textInputsContainer = null;
			
			_validateButton.removeEventListener(Event.TRIGGERED, onValidate);
			_validateButton.removeFromParent(true);
			_validateButton = null;
			
			_retreivePasswordLink.removeEventListener(TouchEvent.TOUCH, onForgotPasswordTouched);
			_retreivePasswordLink.removeFromParent(true);
			_retreivePasswordLink = null;
			
			super.dispose();
		}
		
	}
}