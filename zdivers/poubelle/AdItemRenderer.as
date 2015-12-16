/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 25 juil. 2013
*/
package com.ludofactory.mobile.application.ads
{
	import com.ludofactory.mobile.core.theme.Theme;
	import com.ludofactory.common.utils.logs.log;
	import com.ludofactory.common.utils.scaleToDpi;
	
	import flash.geom.Point;
	
	import app.AppEntryPoint;
	import com.ludofactory.mobile.application.config.GlobalConfig;
	
	import feathers.controls.Button;
	import feathers.controls.ImageLoader;
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
	
	public class AdItemRenderer extends FeathersControl implements IListItemRenderer
	{
		private const BASE_HEIGHT:int = 200;
		private const BASE_STROKE_THICKNESS:int = 3;
		
		private static const HELPER_POINT:Point = new Point();
		private static const HELPER_TOUCHES_VECTOR:Vector.<Touch> = new <Touch>[];
		protected var _touchPointID:int = -1;
		
		protected var _paddingTop:int;
		protected var _paddingRight:int;
		protected var _paddingBottom:int;
		protected var _paddingLeft:int;
		
		/**
		 * Background stroke */		
		private var _stroke:Quad;
		/**
		 * Background gradient */		
		private var _gradient:Quad;
		
		/**
		 * The title */		
		private var _title:Label;
		
		/**
		 * The button */		
		private var _adButton:Button;
		
		/**
		 * Highlight ad */		
		protected var _highlighAd:Image;
		
		/**
		 * Ad icon */		
		protected var _icon:ImageLoader;
		
		private var _strokeThickness:Number;
		private var _itemHeight:Number;
		
		public function AdItemRenderer()
		{
			super();
			this.addEventListener(TouchEvent.TOUCH, touchHandler);
		}
		
		override protected function initialize():void
		{
			_strokeThickness = scaleToDpi(BASE_STROKE_THICKNESS);
			_itemHeight = scaleToDpi(BASE_HEIGHT);
			
			_paddingBottom = _paddingTop = _paddingLeft = _paddingRight = scaleToDpi(20);
			
			// TODO Faire un quad batch à la place ?
			if(!_stroke && !_gradient)
			{
				_stroke = new Quad(5, _itemHeight, 0xffffff);
				addChild(_stroke);
				
				_gradient = new Quad(5, _itemHeight - (_strokeThickness * 2), 0x0000ff);
				_gradient.setVertexColor(0, 0x43dfff);
				_gradient.setVertexColor(1, 0x43dfff);
				_gradient.setVertexColor(2, 0x02bbff);
				_gradient.setVertexColor(3, 0x02bbff);
				addChild(_gradient);
			}
			
			if(!_highlighAd)
			{
				_highlighAd = new Image(AbstractEntryPoint.assets.getTexture("HighlighAd"));
				_highlighAd.scaleX = _highlighAd.scaleY = GlobalConfig.dpiScalez;
				addChild(_highlighAd);
			}
			
			if(!this._title)
			{
				this._title = new Label();
				this.addChild(this._title);
			}
			
			if(!_adButton)
			{
				_adButton = new Button();
				_adButton.nameList.add(Theme.BUTTON_AD);
				addChild(_adButton);
			}
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
			this._title.width = NaN;
			this._title.height = NaN;
			this._title.validate();
			var newWidth:Number = this.explicitWidth;
			if(needsWidth)
			{
				newWidth = this._title.width;
				newWidth += this._paddingLeft + this._paddingRight;
			}
			var newHeight:Number = this.explicitHeight;
			if(needsHeight)
			{
				newHeight = this._title.height;
			}
			return this.setSizeInternal(newWidth, newHeight, false);
		}
		
		protected function commitData():void
		{
			if(this._owner)
			{
				_adButton.visible = _stroke.visible = _gradient.visible = _highlighAd.visible = true;
				
				if(this._data)
				{
					_title.text = _data.title;
					_adButton.label = _data.buttonLabel;
					
					if(_icon)
						_icon.removeFromParent(true);
					_icon = new ImageLoader();
					_icon.source = AbstractEntryPoint.assets.getTexture(_data.imageName);
					_icon.textureScale = GlobalConfig.dpiScalez;
					addChild(_icon);
				}
				else
				{
					this._title.text = "";
				}
			}
			else
			{
				_title.text = null;
				_adButton.visible = _stroke.visible = _gradient.visible = _highlighAd.visible = false;
			}
		}
		
		protected function layout():void
		{
			this.width = this.owner.width;
			this.height = this.owner.height;
			
			_stroke.width = this.actualWidth;
			_gradient.width = this.actualWidth - (_strokeThickness * 2);
			_gradient.y = _strokeThickness;
			_gradient.x = _strokeThickness;
			
			_highlighAd.width = this.actualWidth;
			_highlighAd.x = _strokeThickness;
			_highlighAd.y = _strokeThickness;
			
			_adButton.validate();
			_adButton.x = this.actualWidth - _adButton.width;
			_adButton.y = this.actualHeight - _adButton.height - scaleToDpi(40);
			
			_title.width = this.actualWidth * 0.5 - _paddingRight;
			_title.x = this.actualWidth - _title.width - _paddingRight;
			_title.validate();
			_title.y = (_adButton.y - _title.height) * 0.5;
			
			_icon.validate();
			_icon.x = (this.actualWidth - _icon.width) * 0.15;
			_icon.y = (this.actualHeight - _icon.height) * 0.5;
		}
		
		protected var _data:AdData;
		
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
			this._data = AdData(value);
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
			/*if(this._owner && this._owner.dataProvider)
			{
				this.isLastItem = this._index == this._owner.dataProvider.length - 1;
			}*/
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
						/*if(!this._isSelected && !this._data.isDepartingFromHere)
						{
							this.isSelected = true;
						}*/
						log("touché !!");
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
		
		override public function dispose():void
		{
			this.removeEventListener(TouchEvent.TOUCH, touchHandler);
			
			_stroke.removeFromParent(true);
			_stroke = null;
			
			_gradient.removeFromParent(true);
			_gradient = null;
			
			_title.removeFromParent(true);
			_title = null;
			
			_adButton.removeFromParent(true);
			_adButton = null;
			
			_highlighAd.removeFromParent(true);
			_highlighAd = null;
			
			_icon.removeFromParent(true);
			_icon = null;
			
			_data = null;
			
			if( this._owner )
				this._owner.removeEventListener(Event.SCROLL, owner_scrollHandler);
			
			super.dispose();
		}
	}
}