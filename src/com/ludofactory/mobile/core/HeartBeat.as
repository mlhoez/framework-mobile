/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 29 août 2012
*/
package com.ludofactory.mobile.core
{
	
	import flash.utils.getTimer;
	
	import starling.core.Starling;
	import starling.events.EnterFrameEvent;
	
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
		
		/**
		 * Previous time (before the update). */
		private static var _previousTime:int;
		/**
		 * Elapsed time. */
		private static var _elapsedTime:int;
		
		public function HeartBeat()
		{
			
		}
		
//------------------------------------------------------------------------------------------------------------
//	Function registering / unregistering
		
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
		
		/**
		 * Starts the HearBeat.
		 */	
		private static function start():void
		{
			if(_isPaused && _listenersList.length != 0)
			{
				_isPaused = false;
				_previousTime = getTimer();
				Starling.current.stage.addEventListener(EnterFrameEvent.ENTER_FRAME, beat);
			}
		}
		
		/**
		 * Stops the HearBeat.
		 */	
		private static function stop():void
		{
			if(!_isPaused)
			{
				_isPaused = true;
				Starling.current.stage.removeEventListener(EnterFrameEvent.ENTER_FRAME, beat);
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Pause / Resume
		
		/**
		 * Resumes the HearBeat.
		 */
		public static function resume():void
		{
			if(_isPaused && _listenersList.length != 0)
			{
				_isPaused = false;
				Starling.current.stage.addEventListener(EnterFrameEvent.ENTER_FRAME, beat);
			}
		}
		
		/**
		 * Pauses the HearBeat.
		 */
		public static function pause():void
		{
			if(!_isPaused)
			{
				_isPaused = true;
				Starling.current.stage.removeEventListener(EnterFrameEvent.ENTER_FRAME, beat);
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Core update
		
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
			
			_elapsedTime = getTimer() - _previousTime;
			_previousTime = getTimer();
			
			for each(var func:Function in _listenersList)
				func(_normalElapsedTime, _elapsedTime);
		}
	}
}