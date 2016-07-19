/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 18 sept. 2013
*/
package com.ludofactory.mobile.core.notification.content.neww.highscore
{
	
	/**
	 * 
	 */	
	public class HighscoreRankingData
	{
		/**
		 * The player rank. */		
		private var _rank:int;
		
		/**
		 * Whether the current HighScoreData is owned by the current user. */		
		private var _isMe:Boolean;
		
		/**
		 * The player pseudo. */		
		private var _pseudo:String;
		
		/**
		 * The player score. */		
		private var _score:int;
		
		public function HighscoreRankingData(data:Object)
		{
			_rank = data.classement;
			_isMe = data.isMembre;
			_pseudo = data.pseudo;
			_score = data.score;
		}
		
		public function get rank():int { return _rank; }
		public function get isMe():Boolean { return _isMe; }
		public function get pseudo():String { return _pseudo; }
		public function get score():int { return _score; }
		
	}
}