/*
 Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
 Framework mobile
 Author  : Maxime Lhoez
 Created : 24 Août 2015
*/
package com.ludofactory.mobile.core.avatar.maker.items
{
	
	import com.ludofactory.mobile.core.avatar.maker.data.AvatarFrameData;
	import com.ludofactory.mobile.core.avatar.maker.data.AvatarItemData;
	import com.ludofactory.mobile.core.avatar.maker.sections.SectionData;
	import com.ludofactory.mobile.core.avatar.test.config.AvatarGenderType;
	import com.ludofactory.mobile.core.avatar.test.config.LudokadoBones;
	import com.ludofactory.mobile.core.avatar.test.manager.LKConfigManager;
	import com.ludofactory.mobile.core.avatar.test.manager.LudokadoBoneConfiguration;
	
	/**
	 * Item Manager
	 */
	public class ItemManager
	{
		
	// ---------- Constants & Statics
		/**
		 * List of emptiable sections.
		 * This is used by the AvatarItemData in order to replace the item name and icon by "Remove". */
		private static const EMPTIABLE_SECTIONS_HUMAN:Array = [LudokadoBones.FACE_CUSTOM, LudokadoBones.MOUSTACHE, LudokadoBones.BEARD, LudokadoBones.HAT, LudokadoBones.LEFT_HAND, LudokadoBones.RIGHT_HAND];
		private static const EMPTIABLE_SECTIONS_POTATO:Array = [LudokadoBones.SHIRT, LudokadoBones.LEFT_HAND, LudokadoBones.RIGHT_HAND, LudokadoBones.EPAULET];
		
		/**
		 * ItemManager instance. */
		private static var _instance:ItemManager;
		
	// ---------- Common properties
		
		/**
		 * List of items. */
		private var _items:Object;
		/**
		 * Selector data. */
		//private var _selectorData:Array = [];
		/**
		 * New VIP items to display at launch. */
		private var _newVipItems:Vector.<AvatarItemData>;
		/**
		 * New common items to display at launch. */
		private var _newCommonItems:Vector.<AvatarItemData>;
		
		public function ItemManager(sk:SecurityKey)
		{
			if(sk == null)
				throw new Error("Error : direct instanciation not allowed, use ItemManager.getInstance() instead.");
		}
		
//------------------------------------------------------------------------------------------------------------
//	

		/**
		 * Parses the data (items, selector, new items).
		 * 
		 * @param data
		 */
		public function parseData(data:Object):void
		{
			var i:int = 0;
			
			//data = DebugItems.ITEMS;
			_items = {};
			var itemData:AvatarItemData;
			for each(var object:Object in data.listItem)
			{
				// else simply put it in the correct group
				itemData = new AvatarItemData(object);
				if( !_items.hasOwnProperty(itemData.armatureGroup) )
					_items[itemData.armatureGroup] = new Vector.<AvatarItemData>();
				(_items[itemData.armatureGroup] as Vector.<AvatarItemData>).push( itemData );
			}
			
			// build the selector
			/*_selectorData = [];
			if(data.selector)
			{
				var categoryData:Object;
				var elementToPush:Object;
				var tempList:Vector.<SectionData>;
				for (i = 0; i < data.selector.length; i++)
				{
					// categoryData => { categoryName:"", section"" }
					categoryData = data.selector[i];
					elementToPush = { header:categoryData.categoryName, children:[] };
					tempList = new Vector.<SectionData>();
					for (var j:int = 0; j < categoryData.sections.length; j++)
					{
						tempList.push( new SectionData(categoryData.sections[j]) );
					}
					elementToPush.children.push( tempList );
					_selectorData.push(elementToPush);
				}
			}*/
			
			/*log(LKConfigManager.currentGenderId);
			if(LKConfigManager.currentGenderId == AvatarGenderType.GIRL)
			{
				data.newItems = {};
				data.newItems.vip = [
					JSON.parse('{"flashId":"eyebrows_0","name":"Sourcils 0","armatureSectionType":"mouth","behaviors":[{"urlImage":"//img.ludokado.com/img/frontoffice/fr/v4/avatar/eyebrows/boy/eyebrows_0.png","price":0,"paiementType":1,"name":"defaut","isNewVip":false,"isOwned":false,"flashId":"defaut","id":119,"rang":1,"isNew":true}]}'),
					JSON.parse('{"flashId":"hat_5","name":"Sourcils 0","armatureSectionType":"hat","behaviors":[{"urlImage":"//img.ludokado.com/img/frontoffice/fr/v4/avatar/hat/human/hat_4.png","price":0,"paiementType":1,"name":"defaut","isNewVip":false,"isOwned":false,"flashId":"defaut","id":98,"rang":1,"isNew":true}]}'),
					JSON.parse('{"flashId":"eyebrows_2","name":"Sourcils 0","armatureSectionType":"eyebrows","behaviors":[{"urlImage":"//img.ludokado.com/img/frontoffice/fr/v4/avatar/eyebrows/boy/eyebrows_0.png","price":0,"paiementType":1,"name":"defaut","isNewVip":false,"isOwned":false,"flashId":"defaut","id":1,"rang":1,"isNew":true}]}'),
					JSON.parse('{"flashId":"eyebrows_3","name":"Sourcils 0","armatureSectionType":"eyebrows","behaviors":[{"urlImage":"//img.ludokado.com/img/frontoffice/fr/v4/avatar/eyebrows/boy/eyebrows_0.png","price":0,"paiementType":1,"name":"defaut","isNewVip":false,"isOwned":false,"flashId":"defaut","id":1,"rang":1,"isNew":true}]}')
				];
				data.newItems.common = [
					JSON.parse('{"flashId":"eyebrows_0","name":"Sourcils 0","armatureSectionType":"eyebrows","behaviors":[{"urlImage":"//img.ludokado.com/img/frontoffice/fr/v4/avatar/eyebrows/boy/eyebrows_0.png","price":0,"paiementType":1,"name":"defaut","isNewVip":false,"isOwned":false,"flashId":"defaut","id":1,"rang":1,"isNew":true}]}'),
					JSON.parse('{"flashId":"eyebrows_1","name":"Sourcils 0","armatureSectionType":"eyebrows","behaviors":[{"urlImage":"//img.ludokado.com/img/frontoffice/fr/v4/avatar/eyebrows/boy/eyebrows_0.png","price":0,"paiementType":1,"name":"defaut","isNewVip":false,"isOwned":false,"flashId":"defaut","id":1,"rang":1,"isNew":true}]}'),
					JSON.parse('{"flashId":"eyebrows_2","name":"Sourcils 0","armatureSectionType":"eyebrows","behaviors":[{"urlImage":"//img.ludokado.com/img/frontoffice/fr/v4/avatar/eyebrows/boy/eyebrows_0.png","price":0,"paiementType":1,"name":"defaut","isNewVip":false,"isOwned":false,"flashId":"defaut","id":1,"rang":1,"isNew":true}]}'),
					JSON.parse('{"flashId":"eyebrows_3","name":"Sourcils 0","armatureSectionType":"eyebrows","behaviors":[{"urlImage":"//img.ludokado.com/img/frontoffice/fr/v4/avatar/eyebrows/boy/eyebrows_0.png","price":0,"paiementType":1,"name":"defaut","isNewVip":false,"isOwned":false,"flashId":"defaut","id":1,"rang":1,"isNew":true}]}')
				];
			}*/
			
			
			/*
				Important :
				In order to test the new items, we need to go to the back office, in "Configuration des déclinaisons", then
				select one item, a gender and change the start date to "now"
			 */
			
			// fetch the new items
			_newVipItems = new Vector.<AvatarItemData>();
			_newCommonItems = new Vector.<AvatarItemData>();
			if("newItems" in data && data.newItems)
			{
				if ("vip" in data.newItems && data.newItems.vip)
				{
					// there are new vip items
					for (i = 0; i < data.newItems.vip.length; i++)
						_newVipItems.push(new AvatarItemData(data.newItems.vip[i]));
				}
				
				if ("common" in data.newItems && data.newItems.common)
				{
					// there are new common items
					for (i = 0; i < data.newItems.common.length; i++)
						_newCommonItems.push(new AvatarItemData(data.newItems.common[i]));
				}
			}
		}
		
		public function hasNewItemsToShow():Boolean
		{
			return (_newVipItems && _newVipItems.length > 0) || (_newCommonItems && _newCommonItems.length > 0);
		}
		
		public function updateListAfterPurchase():void
		{
			var sectionItemsList:Vector.<AvatarItemData>;
			var itemData:AvatarItemData;
			var frameData:AvatarFrameData;
			
			// loop through all sections
			for(var armatureSectionType:String in _items )
			{
				// retrieve all the items for this section and loop through them
				sectionItemsList = _items[armatureSectionType];
				for (var i:int = 0; i < sectionItemsList.length; i++)
				{
					itemData = sectionItemsList[i];
					// the purchased item was selected for sure, so we can check for the isSelected property to find
					// the right item in the section
					if (itemData.isSelected)
					{
						//log('Checking ' + armatureSectionType + " for item " + itemData.name);
						
						if (itemData.behaviors.length > 0)
						{
							// we purchased a behavior, so we also need to update the purchased behavior
							for (var j:int = 0; j < itemData.behaviors.length; j++)
							{
								frameData = itemData.behaviors[j];
								if (frameData.id == LudokadoBoneConfiguration(LKConfigManager.currentConfig[armatureSectionType]).id)
								{
									frameData.isOwned = true;
								}
							}
						}
						else
						{
							// the item was purchased, so update it's state
							if(itemData.id == LudokadoBoneConfiguration(LKConfigManager.currentConfig[itemData.armatureSectionType]).id)
								itemData.isOwned = true;
						}
					}
				}
			}
		}
		
		/**
		 * Called after a reset or a random.
		 * 
		 * 
		 * 
		 * @param byUserConfig Whether we use the user config to update the isSelected states.
		 */
		public function updateSelectedStates(byUserConfig:Boolean):void
		{
			var sectionItemsList:Vector.<AvatarItemData>;
			var itemData:AvatarItemData;
			var frameData:AvatarFrameData;
			
			// loop through all sections
			for(var armatureSectionType:String in _items )
			{
				// retrieve all the items for this section and loop through them
				sectionItemsList = _items[armatureSectionType];
				for (var i:int = 0; i < sectionItemsList.length; i++)
				{
					itemData = sectionItemsList[i];
					if (itemData.behaviors.length > 0)
					{
						// the item has behaviors, thus we need to select  the behavior if necessary
						for (var j:int = 0; j < itemData.behaviors.length; j++)
						{
							frameData = itemData.behaviors[j];
							itemData.isSelected = frameData.isSelected = frameData.id == (byUserConfig ? LudokadoBoneConfiguration(LKConfigManager.currentConfig[armatureSectionType]).id : LudokadoBoneConfiguration(LKConfigManager.currentConfig[armatureSectionType]).tempId);
							if(itemData.isSelected)
								itemData.isExpanded = true;
						}
					}
					else
					{
						itemData.isSelected = itemData.id == (byUserConfig ? LudokadoBoneConfiguration(LKConfigManager.currentConfig[itemData.armatureSectionType]).id : LudokadoBoneConfiguration(LKConfigManager.currentConfig[itemData.armatureSectionType]).tempId);
					}
				}
			}
		}
		
		public function newItemHasBehaviors(newItemToCheck:AvatarItemData):Boolean
		{
			var sectionItemsList:Vector.<AvatarItemData>;
			var itemData:AvatarItemData;
			var frameData:AvatarFrameData;
			
			// loop through all sections
			for(var armatureSectionType:String in _items )
			{
				if(armatureSectionType == newItemToCheck.armatureSectionType)
				{
					// retrieve all the items for this section and loop through them
					sectionItemsList = _items[armatureSectionType];
					for (var i:int = 0; i < sectionItemsList.length; i++)
					{
						itemData = sectionItemsList[i];
						if (itemData.hasBehaviors)
						{
							// the item has behaviors, thus we need to select the behavior if necessary
							for (var j:int = 0; j < itemData.behaviors.length; j++)
							{
								frameData = itemData.behaviors[j];
								if(frameData.id == (newItemToCheck.hasBehaviors ? newItemToCheck.behaviors[0].id : newItemToCheck.id))
									return true;
							}
						}
					}
				}
			}
			return false;
		}
		
//------------------------------------------------------------------------------------------------------------
//	Helpers
		
		/**
		 * Determines if the section given in parameters is emptiable.
		 * 
		 * @param armatureSectionType The armature section type to check
		 * 
		 * @return true if emptiable, false otherwise
		 */
		public static function isEmptiable(armatureSectionType:String):Boolean
		{
			if(LKConfigManager.currentGenderId != AvatarGenderType.POTATO)
				return EMPTIABLE_SECTIONS_HUMAN.indexOf(armatureSectionType) > -1;
			else
				return EMPTIABLE_SECTIONS_POTATO.indexOf(armatureSectionType) > -1;
		}

//------------------------------------------------------------------------------------------------------------
//	Get

		/**
		 * List of items. */
		public function get items():Object { return _items; }
		public function get newVipItems():Vector.<AvatarItemData> { return _newVipItems; }
		public function get newCommonItems():Vector.<AvatarItemData> { return _newCommonItems; }
		//public function get selectorData():Array { return _selectorData; }
		
//------------------------------------------------------------------------------------------------------------
//	Singleton

		/**
		 * Singleton.
		 */
		public static function getInstance():ItemManager
		{
			if(_instance == null)
				_instance = new ItemManager(new SecurityKey());
			return _instance;
		}
	}
}

internal class SecurityKey{}