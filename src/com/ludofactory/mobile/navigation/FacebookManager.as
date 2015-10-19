/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 30 janv. 2014
*/
package com.ludofactory.mobile.navigation
{
	
	import com.freshplanet.nativeExtensions.AirNetworkInfo;
	import com.ludofactory.common.gettext.LanguageManager;
	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.common.utils.log;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.AbstractGameInfo;
	import com.ludofactory.mobile.core.manager.InfoContent;
	import com.ludofactory.mobile.core.manager.InfoManager;
	import com.ludofactory.mobile.core.manager.MemberManager;
	import com.ludofactory.mobile.core.model.ScreenIds;
	import com.ludofactory.mobile.core.remoting.Remote;
	import com.ludofactory.mobile.navigation.authentication.RegisterType;
	import com.milkmangames.nativeextensions.GVFacebookFriend;
	import com.milkmangames.nativeextensions.GoViral;
	import com.milkmangames.nativeextensions.events.GVFacebookEvent;
	
	import starling.events.EventDispatcher;
	
	/**
	 * FacebookManager
	 * 
	 * Il est possible de récupérer le photo de profile de cette façon :
	 * https://graph.facebook.com/100003577159732/picture?type=[small|normal|large|square]
	 */	
	public class FacebookManager extends EventDispatcher
	{
		/**
		 * Singleton instance. */
		private static var _instance:FacebookManager;
		
		/**
		 * Registering mode. */		
		private static const MODE_REGISTER:String = "register"; 
		/**
		 * Associating mode. */		
		private static const MODE_ASSOCIATING:String = "associating";
		/**
		 * Publishing mode. */		
		private static const MODE_PUBLISHING:String = "publishing";
		/**
		 * Get token. */
		private static const MODE_TOKEN:String = "token";
		
		/**
		 * Current mode (see above). */
		private static var _mode:String;
		
		public function FacebookManager(sk:SecurityKey)
		{
			if(sk == null)
				throw new Error("Erreur : Echec de l'instanciation : Utiliser FacebookManager.getInstance() au lieu de new.");
		}
		
		/**
		 * Checks if the Facebook token is still valid, if so, we don't need to do anything special, otherwise,
		 * we authenticate the user to retrieve a new one.
		 */
		public function checkTokenValidity():void
		{
			if( AirNetworkInfo.networkInfo.isConnected() )
			{
				if( GoViral.isSupported() && GoViral.goViral.isFacebookSupported() )
				{
					if( MemberManager.getInstance().isLoggedIn() && MemberManager.getInstance().facebookId != 0 ) // just in case but usually this test is done before in the screen
					{
						var now:Date = new Date();
						var tokenExpiryDate:Date = new Date( MemberManager.getInstance().getFacebookTokenExpiryTimestamp() );
						if( now < tokenExpiryDate )
						{
							// the token is still valid, then we don't need to do something special
							requestMe();
						}
						else
						{
							// the token has expired, we need to authenticate again
							authenticate();
						}
					}
					else
					{
						// not logged in or no Facebook account associated
						authenticate();
					}
				}
				else
				{
					// Facebook is not supported on this plateform
					InfoManager.showTimed(_("Facebook n'est pas supporté sur cet appareil."), InfoManager.DEFAULT_DISPLAY_TIME, InfoContent.ICON_CROSS);
				}
			}
			else
			{
				InfoManager.showTimed(_("Aucune connexion Internet."), InfoManager.DEFAULT_DISPLAY_TIME, InfoContent.ICON_CROSS);
			}
		}
		
		/**
		 * Use this funtion when we want to publish a news on the user's wall.
		 * 
		 * <p>If the user is not connected to Internet or if Facebook is not supported on the device, we first return
		 * an error.</p>
		 * 
		 * <p>If everything is ok, we check if the user have already associated his account with Facebook, if yes, we
		 * check if the current Facebook session is the good one (by checking the user's Facebook id and the one returned
		 * by the current Facebook session), otherwise, we ask the user to log in and on ce the account is associated,
		 * we launch the publication.</p>
		 */		
		public function associateForPublish():void
		{
			if( MemberManager.getInstance().facebookId != 0 )
			{
				// this account is associated to a Facebook account, in this case we need to authenticate with
				// Facebook and then check if the Facebook id matches the user's. If there is a match, then we
				// can directly publish the stream on the user's wall, otherwise, we need to tell the user that
				// the current Facebook session is not the good one.
				_mode = MODE_PUBLISHING;
			}
			else
			{
				// this account is not associated to a Facebook account, in this case we need to associate the
				// current Facebook session to this account, and then launch the publication.
				_mode = MODE_ASSOCIATING;
			}
			checkTokenValidity();
		}
		
		/**
		 * Association function.
		 */		
		public function associate():void
		{
			_mode = MODE_ASSOCIATING;
			checkTokenValidity();
		}
		
		/**
		 * Register or connect the user with Facebook.
		 */		
		public function register():void
		{
			_mode = MODE_REGISTER;
			checkTokenValidity();
		}
		
		/**
		 * Register or connect the user with Facebook.
		 */
		public function getToken():void
		{
			_mode = MODE_TOKEN;
			checkTokenValidity();
		}
		
//------------------------------------------------------------------------------------------------------------
//	Common authentication
		
		/**
		 * Authenticate the user with Facebook.
		 */		
		private function authenticate():void
		{
			InfoManager.show(_("Chargement..."));
			
			if( GoViral.goViral.isFacebookAuthenticated() )
			{
				// the user is already authenticated (so we already have a token stored in the application),
				// then we directly request his profile.
				requestMe();
			}
			else
			{
				// the user is not authenticated, then we need to log in with Facebook before in order to get a token,
				// and then request his profile
				GoViral.goViral.addEventListener(GVFacebookEvent.FB_LOGGED_IN, requestMe);
				GoViral.goViral.addEventListener(GVFacebookEvent.FB_LOGIN_CANCELED, onAuthenticationCancelledOrFailed);
				GoViral.goViral.addEventListener(GVFacebookEvent.FB_LOGIN_FAILED, onAuthenticationCancelledOrFailed);
				GoViral.goViral.authenticateWithFacebook( AbstractGameInfo.FACEBOOK_PERMISSIONS );
			}
		}
		
		/**
		 * Authentication was cancelled or failed.
		 */		
		private function onAuthenticationCancelledOrFailed(event:GVFacebookEvent):void
		{
			GoViral.goViral.removeEventListener(GVFacebookEvent.FB_LOGGED_IN, requestMe);
			GoViral.goViral.removeEventListener(GVFacebookEvent.FB_LOGIN_CANCELED, onAuthenticationCancelledOrFailed);
			GoViral.goViral.removeEventListener(GVFacebookEvent.FB_LOGIN_FAILED, onAuthenticationCancelledOrFailed);
			InfoManager.hide(event.errorMessage, InfoContent.ICON_CROSS, 3);
		}
		
		/**
		 * Request the user profile.
		 */		
		private function requestMe(event:GVFacebookEvent = null):void
		{
			GoViral.goViral.removeEventListener(GVFacebookEvent.FB_LOGGED_IN, requestMe);
			GoViral.goViral.removeEventListener(GVFacebookEvent.FB_LOGIN_CANCELED, onAuthenticationCancelledOrFailed);
			GoViral.goViral.removeEventListener(GVFacebookEvent.FB_LOGIN_FAILED, onAuthenticationCancelledOrFailed);
			
			GoViral.goViral.addEventListener(GVFacebookEvent.FB_REQUEST_RESPONSE, onMeReturned);
			GoViral.goViral.addEventListener(GVFacebookEvent.FB_REQUEST_FAILED, onRequestFailed);
			GoViral.goViral.requestMyFacebookProfile();
		}
		
		/**
		 * The user's informations have been returned by the Facebook graph api. This function
		 * will try to log in or register this user depending on if he was in the database or not.
		 */		
		private function onMeReturned(event:GVFacebookEvent):void
		{
			if(event.graphPath == "me")
			{
				GoViral.goViral.removeEventListener(GVFacebookEvent.FB_REQUEST_RESPONSE, onMeReturned);
				GoViral.goViral.removeEventListener(GVFacebookEvent.FB_REQUEST_FAILED, onRequestFailed);
				
				// small - normal - large - square
				//https://graph.facebook.com/100003577159732/picture?type=large
				
				var me:GVFacebookFriend = event.friends[0];
				var formattedUserData:Object = {};
				if( me.properties.hasOwnProperty("id") )         formattedUserData.id_facebook = me.properties.id;
				if( me.properties.hasOwnProperty("email") )      formattedUserData.mail = me.properties.email;
				if( me.properties.hasOwnProperty("last_name") )  formattedUserData.nom = me.properties.last_name;
				if( me.properties.hasOwnProperty("first_name") ) formattedUserData.prenom = me.properties.first_name;
				if( me.properties.hasOwnProperty("gender") )     formattedUserData.titre = me.properties.gender == "male" ? 1:2;
				if( me.properties.hasOwnProperty("location") )   formattedUserData.ville = me.locationName;
				if( me.properties.hasOwnProperty("birthday") )   formattedUserData.date_naissance = me.properties.birthday;
				formattedUserData.id_parrain = -1;
				formattedUserData.type_inscription = RegisterType.FACEBOOK;
				formattedUserData.langue = LanguageManager.getInstance().lang;
				
				// also update the token and its expiration date here
				MemberManager.getInstance().setFacebookToken(GoViral.goViral.getFbAccessToken());
				MemberManager.getInstance().setFacebookTokenExpiryTimestamp(GoViral.goViral.getFbAccessExpiry());
				
				switch(_mode)
				{
					case MODE_REGISTER:
					{
						// Connect or register the user with Facebook
						if( !formattedUserData.hasOwnProperty("mail") || formattedUserData.mail == null || formattedUserData.mail == "" )
						{
							AbstractEntryPoint.screenNavigator.screenData.tempFacebookData = formattedUserData;
							InfoManager.hide(_("Nous n'avons pas pu récupéré votre email via Facebook. Merci de compléter l'inscription normalement."), InfoContent.ICON_CROSS, InfoManager.DEFAULT_DISPLAY_TIME, AbstractEntryPoint.screenNavigator.showScreen, [ ScreenIds.REGISTER_SCREEN ]);
							return;
						}
						
						// we got all we want, we can connect the user or create an account
						Remote.getInstance().registerUserViaFacebook(formattedUserData, onFacebookAuthenticationSuccess, onFacebookAuthenticationFailure, onFacebookAuthenticationFailure, 1, AbstractEntryPoint.screenNavigator.activeScreenID);
						
						break;
					}
					case MODE_ASSOCIATING:
					{
						// we got a Facebook session, now we can try to associate this account
						Remote.getInstance().associateAccount(MemberManager.getInstance().id, formattedUserData.id_facebook, formattedUserData.mail, formattedUserData.prenom, formattedUserData.nom, formattedUserData.ville, formattedUserData.date_naissance, formattedUserData.titre, onFacebookAssociationSuccess, onFacebookAssociationFailure, onFacebookAssociationFailure, 1, AbstractEntryPoint.screenNavigator.activeScreenID);
						
						break;
					}
					case MODE_PUBLISHING:
					{
						// we don't need to check if me.properties.id equals to MemberManager.getInstance().getFacebookId()
						// because we don't care if the associated Facebook account matches the current session on the phone
						// we only want the user to publish
						InfoManager.hide("", InfoContent.ICON_NOTHING, 0);
						dispatchEventWith(FacebookManagerEventType.AUTHENTICATED_OR_ASSOCIATED, false, formattedUserData);
						
						break;
					}
					case MODE_TOKEN:
					{
						// we don't need to check if me.properties.id equals to MemberManager.getInstance().getFacebookId()
						// because we don't care if the associated Facebook account matches the current session on the phone
						// we only want a token here to finish all the actions
						InfoManager.hide("", InfoContent.ICON_NOTHING, 0);
						dispatchEventWith(FacebookManagerEventType.AUTHENTICATED_OR_ASSOCIATED);
						
						break;
					}
				}
			}
		}
		
		/**
		 * The <code>requestMyFacebookProfile</code> have failed.
		 * 
		 * <p>We could not retrieve the data from Facebook so we need
		 * to clear the Facebook session for security reason.</p>
		 */		
		private function onRequestFailed(event:GVFacebookEvent):void
		{
			GoViral.goViral.removeEventListener(GVFacebookEvent.FB_REQUEST_RESPONSE, onMeReturned);
			GoViral.goViral.removeEventListener(GVFacebookEvent.FB_REQUEST_FAILED, onRequestFailed);
			
			// clear the token for security reason
			GoViral.goViral.logoutFacebook();
			
			InfoManager.hide(event.errorMessage, InfoContent.ICON_CROSS, 3);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Association callbacks
		
		/**
		 * The Amfphp request is complete. This function will check if the user could be
		 * logged in or registered in the database.
		 */		
		private function onFacebookAssociationSuccess(result:Object):void
		{
			switch(result.code)
			{
				case 1:
				{
					// The user have successfully logged in with his Facebook account, then we dispatch
					// an event in order to update the associate button (becoming a publish button or
					// whatever).
					
					// association success
					
					InfoManager.hide(result.txt, InfoContent.ICON_CHECK, 3);
					dispatchEventWith(FacebookManagerEventType.AUTHENTICATED_OR_ASSOCIATED);
					break;
				}
					
				default:
				{
					onFacebookAssociationFailure(result);
					break;
				}
			}
		}
		
		/**
		 * There was an error executing the Amfphp request.
		 */		
		private function onFacebookAssociationFailure(error:Object = null):void
		{
			InfoManager.hide(error ? error.txt : _("Une erreur est survenue, veuillez réessayer."), InfoContent.ICON_CROSS, 4);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Registration callbacks
		
		/**
		 * The Amfphp request is complete. This function will check if the user could be
		 * logged in or registered in the database.
		 */		
		private function onFacebookAuthenticationSuccess(result:Object):void
		{
			switch(result.code)
			{
				case 0:  // Invalid entry data
				case 1:  // 
				case 2:  // Missing required field
				case 3:  // Account already exists
				case 4:  // Insert error
				case 5:  // Invalid mail or password
				case 10: // impossible de creer compte avec fb car pas autoriser a récuperer les informations persos.
				case 11: // inscription standard compte existant mdp correspond LOGIN OK PSEUDO OK
				case 12: // inscription standard compte existant email mdp OK LOGIN OK PSEUDO PAS OK
				{ 
					InfoManager.hide(result.txt, InfoContent.ICON_CHECK, 4);
					break;
				}
				case 6:
				{
					// The user have successfully logged in with his Facebook account
					InfoManager.hide(result.txt, InfoContent.ICON_CHECK, InfoManager.DEFAULT_DISPLAY_TIME, AbstractEntryPoint.screenNavigator.showScreen, [ ScreenIds.HIGH_SCORE_LIST_SCREEN ] );
					dispatchEventWith(FacebookManagerEventType.AUTHENTICATED_OR_ASSOCIATED);
					break;
				}
				case 7:
				{
					// The user have successfully logged in with his Facebook account but the pseudo field
					// is missing, thus we redirect the user to the pseudo choice screen
					AbstractEntryPoint.screenNavigator.screenData.defaultPseudo = result.pseudo_defaut;
					InfoManager.hide(result.txt, InfoContent.ICON_CHECK, InfoManager.DEFAULT_DISPLAY_TIME, AbstractEntryPoint.screenNavigator.showScreen, [ ScreenIds.PSEUDO_CHOICE_SCREEN ]);
					break;
				}
				case 9:
				{
					// The user have successfully created an account with his Facebook data.
					// in this case, we need to redirect him to the sponsor screen, and then the
					// pseudo choice screen
					AbstractEntryPoint.screenNavigator.screenData.defaultPseudo = result.pseudo_defaut;
					InfoManager.hide(result.txt, InfoContent.ICON_CHECK, InfoManager.DEFAULT_DISPLAY_TIME, AbstractEntryPoint.screenNavigator.showScreen, [ ScreenIds.SPONSOR_REGISTER_SCREEN ]);
					break;
				}
				
				default:
				{
					onFacebookAuthenticationFailure();
					break;
				}
			}
		}
		
		/**
		 * There was an error executing the Amfphp request.
		 */		
		private function onFacebookAuthenticationFailure(error:Object = null):void
		{
			InfoManager.hide(_("Une erreur est survenue, veuillez réessayer."), InfoContent.ICON_CROSS);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Permissions
		
		/**
		 * Requests a new Facebook permission
		 * 
		 * @param newPermission Name of the new permission to request.
		 */
		public function requestNewReadPermission(newPermission:String):void
		{
			log("[FacebookManager] Requesting new permission : " + newPermission);
			if(GoViral.goViral.isFacebookPermissionGranted(newPermission))
			{
				// already granted
				dispatchEventWith(FacebookManagerEventType.PERMISSION_GRANTED);
			}
			else
			{
				// request the new permission
				GoViral.goViral.addEventListener(GVFacebookEvent.FB_READ_PERMISSIONS_UPDATED, onPermissionGranted);
				GoViral.goViral.addEventListener(GVFacebookEvent.FB_READ_PERMISSIONS_FAILED, onPermissionNotGranted);
				GoViral.goViral.requestNewFacebookReadPermissions(newPermission);
			}
		}
		
		/**
		 * Then ew permission have been granted.
		 */
		private function onPermissionGranted(event:GVFacebookEvent):void
		{
			log("[FacebookManager] Permission granted.");
			GoViral.goViral.removeEventListener(GVFacebookEvent.FB_READ_PERMISSIONS_UPDATED, onPermissionGranted);
			GoViral.goViral.removeEventListener(GVFacebookEvent.FB_READ_PERMISSIONS_FAILED, onPermissionNotGranted);
			dispatchEventWith(FacebookManagerEventType.PERMISSION_GRANTED);
		}
		
		private function onPermissionNotGranted(event:GVFacebookEvent):void
		{
			log("[FacebookManager] Permission NOT granted.");
			GoViral.goViral.removeEventListener(GVFacebookEvent.FB_READ_PERMISSIONS_UPDATED, onPermissionGranted);
			GoViral.goViral.removeEventListener(GVFacebookEvent.FB_READ_PERMISSIONS_FAILED, onPermissionNotGranted);
			dispatchEventWith(FacebookManagerEventType.PERMISSION_NOT_GRANTED);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
		
		public function dispose():void
		{
			try
			{
				if( GoViral.isSupported() && GoViral.goViral.isFacebookSupported() )
				{
					GoViral.goViral.removeEventListener(GVFacebookEvent.FB_LOGGED_IN, requestMe);
					GoViral.goViral.removeEventListener(GVFacebookEvent.FB_LOGIN_CANCELED, onAuthenticationCancelledOrFailed);
					GoViral.goViral.removeEventListener(GVFacebookEvent.FB_LOGIN_FAILED, onAuthenticationCancelledOrFailed);
					GoViral.goViral.removeEventListener(GVFacebookEvent.FB_REQUEST_RESPONSE, onMeReturned);
					GoViral.goViral.removeEventListener(GVFacebookEvent.FB_REQUEST_FAILED, onRequestFailed);
				}
			} 
			catch(error:Error) 
			{
				
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Singleton
		
		public static function getInstance():FacebookManager
		{
			if(_instance == null)
				_instance = new FacebookManager(new SecurityKey());
			return _instance;
		}
		
	}
}

internal class SecurityKey{}