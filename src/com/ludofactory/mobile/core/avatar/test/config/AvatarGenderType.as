/**
 * Created by Maxime on 29/06/15.
 */
package com.ludofactory.mobile.core.avatar.test.config
{
	/**
	 * Ludokado avatar genders.
	 */
	public class AvatarGenderType
	{
		/**
		 * Boy gender. */
		public static const BOY:int = 1;
		/**
		 * Girl gender. */
		public static const GIRL:int = 2;
		/**
		 * Potato gender. */
		public static const POTATO:int = 3;
		
		public static function gerGenderNameById(genderId:int):String
		{
			switch (genderId)
			{
				case BOY:    { return "boy"; }
				case GIRL:   { return "girl"; }
				case POTATO: { return "potato"; }
			}
			return ""; // should not happen
		}
	}
}