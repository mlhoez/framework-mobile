/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 29 nov. 2013
*/
package com.ludofactory.mobile.navigation.event
{
	
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.milkmangames.nativeextensions.CoreMobile;
	
	import feathers.controls.ImageLoader;
	import feathers.core.FeathersControl;
	
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import starling.display.Button;
	import starling.display.Quad;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	
	public class FullScreenEvent extends AbstractFullScreenEvent
	{
		/**
		 * The overlay. */		
		private var _overlay:Quad;
		
		/**
		 * The image. */		
		private var _image:ImageLoader;
		
		/**
		 * The event data. */		
		private var _data:EventData;
		
		private var _closeButton:Button;
		
		public function FullScreenEvent( data:EventData )
		{
			super();
			
			_data = data;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			_overlay = new Quad(50, 50, _data.decorationColor.toRgb());
			_overlay.alpha = _data.decorationColor.alpha;
			addChild(_overlay);
			
			_image = new ImageLoader();
			_image.source = _data.imageUrl;
			_image.snapToPixels = true;
			_image.addEventListener(Event.COMPLETE, onImageLoaded);
			addChild(_image);
			
			_closeButton = new Button( AbstractEntryPoint.assets.getTexture("event-close-button") );
			_closeButton.scaleX = _closeButton.scaleY = GlobalConfig.dpiScale;
			addChild(_closeButton);
		}
		
		override protected function draw():void
		{
			super.draw();
			
			_image.width = _overlay.width = actualWidth;
			_image.height = _overlay.height = actualHeight;
			
			_closeButton.x = actualWidth - _closeButton.width - scaleAndRoundToDpi(10);
			_closeButton.y = scaleAndRoundToDpi(10);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Handlers
		
		/**
		 * Use a short delay to enable the event, so that the user won't click on it to quickly without
		 * seeing what is it about.
		 */
		override public function enableEvent():void
		{
			_closeButton.addEventListener(Event.TRIGGERED, onClose);
			_image.addEventListener(TouchEvent.TOUCH, onTouch);
		}
		
		/**
		 * The image was touched.
		 */		
		private function onTouch(event:TouchEvent):void
		{
			var touch:Touch = event.getTouch(_image);
			if( touch && touch.phase == TouchPhase.BEGAN )
			{
				var request:URLRequest = new URLRequest();
				if( _data.urlScheme != null && _data.urlScheme != "" )
				{
					// this is a game event that must trigger an app open (the target app)
					if( CoreMobile.isSupported() && CoreMobile.mobile.canOpenUrl(_data.urlScheme) )
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
					if( _data.link.indexOf("http") != -1 || _data.link.indexOf("https") != -1 )
					{
						request.url = _data.link;
					}
					else
					{
						AbstractEntryPoint.screenNavigator.showScreen( _data.link );
						dispatchEventWith(Event.CLOSE);
					}
				}
				
				if( request.url != null && request.url != "" )
				{
					if(_data.closeWhenRedirect)
						dispatchEventWith(Event.CLOSE);
					navigateToURL( request );
				}
			}
			touch = null;
		}
		
		private function onImageLoaded(event:Event):void
		{
			dispatchEventWith(Event.COMPLETE);
		}
		
		private function onClose(event:Event):void
		{
			dispatchEventWith(Event.CLOSE);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
//------------------------------------------------------------------------------------------------------------
		
		override public function dispose():void
		{
			_overlay.removeFromParent(true);
			_overlay = null;
			
			_image.removeEventListener(Event.COMPLETE, onImageLoaded);
			_image.removeEventListener(TouchEvent.TOUCH, onTouch);
			_image.removeFromParent(true);
			_image = null;
			
			_closeButton.removeEventListener(Event.TRIGGERED, onClose);
			_closeButton.removeFromParent(true);
			_closeButton = null;
			
			super.dispose();
		}
		
	}
}