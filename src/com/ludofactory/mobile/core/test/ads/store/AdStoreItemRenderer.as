/*
LudoFactory
Framework mobile
Author  : Maxime Lhoez
Created : 25 nov. 2013
*/
package com.ludofactory.mobile.core.test.ads.store
{
	import com.gamua.flox.Flox;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	
	import flash.geom.Point;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.text.TextFormat;
	
	import feathers.controls.ImageLoader;
	import feathers.controls.List;
	import feathers.controls.renderers.IListItemRenderer;
	import feathers.core.FeathersControl;
	
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	
	public class AdStoreItemRenderer extends FeathersControl implements IListItemRenderer
	{
		private static const HELPER_POINT:Point = new Point();
		private static const HELPER_TOUCHES_VECTOR:Vector.<Touch> = new <Touch>[];
		protected var _touchPointID:int = -1;
		
		private const BASE_HEIGHT:int = 200;
		private var _itemHeight:Number;
		
		/**
		 * Ad icon */		
		protected var _giftImage:ImageLoader;
		
		public function AdStoreItemRenderer()
		{
			super();
			this.addEventListener(TouchEvent.TOUCH, touchHandler);
		}
		
		override protected function initialize():void
		{
			_itemHeight = scaleAndRoundToDpi(BASE_HEIGHT);
			
			_giftImage = new ImageLoader();
			//_giftImage.scaleX = _giftImage.scaleY = GlobalConfig.dpiScalez;
			_giftImage.snapToPixels = true;
			//_giftImage.addEventListener(Event.COMPLETE, onImageLoader);
			//_giftImage.maintainAspectRatio = false;
			addChild(_giftImage);
		}
		
		/**
		 * When the image is loaded
		 */		
		/*protected function onImageLoader(event:Event):void
		{
			invalidate(INVALIDATION_FLAG_SIZE);
		}*/
		
		override protected function draw():void
		{
			const dataInvalid:Boolean = this.isInvalid(INVALIDATION_FLAG_DATA);
			const selectionInvalid:Boolean = this.isInvalid(INVALIDATION_FLAG_SELECTED);
			var sizeInvalid:Boolean = this.isInvalid(INVALIDATION_FLAG_SIZE);
			
			if(dataInvalid)
			{
				this.commitData();
			}
			
			//sizeInvalid = this.autoSizeIfNeeded() || sizeInvalid;
			
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
			this._giftImage.width = NaN;
			this._giftImage.height = NaN;
			this._giftImage.validate();
			var newWidth:Number = this.explicitWidth;
			if(needsWidth)
			{
				newWidth = this._giftImage.width;
			}
			var newHeight:Number = this.explicitHeight;
			if(needsHeight)
			{
				newHeight = this._giftImage.height;
			}
			return this.setSizeInternal(newWidth, newHeight, false);
		}
		
		protected function commitData():void
		{
			if(this._owner)
			{
				if(this._data)
				{
					_giftImage.visible = true;
					_giftImage.source = _data.imageUrl;
				}
				else
				{
					_giftImage.visible = false;
				}
			}
			else
			{
				_giftImage.visible = false;
			}
		}
		
		//private var
		protected function layout():void
		{
			this.width = _giftImage.width = owner.width;
			this.height = _giftImage.height = owner.height;
		}
		
		protected var _data:AdStoreData;
		
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
			this._data = AdStoreData(value);
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
		
		private var _firstTextFormat:TextFormat;
		public function set firstTextFormat(val:TextFormat):void
		{
			_firstTextFormat = val;
		}
		
		private var _secondTextFormat:TextFormat;
		public function set secondTextFormat(val:TextFormat):void
		{
			_secondTextFormat = val;
		}
		
		private var _thirdTextFormat:TextFormat;
		public function set thirdTextFormat(val:TextFormat):void
		{
			_thirdTextFormat = val;
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
						Flox.logEvent("Clics banniere suite a l'affichage des achats integres", {Redirection:"Clics banniere"});
						if( _data.link != null && _data.link != "" )
						{
							Flox.logInfo("Redirection vers {0}", _data.link);
							if( _data.link.indexOf("http") != -1 || _data.link.indexOf("https") != -1 )
							{
								navigateToURL( new URLRequest( _data.link ) );
							}
							else
							{
								if( _data.link.toLocaleLowerCase().indexOf("vip") != -1 )
									AbstractEntryPoint.screenNavigator.screenData.vipScreenInitializedFromStore = true;
								AbstractEntryPoint.screenNavigator.showScreen( _data.link );
							}
						}
						else
						{
							Flox.logError("Aucune redirection car aucun lien défini.");
						}
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
//------------------------------------------------------------------------------------------------------------
		
		override public function dispose():void
		{
			this.removeEventListener(TouchEvent.TOUCH, touchHandler);
			
			//_giftImage.removeEventListener(Event.COMPLETE, onImageLoader);
			_giftImage.removeFromParent(true);
			_giftImage = null;
			
			_data = null;
			
			if( this._owner )
				this._owner.removeEventListener(Event.SCROLL, owner_scrollHandler);
			
			super.dispose();
		}
	}
}