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
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.AbstractGameInfo;
	import com.ludofactory.mobile.core.controls.AdvancedScreen;
	import com.ludofactory.mobile.core.model.ScreenIds;
	import com.ludofactory.mobile.core.manager.InfoContent;
	import com.ludofactory.mobile.core.manager.InfoManager;
	import com.ludofactory.mobile.core.remoting.Remote;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import flash.text.ReturnKeyLabel;
	import flash.text.SoftKeyboardType;
	
	import feathers.controls.Button;
	import feathers.controls.ImageLoader;
	import feathers.controls.ScrollContainer;
	import feathers.controls.Scroller;
	import feathers.controls.TextInput;
	import feathers.events.FeathersEventType;
	import feathers.layout.VerticalLayout;
	
	import starling.core.Starling;
	
	import starling.events.Event;
	
	/**
	 * This is the screen where the user can register a new account.
	 */	
	public class RegisterScreen extends AdvancedScreen
	{
		/**
		 * The logo */		
		private var _logo:ImageLoader;
		
		/**
		 * TextInputs container with no gap */		
		private var _textInputsContainer:ScrollContainer;
		
		/**
		 * The mail input */		
		private var _mailInput:TextInput;
		
		/**
		 * The password input */		
		private var _passwordInput:TextInput;
		
		/**
		 * The sponsor input */		
		private var _sponsorInput:TextInput;
		
		/**
		 * Validate button */		
		private var _validateButton:Button;
		
		public function RegisterScreen()
		{
			super();
			
			_whiteBackground = true;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			_headerTitle = _("Inscription");
			
			_logo = new ImageLoader();
			_logo.source = Theme.ludokadoLogoTexture;
			_logo.textureScale = GlobalConfig.dpiScale;
			_logo.snapToPixels = true;
			_logo.touchable = false;
			addChild( _logo );
			
			_textInputsContainer = new ScrollContainer();
			_textInputsContainer.layout = new VerticalLayout();
			_textInputsContainer.verticalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			_textInputsContainer.horizontalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
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
			_passwordInput.textEditorProperties.returnKeyLabel = ReturnKeyLabel.NEXT;
			_passwordInput.addEventListener(FeathersEventType.ENTER, onEnterKeyPressed);
			_textInputsContainer.addChild(_passwordInput);
			
			_sponsorInput = new TextInput();
			_sponsorInput.prompt = _("Code parrain... (facultatif)");
			_sponsorInput.textEditorProperties.returnKeyLabel = ReturnKeyLabel.GO;
			_sponsorInput.textEditorProperties.restrict = "0-9";
			_sponsorInput.textEditorProperties.softKeyboardType = SoftKeyboardType.NUMBER;
			_sponsorInput.addEventListener(FeathersEventType.ENTER, onEnterKeyPressed);
			addChild(_sponsorInput);
			
			_validateButton = new Button();
			_validateButton.label = _("Confirmer");
			_validateButton.addEventListener(Event.TRIGGERED, onValidate);
			addChild( _validateButton );
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
					
					_textInputsContainer.validate();
					_sponsorInput.validate();
					_validateButton.validate();
					
					_textInputsContainer.width = _mailInput.width = _passwordInput.width = _sponsorInput.width = _validateButton.width = actualWidth * (GlobalConfig.isPhone ? 0.8 : 0.6);
					_textInputsContainer.x = _sponsorInput.x = _validateButton.x = (actualWidth - (actualWidth * (GlobalConfig.isPhone ? 0.8 : 0.6))) * 0.5;
					_textInputsContainer.y = (_logo.y + _logo.height) + scaleAndRoundToDpi(GlobalConfig.isPhone ? 10 : 20) + ( ((actualHeight - _logo.y - _logo.height) - (_textInputsContainer.height + _sponsorInput.height + _validateButton.height + scaleAndRoundToDpi(GlobalConfig.isPhone ? 40 : 80))) * 0.5) << 0;
					
					_sponsorInput.y = _textInputsContainer.y + _textInputsContainer.height + scaleAndRoundToDpi(GlobalConfig.isPhone ? 20 : 40);
					_validateButton.y = _sponsorInput.y + _sponsorInput.height + scaleAndRoundToDpi(GlobalConfig.isPhone ? 20 : 40);
				}
				else
				{
					_logo.width = actualWidth * (GlobalConfig.isPhone ? 0.65 : 0.75);
					_logo.validate();
					_logo.y = scaleAndRoundToDpi( GlobalConfig.isPhone ? 15 : 30 );
					_logo.x = ((actualWidth - _logo.width) * 0.5) << 0;
					
					_textInputsContainer.validate();
					_sponsorInput.validate();
					_validateButton.validate();
					
					_textInputsContainer.width = _mailInput.width = _passwordInput.width = _sponsorInput.width = _validateButton.width = actualWidth * (GlobalConfig.isPhone ? 0.8 : 0.6);
					_textInputsContainer.x = _sponsorInput.x = _validateButton.x = (actualWidth - (actualWidth * (GlobalConfig.isPhone ? 0.8 : 0.6))) * 0.5;
					_textInputsContainer.y = (_logo.y + _logo.height) + scaleAndRoundToDpi(GlobalConfig.isPhone ? 10 : 20) + ( ((actualHeight - _logo.y - _logo.height) - (_textInputsContainer.height + _sponsorInput.height + _validateButton.height + scaleAndRoundToDpi(GlobalConfig.isPhone ? 50 : 100))) * 0.5) << 0;
					
					_sponsorInput.y = _textInputsContainer.y + _textInputsContainer.height + scaleAndRoundToDpi(GlobalConfig.isPhone ? 20 : 40);
					_validateButton.y = _sponsorInput.y + _sponsorInput.height + scaleAndRoundToDpi(GlobalConfig.isPhone ? 20 : 40);
				}
			}
			
			super.draw();
		}
		
//------------------------------------------------------------------------------------------------------------
//	Handlers
		
		/**
		 * The user touched the "Enter" / "Next" key, so we validate the form or simply go to
		 * the next input depending on the current input.
		 */		
		private function onEnterKeyPressed(event:Event):void
		{
			switch(event.currentTarget)
			{
				case _mailInput:
				{
					_passwordInput.setFocus();
					break;
				}
				case _passwordInput:
				{
					_sponsorInput.setFocus();
					break;
				}
				case _sponsorInput:
				{
					onValidate();
					break;
				}
			}
		}
		
		/**
		 * Validates the subscription.
		 */		
		private function onValidate(event:Event = null):void
		{
			if( _mailInput.text == "" || !Utilities.isValidMail(_mailInput.text) )
			{
				InfoManager.showTimed( _("Email invalide."), InfoManager.DEFAULT_DISPLAY_TIME, InfoContent.ICON_CROSS );
				Starling.current.nativeStage.focus = null;
				return;
			}
			
			if( _passwordInput.text == "" )
			{
				InfoManager.showTimed( _("Le mot de passe ne peut être vide."), InfoManager.DEFAULT_DISPLAY_TIME, InfoContent.ICON_CROSS );
				Starling.current.nativeStage.focus = null;
				return;
			}
			
			if( AirNetworkInfo.networkInfo.isConnected() )
			{
				this.isEnabled = false;
				
				InfoManager.show(_("Chargement..."));
				
				_mailInput.clearFocus();
				_passwordInput.clearFocus();
				_sponsorInput.clearFocus();
				
				Starling.current.nativeStage.focus = null;
				
				// if _data.tempFacebookData is defined, it means that the user tried to register
				// via Facebook but no mail could be retreived, thus we need to complete the object
				// with the data got from the form
				this.advancedOwner.screenData.tempFacebookData = this.advancedOwner.screenData.tempFacebookData ? this.advancedOwner.screenData.tempFacebookData:{};
				this.advancedOwner.screenData.tempFacebookData.mail = _mailInput.text;
				this.advancedOwner.screenData.tempFacebookData.mdp = _passwordInput.text;
				this.advancedOwner.screenData.tempFacebookData.id_parrain = _sponsorInput.text == "" ? "0":_sponsorInput.text;
				this.advancedOwner.screenData.tempFacebookData.type_inscription = RegisterType.STANDARD;
				
				Remote.getInstance().registerUser(this.advancedOwner.screenData.tempFacebookData, onSubscriptionSuccess, onSubscriptionFailure, onSubscriptionFailure, 2, advancedOwner.activeScreenID);
			}
			else
			{
				InfoManager.showTimed(_("Aucune connexion Internet."), InfoManager.DEFAULT_DISPLAY_TIME, InfoContent.ICON_CROSS);
			}
		}
		
		/**
		 * The subscription is complete. This function handles all the different cases for a
		 * subscription, whether it is by Facebook or not.
		 */		
		private function onSubscriptionSuccess(result:Object):void
		{
			switch(result.code)
			{
				case 0: // Invalid entry data
				case 2: // Missing required field
				case 3: // Account already exists
				case 4: // Insert error
				case 5: // Invalid mail
				{
					this.isEnabled = true;
					InfoManager.hide(result.txt, InfoContent.ICON_CROSS, InfoManager.DEFAULT_DISPLAY_TIME);
					break;
				}
				case 1:
				{
					// The account have been successfully created with the standard process, now we
					// go to the pseudo choice screen with the default pseudo returned.
					this.advancedOwner.screenData.defaultPseudo = result.pseudo_defaut;
					InfoManager.hide(result.txt, InfoContent.ICON_CHECK, InfoManager.DEFAULT_DISPLAY_TIME, this.advancedOwner.showScreen, [ ScreenIds.PSEUDO_CHOICE_SCREEN ]);
					break;
				}
				case 6:
				{
					// The user have successfully logged in with his Facebook account
					InfoManager.hide(result.txt, InfoContent.ICON_CHECK, InfoManager.DEFAULT_DISPLAY_TIME, this.advancedOwner.showScreen, [ ScreenIds.HOME_SCREEN ] );
					break;
				}
				case 7: 
				{
					// The user have successfully logged in with his Facebook account but the pseudo field
					// is missing, thus we redirect the user to the pseudo choice screen
					this.advancedOwner.screenData.defaultPseudo = result.pseudo_defaut;
					InfoManager.hide(result.txt, InfoContent.ICON_CHECK, InfoManager.DEFAULT_DISPLAY_TIME, this.advancedOwner.showScreen, [ ScreenIds.PSEUDO_CHOICE_SCREEN ]);
					break;
				}
				case 9:
				{
					// The user have successfully created an account with his Facebook data.
					// in this case, we need to redirect him to the sponsor screen, and then the
					// pseudo choice screen
					this.advancedOwner.screenData.defaultPseudo = result.pseudo_defaut;
					InfoManager.hide(result.txt, InfoContent.ICON_CHECK, InfoManager.DEFAULT_DISPLAY_TIME, this.advancedOwner.showScreen, [ ScreenIds.SPONSOR_REGISTER_SCREEN ]);
					break;
				}
				case 10:
				{
					// This case should never happen since all the checks are done in the application
					// If this happens, we simply display an error message
					onSubscriptionFailure();
					break;
				}
				case 11:
				{
					// The user have successfully logged in
					InfoManager.hide(result.txt, InfoContent.ICON_CHECK, InfoManager.DEFAULT_DISPLAY_TIME, this.advancedOwner.showScreen, [ ScreenIds.HOME_SCREEN ] );
					break;
				}
				case 12:
				{
					// The account have been successfully created with the standard process, now we
					// go to the pseudo choice screen with the default pseudo returned.
					this.advancedOwner.screenData.defaultPseudo = result.pseudo_defaut;
					InfoManager.hide(result.txt, InfoContent.ICON_CHECK, InfoManager.DEFAULT_DISPLAY_TIME, this.advancedOwner.showScreen, [ ScreenIds.PSEUDO_CHOICE_SCREEN ]);
					break;
				}
					
				default:
				{
					onSubscriptionFailure();
					break;
				}
			}
		}
		
		/**
		 * There was an error executing the Amfphp request.
		 */		
		private function onSubscriptionFailure(error:Object = null):void
		{
			this.isEnabled = true;
			InfoManager.hide(_("Une erreur est survenue, veuillez réessayer."), InfoContent.ICON_CROSS);
		}
		
		/**
		 * The user touched the "I already have an account" link. He is redirected
		 * the the LoginScreen.
		 */		
		private function onLogIn(event:Event):void
		{
			this.advancedOwner.showScreen( ScreenIds.LOGIN_SCREEN );
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
		
		override public function dispose():void
		{
			AbstractEntryPoint.screenNavigator.screenData.tempFacebookData = {};
			
			_logo.removeFromParent(true);
			_logo = null;
			
			_mailInput.removeEventListener(FeathersEventType.ENTER, onEnterKeyPressed);
			_mailInput.removeFromParent(true);
			_mailInput = null;
			
			_passwordInput.removeEventListener(FeathersEventType.ENTER, onEnterKeyPressed);
			_passwordInput.removeFromParent(true);
			_passwordInput = null;
			
			_sponsorInput.removeEventListener(FeathersEventType.ENTER, onEnterKeyPressed);
			_sponsorInput.removeFromParent(true);
			_sponsorInput = null;
			
			_textInputsContainer.removeFromParent(true);
			_textInputsContainer = null;
			
			_validateButton.removeEventListener(Event.TRIGGERED, onValidate);
			_validateButton.removeFromParent(true);
			_validateButton = null;
			
			super.dispose();
		}
		
	}
}