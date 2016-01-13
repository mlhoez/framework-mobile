/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 17 sept. 2013
*/
package com.ludofactory.mobile.core.avatar.maker.sections
{
	
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	
	import feathers.controls.GroupedList;
	import feathers.controls.List;
	import feathers.controls.renderers.IGroupedListItemRenderer;
	import feathers.core.FeathersControl;
	import feathers.data.ListCollection;
	import feathers.layout.FlowLayout;
	
	import starling.display.Quad;
	
	import starling.events.Event;
	
	/**
	 * Item renderer used to display the customer service messages.
	 */	
	public class CategoryItemRenderer extends FeathersControl implements IGroupedListItemRenderer
	{
		/**
		 * The base height of a line in the list. */		
		private static const BASE_HEIGHT:int = 20;
		/**
		 * The scaled item height. */		
		private var _itemHeight:Number;
		
		/**
		 * The base stroke thickness. */		
		private static const BASE_STROKE_THICKNESS:int = 2;
		/**
		 * The scaled stroke thickness. */		
		private var _strokeThickness:Number;
		
		private var _list:List;
		
		public function CategoryItemRenderer()
		{
			super();
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			_itemHeight = scaleAndRoundToDpi(BASE_HEIGHT);
			_strokeThickness = scaleAndRoundToDpi(BASE_STROKE_THICKNESS);
			
			var listLayout:FlowLayout = new FlowLayout();
			listLayout.horizontalAlign = FlowLayout.HORIZONTAL_ALIGN_CENTER;
			listLayout.rowVerticalAlign = FlowLayout.HORIZONTAL_ALIGN_CENTER;
			listLayout.horizontalGap = scaleAndRoundToDpi(6);
			listLayout.verticalGap = scaleAndRoundToDpi(6);
			
			_list = new List();
			_list.layout = listLayout;
			_list.itemRendererType = SectionItemRenderer;
			addChild(_list);
		}
		
		override protected function draw():void
		{
			const dataInvalid:Boolean = this.isInvalid(INVALIDATION_FLAG_DATA);
			var sizeInvalid:Boolean = this.isInvalid(INVALIDATION_FLAG_SIZE);
			
			if(dataInvalid)
			{
				this.commitData();
			}
			
			if(dataInvalid || sizeInvalid)
			{
				this.layout();
			}
		}
		
		protected function commitData():void
		{
			if(this._owner)
			{
				if( _data )
				{
					_list.dataProvider = new ListCollection(_data);
					_list.validate();
				}
			}
		}
		
		protected function layout():void
		{
			_list.y = scaleAndRoundToDpi(10);
			_list.width = this.actualWidth;
			_list.validate();
			
			setSize(actualWidth, (_list.y + _list.height));
		}
		
		/**
		 * Data is an array of SectionData items used to build the sublist
		 */
		protected var _data:Vector.<SectionData>;
		
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
			this._data = value as Vector.<SectionData>;
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