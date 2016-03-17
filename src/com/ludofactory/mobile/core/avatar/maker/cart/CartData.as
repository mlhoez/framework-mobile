/*
 Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
 Framework mobile
 Author  : Maxime Lhoez
 Created : 22 Décembre 2014
*/
package com.ludofactory.mobile.core.avatar.maker.cart
{
	
	import com.ludofactory.mobile.core.avatar.maker.data.AvatarFrameData;
	import com.ludofactory.mobile.core.avatar.maker.data.AvatarItemData;
	
	/**
	 * Data used by the CartItemRenderer in order to display the items to buy in the list.
	 */
	public class CartData
	{
		/**
		 * AvatarItemData. */
		private var _itemData:AvatarItemData;
		/**
		 * AvatarFrameData. */
		private var _frameData:AvatarFrameData;
		
		// helper for the item renderer
		
		/**
		 * Whether the item is checked, thus took in account of the total count. */
		private var _isChecked:Boolean = true;
		
		public function CartData(itemData:AvatarItemData, frameData:AvatarFrameData)
		{
			_itemData = itemData;
			_frameData = frameData;
			_isChecked = !isLocked;
		}
		
//------------------------------------------------------------------------------------------------------------
//	Get - Set
		
		public function get itemData():AvatarItemData { return _itemData; }
		public function get frameData():AvatarFrameData { return _frameData; }
		
		public function get id():int  { return _frameData == null ? _itemData.id : _frameData.id; }
		public function get name():String { return _frameData == null ? _itemData.name : (_itemData.name + " (" + _frameData.name +")"); }
		public function get price():int  { return _frameData == null ? _itemData.price : _frameData.price; }
		public function get isOwned():Boolean { return _frameData == null ? _itemData.isOwned : _frameData.isOwned; }
		public function get isSelected():Boolean  { return _frameData == null ? _itemData.isSelected : _frameData.isSelected; }
		public function get armatureSectionType():String { return _itemData.armatureSectionType; }
		public function get imageUrl():String { return _frameData == null ? _itemData.imageUrl : _frameData.imageUrl; }
		public function get rank():int { return _frameData == null ? _itemData.rank : _frameData.rank; }
		public function get rankName():String { return _frameData == null ? _itemData.rankName : _frameData.rankName; }
		public function get isLocked():Boolean { return _frameData == null ? _itemData.isLocked : _frameData.isLocked; }
		public function get isChecked():Boolean { return _isChecked; }
		public function set isChecked(value:Boolean):void { _isChecked = value; }
		
	}
}