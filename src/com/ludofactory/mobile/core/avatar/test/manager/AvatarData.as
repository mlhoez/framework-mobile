/**
 * Created by Maxime on 23/10/15.
 */
package com.ludofactory.mobile.core.avatar.test.manager
{
	
	/**
	 * Custom class used by each armature in the avatar.userData property.
	 */
	public class AvatarData
	{
		/**
		 * The gender id associated to this avatar.
		 * @see com.ludofactory.ludokado.config.AvatarGenderType */
		private var _genderId:int;
		
		/**
		 * Display type.
		 * @see com.ludofactory.ludokado.config.AvatarDisplayerType */
		private var _displayType:String;
		
		/**
		 * Whether the avatar is touchable / clickable.
		 * @see com.ludofactory.ludokado.config.AvatarDisplayerType */
		private var _isTouchable:Boolean;
		
		public function AvatarData(genderId:int, displayType:String, isTouchable:Boolean)
		{
			_genderId = genderId;
			_displayType = displayType;
			_isTouchable = isTouchable;
		}
		
//------------------------------------------------------------------------------------------------------------
//	Get - Set
		
		/**
		 * The gender id associated to this avatar.
		 * @see com.ludofactory.ludokado.config.AvatarGenderType */
		public function get genderId():int { return _genderId; }
		/**
		 * Display type.
		 * @see com.ludofactory.ludokado.config.AvatarDisplayerType */
		public function get displayType():String { return _displayType; }
		/**
		 * Whether the avatar is touchable / clickable.
		 * @see com.ludofactory.ludokado.config.AvatarDisplayerType */
		public function get isTouchable():Boolean { return _isTouchable; }
		
	}
}