/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 8 oct. 2013
*/
package com.ludofactory.mobile.debug
{
	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.controls.ArrowGroup;
	import com.ludofactory.mobile.core.controls.CustomToggleSwitch;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import feathers.controls.Label;
	import feathers.controls.List;
	import feathers.controls.PickerList;
	import feathers.controls.renderers.IListItemRenderer;
	import feathers.core.FeathersControl;
	import feathers.core.FeathersControl;
	import feathers.core.FeathersControl;
	
	import starling.display.DisplayObject;
	
	import starling.display.Quad;
	import starling.events.Event;
	
	/**
	 * Item renderer used to display the customer service messages.
	 */	
	public class DebugItemRenderer extends FeathersControl implements IListItemRenderer
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
		 * The control to display. */		
		private var _control:DisplayObject;
		
		/**
		 * The background border width. */		
		private var _backgroundBorderWidth:int;
		
		public function DebugItemRenderer()
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
			
			//this.width = GlobalConfig.stageWidth;
			this.height = _itemHeight;
			
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
			
			_backgroundBorder = new Quad(scaleAndRoundToDpi(40), _itemHeight, 0x292929);
			addChild(_backgroundBorder);
			
			_title = new Label();
			addChild(_title);
			_title.textRendererProperties.textFormat = Theme.settingsIRTextFormat;
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
				newWidth = owner.width;
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
					
					_title.text = _(_data.title); // necessary when the language change in the settings
					
					_control = _data.accessory;
					if( _control )
						addChild(_control);
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
			
			if( owner && (owner.dataProvider.data.length - 1) == _index)
			{
				_bottomStripe.visible = true;
				_bottomStripe.y = this.actualHeight - _strokeThickness;
				_bottomStripe.width = this.actualWidth;
			}
			else
			{
				
				_bottomStripe.visible = false;
			}
			
			_title.x = _backgroundBorder.width + _padding;
			_title.width = actualWidth - _backgroundBorder.width - _padding * 2;
			_title.validate();
			_title.y = (_itemHeight - _title.height) * 0.5;
			
			if( _control )
			{
				if( _control is CustomToggleSwitch )
				{
					_control.width = scaleAndRoundToDpi(200);
					if(_control is FeathersControl) FeathersControl(_control).validate();
				}
				else
				{
					//_control.width = (actualWidth - _title.x) * (GlobalConfig.isPhone ? 0.35 : 0.25);
					if( _control is ArrowGroup )
					{
						if(_control is FeathersControl) FeathersControl(_control).validate();
					}
					else if( _control is PickerList )
					{
						if(_control is FeathersControl) FeathersControl(_control).validate();
						_control.width += scaleAndRoundToDpi(20);
					}
					else
					{
						_control.width = scaleAndRoundToDpi(200);
					}
					if(_control is FeathersControl)
						_control.height = actualHeight * 0.75;
				}
				
				_control.x = actualWidth - _control.width - _padding;
				_control.y = (_itemHeight - _control.height) * 0.5;
			}
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
			this._data = Object(value);
			this.invalidate(INVALIDATION_FLAG_DATA);
		}
		
		protected var _index:int = -1;
		
		public function get index():int
		{
			return this._index;
		}
		
		public function set index(value:int):void
		{
			if(this._index == value)
			{
				return;
			}
			this._index = value;
			this.invalidate(INVALIDATION_FLAG_DATA);
		}
		
		protected var _owner:List;
		
		public function get owner():List
		{
			return List(this._owner);
		}
		
		public function set owner(value:List):void
		{
			if(this._owner == value)
			{
				return;
			}
			this._owner = value;
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
		
		protected var _factoryID:String;
		
		public function get factoryID():String
		{
			return this._factoryID;
		}
		
		public function set factoryID(value:String):void
		{
			this._factoryID = value;
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
			
			_leftStripe.removeFromParent(true);
			_leftStripe = null;
			
			_background.removeFromParent(true);
			_background = null;
			
			_backgroundBorder.removeFromParent(true);
			_backgroundBorder = null;
			
			_control = null;
			
			_data = null;
			
			super.dispose();
		}
	}
}