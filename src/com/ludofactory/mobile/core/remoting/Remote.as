/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 9 avril 2013
*/
package com.ludofactory.mobile.core.remoting
{
	
	import com.ludofactory.common.gettext.LanguageManager;
	import com.ludofactory.common.utils.logs.log;
	import com.ludofactory.common.utils.logs.logError;
	import com.ludofactory.mobile.core.AbstractGameInfo;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.manager.InfoManager;
	import com.ludofactory.mobile.core.manager.MemberManager;
	import com.ludofactory.mobile.core.notification.CustomPopupManager;
	import com.ludofactory.mobile.core.notification.content.InvalidSessionNotificationContent;
	import com.ludofactory.mobile.core.push.GameSession;
	import com.ludofactory.mobile.core.storage.Storage;
	import com.ludofactory.mobile.core.storage.StorageConfig;
	import com.ludofactory.newClasses.store.StoreData;
	import com.milkmangames.nativeextensions.GoViral;
	
	import starling.events.EventDispatcher;
	import starling.utils.StringUtil;
	
	/**
	 * Simplifies the amfphp connection and the remote calls.
	 */	
	public class Remote extends EventDispatcher
	{
		private static var _instance:Remote;
		
		/**
		 * The amf php path. */		
		private const AMF_PATH:String = "/Amfphp/";
		
		// url quand on n'est pas sur le réseau local
		//private const DEV_PORT:int = 9999;
		//private const DEV_URL:String = "http://appmobile.ludokado.com";
		
		// urls et port quand on est sur le réseau local
		private const DEV_PORT:int = 80;
		//private const DEV_URL:String = "http://www.ludokado.com";
		//private const DEV_URL:String = "http://www.ludokado.dev";
		private const DEV_URL:String = "http://framework-php-mobile.mlhoez.ludofactory.dev";
		
		/**
		 * Production PORT. Automatically used when the GlobalConfig.DEBUG variable
		 * is set to true. */		
		private const PROD_PORT:int = 80;
		/**
		 * Production URL. Automatically used when the GlobalConfig.DEBUG variable
		 * is set to true. */		
		private const PROD_URL:String = "http://www.ludokado.com";
		
		private var _netConnectionManager:NetConnectionManager;
		
		public function Remote(sk:SecurityKey):void
		{
			if(sk == null)
				throw new Error("Erreur : Echec de l'instanciation : Utiliser Remote.getInstance() au lieu de new.");
				
			_netConnectionManager = new NetConnectionManager();
			_netConnectionManager.baseGatewayUrl = /*CONFIG::DEBUG ?*/ DEV_URL /*: PROD_URL*/;
			_netConnectionManager.gatewayPortNumber = /*CONFIG::DEBUG ?*/ DEV_PORT /*: PROD_PORT*/;
			_netConnectionManager.amfPath = AMF_PATH;
			_netConnectionManager.appName = "LudoMobile";
			_netConnectionManager.bridgeName = "LudoMobileEncryption.callAction";
			_netConnectionManager.reportErrorFunctionName = "LudoMobileEncryption.reportError";
			_netConnectionManager.encrypt = true;
			_netConnectionManager.useSecureConnection = Boolean(Storage.getInstance().getProperty(StorageConfig.PROPERTY_USE_SECURED_CALLS));
			_netConnectionManager.genericSuccessCallback = onQueryComplete;
			_netConnectionManager.genericFailureCallback = onQueryFail;
			_netConnectionManager.connect();
		}
		
		public static function getInstance():Remote
		{
			if(_instance == null)
				_instance = new Remote(new SecurityKey());
			return _instance;
		}
		
	// ---------- new calls
		
		/**
		 * Launches a duel. First tries to find an existing duel to challenge, otherwise it will create a new one.
		 */
		public function launchDuel(callbackSuccess:Function, callbackFail:Function, callbackMaxAttempts:Function = null, maxAttempts:int = -1, screenName:String = "default"):void
		{
			_netConnectionManager.call("useClass", [callbackSuccess, callbackMaxAttempts, callbackFail], screenName, maxAttempts, "?", "?", getGenericParams());
		}
		
		/**
		 * Pushes a game session.
		 */
		public function pushGame(gameSession:GameSession, callbackSuccess:Function, callbackFail:Function, callbackMaxAttempts:Function = null, maxAttempts:int = -1, screenName:String = "default"):void
		{
			var params:Object = mergeWithGenericParams( {   info_client:GlobalConfig.userHardwareData,
															gameMode:gameSession.gameMode,
															score:gameSession.score,
															playDate:gameSession.playDate,
															connected:gameSession.connected,
															trophiesWon:gameSession.trophiesWon,
															timeElapsed:gameSession.elapsedTime,
															gameSessionId:gameSession.uniqueId,
															actions:gameSession.actions } );
			_netConnectionManager.call("useClass", [callbackSuccess, callbackMaxAttempts, callbackFail], screenName, maxAttempts, "ServeurJeux", "pushPartie", params);
		}
		
		// ----- in-app purchases
		
		/**
		 * Creates an in-app purchase request in our server.
		 * 
		 * It will take in parameter the request id (the one in our database).
		 */
		public function createInAppPurchaseRequest(databaseOfferId:int, callbackSuccess:Function, callbackFail:Function, callbackMaxAttempts:Function = null, maxAttempts:int = -1, screenName:String = "default"):void
		{
			var params:Object = mergeWithGenericParams({ databaseOfferId:databaseOfferId });
			_netConnectionManager.call("useClass", [callbackSuccess, callbackMaxAttempts, callbackFail], screenName, maxAttempts, "AchatCredits", "createInAppPurchaseRequest", params);
		}
		
		/**
		 * Validates an in-app purchase request in our server.
		 */
		public function validateInAppPurchaseRequest(productData:StoreData, returnData:Object, request:Object, callbackSuccess:Function, callbackFail:Function, callbackMaxAttempts:Function = null, maxAttempts:int = -1, screenName:String = "default"):void
		{
			var params:Object = mergeWithGenericParams({ databaseOfferId:productData.databaseOfferId,
														 requestId:request.id,
														 paymentCode:productData.paymentCode,
													     returnData:returnData });
			_netConnectionManager.call("useClass", [callbackSuccess, callbackMaxAttempts, callbackFail], screenName, maxAttempts, "AchatCredits", "validateInAppPurchaseRequest", params);
		}
		
		/**
		 * Updates an in-app purchase state.
		 */
		public function changeInAppPurchaseRequestState(productData:StoreData, request:Object, requestState:int, callbackSuccess:Function, callbackFail:Function, callbackMaxAttempts:Function = null, maxAttempts:int = -1, screenName:String = "default"):void
		{
			var params:Object = mergeWithGenericParams({ databaseOfferId:productData.id,
														 requestId:request.id,
														 state:requestState });
			_netConnectionManager.call("useClass", [callbackSuccess, callbackMaxAttempts, callbackFail], screenName, maxAttempts, "AchatCredits", "changeInAppPurchaseRequestState", params);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Requests
		
		/**
		 * Initialize function.
		 * 
		 * <p>This functon is called in <code>Storage</code> when it is initialized.</p>
		 * 
		 * @see com.ludofactory.mobile.core.storage.Storage
		 */		
		public function init(callbackSuccess:Function, callbackFail:Function, callbackMaxAttempts:Function = null, maxAttempts:int = -1, screenName:String = "default"):void
		{
			//var params:Object = getGenericParams();
			//params.acces_tournoi = MemberManager.getInstance().isTournamentUnlocked ? 1 : 0;
			_netConnectionManager.call("useClass", [callbackSuccess, callbackMaxAttempts, callbackFail], screenName, maxAttempts, "Accueil", "init", getGenericParams());
		}
		
		// ----- Login / register
		
		/**
		 * Connects the user.
		 */
		public function logIn(login:String, password:String, callbackSuccess:Function, callbackFail:Function, callbackMaxAttempts:Function = null, maxAttempts:int = -1, screenName:String = "default"):void
		{
			var params:Object = getGenericParams();
			params.mail = login;
			params.mdp = password;
			_netConnectionManager.call("useClass", [callbackSuccess, callbackMaxAttempts, callbackFail], screenName, maxAttempts, "Identification", "logIn", params);
		}
		
		/**
		 * Registers the user.
		 */
		public function registerUser(userData:Object, callbackSuccess:Function, callbackFail:Function, callbackMaxAttempts:Function = null, maxAttempts:int = -1, screenName:String = "default"):void
		{
			userData = mergeWithGenericParams(userData);
			_netConnectionManager.call("useClass", [callbackSuccess, callbackMaxAttempts, callbackFail], screenName, maxAttempts, "Inscription", "nouveauJoueur", userData);
		}
		
		/**
		 * Register the user via facebook.
		 *
		 * Utilisé pour l'inscription ET le login (même fonction commune pour facebook)
		 */
		public function registerUserViaFacebook(userData:Object, callbackSuccess:Function, callbackFail:Function, callbackMaxAttempts:Function = null, maxAttempts:int = -1, screenName:String = "default"):void
		{
			userData = mergeWithGenericParams(userData);
			_netConnectionManager.call("useClass", [callbackSuccess, callbackMaxAttempts, callbackFail], screenName, maxAttempts, "Inscription", "nouveauJoueur", userData);
		}
		
		/**
		 * Associates the facebook account with the ludokado account.
		 */
		public function associateAccount(memberId:int, facebookId:String, email:String, prenom:String, nom:String, ville:String, dateNaissance:String, title:int, isPublishing:Boolean, callbackSuccess:Function, callbackFail:Function, callbackMaxAttempts:Function = null, maxAttempts:int = -1, screenName:String = "default"):void
		{
			var params:Object = mergeWithGenericParams( { id_membre:memberId, id_facebook:facebookId, mail_facebook:email, prenom:prenom, nom:nom, ville:ville, date_naissance:dateNaissance, titre:title, isPublishing:isPublishing } );
			_netConnectionManager.call("useClass", [callbackSuccess, callbackMaxAttempts, callbackFail], screenName, maxAttempts, "Inscription", "associationCompteLK", params);
		}
		
		/**
		 * Retreive the password for the account whose mail is given in parameter
		 */
		public function retreivePassword(login:String, callbackSuccess:Function, callbackFail:Function, callbackMaxAttempts:Function = null, maxAttempts:int = -1, screenName:String = "default"):void
		{
			var params:Object = mergeWithGenericParams( { mail:login } );
			_netConnectionManager.call("useClass", [callbackSuccess, callbackMaxAttempts, callbackFail], screenName, maxAttempts, "Identification", "motPasseOublie", params);
		}
		
		
		// ----- 
		
		
		
		/**
		 * Retrieves the list of all trophies associated to this game, in order to dynamize them.
		 */
		public function getTrophies(callbackSuccess:Function, callbackFail:Function, callbackMaxAttempts:Function = null, maxAttempts:int = -1, screenName:String = "default"):void
		{
			_netConnectionManager.call("useClass", [callbackSuccess, callbackMaxAttempts, callbackFail], screenName, maxAttempts, "Accueil", "getTrophies", getGenericParams());
		}
		
		/**
		 * Updates the push token
		 */		
		public function updatePushToken(token:String, callbackSuccess:Function, callbackFail:Function, callbackMaxAttempts:Function = null, maxAttempts:int = -1, screenName:String = "default"):void
		{
			var params:Object = mergeWithGenericParams( { token:token } );
			_netConnectionManager.call("useClass", [callbackSuccess, callbackMaxAttempts, callbackFail], screenName, maxAttempts, "Accueil", "majToken", params);
		}
		
		
		
		
		
		
		
		
		
		
		
		
		
		/**
		 * Push a game
		 * 
		 */		
		public function pushTrophy(trophyId:int, callbackSuccess:Function, callbackFail:Function, callbackMaxAttempts:Function = null, maxAttempts:int = -1, screenName:String = "default"):void
		{
			var params:Object = mergeWithGenericParams( { num_coupe:trophyId } );
			_netConnectionManager.call("useClass", [callbackSuccess, callbackMaxAttempts, callbackFail], screenName, maxAttempts, "ServeurJeux", "saveCoupe", params);
		}
		
		/**
		 * Push a game
		 * 
		 */		
		public function initTrophies(callbackSuccess:Function, callbackFail:Function, callbackMaxAttempts:Function = null, maxAttempts:int = -1, screenName:String = "default"):void
		{
			_netConnectionManager.call("useClass", [callbackSuccess, callbackMaxAttempts, callbackFail], screenName, maxAttempts, "ServeurJeux", "resetAlerteCoupe", getGenericParams());
		}
		
		/**
		 * Updates only the FAQ translations (and add new ones if there were not already there).
		 */		
		public function getFaq(callbackSuccess:Function, callbackFail:Function, callbackMaxAttempts:Function = null, maxAttempts:int = -1, screenName:String = "default"):void
		{
			var params:Object = getGenericParams();
			_netConnectionManager.call("useClass", [callbackSuccess, callbackMaxAttempts, callbackFail], screenName, maxAttempts, "Accueil", "getFAQ", params);
		}
		
		/**
		 * 
		 */		
		public function getNews(callbackSuccess:Function, callbackFail:Function, callbackMaxAttempts:Function = null, maxAttempts:int = -1, screenName:String = "default"):void
		{
			var params:Object = getGenericParams();
			_netConnectionManager.call("useClass", [callbackSuccess, callbackMaxAttempts, callbackFail], screenName, maxAttempts, "Accueil", "getActualites", params);
		}
		
// HighScore list
		
		/**
		 * @param countryId The country id to sort the results (0 is international).
		 */		
		public function getHighScoreRanking(countryId:int, callbackSuccess:Function, callbackFail:Function, callbackMaxAttempts:Function = null, maxAttempts:int = -1, screenName:String = "default"):void
		{
			var params:Object;
			if( countryId == -1 )
			{
				// Facebook
				params = mergeWithGenericParams( { type:"init" } );
				_netConnectionManager.call("useClass", [callbackSuccess, callbackMaxAttempts, callbackFail], screenName, maxAttempts, "HighScore", "getClassementFacebook", params);
			}
			else
			{
				params = mergeWithGenericParams( { id_pays:countryId } );
				_netConnectionManager.call("useClass", [callbackSuccess, callbackMaxAttempts, callbackFail], screenName, maxAttempts, "HighScore", "getClassement", params);
			}
		}
		
		/**
		 * 
		 */		
		public function getHighScoreRankingSup(date:String, score:int, rank:int, countryId:int, callbackSuccess:Function, callbackFail:Function, callbackMaxAttempts:Function = null, maxAttempts:int = -1, screenName:String = "default"):void
		{
			var params:Object;
			if( countryId == -1 )
			{
				// Facebook
				params = mergeWithGenericParams( { type:"sup", position:rank } );
				_netConnectionManager.call("useClass", [callbackSuccess, callbackMaxAttempts, callbackFail], screenName, maxAttempts, "HighScore", "getClassementFacebookSup", params);
			}
			else
			{
				params = mergeWithGenericParams( { date:date, score:score, classement:rank, id_pays:countryId } );
				_netConnectionManager.call("useClass", [callbackSuccess, callbackMaxAttempts, callbackFail], screenName, maxAttempts, "HighScore", "getClassementSup", params);
			}
		}
		
		/**
		 * 
		 */		
		public function getHighScoreRankingInf(date:String, score:int, rank:int, countryId:int, callbackSuccess:Function, callbackFail:Function, callbackMaxAttempts:Function = null, maxAttempts:int = -1, screenName:String = "default"):void
		{
			var params:Object;
			if( countryId == -1 )
			{
				// Facebook
				params = mergeWithGenericParams( { type:"inf", position:rank } );
				_netConnectionManager.call("useClass", [callbackSuccess, callbackMaxAttempts, callbackFail], screenName, maxAttempts, "HighScore", "getClassementFacebookInf", params);
			}
			else
			{
				params = mergeWithGenericParams( { date:date, score:score, classement:rank, id_pays:countryId } );
				_netConnectionManager.call("useClass", [callbackSuccess, callbackMaxAttempts, callbackFail], screenName, maxAttempts, "HighScore", "getClassementInf", params);
			}
		}
		
// Account
		
		/**
		 * Retreive account informations (personal informations,
		 * address, pseudo, mail, etc.
		 */		
		public function getAccountInformations(callbackSuccess:Function, callbackFail:Function, callbackMaxAttempts:Function = null, maxAttempts:int = -1, screenName:String = "default"):void
		{
			_netConnectionManager.call("useClass", [callbackSuccess, callbackMaxAttempts, callbackFail], screenName, maxAttempts, "Compte", "init", getGenericParams());
		}
		
		/**
		 * Updates personal informations.
		 */		
		public function accountUpdatePersonalInformations(data:Object, callbackSuccess:Function, callbackFail:Function, callbackMaxAttempts:Function = null, maxAttempts:int = -1, screenName:String = "default"):void
		{
			var params:Object = mergeWithGenericParams( data );
			_netConnectionManager.call("useClass", [callbackSuccess, callbackMaxAttempts, callbackFail], screenName, maxAttempts, "Compte", "majInfosPerso", params);
		}
		
		/**
		 * Updates address.
		 */		
		public function accountUpdateAddressInformations(data:Object, callbackSuccess:Function, callbackFail:Function, callbackMaxAttempts:Function = null, maxAttempts:int = -1, screenName:String = "default"):void
		{
			var params:Object = mergeWithGenericParams( data );
			_netConnectionManager.call("useClass", [callbackSuccess, callbackMaxAttempts, callbackFail], screenName, maxAttempts, "Compte", "majAdressePays", params);
		}
		
		/**
		 * Updates pseudo.
		 */		
		public function accountUpdatePseudo(data:Object, callbackSuccess:Function, callbackFail:Function, callbackMaxAttempts:Function = null, maxAttempts:int = -1, screenName:String = "default"):void
		{
			var params:Object = mergeWithGenericParams( data );
			_netConnectionManager.call("useClass", [callbackSuccess, callbackMaxAttempts, callbackFail], screenName, maxAttempts, "Compte", "majPseudo", params);
		}
		
		/**
		 * Updates mail.
		 */		
		public function accountUpdateMail(data:Object, callbackSuccess:Function, callbackFail:Function, callbackMaxAttempts:Function = null, maxAttempts:int = -1, screenName:String = "default"):void
		{
			var params:Object = mergeWithGenericParams( data );
			_netConnectionManager.call("useClass", [callbackSuccess, callbackMaxAttempts, callbackFail], screenName, maxAttempts, "Compte", "majMail", params);
		}
		
		/**
		 * Updates password.
		 */		
		public function accountUpdatePassword(data:Object, callbackSuccess:Function, callbackFail:Function, callbackMaxAttempts:Function = null, maxAttempts:int = -1, screenName:String = "default"):void
		{
			var params:Object = mergeWithGenericParams( data );
			_netConnectionManager.call("useClass", [callbackSuccess, callbackMaxAttempts, callbackFail], screenName, maxAttempts, "Compte", "majMdp", params);
		}
		
		/**
		 * Updates push notifications.
		 */		
		public function accountUpdateNotifications(data:Object, callbackSuccess:Function, callbackFail:Function, callbackMaxAttempts:Function = null, maxAttempts:int = -1, screenName:String = "default"):void
		{
			var params:Object = mergeWithGenericParams( data );
			_netConnectionManager.call("useClass", [callbackSuccess, callbackMaxAttempts, callbackFail], screenName, maxAttempts, "Compte", "setNotification", params);
		}
		
		
		
		/**
		 * Check for language update
		 */		
		public function checkForLanguageUpdate(installedLanguageData:Object, callbackSuccess:Function, callbackFail:Function, callbackMaxAttempts:Function = null, maxAttempts:int = -1, screenName:String = "default"):void
		{
			var params:Object = mergeWithGenericParams( { info_langue:installedLanguageData } );
			_netConnectionManager.call("useClass", [callbackSuccess, callbackMaxAttempts, callbackFail], screenName, maxAttempts, "Accueil", "getFichierTraduction", params);
		}

		/**
		 * Insert a line in the database whenever a video starts to display (VidCoin).
		 */
		public function logVidCoin(callbackSuccess:Function, callbackFail:Function, callbackMaxAttempts:Function = null, maxAttempts:int = -1, screenName:String = "default"):void
		{
			_netConnectionManager.call("useClass", [callbackSuccess, callbackMaxAttempts, callbackFail], screenName, maxAttempts, "ServeurJeux", "logDemandeVidcoin", getGenericParams());
		}
		
		/**
		 * Insert a line in the database whenever a video starts to display (VidCoin).
		 */
		public function addRewardAfterSharing(callbackSuccess:Function, callbackFail:Function, callbackMaxAttempts:Function = null, maxAttempts:int = -1, screenName:String = "default"):void
		{
			_netConnectionManager.call("useClass", [callbackSuccess, callbackMaxAttempts, callbackFail], screenName, maxAttempts, "Accueil", "addRewardAfterSharing", getGenericParams());
		}
		
		/**
		 * Generic test function (must return a string, not an object because of the addslash)
		 */		
		public function test(token:String, callbackSuccess:Function, callbackFail:Function, callbackMaxAttempts:Function = null, maxAttempts:int = -1, screenName:String = "default"):void
		{
			//var params:Object = mergeWithGenericParams( { token:token } ); 
			//log( JSON.stringify(params) );
			_netConnectionManager.call("test", [callbackSuccess, callbackMaxAttempts, callbackFail], screenName, maxAttempts, token);
		}
		
		/**
		 * Generic test function (must return a string, not an object because of the addslash)
		 */
		public function reportError(errorObject:Object, maxAttempts:int = 1, screenName:String = "error"):void
		{
			_netConnectionManager.reportError(errorObject, [null, null, null], screenName, maxAttempts);
		}
		
		
		
		
		
		
//------------------------------------------------------------------------------------------------------------
//	Handlers
		
		/**
		 * Generic function called when a query have been sent successfully.
		 * 
		 * <p>If there is a Member object in the result, this function will
		 * also try to parse this object to update the internal Member object.</p>
		 * 
		 * <p>Moreover, if the error code number 999 is returned, this means that
		 * the user could not be identified / reconnected on the server side, so
		 * we need to disconnect him completely in the application and redirect
		 * him in the home screen to avoid any bug</p>
		 */ 
		protected function onQueryComplete(result:Object, queryName:String, callbackSuccess:Function):void
		{
			if( result.code == 999 )
			{
				log("[Remote] onQueryComplete : The user could not be reconnected on the server side (error 999).");
				MemberManager.getInstance().disconnect();
				CustomPopupManager.addPopup(new InvalidSessionNotificationContent());
				InfoManager.forceClose();
			}
			else
			{
				result.queryName = queryName;
				
				// do it before the member is loaded
				if(queryName == "LudoMobile.useClass.Identification.logIn" || queryName == "LudoMobile.useClass.Inscription.nouveauJoueur")
				{
					if( result.code == 1 || result.code == 6 || result.code == 7 || result.code == 8 || result.code == 9 || result.code == 11 || result.code == 12 )
					{
						log("[Remote] Inscription ou connexion réussie, parties anonymes retirées.");
						// because the sign in/up is ok, we need to clear the credits he potentially bought
						MemberManager.getInstance().cumulatedTrophies = 0;
					}
				}
				
				// parse the member object
				if("obj_membre_mobile" in result && result.obj_membre_mobile)
					MemberManager.getInstance().parseData(result.obj_membre_mobile);
				
				// sync the trophies (in case the user changed device for example)
				if(MemberManager.getInstance().isLoggedIn() && "tab_trophy_win" in result)
					MemberManager.getInstance().trophiesWon = result.tab_trophy_win as Array;
				
				// TODO voir comment gérer le MemberManager.getInstance().setDisplayTutorial( int(result.acces_tournoi) != 1 );
				
				if( callbackSuccess )
					callbackSuccess(result);
			}

			// secured calls (https)
			if("appels_https" in result && result.appels_https != null)
			{
				delete result.appels_https;
				Storage.getInstance().setProperty(StorageConfig.PROPERTY_USE_SECURED_CALLS, int(result.appels_https) == 1);
				// now check if the value is different in order to know if we need to reconnect or not
				if(Boolean(Storage.getInstance().getProperty(StorageConfig.PROPERTY_USE_SECURED_CALLS)) != _netConnectionManager.useSecureConnection)
					_netConnectionManager.connect(); // reconnect if invalid
			}
			
			// a force download have been requested for this version
			if("forceDownload" in result && result.forceDownload != null && int(result.forceDownload) == 1)
			{
				if( Boolean(Storage.getInstance().getProperty(StorageConfig.PROPERTY_FORCE_UPDATE)) == false )
				{
					// if the property in Storage have not been already updated, we do it now
					// we need the user to update the game, in this case we change the property FORCE_UPDATE to true,
					// then we need to update the stored game version so that we can later check if the update was
					// made or not (i.e. if the actual game version is higher than the stored one at the moment we
					// requested the update
					log("[Remote] onQueryComplete : The user must update the app (forceDownload = 1).");
					Storage.getInstance().setProperty(StorageConfig.PROPERTY_FORCE_UPDATE, true);
					Storage.getInstance().setProperty(StorageConfig.PROPERTY_FORCE_UPDATE_LINK, result.lien_application);
					Storage.getInstance().setProperty(StorageConfig.PROPERTY_FORCE_UPDATE_TEXT, result.text_force_download);
					Storage.getInstance().setProperty(StorageConfig.PROPERTY_FORCE_UPDATE_BUTTON_NAME, result.btn_force_download);
					Storage.getInstance().setProperty(StorageConfig.PROPERTY_GAME_VERSION, AbstractGameInfo.GAME_VERSION);
				}
				else
				{
					// if we are here, it's because an update have been requested but we already had the value in
					// Storage, so we simply update the text, link and button here
					Storage.getInstance().setProperty(StorageConfig.PROPERTY_FORCE_UPDATE_LINK, result.lien_application);
					Storage.getInstance().setProperty(StorageConfig.PROPERTY_FORCE_UPDATE_TEXT, result.text_force_download);
					Storage.getInstance().setProperty(StorageConfig.PROPERTY_FORCE_UPDATE_BUTTON_NAME, result.btn_force_download);
				}
			}
			
		}
		
		/**
		 * Fonction générale appelée en cas d'échec d'exécution de la requête.
		 */ 
		protected function onQueryFail(error:Object, queryName:String, callback:Function):void
		{
			// set up query name in the object
			if(error) error.queryName = queryName;
			else error = { queryName:queryName };
			
			if(callback)
				callback(error);
			
			try
			{
				if(error.queryName == "useClass")
					error.queryName += "\n onQueryFail : Une requête a échoué.";
				logError(error + StringUtil.format("<br><br><strong>Erreur PHP :</strong><br><strong>Requête : </strong>{0}<br><strong>FaultCode : </strong>{1}<br><strong>FaultString : </strong>{2}<br><strong>FaultDetail :</strong><br>{3}", error.queryName, error.faultCode, error.faultString, error.faultDetail));
				//if( CONFIG::DEBUG )
				//	ErrorDisplayer.showError(StringUtil.format("<strong>Erreur PHP :</strong><br><br><strong>Requête : </strong>{0}<br><br><strong>FaultCode : </strong>{1}<br><br><strong>FaultString : </strong>{2}<br><br><strong>FaultDetail :</strong><br>{3}", error.queryName, error.faultCode, error.faultString, error.faultDetail));
			} 
			catch(error:Error) { }
		}
		
		public function clearAllRespondersOfScreen(screenName:String):void
		{
			_netConnectionManager.clearAllRespondersOfScreen(screenName);
		}
		public function clearAllResponders():void
		{
			_netConnectionManager.clearAllResponders();
		}
		
		/**
		 * Returns a generic object used as parameter in every call.
		 * 
		 * <p>This generic object will contain the following properties :</p>
		 * 
		 * <listing version="3.0">
		 * - id_membre
		 * - mail
		 * - mdp
		 * - langue
		 * - id_jeu
		 * </listing>
		 * 
		 * @return 
		 * 
		 */		
		private function getGenericParams():Object
		{
			var genericParam:Object = {};
			genericParam.id_membre = MemberManager.getInstance().id;
			genericParam.mail = MemberManager.getInstance().email;
			genericParam.mdp = MemberManager.getInstance().password;
			genericParam.langue = LanguageManager.getInstance().lang;
			genericParam.id_jeu = AbstractGameInfo.GAME_ID;
			genericParam.nom_jeu = AbstractGameInfo.GAME_NAME;
			genericParam.type_appareil = GlobalConfig.isPhone ? "smartphone":"tablette";
			genericParam.plateforme = GlobalConfig.platformName;
			genericParam.id_appareil = GlobalConfig.deviceId;
			genericParam.version_jeu = AbstractGameInfo.GAME_VERSION + "." + AbstractGameInfo.GAME_BUILD_VERSION;
			genericParam.screen_orientation = AbstractGameInfo.LANDSCAPE ? "paysage" : "portrait";
			genericParam.store = GlobalConfig.ios ? "applestore" : (GlobalConfig.amazon ? "amazon" : "googleplay");
			try
			{
				if( GoViral.isSupported() && GoViral.goViral.isFacebookSupported() && GoViral.goViral.isFacebookAuthenticated() )
					genericParam.fb_token = GoViral.goViral.getFbAccessToken();
			} 
			catch(error:Error) 
			{
				// goViral was not created
			}
			return genericParam;
		}
		
		private function mergeWithGenericParams( objectToMerge:Object ):Object
		{
			var genericParams:Object = getGenericParams();
			for( var key:String in objectToMerge )
				genericParams[key] = objectToMerge[key];
			return genericParams;
		}
		
		public function reconnect(url:String, port:int):void
		{
			_netConnectionManager.baseGatewayUrl = url;
			_netConnectionManager.gatewayPortNumber = port;
			_netConnectionManager.connect();
		}
		
		public function get isTimerRunning():Boolean
		{
			return _netConnectionManager.isTimerRunning;
		}
		
		public function get baseGatewayUrl():String
		{
			return _netConnectionManager.baseGatewayUrl;
		}
		
		public function get gatewayPortNumber():int
		{
			return _netConnectionManager.gatewayPortNumber;
		}
		
	}
}

internal class SecurityKey{}