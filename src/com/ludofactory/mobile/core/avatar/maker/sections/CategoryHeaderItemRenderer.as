/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 14 oct. 2013
*/
package com.ludofactory.mobile.core.avatar.maker.sections
{
	
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import feathers.controls.GroupedList;
	import feathers.controls.renderers.IGroupedListHeaderOrFooterRenderer;
	import feathers.core.FeathersControl;
	
	import starling.display.Quad;
	import starling.events.Event;
	import starling.text.TextField;
	import starling.utils.HAlign;
	import starling.utils.VAlign;
	
	/**
	 * Item renderer used to display the header in the tournaments ranking list.
	 */	
	public class CategoryHeaderItemRenderer extends FeathersControl implements IGroupedListHeaderOrFooterRenderer
	{
		/**
		 * The base height of a line in the list. */		
		private static const BASE_HEIGHT:int = 35;
		
		/**
		 * Name of the current gift. */		
		private var _title:TextField;
		
		/**
		 * Bottom stripe. */
		private var _stripe:Quad;
		
		public function CategoryHeaderItemRenderer()
		{
			super();
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			this.height = scaleAndRoundToDpi(BASE_HEIGHT);
			
			_stripe = new Quad(5, 1, 0xffffff);
			_stripe.alpha = 0.75;
			addChild(_stripe);
			
			_title = new TextField(10, BASE_HEIGHT, "", Theme.FONT_OSWALD, scaleAndRoundToDpi(16), 0xffffff, true);
			_title.hAlign = HAlign.LEFT;
			_title.vAlign = VAlign.BOTTOM;
			addChild(_title);
		}
		
		override protected function draw():void
		{
			const dataInvalid:Boolean = this.isInvalid(INVALIDATION_FLAG_DATA);
			var sizeInvalid:Boolean = this.isInvalid(INVALIDATION_FLAG_SIZE);
			
			if(dataInvalid)
			{
				this.commitData();
			}
			
			sizeInvalid = this.autoSizeIfNeeded() || sizeInvalid;
			
			if(dataInvalid || sizeInvalid)
			{
				this.layout();
			}
		}
		
		protected function autoSizeIfNeeded():Boolean
		{
			const needsWidth:Boolean = isNaN(this.explicitWidth);
			const needsHeight:Boolean = isNaN(this.explicitHeight);
			if(!needsWidth && !needsHeight)
			{
				return false;
			}
			var newWidth:Number = this.explicitWidth;
			if(needsWidth)
			{
				newWidth = _title.width;
			}
			var newHeight:Number = this.explicitHeight;
			if(needsHeight)
			{
				newHeight = _title.height;
			}
			return this.setSizeInternal(newWidth, newHeight, false);
		}
		
		protected function commitData():void
		{
			if(this._owner && _data)
			{
				_title.text = String(_data);
			}
		}
		
		protected function layout():void
		{
			_title.x = scaleAndRoundToDpi(8);
			_title.width = actualWidth - _title.x;
			
			_stripe.width = actualWidth * 0.89;
			_stripe.x = (actualWidth - _stripe.width) * 0.5;
			_stripe.y = _title.height - _stripe.height - scaleAndRoundToDpi(2);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Get - Set
		
		protected var _data:Object;
		
		public function get data():Object
		{
			return this._data;
		}
		
		public function set data(value:Object):void
		{
			if(this._data == value)
			{
				return;
			}
			this._data = value;
			this.invalidate(INVALIDATION_FLAG_DATA);
		}
		
		protected var _isSelected:Boolean;
		
		public function get isSelected():Boolean
		{
			return this._isSelected;
		}
		
		public function set isSelected(value:Boolean):void
		{
			if(this._isSelected == value)
			{
				return;
			}
			this._isSelected = value;
			this.invalidate(INVALIDATION_FLAG_SELECTED);
			this.dispatchEventWith(Event.CHANGE);
		}
		
		protected var _groupIndex:int = -1;
		
		public function get groupIndex():int
		{
			return this._groupIndex;
		}
		
		public function set groupIndex(value:int):void
		{
			this._groupIndex = value;
		}
		
		protected var _itemIndex:int = -1;
		
		public function get itemIndex():int
		{
			return this._itemIndex;
		}
		
		public function set itemIndex(value:int):void
		{
			this._itemIndex = value;
		}
		
		protected var _layoutIndex:int = -1;
		
		public function get layoutIndex():int
		{
			return this._layoutIndex;
		}
		
		public function set layoutIndex(value:int):void
		{
			this._layoutIndex = value;
		}
		
		protected var _owner:GroupedList;
		
		public function get owner():GroupedList
		{
			return GroupedList(this._owner);
		}
		
		public function set owner(value:GroupedList):void
		{
			if(this._owner == value)
			{
				return;
			}
			this._owner = value;
			this.invalidate(INVALIDATION_FLAG_DATA);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
		
		override public function dispose():void
		{
			owner = null;
			
			_title.removeFromParent(true);
			_title = null;
			
			_data = null;
			
			super.dispose();
		}
		
		/**
		 * @private
		 */
		protected var _factoryID:String;
		
		/**
		 * @inheritDoc
		 */
		public function get factoryID():String
		{
			return this._factoryID;
		}
		
		/**
		 * @private
		 */
		public function set factoryID(value:String):void
		{
			this._factoryID = value;
		}
		
	}
}