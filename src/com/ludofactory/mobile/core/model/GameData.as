/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 30 sept. 2013
*/
package com.ludofactory.mobile.core.model
{
	/**
	 * An object representing some variables associated to a game session.
	 */	
	public class GameData
	{
		// ----- Common data
		
		/**
		 * The user's final score which is set up in validateGame. */
		private var _finalScore:int;
		/**
		 * Whether it's a new high score. */
		private var _isNewHighscore:Boolean;
		
	// ----- Duel data
		
		/**
		 * The duel id. */
		private var _duelId:Number;
		/**
		 * The reward in duel mode (added or substracted depending on a victory or defeat). */
		private var _duelReward:int;
		/**
		 * The challenger Facebook id. */
		private var _challengerFacebookId:Number;
		/**
		 * The challenger nickname. */
		private var _challengerNickname:String;
		/**
		 * The challenger trophies count. */
		private var _challengerTrophiesCount:int;
		/**
		 * The challenger actions. */
		private var _challengerActions:Array;
		/**
		 * Whether it's a new duel or not. */
		private var _isAnonymousDuel:Boolean;
		
		// if the user changed notch (top)
		
		/**
		 * Whether the player has reached a new top / level. */		
		private var _hasReachNewTop:Boolean;
		/**
		 * The position of the player in the current duel ranking. */		
		private var _position:int;
		/**
		 * The current notch (top) of the player in the duel ranking (ex : top 100). */		
		private var _top:int;
		
		// ----- Facebook data
		
		private var _facebookFriends:Array;
		private var _facebookMoving:int; // how many places gained
		private var _facebookPosition:int; // 0, 1 or 2 => where was the user (from top to bottom, so 2 = last)
		
		public function GameData()
		{
			
		}
		
//------------------------------------------------------------------------------------------------------------
//	
		
		/**
		 * Parses the duel data.
		 */
		public function parse(data:Object):void
		{
			_isNewHighscore = int(data.isHighscore) == 1;
			
			// parse duel informations
			if("duel" in data && data.duel)
			{
				_duelId = ("id" in data.duel && data.duel.id) ? data.duel.id : 0;
				_duelReward = ("reward" in data.duel && data.duel.reward) ? data.duel.reward : 0;
				if("challenger" in data.duel)
				{
					_isAnonymousDuel = false;
					_challengerFacebookId = ("facebookId" in data.duel.challenger && data.duel.challenger.facebookId) ? data.duel.challenger.facebookId : 0;
					_challengerNickname = ("nickname" in data.duel.challenger && data.duel.challenger.nickname) ? data.duel.challenger.nickname : "";
					_challengerTrophiesCount = ("trophiesCount" in data.duel.challenger && data.duel.challenger.trophiesCount) ? data.duel.challenger.trophiesCount : 0;
					// TODO retirer le code en dur
					_challengerActions = JSON.parse('[{"s":100,"t":4},{"s":150,"t":5},{"s":200,"t":6},{"s":250,"t":10},{"s":100,"t":15},{"s":150,"t":16},{"s":200,"t":17},{"s":250,"t":18},{"s":300,"t":19},{"s":100,"t":25},{"s":150,"t":26},{"s":200,"t":31},{"s":250,"t":32},{"s":300,"t":33},{"s":250,"t":40},{"s":1100,"t":43},{"s":200,"t":44},{"s":550,"t":45},{"s":100,"t":52},{"s":150,"t":55},{"s":1500,"t":58},{"s":100,"t":60},{"s":100,"t":66},{"s":3000,"t":71},{"s":100,"t":75},{"s":100,"t":82},{"s":350,"t":86},{"s":250,"t":88},{"s":100,"t":94},{"s":250,"t":98},{"s":450,"t":101},{"s":100,"t":104},{"s":150,"t":105},{"s":200,"t":106},{"s":250,"t":110},{"s":200,"t":111},{"s":250,"t":112},{"s":650,"t":113},{"s":400,"t":114},{"s":100,"t":123},{"s":1100,"t":126},{"s":100,"t":129},{"s":100,"t":139},{"s":1500,"t":144},{"s":9900,"t":148},{"s":0,"t":155}]') as Array;
					// TODO ajouter les plateaux
				}
				else
				{
					_isAnonymousDuel = false;
				}
				
				_position = ("classement" in data.duel && data.duel.classement) ? data.duel.classement : 0;
				_top = ("top" in data.duel && data.duel.top) ? data.duel.top : 0;
				_hasReachNewTop = ("podium" in data.duel && data.duel.podium) ? data.duel.podium : 0;
			}
			
			// parse Facebook data - only returned when the user is connected with Facebook and have a valid token
			if("fb_hs_friends" in data && data.fb_hs_friends)
			{
				if("classement" in data.fb_hs_friends && (data.fb_hs_friends.classement as Array).length > 0)
				{
					_facebookFriends = (data.fb_hs_friends.classement as Array).concat();
					_facebookMoving = int(data.fb_hs_friends.deplacement);
					_facebookPosition = int(data.fb_hs_friends.key_position);
				}
			}
			/*else // Temporary for debugging
			 {
			 advancedOwner.screenData.gameData.facebookFriends = [ { classement:1, id:7526441, id_facebook:1087069645, last_classement:1, last_score:350, nom:"Maxime Lhoez", score:350 },
			 { classement:2, id:7525967, id_facebook:100001491084445, last_classement:3, last_score:220, nom:"Nicolas Alexandre", score:220 },
			 { classement:2, id:7525969, id_facebook:100003577159732, last_classement:4, last_score:100, nom:"Maxime Lhz", score:250 } ];
			 advancedOwner.screenData.gameData.facebookMoving = 1;
			 advancedOwner.screenData.gameData.facebookPosition = 2;
			 }*/
		}
		
//------------------------------------------------------------------------------------------------------------
//	Get - Set
		
		/**
		 * The user's final score which is set up in validateGame. */
		public function get finalScore():int { return _finalScore; }
		public function set finalScore(val:int):void { _finalScore = val; }
		/**
		 * Whether it's a new high score. */
		public function get isNewHighscore():Boolean { return _isNewHighscore; }
		public function set isNewHighscore(value:Boolean):void { _isNewHighscore = value; }
		
		/**
		 * The duel id. */
		public function get duelId():Number { return _duelId; }
		/**
		 * The reward in duel mode (added or substracted depending on a victory or defeat). */
		public function get duelReward():int { return _duelReward; }
		/**
		 * The challenger Facebook id. */
		public function get challengerFacebookId():Number { return _challengerFacebookId; }
		/**
		 * The challenger nickname. */
		public function get challengerNickname():String { return _challengerNickname; }
		/**
		 * The challenger trophies count. */
		public function get challengerTrophiesCount():int { return _challengerTrophiesCount; }
		/**
		 * The challenger actions. */
		public function get challengerActions():Array { return _challengerActions; }
		/**
		 * Whether it's a new duel or not. */
		public function get isAnonymousDuel():Boolean { return _isAnonymousDuel; }
		
		
		public function get position():int { return _position; }
		public function set position(val:int):void { _position = val; }
		
		public function get top():int { return _top; }
		public function set top(val:int):void { _top = val; }
		
		public function get hasReachNewTop():Boolean { return _hasReachNewTop; }
		public function set hasReachNewTop(val:Boolean):void { _hasReachNewTop = val; }
		
		
		public function get facebookFriends():Array { return _facebookFriends; }
		public function set facebookFriends(val:Array):void { _facebookFriends = val; }
		
		public function get facebookMoving():int { return _facebookMoving; }
		public function set facebookMoving(val:int):void { _facebookMoving = val; }
		
		public function get facebookPosition():int { return _facebookPosition; }
		public function set facebookPosition(val:int):void { _facebookPosition = val; }
		
	}
}