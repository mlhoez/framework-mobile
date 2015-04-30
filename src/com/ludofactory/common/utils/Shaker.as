/*
Copyright © 2006-2015 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 20 juin 2013
*/
package com.ludofactory.common.utils
{
	import com.ludofactory.mobile.core.HeartBeat;
	
	import starling.display.DisplayObject;
	import starling.events.Event;
	import starling.events.EventDispatcher;
	
	/**
	 * Shake an element with a specific amplitude.
	 */	
	public class Shaker
	{
		/**
		 * The default camera shake amplitude (if not specified) */		
		private static const CAMERA_SHAKE_AMPLITUDE:int = 15;
		
		/**
		 * The current camera shake value */		
		private static var _cameraShakeValue:Number = 0;
		
		/**
		 * The element to shake */		
		private static var _elementToShake:DisplayObject;
		
		/**
		 * The element to shake start X position. */		
		private static var _elementToShakeStartX:Number;
		/**
		 * The element to shake start Y position. */		
		private static var _elementToShakeStartY:Number;
		
		private static var _dispatcher:EventDispatcher;
		
		/**
		 * Start shaking the given element given with a specified amplitude.
		 * 
		 * @param elementToShake The element to shake
		 * @param amplitude The amplitude (default is 15)
		 */		
		public static function startShaking(elementToShake:DisplayObject, amplitude:int = CAMERA_SHAKE_AMPLITUDE):void
		{
			_elementToShake = elementToShake;
			_elementToShakeStartX = _elementToShake.x;
			_elementToShakeStartY = _elementToShake.y;
			_cameraShakeValue = amplitude;
			HeartBeat.registerFunction(shake);
		}
		
		/**
		 * Shake the element.
		 * 
		 * @param elapsedTime
		 */		
		private static function shake(elapsedTime:int):void
		{
			if (_cameraShakeValue > 0 && _elementToShake != null)
			{
				_cameraShakeValue -= 0.1;
				_elementToShake.x = _elementToShakeStartX + Math.random() * _cameraShakeValue - _cameraShakeValue * 0.5; // Shake left right randomly.
				_elementToShake.y = _elementToShakeStartY + Math.random() * _cameraShakeValue - _cameraShakeValue * 0.5; // Shake up down randomly.
			}
			else
			{
				HeartBeat.unregisterFunction(shake);
				if( _elementToShake )
				{
					_elementToShake.x = _elementToShakeStartX;
					_elementToShake.y = _elementToShakeStartY;
				}
				_elementToShake = null; // clear reference
				dispatcher.dispatchEventWith(Event.COMPLETE);
			}
		}
		
		public static function get dispatcher():EventDispatcher
		{
			if( !_dispatcher )
				_dispatcher = new EventDispatcher();
			return _dispatcher;
		}
	}
}