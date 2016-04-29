/*
 Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
 Game Server - Ludokado
 Author  : Maxime Lhoez
 Created : 18 août 2014
*/
package com.ludofactory.mobile.core.model
{
	/**
	 * All the game modes.
	 */	
	public class GameMode
	{
		/**
		 * Adventure. */		
		public static const SOLO:int = 1;
		/**
		 * Duel. */		
		public static const DUEL:int = 3;
		
		public static function getModeString(gameMode:int):String
		{
			switch (gameMode)
			{
				case SOLO:         { return "Solo"; }
				case DUEL:         { return "Duel"; }
				default:           { return "Inconnu"; }
			}
		}
	}
}