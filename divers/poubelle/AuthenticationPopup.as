package com.ludofactory.mobile.authentication
{
	/*_________________________________________________________________________________________
	|
	| Auteur      : Maxime Lhoez
	| Création    : 18 avril 2013
	| Description : Authentication popup.
	|				This popup must be called everytime the player wants to access a restricted
	|				area such as the CustomerServiceScreen. This provides the ability to sign in
	|				and sign up for a really easy process.
	|
	|				Cette classe n'est plus utilisée !!!!!!!!!
	|________________________________________________________________________________________*/
	
	import com.freshplanet.ane.AirFacebook.Facebook;
	import com.freshplanet.nativeExtensions.AirNetworkInfo;
	import com.greensock.TweenMax;
	import com.ludofactory.mobile.core.manager.AlertManager;
	import com.ludofactory.mobile.core.Localizer;
	import com.ludofactory.mobile.core.membership.MemberManager;
	import com.ludofactory.mobile.utils.PivotUtils;
	import com.ludofactory.mobile.utils.Utility;
	import com.ludofactory.mobile.utils.log;
	
	import flash.text.ReturnKeyLabel;
	import flash.text.SoftKeyboardType;
	
	import app.MetalWorksMobileTheme;
	import app.AppEntryPoint;
	import app.config.Config;
	import app.remoting.Remote;
	
	import feathers.controls.Button;
	import feathers.controls.ImageLoader;
	import feathers.controls.Label;
	import feathers.controls.ScrollContainer;
	import feathers.controls.Scroller;
	import feathers.controls.TextInput;
	import feathers.core.FeathersControl;
	import feathers.events.FeathersEventType;
	import feathers.layout.HorizontalLayout;
	import feathers.layout.VerticalLayout;
	import feathers.system.DeviceCapabilities;
	
	import starling.core.Starling;
	import starling.display.Button;
	import starling.events.Event;
	
	public class AuthenticationPopup extends FeathersControl
	{
		private static const LOGIN_STATE:String    = "login";
		private static const REGISTER_STATE:String = "register";
		private var _state:String;
		
		/**
		 * Form container */		
		private var _formContainer:ScrollContainer;
		
		/**
		 * Title */		
		private var _title:Label;
		
		/**
		 * Form mail input */		
		private var _mailInput:TextInput;
		
		/**
		 * Passwords container */		
		private var _passwordsContainer:ScrollContainer;
		
		/**
		 * Form password input */		
		private var _passwordInput:TextInput;
		
		/**
		 * Form password confirm input */		
		private var _confirmPasswordInput:TextInput;
		
		/**
		 * Buttons container */		
		private var _buttonsContainer:ScrollContainer;
		
		/**
		 * Facebook button */		
		private var _facebookButton:feathers.controls.Button;
		
		/**
		 * Facebook icon */		
		private var _facebookIcon:ImageLoader;
		
		/**
		 * Validate button */		
		private var _validateButton:feathers.controls.Button;
		
		/**
		 * Switch button */		
		private var _switchButton:feathers.controls.Button;
		
		/**
		 * Switch label */		
		private var _switchLabel:Label;
		
		/**
		 * Close button */		
		private var _closeButton:starling.display.Button;
		
		/**
		 * The screen to redirect after authentication */		
		private var _redirectScreen:String = "";
		
		public function AuthenticationPopup(redirectScreenName:String)
		{
			super();
			
			_redirectScreen = redirectScreenName;
			this.actualWidth = GlobalConfig.stageWidth;
			this.actualHeight = GlobalConfig.stageHeight;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			const vLayout:VerticalLayout = new VerticalLayout();
			vLayout.gap = Config.PADDING_10 * Config.dpiScale;
			vLayout.padding = Config.PADDING_10 * 2 * Config.dpiScale;
			
			_formContainer = new ScrollContainer();
			_formContainer.nameList.add( MetalWorksMobileTheme.ALTERNATE_SCROLL_CONTAINER_SQUARED );
			_formContainer.horizontalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			_formContainer.verticalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			_formContainer.layout = vLayout;
			addChild(_formContainer);
			
			_title = new Label();
			_title.nameList.add( MetalWorksMobileTheme.LABEL_TITLE_CENTERED );
			_title.touchable = false;
			_title.text = Localizer.getInstance().translate("AUTH.TITLE");
			_formContainer.addChild(_title);
			
			_mailInput = new TextInput();
			_mailInput.prompt = Localizer.getInstance().translate("AUTH.MAIL_HINT");
			_mailInput.textEditorProperties.returnKeyLabel = ReturnKeyLabel.NEXT;
			_mailInput.textEditorProperties.softKeyboardType = SoftKeyboardType.EMAIL;
			_mailInput.addEventListener(FeathersEventType.ENTER, onEnterKeyPressed);
			_formContainer.addChild(_mailInput);
			
			const hLayout:HorizontalLayout = new HorizontalLayout();
			hLayout.gap = Config.PADDING_10 * 2 * Config.dpiScale;
			hLayout.horizontalAlign = HorizontalLayout.HORIZONTAL_ALIGN_CENTER;
			
			_passwordsContainer = new ScrollContainer();
			_passwordsContainer.layout = hLayout;
			_passwordsContainer.horizontalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			_passwordsContainer.verticalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			_formContainer.addChild(_passwordsContainer);
			
			_passwordInput = new TextInput();
			_passwordInput.prompt = Localizer.getInstance().translate("AUTH.PASSWORD_HINT");
			_passwordInput.textEditorProperties.displayAsPassword = true;
			_passwordInput.textEditorProperties.returnKeyLabel = ReturnKeyLabel.DONE;
			_passwordInput.addEventListener(FeathersEventType.ENTER, onEnterKeyPressed);
			_passwordsContainer.addChild(_passwordInput);
			
			_confirmPasswordInput = new TextInput();
			_confirmPasswordInput.prompt = Localizer.getInstance().translate("AUTH.PASSWORD_CONFIRM_HINT");
			_confirmPasswordInput.textEditorProperties.displayAsPassword = true;
			_confirmPasswordInput.textEditorProperties.returnKeyLabel = ReturnKeyLabel.GO;
			_confirmPasswordInput.addEventListener(FeathersEventType.ENTER, onEnterKeyPressed);
			_passwordsContainer.addChild(_confirmPasswordInput);
			
			_buttonsContainer = new ScrollContainer();
			_buttonsContainer.layout = hLayout;
			_formContainer.addChild(_buttonsContainer);
			
			_facebookIcon = new ImageLoader();
			_facebookIcon.source = AbstractEntryPoint.assets.getTexture("FacebookIcon");
			_facebookIcon.snapToPixels = true;
			_facebookIcon.textureScale = Config.dpiScale;
			
			_facebookButton = new feathers.controls.Button();
			_facebookButton.label = Localizer.getInstance().translate("AUTH.FACEBOOK_CONNECT");
			_facebookButton.defaultIcon = _facebookIcon;
			_facebookButton.addEventListener(Event.TRIGGERED, onLoginWithFacebook);
			_buttonsContainer.addChild(_facebookButton);
			
			_validateButton = new feathers.controls.Button();
			_validateButton.label = Localizer.getInstance().translate("AUTH.VALIDATE");
			_validateButton.addEventListener(Event.TRIGGERED, onValidate);
			_buttonsContainer.addChild(_validateButton);
			
			_switchButton = new feathers.controls.Button();
			_switchButton.label = Localizer.getInstance().translate("AUTH.SUBSCRIBE");
			_switchButton.addEventListener(Event.TRIGGERED, onButtonTouched);
			addChild(_switchButton);
			
			_switchLabel = new Label();
			_switchLabel.nameList.add( MetalWorksMobileTheme.LABEL_RIGHT );
			_switchLabel.text = Localizer.getInstance().translate("AUTH.NOT_A_MEMBER");
			addChild(_switchLabel);
			
			_closeButton = new starling.display.Button( AbstractEntryPoint.assets.getTexture("CloseButton") );
			_closeButton.scaleX = _closeButton.scaleY = Config.dpiScale;
			_closeButton.addEventListener(Event.TRIGGERED, onClose);
			PivotUtils.setCenterAndMiddle( _closeButton );
			addChild(_closeButton);
		}
		
		override protected function draw():void
		{
			super.draw();
			
			if( DeviceCapabilities.isTablet(Starling.current.nativeStage) )
			{
				_formContainer.width = this.actualWidth * 0.6;
			}
			else
			{
				_formContainer.width = this.actualWidth - (Config.PADDING_10 * 8 * Config.dpiScale);
			}
			
			_formContainer.validate();
			_formContainer.x = _formContainer.x = (this.actualWidth - _formContainer.width) * 0.5;
			_formContainer.y = _closeButton.y = _formContainer.y = (this.actualHeight - _formContainer.height) * 0.35;
			
			_closeButton.x = _formContainer.x + _formContainer.width;
			
			_passwordInput.width = _title.width = _passwordsContainer.width = _buttonsContainer.width = _mailInput.width = _formContainer.width - ((_formContainer.layout as VerticalLayout).padding * 2);
			_validateButton.width = _facebookButton.width = (_passwordsContainer.width - (_passwordsContainer.layout as HorizontalLayout).gap ) * 0.5;
			_confirmPasswordInput.width = 0;
			
			_switchButton.validate();
			_switchLabel.validate();
			
			_switchButton.height *= 0.75;
			_switchButton.x = _formContainer.x + _formContainer.width - _switchButton.width;
			_switchButton.y = _switchLabel.y = _formContainer.y + _formContainer.height + (Config.PADDING_10 * 2 * Config.dpiScale);
			_switchButton.width = _switchButton.width; // to avoid resizing by itself
			_switchLabel.x = _formContainer.x;
			_switchLabel.width = _formContainer.width - _switchButton.width - (Config.PADDING_10 * Config.dpiScale);
			
			_state = LOGIN_STATE;
		}
		
//------------------------------------------------------------------------------------------------------------
//	Handlers
//------------------------------------------------------------------------------------------------------------
		
		/**
		 * User touches the Enter / Next key, so we validate the form or simply go to the next input depending
		 * on the current state.
		 */		
		private function onEnterKeyPressed(event:Event):void
		{
			if( event.target == _mailInput )
			{
				_passwordInput.setFocus();
			}
			else if( event.target == _passwordInput )
			{
				if( _state == LOGIN_STATE )
					onValidate();
				else
					_confirmPasswordInput.setFocus();
			}
			else
			{
				onValidate();
			}
		}
		
		/**
		 * Change authentication mode.
		 */		
		private function onButtonTouched(event:Event):void
		{
			if( _state == LOGIN_STATE )
			{
				log("[AuthenticationPopup] Login form displayed");
				
				_switchLabel.text = Localizer.getInstance().translate("AUTH.ALREADY_A_MEMBER");
				_switchButton.label = Localizer.getInstance().translate("AUTH.CONNECT");
				
				_passwordInput.textEditorProperties.returnKeyLabel = ReturnKeyLabel.NEXT;
				
				_confirmPasswordInput.visible = true;
				_confirmPasswordInput.touchable = true;
				
				TweenMax.to(_passwordInput, 0.5, { width:(_passwordsContainer.width - (_passwordsContainer.layout as HorizontalLayout).gap ) * 0.5 } );
				TweenMax.to(_confirmPasswordInput, 0.5, { width:(_passwordsContainer.width - (_passwordsContainer.layout as HorizontalLayout).gap ) * 0.5 } );
				
				_confirmPasswordInput.text = "";
				
				_state = REGISTER_STATE;
			}
			else
			{
				log("[AuthenticationPopup] Register form displayed");
				
				_switchLabel.text = Localizer.getInstance().translate("AUTH.NOT_A_MEMBER"); 
				_switchButton.label = Localizer.getInstance().translate("AUTH.SUBSCRIBE");
				
				_passwordInput.textEditorProperties.returnKeyLabel = ReturnKeyLabel.GO;
				
				_confirmPasswordInput.touchable = false;
				
				TweenMax.to(_passwordInput, 0.5, { width:_passwordsContainer.width } );
				TweenMax.to(_confirmPasswordInput, 0.5, { width:0, onComplete:function():void{ _confirmPasswordInput.visible = false; } } );
				
				_state = LOGIN_STATE;
			}
		}
		
		
		/**
		 * Validate form
		 */		
		private function onValidate(event:Event = null):void
		{
			if(_mailInput.text == "" || !Utility.isValidMail(_mailInput.text))
			{
				AlertManager.showTimed( Localizer.getInstance().translate("AUTH.MAIL_INVALID"), 1, true, false );
				return;
			}
			
			if(_passwordInput.text == "")
			{
				AlertManager.showTimed( Localizer.getInstance().translate("AUTH.PASSWORD_INVALID"), 1, true, false );
				return;
			}
			
			if( _state == REGISTER_STATE )
			{
				if(_confirmPasswordInput.text == "" || _passwordInput.text != _confirmPasswordInput.text)
				{
					AlertManager.showTimed(Localizer.getInstance().translate("AUTH.PASSWORD_MISMATCH"), 1, true, false );
					return;
				}
			}
			
			if( AirNetworkInfo.networkInfo.isConnected() )
			{
				AlertManager.show(Localizer.getInstance().translate("COMMON.LOADING"));
				
				if( _state == LOGIN_STATE )
				{
					log("[AuthenticationPopup] onValidate - login state");
					Remote.getInstance().logIn( _mailInput.text, _passwordInput.text, onLoginSuccess, -1, null, onLoginFailure);
				}
				else
				{
					log("[AuthenticationPopup] onValidate - register state");
					//Remote.getInstance().registerUser( _mailInput.text, _passwordInput.text, onRegisterSuccess, onRegisterFailure);
				}
			}
			else
			{
				AlertManager.showTimed(Localizer.getInstance().translate("COMMON.NOT_CONNECTED"), 1, true, false);
			}
		}
		
		/**
		 * Close the popup.
		 */		
		private function onClose():void
		{
			log("Close form !");
			dispatchEventWith(Event.COMPLETE);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Login normally
//------------------------------------------------------------------------------------------------------------
		
		/**
		 * On login success.
		 */		
		private function onLoginSuccess(result:Object):void
		{
			log("[AuthenticationPopup] onLoginSuccess");
			log(result);
			
			if(result.error)
			{
				AlertManager.hide(Localizer.getInstance().translate("AUTH.WRONG_LOGIN_OR_PASSWORD"), false, 1);
				return;
			}
			
			MemberManager.getInstance().parseData(result.member); // update member data
			AlertManager.hide(Localizer.getInstance().translate("AUTH.CONNECTED"), true, 1);
			dispatchEventWith(Event.COMPLETE, false, _redirectScreen);
		}
		
		/**
		 * On login failure.
		 */		
		private function onLoginFailure(error:Object):void
		{
			log("[AuthenticationPopup] onLoginFailure");
		}
		
//------------------------------------------------------------------------------------------------------------
//	Register
//------------------------------------------------------------------------------------------------------------
		
		/**
		 * On register success.
		 */		
		private function onRegisterSuccess(result:Object):void
		{
			log("[AuthenticationPopup] onRegisterSuccess");
			log(result);
			
			if(result.error)
			{
				switch(result.error_id)
				{
					case -1:
					{
						// member was not created successfuly
						AlertManager.hide(Localizer.getInstance().translate("COMMON.ERROR"), false);
						return;
						break;
					}
					case -2:
					{
						// account already created with this email
						AlertManager.hide(Localizer.getInstance().translate("AUTH.ACCOUNT_ALREADY_EXISTS"), false);
						return;
						break;
					}
				}
			}
			
			MemberManager.getInstance().parseData(result.member); // update member data
			AlertManager.hide(Localizer.getInstance().translate("AUTH.ACCOUNT_CREATED"), true);
			dispatchEventWith(Event.COMPLETE, false, _redirectScreen);
		}
		
		/**
		 * On register failure.
		 */		
		private function onRegisterFailure(error:Object):void
		{
			log("[AuthenticationPopup] onRegisterFailure");
		}
		
//------------------------------------------------------------------------------------------------------------
//	Login with Facebook
//------------------------------------------------------------------------------------------------------------
		
		/**
		 * Login with Facebook.
		 */		
		private function onLoginWithFacebook(event:Event):void
		{
			if( AirNetworkInfo.networkInfo.isConnected() )
			{
				log("[AuthenticationPopup] Login with Facebook");
				AlertManager.show(Localizer.getInstance().translate("COMMON.LOADING"));
				
				Facebook.getInstance().logEnabled = Utility.enableTracer;
				Facebook.getInstance().init( Config.FACEBOOK_APP_ID );
				
				if( Facebook.getInstance().isSessionOpen )
				{
					log("  [AuthenticationPopup] Facebook session already opened, get user informations");
					Facebook.getInstance().requestWithGraphPath("me", null, "GET", onFacebookUserDataReturned);
				}
				else
				{
					log("  [AuthenticationPopup] No Facebook session opened, authenticating");
					Facebook.getInstance().openSessionWithPermissions(Config.USER_PERMISSIONS, subscribeFinished);
				}
			}
			else
			{
				AlertManager.showTimed(Localizer.getInstance().translate("COMMON.NOT_CONNECTED"), 1, true, false);
			}
		}
		
		/**
		 * When the user comes back to the application.
		 * 
		 * @param success If the subscription has finished successfuly or not
		 * @param userCanceled If the user canceled the process
		 * @param error Error message
		 * 
		 */		
		private function subscribeFinished(success:Boolean, userCanceled:Boolean, error:String):void
		{
			if(userCanceled)
			{
				AlertManager.hide(Localizer.getInstance().translate("COMMON.CANCELED"), false);
			}
			else
			{
				if(success)
				{
					Facebook.getInstance().requestWithGraphPath("me", null, "GET", onFacebookUserDataReturned);
				}
				else
				{
					// on desktop, probably because this Facebook ANE is not supported
					AlertManager.hide(Localizer.getInstance().translate("COMMON.CANCELED"), false);
				}
			}
		}
		
		/**
		 * We got all informations successfuly
		 * @param userData The user's data
		 * 
		 */		
		private function onFacebookUserDataReturned(userData:Object):void
		{
			log("[AuthenticationPopup] User data was returned by Facebook :");
			log(userData);
			Remote.getInstance().connectUserWithFacebook(userData, onUserConnectionSuccess, -1, null, onUserConnectionFailure);
		}
		
		/**
		 * User is connected with Facebook.
		 */		
		private function onUserConnectionSuccess(result:Object):void
		{
			if(result.newUser)
			{
				// user has connected with facebook but he didn't have an account yet
				//  Tell the user he have a new account + bonus credited
				log("[AuthenticationPopup] User didn't have an account.");
				
				AlertManager.hide("Vous êtes connecté avec Facebook et un compte a été créé.\nNous vous offrons 5 parties gratuites " + result.userData.name + "!", true); //  [Traduction] 
				
				//  a terminer
				
			}
			else
			{
				// user has connected with facebook and he already had an account
				//  Update user's data
				log("[AuthenticationPopup] User already had an account.");
				
				AlertManager.hide("Vous êtes connecté avec Facebook " + result.userData.name + " !", true); //  [Traduction] 
				
				//  a terminer
				//var member:Member = MemberManager.getInstance().getEncryptedMember();
				//log(member);
			}
		}
		
		/**
		 * User could not connect with Facebook.
		 */		
		private function onUserConnectionFailure():void
		{
			AlertManager.hide("Une erreur est survenue, veuillez réessayer.", false); //  [Traduction] 
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
//------------------------------------------------------------------------------------------------------------
		
		override public function dispose():void
		{
			_closeButton.removeEventListener(Event.TRIGGERED, onClose);
			_closeButton.removeFromParent(true);
			_closeButton = null;
			
			_switchButton.removeEventListener(Event.TRIGGERED, onButtonTouched);
			_switchButton.removeFromParent(true);
			_switchButton = null;
			
			_switchLabel.removeFromParent(true);
			_switchLabel = null;
			
			_facebookIcon.removeFromParent(true);
			_facebookIcon = null;
			
			_facebookButton.removeEventListener(Event.TRIGGERED, onLoginWithFacebook);
			_facebookButton.removeFromParent(true);
			_facebookButton = null;
			
			_validateButton.removeEventListener(Event.TRIGGERED, onValidate);
			_validateButton.removeFromParent(true);
			_validateButton = null;
			
			_buttonsContainer.removeFromParent(true);
			_buttonsContainer = null;
			
			_confirmPasswordInput.removeEventListener(FeathersEventType.ENTER, onEnterKeyPressed);
			_confirmPasswordInput.removeFromParent(true);
			_confirmPasswordInput = null;
			
			_passwordInput.removeEventListener(FeathersEventType.ENTER, onEnterKeyPressed);
			_passwordInput.removeFromParent(true);
			_passwordInput = null;
			
			_passwordsContainer.removeFromParent(true);
			_passwordsContainer = null;
			
			_mailInput.removeEventListener(FeathersEventType.ENTER, onEnterKeyPressed);
			_mailInput.removeFromParent(true);
			_mailInput = null;
			
			_title.removeFromParent(true);
			_title = null;
			
			_formContainer.removeFromParent(true);
			_formContainer = null;
			
			super.dispose();
		}
	}
}