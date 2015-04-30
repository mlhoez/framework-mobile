/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 26 oct. 2012
Refractored : 11 déc. 2013
*/
package com.ludofactory.mobile.core.manager
{
	import com.ludofactory.mobile.core.HeartBeat;
	
	public class TimerManager
	{
		/**
		 * The base time (converted from seconds to milliseconds
		 * at creation). */		
		private var _baseTime:int = 1000;
		/**
		 * The current time. */		
		private var _currentTime:int;
		/**
		 * How many times the timer will repeat. */		
		private var _repeatCount:int;
		
		/**
		 * Function called on each update. */		
		private var _updateFunction:Function;
		/**
		 * Function called at the end. */		
		private var _finishFunction:Function;
		/**
		 * Function called on each tick. */		
		private var _tickFunction:Function;
		
		//private var _currentHour:int;
		private var _currentMin:int;
		private var _currentSec:int;
		private var _formatTime:String;
		
		/**
		 * The saved time when the turn started. */		
		private var _timeOnStartTurn:int;
		
		/**
		 * The total elapsed time since the counter
		 * was started. */		
		private var _totalElapsedTime:int;
		
		/**
		 * Creates a timer.
		 * 
		 * @param timeInSeconds The time in seconds (will be converted into milliseconds).
		 * @param repeat How many times the timer will repeat.
		 * @param updateFunction The function called on each update.
		 * @param tickFunction The function called on each tick.
		 * @param finishFunction The function called at the end.
		 * 
		 */		
		public function TimerManager(timeInSeconds:int, repeatCount:int = -1, updateFunction:Function = null, tickFunction:Function = null, finishFunction:Function = null)
		{
			// convert timeInSeconds from seconds to milliseconds to adapt
			_baseTime = timeInSeconds * 1000;
			_currentTime = _baseTime;
			_updateFunction = updateFunction;
			_finishFunction = finishFunction;
			_tickFunction = tickFunction;
			_repeatCount = repeatCount;
			_totalElapsedTime = 0;
			computeAndUpdate();
		}
		
		/**
		 * Compute values and call the update function.
		 */		
		private function computeAndUpdate():void
		{
			const timeInSecondes:Number = _currentTime / 1000;
			//_currentHour = Math.round(timeInSecondes) / 3600
			_currentMin = (Math.round(timeInSecondes) / 60) % 60;
			_currentSec = Math.round(timeInSecondes) % 60;
			
			if(_updateFunction != null && _updateFunction is Function)
				_updateFunction(_currentMin, _currentSec, getFormatedTime());
		}
		
		/**
		 * 
		 */		
		public function getCurrentTime():int
		{
			return _currentTime / 1000;
		}
		
		/**
		 * Save the current time as a "start point" in order
		 * to be tracked later when the <code>getTurnTime</code>
		 * is called to report an "end point". 
		 * 
		 * <p>This function can be used when we need to
		 * track a time to complete something (ex : finish
		 * a level in less than 50 seconds).</p>
		 */		
		public function reportStartTurn():void
		{
			_timeOnStartTurn = _currentTime / 1000;
		}
		
		/**
		 * Returns the time in seconds between the "start point"
		 * reported earlier with the <code>reportStartTurn</code>
		 * and the "end point" reported there when this function
		 * is called.
		 */		
		public function getTurnTime():int
		{
			return _timeOnStartTurn - (_currentTime / 1000);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Main functions
//------------------------------------------------------------------------------------------------------------
		
		/**
		 * Start (or restart) the timer.
		 * 
		 * <p>In case the repeat count is different from -1,
		 * this function will only restart the current repeat
		 * count.</p>
		 */		
		public function restart():void
		{
			stop();
			
			_currentTime = _baseTime;
			computeAndUpdate();
			
			reportStartTurn();
			
			HeartBeat.registerFunction(onTimerUpdate);
		}
		
		/**
		 * Stop the timer.
		 */		
		public function stop():void
		{
			HeartBeat.unregisterFunction(onTimerUpdate);
		}
		
		/**
		 * Pause the timer.
		 */		
		public function pause():void
		{
			HeartBeat.unregisterFunction(onTimerUpdate);
		}
		
		/**
		 * Resume the timer.
		 */		
		public function resume():void
		{
			HeartBeat.registerFunction(onTimerUpdate);
		}
		
		/**
		 * Add or remove time.
		 * 
		 * @param timeInSeconds Time in seconds
		 * 
		 */		
		public function updateTime(timeInSeconds:int):void
		{
			timeInSeconds = timeInSeconds * 1000;
			_currentTime += timeInSeconds;
			_currentTime = _currentTime < 0 ? 0 : _currentTime;
			computeAndUpdate();
		}
		
//------------------------------------------------------------------------------------------------------------
//	Utils
//------------------------------------------------------------------------------------------------------------
		
		/**
		 * Return a formated string for convinience.
		 * 
		 * @return A formated string (min:sec)
		 */		
		private function getFormatedTime():String
		{
			return _currentSec < 10 ? (_currentMin + ":0" + _currentSec) : (_currentMin + ":" + _currentSec);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Handler
//------------------------------------------------------------------------------------------------------------
		
		/**
		 * Update the timer.
		 * 
		 * @param elapsedTime The elapsed time in milliseconds.
		 */		
		private function onTimerUpdate(elapsedTime:Number):void
		{
			_currentTime -= elapsedTime;
			_totalElapsedTime += elapsedTime;
			computeAndUpdate();
			
			if(_currentTime <= 0)
			{
				if(_repeatCount == -1)
				{
					if(_tickFunction != null && _tickFunction is Function)
						_tickFunction();
					restart();
				}
				else
				{
					_repeatCount--;
					if(_repeatCount <= 0)
					{
						stop();
						if(_finishFunction != null && _finishFunction is Function)
							_finishFunction();
					}
					else
					{
						if(_tickFunction != null && _tickFunction is Function)
							_tickFunction();
						restart();
					}
				}
			}
		}
		
		/**
		 * The total elapsed time.
		 * 
		 * <p>Use totalElapsedTime / 1000 to get the time in seconds.</p>
		 */		
		public function get totalElapsedTime():int { return _totalElapsedTime; }
		
//------------------------------------------------------------------------------------------------------------
//	Destroy
//------------------------------------------------------------------------------------------------------------
		
		public function dispose():void
		{
			stop();
			
			_updateFunction = null;
			_finishFunction = null;
			_tickFunction = null;
		}
		
	}
}