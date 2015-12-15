/*
 Copyright © 2006-2015 Ludo Factory
 Framework Ludokado - Ludokado
 Author  : Maxime Lhoez
 Created : 29 Juin 2015
*/
package com.ludofactory.mobile.core.avatar.test.config
{

	/**
	 * Name of the Ludokado bones defined in Flash Pro.
	 */
	public class LudokadoBones
	{
		
	// ---------- Common - can be modified - are part of the cart
		
		// Bones
		
		/**
		 * Hat.
		 * For all genders. */
		public static const HAT:String = "hat";
		
		/**
		 * Hair.
		 * For all genders. */
		public static const HAIR:String = "hair";
		
		/**
		 * Eyebrows.
		 * For all genders. */
		public static const EYEBROWS:String = "eyebrows";
		
		/**
		 * Eyes.
		 * For all genders. */
		public static const EYES:String = "eyes";
		
		/**
		 * Nose.
		 * For all genders. */
		public static const NOSE:String = "nose";
		
		/**
		 * Mouth.
		 * For all genders. */
		public static const MOUTH:String = "mouth";
		
		/**
		 * Moustache.
		 * For potato and boy. */
		public static const MOUSTACHE:String = "moustache";
		
		/**
		 * Beard.
		 * For boy only. */
		public static const BEARD:String = "beard";
		
		/**
		 * Shirt.
		 * For all genders. */
		public static const SHIRT:String = "shirt";
		
		/**
		 * Left hand.
		 * For all genders. */
		public static const LEFT_HAND:String = "leftHand";
		
		/**
		 * Right hand.
		 * For all genders. */
		public static const RIGHT_HAND:String = "rightHand";
		
		/**
		 * Face customs (tatoo, scars, etc.)
		 * For Boys and Girls. */
		public static const FACE_CUSTOM:String = "faceCustom";
		
		/**
		 * Epaulet
		 * Only for potato. */
		public static const EPAULET:String = "epaulet";
		
		// Colors
		
		/**
		 * Skin color.
		 * For all genders. */
		public static const SKIN_COLOR:String = "skinColor";
		
		/**
		 * Eyes color.
		 * For all genders. */
		public static const EYES_COLOR:String = "eyesColor";
		
		/**
		 * Hair color.
		 * For all genders. */
		public static const HAIR_COLOR:String = "hairColor";
		
		/**
		 * Lips color.
		 * For girls only. */
		public static const LIPS_COLOR:String = "lipsColor";
		
		// Age
		
		/**
		 * Age.
		 * For boys & girls only. */
		public static const AGE:String = "age";
		
	// ---------- Cannot be modified directly - are not part of the cart
		
		/**
		 * Head.
		 * For all genders. */
		public static const HEAD:String = "head";
		
		/**
		 * Body.
		 * For all genders. */
		public static const BODY:String = "body";
		
		/**
		 * Pant.
		 * For boys and girls. */
		public static const PANT:String = "pant";
		
		/**
		 * Back hair.
		 * For girls only. */
		public static const BACK_HAIR:String = "backHair";
		
	// ---------- Helper used by the cart manager to simplify the code
		
		public static const PURCHASABLE_ITEMS:Array = [ HAT, HAIR, EYEBROWS, EYES, NOSE, MOUTH, MOUSTACHE, BEARD, SHIRT, LEFT_HAND, 
														RIGHT_HAND, SKIN_COLOR, EYES_COLOR, HAIR_COLOR, LIPS_COLOR, AGE, FACE_CUSTOM,
														EPAULET ];
		
	}
}