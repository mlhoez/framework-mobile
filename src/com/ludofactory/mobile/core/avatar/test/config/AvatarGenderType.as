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
		 * Shadow. */
		public static const SHADOW:int = 0;
		/**
		 * Boy gender. */
		public static const BOY:int = 1;
		/**
		 * Girl gender. */
		public static const GIRL:int = 2;
		/**
		 * Potato gender. */
		public static const POTATO:int = 3;
		
		/**
		 * Shadow gender name. */
		public static const SHADOW_NAME:String = "shadow";
		/**
		 * Boy gender name. */
		public static const BOY_NAME:String = "boy";
		/**
		 * Girl gender name. */
		public static const GIRL_NAME:String = "girl";
		/**
		 * Potato gender name. */
		public static const POTATO_NAME:String = "potato";
		
		public static function gerGenderNameById(genderId:int):String
		{
			switch (genderId)
			{
				case SHADOW: { return SHADOW_NAME; }
				case BOY:    { return BOY_NAME; }
				case GIRL:   { return GIRL_NAME; }
				case POTATO: { return POTATO_NAME; }
			}
			return ""; // should not happen
		}
		
		public static function getGenderIdByName(genderName:String):int
		{
			switch (genderName)
			{
				case SHADOW_NAME: { return SHADOW; }
				case BOY_NAME:    { return BOY; }
				case GIRL_NAME:   { return GIRL; }
				case POTATO_NAME: { return POTATO; }
			}
			return -1; // should not happen
		}
	}
}