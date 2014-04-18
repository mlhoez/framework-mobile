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
	import com.ludofactory.mobile.core.events.LudoEventType;
	import com.ludofactory.mobile.core.remoting.Remote;
	
	import flash.utils.getTimer;

	/**
	 * A global timer used to display the time before the free game sessions gets updated.
	 */	
	public class GameSessionTimer
	{
		/**
		 * The vector of functions to call. */		
		private static var _listenersList:Vector.<Function> = new Vector.<Function>();
		
		/**
		 * Previous time (before the update). */		
		private static var _previousTime:Number;
		/**
		 * Elapsed time. */		
		private static var _elapsedTime:Number;
		/**
		 * Total time (in milliseconds). */		
		private static var _totalTime:Number;
		
		private static var _h:int;
		private static var _m:int;
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
		 * Called from Remote.
		 * 
		 * @see com.ludofactory.mobile.core.remoting.Remote
		 */		
		public function update():void
		{
			if( MemberManager.getInstance().isLoggedIn() )
			{
				if( MemberManager.getInstance().getNumFreeGameSessions() > 0 )
				{
					_valueToDisplay = "" + MemberManager.getInstance().getNumFreeGameSessions();
				}
				else
				{
					// no need to start the timer if no function registered...
					if( _listenersList.length > 0 )
						start();
				}
			}
			else
			{
				_valueToDisplay = "" + ( MemberManager.getInstance().isLoggedIn() ? (MemberManager.getInstance().getNumFreeGameSessions()) : (MemberManager.getInstance().getNumFreeGameSessions() == 0 ? "???" : MemberManager.getInstance().getNumFreeGameSessions()) );
			}
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
			start();
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
			if( _listenersList.length == 0 )
				stop();
		}
		
//------------------------------------------------------------------------------------------------------------
//	Start, Stop & Pause
		
		/**
		 * Starts the timer.
		 */		
		public static function start():void
		{
			// TODO checker s'il y a des fonctions enregistrées avant de faire le start ?
			
			
			// calculate the number of milliseconds until the end of the day
			var nowInFrance:Date = Utilities.getLocalFrenchDate();
			_totalTime = (86400 - (nowInFrance.hours * 60 * 60) - (nowInFrance.minutes * 60) - nowInFrance.seconds) * 1000;
			_previousTime = getTimer();
			
			// update labels
			// TODO
			
			HeartBeat.registerFunction(update);
		}
		
		/**
		 * Stops the timer.
		 */		
		public static function stop():void
		{
			HeartBeat.unregisterFunction(update);
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
		private static function update(elapsedTime:Number):void
		{
			_totalTime -= 1000;
			
			if( _totalTime > 0 )
			{
				// still in loop
				_h = Math.round(_totalTime / 1000) / 3600;
				_m = (Math.round(_totalTime / 1000) / 60) % 60;
				_s = Math.round(_totalTime / 1000) % 60;
				
				_valueToDisplay = (_h < 10 ? "0":"") + _h + ":" + (_m < 10 ? "0":"") + _m + ":" + (_s < 10 ? "0":"") + _s;
				
				for each(var func:Function in _listenersList)
					func(_valueToDisplay);
			}
			else
			{
				// timer is over, stop everything
				// request mises, and then update the summary
				
				
				stop();
				
				if( AirNetworkInfo.networkInfo.isConnected() )
				{
					Remote.getInstance().updateMises(onStakesUpdated, onStakesUpdated, onStakesUpdated, 1);
				}
				else
				{
					_valueToDisplay = "00:00:00";
					
					for each(var func:Function in _listenersList)
						func(_valueToDisplay);
				}
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Update callback
		
		/**
		 * When the stakes have been updated.
		 */		
		private static function onStakesUpdated(result:Object = null):void
		{
			// TODO Gérer ce cas...
			//if( MemberManager.getInstance().getNumFreeGameSessions() == 0 )
			//	IS_TIMER_OVER_AND_REQUEST_FAILED = true;
			//else
			//	IS_TIMER_OVER_AND_REQUEST_FAILED = false;
			
			_valueToDisplay = "" + MemberManager.getInstance().getNumFreeGameSessions();
			
			for each(var func:Function in _listenersList)
				func(_valueToDisplay);
		}
		
	}
}