/*
Copyright © 2006-2014 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 17 sept. 2013
*/
package com.ludofactory.mobile.navigation.account.history.account
{
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import feathers.controls.GroupedList;
	import feathers.controls.Label;
	import feathers.controls.renderers.IGroupedListItemRenderer;
	import feathers.core.FeathersControl;
	
	import starling.display.Quad;
	import starling.events.Event;
	
	/**
	 * Item renderer used to display the customer service messages.
	 */	
	public class AccountHistoryItemRenderer extends FeathersControl implements IGroupedListItemRenderer
	{
		/**
		 * The base height of a line in the list. */		
		private static const BASE_HEIGHT:int = 80;
		/**
		 * The scaled item height. */		
		private var _itemHeight:Number;
		
		/**
		 * The base stroke thickness. */		
		private static const BASE_STROKE_THICKNESS:int = 2;
		/**
		 * The scaled stroke thickness. */		
		private var _strokeThickness:Number;
		
		/**
		 * Name of the trophy. */		
		private var _title:Label;
		
		/**
		 * The top stripe displayed in each item renderer. */		
		private var _topStripe:Quad;
		/**
		 * The bottom stripe only displayed in the last item renderer. */		
		private var _bottomStripe:Quad;
		/**
		 * The left stripe. */		
		private var _leftStripe:Quad;
		
		/**
		 * The background. */		
		private var _background:Quad;
		
		/**
		 * The background black border. */		
		private var _backgroundBorder:Quad;
		
		/**
		 * The global padding of the item renderer. */		
		private var _padding:int = 10;
		
		/**
		 * The background border width. */		
		private var _backgroundBorderWidth:int;
		
		/**
		 * The shadow. */		
		private var _shadow:Quad;
		
		public function AccountHistoryItemRenderer()
		{
			super();
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			_itemHeight = scaleAndRoundToDpi(BASE_HEIGHT);
			_strokeThickness = scaleAndRoundToDpi(BASE_STROKE_THICKNESS);
			_padding *= GlobalConfig.dpiScale;
			_backgroundBorderWidth = scaleAndRoundToDpi(40);
			
			this.width = GlobalConfig.stageWidth;
			//this.height = _itemHeight;
			
			_background = new Quad(this.width - _backgroundBorderWidth, _itemHeight, 0xf7f7f7);
			_background.x = _backgroundBorderWidth;
			addChild(_background);
			
			_leftStripe = new Quad(_strokeThickness, _itemHeight, 0xbfbfbf);
			_leftStripe.x = _backgroundBorderWidth;
			addChild(_leftStripe);
			
			_topStripe = new Quad(50, _strokeThickness, 0xbfbfbf);
			addChild(_topStripe);
			
			_bottomStripe = new Quad(50, _strokeThickness, 0xbfbfbf);
			_bottomStripe.visible = false;
			addChild(_bottomStripe);
			
			_backgroundBorder = new Quad(_backgroundBorderWidth, _itemHeight, 0x292929);
			addChild(_backgroundBorder);
			
			_shadow = new Quad(50, scaleAndRoundToDpi(12), 0x000000);
			_shadow.setVertexAlpha(0, 0.3);
			_shadow.setVertexAlpha(1, 0.3);
			_shadow.setVertexColor(2, 0xffffff);
			_shadow.setVertexAlpha(2, 0);
			_shadow.setVertexColor(3, 0xffffff);
			_shadow.setVertexAlpha(3, 0);
			addChild(_shadow);
			
			_title = new Label();
			addChild(_title);
			_title.textRendererProperties.textFormat = Theme.accoutHistoryIRTitleTextFormat;
		}
		
		override protected function draw():void
		{
			const dataInvalid:Boolean = this.isInvalid(INVALIDATION_FLAG_DATA);
			const selectionInvalid:Boolean = this.isInvalid(INVALIDATION_FLAG_SELECTED);
			var sizeInvalid:Boolean = this.isInvalid(INVALIDATION_FLAG_SIZE);
			
			if(dataInvalid)
			{
				this.commitData();
			}
			
			sizeInvalid = this.autoSizeIfNeeded() || sizeInvalid;
			
			if(dataInvalid || sizeInvalid || dataInvalid)
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
			_title.width = NaN;
			_title.height = NaN;
			_title.validate();
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
			if(this._owner)
			{
				if( _data )
				{
					_title.visible = true;
					
					_title.text = _data.date + " - " + _data.text;
					
					_background.color = ((_itemIndex % 2) == 0) ? 0xf7f7f7 : 0xffffff;
				}
				else
				{
					_title.text = "";
				}
			}
			else
			{
				_title.visible = false;
			}
		}
		
		protected function layout():void
		{
			_topStripe.width = this.actualWidth;
			
			
			if( owner && _itemIndex == 0 )
			{
				_shadow.visible = true;
				_shadow.width = this.actualWidth;
			}
			else
			{
				_shadow.visible = false;
			}
			
			if( _groupIndex >= 0 && _itemIndex >= 0 && owner/* && owner.dataProvider && (owner.dataProvider.data.length - 1) == _groupIndex*/ && (owner.dataProvider.data[_groupIndex].children.length - 1) == _itemIndex)
			{
				_bottomStripe.visible = true;
				_bottomStripe.width = this.actualWidth;
			}
			else
			{
				
				_bottomStripe.visible = false;
			}
			
			_shadow.width = this.actualWidth;
			
			_title.x = _backgroundBorder.width + _padding;
			_title.width = this.actualWidth - _backgroundBorder.width - _padding * 2;
			_title.validate();
			
			_background.height = _backgroundBorder.height = _leftStripe.height = Math.max(_itemHeight, (_title.height + scaleAndRoundToDpi(20)));
			
			_title.y = (_background.height - _title.height) * 0.5;
			_bottomStripe.y = this.actualHeight - _strokeThickness;
			
			setSize( actualWidth, _background.height );
		}
		
		protected var _data:AccountHistoryData;
		
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
			this._data = AccountHistoryData(value);
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
//------------------------------------------------------------------------------------------------------------
		
		override public function dispose():void
		{
			owner = null;
			
			_title.removeFromParent(true);
			_title = null;
			
			_topStripe.removeFromParent(true);
			_topStripe = null;
			
			_bottomStripe.removeFromParent(true);
			_bottomStripe = null;
			
			_background.removeFromParent(true);
			_background = null;
			
			_shadow.removeFromParent(true);
			_shadow = null;
			
			_data = null;
			
			super.dispose();
		}
	}
}