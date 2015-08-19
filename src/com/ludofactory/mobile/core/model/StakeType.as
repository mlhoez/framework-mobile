/*
 Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
 Framework
 Author  : Maxime Lhoez
 Created : 18 août 2014
*/
package com.ludofactory.mobile.core.model
{
	/**
	 * All the stake types.
	 */	
	public class StakeType
	{
		/**
		 * Point. */
		public static const POINT:int = 1;
		
		/**
		 * Credit. */
		public static const CREDIT:int = 5;
		
		/**
		 * Token. */		
		public static const TOKEN:int = 8;

		/**
		 * Experience. */
		public static const XP:int = 9;

		public static function getStakeString(stakeType:int):String
		{
			switch (stakeType)
			{
				case POINT:  { return "Points"; }
				case CREDIT: { return "Credits"; }
				case TOKEN:  { return "Jetons"; }
				case XP:     { return "Xp"; }
				default:     { return "Inconnu"; }
			}
		}
	}
}