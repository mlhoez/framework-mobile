/*
Copyright © 2006-2014 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 18 sept. 2013
*/
package com.ludofactory.mobile.core.navigation.highscore
{
	import com.ludofactory.mobile.core.config.GlobalConfig;

	/**
	 * 
	 */	
	public class HighScoreData
	{
		/**
		 * The player rank. */		
		private var _rank:int;
		
		/**
		 * The player country. */		
		private var _countryCode:String;
		
		/**
		 * The player country. */		
		private var _countryId:int;
		
		/**
		 * The date. */		
		private var _date:String;
		
		/**
		 * Whether the current HighScoreData is owned
		 * by the current user. */		
		private var _isMe:Boolean;
		
		/**
		 * The player pseudo. */		
		private var _pseudo:String;
		
		/**
		 * The player truncated pseudo. */		
		private var _truncatedPseudo:String;
		
		/**
		 * The player score. */		
		private var _score:int;
		
		/**
		 * Whether the pseudo have been truncated.
		 * Used by the list to detrmine if we need
		 * to add a tooltip with the full pseudo or
		 * not. */		
		private var _isTruncated:Boolean = false;
		
		public function HighScoreData(data:Object)
		{
			_rank = data.classement;
			_countryCode = data.code_pays;
			_countryId = data.id_pays;
			_date = data.date;
			_isMe = data.isMembre;
			_pseudo = data.pseudo;
			_score = data.score;
			_truncatedPseudo = _pseudo.length > (GlobalConfig.isPhone ? 15 : 40) ? (_pseudo.substring(0, (GlobalConfig.isPhone ? 15 : 40)) + "...") : _pseudo;
			_isTruncated = _pseudo != _truncatedPseudo;
		}
		
		public function get rank():int { return _rank; }
		public function get countryCode():String { return _countryCode; }
		public function get countryId():int { return _countryId; }
		public function get date():String { return _date; }
		public function get isMe():Boolean { return _isMe; }
		public function get pseudo():String { return _pseudo; }
		public function get truncatedPseudo():String { return _truncatedPseudo; }
		public function get score():int { return _score; }
		public function get isTruncated():Boolean { return _isTruncated; }
	}
}