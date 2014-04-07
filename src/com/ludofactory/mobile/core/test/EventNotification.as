/*
Copyright © 2006-2014 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 18 oct. 2013
*/
package com.ludofactory.mobile.core.test
{
	import com.greensock.TweenMax;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.notification.NotificationManager;
	import com.ludofactory.mobile.core.notification.content.AbstractNotification;
	import com.ludofactory.mobile.core.test.config.GlobalConfig;
	import com.ludofactory.mobile.core.test.event.EventData;
	import com.sticksports.nativeExtensions.canOpenUrl.CanOpenUrl;
	
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import feathers.controls.ImageLoader;
	import feathers.events.FeathersEventType;
	import feathers.layout.VerticalLayout;
	
	import starling.core.Starling;
	import starling.display.MovieClip;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.utils.HAlign;
	import starling.utils.VAlign;
	
	public class EventNotification extends AbstractNotification
	{
		/**
		 * Loader used while the image is loading. */		
		private var _imageLoader:MovieClip;
		
		/**
		 * The disconnect icon. */		
		private var _icon:ImageLoader;
		
		/**
		 * If we need to resize the notification */		
		private var _needResize:Boolean = false;
		
		/**
		 * The vent data. */		
		private var _eventData:EventData;
		
		public function EventNotification( data:EventData )
		{
			super();
			
			_eventData = data;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			const layout:VerticalLayout = new VerticalLayout();
			layout.horizontalAlign = VerticalLayout.HORIZONTAL_ALIGN_CENTER;
			layout.verticalAlign = VerticalLayout.VERTICAL_ALIGN_MIDDLE;
			layout.gap = scaleAndRoundToDpi( GlobalConfig.isPhone ? 40:60 );
			_container.layout = layout;
			
			_imageLoader = new MovieClip( AbstractEntryPoint.assets.getTextures("MiniLoader") );
			_imageLoader.scaleX = _imageLoader.scaleY = GlobalConfig.dpiScale;
			_container.addChild(_imageLoader);
			Starling.juggler.add(_imageLoader);
			
			_icon = new ImageLoader();
			_icon.addEventListener(Event.COMPLETE, onImageLoaded);
			_icon.addEventListener(FeathersEventType.ERROR, onImageError);
			_icon.source = _eventData.imageUrl;
			//_icon.scaleX = _icon.scaleY = GlobalConfig.dpiScalez;
			_container.addChild(_icon);
			
			_icon.addEventListener(TouchEvent.TOUCH, onTouchImage);
		}
		
		override protected function draw():void
		{
			_container.width = this.actualWidth //- padSide * 2;
			//_container.x = padSide;
			
			if( _icon.isLoaded )
			{
				_icon.validate();
				//if( _icon.width > _container.width )
					_icon.width = _container.width;
			}
			
			_closeButton.x = this.actualWidth * 0.5;
			
			_topLeftDecoration.width = _topRightDecoration.width = _closeButton.x - padSideDeco - (_closeButton.width * 0.35);
			_topRightDecoration.alignPivot(HAlign.RIGHT, VAlign.TOP);
			_topRightDecoration.scaleX = -1;
			_topLeftDecoration.y = _topRightDecoration.y = padTopDeco;
			_topLeftDecoration.x = padSideDeco;
			_topRightDecoration.x = this.actualWidth - padSideDeco - _topRightDecoration.width;
			
			_container.validate();
			if( _container.height > maximumContainerHeight )
				_container.height = maximumContainerHeight;
			_container.y = scaleAndRoundToDpi(66)//_topLeftDecoration.y + _topLeftDecoration.height + scaleAndRoundToDpi(10);
			
			_bottomLeftDecoration.width = _bottomRightDecoration.width = (this.actualWidth * 0.5) - padSideDeco * 2;
			_bottomRightDecoration.alignPivot(HAlign.RIGHT, VAlign.TOP);
			_bottomRightDecoration.scaleX = -1;
			_bottomLeftDecoration.y = _bottomRightDecoration.y = _container.y + _container.height - _bottomLeftDecoration.height - scaleAndRoundToDpi(10);
			_bottomLeftDecoration.x = padSideDeco;
			_bottomRightDecoration.x = this.actualWidth - padSideDeco - _bottomRightDecoration.width;
			
			_backgroundSkinou.width = this.actualWidth;
			_backgroundSkinou.y = padTopBackgroundSkinou;
			_backgroundSkinou.height = _container.height + _container.y - padTopBackgroundSkinou;
			
			/*_backgroundGradient.width = this.actualWidth - padSide * 2;
			_backgroundGradient.x = padSide;
			_backgroundGradient.y = _container.y;
			_backgroundGradient.height = _backgroundSkinou.height + _backgroundSkinou.y - _backgroundGradient.y;*/
			
			_topLeftDecoration.color = _topRightDecoration.color = _bottomLeftDecoration.color = _bottomRightDecoration.color = _eventData.decorationColor;
			_topLeftDecoration.visible = _topRightDecoration.visible = _bottomLeftDecoration.visible = _bottomRightDecoration.visible = _eventData.decorationVisible;
			
			_backgroundSkinou.visible = false;
			_backgroundGradient.visible = false;
			
			setSize(this.actualWidth, _backgroundSkinou.height + _backgroundSkinou.y);
			
			if( _needResize )
			{
				_needResize = false;
				NotificationManager.replaceNotification();
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Handlers
//------------------------------------------------------------------------------------------------------------

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
			_needResize = true;
			_container.invalidate(INVALIDATION_FLAG_SIZE);
			this.invalidate(INVALIDATION_FLAG_SIZE);
		}
		
		/**
		 * When the image could not be loaded.
		 */		
		protected function onImageError(event:Event):void
		{
			this.invalidate(INVALIDATION_FLAG_SIZE);
		}
		
		private function onTouchImage(event:TouchEvent):void
		{
			var touch:Touch = event.getTouch(this);
			if( touch && touch.phase == TouchPhase.ENDED )
			{
				var request:URLRequest = new URLRequest();
				if( _eventData.urlScheme != null && _eventData.urlScheme != "" )
				{
					// this is a game event that must trigger an app open (the target app)
					if( CanOpenUrl.canOpen(_eventData.urlScheme) )
					{
						// the app is installed on the device, then open it
						request.url = _eventData.urlScheme;
					}
					else if( _eventData.link != null && _eventData.link != "" )
					{
						// the app is not installed, then redirect to a download
						// link if defined, and start app to app tracking
						// FIXME MAT Integrate this later
						/*try
						{
							if( _eventData.targetAppId != null && _eventData.targetAppId != "" )
								MobileAppTracker.instance.startAppToAppTracking(_eventData.targetAppId, GameConfig.HAS_OFFERS_ADVERTISER_ID, _eventData.offerId, _eventData.publisherId, false);
						} 
						catch(error:Error) 
						{
							
						}*/
						request.url = _eventData.link;
					}
				}
				else if( _eventData.link != null && _eventData.link != "" )
				{
					if( _eventData.link.indexOf("http") != -1 || _eventData.link.indexOf("https") != -1 )
						request.url = _eventData.link;
					else
						AbstractEntryPoint.screenNavigator.showScreen( _eventData.link );
				}
				
				if( request.url != null && request.url != "" )
					navigateToURL( request );
			}
			touch = null;
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
//------------------------------------------------------------------------------------------------------------
		
		override public function dispose():void
		{
			removeEventListener(TouchEvent.TOUCH, onTouchImage);
			
			if( _imageLoader )
			{
				Starling.juggler.remove(_imageLoader);
				_imageLoader.removeFromParent(true);
				_imageLoader = null;
			}
			
			_icon.removeEventListener(Event.COMPLETE, onImageLoaded);
			_icon.removeEventListener(FeathersEventType.ERROR, onImageError);
			_icon.removeFromParent(true);
			_icon = null;
			
			_eventData = null;
			
			super.dispose();
		}
	}
}