/*
Copyright © 2006-2014 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 26 juil. 2013
*/
package com.ludofactory.mobile.core.test.tournament.listing
{
	import com.ludofactory.mobile.core.test.config.GlobalConfig;

	/**
	 * 
	 */	
	public class RankData
	{
		/**
		 * The player rank. */		
		private var _rank:int;
		
		/**
		 * The player pseudo. */		
		private var _pseudo:String;
		
		/**
		 * The player truncated pseudo. */		
		private var _truncatedPseudo:String;
		
		/**
		 * The player country. */		
		private var _country:String;
		
		/**
		 * The player number of stars. */		
		private var _stars:int;
		
		/**
		 * Whether the current RankData is owned
		 * by the current user. */		
		private var _isMe:Boolean;
		
		/**
		 * The date the score was made. */		
		private var _lastDateScore:String;
		
		/**
		 * Whether the pseudo have been truncated.
		 * Used by the list to detrmine if we need
		 * to add a tooltip with the full pseudo or
		 * not. */		
		private var _isTruncated:Boolean = false;
		
		public function RankData(data:Object)
		{
			_rank = data.classement;
			_pseudo = data.pseudo;
			_country = data.pays;
			_stars = data.score;
			_isMe = data.isMembre;
			_lastDateScore = data.lastDateScore;
			_truncatedPseudo = _pseudo.length > (GlobalConfig.isPhone ? 15 : 40) ? (_pseudo.substring(0, (GlobalConfig.isPhone ? 15 : 40)) + "...") : _pseudo;
			_isTruncated = _pseudo != _truncatedPseudo;
		}
		
		public function get rank():int { return _rank; }
		public function get pseudo():String { return _pseudo; }
		public function get truncatedPseudo():String { return _truncatedPseudo; }
		public function get country():String { return _country; }
		public function get stars():int { return _stars; }
		public function get isMe():Boolean { return _isMe; }
		public function get lastDateScore():String { return _lastDateScore; }
		public function get isTruncated():Boolean { return _isTruncated; }
	}
}