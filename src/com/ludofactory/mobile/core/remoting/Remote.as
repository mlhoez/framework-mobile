/*
Copyright © 2006-2014 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 9 avril 2013
*/
package com.ludofactory.mobile.core.remoting
{
	import com.gamua.flox.Flox;
	import com.ludofactory.common.utils.log;
	import com.ludofactory.mobile.core.AbstractGameInfo;
	import com.ludofactory.mobile.core.InvalidSessionNotification;
	import com.ludofactory.mobile.core.Localizer;
	import com.ludofactory.mobile.core.authentication.MemberManager;
	import com.ludofactory.mobile.core.events.LudoEventType;
	import com.ludofactory.mobile.debug.ErrorDisplayer;
	import com.ludofactory.mobile.core.manager.InfoContent;
	import com.ludofactory.mobile.core.manager.InfoManager;
	import com.ludofactory.mobile.core.notification.NotificationManager;
	import com.ludofactory.mobile.core.storage.Storage;
	import com.ludofactory.mobile.core.storage.StorageConfig;
	import com.ludofactory.mobile.core.test.config.GlobalConfig;
	import com.ludofactory.mobile.core.test.push.GameSession;
	import com.ludofactory.mobile.core.test.store.StoreData;
	import com.milkmangames.nativeextensions.GoViral;
	
	import flash.system.Capabilities;
	
	import starling.events.EventDispatcher;
	import starling.utils.formatString;
	
	/**
	 * Simplifies the amfphp connection and the remote calls.
	 */	
	public class Remote extends EventDispatcher
	{
		private static var _instance:Remote;
		
		/**
		 * The amf php path. */		
		private const AMF_PATH:String = "/amfphp2/";
		
		// url quand on n'est pas sur le réseau local
		private const DEV_PORT:int = 9999;
		private const DEV_URL:String = "http://ludomobile.ludokado.com";
		
		// urls et port quand on est sur le réseau local
		//private const DEV_PORT:int = 80;
		//private const DEV_URL:String = "http://ludokado.dev";
		//private const DEV_URL:String = "http://ludomobile.ludokado.dev";
		//private const DEV_URL:String = "http://ludokadom.mlhoez.ludofactory.dev";
		//private const DEV_URL:String = "http://ludokado.pterrier.ludofactory.dev";
		//private const DEV_URL:String = "http://ludokado.aguerreiro.ludofactory.dev";
		//private const DEV_URL:String = "http://semiprod.ludokado.com";
		
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
			_netConnectionManager.baseGatewayUrl = GlobalConfig.DEBUG ? DEV_URL : PROD_URL;
			_netConnectionManager.gatewayPortNumber = GlobalConfig.DEBUG ? DEV_PORT : PROD_PORT;
			_netConnectionManager.amfPath = AMF_PATH;
			_netConnectionManager.appName = "LudoMobile";
			_netConnectionManager.bridgeName = "LudoMobileEncryption.callAction";
			_netConnectionManager.encrypt = true;
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
		
//------------------------------------------------------------------------------------------------------------
//	Requests
		
		public function getTermsAndConditions(callbackSuccess:Function, callbackFail:Function, callbackMaxAttempts:Function = null, maxAttempts:int = -1, screenName:String = "default"):void
		{
			_netConnectionManager.call("useClass", [callbackSuccess, callbackMaxAttempts, callbackFail], screenName, maxAttempts, "Accueil", "getReglement", getGenericParams());
		}
		
		/**
		 * Initialize function.
		 * 
		 * <p>This functon is called in <code>Storage</code> when it is initialized.</p>
		 * 
		 * @see com.ludofactory.mobile.core.storage.Storage
		 */		
		public function init(callbackSuccess:Function, callbackFail:Function, callbackMaxAttempts:Function = null, maxAttempts:int = -1, screenName:String = "default"):void
		{
			var params:Object = getGenericParams();
			params.langues = Localizer.getInstance().getGlobalLanguagesVersion();
			params.acces_tournoi = MemberManager.getInstance().getTournamentUnlocked() == true ? 1 : 0;
			_netConnectionManager.call("useClass", [callbackSuccess, callbackMaxAttempts, callbackFail], screenName, maxAttempts, "Accueil", "init", params);
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
		 * Updates the push token
		 */		
		public function getEvent(callbackSuccess:Function, callbackFail:Function, callbackMaxAttempts:Function = null, maxAttempts:int = -1, screenName:String = "default"):void
		{
			_netConnectionManager.call("useClass", [callbackSuccess, callbackMaxAttempts, callbackFail], screenName, maxAttempts, "Accueil", "evenementiel", getGenericParams());
		}
		
		/**
		 * Connect the user.
		 * 
		 * @param login Login (mail)
		 * @param password Password
		 */		
		public function logIn(login:String, password:String, callbackSuccess:Function, callbackFail:Function, callbackMaxAttempts:Function = null, maxAttempts:int = -1, screenName:String = "default"):void
		{
			var params:Object = getGenericParams();
			params.mail = login;
			params.mdp = password;
			params = addAnonymousGameSessionsIfNeeded( params );
			_netConnectionManager.call("useClass", [callbackSuccess, callbackMaxAttempts, callbackFail], screenName, maxAttempts, "Identification", "logIn", params);
		}
		
		/**
		 * Creates a pseudo.
		 * 
		 * @param userId the user id
		 * @param pseudo pseudo
		 */		
		public function createPseudo(pseudo:String, callbackSuccess:Function, callbackFail:Function, callbackMaxAttempts:Function = null, maxAttempts:int = -1, screenName:String = "default"):void
		{
			var params:Object = getGenericParams();
			params.pseudo = pseudo;
			_netConnectionManager.call("useClass", [callbackSuccess, callbackMaxAttempts, callbackFail], screenName, maxAttempts, "Inscription", "creationPseudo", params);
		}
		
		/**
		 * Get a default pseudo.
		 * 
		 * @param userId User id
		 */		
		public function getDefaultPseudo(callbackSuccess:Function, callbackFail:Function, callbackMaxAttempts:Function = null, maxAttempts:int = -1, screenName:String = "default"):void
		{
			var params:Object = getGenericParams();
			_netConnectionManager.call("useClass", [callbackSuccess, callbackMaxAttempts, callbackFail], screenName, maxAttempts, "Inscription", "getPseudoDefaut", params);
		}
		
		/**
		 * Register the user.
		 * 
		 * @param userData All the data already formatted into an object
		 */		
		public function registerUser(userData:Object, callbackSuccess:Function, callbackFail:Function, callbackMaxAttempts:Function = null, maxAttempts:int = -1, screenName:String = "default"):void
		{
			userData = addAnonymousGameSessionsIfNeeded( userData );
			userData = mergeWithGenericParams(userData);
			_netConnectionManager.call("useClass", [callbackSuccess, callbackMaxAttempts, callbackFail], screenName, maxAttempts, "Inscription", "nouveauJoueur", userData);
		}
		
		/**
		 * Register the user via facebook.
		 * 
		 * @param userData All the data already formatted into an object
		 */		
		public function registerUserViaFacebook(userData:Object, callbackSuccess:Function, callbackFail:Function, callbackMaxAttempts:Function = null, maxAttempts:int = -1, screenName:String = "default"):void
		{
			userData = addAnonymousGameSessionsIfNeeded( userData );
			userData = mergeWithGenericParams(userData);
			_netConnectionManager.call("useClass", [callbackSuccess, callbackMaxAttempts, callbackFail], screenName, maxAttempts, "Inscription", "nouveauJoueur", userData);
		}
		
		/**
		 * Connect the user via facebook.
		 * 
		 * @param userData All the data already formatted into an object
		 */		
		/*public function connectUserViaFacebook(userData:Object, callbackSuccess:Function, callbackFail:Function, callbackMaxAttempts:Function = null, maxAttempts:int = -1, screenName:String = "default"):void
		{
			userData = addAnonymousGameSessionsIfNeeded( userData );
			userData = mergeWithGenericParams(userData);
			_netConnectionManager.call("useClass", [callbackSuccess, callbackMaxAttempts, callbackFail], screenName, maxAttempts, "Identification", "logInFacebook", userData);
		}*/
		
		/**
		 * Set the member sponsor.
		 * 
		 * @param memberId The member id
		 * @param sponsorId The sponsor id
		 */		
		public function setParrainage(sponsorId:String, callbackSuccess:Function, callbackFail:Function, callbackMaxAttempts:Function = null, maxAttempts:int = -1, screenName:String = "default"):void
		{
			var params:Object = getGenericParams();
			params.id_parrain = sponsorId;
			_netConnectionManager.call("useClass", [callbackSuccess, callbackMaxAttempts, callbackFail], screenName, maxAttempts, "Inscription", "setParrainage", params);
		}
		
		/**
		 * Associate the facebook account with the ludokado account
		 * 
		 * @param memberId The member id
		 * @param facebookId The facebook id
		 * @param password The password
		 */		
		public function associateAccount(memberId:int, facebookId:Number, email:String, prenom:String, nom:String, ville:String, dateNaissance:String, title:int, callbackSuccess:Function, callbackFail:Function, callbackMaxAttempts:Function = null, maxAttempts:int = -1, screenName:String = "default"):void
		{
			var params:Object = mergeWithGenericParams( { id_membre:memberId, id_facebook:facebookId, mail_facebook:email, prenom:prenom, nom:nom, ville:ville, date_naissance:dateNaissance, titre:title } );
			_netConnectionManager.call("useClass", [callbackSuccess, callbackMaxAttempts, callbackFail], screenName, maxAttempts, "Inscription", "associationCompteLK", params);
		}
		
		/**
		 * Retreive the password for the account whose mail is given in parameter
		 * 
		 * @param login The email
		 */		
		public function retreivePassword(login:String, callbackSuccess:Function, callbackFail:Function, callbackMaxAttempts:Function = null, maxAttempts:int = -1, screenName:String = "default"):void
		{
			var params:Object = mergeWithGenericParams( { mail:login } );
			_netConnectionManager.call("useClass", [callbackSuccess, callbackMaxAttempts, callbackFail], screenName, maxAttempts, "Identification", "motPasseOublie", params);
		}
		
		/**
		 * Push a game
		 * 
		 */		
		public function pushGame(gameSession:GameSession, callbackSuccess:Function, callbackFail:Function, callbackMaxAttempts:Function = null, maxAttempts:int = -1, screenName:String = "default"):void
		{
			var params:Object = mergeWithGenericParams( { info_client:GlobalConfig.userHardwareData, type_mise:gameSession.gamePrice, type_partie:gameSession.gameType, score:gameSession.score, date_partie:gameSession.playDate, connected:gameSession.connected, coupes:gameSession.trophiesWon, temps_ecoule:gameSession.elapsedTime, id_partie:gameSession.uniqueId } );
			_netConnectionManager.call("useClass", [callbackSuccess, callbackMaxAttempts, callbackFail], screenName, maxAttempts, "ServeurJeux", "pushPartie", params);
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
		
		public function updateMises(callbackSuccess:Function, callbackFail:Function, callbackMaxAttempts:Function = null, maxAttempts:int = -1, screenName:String = "default"):void
		{
			_netConnectionManager.call("useClass", [callbackSuccess, callbackMaxAttempts, callbackFail], screenName, maxAttempts, "ServeurJeux", "majMise", getGenericParams());
		}
		
		/**
		 * Get sub categories
		 */		
		public function getSubCategories(idCategory:int, idSubCategory:int, callbackSuccess:Function, callbackFail:Function, callbackMaxAttempts:Function = null, maxAttempts:int = -1, screenName:String = "default"):void
		{
			var params:Object = mergeWithGenericParams( { id_rub:idCategory, id_ssrub:idSubCategory } );
			if( !idSubCategory )
				delete params.id_ssrub;
			_netConnectionManager.call("useClass", [callbackSuccess, callbackMaxAttempts, callbackFail], screenName, maxAttempts, "Boutique", "listingBoutiqueVIP", params);
		}
		
		/**
		 * Order a gift
		 */		
		public function order(idLot:int, lotName:String, callbackSuccess:Function, callbackFail:Function, callbackMaxAttempts:Function = null, maxAttempts:int = -1, screenName:String = "default"):void
		{
			var params:Object = mergeWithGenericParams( { id_article:idLot, nom_article:lotName } );
			_netConnectionManager.call("useClass", [callbackSuccess, callbackMaxAttempts, callbackFail], screenName, maxAttempts, "Boutique", "commander", params);
		}
		
		/**
		 * Retreive pending bids.
		 */		
		public function getPendingBids(callbackSuccess:Function, callbackFail:Function, callbackMaxAttempts:Function = null, maxAttempts:int = -1, screenName:String = "default"):void
		{
			_netConnectionManager.call("useClass", [callbackSuccess, callbackMaxAttempts, callbackFail], screenName, maxAttempts, "Boutique", "listingBoutiqueEnchereEncours", getGenericParams());
		}
		
		/**
		 * Retreive finished bids.
		 */		
		public function getFinishedBids(callbackSuccess:Function, callbackFail:Function, callbackMaxAttempts:Function = null, maxAttempts:int = -1, screenName:String = "default"):void
		{
			_netConnectionManager.call("useClass", [callbackSuccess, callbackMaxAttempts, callbackFail], screenName, maxAttempts, "Boutique", "listingBoutiqueEnchereTerminer", getGenericParams());
		}
		
		/**
		 * Retreive coming soon bids.
		 */		
		public function getComingSoonBids(callbackSuccess:Function, callbackFail:Function, callbackMaxAttempts:Function = null, maxAttempts:int = -1, screenName:String = "default"):void
		{
			_netConnectionManager.call("useClass", [callbackSuccess, callbackMaxAttempts, callbackFail], screenName, maxAttempts, "Boutique", "listingBoutiqueEnchereAVenir", getGenericParams());
		}
		
		/**
		 * Bid.
		 */		
		public function bid(bidId:int, value:int, minimumBid:int, callbackSuccess:Function, callbackFail:Function, callbackMaxAttempts:Function = null, maxAttempts:int = -1, screenName:String = "default"):void
		{
			var params:Object = mergeWithGenericParams( { id:bidId, montant:value, enchere_mini:minimumBid } );
			_netConnectionManager.call("useClass", [callbackSuccess, callbackMaxAttempts, callbackFail], screenName, maxAttempts, "Boutique", "encherir", params);
		}
		
		/**
		 * Retreive a specific bid information.
		 */		
		public function getSpecificBid(bidId:int, callbackSuccess:Function, callbackFail:Function, callbackMaxAttempts:Function = null, maxAttempts:int = -1, screenName:String = "default"):void
		{
			var params:Object = mergeWithGenericParams( { id_enchere:bidId } );
			_netConnectionManager.call("useClass", [callbackSuccess, callbackMaxAttempts, callbackFail], screenName, maxAttempts, "Boutique", "listingBoutiqueEnchereEncoursSpe", params);
		}
		
		
		/**
		 * 
		 */		
		public function getCustomerServiceThreads(state:int, callbackSuccess:Function, callbackFail:Function, callbackMaxAttempts:Function = null, maxAttempts:int = -1, screenName:String = "default"):void
		{
			var params:Object = mergeWithGenericParams( { etat:state } );
			_netConnectionManager.call("useClass", [callbackSuccess, callbackMaxAttempts, callbackFail], screenName, maxAttempts, "ServiceClient", "getListeSujets", params);
		}
		
		/**
		 * 
		 */		
		public function createNewCustomerServiceThread(themeId:int, mail:String, message:String, callbackSuccess:Function, callbackFail:Function, callbackMaxAttempts:Function = null, maxAttempts:int = -1, screenName:String = "default"):void
		{
			var params:Object;
			if( !mail )
				params = mergeWithGenericParams( { id_theme:themeId, message:message } );
			else
				params = mergeWithGenericParams( { id_theme:themeId, mail:mail, message:message } );
				
			_netConnectionManager.call("useClass", [callbackSuccess, callbackMaxAttempts, callbackFail], screenName, maxAttempts, "ServiceClient", "creationSujet", params);
		}
		
		/**
		 * 
		 */		
		public function getThread(threadId:int, callbackSuccess:Function, callbackFail:Function, callbackMaxAttempts:Function = null, maxAttempts:int = -1, screenName:String = "default"):void
		{
			var params:Object = mergeWithGenericParams( { id_sujet:threadId } );
			_netConnectionManager.call("useClass", [callbackSuccess, callbackMaxAttempts, callbackFail], screenName, maxAttempts, "ServiceClient", "getDiscussion", params);
		}
		
		/**
		 * 
		 */		
		public function createNewMessage(threadId:int, message:String, callbackSuccess:Function, callbackFail:Function, callbackMaxAttempts:Function = null, maxAttempts:int = -1, screenName:String = "default"):void
		{
			var params:Object = mergeWithGenericParams( { id_sujet:threadId, message:message } );
			_netConnectionManager.call("useClass", [callbackSuccess, callbackMaxAttempts, callbackFail], screenName, maxAttempts, "ServiceClient", "creationMessage", params);
		}
		
		/**
		 * 
		 */		
		public function initCustomerService(callbackSuccess:Function, callbackFail:Function, callbackMaxAttempts:Function = null, maxAttempts:int = -1, screenName:String = "default"):void
		{
			_netConnectionManager.call("useClass", [callbackSuccess, callbackMaxAttempts, callbackFail], screenName, maxAttempts, "ServiceClient", "init", getGenericParams());
		}
		
		/**
		 * Updates only the FAQ translations (and add new ones if there were not already there).
		 */		
		public function getFaq(callbackSuccess:Function, callbackFail:Function, callbackMaxAttempts:Function = null, maxAttempts:int = -1, screenName:String = "default"):void
		{
			var params:Object = getGenericParams();
			params.version = Localizer.getInstance().getFaqVersion();
			_netConnectionManager.call("useClass", [callbackSuccess, callbackMaxAttempts, callbackFail], screenName, maxAttempts, "Accueil", "getFAQ", params);
		}
		
		/**
		 * Updates only the VIP translations (and add new ones if there were not already there).
		 */		
		public function getVip(callbackSuccess:Function, callbackFail:Function, callbackMaxAttempts:Function = null, maxAttempts:int = -1, screenName:String = "default"):void
		{
			var params:Object = getGenericParams();
			params.version = Localizer.getInstance().getVipVersion();
			_netConnectionManager.call("useClass", [callbackSuccess, callbackMaxAttempts, callbackFail], screenName, maxAttempts, "Accueil", "getVIP", params);
		}
		
		/**
		 * 
		 */		
		public function getNews(callbackSuccess:Function, callbackFail:Function, callbackMaxAttempts:Function = null, maxAttempts:int = -1, screenName:String = "default"):void
		{
			var params:Object = getGenericParams();
			params.version = Localizer.getInstance().getNewsVersion();
			_netConnectionManager.call("useClass", [callbackSuccess, callbackMaxAttempts, callbackFail], screenName, maxAttempts, "Accueil", "getActualites", params);
		}
		
		/**
		 * Retreive the tournament ranking (id in parameter)
		 */		
		public function getCurrentTournamentRanking(tournamentId:int, callbackSuccess:Function, callbackFail:Function, callbackMaxAttempts:Function = null, maxAttempts:int = -1, screenName:String = "default"):void
		{
			var params:Object;
			if( !tournamentId )
				params = getGenericParams();
			else
				params = mergeWithGenericParams( { id_tournoi:tournamentId } );
			_netConnectionManager.call("useClass", [callbackSuccess, callbackMaxAttempts, callbackFail], screenName, maxAttempts, "Tournoi", "getClassementTournoi", params);
		}
		
		/**
		 * Retreive the list of previous tournaments (10 by default).
		 */		
		public function getPreviousTournaments(callbackSuccess:Function, callbackFail:Function, callbackMaxAttempts:Function = null, maxAttempts:int = -1, screenName:String = "default"):void
		{
			_netConnectionManager.call("useClass", [callbackSuccess, callbackMaxAttempts, callbackFail], screenName, maxAttempts, "Tournoi", "getDerniersTournoisTerminer", getGenericParams());
		}
		
		/**
		 * 
		 */		
		public function getInfBloc(tournamentId:int, rank:int, stars:int, date:String, callbackSuccess:Function, callbackFail:Function, callbackMaxAttempts:Function = null, maxAttempts:int = -1, screenName:String = "default"):void
		{
			var params:Object = mergeWithGenericParams( { id_tournoi:tournamentId, reference:rank, score_membre:stars, date_score:date } );
			_netConnectionManager.call("useClass", [callbackSuccess, callbackMaxAttempts, callbackFail], screenName, maxAttempts, "Tournoi", "getClassementInf", params);
		}
		
		/**
		 * 
		 */		
		public function getSupBloc(tournamentId:int, rank:int, stars:int, date:String, callbackSuccess:Function, callbackFail:Function, callbackMaxAttempts:Function = null, maxAttempts:int = -1, screenName:String = "default"):void
		{
			var params:Object = mergeWithGenericParams( { id_tournoi:tournamentId, reference:rank, score_membre:stars, date_score:date } );
			_netConnectionManager.call("useClass", [callbackSuccess, callbackMaxAttempts, callbackFail], screenName, maxAttempts, "Tournoi", "getClassementSup", params);
		}
		
		/**
		 * 
		 */		
		public function parrainer(type:String, filleuls:Array, callbackSuccess:Function, callbackFail:Function, callbackMaxAttempts:Function = null, maxAttempts:int = -1, screenName:String = "default"):void
		{
			var params:Object = mergeWithGenericParams( { type:type, parrainages:filleuls } );
			_netConnectionManager.call("useClass", [callbackSuccess, callbackMaxAttempts, callbackFail], screenName, maxAttempts, "Parrainage", "parrainer", params);
		}
		
		/**
		 * 
		 */		
		public function getFilleuls(callbackSuccess:Function, callbackFail:Function, callbackMaxAttempts:Function = null, maxAttempts:int = -1, screenName:String = "default"):void
		{
			_netConnectionManager.call("useClass", [callbackSuccess, callbackMaxAttempts, callbackFail], screenName, maxAttempts, "Parrainage", "suivi_filleul", getGenericParams());
		}
		
		/**
		 * 
		 */		
		public function initParrainage(callbackSuccess:Function, callbackFail:Function, callbackMaxAttempts:Function = null, maxAttempts:int = -1, screenName:String = "default"):void
		{
			_netConnectionManager.call("useClass", [callbackSuccess, callbackMaxAttempts, callbackFail], screenName, maxAttempts, "Parrainage", "init", getGenericParams());
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
			_netConnectionManager.call("useClass", [callbackSuccess, callbackMaxAttempts, callbackFail], screenName, maxAttempts, "Compte", "majPseudoPays", params);
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
		 * Retreive the payments history.
		 */		
		public function getPaymentsHistory(callbackSuccess:Function, callbackFail:Function, callbackMaxAttempts:Function = null, maxAttempts:int = -1, screenName:String = "default"):void
		{
			_netConnectionManager.call("useClass", [callbackSuccess, callbackMaxAttempts, callbackFail], screenName, maxAttempts, "Compte", "getHistoriquePaiement", getGenericParams());
		}
		
		/**
		 * Retreive the account history.
		 * 
		 * <p>startIndex here is the sum of _dataProvider.data[i].children.length</p>
		 */		
		public function getAccountHistory(startIndex:int, count:int, callbackSuccess:Function, callbackFail:Function, callbackMaxAttempts:Function = null, maxAttempts:int = -1, screenName:String = "default"):void
		{
			var params:Object = mergeWithGenericParams( { debut:startIndex, limite:count } );
			_netConnectionManager.call("useClass", [callbackSuccess, callbackMaxAttempts, callbackFail], screenName, maxAttempts, "Compte", "getHistoriqueCompte", params);
		}
		
		/**
		 * Resends a validation email.
		 */		
		public function resendValidationEmail(callbackSuccess:Function, callbackFail:Function, callbackMaxAttempts:Function = null, maxAttempts:int = -1, screenName:String = "default"):void
		{
			_netConnectionManager.call("useClass", [callbackSuccess, callbackMaxAttempts, callbackFail], screenName, maxAttempts, "Compte", "getMailValidation", getGenericParams());
		}
		
		/**
		 * Retreive de gifts history.
		 * 
		 * <p>startIndex here is the sum of _dataProvider.data[i].children.length</p>
		 */		
		public function getGiftsHistory(startIndex:int, count:int, callbackSuccess:Function, callbackFail:Function, callbackMaxAttempts:Function = null, maxAttempts:int = -1, screenName:String = "default"):void
		{
			var params:Object = mergeWithGenericParams( { debut:startIndex, limite:count } );
			_netConnectionManager.call("useClass", [callbackSuccess, callbackMaxAttempts, callbackFail], screenName, maxAttempts, "Gains", "getHistoriqueGains", params);
		}
		
		public function initGifts(callbackSuccess:Function, callbackFail:Function, callbackMaxAttempts:Function = null, maxAttempts:int = -1, screenName:String = "default"):void
		{
			_netConnectionManager.call("useClass", [callbackSuccess, callbackMaxAttempts, callbackFail], screenName, maxAttempts, "Gains", "init", getGenericParams());
		}
		
		public function exchangeWithCheque(idGain:int, tableType:String, callbackSuccess:Function, callbackFail:Function, callbackMaxAttempts:Function = null, maxAttempts:int = -1, screenName:String = "default"):void
		{
			var params:Object = mergeWithGenericParams( { id_gain:idGain, type_table:tableType } );
			_netConnectionManager.call("useClass", [callbackSuccess, callbackMaxAttempts, callbackFail], screenName, maxAttempts, "Gains", "echangerChequeCadeauCheque", params);
		}
		
		public function exchangeWithPoints(idGain:int, tableType:String, callbackSuccess:Function, callbackFail:Function, callbackMaxAttempts:Function = null, maxAttempts:int = -1, screenName:String = "default"):void
		{
			var params:Object = mergeWithGenericParams( { id_gain:idGain, type_table:tableType } );
			_netConnectionManager.call("useClass", [callbackSuccess, callbackMaxAttempts, callbackFail], screenName, maxAttempts, "Gains", "echangerLotPoints", params);
		}
		
// Store
		
		public function getProductIds(callbackSuccess:Function, callbackFail:Function, callbackMaxAttempts:Function = null, maxAttempts:int = -1, screenName:String = "default"):void
		{
			_netConnectionManager.call("useClass", [callbackSuccess, callbackMaxAttempts, callbackFail], screenName, maxAttempts, "AchatCredits", "getListeOffres", getGenericParams());
		}
		
		public function createRequest(productNumberId:int, callbackSuccess:Function, callbackFail:Function, callbackMaxAttempts:Function = null, maxAttempts:int = -1, screenName:String = "default"):void
		{
			var params:Object = mergeWithGenericParams( { id_offre:productNumberId } ); 
			_netConnectionManager.call("useClass", [callbackSuccess, callbackMaxAttempts, callbackFail], screenName, maxAttempts, "AchatCredits", "creationDemande", params);
		}
		
		public function validateRequest(productData:StoreData, result:Object, request:Object, callbackSuccess:Function, callbackFail:Function, callbackMaxAttempts:Function = null, maxAttempts:int = -1, screenName:String = "default"):void
		{
			log("\n\nValidate request : ");
			
			var params:Object = mergeWithGenericParams( { code_paiement:productData.paymentCode, code_retour:result, id_offre:productData.databaseOfferId, id_demande:request.id } );
			_netConnectionManager.call("useClass", [callbackSuccess, callbackMaxAttempts, callbackFail], screenName, maxAttempts, "AchatCredits", "paiementAccepte", params);
		}
		public function changeRequestState(productData:StoreData, request:Object, state:int, callbackSuccess:Function, callbackFail:Function, callbackMaxAttempts:Function = null, maxAttempts:int = -1, screenName:String = "default"):void
		{
			var params:Object = mergeWithGenericParams( { id_offre:productData.id, id_demande:request.id, etat:state } );
			_netConnectionManager.call("useClass", [callbackSuccess, callbackMaxAttempts, callbackFail], screenName, maxAttempts, "AchatCredits", "changementEtatDemande", params);
		}
		
		
		
		
		public function getAlerts(callbackSuccess:Function, callbackFail:Function, callbackMaxAttempts:Function = null, maxAttempts:int = -1, screenName:String = "default"):void
		{
			_netConnectionManager.call("useClass", [callbackSuccess, callbackMaxAttempts, callbackFail], screenName, maxAttempts, "Menu", "Init", getGenericParams());
		}
		
		
		
		
		/**
		 * Save the device settings
		 */		
		public function sendSettings(data:Object, callbackSuccess:Function, callbackFail:Function, callbackMaxAttempts:Function = null, maxAttempts:int = -1, screenName:String = "default"):void
		{
			var params:Object = getGenericParams();
			data.os = Capabilities.os;
			params.obj_reglages = data;
			_netConnectionManager.call("useClass", [callbackSuccess, callbackMaxAttempts, callbackFail], screenName, maxAttempts, "Reglages", "maj", params);
		}
		
		/**
		 * Save the device settings
		 */		
		public function getBoutiqueCategories(callbackSuccess:Function, callbackFail:Function, callbackMaxAttempts:Function = null, maxAttempts:int = -1, screenName:String = "default"):void
		{
			_netConnectionManager.call("useClass", [callbackSuccess, callbackMaxAttempts, callbackFail], screenName, maxAttempts, "Boutique", "listingBoutiqueCategorie", getGenericParams());
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
		
//------------------------------------------------------------------------------------------------------------
//	Handlers
//------------------------------------------------------------------------------------------------------------
		
		/**
		 * Generic function called when a query have been sent successfully.
		 * 
		 * <p>If there is a Member object in the result, this function will
		 * also try to parse this object to update the internal MemberData.</p>
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
				NotificationManager.addNotification(new InvalidSessionNotification());
				InfoManager.hide("", InfoContent.ICON_NOTHING, 0); // just in case
			}
			else
			{
				result.queryName = queryName;
				
				if( queryName == "LudoMobile.useClass.Identification.logIn" || queryName == "LudoMobile.useClass.Inscription.nouveauJoueur" )
				{
					if( result.code == 1 || result.code == 6 || result.code == 7 || result.code == 8 || result.code == 9 || result.code == 11 || result.code == 12 && !MemberManager.getInstance().getAnonymousGameSessionsAlreadyUsed() )
					{
						log("[Remote] Inscription ou connexion réussie, parties anonymes retirées.");
						MemberManager.getInstance().setAnonymousGameSessionsAlreadyUsed(true);
						MemberManager.getInstance().setNumFreeGameSessions(0);
						MemberManager.getInstance().setPoints(0);
						MemberManager.getInstance().setCumulatedStars(0);
						MemberManager.getInstance().setAnonymousGameSessions([]);
					}
				}
				
				if( "obj_membre_mobile" in result && result.obj_membre_mobile)
				{
					MemberManager.getInstance().parseData(result.obj_membre_mobile);
					dispatchEventWith(LudoEventType.UPDATE_SUMMARY);
				}
				
				if( MemberManager.getInstance().isLoggedIn() && "highscore" in result )
					MemberManager.getInstance().setHighscore( int(result.highscore) );
				
				if( MemberManager.getInstance().isLoggedIn() && "tab_trophy_win" in result )
					MemberManager.getInstance().setTrophiesWon( result.tab_trophy_win as Array ); // TODO peut être afficher les trophées ici ? canWin... si oui => onWinTrophy...
				
				if( MemberManager.getInstance().isLoggedIn() && "acces_tournoi" in result &&  queryName != "LudoMobile.useClass.ServeurJeux.pushPartie" )
				{
					MemberManager.getInstance().setTournamentUnlocked( int(result.acces_tournoi) == 1 ? true : false );
					//MemberManager.getInstance().setTournamentAnimPending( false ); // sinon pas d'anim quand partie classique => popup marketing => inscription => acccueil
					MemberManager.getInstance().setDisplayTutorial( int(result.acces_tournoi) == 1 ? false : true );
				}
				
				if( callbackSuccess )
					callbackSuccess(result);
			}
			
			if( Boolean(Storage.getInstance().getProperty(StorageConfig.PROPERTY_FORCE_UPDATE)) == false )
			{
				// go here only if we didn't already request an update
				if( "forceDownload" in result && result.forceDownload != null && int(result.forceDownload) == 1 )
				{
					// we need the user to update the game, in this case we change the property FORCE_UPDATE to true,
					// then we need to update the stored game version so that we can later check if the update was
					// made or not (i.e. if the actual game version is higher than the stored one at the moment we
					// requested the update
					log("[Remote] onQueryComplete : The user must update its application version (forceDownload = 1).");
					Storage.getInstance().setProperty(StorageConfig.PROPERTY_FORCE_UPDATE, true);
					Storage.getInstance().setProperty(StorageConfig.PROPERTY_FORCE_UPDATE_LINK, result.lien_application);
					Storage.getInstance().setProperty(StorageConfig.PROPERTY_GAME_VERSION, AbstractGameInfo.GAME_VERSION);
				}
			}
			
		}
		
		/**
		 * Fonction générale appelée en cas d'échec d'exécution de la requête.
		 */ 
		protected function onQueryFail(error:Object, queryName:String, callback:Function):void
		{
			// set up query name in the object
			if( error ) error.queryName = queryName;
			else error = { queryName:queryName }
			
			if( callback )
				callback( error );
			
			try
			{
				if( error.queryName == "useClass" )
					error.queryName += "\n onQueryFail : Une requête a échoué.";
				Flox.logError(log(error), "<br><br><strong>Erreur PHP :</strong><br><strong>Requête : </strong>{0}<br><strong>FaultCode : </strong>{1}<br><strong>FaultString : </strong>{2}<br><strong>FaultDetail :</strong><br>{3}", error.queryName, error.faultCode, error.faultString, error.faultDetail);
				if( GlobalConfig.DEBUG )
					ErrorDisplayer.showError(formatString("<strong>Erreur PHP :</strong><br><br><strong>Requête : </strong>{0}<br><br><strong>FaultCode : </strong>{1}<br><br><strong>FaultString : </strong>{2}<br><br><strong>FaultDetail :</strong><br>{3}", error.queryName, error.faultCode, error.faultString, error.faultDetail));
			} 
			catch(error:Error) 
			{
				
			}
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
			genericParam.id_membre = MemberManager.getInstance().getId();
			genericParam.mail = MemberManager.getInstance().getMail();
			genericParam.mdp = MemberManager.getInstance().getPassword();
			genericParam.langue = Localizer.getInstance().lang;
			genericParam.id_jeu = AbstractGameInfo.GAME_ID;
			genericParam.type_appareil = GlobalConfig.isPhone ? "smartphone":"tablette";
			genericParam.plateforme = GlobalConfig.platformName;
			genericParam.id_appareil = GlobalConfig.deviceId;
			genericParam.version_jeu = AbstractGameInfo.GAME_VERSION;
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
		
		/**
		 * For login, login with Facebook, account creation and account creation
		 * with Facebook, this function will add an extra parameter containing all
		 * anonymous game sessions so that they can be taken in account when the user
		 * either login or create an account.
		 */		
		private function addAnonymousGameSessionsIfNeeded( params:Object ):Object
		{
			params.parties = [];
			params.acces_tournoi = MemberManager.getInstance().getTournamentUnlocked() == true ? 1 : 0;
			if( !MemberManager.getInstance().getAnonymousGameSessionsAlreadyUsed() )
			{
				// we can send them
				var gameSession:GameSession;
				var len:int = MemberManager.getInstance().getAnonymousGameSessions().length;
				for(var i:int = 0; i < len; i++)
				{
					gameSession = MemberManager.getInstance().getAnonymousGameSessions()[i];
					params.parties.push( { info_client:GlobalConfig.userHardwareData, type_mise:gameSession.gamePrice, type_partie:gameSession.gameType, score:gameSession.score, date_partie:gameSession.playDate, connected:gameSession.connected, coupes:gameSession.trophiesWon, temps_ecoule:gameSession.elapsedTime, id_partie:gameSession.uniqueId } );
				}
				
				Flox.logEvent("Nombre de parties jouées avant authentification", { Nombre:len });
			}
			return params;
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