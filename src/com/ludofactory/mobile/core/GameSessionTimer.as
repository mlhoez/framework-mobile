/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 16 avr. 2014
*/
package com.ludofactory.mobile.core
{
	
	import com.freshplanet.nativeExtensions.AirNetworkInfo;
	import com.ludofactory.ane.DeviceUtils;
	import com.ludofactory.common.utils.Utilities;
	import com.ludofactory.common.utils.log;
	import com.ludofactory.mobile.core.manager.MemberManager;
	import com.ludofactory.mobile.core.remoting.Remote;
	
	/**
	 * A global timer used to display the time before the tokens gets updated.
	 */	
	public class GameSessionTimer
	{
		/**
		 * Time in seconds for new tokens when not authenticated. */
		private static const TIME_FOR_NEW_TOKENS_NOT_AUTHENTICATED_STEP_1:int = 1200; // 1200 - 20 min
		private static const TIME_FOR_NEW_TOKENS_NOT_AUTHENTICATED_STEP_2:int = 2400; // 2400 - 40 min
		/**
		 * How many tokens to give when the timer is over. */
		public static const NUM_TOKENS_ADDED_WHEN_TIMER_OVER:int = 50;
		
		/**
		 * Number of seconds in a day. */		
		private static const NUM_SECONDS_IN_A_DAY:int = 86400;
		
		private static const ONE_SECOND:int = 500;
		
		private static var _labelUpdateFunction:Function = null;
		
		
		
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
		 * This function should be called whenever the number of free game sessions change and when a user log in / out.
		 * 
		 * <p>It will update the state of the GameSessionTimer in order to display the correct number of free game sessions
		 * or the timer if there are no more and the user is logged in.
		 */		
		public static function updateState():void
		{
			if( MemberManager.getInstance().isLoggedIn() )
			{
				if( MemberManager.getInstance().tokens <= 0 )
				{
					// no more free game session then start the timer
					start();
				}
				else
				{
					stop();
				}
			}
			else
			{
				// no more free game session then start the timer
				if( !MemberManager.getInstance().anonymousGameSessionsAlreadyUsed && MemberManager.getInstance().tokens < 50 )
				{
					start();
				}
				else
				{
					stop();
				}
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
				
				// FIXME MODIF TOURNOI condition rajoutée
				if(MemberManager.getInstance().isLoggedIn())
				{
					// calculate the number of seconds until the end of the day
					var nowInFrance:Date = Utilities.getLocalFrenchDate();
					_totalTime = (NUM_SECONDS_IN_A_DAY - (nowInFrance.hours * 60 * 60) - (nowInFrance.minutes * 60) - nowInFrance.seconds) * 1000;
					HeartBeat.registerFunction(update);
				}
				else
				{
					if(isNaN(MemberManager.getInstance().bootTime))
					{
						// no boot time saved yet
						// should not happen
						//MemberManager.getInstance().bootTime = DeviceUtils.getInstance().getBootTime(); // TODO a checker
						//MemberManager.getInstance().tokenDate = DeviceUtils.getInstance().getBootTime(); // TODO a checker
						stop();
					}
					else
					{
						log("Boot time (ANE) = " + DeviceUtils.getInstance().getBootTime());
						log("Boot time (member) = " + MemberManager.getInstance().bootTime);
						
						var elapsedTimeInSeconds:int;
						if(DeviceUtils.getInstance().getBootTime() < MemberManager.getInstance().bootTime)
						{
							// the current boot time is lower than the saved one, this means that the device must
							// have been rebooted in the meantime. In this case we cannot calculate precisely the
							// elasped time so we need to base our calculation one the saved date and the current date
							
							// get the elapsed time in seconds
							var currentDate:Date = new Date();
							elapsedTimeInSeconds = ((currentDate.time - MemberManager.getInstance().tokenDate.time) / 1000) << 0;
						}
						else
						{
							// get the elapsed time in seconds
							elapsedTimeInSeconds = DeviceUtils.getInstance().getBootTime() - MemberManager.getInstance().bootTime;
						}
						
						var timeToWait:int = (MemberManager.getInstance().numRecreditations <= 0 ? TIME_FOR_NEW_TOKENS_NOT_AUTHENTICATED_STEP_2 : TIME_FOR_NEW_TOKENS_NOT_AUTHENTICATED_STEP_1);
						
						// now we calculate how many tokens can be granted according to the elapsed time
						var numTokensToGrant:int = ((elapsedTimeInSeconds / timeToWait) << 0) * NUM_TOKENS_ADDED_WHEN_TIMER_OVER;
						
						log("[GameSessionTimer] " + elapsedTimeInSeconds + " elapsed since the last launch, now granting " + numTokensToGrant + " tokens.");
						
						// we know how many tokens to grant
						if(numTokensToGrant > 0)
						{
							if((MemberManager.getInstance().tokens + numTokensToGrant) > 50 )
								numTokensToGrant = 50 - MemberManager.getInstance().tokens; // don't give more than 50
							
							MemberManager.getInstance().numRecreditations--;
							log("Nombre de recréditations : " + MemberManager.getInstance().numRecreditations);
							MemberManager.getInstance().tokens += numTokensToGrant;
							valueToDisplay = "" + MemberManager.getInstance().tokens;
							log("[GameSessionTimer] " + numTokensToGrant + " have been granted.");
							stop();
						}
						else
						{
							// not enough passed time to grant the tokens, here we need to calculate the time needed
							// to grant the tokens
							_totalTime = ONE_SECOND;
							_realTime = (1 - (elapsedTimeInSeconds / timeToWait)) * timeToWait;
							log("[GameSessionTimer] Real time is : " + _realTime + ". Now launching the timer...");
							_previousBootTime = DeviceUtils.getInstance().getBootTime();
							HeartBeat.registerFunction(updateWhenNotAuthenticated);
						}
					}
				}
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
				HeartBeat.unregisterFunction(update);
				HeartBeat.unregisterFunction(updateWhenNotAuthenticated);
				MemberManager.getInstance().bootTime = NaN;
				MemberManager.getInstance().tokenDate = null;
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Update function
		
		/**
		 * Main update function.
		 */		
		private static function update(frameElapsedTime:int, totalElapsedTime:int):void
		{
			// calculate the elapsed time
			_totalTime -= totalElapsedTime;
			
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
					
					valueToDisplay = "00:00";
				}
			//}
		}
		
		private static var _realTime:int;
		private static var _previousBootTime:Number;
		/**
		 * Main update function.
		 */
		private static function updateWhenNotAuthenticated(frameElapsedTime:int, totalElapsedTime:int):void
		{
			// calculate the elapsed time
			_totalTime -= totalElapsedTime;
			
			// every second, we check the elapsed time
			if( _totalTime < 0 )
			{
				_totalTime = ONE_SECOND;
				var delta:int = DeviceUtils.getInstance().getBootTime() - _previousBootTime;
				if(delta > 0)
				{
					_realTime -= delta;
					_previousBootTime = DeviceUtils.getInstance().getBootTime();
				}
				
				if( _realTime > 0 )
				{
					//log("[GameSessionTimer] + " + _realTime + " seconds left.");
					
					// still in loop
					_h = Math.round(_realTime) / 3600;
					_m = (Math.round(_realTime) / 60) % 60;
					_s = Math.round(_realTime) % 60;
					
					valueToDisplay = (_m < 10 ? "0":"") + _m + ":" + (_s < 10 ? "0":"") + _s;
				}
				else
				{
					log("[GameSessionTimer] Timer is over, now granting " + NUM_TOKENS_ADDED_WHEN_TIMER_OVER + " tokens");
					
					// timer is over, stop everything, request stakes, and then update the fields
					stop();
					
					MemberManager.getInstance().numRecreditations--;
					log("Nombre de recréditations : " + MemberManager.getInstance().numRecreditations);
					MemberManager.getInstance().tokens += NUM_TOKENS_ADDED_WHEN_TIMER_OVER;
					
					valueToDisplay = "" + MemberManager.getInstance().tokens;
				}
			}
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
		
		public static function get isRunning():Boolean
		{
			return _isRunning;
		}
		
//------------------------------------------------------------------------------------------------------------
//	Getters / Setters
		
		public static function set valueToDisplay(val:String):void
		{
			_valueToDisplay = val;
			//for each(_helperFunction in _listenersList)
			//	_helperFunction(_valueToDisplay);
			_labelUpdateFunction(_valueToDisplay);
		}
		
		
		public static function set labelUpdateFunction(value:Function):void
		{
			_labelUpdateFunction = value;
		}
		
		
		public static function get valueToDisplay():String
		{
			return _valueToDisplay;
		}
		
//------------------------------------------------------------------------------------------------------------
//	Update callback
		
		/**
		 * When the stakes have been updated.
		 */		
		private static function onStakesUpdated(result:Object = null):void
		{
			if( MemberManager.getInstance().tokens == 0 )
			{
				IS_TIMER_OVER_AND_REQUEST_FAILED = true;
				valueToDisplay = "???";
			}
			else
			{
				IS_TIMER_OVER_AND_REQUEST_FAILED = false;
				valueToDisplay = "" + MemberManager.getInstance().tokens;
			}
		}
		
	}
}