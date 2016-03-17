/*
 Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
 Framework mobile
 Author  : Maxime Lhoez
 Created : 14 Décembre 2014
*/
package com.ludofactory.mobile.core.avatar.maker.data
{
	
	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.mobile.core.avatar.maker.items.ItemManager;
	import com.ludofactory.mobile.core.avatar.test.manager.LKConfigManager;
	import com.ludofactory.mobile.core.avatar.test.manager.LudokadoBoneConfiguration;
	
	/**
	 * Ludokado avatar item data.
	 * 
	 * This data is used by the GlobbiesItemRenderer class.
	 * 
	 * @see com.ludofactory.server.avatar.customization.items.AvatarItemRenderer
	 */
	public class AvatarItemData
	{
		
	// ---------- Item properties
		
		/**
		 * Item id in database (if 1 behavior, it's the value of this one). */
		private var _id:int;
		/**
		 * The item export name in the FLA (ex : "hat_1"). */
		private var _linkageName:String;
		/**
		 * The extracted item id (ex : for the item "hat_1", it will be 1). Mainly used to link items between them. */
		private var _extractedId:int;
		/**
		 * Item display name. */
		private var _name:String = "";
		/**
		 * Item price (if 1 behavior, it's the value of this one). */
		private var _price:Number = -1;
		/**
		 * Whether it's a new item (if 1 behavior, it's the value of this one). */
		private var _isNew:Boolean = false;
		/**
		 * Whether it's a Vip item (if 1 behavior, it's the value of this one). */
		private var _isNewVip:Boolean = false;
		/**
		 * Whether the item is locked (because of a vip rank) - (if 1 behavior, it's the value of this one). */
		private var _isLocked:Boolean = false;
		/**
		 * The rank id (used to display the rank icon when _isVip is set to true) (if 1 behavior, it's the value of this one). */
		private var _rank:int;
		/**
		 * The rank name. */
		private var _rankName:String;
		/**
		 * The frame name : it is necessary for color items. */
		private var _frameName:String;
		/**
		 * Section type = to which section this item belongs. */
		private var _armatureSectionType:String;
		/**
		 * Somes items are linked together, for example the hair and hats. This property is used to name this group
		 * and load the correct items in the list. */
		private var _armatureGroup:String;
		/**
		 * List of behaviors associated to this item. */
		private var _behaviors:Vector.<AvatarFrameData> = new Vector.<AvatarFrameData>();
		/**
		 * Item image url. */
		private var _imageUrl:String = "";
		/**
		 * Whether the item is owned (if 1 behavior, it's the value of this one). */
		private var _isOwned:Boolean = false;
		
	// ---------- Item renderer properties

		/**
		 * Whether the item is selected for purchase in the list. */
		private var _isSelected:Boolean = false;
		/**
		 * Whether the item is expanded (only available if there are behaviors to display). */
		private var _isExpanded:Boolean = false;
		/**
		 * Whether the section can be emptied. */
		private var _isEmptyable:Boolean = false;
		/**
		 * Whether the item has behaviors. */
		private var _hasBehaviors:Boolean = false;
		
		public function AvatarItemData(data:Object)
		{
			_armatureSectionType = String(data.armatureSectionType);
			_armatureGroup = String(data.armatureGroup);
			_linkageName = String(data.flashId);
			_extractedId = _linkageName.split("_")[2];
			_isEmptyable = _extractedId == 0 && ItemManager.isEmptiable(_armatureSectionType);
			_name = _isEmptyable ? _("Retirer") : String(data.name);
			_hasBehaviors = (data.behaviors as Array).length > 1;
			
			var frameData:AvatarFrameData;
			if(_hasBehaviors)
			{
				// parse behaviors
				for (var i:int = 0; i < (data.behaviors as Array).length; i++)
				{
					frameData = new AvatarFrameData(data.behaviors[i], _armatureSectionType);
					_behaviors.push(frameData);
					
					if(frameData.id == LudokadoBoneConfiguration(LKConfigManager.currentConfig[_armatureSectionType]).tempId)
					{
						_isSelected = true;
						frameData.isSelected = true;
					}
				}
			}
			else
			{
				frameData = new AvatarFrameData(data.behaviors[0], _armatureSectionType);
				_id = frameData.id;
				_isOwned = frameData.isOwned;
				_price = frameData.price;
				_isNew = frameData.isNew;
				_isNewVip = frameData.isNewVip;
				_rank = frameData.rank;
				_rankName = frameData.rankName;
				_imageUrl = frameData.imageUrl;
				_frameName = frameData.frameName;
				_isLocked = frameData.isLocked;
				_isSelected = _id == LudokadoBoneConfiguration(LKConfigManager.currentConfig[_armatureSectionType]).tempId;
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Utils
		
		/**
		 * Returns true if at least one behavior is owned.
		 */
		public function hasOwnedBehaviors():Boolean
		{
			for (var i:int = 0; i < _behaviors.length; i++)
			{
				if(_behaviors[i].isOwned )
					return true;
			}
			
			return false;
		}
		
		/**
		 * Returns true if one of the behaviors is a new common one.
		 */
		public function hasNewCommonBehavior():Boolean
		{
			var frameData:AvatarFrameData;
			for (var i:int = 0; i < _behaviors.length; i++)
			{
				frameData = _behaviors[i];
				if(frameData.isNew)
					return true;
			}
			return false;
		}
		
		/**
		 * Returns true if one of the behaviors is a new vip one.
		 */
		public function hasNewVipBehavior():Boolean
		{
			var frameData:AvatarFrameData;
			for (var i:int = 0; i < _behaviors.length; i++)
			{
				frameData = _behaviors[i];
				if(frameData.isNewVip)
					return true;
			}
			return false;
		}
		
//------------------------------------------------------------------------------------------------------------
//	Get - Set
		
		// ---------- Item getters and setters
		
		/**
		 * Item id in database. */
		public function get id():int { return _id; }
		/**
		 * The item name in the FLA (ex : "hat_1"). */
		public function get linkageName():String { return _linkageName; }
		/**
		 * The extracted item id (ex : for the item "hat_1", it will be 1). */
		public function get extractedId():int { return _extractedId; }
		/**
		 * Item name. */
		public function get name():String { return _name; }
		/**
		 * Item price. */
		public function get price():Number { return _price; }
		/**
		 * Whether it's a new common item (if 1 behavior, it's the value of this one). */
		public function get isNew():Boolean{ return _hasBehaviors ? hasNewCommonBehavior() : _isNew; }
		/**
		 * Whether it's a new Vip item (if 1 behavior, it's the value of this one). */
		public function get isNewVip():Boolean { return _hasBehaviors ? hasNewVipBehavior() : _isNewVip; }
		/**
		 * The rank id (used to display the rank icon when _isVip is set to true) (if 1 behavior, it's the value of this one). */
		public function get rank():int { return _rank; }
		/**
		 * The rank name. */
		public function get rankName():String { return _rankName; }
		/**
		 * Whether the item is locked (because of a vip rank) - (if 1 behavior, it's the value of this one). */
		public function get isLocked():Boolean { return _isLocked; }
		/**
		 * The frame name : it is necessary for color items. */
		public function get frameName():String { return _frameName; }
		/**
		 * Section type = to which section this item belongs.*/
		public function get armatureSectionType():String { return _armatureSectionType; }
		/**
		 * Somes items are linked together, for example the hair and hats. This property is used to name this group
		 * and load the correct items in the list. */
		public function get armatureGroup():String { return _armatureGroup; }
		/**
		 * List of behaviors associated to this item. */
		public function get behaviors():Vector.<AvatarFrameData> { return _behaviors; }
		/**
		 * Item image url. */
		public function get imageUrl():String { return _imageUrl; }
		/**
		 * Whether the item is owned. */
		public function get isOwned():Boolean { return _isOwned; }
		public function set isOwned(value:Boolean):void { _isOwned = value; }
		
		// ---------- Item renderer getters and setters
		
		/**
		 * Whether the item is selected for purchase in the list. */
		public function get isSelected():Boolean { return _isSelected; }
		public function set isSelected(value:Boolean):void { _isSelected = value; }
		/**
		 * Whether the item is expanded (only available if there are behaviors to display). */
		public function get isExpanded():Boolean { return _isExpanded; }
		public function set isExpanded(value:Boolean):void { _isExpanded = value; }
		/**
		 * Whether the section can be emptied. */
		public function get isEmptyable():Boolean { return _isEmptyable; }
		/**
		 * Whether the item has behaviors. */
		public function get hasBehaviors():Boolean { return _hasBehaviors; }
		
	}
}