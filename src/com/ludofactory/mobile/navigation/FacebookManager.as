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
		
		private static var _publicationData:FacebookPublicationData;
		
		private static var _sponsorId:String = "-1";
		private static var _isFacebookRewarded:Boolean = false;
		
		private static var _isPublishing:Boolean = false;
		
		public function FacebookManager(sk:SecurityKey)
		{
			if(sk == null)
				throw new Error("Erreur : Echec de l'instanciation : Utiliser FacebookManager.getInstance() au lieu de new.");
		}
		
//------------------------------------------------------------------------------------------------------------
//	Public API
		
		/**
		 * This function must be used whenever we want to authenticate the user within the app.
		 */
		public function connect(isPublishing:Boolean = false):void
		{
			if( AirNetworkInfo.networkInfo.isConnected() )
			{
				if( GoViral.isSupported() && GoViral.goViral.isFacebookSupported() )
				{
					_isPublishing = isPublishing;
					if( MemberManager.getInstance().isLoggedIn() )
					{
						// the user is logged in
						if(MemberManager.getInstance().facebookId != 0)
						{
							// already linked with a Facebook account
							_mode = MODE_TOKEN;
						}
						else
						{
							// not associated with Facebook, then we
							_mode = MODE_ASSOCIATING;
						}
					}
					else
					{
						// not logged in, then we launch a classic Facebook Connect
						_mode = MODE_REGISTER;
					}

					InfoManager.show(_("Chargement..."));

					if( GoViral.goViral.isFacebookAuthenticated() )
					{
						// check if the token is still valid
						var now:Date = new Date();
						var tokenExpiryDate:Date = new Date( MemberManager.getInstance().facebookTokenExpiryTimestamp );
						if( now < tokenExpiryDate )
						{
							// the token is still valid, then we don't need to do something special
							//onMeReturned();
							//requestMe();
							
							if(_publicationData)
								publish();
							
							// else : ne doit pas arriver, ça bug si on me renvoie pas l'id facebook correctement,
							// cardu coup on passe ici, y'a pas de publication et on reste coincé
							// mais sinon il faudrait faire InfoManager.hide et dispatcher l'event ci-dessous
							
							dispatchEventWith(FacebookManagerEventType.AUTHENTICATED, false, true);
						}
						else
						{
							// the token has expired, we need to get a new one
							// the user is already authenticated (so we already have a token stored in the application),
							// then we directly request his profile.
							requestMe();
						}
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
		 * This function is used whenever we want to publish on the user's wall.
		 * 
		 * It will first check the user's state (logged in or not, associated with Facebook or not, etc.).
		 * 
		 * @param publicationData The publication data
		 * @param doConnect The publication data
		 */
		public function publishOnWall(publicationData:FacebookPublicationData, doConnect:Boolean = true):void
		{
			// save the publication data, in case we need to associate or connect the player before
			_publicationData = publicationData;
			// tell the manager we are in public mode
			_mode = MODE_PUBLISHING;
			// then connect / associate or retrieve a token
			if(doConnect) connect();
			else publish();
		}
		
//------------------------------------------------------------------------------------------------------------
//	Common authentication
		
		/**
		 * Authentication was cancelled or failed.
		 */		
		private function onAuthenticationCancelledOrFailed(event:GVFacebookEvent):void
		{
			GoViral.goViral.removeEventListener(GVFacebookEvent.FB_LOGGED_IN, requestMe);
			GoViral.goViral.removeEventListener(GVFacebookEvent.FB_LOGIN_CANCELED, onAuthenticationCancelledOrFailed);
			GoViral.goViral.removeEventListener(GVFacebookEvent.FB_LOGIN_FAILED, onAuthenticationCancelledOrFailed);

			resetData();
			
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
				if( me.properties.hasOwnProperty("id") )         formattedUserData.id_facebook = "" + me.properties.id; // issue with bigint in php if we give a number
				if( me.properties.hasOwnProperty("email") )      formattedUserData.mail = me.properties.email;
				if( me.properties.hasOwnProperty("last_name") )  formattedUserData.nom = me.properties.last_name;
				if( me.properties.hasOwnProperty("first_name") ) formattedUserData.prenom = me.properties.first_name;
				if( me.properties.hasOwnProperty("gender") )     formattedUserData.titre = me.properties.gender == "male" ? 1:2;
				if( me.properties.hasOwnProperty("location") )   formattedUserData.ville = me.locationName;
				if( me.properties.hasOwnProperty("birthday") )   formattedUserData.date_naissance = me.properties.birthday;
				formattedUserData.id_parrain = _sponsorId;
				formattedUserData.isPublishing = (_publicationData || _isPublishing) ? true : false;
				formattedUserData.type_inscription = RegisterType.FACEBOOK;
				formattedUserData.langue = LanguageManager.getInstance().lang;
				 
				switch(_mode)
				{
					case MODE_REGISTER:
					{
						// Connect or register the user with Facebook
						if( !formattedUserData.hasOwnProperty("mail") || formattedUserData.mail == null || formattedUserData.mail == "" )
						{
							AbstractEntryPoint.screenNavigator.screenData.tempFacebookData = formattedUserData;
							InfoManager.hide(_("Nous n'avons pas pu récupérer votre email via Facebook. Merci de compléter l'inscription normalement."), InfoContent.ICON_CROSS, InfoManager.DEFAULT_DISPLAY_TIME, AbstractEntryPoint.screenNavigator.showScreen, [ ScreenIds.REGISTER_SCREEN ]);
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
						
						publish();
						
						break;
					}
					case MODE_TOKEN:
					{
						// we don't need to check if me.properties.id equals to MemberManager.getInstance().getFacebookId()
						// because we don't care if the associated Facebook account matches the current session on the phone
						// we only want a token here to finish all the actions
						InfoManager.hide("", InfoContent.ICON_NOTHING, 0);
						
						if(_publicationData)
							publish();
						
						dispatchEventWith(FacebookManagerEventType.AUTHENTICATED, false, true);
						
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
			
			resetData();
			
			InfoManager.hide(event.errorMessage, InfoContent.ICON_CROSS, 3);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Publish
		
		/**
		 * Publish on Facebook.
		 */
		private function publish():void
		{
			InfoManager.show(_("Chargement..."));
			
			GoViral.goViral.addEventListener(GVFacebookEvent.FB_DIALOG_FINISHED, onPublishOver);
			GoViral.goViral.addEventListener(GVFacebookEvent.FB_DIALOG_FAILED, onPublishCancelledOrFailed);
			GoViral.goViral.addEventListener(GVFacebookEvent.FB_DIALOG_CANCELED, onPublishCancelledOrFailed);
			GoViral.goViral.showFacebookShareDialog( _publicationData.title, _publicationData.caption, _publicationData.description, _publicationData.linkUrl, _publicationData.imageUrl, _publicationData.extraParams);
		}
		
		/**
		 * Publication cancelled or failed.
		 */
		private function onPublishCancelledOrFailed(event:GVFacebookEvent):void
		{
			//Flox.logEvent("Publications Facebook", {Etat:"Annulee"});
			InfoManager.hide(_("Publication annulée"), InfoContent.ICON_CHECK, 4);
			
			resetData();
			
			GoViral.goViral.removeEventListener(GVFacebookEvent.FB_DIALOG_FINISHED, onPublishOver);
			GoViral.goViral.removeEventListener(GVFacebookEvent.FB_DIALOG_FAILED, onPublishCancelledOrFailed);
			GoViral.goViral.removeEventListener(GVFacebookEvent.FB_DIALOG_CANCELED, onPublishCancelledOrFailed);
		}
		
		/**
		 * Publication posted.
		 */
		private function onPublishOver(event:GVFacebookEvent):void
		{
			//Flox.logEvent("Publications Facebook", {Etat:"Validee"});
			
			resetData();
			
			GoViral.goViral.removeEventListener(GVFacebookEvent.FB_DIALOG_FINISHED, onPublishOver);
			GoViral.goViral.removeEventListener(GVFacebookEvent.FB_DIALOG_FAILED, onPublishCancelledOrFailed);
			GoViral.goViral.removeEventListener(GVFacebookEvent.FB_DIALOG_CANCELED, onPublishCancelledOrFailed);
			
			dispatchEventWith(FacebookManagerEventType.PUBLISHED)
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
					
					// also update the token and its expiration date here
					MemberManager.getInstance().facebookToken = GoViral.goViral.getFbAccessToken();
					MemberManager.getInstance().facebookTokenExpiryTimestamp = GoViral.goViral.getFbAccessExpiry();
					
					if("facebookRewarded" in result && result.facebookRewarded != null) _isFacebookRewarded = result.facebookRewarded;
					
					if(_publicationData)
						publish();
					
					// so that the popup can be closed
					dispatchEventWith(FacebookManagerEventType.AUTHENTICATED, false, true);
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
			// reset the data by security
			resetData();
			
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
					// also update the token and its expiration date here
					MemberManager.getInstance().facebookToken = GoViral.goViral.getFbAccessToken();
					MemberManager.getInstance().facebookTokenExpiryTimestamp = GoViral.goViral.getFbAccessExpiry();
					
					if("facebookRewarded" in result && result.facebookRewarded != null) _isFacebookRewarded = result.facebookRewarded;

					if(_publicationData)
					{
						publish();
					}
					else
					{
						// The user have successfully logged in with his Facebook account
						// we dispatch an event to tell the app the result
						InfoManager.hide(result.txt, InfoContent.ICON_CHECK, InfoManager.DEFAULT_DISPLAY_TIME);
						dispatchEventWith(FacebookManagerEventType.AUTHENTICATED, false, true);
					}
					break;
				}
				case 7: // logged in but no pseudo, if we were publishing, a pseudo is automatically given
				{
					// also update the token and its expiration date here
					MemberManager.getInstance().facebookToken = GoViral.goViral.getFbAccessToken();
					MemberManager.getInstance().facebookTokenExpiryTimestamp = GoViral.goViral.getFbAccessExpiry();
					
					if("facebookRewarded" in result && result.facebookRewarded != null) _isFacebookRewarded = result.facebookRewarded;
					
					if(_publicationData)
					{
						InfoManager.hide(result.txt, InfoContent.ICON_CHECK, InfoManager.DEFAULT_DISPLAY_TIME, publish);
					}
					else
					{
						// The user have successfully logged in with his Facebook account but the pseudo field
						// is missing, thus we redirect the user to the pseudo choice screen
						AbstractEntryPoint.screenNavigator.screenData.defaultPseudo = result.pseudo_defaut;
						InfoManager.hide(result.txt, InfoContent.ICON_CHECK, InfoManager.DEFAULT_DISPLAY_TIME, AbstractEntryPoint.screenNavigator.showScreen, [ ScreenIds.PSEUDO_CHOICE_SCREEN ]);

						// no event dispatched here because we redirect to the pseudo choixe screen already
						// if we dispatch an event, the popup will close, redirect to the pseudo choixe screen and
						// then to the home screen
						dispatchEventWith(FacebookManagerEventType.AUTHENTICATED, false, false);
					}
					
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
			resetData();
			
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
//	Help
		
		public function canDisplayFacebookConnectButton():Boolean
		{
			return (!MemberManager.getInstance().isLoggedIn() || (MemberManager.getInstance().isLoggedIn() && MemberManager.getInstance().facebookId == 0));
		}
		
		/**
		 * resets the data.
		 */
		private function resetData():void
		{
			_publicationData = null;
			_isPublishing = false;
			_sponsorId = "-1";
		}
		
//------------------------------------------------------------------------------------------------------------
//	Get - Set
		
		public static function get sponsorId():String { return _sponsorId; }
		public static function set sponsorId(value:String):void { _sponsorId = value; }
		
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