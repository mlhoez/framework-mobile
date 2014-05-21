/*
Copyright © 2006-2014 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 16 avr. 2014
*/
package com.ludofactory.mobile.core
{
	import com.freshplanet.nativeExtensions.AirNetworkInfo;
	import com.ludofactory.common.utils.Utilities;
	import com.ludofactory.mobile.core.authentication.MemberManager;
	import com.ludofactory.mobile.core.remoting.Remote;
	
	import flash.utils.getTimer;
	
	import starling.core.Starling;
	import starling.events.Event;

	/**
	 * A global timer used to display the time before the free game sessions gets updated.
	 */	
	public class GameSessionTimer
	{
		public static var IS_TIMER_OVER_AND_REQUEST_FAILED:Boolean = false;
		
		/**
		 * The vector of functions to call. */		
		private static var _listenersList:Vector.<Function> = new Vector.<Function>();
		
		/**
		 * Whether the HeartBeat is paused. */		
		private static var _isPaused:Boolean = true;
		
		/**
		 * Helper function. */		
		private static var _helperFunction:Function;
		
		/**
		 * Previous time (before the update). */		
		private static var _previousTime:Number;
		/**
		 * Elapsed time. */		
		private static var _elapsedTime:Number;
		/**
		 * Total time (in milliseconds). */		
		private static var _totalTime:Number;
		
		/**
		 * Hour. */		
		private static var _h:int;
		/**
		 * Minutes. */		
		private static var _m:int;
		/**
		 * Seconds. */		
		private static var _s:int;
		
		/**
		 * The value to display. */		
		private static var _valueToDisplay:String;
		
		public function GameSessionTimer()
		{
			
		}
		
//------------------------------------------------------------------------------------------------------------
//	Update function
		
		/**
		 * Called from MemberManager in the function <code>setNumFreeGameSessions</code> 
		 * whenever the value of the game sessions change.
		 */		
		public static function updateState():void
		{
			if( MemberManager.getInstance().isLoggedIn() )
			{
				if( MemberManager.getInstance().getNumFreeGameSessions() > 0 )
				{
					// display the number of game sessions
					valueToDisplay = "" + MemberManager.getInstance().getNumFreeGameSessions();
				}
				else
				{
					// no free game session, show the timer if necessary
					// no need to start the timer if no function registered...
					//if( _listenersList.length > 0 )
						start();
				}
			}
			else
			{
				// if not logged in, display "???" if no more game session, otherwise display the number
				valueToDisplay = "" + (MemberManager.getInstance().getNumFreeGameSessions() == 0 ? "???" : MemberManager.getInstance().getNumFreeGameSessions());
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Start, Stop & Pause
		
		/**
		 * Starts the timer.
		 */		
		public static function start():void
		{
			if(_isPaused /*&& _listenersList.length != 0*/)
			{
				_isPaused = false;
				
				// calculate the number of milliseconds until the end of the day
				var nowInFrance:Date = Utilities.getLocalFrenchDate();
				_totalTime = (86400 - (nowInFrance.hours * 60 * 60) - (nowInFrance.minutes * 60) - nowInFrance.seconds) * 1000;
				_previousTime = getTimer();
				Starling.current.stage.addEventListener(Event.ENTER_FRAME, update);
			}
			
		}
		
		/**
		 * Stops the timer.
		 */		
		public static function stop():void
		{
			if(!_isPaused)
			{
				_isPaused = true;
				
				Starling.current.stage.removeEventListener(Event.ENTER_FRAME, update);
			}
		}
		
		/**
		 * Pauses the timer (mainly used when the user starts playing).
		 */		
		public static function pause():void
		{
			
		}
		
		/**
		 * Resumes the timer (mainly used when the user stops playing).
		 */		
		public static function resume():void
		{
			
		}
		
//------------------------------------------------------------------------------------------------------------
//	Update function
		
		/**
		 * Main update function.
		 * 
		 * <p>When we get here, it is when a second has elapsed, so no need
		 * to calculate the time, we only need to decrement the counter by
		 * 1000 milliseconds.</p>
		 */		
		private static function update(event:Event):void
		{
			_elapsedTime = getTimer() - _previousTime;
			_previousTime = getTimer();
			_totalTime -= _elapsedTime;
			
			// every second
			//if( _totalTime % 1000 == 0 )
			//{
				if( _totalTime > 0 )
				{
					// still in loop
					_h = Math.round(_totalTime / 1000) / 3600;
					_m = (Math.round(_totalTime / 1000) / 60) % 60;
					_s = Math.round(_totalTime / 1000) % 60;
					
					valueToDisplay = (_h < 10 ? "0":"") + _h + ":" + (_m < 10 ? "0":"") + _m + ":" + (_s < 10 ? "0":"") + _s;
				}
				else
				{
					// timer is over, stop everything
					// request stakes, and then update the summary
					stop();
					
					if( AirNetworkInfo.networkInfo.isConnected() )
						Remote.getInstance().updateMises(onStakesUpdated, onStakesUpdated, onStakesUpdated, 1);
					
					valueToDisplay = "00:00:00";
				}
			//}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Register / Unregister
		
		/**
		 * Registers a function to the core update.
		 * 
		 * <p>The functions must have this signature :<br /> myFunction(elapsedTime:int):void { }</p>
		 * 
		 * <p>NOTE : The time given in parameters is in milliseconds.</p>
		 * 
		 * @param listener The function the register.
		 */		
		public static function registerFunction(listener:Function):void
		{
			if( _listenersList.indexOf(listener) == -1 )
				_listenersList.push(listener);
		}
		
		/**
		 * Unregisters a function from the core update.
		 * 
		 * @param listener The function to unregister.
		 */		
		public static function unregisterFunction(listener:Function):void
		{
			if( _listenersList.indexOf(listener) != -1 )
				_listenersList.splice(_listenersList.indexOf(listener), 1);
		}
		
		public static function set valueToDisplay(val:String):void
		{
			_valueToDisplay = val;
			for each(_helperFunction in _listenersList)
				_helperFunction(_valueToDisplay);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Update callback
		
		/**
		 * When the stakes have been updated.
		 */		
		private static function onStakesUpdated(result:Object = null):void
		{
			// TODO Gérer ce cas...
			if( MemberManager.getInstance().getNumFreeGameSessions() == 0 )
				IS_TIMER_OVER_AND_REQUEST_FAILED = true;
			else
				IS_TIMER_OVER_AND_REQUEST_FAILED = false;
			
			valueToDisplay = "" + MemberManager.getInstance().getNumFreeGameSessions();
		}
		
	}
}