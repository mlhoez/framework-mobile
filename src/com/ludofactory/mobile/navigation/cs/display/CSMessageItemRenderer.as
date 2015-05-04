/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 25 août 2013
*/
package com.ludofactory.mobile.navigation.cs.display
{
	
	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.common.utils.roundUp;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import feathers.controls.List;
	import feathers.controls.renderers.IListItemRenderer;
	import feathers.core.FeathersControl;
	
	import flash.geom.Point;
	
	import starling.display.Quad;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.text.TextField;
	import starling.utils.HAlign;
	import starling.utils.VAlign;
	
	/**
	 * Item renderer used to display the customer service messages.
	 */	
	public class CSMessageItemRenderer extends FeathersControl implements IListItemRenderer
	{
		private static const HELPER_POINT:Point = new Point();
		private static const HELPER_TOUCHES_VECTOR:Vector.<Touch> = new <Touch>[];
		protected var _touchPointID:int = -1;
		
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
		 * Title of the message, it's the name of the choosed theme. */		
		private var _title:TextField;
		/**
		 * A preview (75 chars max) of the last message sent. */		
		private var _message:TextField;
		/**
		 * Date on which the thread was created. */		
		private var _date:TextField;
		
		/**
		 * The top stripe displayed in each item renderer. */		
		private var _topStripe:Quad;
		/**
		 * The bottom stripe only displayed in the last item renderer. */		
		private var _bottomStripe:Quad;
		
		/**
		 * The global padding of the item renderer. */		
		private var _padding:int = 20;
		
		private var _whiteGradient:Quad;
		
		public function CSMessageItemRenderer()
		{
			super();
			this.addEventListener(TouchEvent.TOUCH, touchHandler);
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			_itemHeight = scaleAndRoundToDpi(BASE_HEIGHT);
			_strokeThickness = scaleAndRoundToDpi(BASE_STROKE_THICKNESS);
			_padding *= GlobalConfig.dpiScale;
			
			this.width = GlobalConfig.stageWidth;
			this.height = _itemHeight;
			
			_topStripe = new Quad(50, _strokeThickness, 0xbfbfbf);
			addChild(_topStripe);
			
			_bottomStripe = new Quad(50, _strokeThickness, 0xbfbfbf);
			_bottomStripe.visible = false;
			addChild(_bottomStripe);
			
			_title = new TextField(10, 10, "", Theme.FONT_ARIAL, scaleAndRoundToDpi(GlobalConfig.isPhone ? 28 : 32), Theme.COLOR_ORANGE);
			_title.vAlign = VAlign.TOP;
			_title.hAlign = HAlign.LEFT;
			addChild(_title);
			
			_message = new TextField(10, 10, "", Theme.FONT_ARIAL, scaleAndRoundToDpi(GlobalConfig.isPhone ? 28 : 32), Theme.COLOR_LIGHT_GREY);
			_message.vAlign = VAlign.TOP;
			_message.hAlign = HAlign.LEFT;
			_message.italic = true;
			addChild(_message);
			
			_date = new TextField(10, 10, "", Theme.FONT_ARIAL, scaleAndRoundToDpi(GlobalConfig.isPhone ? 28 : 32), Theme.COLOR_LIGHT_GREY);
			_date.vAlign = VAlign.TOP;
			_date.hAlign = HAlign.RIGHT;
			addChild(_date);
			
			_whiteGradient = new Quad(scaleAndRoundToDpi(100), _itemHeight * 0.5);
			_whiteGradient.setVertexAlpha(0, 0.4);
			_whiteGradient.setVertexAlpha(2, 0.4);
			addChild(_whiteGradient);
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
			_title.width = NaN;
			_title.height = NaN;
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
					_title.visible = _message.visible = _date.visible = true;
					
					_title.text = _(_data.title);
					_message.text = _data.message;
					_date.text = _data.date;
					
					if( _data.read )
					{
						_title.bold = false;
						_message.bold = false;
						_date.bold = false;
					}
					else
					{
						_title.bold = true;
						_message.bold = true;
						_date.bold = true;
					}
				}
				else
				{
					_title.text = _message.text = _date.text = "";
				}
			}
			else
			{
				_title.visible = _message.visible = _date.visible = false;
			}
		}
		
		protected function layout():void
		{
			_topStripe.width = this.actualWidth;
			
			if( this.owner && this.owner.dataProvider && (this.owner.dataProvider.length - 1) == _index )
			{
				_bottomStripe.visible = true;
				_bottomStripe.y = this.actualHeight - _strokeThickness;
				_bottomStripe.width = this.actualWidth;
			}
			else
			{
				_bottomStripe.visible = false;
			}
			
			_title.width = this.actualWidth - _padding;
			_title.height = roundUp(_itemHeight * 0.5);
			_title.x = _padding;
			
			_message.width = this.actualWidth - _padding;
			_message.height = roundUp(_itemHeight * 0.5);
			_message.y = roundUp(_itemHeight * 0.5) - scaleAndRoundToDpi(5);
			_message.x = _padding;
			
			_date.width = this.actualWidth * 0.5;
			_date.height = roundUp(_itemHeight * 0.5);
			_date.x = this.actualWidth - _date.width - _padding;
			
			_whiteGradient.x = actualWidth - _whiteGradient.width - _padding;
			_whiteGradient.y = _itemHeight * 0.5 - _strokeThickness;
		}
		
		protected var _data:CSMessageData;
		
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
			this._data = CSMessageData(value);
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
			if(this._owner)
			{
				this._owner.removeEventListener(Event.SCROLL, owner_scrollHandler);
			}
			this._owner = value;
			if(this._owner)
			{
				this._owner.addEventListener(Event.SCROLL, owner_scrollHandler);
			}
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
		
		protected function touchHandler(event:TouchEvent):void
		{
			if(!this._isEnabled)
			{
				return;
			}
			
			const touches:Vector.<Touch> = event.getTouches(this, null, HELPER_TOUCHES_VECTOR);
			if(touches.length == 0)
			{
				//end of hover
				return;
			}
			if(this._touchPointID >= 0)
			{
				var touch:Touch;
				for each(var currentTouch:Touch in touches)
				{
					if(currentTouch.id == this._touchPointID)
					{
						touch = currentTouch;
						break;
					}
				}
				
				if(!touch)
				{
					//end of hover
					HELPER_TOUCHES_VECTOR.length = 0;
					return;
				}
				
				if(touch.phase == TouchPhase.ENDED)
				{
					this._touchPointID = -1;
					touch.getLocation(this, HELPER_POINT);
					var isInBounds:Boolean = this.hitTest(HELPER_POINT, true) != null;
					if(isInBounds)
					{
						owner.dispatchEventWith(Event.CHANGE, false, _data);
					}
				}
			}
			else //if we get here, we don't have a saved touch ID yet
			{
				for each(touch in touches)
				{
					if(touch.phase == TouchPhase.BEGAN)
					{
						this._touchPointID = touch.id;
						break;
					}
				}
			}
			HELPER_TOUCHES_VECTOR.length = 0;
		}
		
		protected function owner_scrollHandler(event:Event):void
		{
			this._touchPointID = -1;
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
		
		override public function dispose():void
		{
			removeEventListener(TouchEvent.TOUCH, touchHandler);
			
			if( this._owner )
				this._owner.removeEventListener(Event.SCROLL, owner_scrollHandler);
			
			_title.removeFromParent(true);
			_title = null;
			
			_date.removeFromParent(true);
			_date = null;
			
			_message.removeFromParent(true);
			_message = null;
			
			_topStripe.removeFromParent(true);
			_topStripe = null;
			
			_bottomStripe.removeFromParent(true);
			_bottomStripe = null;
			
			_whiteGradient.removeFromParent(true);
			_whiteGradient = null;
			
			_data = null;
			
			super.dispose();
		}
	}
}