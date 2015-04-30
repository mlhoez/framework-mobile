/*
Copyright © 2006-2014 Ludo Factory
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
	import com.ludofactory.mobile.core.events.LudoEventType;
	import com.ludofactory.mobile.core.push.AbstractElementToPush;
	import com.ludofactory.mobile.core.push.GameSession;
	import com.ludofactory.mobile.core.push.PushNewCSMessage;
	import com.ludofactory.mobile.core.push.PushNewCSThread;
	import com.ludofactory.mobile.core.push.PushTrophy;
	import com.ludofactory.mobile.core.remoting.Remote;
	import com.milkmangames.nativeextensions.GoViral;
	import com.vidcoin.vidcoincontroller.VidCoinController;

	import eu.alebianco.air.extensions.analytics.Analytics;

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
			loadEncryptedMember( HELPER_BYTE_ARRAY == null ? DEFAULT_MEMBER_ID : HELPER_BYTE_ARRAY.readInt() );
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
			// if the id is different from the actual one, we need load the new one
			// so that we don't affect someone's data to someone else (this should
			// not happen actually, but leave it by security)
			if( "id_membre" in memberData && int(memberData.id_membre) != _member.id )
				loadEncryptedMember( int(memberData.id_membre) );
			
			_member.parseData(memberData);
			setEncryptedMember();
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
		private function loadEncryptedMember(memberId:int):void
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
				if( Analytics.isSupported() && AbstractEntryPoint.tracker )
					AbstractEntryPoint.tracker.buildEvent("Connexions", "-").withLabel("Compte (" + memberId + ")").track();
				log("<strong>Connexion du joueur " + memberId + "</strong>");
				
				updateVidCoinData();
			}
			
			// update the values of the footer
			dispatchEventWith(LudoEventType.UPDATE_SUMMARY);
		}
		
		public function updateVidCoinData():void
		{
			if( AbstractEntryPoint.vidCoin )
			{
				var dict:Dictionary = new Dictionary();
				dict[VidCoinController.kVCUserGameID] = getId();
				dict[VidCoinController.kVCUserBirthYear] = getBirthDate().split("-")[0];
				dict[VidCoinController.kVCUserGenderKey]= getTitle() == "Mr." ? VidCoinController.kVCUserGenderMale : VidCoinController.kVCUserGenderFemale;
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
			if( Analytics.isSupported() && AbstractEntryPoint.tracker )
				AbstractEntryPoint.tracker.buildEvent("Déconnexions", "-").withLabel("Compte prédécent (" + _member.id + ")").track();
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
			
			if( !_member.tournamentUnlocked && tournamentUnlocked )
				setTournamentUnlocked(true);
			
			// clear Facebook session
			if( GoViral.isSupported() && GoViral.goViral.isFacebookSupported() )
				GoViral.goViral.logoutFacebook();
		}
		
		/**
		 * Whether the user is logged in.
		 */		
		public function isLoggedIn():Boolean { return !(_member.id == DEFAULT_MEMBER_ID); }
		
//------------------------------------------------------------------------------------------------------------
//	Get - Set
		
		/**
		 * The highscore is updated only when a push of a GameSession has failed
		 * (if there is a highscore of course), and on the handler onQueryComplete
		 * of Remote.
		 * 
		 * @see com.ludofactory.mobile.core.remoting.Remote#onQueryComplete
		 */		
		public function setHighscore(val:int):void
		{
			if( _member.highscore < val )
			{
				_member.highscore = val;
				setEncryptedMember();
			}
		}
		
		/**
		 * Updates the number of free game sessions.
		 */		
		public function setNumFreeGameSessions(val:int):void
		{
			if( _member.numTokens != val )
			{
				_member.numTokens = val;
				setEncryptedMember();
				
				// the data changed, so we need to update the footer
				dispatchEventWith(LudoEventType.UPDATE_SUMMARY);
			}
		}
		
		/**
		 * Updates the number of credits.
		 */		
		public function setCredits(val:int):void
		{
			if( _member.credits != val )
			{
				_member.credits = val;
				setEncryptedMember();
				
				// the data changed, so we need to update the footer
				dispatchEventWith(LudoEventType.UPDATE_SUMMARY);
			}
		}
		
		/**
		 * Updates the number of points.
		 */		
		public function setPoints(val:int):void
		{
			if( _member.points != val )
			{
				_member.points = val;
				setEncryptedMember();
				
				// the data changed, so we need to update the footer
				dispatchEventWith(LudoEventType.UPDATE_SUMMARY);
			}
		}
		
		/**
		 * Updates the number of cumulated stars.
		 */		
		public function setCumulatedStars(val:int):void
		{
			if( _member.cumulatedStars != val )
			{
				_member.cumulatedStars= val;
				setEncryptedMember();
			}
		}
		
		/**
		 * Updates the list of won trophies.
		 */		
		public function setTrophiesWon(val:Array):void
		{
			var len:int = val.length;
			for(var i:int = 0; i < len; i++)
			{
				if( _member.trophiesWon.indexOf( val[i] ) == -1 )
				{
					_member.trophiesWon = val;
					setEncryptedMember();
					return;
				}
			}
		}
		
		/**
		 * Updates the elements to push.
		 */		
		public function setElementToPush(val:Vector.<AbstractElementToPush>):void
		{
			_member.elementsToPush = val;
			setEncryptedMember();
		}
		
		/**
		 * Updates the anonymous game sessions.
		 */		
		public function setAnonymousGameSessions(val:Array):void
		{
			_member.anonymousGameSessions = val;
			setEncryptedMember();
		}
		
		/**
		 * Updates the value of <code>anonymousGameSessionsAlreadyUsed</code>.
		 */		
		public function setAnonymousGameSessionsAlreadyUsed(val:Boolean):void
		{
			if( _member.anonymousGameSessionsAlreadyUsed != val )
			{
				_member.anonymousGameSessionsAlreadyUsed = val;
				setEncryptedMember();
			}
		}
		
		/**
		 * Updates the last trophy won id.
		 */		
		public function setLastTrophyWonId(val:int):void
		{
			if( _member.lastTrophyWonId != val )
			{
				_member.lastTrophyWonId = val;
				setEncryptedMember();
			}
		}
		
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
		
		/** Returns the member's id. */		
		public function getId():int { return _member.id; }
		/** Returns the member's highscore */		
		public function getHighscore():int { return _member.highscore; }
		/** Returns the member's Facebook id. */		
		public function getFacebookId():Number { return _member.facebookId; }
		/** Returns the member's mail. */		
		public function getMail():String { return _member.mail; }
		/** Returns the member's password. */		
		public function getPassword():String { return _member.password; }
		/** Returns the member's number of credits. */		
		public function getCredits():int { return _member.credits; }
		/** Returns the member's number of points. */		
		public function getPoints():int { return _member.points; }
		/** Returns the member's number of cumulated stars for the current tournament. */		
		public function getCumulatedStars():int { return _member.cumulatedStars; }
		/** Returns the member's number of free game sessions. */		
		public function getNumFreeGameSessions():int { return _member.numTokens; }
		/**  Returns the member's total of free game sessions. */		
		public function getTotalTokensADay():int { return _member.totalTokensADay; }
		/**  Returns the member's pseudo. */		
		public function getPseudo():String { return _member.pseudo; }
		/**  Returns the member's birth date. */
		public function getBirthDate():String { return _member.birthDate; }
		/**  Returns the member's title. */
		public function getTitle():String { return _member.title; }
		/** Returns the member's won trophies. */		
		public function getTrophiesWon():Array { return _member.trophiesWon; }
		/** Returns the member's rank. */		
		public function getRank():int { return _member.rank; }
		/** Returns the member's number of credits bought. */		
		public function getNumCreditsBought():int { return _member.numCreditsBought; }
		/** Returns the member's elements to push. */		
		public function getElementsToPush():Vector.<AbstractElementToPush> { return _member.elementsToPush; }
		/** Returns the update date. */		
		public function getUpdateDate():String { return _member.updateDate; }
		/** Returns the array of anonymous game sessions. */		
		public function getAnonymousGameSessions():Array { return _member.anonymousGameSessions; }
		/** Returns */		
		public function getAnonymousGameSessionsAlreadyUsed():Boolean { return _member.anonymousGameSessionsAlreadyUsed; }
		/** Returns */		
		public function getLastTrophyWonId():int { return _member.lastTrophyWonId; }
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
		
		public function getNumStarsEarnedInAnonymousGameSessions():int
		{
			var count:int = 0;
			var gameSession:GameSession;
			for(var i:int = 0; i < getAnonymousGameSessions().length; i++)
			{
				gameSession = getAnonymousGameSessions()[i];
				if( gameSession.gameType == GameSession.TYPE_TOURNAMENT )
					count += gameSession.numStarsOrPointsEarned;
			}
			return count;
		}
		
		public function getNumTrophiesEarnedInAnonymousGameSessions():int
		{
			var count:int = 0;
			var gameSession:GameSession;
			for(var i:int = 0; i < getAnonymousGameSessions().length; i++)
			{
				gameSession = getAnonymousGameSessions()[i];
				if( gameSession.trophiesWon.length > 0 )
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