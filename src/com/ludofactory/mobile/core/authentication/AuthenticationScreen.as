/*
Copyright © 2006-2014 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 12 nov. 2013
*/
package com.ludofactory.mobile.core.authentication
{
	import com.freshplanet.nativeExtensions.AirNetworkInfo;
	import com.ludofactory.common.utils.log;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.AbstractGameInfo;
	import com.ludofactory.mobile.core.Localizer;
	import com.ludofactory.mobile.core.controls.AdvancedScreen;
	import com.ludofactory.mobile.core.controls.ScreenIds;
	import com.ludofactory.mobile.core.manager.InfoContent;
	import com.ludofactory.mobile.core.manager.InfoManager;
	import com.ludofactory.mobile.core.remoting.Remote;
	import com.ludofactory.mobile.core.test.config.GlobalConfig;
	import com.ludofactory.mobile.core.theme.Theme;
	import com.milkmangames.nativeextensions.GVFacebookFriend;
	import com.milkmangames.nativeextensions.GoViral;
	import com.milkmangames.nativeextensions.events.GVFacebookEvent;
	
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import feathers.controls.Button;
	import feathers.controls.ImageLoader;
	import feathers.controls.Label;
	
	import starling.events.Event;
	
	/**
	 * Authentication screen that displays the different options
	 * to authenticate in the application : login, register and
	 * login with Facebook.
	 */	
	public class AuthenticationScreen extends AdvancedScreen
	{
		/**
		 * The Ludokado logo. */		
		private var _logo:ImageLoader;
		
		/**
		 * The title */		
		private var _title:Label;
		
		/**
		 * The login icon */		
		private var _loginIcon:ImageLoader;
		/**
		 * The login button. */		
		private var _loginButton:Button;
		
		/**
		 * The register icon. */		
		private var _registerIcon:ImageLoader;
		/**
		 * The register button. */		
		private var _registerButton:Button;
		
		/**
		 * The Facebook button icon. */		
		private var _facebookIcon:ImageLoader;
		/**
		 * The Facebook authentication button. */		
		private var _facebookButton:Button;
		
		public function AuthenticationScreen()
		{
			super();
			
			_whiteBackground = true;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			_headerTitle = Localizer.getInstance().translate("AUTHENTICATION.HEADER_TITLE");
			
			_logo = new ImageLoader();
			_logo.touchable = false;
			_logo.source = Theme.ludokadoLogoTexture;
			_logo.textureScale = GlobalConfig.dpiScale;
			_logo.snapToPixels = true;
			addChild( _logo );
			
			_title = new Label();
			_title.touchable = false;
			_title.text = Localizer.getInstance().translate("AUTHENTICATION.TITLE");
			addChild(_title);
			_title.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(38), Theme.COLOR_DARK_GREY, false, false, null, null, null, TextFormatAlign.CENTER);
			
			_loginIcon = new ImageLoader();
			_loginIcon.touchable = false;
			_loginIcon.source = AbstractEntryPoint.assets.getTexture("auth-login-icon");
			_loginIcon.scaleX = _loginIcon.scaleY = GlobalConfig.dpiScale;
			_loginIcon.snapToPixels = true;
			
			_loginButton = new Button();
			_loginButton.nameList.add( Theme.BUTTON_TRANSPARENT_BLUE );
			_loginButton.defaultIcon = _loginIcon;
			_loginButton.iconPosition = Button.ICON_POSITION_TOP;
			_loginButton.addEventListener(Event.TRIGGERED, onGoToLoginScreen);
			_loginButton.label = Localizer.getInstance().translate("COMMON.LOGIN");
			addChild(_loginButton);
			
			_registerIcon = new ImageLoader();
			_registerIcon.touchable = false;
			_registerIcon.source = AbstractEntryPoint.assets.getTexture("auth-register-icon");
			_registerIcon.scaleX = _registerIcon.scaleY = GlobalConfig.dpiScale;
			_registerIcon.snapToPixels = true;
			
			_registerButton = new Button();
			_registerButton.nameList.add( Theme.BUTTON_TRANSPARENT_BLUE );
			_registerButton.defaultIcon = _registerIcon;
			_registerButton.iconPosition = Button.ICON_POSITION_TOP;
			_registerButton.addEventListener(Event.TRIGGERED, onGoToRegisterScreen);
			_registerButton.label = Localizer.getInstance().translate("COMMON.REGISTER");
			addChild(_registerButton);
			
			_facebookIcon = new ImageLoader();
			_facebookIcon.touchable = false;
			_facebookIcon.source = AbstractEntryPoint.assets.getTexture( GlobalConfig.isPhone ? "facebook-icon" : "facebook-icon-hd");
			_facebookIcon.textureScale = GlobalConfig.dpiScale;
			_facebookIcon.snapToPixels = true;
			
			_facebookButton = new Button();
			_facebookButton.addEventListener(Event.TRIGGERED, onAuthenticateWithFacebook);
			_facebookButton.defaultIcon = _facebookIcon;
			_facebookButton.label = Localizer.getInstance().translate("COMMON.FACEBOOK");
			addChild(_facebookButton);
			_facebookButton.iconPosition = Button.ICON_POSITION_LEFT;
			_facebookButton.gap = scaleAndRoundToDpi(GlobalConfig.isPhone ? 10 : 20);
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
				
				_loginButton.validate();
				_facebookButton.validate();
				
				_title.width = actualWidth * 0.9;
				_title.validate();
				_title.x = (actualWidth - _title.width) * 0.5;
				_title.y = (_logo.y + _logo.height) + /* scaleAndRoundToDpi(GlobalConfig.isPhone ? 10 : 20) + */ ( ((actualHeight - _logo.x - _logo.height) - (_title.height + _loginButton.height + _facebookButton.height + scaleAndRoundToDpi(GlobalConfig.isPhone ? 50 : 100))) * 0.5) << 0;
				
				_loginButton.width = _registerButton.width = actualWidth * (GlobalConfig.isPhone ? 0.45 : 0.4);
				_loginButton.x = ((actualWidth * 0.5) - (actualWidth * (GlobalConfig.isPhone ? 0.45 : 0.4))) * 0.5;
				_registerButton.x = (actualWidth * 0.5) + _loginButton.x;
				_loginButton.y = _registerButton.y = _title.y + _title.height + scaleAndRoundToDpi(GlobalConfig.isPhone ? 20 : 40);
				_loginButton.validate();
				_registerButton.validate();
				_loginButton.height = _registerButton.height = Math.max(_loginButton.height, _registerButton.height);
				
				_facebookButton.width = actualWidth * (GlobalConfig.isPhone ? 0.8 : 0.6);
				_facebookButton.y = _loginButton.y + _loginButton.height + scaleAndRoundToDpi(GlobalConfig.isPhone ? 20 : 40);
				_facebookButton.x = (actualWidth - _facebookButton.width) * 0.5;
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Handlers
		
		/**
		 * Go to login screen.
		 */		
		private function onGoToLoginScreen(event:Event):void
		{
			advancedOwner.showScreen( ScreenIds.LOGIN_SCREEN );
		}
		
		/**
		 * Go to register screen.
		 */		
		private function onGoToRegisterScreen(event:Event):void
		{
			advancedOwner.showScreen( ScreenIds.REGISTER_SCREEN );
		}
		
		/**
		 * Facebook authentication.
		 */		
		private function onAuthenticateWithFacebook(event:Event):void
		{
			if( AirNetworkInfo.networkInfo.isConnected() )
			{
				if( GoViral.isSupported() && GoViral.goViral.isFacebookSupported() )
				{
					InfoManager.show(Localizer.getInstance().translate("COMMON.LOADING"));
					if( !GoViral.goViral.isFacebookAuthenticated() )
					{
						log("[LoginScreen] User not authenticated with Facebook");
						GoViral.goViral.addEventListener(GVFacebookEvent.FB_LOGGED_IN, requestMe);
						GoViral.goViral.addEventListener(GVFacebookEvent.FB_LOGIN_CANCELED, onAuthenticationCancelled);
						GoViral.goViral.addEventListener(GVFacebookEvent.FB_LOGIN_FAILED, onAuthenticationCancelled);
						GoViral.goViral.authenticateWithFacebook( AbstractGameInfo.FACEBOOK_PERMISSIONS );
					}
					else
					{
						log("[LoginScreen] User already authenticated with Facebook");
						requestMe();
					}
				}
				else
				{
					InfoManager.showTimed(Localizer.getInstance().translate("AUTHENTICATION.FACEBOOK_NOT_SUPPORTED_ERROR"), InfoManager.DEFAULT_DISPLAY_TIME, InfoContent.ICON_CROSS);
				}
			}
			else
			{
				InfoManager.showTimed(Localizer.getInstance().translate("COMMON.NOT_CONNECTED"), InfoManager.DEFAULT_DISPLAY_TIME, InfoContent.ICON_CROSS);
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Facebook Authentication
		
		/**
		 * Authentication was cancelled (whether by touching the back button
		 * within Facebook or by switching back to the application.
		 */		
		private function onAuthenticationCancelled(event:GVFacebookEvent):void
		{
			GoViral.goViral.removeEventListener(GVFacebookEvent.FB_LOGGED_IN, requestMe);
			GoViral.goViral.removeEventListener(GVFacebookEvent.FB_LOGIN_CANCELED, onAuthenticationCancelled);
			GoViral.goViral.removeEventListener(GVFacebookEvent.FB_LOGIN_FAILED, onAuthenticationCancelled);
			
			InfoManager.hide(event.errorMessage, InfoContent.ICON_CROSS, 2);
		}
		
		/**
		 * Request user profile.
		 */		
		private function requestMe(event:GVFacebookEvent = null):void
		{
			GoViral.goViral.removeEventListener(GVFacebookEvent.FB_LOGGED_IN, requestMe);
			GoViral.goViral.removeEventListener(GVFacebookEvent.FB_LOGIN_CANCELED, onAuthenticationCancelled);
			GoViral.goViral.removeEventListener(GVFacebookEvent.FB_LOGIN_FAILED, onAuthenticationCancelled);
			
			GoViral.goViral.addEventListener(GVFacebookEvent.FB_REQUEST_RESPONSE, onFacebookResponse);
			GoViral.goViral.addEventListener(GVFacebookEvent.FB_REQUEST_FAILED, onRequestFailed);
			GoViral.goViral.requestMyFacebookProfile();
		}
		
		/**
		 * The user's profile have been returned by the Facebook graph api.
		 * This function will try to log in or register this user depending
		 * on if he was in the database or not.
		 */		
		private function onFacebookResponse(event:GVFacebookEvent):void
		{
			// the graphPath property is 'me' for a profile request.
			if(event.graphPath == "me")
			{
				var me:GVFacebookFriend = event.friends[0];
				
				var formattedUserData:Object = {};
				if( me.properties.hasOwnProperty("id") )
					formattedUserData.id_facebook = me.properties.id;
				if( me.properties.hasOwnProperty("email") )
					formattedUserData.mail = me.properties.email;
				if( me.properties.hasOwnProperty("last_name") )
					formattedUserData.nom = me.properties.last_name;
				if( me.properties.hasOwnProperty("first_name") )
					formattedUserData.prenom = me.properties.first_name;
				if( me.properties.hasOwnProperty("gender") )
					formattedUserData.titre = me.properties.gender == "male" ? 1:2;
				if( me.properties.hasOwnProperty("location") )
					formattedUserData.ville = me.locationName;
				if( me.properties.hasOwnProperty("birthday") )
					formattedUserData.date_naissance = me.properties.birthday;
				formattedUserData.id_parrain = -1;
				formattedUserData.type_inscription = RegisterType.FACEBOOK;
				formattedUserData.langue = Localizer.getInstance().lang;
				
				GoViral.goViral.removeEventListener(GVFacebookEvent.FB_REQUEST_RESPONSE, onFacebookResponse);
				GoViral.goViral.removeEventListener(GVFacebookEvent.FB_REQUEST_FAILED, onRequestFailed);
				
				if( !formattedUserData.hasOwnProperty("mail") || formattedUserData.mail == null || formattedUserData.mail == "" )
				{
					this.advancedOwner.screenData.tempFacebookData = formattedUserData;
					InfoManager.hide(Localizer.getInstance().translate("AUTHENTICATION.MAIL_NOT_RETURNED_BY_FACEBOOK_ERROR"), InfoContent.ICON_CROSS, InfoManager.DEFAULT_DISPLAY_TIME, this.advancedOwner.showScreen, [ ScreenIds.REGISTER_SCREEN ]);
					return;
				}
				
				//GoViral.goViral.facebookGraphRequest(me.id + "/scores", GVHttpMethod.POST, {score:1245}/*, "publish_actions"*/);
				
				Remote.getInstance().registerUserViaFacebook(formattedUserData, onFacebookAuthenticationSuccess, onFacebookAuthenticationFailure, onFacebookAuthenticationFailure, 2, advancedOwner.activeScreenID);
			}
		}
		
		/**
		 * The user's profile could not be retreived.
		 */		
		private function onRequestFailed(event:GVFacebookEvent):void
		{
			GoViral.goViral.removeEventListener(GVFacebookEvent.FB_REQUEST_RESPONSE, onFacebookResponse);
			GoViral.goViral.removeEventListener(GVFacebookEvent.FB_REQUEST_FAILED, onRequestFailed);
			
			InfoManager.hide(event.errorMessage, InfoContent.ICON_CROSS);
		}
		
		/**
		 * The Amfphp request is complete. This function will check if the user could be
		 * logged in or registered in the database.
		 */		
		private function onFacebookAuthenticationSuccess(result:Object):void
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
					onFacebookAuthenticationFailure(result);
					break;
				}
					
				default:
				{
					onFacebookAuthenticationFailure(result);
					break;
				}
			}
		}
		
		/**
		 * There was an error executing the request.
		 */		
		private function onFacebookAuthenticationFailure(error:Object = null):void
		{
			this.isEnabled = true;
			InfoManager.hide(error ? error.txt : Localizer.getInstance().translate("COMMON.QUERY_FAILURE"), InfoContent.ICON_CROSS);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
		
		override public function dispose():void
		{
			_logo.removeFromParent(true);
			_logo = null;
			
			_title.removeFromParent(true);
			_title = null;
			
			_loginButton.removeEventListener(Event.TRIGGERED, onGoToLoginScreen);
			_loginButton.removeFromParent(true);
			_loginButton = null;
			
			_registerButton.removeEventListener(Event.TRIGGERED, onGoToRegisterScreen);
			_registerButton.removeFromParent(true);
			_registerButton = null;
			
			_facebookButton.removeEventListener(Event.TRIGGERED, onAuthenticateWithFacebook);
			_facebookButton.removeFromParent(true);
			_facebookButton = null;
			
			super.dispose();
		}
		
	}
}