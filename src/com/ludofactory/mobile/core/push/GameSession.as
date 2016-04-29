package com.ludofactory.mobile.core.push
{
	
	import com.ludofactory.common.utils.Utilities;
	import com.ludofactory.mobile.core.manager.MemberManager;
	
	public class GameSession extends AbstractElementToPush
	{
		/**
		 * A unique id generated at creation. */		
		private var _uniqueId:String;
		/**
		 * The game mode (whether solo or duel). */
		private var _gameMode:int;
		/**
		 * Score of this game session */		
		private var _score:int;
		/**
		 * The date the game session was played (it's the device date so it might not be the real one).
		 * <p>Note that this is just for information because the real server date is used instead.</p> */		
		private var _playDate:String;
		/**
		 * Trophies won on the game session. */
		private var _trophiesWon:Array = [];
		/**
		 * The time elapsed on the game in seconds. */
		private var _elapsedTime:int;
		
		/**
		 * Whether this game session was stored. Default is false. */		
		private var _connected:Boolean;
		/**
		 * The number of stars or points earned, at the moment only used in the AlertItemRenderer for information. */		
		private var _numStarsOrPointsEarned:int;
		
		public function GameSession(pushType:String = null, gameType:int = 0)
		{
			super(pushType);
			
			if( pushType == null ) // restaured from encrypted local store
				return;
			
			_uniqueId = String(new Date().getTime());
			_gameMode = gameType;
			_score = -1;
			_playDate = MemberManager.getInstance().lastUpdateDate ? MemberManager.getInstance().lastUpdateDate : Utilities.formatDateUS(new Date());
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
		
		public function get gameMode():int { return _gameMode; }
		public function set gameMode(val:int):void { _gameMode = val; }
		
		public function get score():int { return _score; }
		public function set score(val:int):void { _score = val; }
		
		public function get playDate():String { return _playDate; }
		public function set playDate(val:String):void { _playDate = val; }
		
		public function get trophiesWon():Array { return _trophiesWon; }
		public function set trophiesWon(val:Array):void { _trophiesWon = val; }
		
		public function get elapsedTime():int { return _elapsedTime; }
		public function set elapsedTime(val:int):void { _elapsedTime = val; }
		
		public function get connected():Boolean { return _connected; }
		public function set connected(val:Boolean):void { _connected = val; }
		
		public function get numStarsOrPointsEarned():int { return _numStarsOrPointsEarned; }
		public function set numStarsOrPointsEarned(val:int):void { _numStarsOrPointsEarned = val; }
	}
}