/*
 Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
 Framework mobile
 Author  : Maxime Lhoez
 Created : 17 Décembre 2014
*/
package com.ludofactory.mobile.core.avatar.maker.data
{
	
	import com.ludofactory.mobile.core.manager.MemberManager;
	
	/**
	 * This item is associated to a GlobbiesItemData.
	 * 
	 * It represents a behavior (i.e. an animation) associated to the item and
	 * which can be purchased.
	 */
	public class AvatarFrameData
	{
		
	// ---------- Item properties
		
		/**
		 * Behavior id (in database). */
		private var _id:int;
		/**
		 * The behavior display name. */
		private var _name:String = "";
		/**
		 * The behavior frame name (used to switch frame on the item). */
		private var _frameName:String = "";
		/**
		 * The behavior price. */
		private var _price:Number = -1;
		/**
		 * Whether it's a new common item. */
		private var _isNew:Boolean = false;
		/**
		 * Whether it's a new Vip item. */
		private var _isNewVip:Boolean = false;
		/**
		 * The rank id (used to display the rank icon when _isVip is set to true). */
		private var _rank:int;
		/**
		 * The rank name. */
		private var _rankName:String;
		/**
		 * Whether the item is locked (because of a vip rank). */
		private var _isLocked:Boolean = false;
		/**
		 * Behavior image url. */
		private var _imageUrl:String = "";
		/**
		 * Whether this behavior is owned by the user. */
		private var _isOwned:Boolean = false;
		/**
		 * Armature section type. */
		private var _armatureSectionType:String;
		
	// ---------- Item renderer properties

		/**
		 * Whether the item is selected for purchase in the list. */
		private var _isSelected:Boolean = false;
		
		/**
		 * @param data The data to be parsed
		 * @param armatureSectionType 
		 */
		public function AvatarFrameData(data:Object, armatureSectionType:String)
		{
			// paiementType is not used for the moment
			
			_id = int(data.id);
			_name = String(data.name);
			_frameName = String(data.flashId);
			_price = Number(data.price);
			_isOwned = Boolean(data.isOwned);
			_isNew = Boolean(data.isNew);
			_isNewVip = Boolean(data.isNewVip);
			_rank = int(data.rang);
			_rankName = String(data.rankName);
			_isLocked = MemberManager.getInstance().rank < int(data.rang);
			_imageUrl = String(data.urlImage);
			_armatureSectionType = armatureSectionType;
		}

//------------------------------------------------------------------------------------------------------------
//	Get - Set
		
		// ---------- Item getters and setters
		
		/**
		 * Behavior id (in database). */
		public function get id():int { return _id; }
		/**
		 * The behavior display name. */
		public function get name():String { return _name; }
		/**
		 * The behavior frame name (used to switch frame on the item). */
		public function get frameName():String { return _frameName; }
		/**
		 * The behavior price. */
		public function get price():Number { return _price; }
		/**
		 * Whether it's a new common item. */
		public function get isNew():Boolean { return _isNew; } 
		/**
		 * Whether it's a new Vip item. */
		public function get isNewVip():Boolean { return _isNewVip; }
		/**
		 * The rank id (used to display the rank icon when _isVip is set to true). */
		public function get rank():int { return _rank; }
		/**
		 * The ran name. */
		public function get rankName():String { return _rankName; }
		/**
		 * Whether the item is locked (because of a vip rank). */
		public function get isLocked():Boolean { return _isLocked; }
		/**
		 * */
		public function get imageUrl():String { return _imageUrl; }
		/**
		 * Whether this behavior is owned by the user. */
		public function get isOwned():Boolean { return _isOwned; }
		public function set isOwned(value:Boolean):void { _isOwned = value; }
		/**
		 * Armature section type. */
		public function get armatureSectionType():String { return _armatureSectionType; }
		public function set armatureSectionType(value:String):void { _armatureSectionType = value; }
		
		// ---------- Item renderer getters and setters
		
		/**
		 * Whether the item is selected for purchase in the list. */
		public function get isSelected():Boolean { return _isSelected; }
		public function set isSelected(value:Boolean):void { _isSelected = value; }
		
	}
}