/*
Copyright © 2006-2014 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 31 août 2013
*/
package com.ludofactory.mobile.core.test.achievements
{
	import com.ludofactory.mobile.core.test.push.GameSession;
	import com.ludofactory.mobile.core.authentication.MemberManager;
	import com.ludofactory.mobile.core.storage.Storage;
	import com.ludofactory.mobile.core.storage.StorageConfig;
	
	import starling.events.Event;
	import starling.events.EventDispatcher;

	/**
	 * Manage all the process associated to a trophy.
	 */	
	public class TrophyManager extends EventDispatcher
	{
		/**
		 * Singletion instance. */		
		private static var _instance:TrophyManager;
		
		/**
		 * Trophies won. */		
		private var _trophiesWon:Array;
		
		/**
		 * The trophies data retreived from the configuration. */		
		private var _trophiesData:Array;
		
		/**
		 * The trophy displayer. */		
		private var _trophyDisplayer:TrophyDisplayer;
		
		/**
		 * Sets the current game session. */		
		private var _currentGameSession:GameSession;
		
		public function TrophyManager(sk:SecurityKey)
		{
			_trophiesData = (Storage.getInstance().getProperty( StorageConfig.PROPERTY_TROPHIES ) as Array).concat();
			_trophyDisplayer = new TrophyDisplayer();
			_trophyDisplayer.addEventListener(Event.COMPLETE, onTrophyDisplayComplete);
		}
		
		public static function getInstance():TrophyManager
		{
			if(_instance == null)
				_instance = new TrophyManager(new SecurityKey());
			return _instance;
		}
		
//------------------------------------------------------------------------------------------------------------
//	Get
//------------------------------------------------------------------------------------------------------------
		
		/**
		 * Return a trophy data by its id.
		 * 
		 * @see com.ludofactory.mobile.trophies.TrophyData
		 */		
		public function getTrophyDataById(trophyId:int):TrophyData
		{
			_trophiesWon = MemberManager.getInstance().getTrophiesWon().concat();
			for(var i:int = 0; i < _trophiesData.length; i++)
			{
				if( TrophyData(_trophiesData[i]).id == trophyId )
					return TrophyData(_trophiesData[i]);
			}
			throw new Error("[TrophyManager] The trophy " + trophyId + " doesn't exists.");
		}
		
//------------------------------------------------------------------------------------------------------------
//	Check and update
//------------------------------------------------------------------------------------------------------------
		
		/**
		 * Checks if the user can win the trophy whose id is given
		 * in parameters.
		 * 
		 * <p>Return false if not, true otherwise.</p>
		 */		
		public function canWinTrophy(trophyId:int):Boolean
		{
			_trophiesWon = MemberManager.getInstance().getTrophiesWon().concat();
			for(var i:int = 0; i < _trophiesWon.length; i++)
			{
				if( _trophiesWon[i] == trophyId)
					return false;
			}
			return true;
		}
		
		/**
		 * The user won a trophy.
		 * 
		 * <p>In this case, we try to push this information directly
		 * to the server. If we can't no connection or if an error
		 * occurred, we store the information so that we can push it
		 * later.</p>
		 * 
		 * <p>In any case, the information is stored internaly in the
		 * Member object and then pushed to the ELS so that the user
		 * won't win twice the same trophy.</p>
		 */		
		public function onWinTrophy(trophyId:int):void
		{
			MemberManager.getInstance().setLastTrophyWonId(trophyId);
			_trophiesWon = MemberManager.getInstance().getTrophiesWon().concat();
			_trophiesWon.push(trophyId);
			MemberManager.getInstance().setTrophiesWon(_trophiesWon);
			
			if( _currentGameSession )
				_currentGameSession.trophiesWon.push( trophyId );
			
			GameCenterManager.reportAchievement("pyramid." + trophyId, 100);
			
			_trophyDisplayer.onTrophyWon( getTrophyDataById(trophyId) );
		}
		
		/**
		 * All the trophies have finished displaying.
		 */		
		private function onTrophyDisplayComplete(event:Event):void
		{
			dispatchEventWith(Event.COMPLETE);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Get / Set
//------------------------------------------------------------------------------------------------------------
		
		public function get isTrophyMessageDisplaying():Boolean { return _trophyDisplayer.isTrophyMessageDisplaying; }
		
		public function get currentGameSession():GameSession { return _currentGameSession; }
		public function set currentGameSession(val:GameSession):void { _currentGameSession = val; }
	}
}

internal class SecurityKey{}