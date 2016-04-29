/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 12 Août 2013
*/
package com.ludofactory.mobile.core.manager
{
	
	import com.ludofactory.mobile.core.push.AbstractElementToPush;
	
	/**
	 * Member object class.
	 * 
	 * <p>All properties should be enough for each new application, but in case you need to have more properties here,
	 * you can add them if you also add getters and setters for those properties. They will be accessible even if the
	 * previous encrypted and stored member didn't have those properties.</p>
	 * 
	 * <p>But you CANNOT remove properties from here because the decryption must probably fail.</p>
	 */	
	public class Member
	{
		// Application specific data
		
		/**
		 * Whether we need to display the tutorial the first time. */		
		private var _displayTutorial:Boolean = true;
		
		/**
		 * Whether we need to display the tutorial the first time. */		
		private var _tournamentAnimPending:Boolean = false;
		
		/**
		 * Whether we need to display the tutorial the first time. */		
		private var _tournamentUnlocked:Boolean = false;
		/**
		 * How many game sessions in solo mode to play in order to unlock the tournament mode. */
		private var _tournamentUnlockCounter:int = 2;
		
		/**
		 * The member's highscore */		
		private var _highscore:int = 0;
		
		/**
		 * Ids of won trophies. */		
		private var _trophiesWon:Array = [];
		
		/**
		 * The elements to push. */		
		private var _elementsToPush:Vector.<AbstractElementToPush> = new Vector.<AbstractElementToPush>();
		
		/**
		 * Array of anonymous game sessions. 
		 * This is used only once when the user wants to login
		 * or create a new account so that anonymous game sessions
		 * can be taken in account. */		
		private var _anonymousGameSessions:Array = [];
		
		/**
		 * Apple does not allow us to require to be logged in in order to make a purchase. Because of that, we
		 * need to store all the transcation ids here and send them when the user sign in/up. */
		private var _transactionIds:Array = [];
		
		/**
		 * The id of the last trophy won. */		
		private var _lastTrophyWonId:int = -1;
		
		// database part 
		
		/**
		 * The member's id */		
		private var _id:Number = 0;
		
		/**
		 * The member's mail */		
		private var _mail:String = "";
		
		/**
		 * The member's password */		
		private var _password:String = "";
		
		/**
		 * The member's pseudo */		
		private var _pseudo:String = "";

		/**
		 * The member's birth date.
		 * Default is "0000-00-00" */
		private var _birthDate:String = "0000-00-00";

		/**
		 * The member's title (Mr., Mme. or Mlle.
		 * default is "Mr." */
		private var _title:String = "Mr.";
		
		/**
		 * The member's number of cumulated stars for the current tournament. */		
		private var _cumulatedStars:int = 0;
		
		/**
		 * The member's facebook id */		
		private var _facebookId:Number = 0;
		
		/**
		 * The date the free game count have been updated. It is used
		 * when we want to push a game session so that the free games
		 * of the correct day are decremented at the moment of the
		 * push. */		
		private var _updateDate:String;

		/**
		 * Whether the player can watch a VidCoin video in order to get 1 (or more)
		 * free game session.
		 */
		private var _canWatchVideo:Boolean = false;
		
		/**
		 * Whether we can display an interstital after a stake have been selected. */
		private var _canDisplayInterstitial:Boolean = false;
		
		/**
		 * Whether the user is admin or not. */
		private var _isAdmin:Boolean = false;
		
		/**
		 * Facebook token. */
		private var _facebookToken:String = "";
		/**
		 * Facebook token expiry date (time in ms).
		 * use new Date(tokenExpiryDate) to get the full date to compare. */
		private var _facebookTokenExpiryTimestamp:Number = 0;
		
		/**
		 * The boot time. */
		private var _bootTime:Number = NaN;
		private var _tokenDate:Date;
		
		/**
		 * Whether the player can have the reward after its first publish.
		 * True by default so that a non authenticated user will see it. */
		private var _canHaveRewardAfterPublish:Boolean = true;
		
		/**
		 * If the anonymous game sessions can be sent when
		 * the user creates an account et simply log in. */
		private var _anonymousGameSessionsAlreadyUsed:Boolean = false;
		
		public function Member() { }
		
		/**
		 * Parses a data object coming from the database.
		 * 
		 * @param memberData
		 */		
		public function parseData(memberData:Object):void
		{
			if( "id_membre" in memberData && memberData.id_membre != null )                     _id = Number(memberData.id_membre);
			if( "mail" in memberData && memberData.mail != null )                               _mail = String(memberData.mail);
			if( "mdp" in memberData && memberData.mdp != null )                                 _password = String(memberData.mdp);
			if( "pseudo" in memberData && memberData.pseudo != null )                           _pseudo = String(memberData.pseudo);
			if( "date_naissance" in memberData && memberData.date_naissance != null )           _birthDate = String(memberData.date_naissance);
			if( "sexe" in memberData && memberData.sexe != null )                               _title = String(memberData.sexe);
			if( "score_cumule" in memberData && memberData.score_cumule != null )               _cumulatedStars = int(memberData.score_cumule);
			if( "id_facebook" in memberData && memberData.id_facebook != null )                 _facebookId = Number(memberData.id_facebook);
			if( "date_jetons" in memberData && memberData.date_jetons != null )                 _updateDate = String(memberData.date_jetons);
			if( "video_disponible" in memberData && memberData.video_disponible != null )       _canWatchVideo = Boolean(memberData.video_disponible);
			if( "isAdmin" in memberData && memberData.isAdmin != null )                         _isAdmin = Boolean(memberData.isAdmin);
			if( "displayInterstitial" in memberData && memberData.displayInterstitial != null ) _canDisplayInterstitial = Boolean(memberData.displayInterstitial);
			if( "canHaveRewardAfterPublish" in memberData && memberData.canHaveRewardAfterPublish != null ) _canHaveRewardAfterPublish = Boolean(memberData.canHaveRewardAfterPublish);
			// Example date for tests = "2012-10-14 11:46:09"
		}
		
//------------------------------------------------------------------------------------------------------------
//	Get - Set
		
		// since this class is saved in the EncryptedLocalStore, everything has to be r/w !
		
		public function get pseudo():String { return _pseudo; }
		public function set pseudo(val:String):void { _pseudo = val; }

		public function get birthDate():String { return _birthDate; }
		public function set birthDate(val:String):void { _birthDate = val; }

		public function get title():String { return _title; }
		public function set title(val:String):void { _title = val; }
		
		public function get highscore():int { return _highscore; }
		public function set highscore(val:int):void { _highscore = val; }
		
		public function get cumulatedStars():int { return _cumulatedStars; }
		public function set cumulatedStars(val:int):void { _cumulatedStars = val; }
		
		public function get id():Number { return _id; }
		public function set id(val:Number):void { _id = val; }
		
		public function get mail():String { return _mail; }
		public function set mail(val:String):void { _mail = val; }
		
		public function get password():String { return _password; }
		public function set password(val:String):void { _password = val; }
		
		public function get facebookId():Number { return _facebookId; }
		public function set facebookId(val:Number):void { _facebookId = val; }
		
		public function get trophiesWon():Array { return _trophiesWon; }
		public function set trophiesWon(val:Array):void { _trophiesWon = val; }
		
		public function get elementsToPush():Vector.<AbstractElementToPush> { return _elementsToPush; }
		public function set elementsToPush(val:Vector.<AbstractElementToPush>):void { _elementsToPush = val; }
		
		public function get updateDate():String { return _updateDate; }
		public function set updateDate(val:String):void { _updateDate = val; }
		
		public function get anonymousGameSessions():Array { return _anonymousGameSessions; }
		public function set anonymousGameSessions(val:Array):void { _anonymousGameSessions = val; }
		
		public function get lastTrophyWonId():int { return _lastTrophyWonId; }
		public function set lastTrophyWonId(val:int):void { _lastTrophyWonId = val; }
		
		public function get displayTutorial():Boolean { return _displayTutorial; }
		public function set displayTutorial(val:Boolean):void { _displayTutorial = val; }
		
		public function get tournamentAnimPending():Boolean { return _tournamentAnimPending; }
		public function set tournamentAnimPending(val:Boolean):void { _tournamentAnimPending = val; }
		
		public function get tournamentUnlocked():Boolean { return _tournamentUnlocked; }
		public function set tournamentUnlocked(val:Boolean):void { _tournamentUnlocked = val; }

		public function get canWatchVideo():Boolean { return _canWatchVideo; }
		public function set canWatchVideo(val:Boolean):void { _canWatchVideo = val; }
		
		public function get isAdmin():Boolean { return _isAdmin; }
		public function set isAdmin(val:Boolean):void { _isAdmin = val; }
		
		public function get canDisplayInterstitial():Boolean { return _canDisplayInterstitial; }
		public function set canDisplayInterstitial(val:Boolean):void { _canDisplayInterstitial = val; }
		
		public function get facebookToken():String { return _facebookToken; }
		public function set facebookToken(val:String):void { _facebookToken = val; }
		
		public function get facebookTokenExpiryTimestamp():Number { return _facebookTokenExpiryTimestamp; }
		public function set facebookTokenExpiryTimestamp(val:Number):void { _facebookTokenExpiryTimestamp = val; }
		
		public function get transactionIds():Array { return _transactionIds; }
		public function set transactionIds(value:Array):void { _transactionIds = value; }
		
		public function get bootTime():Number { return _bootTime; }
		public function set bootTime(value:Number):void { _bootTime = value; }
		
		public function get tokenDate():Date { return _tokenDate; }
		public function set tokenDate(value:Date):void { _tokenDate = value; }
		
		public function get tournamentUnlockCounter():int { return _tournamentUnlockCounter; }
		public function set tournamentUnlockCounter(value:int):void { _tournamentUnlockCounter = value; }
		
		public function get canHaveRewardAfterPublish():Boolean { return _canHaveRewardAfterPublish; }
		public function set canHaveRewardAfterPublish(value:Boolean):void { _canHaveRewardAfterPublish = value; }
		
		public function get anonymousGameSessionsAlreadyUsed():Boolean { return _anonymousGameSessionsAlreadyUsed; }
		public function set anonymousGameSessionsAlreadyUsed(val:Boolean):void { _anonymousGameSessionsAlreadyUsed = val; }
		
	}
}