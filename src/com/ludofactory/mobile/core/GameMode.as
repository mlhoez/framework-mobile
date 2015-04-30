/*
 Copyright © 2006-2015 Ludo Factory
 Game Server - Ludokado
 Author  : Maxime Lhoez
 Created : 18 août 2014
*/
package com.ludofactory.mobile.core
{
	/**
	 * All the Ludokado game modes.
	 */	
	public class GameMode
	{
		/**
		 * Adventure. */		
		public static const SOLO:int = 1;
		
		/**
		 * Tournament. */		
		public static const TOURNAMENT:int = 2;
		
		/**
		 * Duel. */		
		public static const DUEL:int = 3;

		/**
		 * Scratch. */
		public static const SCRATCH:int = 4;

		/**
		 * Disconnected. */
		public static const DISCONNECTED:int = 6;
		
		public static function getModeString(gameMode:int):String
		{
			switch (gameMode)
			{
				case SOLO:         { return "Solo"; }
				case TOURNAMENT:   { return "Tournoi"; }
				case DUEL:         { return "Duel"; }
				case SCRATCH:      { return "Grattage"; }
				case DISCONNECTED: { return "Déconnecte"; }
				default:           { return "Inconnu"; }
			}
		}
	}
}