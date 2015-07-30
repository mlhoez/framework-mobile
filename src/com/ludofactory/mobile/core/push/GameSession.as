package com.ludofactory.mobile.core.push
{
	import com.ludofactory.mobile.core.manager.MemberManager;

	public class GameSession extends AbstractElementToPush
	{
		/**
		 * A unique id generated at creation. */		
		private var _uniqueId:String;
		
		/**
		 * Score of the game session */		
		private var _score:int;
		
		/**
		 * The price paid by the user to play : free, paid or point */		
		private var _gamePrice:int;
		
		/**
		 * The game type (whether free or tournament). */		
		private var _gameType:int;
		
		/**
		 * The date the game session was played so that when the
		 * push occur, when decrement the free game sessions of
		 * the correct day, and not the actual one. 
		 * <p>This date is only used when a game session is pushed
		 * later, not when the push was successfully made after a game
		 * (in this case it's the date of the server on the server side
		 * that is taken.</p> */		
		private var _playDate:String;
		
		/**
		 * Whether this game session was stored.
		 * Default is false. */		
		private var _connected:Boolean;
		
		/**
		 * The number of stars or points earned, at the moment only used in
		 * the AlertItemRenderer for information. */		
		private var _numStarsOrPointsEarned:int;
		
		/**
		 * Trophies won on the game session. */		
		private var _trophiesWon:Array = [];
		
		/**
		 * The time elapsed on the game. */		
		private var _elapsedTime:int;
		
		public function GameSession(pushType:String = null, gameType:int = 0, gamePrice:int = 0)
		{
			super(pushType);
			
			if( gamePrice == 0 )
				return;
			
			_uniqueId = String(new Date().getTime());
			_gameType = gameType;
			_gamePrice = gamePrice;
			_score = -1;
			_playDate = MemberManager.getInstance().getUpdateDate();
			_trophiesWon = [];
			_connected = false;
			_numStarsOrPointsEarned = 0;
			_elapsedTime = 0;
		}
		
//------------------------------------------------------------------------------------------------------------
//	Get - Set
		
		// since this class is saved in the EncryptedLocalStore, everything has to be r/w !
		
		public function get uniqueId():String { return _uniqueId; }
		public function set uniqueId(val:String):void { _uniqueId = val; }
		
		public function get gameType():int { return _gameType; }
		public function set gameType(val:int):void { _gameType = val; }
		
		public function get gamePrice():int { return _gamePrice; }
		public function set gamePrice(val:int):void { _gamePrice = val; }
		
		public function get score():int { return _score; }
		public function set score(val:int):void { _score = val; }
		
		public function get playDate():String { return _playDate; }
		public function set playDate(val:String):void { _playDate = val; }
		
		public function get connected():Boolean { return _connected; }
		public function set connected(val:Boolean):void { _connected = val; }
		
		public function get numStarsOrPointsEarned():int { return _numStarsOrPointsEarned; }
		public function set numStarsOrPointsEarned(val:int):void { _numStarsOrPointsEarned = val; }
		
		public function get trophiesWon():Array { return _trophiesWon; }
		public function set trophiesWon(val:Array):void { _trophiesWon = val; }
		
		public function get elapsedTime():int { return _elapsedTime; }
		public function set elapsedTime(val:int):void { _elapsedTime = val; }
	}
}