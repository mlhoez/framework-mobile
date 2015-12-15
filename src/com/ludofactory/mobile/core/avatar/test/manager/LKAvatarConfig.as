/**
 * Created by Maxime on 22/07/15.
 */
package com.ludofactory.mobile.core.avatar.test.manager
{
	
	import com.ludofactory.common.utils.log;
	import com.ludofactory.mobile.core.avatar.test.config.AvatarGenderType;
	import com.ludofactory.mobile.core.avatar.test.config.LudokadoBones;
	
	/**
	 * Class holding the configuration of an avatar gender in Ludokado.com
	 */
	public class LKAvatarConfig
	{
		
	// ---------- Properties
		
		/**
		 * Gender. */
		private var _gender:int = 0;
		/**
		 * Price (in points) to unlock the gender. */
		private var _price:int = 0;
		/**
		 * Price type */
		private var _priceType:int = 0;
		/**
		 * Whether the avatar is owned. */
		private var _isOwned:Boolean = false;
		
		/**
		 * Just a helper in order to retrieve the data (the name must be the same as the values in ArmatureSectionType !) */
		private var _hat:LudokadoBoneConfiguration = new LudokadoBoneConfiguration();
		private var _hair:LudokadoBoneConfiguration = new LudokadoBoneConfiguration();
		private var _eyebrows:LudokadoBoneConfiguration = new LudokadoBoneConfiguration();
		private var _eyes:LudokadoBoneConfiguration = new LudokadoBoneConfiguration();
		private var _nose:LudokadoBoneConfiguration = new LudokadoBoneConfiguration();
		private var _mouth:LudokadoBoneConfiguration = new LudokadoBoneConfiguration();
		private var _moustache:LudokadoBoneConfiguration = new LudokadoBoneConfiguration();
		private var _beard:LudokadoBoneConfiguration = new LudokadoBoneConfiguration();
		private var _shirt:LudokadoBoneConfiguration = new LudokadoBoneConfiguration();
		private var _leftHand:LudokadoBoneConfiguration = new LudokadoBoneConfiguration();
		private var _rightHand:LudokadoBoneConfiguration = new LudokadoBoneConfiguration();
		private var _backHair:LudokadoBoneConfiguration = new LudokadoBoneConfiguration();
		private var _head:LudokadoBoneConfiguration = new LudokadoBoneConfiguration();
		private var _body:LudokadoBoneConfiguration = new LudokadoBoneConfiguration();
		private var _pant:LudokadoBoneConfiguration = new LudokadoBoneConfiguration();
		private var _faceCustom:LudokadoBoneConfiguration = new LudokadoBoneConfiguration();
		private var _eyesColor:LudokadoBoneConfiguration = new LudokadoBoneConfiguration();
		private var _hairColor:LudokadoBoneConfiguration = new LudokadoBoneConfiguration();
		private var _skinColor:LudokadoBoneConfiguration = new LudokadoBoneConfiguration();
		private var _lipsColor:LudokadoBoneConfiguration = new LudokadoBoneConfiguration();
		private var _age:LudokadoBoneConfiguration = new LudokadoBoneConfiguration();
		private var _epaulet:LudokadoBoneConfiguration = new LudokadoBoneConfiguration();
		
		public function LKAvatarConfig(genderId:int)
		{
			_gender = genderId;
		}
		
//------------------------------------------------------------------------------------------------------------
//	Parse
		
		/**
		 * Parse the given configuration.
		 */
		public function initialize(config:Object):void
		{
			if(config)
			{
				for (var i:int = 0; i < LudokadoBones.PURCHASABLE_ITEMS.length; i++)
					LudokadoBoneConfiguration(this[LudokadoBones.PURCHASABLE_ITEMS[i]]).initialize(config[LudokadoBones.PURCHASABLE_ITEMS[i]]);
				
				if( "price" in config && config.price != null ) _price = int(config.price);
				if( "paiementType" in config && config.paiementType != null ) _priceType = int(config.paiementType);
				if( "isOwned" in config && config.isOwned != null ) _isOwned = Boolean(config.isOwned);
			}
		}
		
		/**
		 * Parse the given configuration.
		 */
		public function parseConfig(config:Object):void
		{
			if(config)
			{
				for (var i:int = 0; i < LudokadoBones.PURCHASABLE_ITEMS.length; i++)
					LudokadoBoneConfiguration(this[LudokadoBones.PURCHASABLE_ITEMS[i]]).parse(config[LudokadoBones.PURCHASABLE_ITEMS[i]]);
				
				if( "price" in config && config.price != null ) _price = int(config.price);
				if( "paiementType" in config && config.paiementType != null ) _priceType = int(config.paiementType);
				if( "isOwned" in config && config.isOwned != null ) _isOwned = Boolean(config.isOwned);
				
				log("Gender " + AvatarGenderType.gerGenderNameById(_gender) + " parsed and owned ? " + _isOwned)
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Utils
		
		/**
		 * Resets the configuration to the user values.
		 */
		public function resetToUser():void
		{
			for (var i:int = 0; i < LudokadoBones.PURCHASABLE_ITEMS.length; i++)
				LudokadoBoneConfiguration(this[LudokadoBones.PURCHASABLE_ITEMS[i]]).resetToUser();
		}
		
		/**
		 * Generate the temporary user configuration.
		 *
		 * BEWARE that it's the current one with the items ids the user played with.
		 */ 
		public function generateTemporaryConfig():Object
		{
			var avatar:Object = {};
			avatar.idGender = _gender;
			var armatureType:String;
			for (var i:int = 0; i < LudokadoBones.PURCHASABLE_ITEMS.length; i++)
			{
				armatureType = LudokadoBones.PURCHASABLE_ITEMS[i];
				avatar[armatureType] = {};
				avatar[armatureType].itemId = LudokadoBoneConfiguration(this[armatureType]).isCheckedInCart ? LudokadoBoneConfiguration(this[armatureType]).tempId : LudokadoBoneConfiguration(this[armatureType]).id;
				//avatar[armatureType].isChecked = LudokadoBoneConfiguration(this[armatureType]).isCheckedInCart;
			}
			
			return avatar;
		}
		
		/**
		 * Generate the user configuration.
		 * 
		 * BEWARE that it's the one the user had at the last save !
		 */
		public function generateUserConfig():Object
		{
			var avatar:Object = {};
			avatar.idGender = _gender;
			var armatureType:String;
			for (var i:int = 0; i < LudokadoBones.PURCHASABLE_ITEMS.length; i++)
			{
				armatureType = LudokadoBones.PURCHASABLE_ITEMS[i];
				avatar[armatureType] = {};
				avatar[armatureType].itemId = LudokadoBoneConfiguration(this[armatureType]).id;
			}
			
			return avatar;
		}
		
		/**
		 * Checks if the current configuration match to the user configuration.
		 */
		public function isUserConfiguration():Boolean
		{
			for (var i:int = 0; i < LudokadoBones.PURCHASABLE_ITEMS.length; i++)
			{
				if(!LudokadoBoneConfiguration(this[LudokadoBones.PURCHASABLE_ITEMS[i]]).isUserConfiguration())
					return false;
			}
			return true;
		}
		
//------------------------------------------------------------------------------------------------------------
//	Get - Set
		
		public function get gender():int { return _gender; }
		public function get price():int { return _price; }
		public function get priceType():int { return _priceType; }
		public function get isOwned():Boolean { return _isOwned; }
		public function get leftHand():LudokadoBoneConfiguration { return _leftHand; }
		public function get hat():LudokadoBoneConfiguration { return _hat; }
		public function get hair():LudokadoBoneConfiguration { return _hair; }
		public function get backHair():LudokadoBoneConfiguration { return _backHair; }
		public function get eyebrows():LudokadoBoneConfiguration { return _eyebrows; }
		public function get eyes():LudokadoBoneConfiguration { return _eyes; }
		public function get nose():LudokadoBoneConfiguration { return _nose; }
		public function get mouth():LudokadoBoneConfiguration { return _mouth; }
		public function get head():LudokadoBoneConfiguration { return _head; }
		public function get body():LudokadoBoneConfiguration { return _body; }
		public function get shirt():LudokadoBoneConfiguration { return _shirt; }
		public function get pant():LudokadoBoneConfiguration { return _pant; }
		public function get faceCustom():LudokadoBoneConfiguration { return _faceCustom; }
		public function get moustache():LudokadoBoneConfiguration { return _moustache; }
		public function get beard():LudokadoBoneConfiguration { return _beard; }
		public function get rightHand():LudokadoBoneConfiguration { return _rightHand; }
		public function get eyesColor():LudokadoBoneConfiguration { return _eyesColor; }
		public function get hairColor():LudokadoBoneConfiguration { return _hairColor; }
		public function get skinColor():LudokadoBoneConfiguration { return _skinColor; }
		public function get lipsColor():LudokadoBoneConfiguration { return _lipsColor; }
		public function get epaulet():LudokadoBoneConfiguration { return _epaulet; }
		public function get age():LudokadoBoneConfiguration { return _age; }
		
	}
}