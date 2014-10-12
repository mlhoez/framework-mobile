/*
Copyright © 2006-2014 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 2 septembre 2013
*/
package com.ludofactory.mobile.core.navigation.faq
{
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import flash.geom.Point;
	
	import feathers.controls.Label;
	import feathers.controls.List;
	import feathers.controls.renderers.IListItemRenderer;
	import feathers.core.FeathersControl;
	
	import starling.display.Image;
	import starling.display.Quad;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	
	/**
	 * Item renderer used to display the customer service messages.
	 */	
	public class FaqItemRenderer extends FeathersControl implements IListItemRenderer
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
		 * The arrow used to indicate the the user can touch the renderer. */		
		private var _arrow:Image;
		
		public function FaqItemRenderer()
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
			_backgroundBorderWidth = scaleAndRoundToDpi(40);
			
			this.width = GlobalConfig.stageWidth;
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
			_title.textRendererProperties.textFormat = Theme.faqIRTextFormat;
			
			_arrow = new Image(AbstractEntryPoint.assets.getTexture("arrow-right-dark"));
			_arrow.scaleX = _arrow.scaleY = GlobalConfig.dpiScale;
			addChild(_arrow);
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
					
					_title.text = _data.question;
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
			
			_title.x = _backgroundBorder.width + _padding;
			_title.width = actualWidth - _backgroundBorder.width - _padding * 2 - _arrow.width;
			_title.validate();
			
			_arrow.x = actualWidth - _arrow.width - _padding;
			_title.validate();
			
			if( (_title.y + _title.height) > actualHeight )
			{
				_leftStripe.height = _background.height = _backgroundBorder.height = _title.height + _padding * 2;
				setSize(actualWidth, _leftStripe.height);
			}
			
			_title.y = (_leftStripe.height - _title.height) * 0.5;
			_arrow.y = (_leftStripe.height - _arrow.height) * 0.5;
		}
		
		protected var _data:FaqQuestionAnswerData;
		
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
			this._data = FaqQuestionAnswerData(value);
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
					if(isInBounds && owner)
					{
						owner.dispatchEventWith(Event.OPEN, false, _data);
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
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
//------------------------------------------------------------------------------------------------------------
		
		override public function dispose():void
		{
			this.removeEventListener(TouchEvent.TOUCH, touchHandler);
			
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