/*
Copyright © 2006-2014 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 22 Août 2013
*/
package com.ludofactory.mobile.core.shop.vip
{
	import com.greensock.TweenMax;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.events.LudoEventType;
	import com.ludofactory.mobile.core.test.config.GlobalConfig;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import flash.geom.Point;
	
	import feathers.controls.ImageLoader;
	import feathers.controls.Label;
	import feathers.controls.List;
	import feathers.controls.renderers.IListItemRenderer;
	import feathers.core.FeathersControl;
	import feathers.events.FeathersEventType;
	
	import starling.core.Starling;
	import starling.display.MovieClip;
	import starling.display.Quad;
	import starling.display.QuadBatch;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	
	public class BoutiqueCategoryItemRenderer extends FeathersControl implements IListItemRenderer
	{
		private static const HELPER_POINT:Point = new Point();
		private static const HELPER_TOUCHES_VECTOR:Vector.<Touch> = new <Touch>[];
		protected var _touchPointID:int = -1;
		
		/**
		 * The title stripe */		
		private var _stripe:Quad;
		
		/**
		 * The title */		
		private var _title:Label;
		
		/**
		 * The icon */		
		private var _icon:ImageLoader;
		
		/**
		 * The border */		
		private var _borderBatch:QuadBatch;
		
		/**
		 * Loader used while the image is loading. */		
		private var _imageLoader:MovieClip;
		
		public function BoutiqueCategoryItemRenderer()
		{
			super();
			this.addEventListener(TouchEvent.TOUCH, touchHandler);
		}
		
		override protected function initialize():void
		{
			_stripe = new Quad(50, scaleAndRoundToDpi(45), 0xffffff);
			addChild(_stripe);
			
			_title = new Label();
			addChild(_title);
			_title.textRendererProperties.textFormat = Theme.boutiqueCategoryIRTitleTextFormat;
			
			_imageLoader = new MovieClip( AbstractEntryPoint.assets.getTextures("MiniLoader") );
			_imageLoader.scaleX = _imageLoader.scaleY = GlobalConfig.dpiScale;
			addChild(_imageLoader);
			Starling.juggler.add(_imageLoader);
			
			_icon = new ImageLoader();
			_icon.addEventListener(Event.COMPLETE, onImageLoaded);
			_icon.addEventListener(FeathersEventType.ERROR, onImageError);
			addChild(_icon);
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
				if(this._data)
				{
					_title.text = _data.title;
					
					if( _icon )
						_icon.visible = true;
					
					
					_imageLoader.visible = _data.imageNameOrUrl.indexOf("http") == -1 ? false : true;
					_icon.source = _data.imageNameOrUrl.indexOf("http") == -1 ? AbstractEntryPoint.assets.getTexture(_data.imageNameOrUrl) : _data.imageNameOrUrl;
				}
				else
				{
					this._title.text = "";
					_icon.visible = false;
				}
			}
			else
			{
				_title.text = null;
				_icon.visible = false;
			}
		}
		
		protected function layout():void
		{
			this.width = _stripe.width = _title.width = this.owner.width / 3;
			this.height = this.owner.height / 3;
			
			_stripe.y = this.actualHeight - _stripe.height;
			_title.validate();
			_title.y = _stripe.y + (_stripe.height - _title.height) * 0.5;
			
			_icon.height = _stripe.y * 0.6;
			_icon.validate();
			_icon.alignPivot();
			_icon.x = this.actualWidth * 0.5;
			_icon.y = _stripe.y * 0.5;
			
			if( _imageLoader )
			{
				_imageLoader.x = (actualWidth * 0.5) - (_imageLoader.width * 0.5);
				_imageLoader.y = (actualHeight * 0.5) - (_imageLoader.height * 0.5);
			}
			
			if( !_borderBatch )
			{
				_borderBatch = new QuadBatch();
				var quad:Quad = new Quad(scaleAndRoundToDpi(2), this.actualHeight, 0xe6e6e6);
				_borderBatch.addQuad(quad);
				quad.x = this.actualWidth - quad.width;
				_borderBatch.addQuad(quad);
				quad.height = quad.width * 2;
				quad.width = this.actualWidth;
				quad.x = 0;
				quad.y = this.actualHeight - quad.height;
				_borderBatch.addQuad(quad);
				addChild(_borderBatch);
				quad = null;
			}
		}
		
		protected var _data:BoutiqueCategoryData;
		
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
			this._data = BoutiqueCategoryData(value);
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
					if(isInBounds)
					{
						owner.dispatchEventWith(LudoEventType.BOUTIQUE_CATEGORY_TOUCHED, false, _data);
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
		
		
		/**
		 * When the image have correctly been loaded.
		 */		
		protected function onImageLoaded(event:Event):void
		{
			Starling.juggler.remove(_imageLoader);
			_imageLoader.removeFromParent(true);
			_imageLoader = null;
			
			_icon.alpha = 0;
			TweenMax.to(_icon, 0.75, {alpha:1});
			invalidate(INVALIDATION_FLAG_SIZE);
		}
		
		/**
		 * When the image could not be loaded.
		 */		
		protected function onImageError(event:Event):void
		{
			// FIXME Logguer l'erreur pour pouvoir corriger l'url si besoin.
			this.invalidate(INVALIDATION_FLAG_SIZE);
		}
		
		
		
		override public function dispose():void
		{
			this.removeEventListener(TouchEvent.TOUCH, touchHandler);
			
			_stripe.removeFromParent(true);
			_stripe = null;
			
			_title.removeFromParent(true);
			_title = null;
			
			_icon.removeFromParent(true);
			_icon = null;
			
			_borderBatch.reset();
			_borderBatch.removeFromParent(true);
			_borderBatch = null;
			
			if( _icon )
			{
				_icon.removeEventListener(Event.COMPLETE, onImageLoaded);
				_icon.removeEventListener(FeathersEventType.ERROR, onImageError);
				_icon.removeFromParent(true);
				_icon = null;
			}
			
			if( _imageLoader )
			{
				Starling.juggler.remove(_imageLoader);
				_imageLoader.removeFromParent(true);
				_imageLoader = null;
			}
			
			_data = null;
			
			super.dispose();
		}
	}
}