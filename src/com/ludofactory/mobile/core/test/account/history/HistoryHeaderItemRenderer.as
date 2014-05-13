/*
Copyright © 2006-2014 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 17 sept. 2013
*/
package com.ludofactory.mobile.core.test.account.history
{
	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.common.utils.Utilities;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.test.config.GlobalConfig;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import feathers.controls.GroupedList;
	import feathers.controls.Label;
	import feathers.controls.renderers.IGroupedListHeaderOrFooterRenderer;
	import feathers.core.FeathersControl;
	
	import starling.display.Quad;
	import starling.events.Event;
	import starling.utils.formatString;
	
	/**
	 * Item renderer used to display the customer service messages.
	 */	
	public class HistoryHeaderItemRenderer extends FeathersControl implements IGroupedListHeaderOrFooterRenderer
	{
		/**
		 * The base height of a line in the list. */		
		private static const BASE_HEIGHT:int = 60;
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
		 * The background. */		
		private var _background:Quad;
		
		/**
		 * The global padding of the item renderer. */		
		private var _padding:int = 10;
		
		public function HistoryHeaderItemRenderer()
		{
			super();
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			_itemHeight = scaleAndRoundToDpi(BASE_HEIGHT);
			_strokeThickness = scaleAndRoundToDpi(BASE_STROKE_THICKNESS);
			_padding *= GlobalConfig.dpiScale;
			
			this.width = GlobalConfig.stageWidth;
			this.height = _itemHeight;
			
			_background = new Quad(this.width, _itemHeight, 0xff5800);
			addChild(_background);
			
			_topStripe = new Quad(this.width, _strokeThickness, 0xffffff);
			addChild(_topStripe);
			
			_bottomStripe = new Quad(this.width, _strokeThickness, 0xffffff);
			_bottomStripe.y = _background.height - _strokeThickness;
			addChild(_bottomStripe);
			
			_title = new Label();
			addChild(_title);
			_title.textRendererProperties.textFormat = Theme.historyIRTitleTextFormat;
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
					
					_title.text = Utilities.isToday(String(_data)) ? _("Historique du jour") : formatString(_("Historique du {0}"), String(_data));
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
			_title.x = _padding;
			_title.width = this.actualWidth - _padding * 2;
			_title.validate();
			_title.y = (_itemHeight - _title.height) * 0.5;
		}
		
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
			
			_data = null;
			
			super.dispose();
		}
	}
}