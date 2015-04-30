/*
Copyright © 2006-2015 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 22 Août 2013
*/
package com.ludofactory.mobile.navigation.shop.vip
{
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.AbstractGameInfo;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import flash.geom.Point;
	
	import feathers.controls.ImageLoader;
	import feathers.controls.Label;
	import feathers.controls.List;
	import feathers.controls.renderers.IListItemRenderer;
	import feathers.core.FeathersControl;
	import feathers.events.FeathersEventType;
	
	import starling.animation.Transitions;
	import starling.animation.Tween;
	import starling.core.Starling;
	import starling.display.MovieClip;
	import starling.display.Quad;
	import starling.display.QuadBatch;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	
	public class BoutiqueItemRenderer extends FeathersControl implements IListItemRenderer
	{
		private static const HELPER_POINT:Point = new Point();
		private static const HELPER_TOUCHES_VECTOR:Vector.<Touch> = new <Touch>[];
		protected var touchPointID:int = -1;
		
		/**
		 * The gift image. */		
		protected var _image:ImageLoader;
		
		/**
		 * Loader used while the image is loading. */		
		private var _imageLoader:MovieClip;
		
		/**
		 * The gift fade tween. */		
		protected var _fadeTween:Tween;
		
		/**
		 * The title */		
		private var _title:Label;
		
		/**
		 * The title stripe */		
		private var _stripe:Quad;
		
		/**
		 * The border */		
		private var _borderBatch:QuadBatch;
		
		/**
		 * Determine if the elements have been positioned yet */		
		private var _elementsPositioned:Boolean = false;
		
		public function BoutiqueItemRenderer()
		{
			this.isQuickHitAreaEnabled = true;
			this.addEventListener(TouchEvent.TOUCH, touchHandler);
			this.addEventListener(Event.REMOVED_FROM_STAGE, removedFromStageHandler)
		}
		
		override protected function initialize():void
		{
			_stripe = new Quad(50, scaleAndRoundToDpi(45), 0xffffff);
			addChild(_stripe);
			
			this._image = new ImageLoader();
			this._image.addEventListener(Event.COMPLETE, onImageLoader);
			this._image.addEventListener(FeathersEventType.ERROR, onImageError);
			this.addChild(this._image);
			
			_imageLoader = new MovieClip( Theme.blackLoaderTextures );
			_imageLoader.scaleX = _imageLoader.scaleY = GlobalConfig.dpiScale;
			_imageLoader.alignPivot();
			addChild(_imageLoader);
			Starling.juggler.add(_imageLoader);
			
			_title = new Label();
			addChild(_title);
			_title.textRendererProperties.textFormat = Theme.boutiqueItemIRTextFormat;
		}
		
		override protected function draw():void
		{
			const dataInvalid:Boolean = this.isInvalid(INVALIDATION_FLAG_DATA);
			const selectionInvalid:Boolean = this.isInvalid(INVALIDATION_FLAG_SELECTED);
			var sizeInvalid:Boolean = this.isInvalid(INVALIDATION_FLAG_SIZE);
			
			if(dataInvalid)
			{
				if(this._fadeTween)
				{
					this._fadeTween.advanceTime(Number.MAX_VALUE);
				}
				if(this._data)
				{
					_imageLoader.visible = true;
					if( _borderBatch )
						_borderBatch.visible = true;
					_stripe.visible = true;
					_title.visible = true;
					
					_image.visible = false;
					_image.source = this._data.imageUrl;
					
					_title.text = _data.points;
				}
				else
				{
					if( _borderBatch )
						_borderBatch.visible = false;
					_stripe.visible = false;
					_title.visible = false;
					_imageLoader.visible = false;
					_image.source = null;
				}
			}
			
			sizeInvalid = this.autoSizeIfNeeded() || sizeInvalid;
			
			if(sizeInvalid)
			{
				layout();
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
		
		private function layout():void
		{
			if( !_elementsPositioned )
			{
				this.width = _stripe.width = _title.width = this.owner.width / (AbstractGameInfo.LANDSCAPE ? 4 : 3);
				this.height = this.owner.height / (AbstractGameInfo.LANDSCAPE ? 2 : 3);
				
				_stripe.y = this.actualHeight - _stripe.height;
				_title.validate();
				_title.y = _stripe.y + (_stripe.height - _title.height) * 0.5;
				
				_imageLoader.x = this.actualWidth * 0.5;
				_imageLoader.y = _stripe.y * 0.5;
				
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
				
				_image.width = this.actualWidth;
				_image.height = _stripe.y;
				
				_elementsPositioned = true;
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Handlers
//------------------------------------------------------------------------------------------------------------
		
		protected function touchHandler(event:TouchEvent):void
		{
			const touches:Vector.<Touch> = event.getTouches(this, null, HELPER_TOUCHES_VECTOR);
			if(touches.length == 0)
			{
				return;
			}
			if(this.touchPointID >= 0)
			{
				var touch:Touch;
				for each(var currentTouch:Touch in touches)
				{
					if(currentTouch.id == this.touchPointID)
					{
						touch = currentTouch;
						break;
					}
				}
				if(!touch)
				{
					HELPER_TOUCHES_VECTOR.length = 0;
					return;
				}
				if(touch.phase == TouchPhase.ENDED)
				{
					this.touchPointID = -1;
					
					touch.getLocation(this, HELPER_POINT);
					if(this.hitTest(HELPER_POINT, true) != null && !this._isSelected)
					{
						//this.isSelected = true;
						owner.dispatchEventWith(Event.CHANGE, false, _data);
					}
				}
			}
			else
			{
				for each(touch in touches)
				{
					if(touch.phase == TouchPhase.BEGAN)
					{
						this.touchPointID = touch.id;
						break;
					}
				}
			}
			HELPER_TOUCHES_VECTOR.length = 0;
		}
		
		/**
		 * @private
		 */
		protected function owner_scrollHandler(event:Event):void
		{
			this.touchPointID = -1;
		}
		
		protected function removedFromStageHandler(event:Event):void
		{
			this.touchPointID = -1;
		}
		
		/**
		 * When the image fade is complete.
		 */		
		protected function onFadeComplete():void
		{
			Starling.juggler.remove(_fadeTween);
			_fadeTween = null;
		}
		
		/**
		 * When the image is loaded
		 */		
		protected function onImageLoader(event:Event):void
		{
			_imageLoader.visible = false;
			
			_image.alpha = 0;
			_image.visible = true;
			_fadeTween = new Tween(_image, 0.25, Transitions.EASE_OUT);
			_fadeTween.fadeTo(1);
			_fadeTween.onComplete = onFadeComplete;
			Starling.juggler.add(_fadeTween);
			//invalidate(INVALIDATION_FLAG_SIZE);
		}
		
		/**
		 * When the image could not be loaded.
		 */		
		protected function onImageError(event:Event):void
		{
			// FIXME Logguer l'erreur pour pouvoir corriger l'url si besoin.
			//invalidate(INVALIDATION_FLAG_SIZE);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Get - Set
//------------------------------------------------------------------------------------------------------------
		
		private var _index:int = -1;
		
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
		
		private var _data:BoutiqueItemData;
		
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
			this.touchPointID = -1;
			this._data = BoutiqueItemData(value);
			this.invalidate(INVALIDATION_FLAG_DATA);
		}
		
		private var _isSelected:Boolean;
		
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
			this.dispatchEventWith(Event.CHANGE);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
//------------------------------------------------------------------------------------------------------------
		
		override public function dispose():void
		{
			if( _owner )
				_owner.removeEventListener(Event.SCROLL, owner_scrollHandler);
			
			removeEventListener(TouchEvent.TOUCH, touchHandler);
			removeEventListener(Event.REMOVED_FROM_STAGE, removedFromStageHandler);
			
			_title.removeFromParent(true);
			_title = null;
			
			_borderBatch.reset();
			_borderBatch.removeFromParent(true);
			_borderBatch = null;
			
			_stripe.removeFromParent(true);
			_stripe = null;
			
			_image.removeEventListener(Event.COMPLETE, onImageLoader);
			_image.removeEventListener(FeathersEventType.ERROR, onImageError);
			_image.removeFromParent(true);
			_image = null;
			
			if( _fadeTween )
			{
				Starling.juggler.remove(_fadeTween);
				_fadeTween = null;
			}
			
			Starling.juggler.remove(_imageLoader);
			_imageLoader.removeFromParent(true);
			_imageLoader = null;
			
			super.dispose();
		}
	}
}