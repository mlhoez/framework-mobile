/*
Copyright © 2006-2014 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 26 mars 2014
*/
package com.ludofactory.mobile.debug
{
	import com.greensock.TweenMax;
	
	import flash.display.BitmapData;
	import flash.display.Shape;
	
	import starling.core.Starling;
	import starling.display.Image;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.textures.Texture;

	/**
	 * Displays the touch inputs on the screen.
	 * 
	 * <p>Intended to be used only in development mode and in order to
	 * create demo videos.</p>
	 */	
	public class TouchMarkerManager
	{
		/**
		 * The marker to display on the starling stage. */		
		private var _marker:Image;
		
		/**
		 * Helper touch. */		
		private var _helperTouch:Touch;
		
		public function TouchMarkerManager()
		{
			_marker = new Image(createTexture());
			_marker.pivotX = _marker.width / 2;
			_marker.pivotY = _marker.height / 2;
			_marker.touchable = false;
			_marker.visible = false;
			Starling.current.stage.addChild(_marker);
			Starling.current.stage.addEventListener(TouchEvent.TOUCH, onTouch);
		}
		
		/**
		 * Touch handler.
		 */		
		private function onTouch(event:TouchEvent):void
		{
			_helperTouch = event.getTouch(Starling.current.stage);
			if( _helperTouch )
			{
				if( _helperTouch.phase == TouchPhase.BEGAN )
				{
					TweenMax.killTweensOf(_marker);
					_marker.scaleX = _marker.scaleY = 1.2;
					TweenMax.to(_marker, 0.15, { autoAlpha:1, scaleX:1, scaleY:1 });
					_marker.x = _helperTouch.globalX;
					_marker.y = _helperTouch.globalY;
				}
				else if( _helperTouch.phase == TouchPhase.MOVED )
				{
					_marker.x = _helperTouch.globalX;
					_marker.y = _helperTouch.globalY;
				}
				else if( _helperTouch.phase == TouchPhase.ENDED )
				{
					TweenMax.killTweensOf(_marker);
					_marker.scaleX = _marker.scaleY = _marker.alpha = 1;
					_marker.visible = true;
					TweenMax.to(_marker, 0.15, { delay:0.15, autoAlpha:0, scaleX:1.2, scaleY:1.2 });
				}
			}
		}
		
		/**
		 * Creates the marker texture.
		 */		
		private function createTexture():Texture
		{
			var scale:Number = Starling.contentScaleFactor;
			var radius:Number = 24 * scale;
			var width:int = 64 * scale;
			var height:int = 64 * scale;
			var thickness:Number = 2 * scale;
			var shape:Shape = new Shape();
			
			// draw dark outline
			shape.graphics.lineStyle(thickness, 0x0, 0.3);
			shape.graphics.drawCircle(width/2, height/2, radius + thickness);
			
			// draw white inner circle
			shape.graphics.beginFill(0xffffff, 0.4);
			shape.graphics.lineStyle(thickness, 0xffffff);
			shape.graphics.drawCircle(width/2, height/2, radius);
			shape.graphics.endFill();
			
			var bmpData:BitmapData = new BitmapData(width, height, true, 0x0);
			bmpData.draw(shape);
			
			return Texture.fromBitmapData(bmpData, false, false, scale);
		}
		
	}
}