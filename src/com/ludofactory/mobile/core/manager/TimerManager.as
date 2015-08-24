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
		 * The base time (converted from seconds to milliseconds at creation). */		
		private var _baseTime:int = 1000;
		/**
		 * The current time. */		
		private var _currentTime:int;
		/**
		 * How many times the timer will repeat. */
		private var _baseRepeatCount:int;
		/**
		 * Current repeat count. */
		private var _currentRepeatCount:int;
		
		/**
		 * Function called on each update. */		
		private var _updateFunction:Function;
		/**
		 * Function called at the end. */		
		private var _finishFunction:Function;
		/**
		 * Function called on each tick. */		
		private var _tickFunction:Function;
		
		/**
		 * The saved time when the turn started. */		
		private var _timeOnStartTurn:int;
		
		/**
		 * The total elapsed time since the counter
		 * was started. */		
		private var _totalElapsedTime:int;
		
		/**
		 * A second converted in milliseconds. */
		private var _baseSecond:int = 1000;
		/**
		 * The current second (used to update not at each frame but at each second). */
		private var _currentSecond:int = 0;
		
		/**
		 * Whether the timer is running. */
		private var _isRunning:Boolean = false;
		
		/**
		 * Creates a timer.
		 * 
		 * @param timeInSeconds The time in seconds (will be converted into milliseconds).
		 * @param repeatCount How many times the timer will repeat.
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
			_baseRepeatCount = repeatCount;
			_currentRepeatCount = _baseRepeatCount;
			_totalElapsedTime = 0;
			
			try
			{
				// if we use the TimerManager instance in the update function, the instance will be null and create an error
				computeAndUpdate();
			}
			catch(error:Error)
			{
				
			}
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
		
		/**
		 * Starts the timer.
		 */
		public function start():void
		{
			HeartBeat.registerFunction(onTimerUpdate);
			_isRunning = true;
		}
		
		/**
		 * Restarts the timer.
		 */		
		public function restart():void
		{
			stop();
			
			_currentTime = _baseTime;
			_currentRepeatCount = _baseRepeatCount;
			computeAndUpdate();
			
			reportStartTurn();
			
			start();
		}
		
		/**
		 * Stops the timer.
		 */		
		public function stop():void
		{
			HeartBeat.unregisterFunction(onTimerUpdate);
			_isRunning = false;
		}
		
		/**
		 * Pauses the timer.
		 */		
		public function pause():void
		{
			HeartBeat.unregisterFunction(onTimerUpdate);
			_isRunning = false;
		}
		
		/**
		 * Resumes the timer.
		 */		
		public function resume():void
		{
			HeartBeat.registerFunction(onTimerUpdate);
			_isRunning = true;
		}
		
		private function continueTick():void
		{
			if( _isRunning )
			{
				stop();
				
				_currentTime = _baseTime;
				computeAndUpdate();
				
				HeartBeat.registerFunction(onTimerUpdate);
				_isRunning = true;
			}
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
		
		/**
		 * Return a formated string for convinience.
		 * 
		 * @return A formated string (min:sec)
		 */		
		private function getFormatedTime():String
		{
			return currentSec < 10 ? (currentMin + ":0" + currentSec) : (currentMin + ":" + currentSec);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Handler
		
		/**
		 * Updates the timer.
		 * 
		 * @param elapsedTime The elapsed time in milliseconds.
		 */		
		private function onTimerUpdate(elapsedTime:Number):void
		{
			// if elapsedTime is negative, we don't count this
			if( elapsedTime < 0 /*&& (elapsedTime < 0 ? (elapsedTime*-1) : elapsedTime) > BaseServerData.dateChangeTolerance.value*/) // 1000 ms = 1 sec
			{
				// the date has changed
				//CheatManager.getInstance().reportDateChange(elapsedTime, BaseServerData.dateChangeTolerance.value);
				elapsedTime = 0;
			}
			_currentTime -= elapsedTime;
			_totalElapsedTime += elapsedTime;
			
			_currentSecond -= elapsedTime;
			if( _currentSecond <= 0 )
			{
				_currentSecond = _baseSecond;
				computeAndUpdate();
			}
			
			if(_currentTime <= 0)
			{
				_currentTime = 0;
				if(_currentRepeatCount == -1)
				{
					if(_tickFunction != null && _tickFunction is Function)
						_tickFunction();
					continueTick();
				}
				else
				{
					// removed by security because it could be -1 which caused the timer to repeat endlessly
					//_currentRepeatCount--;
					_currentRepeatCount = (_currentRepeatCount - 1) < 0 ? 0 : (_currentRepeatCount - 1);
					if(_currentRepeatCount == 0)
					{
						stop();
						if(_finishFunction != null && _finishFunction is Function)
							_finishFunction();
					}
					else
					{
						if(_tickFunction != null && _tickFunction is Function)
							_tickFunction();
						continueTick();
					}
				}
			}
		}
		
		/**
		 * Compute values and call the update function.
		 */
		private function computeAndUpdate():void
		{
			if(_updateFunction != null && _updateFunction is Function)
				_updateFunction(getFormatedTime());
		}
		
//------------------------------------------------------------------------------------------------------------
//	Get
		
		/**
		 * The total elapsed time (in seconds).
		 * 
		 * FIXME Avant c'était return _totalElapsedTime et non pas _totalElapsedTime / 1000
		 */
		public function get totalElapsedTime():int { return _totalElapsedTime / 1000; }
		
		/**
		 * Current time in seconds. */
		public function get currentTime():int { return ((_currentTime / 1000) << 0); }
		
		/**
		 * How many days left. */
		public function get currentDay():int { return (((_currentTime / 1000) << 0) / 86400); }
		/**
		 * How many hours left.
		 * Note that it's not the total of hours left, to get this value, remove the "% 24" */
		public function get currentHour():int { return ((((_currentTime / 1000) << 0) / 3600) % 24); }
		/**
		 * How many minutes left.
		 * Note that it's not the total of minutes left, to get this value, remove the "% 60" */
		public function get currentMin():int { return ((((_currentTime / 1000) << 0) / 60) % 60); }
		/**
		 * How many seconds left.
		 * Note that it's not the total of seconds left, to get this value, remove the "% 60" */
		public function get currentSec():int { return (((_currentTime / 1000) << 0) % 60); }
		
		/**
		 * Whether the timer is running. */
		public function get isRunning():Boolean { return _isRunning; }
		
//------------------------------------------------------------------------------------------------------------
//	Destroy
		
		public function dispose():void
		{
			stop();
			
			_updateFunction = null;
			_finishFunction = null;
			_tickFunction = null;
		}
		
	}
}