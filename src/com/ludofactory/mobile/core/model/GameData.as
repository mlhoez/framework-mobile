/*
Copyright © 2006-2014 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 30 sept. 2013
*/
package com.ludofactory.mobile.core.model
{
	/**
	 * An object representing some variables associated
	 * to a game session.
	 */	
	public class GameData
	{
		/**
		 * Whether the game session have been pushed.
		 * It will determine which content should be
		 * initialized in the tournament end screen. */		
		private var _gameSessionPushed:Boolean;
		
		/**
		 * The number of stars or pointq earned in tournament or free 
		 * mode. If the game session have been pushed, this value i
		 *  the one from the database, otherwise, it is calculated thanks
		 * to the <code>ScoreToStarsConverter</code> class. */		
		private var _numStarsEarned:int;
		
		/**
		 * The score the user made in this game session. */		
		private var _score:int;
		
		/**
		 * The position of the player in the current tournament. */		
		private var _position:int;
		
		/**
		 * The actual gift image url. */		
		private var _actualGiftImageUrl:String;
		/**
		 * The actual gift name. */		
		private var _actualGiftName:String;
		
		/**
		 * The next gift image url. */		
		private var _nextGiftImageUrl:String;
		/**
		 * The next gift name. */		
		private var _nextGiftName:String;
		
		/**
		 * The current level of the player in the tournament.
		 * Ex : Top 100 */		
		private var _top:int;
		
		/**
		 * The number of stars necessary to win the next gift. */		
		private var _numStarsForNextGift:int;
		
		/**
		 * Whether the player has reached a new top / level. */		
		private var _hasReachNewTop:Boolean;
		
		/**
		 * The time until the tournament ends. */		
		private var _timeUntilTournamentEnd:int;
		
		/**
		 * The name of the gift when the user is first in the tournament.
		 * It is only used when we want to publish on Facebook when we
		 * changed a Top. */		
		private var _topDotationName:String;
		
		private var _facebookFriends:Array;
		private var _facebookMoving:int; // how many places gained
		private var _facebookPosition:int; // 0, 1 or 2 => where was the user (from top to bottom, so 2 = last)
		
		private var _displayPushAlert:Boolean = false;;
		
		public function GameData()
		{
			
		}
		
		public function get gameSessionPushed():Boolean { return _gameSessionPushed; }
		public function set gameSessionPushed(val:Boolean):void { _gameSessionPushed = val; }
		
		public function get numStarsOrPointsEarned():int { return _numStarsEarned; }
		public function set numStarsOrPointsEarned(val:int):void { _numStarsEarned = val; }
		
		public function get score():int { return _score; }
		public function set score(val:int):void { _score = val; }
		
		public function get position():int { return _position; }
		public function set position(val:int):void { _position = val; }
		
		public function get actualGiftImageUrl():String { return _actualGiftImageUrl; }
		public function set actualGiftImageUrl(val:String):void { _actualGiftImageUrl = val; }
		
		public function get actualGiftName():String { return _actualGiftName; }
		public function set actualGiftName(val:String):void { _actualGiftName = val; }
		
		public function get nextGiftImageUrl():String { return _nextGiftImageUrl; }
		public function set nextGiftImageUrl(val:String):void { _nextGiftImageUrl = val; }
		
		public function get nextGiftName():String { return _nextGiftName; }
		public function set nextGiftName(val:String):void { _nextGiftName = val; }
		
		public function get top():int { return _top; }
		public function set top(val:int):void { _top = val; }
		
		public function get numStarsForNextGift():int { return _numStarsForNextGift; }
		public function set numStarsForNextGift(val:int):void { _numStarsForNextGift = val; }
		
		public function get hasReachNewTop():Boolean { return _hasReachNewTop; }
		public function set hasReachNewTop(val:Boolean):void { _hasReachNewTop = val; }
		
		public function get timeUntilTournamentEnd():int { return _timeUntilTournamentEnd; }
		public function set timeUntilTournamentEnd(val:int):void { _timeUntilTournamentEnd = val; }
		
		public function get facebookFriends():Array { return _facebookFriends; }
		public function set facebookFriends(val:Array):void { _facebookFriends = val; }
		
		public function get facebookMoving():int { return _facebookMoving; }
		public function set facebookMoving(val:int):void { _facebookMoving = val; }
		
		public function get facebookPosition():int { return _facebookPosition; }
		public function set facebookPosition(val:int):void { _facebookPosition = val; }
		
		public function get displayPushAlert():Boolean { return _displayPushAlert; }
		public function set displayPushAlert(val:Boolean):void { _displayPushAlert = val; }
		
		public function get topDotationName():String { return _topDotationName; }
		public function set topDotationName(val:String):void { _topDotationName = val; }
	}
}