/*
Copyright © 2006-2014 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 8 sept. 2013
*/
package com.ludofactory.mobile.navigation.tournament
{
	public class PreviousTournamentData
	{
		/**
		 * The previous tournament's id. */		
		private var _id:int;
		
		public function PreviousTournamentData(tournamentId:int)
		{
			_id = tournamentId;
		}
		
		public function get id():int { return _id; }
	}
}