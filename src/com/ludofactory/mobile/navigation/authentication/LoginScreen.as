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
	import com.ludofactory.common.utils.roundUp;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.ButtonFactory;
	import com.ludofactory.mobile.FacebookButton;
	import com.ludofactory.mobile.MobileButton;
	import com.ludofactory.mobile.core.AbstractGameInfo;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.controls.AdvancedScreen;
	import com.ludofactory.mobile.core.controls.ArrowGroup;
	import com.ludofactory.mobile.core.manager.InfoContent;
	import com.ludofactory.mobile.core.manager.InfoManager;
	import com.ludofactory.mobile.core.manager.NavigationManager;
	import com.ludofactory.mobile.core.model.ScreenData;
	import com.ludofactory.mobile.core.model.ScreenIds;
	import com.ludofactory.mobile.core.notification.CustomPopupManager;
	import com.ludofactory.mobile.core.notification.content.RetrievePasswordNotificationContent;
	import com.ludofactory.mobile.core.remoting.Remote;
	import com.ludofactory.mobile.core.theme.Theme;
	import com.ludofactory.mobile.navigation.FacebookManagerEventType;
	
	import feathers.controls.LayoutGroup;
	import feathers.controls.TextInput;
	import feathers.events.FeathersEventType;
	import feathers.layout.VerticalLayout;
	
	import flash.text.ReturnKeyLabel;
	import flash.text.SoftKeyboardType;
	
	import starling.core.Starling;
	import starling.events.Event;
	import starling.events.TouchEvent;
	import starling.text.TextField;
	import starling.text.TextFieldAutoSize;
	import starling.text.TextFormat;
	
	/**
	 * This is the screen displayed when the user needs to log in the application.
	 * From here, he can log in, retreive his password or register a new account.
	 */	
	public class LoginScreen extends AdvancedScreen
	{
		/**
		 * Facebook connect button. */
		private var _facebookButton:FacebookButton;
		/**
		 * Warning message displayed below the Facebook button. */
		private var _warningLabel:TextField;
		
		/**
		 * The mail input */		
		private var _mailInput:TextInput;
		/**
		 * The password input */		
		private var _passwordInput:TextInput;
		/**
		 * TextInputs container */
		private var _textInputsContainer:LayoutGroup;
		
		/**
		 * Validate button */		
		private var _validateButton:MobileButton;
		
		/**
		 * Retreive password label link */		
		private var _retreivePasswordLink:ArrowGroup;
		/**
		 * Link for new members */
		private var _newMemberLabel:ArrowGroup;
		/**
		 * Separator. */
		private var _orContainer:OrContainer;
		
		public function LoginScreen()
		{
			super();
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			//_headerTitle = _("Connexion");
			
			_textInputsContainer = new LayoutGroup();
			_textInputsContainer.layout = new VerticalLayout();
			addChild( _textInputsContainer );
			
			_facebookButton = ButtonFactory.getFacebookButton(_("Facebook"), ButtonFactory.FACEBOOK_TYPE_CONNECT);
			_facebookButton.addEventListener(FacebookManagerEventType.AUTHENTICATED, onFacebookAuthenticated);
			addChild(_facebookButton);
			
			_warningLabel = new TextField(5, 5, _("Nous ne publierons jamais sur votre mur sans votre accord"), new TextFormat(Theme.FONT_ARIAL, scaleAndRoundToDpi(25), 0x6d6d6d));
			_warningLabel.autoSize = TextFieldAutoSize.VERTICAL;
			addChild(_warningLabel);
			
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
			
			_retreivePasswordLink = new ArrowGroup(_("Mot de passe oublié"));
			_retreivePasswordLink.addEventListener(Event.TRIGGERED, onForgotPasswordTouched);
			addChild(_retreivePasswordLink);
			
			_validateButton = ButtonFactory.getButton(_("Confirmer"), ButtonFactory.YELLOW);
			_validateButton.addEventListener(Event.TRIGGERED, onValidate);
			addChild( _validateButton );
			
			_newMemberLabel = new ArrowGroup(_("Nouveau joueur ? Créez un compte"));
			_newMemberLabel.addEventListener(Event.TRIGGERED, onRegister);
			addChild(_newMemberLabel);
			
			_orContainer = new OrContainer();
			addChild(_orContainer);
		}
		
		override protected function draw():void
		{
			if( isInvalid(INVALIDATION_FLAG_SIZE) )
			{
				if( AbstractGameInfo.LANDSCAPE )
				{
					_textInputsContainer.validate();
					
					_newMemberLabel.x = roundUp((actualWidth - _newMemberLabel.width) * 0.5);
					_retreivePasswordLink.x = roundUp((actualWidth - _retreivePasswordLink.width) * 0.5);
					_retreivePasswordLink.y = actualHeight - _retreivePasswordLink.height - scaleAndRoundToDpi(5);
					_newMemberLabel.y = _retreivePasswordLink.y - _newMemberLabel.height;
					
					_textInputsContainer.width = _mailInput.width = _passwordInput.width = _validateButton.width = actualWidth * (GlobalConfig.isPhone ? 0.4 : 0.4);
					_textInputsContainer.x = _validateButton.x = actualWidth * 0.5 + actualWidth * (GlobalConfig.isPhone ? 0.05 : 0.05);
					_textInputsContainer.y = scaleAndRoundToDpi(GlobalConfig.isPhone ? 10 : 20) + ( (_newMemberLabel.y - (_textInputsContainer.height + _validateButton.height + scaleAndRoundToDpi(GlobalConfig.isPhone ? 40 : 80))) * 0.5) << 0;
					
					_validateButton.y = _textInputsContainer.y + _textInputsContainer.height + scaleAndRoundToDpi(GlobalConfig.isPhone ? 20 : 40);
					
					_orContainer.validate();
					_orContainer.y = _textInputsContainer.y;
					_orContainer.x = roundUp((actualWidth - _orContainer.width) * 0.5);
					_orContainer.height = (_validateButton.y + _validateButton.height) - _orContainer.y;
					
					_facebookButton.width = _warningLabel.width = actualWidth * (GlobalConfig.isPhone ? 0.425 : 0.425);
					_facebookButton.height += scaleAndRoundToDpi(GlobalConfig.isPhone ? 0 : 10);
					_facebookButton.y = roundUp((_newMemberLabel.y - _facebookButton.height - _warningLabel.height - scaleAndRoundToDpi(5)) * 0.5);
					_warningLabel.y = _facebookButton.y + _facebookButton.height + scaleAndRoundToDpi(5);
					_facebookButton.x = _warningLabel.x = actualWidth * (GlobalConfig.isPhone ? 0.0375 : 0.0375);
				}
				else
				{
					_textInputsContainer.validate();
					
					_textInputsContainer.width = _mailInput.width = _passwordInput.width = _validateButton.width = actualWidth * (GlobalConfig.isPhone ? 0.8 : 0.6);
					_textInputsContainer.x = _retreivePasswordLink.x = _validateButton.x = (actualWidth - (actualWidth * (GlobalConfig.isPhone ? 0.8 : 0.6))) * 0.5;
					_retreivePasswordLink.x = _textInputsContainer.x;
					_textInputsContainer.y = scaleAndRoundToDpi(GlobalConfig.isPhone ? 10 : 20) + ( ((actualHeight) - (_textInputsContainer.height + _retreivePasswordLink.height + _validateButton.height + scaleAndRoundToDpi(GlobalConfig.isPhone ? 30 : 60))) * 0.5) << 0;
					
					_retreivePasswordLink.y = _textInputsContainer.y + _textInputsContainer.height + scaleAndRoundToDpi(GlobalConfig.isPhone ? 10 : 20);
					_validateButton.y = _retreivePasswordLink.y + _retreivePasswordLink.height + scaleAndRoundToDpi(GlobalConfig.isPhone ? 10 : 20);
				}
			}
			
			super.draw();
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
			
			NavigationManager.resetNavigation(false);
			InfoManager.hide(result.txt, InfoContent.ICON_CHECK, InfoManager.DEFAULT_DISPLAY_TIME, this.advancedOwner.replaceScreen, [ ScreenIds.HOME_SCREEN ]);
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
			this.advancedOwner.replaceScreen( ScreenIds.REGISTER_SCREEN );
		}
		
		/**
		 * The user touched the "forgot password" link. He is redirected
		 * to the ForgotPasswordScreen so that he can retreive it.
		 */		
		private function onForgotPasswordTouched(event:Event):void
		{
			CustomPopupManager.addPopup( new RetrievePasswordNotificationContent() );
		}
		
		/**
		 * Facebook authentication.
		 */
		private function onFacebookAuthenticated(event:Event):void
		{
			if(event.data)
				advancedOwner.replaceScreen(ScreenIds.HOME_SCREEN);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
		
		override public function dispose():void
		{
			ScreenData.getInstance().tempFacebookData = {};
			
			_facebookButton.removeEventListener(FacebookManagerEventType.AUTHENTICATED, onFacebookAuthenticated);
			_facebookButton.removeFromParent(true);
			_facebookButton = null;
			
			_warningLabel.removeFromParent(true);
			_warningLabel = null;
			
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
			
			_newMemberLabel.removeEventListener(Event.TRIGGERED, onRegister);
			_newMemberLabel.removeFromParent(true);
			_newMemberLabel = null;
			
			_orContainer.removeFromParent(true);
			_orContainer = null;
			
			super.dispose();
		}
		
	}
}