/*
Copyright © 2006-2015 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 29 août 2012
*/
package com.ludofactory.mobile.core
{
	import starling.core.Starling;
	import starling.events.EnterFrameEvent;
	import starling.events.Event;
	
	/**
	 * Application's main timer.
	 */	
	public class HeartBeat
	{
		/**
		 * The vector of functions to call. */		
		private static var _listenersList:Vector.<Function> = new Vector.<Function>();
		/**
		 * Whether the HeartBeat is paused. */		
		private static var _isPaused:Boolean = true;
		/**
		 * The normal elapsed time. */		
		private static var _normalElapsedTime:int;
		
		public function HeartBeat()
		{
			
		}
		
//------------------------------------------------------------------------------------------------------------
//	Function registering / unregistering
//------------------------------------------------------------------------------------------------------------
		
		/**
		 * Register a function to the core update.
		 * 
		 * <p>The functions must have this signature :<br /> myFunction(elapsedTime:int):void { }</p>
		 * 
		 * <p>NOTE : to get the raw elapsed time, you must divide the elapsedTime
		 * by 1000 like this : rawElapsedTime = elapsedTime / 1000</p>
		 * 
		 * @param listener The function the register.
		 */		
		public static function registerFunction(listener:Function):void
		{
			if( _listenersList.indexOf(listener) == -1 )
				_listenersList.push(listener);
			start();
		}
		
		/**
		 * Unregister a function from the core update.
		 * 
		 * @param listener The function to unregister.
		 */		
		public static function unregisterFunction(listener:Function):void
		{
			if( _listenersList.indexOf(listener) != -1 )
				_listenersList.splice(_listenersList.indexOf(listener), 1);
			if( _listenersList.length == 0 )
				stop();
		}
		
		/**
		 * Removes all the registered functions.
		 */		
		public static function removeAllListener():void
		{
			stop();
			_listenersList = new Vector.<Function>();
		}
		
//------------------------------------------------------------------------------------------------------------
//	Start / Stop
//------------------------------------------------------------------------------------------------------------
		
		/**
		 * Starts the HearBeat.
		 */	
		public static function start():void
		{
			if(_isPaused && _listenersList.length != 0)
			{
				_isPaused = false;
				Starling.current.stage.addEventListener(Event.ENTER_FRAME, beat);
			}
		}
		
		/**
		 * Stops the HearBeat.
		 */	
		public static function stop():void
		{
			if(!_isPaused)
			{
				_isPaused = true;
				Starling.current.stage.removeEventListener(Event.ENTER_FRAME, beat);
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Core update
//------------------------------------------------------------------------------------------------------------
		
		/**
		 * This is the core update of the HearBeat timer. This function will compute the
		 * values of the time elapsed and then update all the registered functions.
		 * 
		 * <p>evt.passedTime is the raw time, to get the "normal" elapsed time, we must
		 * do int(evt.passedTime * 1000).</p>
		 */		
		public static function beat(event:EnterFrameEvent):void
		{
			_normalElapsedTime = int(event.passedTime * 1000);
			for each(var func:Function in _listenersList)
				func(_normalElapsedTime);
		}
	}
}

internal class securityKey{};