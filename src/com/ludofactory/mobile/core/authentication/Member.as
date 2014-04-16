/*
Copyright © 2006-2014 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 12 Août 2013
*/
package com.ludofactory.mobile.core.authentication
{
	import com.ludofactory.mobile.core.test.push.AbstractElementToPush;
	
	/**
	 * Member
	 * 
	 * <p>All properties should be enough for each new application, but in case you
	 * need to have more properties here, you can add them if you also add getters and 
	 * setters for those properties. They will be accessible even if the previous encrypted
	 * and stored member didn't have this property.</p>
	 * 
	 * <p>But you CANNOT remove properties from here because the decryption must
	 * probably fail.</p>
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
		 * If the anonymous game sessions can be sent when
		 * the user creates an account et simply log in. */		
		private var _anonymousGameSessionsAlreadyUsed:Boolean = false;
		
		/**
		 * The id of the last trophy won. */		
		private var _lastTrophyWonId:int = -1;
		
		// database part 
		
		/**
		 * The member's id */		
		private var _id:int = 0;
		
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
		 * The member's number of credits */		
		private var _credits:int = 0;
		
		/**
		 * The member's number of free game sessions (default is 10 for an anonymous member) */		
		private var _numFreeGameSessions:int = 10;
		
		/**
		 * The member's total of free game sessions available (10 by default with a common rank). */		
		private var _numFreeGameSessionsTotal:int = 10;
		
		/**
		 * The member's number of points */		
		private var _points:int = 0;
		
		/**
		 * The member's number of cumulated stars for the current tournament. */		
		private var _cumulatedStars:int = 0;
		
		/**
		 * The member's number of bought credits. */		
		private var _numCreditsBought:int = 0;
		
		/**
		 * The member's rank id */		
		private var _rank:int = 0;
		
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
		 * The country id associated to the pseudo. */		
		private var _countryId:int = 0;
		
		public function Member() { }
		
		/**
		 * Parses a data object coming from the database.
		 * 
		 * @param memberData
		 */		
		public function parseData(memberData:Object):void
		{
			if( "id_membre" in memberData && memberData.id_membre != null )                           _id = int(memberData.id_membre);
			if( "mail" in memberData && memberData.mail != null )                                     _mail = String(memberData.mail);
			if( "mdp" in memberData && memberData.mdp != null )                                       _password = String(memberData.mdp);
			if( "pseudo" in memberData && memberData.pseudo != null )                                 _pseudo = String(memberData.pseudo);
			if( "credits" in memberData && memberData.credits != null )                               _credits = int(memberData.credits);
			if( "parties_gratuites" in memberData && memberData.parties_gratuites != null )           _numFreeGameSessions = int(memberData.parties_gratuites);
			if( "score_cumule" in memberData && memberData.score_cumule != null )                     _cumulatedStars = int(memberData.score_cumule);
			if( "points" in memberData && memberData.points != null )                                 _points = int(memberData.points);
			if( "rang" in memberData && memberData.rang != null )                                     _rank = int(memberData.rang);
			if( "id_facebook" in memberData && memberData.id_facebook != null )                       _facebookId = Number(memberData.id_facebook);
			if( "nb_credit_acheter" in memberData && memberData.nb_credit_acheter != null )           _numCreditsBought = int(memberData.nb_credit_acheter);
			if( "date_parties_gratuites" in memberData && memberData.date_parties_gratuites != null ) _updateDate = String(memberData.date_parties_gratuites);
			if( "id_pays_pseudo" in memberData && memberData.id_pays_pseudo != null )                 _countryId = int(memberData.id_pays_pseudo);
			if( "parties_quotidiennes" in memberData && memberData.parties_quotidiennes != null )     _numFreeGameSessionsTotal = int(memberData.parties_quotidiennes);
			// Example date for tests = "2012-10-14 11:46:09"
		}
		
//------------------------------------------------------------------------------------------------------------
//	Get - Set
		
		// since this class is saved in the EncryptedLocalStore, everything has to be r/w !
		
		public function get pseudo():String { return _pseudo; }
		public function set pseudo(val:String):void { _pseudo = val; }
		
		public function get numFreeGameSessions():int { return _numFreeGameSessions; }
		public function set numFreeGameSessions(val:int):void { _numFreeGameSessions = val; }
		
		public function get numFreeGameSessionsTotal():int { return _numFreeGameSessionsTotal; }
		public function set numFreeGameSessionsTotal(val:int):void { _numFreeGameSessionsTotal = val; }
		
		public function get credits():int { return _credits; }
		public function set credits(val:int):void { _credits = val; }
		
		public function get highscore():int { return _highscore; }
		public function set highscore(val:int):void { _highscore = val; }
		
		public function get points():int { return _points; }
		public function set points(val:int):void { _points = val; }
		
		public function get cumulatedStars():int { return _cumulatedStars; }
		public function set cumulatedStars(val:int):void { _cumulatedStars = val; }
		
		public function get numCreditsBought():int { return _numCreditsBought; }
		public function set numCreditsBought(val:int):void { _numCreditsBought = val; }
		
		public function get id():int { return _id; }
		public function set id(val:int):void { _id = val; }
		
		public function get mail():String { return _mail; }
		public function set mail(val:String):void { _mail = val; }
		
		public function get password():String { return _password; }
		public function set password(val:String):void { _password = val; }
		
		public function get rank():int { return _rank; }
		public function set rank(val:int):void { _rank = val; }
		
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
		
		public function get anonymousGameSessionsAlreadyUsed():Boolean { return _anonymousGameSessionsAlreadyUsed; }
		public function set anonymousGameSessionsAlreadyUsed(val:Boolean):void { _anonymousGameSessionsAlreadyUsed = val; }
		
		public function get lastTrophyWonId():int { return _lastTrophyWonId; }
		public function set lastTrophyWonId(val:int):void { _lastTrophyWonId = val; }
		
		public function get countryId():int { return _countryId; }
		public function set countryId(val:int):void { _countryId = val; }
		
		public function get displayTutorial():Boolean { return _displayTutorial; }
		public function set displayTutorial(val:Boolean):void { _displayTutorial = val; }
		
		public function get tournamentAnimPending():Boolean { return _tournamentAnimPending; }
		public function set tournamentAnimPending(val:Boolean):void { _tournamentAnimPending = val; }
		
		public function get tournamentUnlocked():Boolean { return _tournamentUnlocked; }
		public function set tournamentUnlocked(val:Boolean):void { _tournamentUnlocked = val; }
	}
}