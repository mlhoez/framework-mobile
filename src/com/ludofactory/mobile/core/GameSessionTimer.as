/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 16 avr. 2014
*/
package com.ludofactory.mobile.core
{
	import com.freshplanet.nativeExtensions.AirNetworkInfo;
	import com.ludofactory.common.utils.Utilities;
	import com.ludofactory.mobile.core.manager.MemberManager;
	import com.ludofactory.mobile.core.remoting.Remote;
	
	import flash.utils.getTimer;
	
	import starling.core.Starling;
	import starling.events.Event;

	/**
	 * A global timer used to display the time before the free game sessions gets updated.
	 */	
	public class GameSessionTimer
	{
		/**
		 * Number of seconds in a day. */		
		private static const NUM_SECONDS_IN_A_DAY:int = 86400;
		
		public static var IS_TIMER_OVER_AND_REQUEST_FAILED:Boolean = false;
		
		/**
		 * The vector of functions to call. */		
		private static var _listenersList:Vector.<Function> = new Vector.<Function>();
		
		/**
		 * Whether the HeartBeat is paused. */		
		private static var _isRunning:Boolean = false;
		
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
//	Update state function
		
		/**
		 * This function should be called whenever the number of free game sessions
		 * change and when a user log in / out.
		 * 
		 * <p>It will update the state of the GameSessionTimer in order to display
		 * the correct number of free game sessions or the timer if there are no more
		 * and the user is logged in, or "???" if the user is not logged in.
		 */		
		public static function updateState():void
		{
			if( MemberManager.getInstance().isLoggedIn() )
			{
				if( MemberManager.getInstance().getNumTokens() > 0 )
				{
					// display the number of game sessions
					stop();
					valueToDisplay = "" + MemberManager.getInstance().getNumTokens();
				}
				else
				{
					// no more free game session then start the timer
					start();
				}
			}
			else
			{
				// if not logged in, display "???" if no more game session, otherwise display the number
				stop();
				valueToDisplay = "" + (MemberManager.getInstance().getNumTokens() == 0 ? "???" : MemberManager.getInstance().getNumTokens());
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Start, Stop & Pause
		
		/**
		 * Starts the timer.
		 */		
		public static function start():void
		{
			if(!_isRunning)
			{
				_isRunning = true;
				
				// calculate the number of seconds until the end of the day
				var nowInFrance:Date = Utilities.getLocalFrenchDate();
				_totalTime = (NUM_SECONDS_IN_A_DAY - (nowInFrance.hours * 60 * 60) - (nowInFrance.minutes * 60) - nowInFrance.seconds) * 1000;
				_previousTime = getTimer();
				Starling.current.stage.addEventListener(Event.ENTER_FRAME, update);
			}
		}
		
		/**
		 * Stops the timer.
		 */		
		public static function stop():void
		{
			if(_isRunning)
			{
				_isRunning = false;
				
				Starling.current.stage.removeEventListener(Event.ENTER_FRAME, update);
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Update function
		
		/**
		 * Main update function.
		 */		
		private static function update(event:Event):void
		{
			// calculate the elapsed time
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
					// timer is over, stop everything, request stakes, and then update the fields
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
		 * <p>The functions must have this signature :<br /> myFunction(valueToDisplay:String):void { }</p>
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
		
//------------------------------------------------------------------------------------------------------------
//	Getters / Setters
		
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
			if( MemberManager.getInstance().getNumTokens() == 0 )
			{
				IS_TIMER_OVER_AND_REQUEST_FAILED = true;
				valueToDisplay = "???";
			}
			else
			{
				IS_TIMER_OVER_AND_REQUEST_FAILED = false;
				valueToDisplay = "" + MemberManager.getInstance().getNumTokens();
			}
		}
		
	}
}