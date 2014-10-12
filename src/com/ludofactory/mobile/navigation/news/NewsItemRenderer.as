/*
Copyright © 2006-2014 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 18 sept. 2013
*/
package com.ludofactory.mobile.navigation.news
{
	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.theme.Theme;
	import com.sticksports.nativeExtensions.canOpenUrl.CanOpenUrl;
	
	import flash.geom.Point;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import feathers.controls.Button;
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
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	
	/**
	 * Item renderer used to display the customer service messages.
	 */	
	public class NewsItemRenderer extends FeathersControl implements IListItemRenderer
	{
		private static const HELPER_POINT:Point = new Point();
		private static const HELPER_TOUCHES_VECTOR:Vector.<Touch> = new <Touch>[];
		protected var _touchPointID:int = -1;
		
		private var PHONE_IMAGE_BASE_WIDTH:int = 269;
		private var TABLET_IMAGE_BASE_WIDTH:int = 360;
		
		/**
		 * The base height of a line in the list. */		
		private static const BASE_HEIGHT:int = 180;
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
		 * The gift fade tween. */		
		protected var _fadeTween:Tween;
		/**
		 * Loader used while the image is loading. */		
		private var _imageLoader:MovieClip;
		/**
		 * The background. */		
		private var _background:Quad;
		/**
		 * The shadow displayed only on the first item */		
		private var _shadow:Quad;
		/**
		 * The game image. */		
		private var _image:ImageLoader;
		/**
		 * Title of the message, it's the name of the choosed theme. */		
		private var _title:Label;
		/**
		 * A preview (75 chars max) of the last message sent. */		
		private var _message:Label;
		/**
		 * The bottom stripe only displayed in the last item renderer. */		
		private var _bottomStripe:Quad;
		/**
		 * The button. */		
		private var _button:Button;
		
		public function NewsItemRenderer()
		{
			super();
			this.addEventListener(TouchEvent.TOUCH, touchHandler);
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			PHONE_IMAGE_BASE_WIDTH = scaleAndRoundToDpi(PHONE_IMAGE_BASE_WIDTH);
			TABLET_IMAGE_BASE_WIDTH = scaleAndRoundToDpi(TABLET_IMAGE_BASE_WIDTH);
			
			_itemHeight = scaleAndRoundToDpi( BASE_HEIGHT * (GlobalConfig.isPhone ? 1:1.25) );
			_strokeThickness = scaleAndRoundToDpi(BASE_STROKE_THICKNESS);
			
			this.width = GlobalConfig.stageWidth;
			this.height = _itemHeight;
			
			_background = new Quad(this.width, this.height);
			addChild(_background);
			
			_shadow = new Quad(this.width, scaleAndRoundToDpi(12), 0x000000);
			_shadow.setVertexAlpha(0, 0.1);
			_shadow.setVertexAlpha(1, 0.1);
			_shadow.setVertexAlpha(2, 0);
			_shadow.setVertexColor(2, 0xffffff);
			_shadow.setVertexAlpha(3, 0);
			_shadow.setVertexColor(3, 0xffffff);
			addChild(_shadow);
			
			_image = new ImageLoader();
			_image.addEventListener(Event.COMPLETE, onImageLoader);
			_image.addEventListener(FeathersEventType.ERROR, onImageError);
			addChild(_image);
			
			_imageLoader = new MovieClip( Theme.blackLoaderTextures );
			_imageLoader.scaleX = _imageLoader.scaleY = GlobalConfig.dpiScale;
			_imageLoader.alignPivot();
			addChild(_imageLoader);
			Starling.juggler.add(_imageLoader);
			
			_title = new Label();
			addChild(_title);
			_title.textRendererProperties.textFormat = Theme.newsIRTitleTextFormat;
			_title.textRendererProperties.wordWrap = false;
			
			_message = new Label();
			addChild(_message);
			_message.textRendererProperties.textFormat = Theme.newsIRMessageTextFormat;
			
			_button = new Button();
			_button.styleName = Theme.BUTTON_NEWS;
			addChild(_button);
			
			_bottomStripe = new Quad(this.width, _strokeThickness, 0xbfbfbf);
			addChild(_bottomStripe);
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
				if(this._fadeTween)
				{
					this._fadeTween.advanceTime(Number.MAX_VALUE);
				}
				if( _data )
				{
					_imageLoader.visible = _data.imageUrl.indexOf("http") == -1 ? false : true;
					_image.visible = _data.imageUrl.indexOf("http") == -1 ? true : false;
					_image.source = _data.imageUrl.indexOf("http") == -1 ? AbstractEntryPoint.assets.getTexture(_data.imageUrl + (GlobalConfig.isPhone ? "" : "-hd")) : _data.imageUrl;
					
					if( _data.urlScheme == null || _data.link == null || _data.urlScheme == "" || _data.link == "" )
						_button.visible = false;
					else
						_button.visible = true;
					_button.label = CanOpenUrl.canOpen(_data.urlScheme) ? _("Jouer") : _("Télécharger");
					
					_title.visible = _message.visible = true;
					_title.text = _data.title;
					_message.text = _data.description;
				}
				else
				{
					_title.visible = _message.visible = false;
					_title.text = _message.text = "";
					_imageLoader.visible = false;
					_image.source = null;
				}
			}
			else
			{
				_title.visible = _message.visible = false;
				_imageLoader.visible = false;
				_image.source = null;
			}
		}
		
		protected function layout():void
		{
			if( this.owner && this.owner.dataProvider && _index == 0 )
				_shadow.visible = true;
			else
				_shadow.visible = false;
			
			_image.width = GlobalConfig.isPhone ? PHONE_IMAGE_BASE_WIDTH:TABLET_IMAGE_BASE_WIDTH;
			_image.height = this.height *1;
			_image.x = scaleAndRoundToDpi(15);
			_image.y = (this.height - _image.height) * 0.5;
			
			_imageLoader.x = _image.x + (_image.width * 0.5);
			_imageLoader.y = this.height * 0.5;
			
			_button.validate();
			_button.y = _image.y + _image.height * 0.85 - _button.height;
			_button.x = _image.x + _image.width - _button.width;
			
			_title.x = _image.x + _image.width + scaleAndRoundToDpi(10);
			_title.width = this.actualWidth - _message.x - scaleAndRoundToDpi(10);
			_title.validate();
			_title.y = _image.y + scaleAndRoundToDpi(10);
			
			_message.x = _image.x + _image.width + scaleAndRoundToDpi(10);
			_message.y = _title.y + _title.height;
			_message.width = this.actualWidth - _message.x - scaleAndRoundToDpi(10);
			_message.validate();
			
			_bottomStripe.y = this.actualHeight - _strokeThickness;
		}
		
		protected var _data:NewsData;
		
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
			this._data = NewsData(value);
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
						var request:URLRequest = new URLRequest();
						if( _data.urlScheme != null && _data.urlScheme != "" )
						{
							// this is a game news that must trigger an app open (the target app)
							if( CanOpenUrl.canOpen(_data.urlScheme) )
							{
								// the app is installed on the device, then open it
								request.url = _data.urlScheme;
							}
							else if( _data.link != null && _data.link != "" )
							{
								// the app is not installed, then redirect to a download
								// link if defined, and start app to app tracking
								// FIXME MAT Integrate this later
								/*try
								{
									if( _data.targetAppId != null && _data.targetAppId != "" )
										MobileAppTracker.instance.startAppToAppTracking(_data.targetAppId, GameConfig.HAS_OFFERS_ADVERTISER_ID, _data.offerId, _data.publisherId, false);
								} 
								catch(error:Error) 
								{
									
								}*/
								request.url = _data.link;
							}
						}
						else if( _data.link != null && _data.link != "" )
						{
							// redirect to the link if defined
							request.url = _data.link;
						}
						
						if( request.url != null && request.url != "" )
							navigateToURL( request );
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
		
		public function onScroll(event:Event):void
		{
			_touchPointID = -1;
		}
		
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
//------------------------------------------------------------------------------------------------------------
		
		override public function dispose():void
		{
			removeEventListener(TouchEvent.TOUCH, touchHandler);
			
			_background.removeFromParent(true);
			_background = null;
			
			_shadow.removeFromParent(true);
			_shadow = null;
			
			_image.removeEventListener(Event.COMPLETE, onImageLoader);
			_image.removeEventListener(FeathersEventType.ERROR, onImageError);
			_image.removeFromParent(true);
			_image = null;
			
			_title.removeFromParent(true);
			_title = null;
			
			_message.removeFromParent(true);
			_message = null;
			
			_bottomStripe.removeFromParent(true);
			_bottomStripe = null;
			
			if( _fadeTween )
			{
				Starling.juggler.remove(_fadeTween);
				_fadeTween = null;
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