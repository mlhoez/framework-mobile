/*
 Copyright © 2006-2015 Ludo Factory
 Game Server - Ludokado
 Author  : Maxime Lhoez
 Created : 25 août 2014
*/
package com.ludofactory.mobile.core.avatar.maker.newItems
{
	
	import com.ludofactory.common.utils.roundUp;
	import com.ludofactory.mobile.core.avatar.AvatarAssets;
	import com.ludofactory.mobile.core.avatar.maker.TouchableItemRenderer;
	import com.ludofactory.mobile.core.avatar.maker.data.AvatarItemData;
	import com.ludofactory.mobile.core.avatar.test.config.LudokadoBones;
	import com.ludofactory.mobile.core.avatar.test.events.LKAvatarMakerEventTypes;
	
	import feathers.controls.ImageLoader;
	import feathers.events.FeathersEventType;
	
	import starling.display.Image;
	import starling.events.Event;
	
	/**
	 * Custom item renderer used in the CSThreadScreen to display
	 * a conversation between the user and the customer service.
	 */	
	public class NewItemRenderer extends TouchableItemRenderer
	{
		
	// ---------- Layout properties
		
		/**
		 * Maximum height of an item in the list. */
		public static const MAX_ITEM_HEIGHT:int = 106;
		/**
		 * Maximum width of an item in the list. */
		public static const MAX_ITEM_WIDTH:int = 106;
		
	// ---------- Layout properties
		
		/**
		 * The background. */		
		private var _background:Image;
		/**
		 * The item icon. */
		private var _itemIcon:ImageLoader;
		
	// ---------- Item renderer properties
		
		/**
		 * Item renderer data. */
		protected var _data:AvatarItemData;
		
		public function NewItemRenderer()
		{
			super();
			
			useHandCursor = true;
			touchGroup = true;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			this.width = MAX_ITEM_WIDTH;
			this.height = MAX_ITEM_HEIGHT;
			
			_background = new Image(AvatarAssets.newItemRendererBackgroundTexture);
			addChild(_background);
			
			_itemIcon = new ImageLoader();
			_itemIcon.snapToPixels = true;
			_itemIcon.addEventListener(Event.COMPLETE, onImageLoaded);
			_itemIcon.addEventListener(FeathersEventType.ERROR, onImageError);
			addChild(_itemIcon);
		}
		
		override protected function draw():void
		{
			var dataInvalid:Boolean = this.isInvalid(INVALIDATION_FLAG_DATA);
			var sizeInvalid:Boolean = this.isInvalid(INVALIDATION_FLAG_SIZE);
			
			if(dataInvalid)
				this.commitData();
			
			if(dataInvalid || sizeInvalid)
				this.layout();
		}
		
		protected function commitData():void
		{
			if(this._owner && _data)
			{
				_itemIcon.source = _data.hasBehaviors ? _data.behaviors[0].imageUrl : _data.imageUrl;
			}
		}
		
		protected function layout():void
		{
			_itemIcon.validate();
			_itemIcon.alignPivot();
			_itemIcon.x = roundUp(_background.width * 0.5) - 5;
			_itemIcon.y = roundUp(_background.height * 0.5);
		}
		
		/**
		 * When the 
		 */
		override protected function onTriggered():void
		{
			dispatchEventWith(LKAvatarMakerEventTypes.ON_NEW_ITEM_SELECTED, true, _data);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Image loading handlers
		
		/**
		 * When the image have correctly been loaded.
		 */		
		protected function onImageLoaded(event:Event):void
		{
			//invalidate(INVALIDATION_FLAG_SIZE);
			if(_data.armatureSectionType == LudokadoBones.EYES_COLOR || _data.armatureSectionType == LudokadoBones.HAIR_COLOR
					|| _data.armatureSectionType == LudokadoBones.LIPS_COLOR || _data.armatureSectionType == LudokadoBones.SKIN_COLOR)
				_itemIcon.scaleX = _itemIcon.scaleY = 0.75;
			else if( _data.armatureSectionType == LudokadoBones.MOUSTACHE || _data.armatureSectionType == LudokadoBones.BEARD ||
					_data.armatureSectionType == LudokadoBones.EYEBROWS || _data.armatureSectionType == LudokadoBones.EYES ||
					_data.armatureSectionType == LudokadoBones.FACE_CUSTOM || _data.armatureSectionType == LudokadoBones.NOSE ||
					_data.armatureSectionType == LudokadoBones.AGE )
				_itemIcon.scaleX = _itemIcon.scaleY = 0.5;
			else
				_itemIcon.scaleX = _itemIcon.scaleY = 0.6;
			
			_itemIcon.validate();
			_itemIcon.alignPivot();
			_itemIcon.x = roundUp(_background.width * 0.5) - 5;
			_itemIcon.y = roundUp(_background.height * 0.5);
		}
		
		/**
		 * When the image could not be loaded.
		 */		
		protected function onImageError(event:Event):void
		{
			// replace it by a placeholder
		}

//------------------------------------------------------------------------------------------------------------
//	Get - Set

		override public function get data():Object
		{
			return this._data;
		}

		override public function set data(value:Object):void
		{
			if(this._data == value)
			{
				return;
			}
			this._data = AvatarItemData(value);
			this.invalidate(INVALIDATION_FLAG_DATA);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
		
		override public function dispose():void
		{
			targetTouch = null;
			
			_background.removeFromParent(true);
			_background = null;
			
			_itemIcon.removeEventListener(Event.COMPLETE, onImageLoaded);
			_itemIcon.removeEventListener(FeathersEventType.ERROR, onImageError);
			_itemIcon.dispose();
			_itemIcon = null;
			
			_data = null;
			
			super.dispose();
		}
		
	}
}