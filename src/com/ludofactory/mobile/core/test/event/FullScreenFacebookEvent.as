/*
LudoFactory
Framework mobile
Author  : Maxime Lhoez
Created : 29 nov. 2013
*/
package com.ludofactory.mobile.core.test.event
{
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.test.FacebookManager;
	import com.ludofactory.mobile.core.test.config.GlobalConfig;
	
	import feathers.controls.ImageLoader;
	import feathers.core.FeathersControl;
	
	import starling.display.Button;
	import starling.display.Quad;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	
	public class FullScreenFacebookEvent extends FeathersControl
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
		
		private var _facebookManager:FacebookManager;
		
		public function FullScreenFacebookEvent( data:EventData )
		{
			super();
			
			_data = data;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			_overlay = new Quad(50, 50, 0x000000);
			_overlay.alpha = 0.5;
			addChild(_overlay);
			
			_image = new ImageLoader();
			_image.source = _data.imageUrl;
			_image.snapToPixels = true;
			_image.addEventListener(Event.COMPLETE, onImageLoaded);
			_image.addEventListener(TouchEvent.TOUCH, onTouch);
			addChild(_image);
			
			_closeButton = new Button( AbstractEntryPoint.assets.getTexture("event-close-button") );
			_closeButton.scaleX = _closeButton.scaleY = GlobalConfig.dpiScale;
			_closeButton.addEventListener(Event.TRIGGERED, onClose);
			addChild(_closeButton);
			
			_facebookManager = new FacebookManager();
			_facebookManager.addEventListener(FacebookManager.ACCOUNT_ASSOCIATED, onAccountAssociated);
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
//------------------------------------------------------------------------------------------------------------
		
		/**
		 * The image was touched.
		 */		
		private function onTouch(event:TouchEvent):void
		{
			var touch:Touch = event.getTouch(_image);
			if( touch && touch.phase == TouchPhase.BEGAN )
			{
				// Association Facebook
				_facebookManager.associate();
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
		
		private function onAccountAssociated(event:Event):void
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
			
			_facebookManager.removeEventListener(FacebookManager.ACCOUNT_ASSOCIATED, onAccountAssociated);
			_facebookManager.dispose();
			_facebookManager = null;
			
			super.dispose();
		}
		
	}
}