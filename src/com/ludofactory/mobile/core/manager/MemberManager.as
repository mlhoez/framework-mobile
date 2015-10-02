/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 12 Août 2013
*/
package com.ludofactory.mobile.core.manager
{
	
	import com.gamua.flox.Flox;
	import com.ludofactory.common.encryption.Encryption;
	import com.ludofactory.common.utils.log;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.AbstractGameInfo;
	import com.ludofactory.mobile.core.AbstractMain;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.events.MobileEventTypes;
	import com.ludofactory.mobile.core.model.GameMode;
	import com.ludofactory.mobile.core.push.AbstractElementToPush;
	import com.ludofactory.mobile.core.push.GameSession;
	import com.ludofactory.mobile.core.push.PushNewCSMessage;
	import com.ludofactory.mobile.core.push.PushNewCSThread;
	import com.ludofactory.mobile.core.push.PushTrophy;
	import com.ludofactory.mobile.core.remoting.Remote;
	import com.ludofactory.mobile.navigation.achievements.GameCenterManager;
	import com.milkmangames.nativeextensions.GAnalytics;
	import com.milkmangames.nativeextensions.GoViral;
	import com.vidcoin.extension.ane.VidCoinController;
	
	import flash.data.EncryptedLocalStore;
	import flash.net.registerClassAlias;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	import starling.events.EventDispatcher;
	
	/**
	 * Member manager.
	 * 
	 * This class handles the update of the stored members.
	 */	
	public class MemberManager extends EventDispatcher
	{
		/**
		 * Helper ByteArray (avoiding too much instanciations). */		
		private var HELPER_BYTE_ARRAY:ByteArray;
		
		/**
		 * MemberManager instance. */		
		private static var _instance:MemberManager;
		
		/**
		 * The default member id (0). */		
		private const DEFAULT_MEMBER_ID:int = 0;
		
		/**
		 * The name used to retreive the last logged in member id (0 for the default member). */		
		private const LAST_LOGGED_IN_MEMBER_ID:String = "LoggedinMemberId";
		
		/**
		 * The base name used to retreive a member in the EncryptedLocalStore. This
		 * value will be suffixed by a member id in order to retrieve a specific member. */		
		private const MEMBER_ACCESS_PREFIX:String = "Member_";
		
		/**
		 * The current member data. */		
		private var _member:Member;
		
		/**
		 * Encryption used to encrypt / decrypt a member instance. */		
		private var _encryption:Encryption;
		
		public function MemberManager(sk:SecurityKey)
		{
			if( sk == null)
				throw new Error("[MemberManager] You must call MamberManager.getInstance instead of new.");
			
			registerClassAlias("AbstractElementToPushClass", AbstractElementToPush);
			registerClassAlias("GameSessionClass", GameSession);
			registerClassAlias("PushTrophyClass", PushTrophy);
			registerClassAlias("PushNewCSThreadClass", PushNewCSThread);
			registerClassAlias("PushNewCSMessageClass", PushNewCSMessage);
			registerClassAlias("MemberClass", Member);
			
			// this value cannot change once the application have been released,
			// or each device won't be able to decrypt the previously stored data
			_encryption = new Encryption("e9Dfc8f4");
			
			HELPER_BYTE_ARRAY = new ByteArray();
			
			// retrieve the id of the last logged in member. If the ByteArray is null, it
			// means that no one have logged in already (probably because it is the first
			// launch of the application) or the ELS have been cleared for some reason.
			// Otherwise we simply read the member id and we load it.
			HELPER_BYTE_ARRAY = EncryptedLocalStore.getItem( LAST_LOGGED_IN_MEMBER_ID );	
			loadEncryptedMember( HELPER_BYTE_ARRAY == null ? DEFAULT_MEMBER_ID : HELPER_BYTE_ARRAY.readInt(), false );
		}
		
//------------------------------------------------------------------------------------------------------------
//	Parse / Encrypt / Decrypt
		
		/**
		 * Parses a member data coming from php.
		 * 
		 * @param memberData The data to parse
		 */		
		public function parseData(memberData:Object):void
		{
			// if the id is different from the actual one, we need load the new one so that we don't affect someone's
			// data to someone else (this should not happen actually, but leave it by security)
			if( "id_membre" in memberData && int(memberData.id_membre) != _member.id )
				loadEncryptedMember( int(memberData.id_membre) );
			
			_member.parseData(memberData);
			setEncryptedMember();
			
			// check if we can enable logs
			AbstractMain.checkToEnableLogs();
		}
		
		/**
		 * Loads the Member instance from the ELS for the given member id.
		 * 
		 * <p>If there is no encrypted Member (if the ByteArray is null) for this id,
		 * then the function will create a new Member instance for this id.</p>
		 * 
		 * <p>To decrypt the data from the ELS, this function will :
		 * 		- Retrieve the ByteArray from the EncryptedLocalStore
		 * 		- Read this ByteArray as a String (which is the Base64 encoded value of the ByteArray of the member)
		 * 		- Decrypt this String the get a non encrypted ByteArray and read it as a Member</p>
		 * 
		 * @see com.ludofactory.common.encryption.Encryption
		 */		
		private function loadEncryptedMember(memberId:int, checkForAdminParameters:Boolean = true):void
		{
			// clear all actual responders for security reasons
			Remote.getInstance().clearAllResponders();
			
			// update the current (and last) logged in member id in the ELS
			if( HELPER_BYTE_ARRAY == null ) HELPER_BYTE_ARRAY = new ByteArray();
			HELPER_BYTE_ARRAY.clear();
			HELPER_BYTE_ARRAY.writeInt( memberId );
			EncryptedLocalStore.setItem(LAST_LOGGED_IN_MEMBER_ID, HELPER_BYTE_ARRAY);
			
			// then retreive the associated member from the ELS
			HELPER_BYTE_ARRAY.clear();
			HELPER_BYTE_ARRAY = EncryptedLocalStore.getItem(MEMBER_ACCESS_PREFIX + memberId);
			// if the ByteArray is null, it means that this is the first time 
			// the user log in with this id so we need to create a new Member
			// instance to affect this id. Otherwise, we simply decrypt the
			// instance that we got from the ELS
			try
			{
				_member = HELPER_BYTE_ARRAY == null ? new Member() : _encryption.decryptToByteArray( HELPER_BYTE_ARRAY.readUTFBytes(HELPER_BYTE_ARRAY.bytesAvailable) ).readObject();
			}
			catch(error:Error)
			{
				Flox.logError("Erreur de décryptage de l'objet membre : " + error.message);
				EncryptedLocalStore.reset();
				loadEncryptedMember(DEFAULT_MEMBER_ID);
				return;
			}
			if( HELPER_BYTE_ARRAY == null ) HELPER_BYTE_ARRAY = new ByteArray();
			
			if( memberId != DEFAULT_MEMBER_ID )
			{
				if( AbstractEntryPoint.pushManager )
					AbstractEntryPoint.pushManager.onUserLoggedIn();
				
				// track the log in
				try{
					
				if( GAnalytics.isSupported() )
					GAnalytics.analytics.defaultTracker.trackEvent("Connexions", "Connexion au compte", null, NaN, memberId);
				}
				catch(error:Error)
				{
					
				}
				//log("<strong>Connexion du joueur " + memberId + "</strong>");
				
				updateVidCoinData();
			}
			
			// update the values of the footer
			dispatchEventWith(MobileEventTypes.UPDATE_SUMMARY);
			
			if( checkForAdminParameters ) // not done the first time
				AbstractMain.checkToEnableLogs();
		}
		
		public function updateVidCoinData():void
		{
			if( AbstractEntryPoint.vidCoin )
			{
				var dict:Dictionary = new Dictionary();
				dict[VidCoinController.kVCUserGameID] = _member.id;
				dict[VidCoinController.kVCUserBirthYear] = birthDate.split("-")[0];
				dict[VidCoinController.kVCUserGenderKey]= title == "Mr." ? VidCoinController.kVCUserGenderMale : VidCoinController.kVCUserGenderFemale;
				AbstractEntryPoint.vidCoin.updateUserDictionary(dict);
			}
		}
		
		/**
		 * Stores a encrypted version of the ByteArray representation of the actual
		 * member in the EncryptedLocalStore.
		 * 
		 * <p>Before being stored in the ELS, this function will :
		 * 		- Convert the member to a ByteArray
		 * 		- Encrypt this ByteArray (internally) and encode it to a Base64 String
		 * 		- Create a ByteArray from this String and upload it to the ELS</p>
		 */		
		private function setEncryptedMember():void
		{
			// convert the member to a ByteArray
			HELPER_BYTE_ARRAY.clear();
			HELPER_BYTE_ARRAY.writeObject(_member);
			
			// encrypt the ByteArray with the static encryption key
			var encryptedMember:String = _encryption.encryptByteArray(HELPER_BYTE_ARRAY);
			
			// convert the encrypted value to a storable ByteArray
			HELPER_BYTE_ARRAY.clear();
			HELPER_BYTE_ARRAY.writeUTFBytes(encryptedMember);
			
			// store the value in the ELS
			EncryptedLocalStore.setItem(MEMBER_ACCESS_PREFIX + _member.id, HELPER_BYTE_ARRAY);
			HELPER_BYTE_ARRAY.clear();
		}
		
//------------------------------------------------------------------------------------------------------------
//	Utils
		
		/**
		 * Disconnects the actual member (no data will be cleared) and load the default
		 * member (whose id is 0).
		 * 
		 * <p>IMPORTANT : if the PushManager is currently pushing something, we need to
		 * lock this action so that the current push can be finished safely.</p>
		 */		
		public function disconnect():void
		{
			if( AbstractEntryPoint.pushManager.isPushing )
			{
				// just in case
				InfoManager.hide("", InfoContent.ICON_NOTHING, 0, InfoManager.show, ["Vous avez des données en cours d'envoi, merci de patienter quelques secondes..."]);
				// lock the push
				AbstractEntryPoint.pushManager.needsLock = true;
				AbstractEntryPoint.pushManager.callback = MemberManager.getInstance().disconnect;
				return;
			}
			
			InfoManager.hide("Toutes les données ont été envoyées.\n\nVous pouvez changer de compte.", InfoContent.ICON_CHECK);
			
			// track the log off
			try{
				
			if( GAnalytics.isSupported() )
				GAnalytics.analytics.defaultTracker.trackEvent("Déconnexions", "Déconnexion du compte", null, NaN, _member.id);
			}
			catch(error:Error)
			{
				
			}
			log("<strong>Déconnexion du joueur (" + _member.id + ")</strong>");
			
			// before the user log off, we save the state of the tournament and
			// we set the the animation pending to false for the current user
			var tournamentUnlocked:Boolean = _member.tournamentUnlocked;
			setTournamentAnimPending(false);
			
			AbstractEntryPoint.screenNavigator.screenData.displayPopupOnHome = false;
			AbstractEntryPoint.isSelectingPseudo = false;
			
			loadEncryptedMember( DEFAULT_MEMBER_ID );
			AbstractEntryPoint.pushManager.onUserLoggedOut();
			AbstractEntryPoint.alertData.onUserLoggedOut();
			AbstractEntryPoint.eventManager.onUserLoggedOut();
			
			if( !_member.tournamentUnlocked && tournamentUnlocked )
				setTournamentUnlocked(true);
			
			// clear Facebook session
			if( GoViral.isSupported() && GoViral.goViral.isFacebookSupported() )
				GoViral.goViral.logoutFacebook();
			
			AbstractMain.checkToEnableLogs();
		}
		
		/**
		 * Whether the user is logged in.
		 */		
		public function isLoggedIn():Boolean { return !(_member.id == DEFAULT_MEMBER_ID); }
		
//------------------------------------------------------------------------------------------------------------
//	Get - Set (new)
		
		/**
		 * The member id. */
		public function get id():Number { return _member.id; }
		/**
		 * The member Facebook id. */
		public function get facebookId():Number { return _member.facebookId; }
		/**
		 * The member email. */
		public function get email():String { return _member.mail; }
		/**
		 * The member password */
		public function get password():String { return _member.password; }
		/**
		 * The member pseudo. */
		public function get pseudo():String { return _member.pseudo; }
		/**
		 * The member birth date. */
		public function get birthDate():String { return _member.birthDate; }
		/**
		 * The member title. */
		public function get title():String { return _member.title; }
		/**
		 * The member rank. */
		public function get rank():int { return _member.rank; }
		/**
		 * The member number of credits bought. */
		public function get numCreditsBought():int { return _member.numCreditsBought; }
		/**
		 * The update date (when the member object have been updated for the last time). */
		public function get lastUpdateDate():String { return _member.updateDate; }
		
		/**
		 * The last trophy won id. */
		public function get lastTrophyWonId():int { return _member.lastTrophyWonId; }
		public function set lastTrophyWonId(val:int):void
		{
			if( _member.lastTrophyWonId != val )
			{
				_member.lastTrophyWonId = val;
				setEncryptedMember();
			}
		}
		
		/**
		 * The member number of cumulated rubies for the current tournament. */
		public function get cumulatedRubies():int { return _member.cumulatedStars; }
		public function set cumulatedRubies(val:int):void
		{
			if( _member.cumulatedStars != val )
			{
				_member.cumulatedStars= val;
				setEncryptedMember();
			}
		}
		
		/**
		 * The member won trophies. */
		public function get trophiesWon():Array { return _member.trophiesWon; }
		public function set trophiesWon(val:Array):void
		{
			var len:int = val.length;
			for(var i:int = 0; i < len; i++)
			{
				if( _member.trophiesWon.indexOf( int(val[i]) ) == -1 )
				{
					_member.trophiesWon = val;
					setEncryptedMember();
					return;
				}
			}
			
			if(GlobalConfig.ios)
			{
				// we need to report the achievements on iOS too
				for (var j:int = 0; j < val.length; j++)
					GameCenterManager.reportAchievement(AbstractGameInfo.ACHIEVEMENTS_PREFIX + "." + val[j], 100);
			}
		}
		
		/**
		 * The member number of credits. */
		public function get credits():int { return _member.credits; }
		public function set credits(val:int):void
		{
			if( _member.credits != val )
			{
				_member.credits = val;
				setEncryptedMember();
				
				// the data changed, so we need to update the footer
				dispatchEventWith(MobileEventTypes.UPDATE_SUMMARY);
			}
		}
		
		/**
		 * The member number of points. */
		public function get points():int { return _member.points; }
		public function set points(val:int):void
		{
			if( _member.points != val )
			{
				_member.points = val;
				setEncryptedMember();
				
				// the data changed, so we need to update the footer
				dispatchEventWith(MobileEventTypes.UPDATE_SUMMARY);
			}
		}
		
		/**
		 * The member number of tokens. */
		public function get tokens():int { return _member.numTokens; }
		public function set tokens(val:int):void
		{
			if( _member.numTokens != val )
			{
				_member.numTokens = val;
				setEncryptedMember();
				
				// the data changed, so we need to update the footer
				dispatchEventWith(MobileEventTypes.UPDATE_SUMMARY);
			}
		}
		
		/**
		 * The array of anonymous game sessions. */
		public function get anonymousGameSessions():Array { return _member.anonymousGameSessions; }
		public function set anonymousGameSessions(val:Array):void
		{
			_member.anonymousGameSessions = val;
			setEncryptedMember();
		}
		
		/**
		 * The array of transaction ids. */
		public function get transactionIds():Array { return _member.transactionIds; }
		public function set transactionIds(val:Array):void
		{
			_member.transactionIds = val;
			setEncryptedMember();
		}
		
		/** 
		 * The member total of tokens available for a day. */
		public function get totalTokensADay():int { return _member.totalTokensADay; }
		
		/**
		 * The member total of bonus tokens for a day. */
		public function get totalBonusTokensADay():int { return _member.totalBonusTokensADay; }
		
		/**
		 * The highscore is updated only when a push of a GameSession has failed (if there is a highscore of course),
		 * and on the handler onQueryComplete of Remote. */
		public function get highscore():int { return _member.highscore; }
		public function set highscore(val:int):void
		{
			if( _member.highscore < val )
			{
				_member.highscore = val;
				setEncryptedMember();
			}
		}
		
		/**
		 * The member elements to push. */
		public function get elementsToPush():Vector.<AbstractElementToPush> { return _member.elementsToPush; }
		public function set elementsToPush(val:Vector.<AbstractElementToPush>):void
		{
			_member.elementsToPush = val;
			setEncryptedMember();
		}
		
//------------------------------------------------------------------------------------------------------------
//	Get - Set
		
		/**
		 * Updates the value of <code>displayTutorial</code>.
		 */		
		public function setDisplayTutorial(val:Boolean):void
		{
			if( _member.displayTutorial != val )
			{
				_member.displayTutorial = val;
				setEncryptedMember();
			}
		}
		
		/**
		 * Updates the value of <code>tournamentAnimPending</code>.
		 */		
		public function setTournamentAnimPending(val:Boolean):void
		{
			if( _member.tournamentAnimPending != val )
			{
				_member.tournamentAnimPending = val;
				setEncryptedMember();
			}
		}
		
		/**
		 * Updates the value of <code>tournamentUnlocked</code>.
		 */		
		public function setTournamentUnlocked(val:Boolean):void
		{
			if( _member.tournamentUnlocked != val )
			{
				_member.tournamentUnlocked = val;
				setEncryptedMember();
			}
		}
		
		public function setGetGiftsEnabled(value:Boolean):void
		{
			_member.giftsEnabled = value;
		}
		
		public function setFacebookToken(value:String):void
		{
			_member.facebookToken = value;
		}
		
		public function setFacebookTokenExpiryTimestamp(value:Number):void
		{
			_member.facebookTokenExpiryTimestamp = value;
		}
		
		/** Returns */		
		public function getCountryId():int { return _member.countryId; }
		/** Returns */		
		public function getDisplayTutorial():Boolean { return _member.displayTutorial; }
		/** Returns */		
		public function getTournamentAnimPending():Boolean { return _member.tournamentAnimPending; }
		/** Returns */		
		public function getTournamentUnlocked():Boolean { return _member.tournamentUnlocked; }
        /** Returns */
        public function getGiftsEnabled():Boolean { return _member.giftsEnabled; }
		/** Returns */
		public function getCanWatchVideo():Boolean { return _member.canWatchVideo; }
		/** Returns */
		public function isAdmin():Boolean { return (CONFIG::DEBUG == true) ? true : _member.isAdmin; }
		/** Returns */
		public function canDisplayInterstitial():Boolean { return _member.canDisplayInterstitial; }
		/** Returns */
		public function getFacebookToken():String { return _member.facebookToken; }
		/** Returns */
		public function getFacebookTokenExpiryTimestamp():Number { return _member.facebookTokenExpiryTimestamp; }
		
		public function getNumStarsEarnedInAnonymousGameSessions():int
		{
			var count:int = 0;
			var gameSession:GameSession;
			for(var i:int = 0; i < anonymousGameSessions.length; i++)
			{
				gameSession = anonymousGameSessions[i];
				if( gameSession.gameType == GameMode.TOURNAMENT )
					count += gameSession.numStarsOrPointsEarned;
			}
			return count;
		}
		
		public function getNumTrophiesEarnedInAnonymousGameSessions():int
		{
			var count:int = 0;
			var gameSession:GameSession;
			for(var i:int = 0; i < anonymousGameSessions.length; i++)
			{
				gameSession = anonymousGameSessions[i];
				if( gameSession.trophiesWon && gameSession.trophiesWon.length > 0 )
					count += gameSession.trophiesWon.length;
			}
			return count;
		}
		
		/**
		 * Return the MemberManager instance.
		 */		
		public static function getInstance():MemberManager
		{			
			if(_instance == null)
				_instance = new MemberManager( new SecurityKey() );			
			return _instance;
		}
	}
}

internal class SecurityKey{};