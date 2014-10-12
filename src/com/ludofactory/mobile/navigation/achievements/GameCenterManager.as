/*
Copyright © 2006-2014 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 4 sept. 2012
*/
package com.ludofactory.mobile.navigation.achievements
{
	import com.ludofactory.common.utils.log;
	import com.ludofactory.mobile.core.events.LudoEventType;
	import com.milkmangames.nativeextensions.ios.GameCenter;
	import com.milkmangames.nativeextensions.ios.events.GameCenterErrorEvent;
	import com.milkmangames.nativeextensions.ios.events.GameCenterEvent;
	
	import starling.events.EventDispatcher;
	
	public class GameCenterManager
	{
		/**
		 * Whether the Game Center is available. */		
		public static var available:Boolean = false;
		private static var _dispatcher:EventDispatcher;
		
//------------------------------------------------------------------------------------------------------------
//	Authenticate
		
		/**
		 * Initializes the Game Center. This function should be called once and at runtime.
		 */		
		public static function initialize(showBanners:Boolean = false):void
		{
			if( !GameCenter.isSupported() )
			{
				log("[GameCenterManager] Game Center is not supported on this platform.");
				available = false;
				return;
			}
			
			try
			{
				GameCenter.create();
			} 
			catch(error:Error) 
			{
				
			}
			
			// check os level support : this is necessary because Game Center only works on iOS versions > 4.1
			if( !GameCenter.gameCenter.isGameCenterAvailable() )
			{
				log("[GameCenterManager] This iOS version does not support Game Center.");
				available = false;
				return;
			}
			
			if( GameCenter.gameCenter.areBannersAvailable() )
				GameCenter.gameCenter.showAchievementBanners( showBanners );
			
			available = true;
		}
		
		/**
		 * Authenticates the user in the Game Center.
		 */		
		public static function authenticateUser():void
		{
			if( available )
			{
				if( GameCenter.gameCenter.isUserAuthenticated() )
				{
					onAuthenticationSuccess();
				}
				else
				{
					GameCenter.gameCenter.addEventListener(GameCenterEvent.AUTH_SUCCEEDED, onAuthenticationSuccess);
					GameCenter.gameCenter.addEventListener(GameCenterErrorEvent.AUTH_FAILED, onAuthenticationFailure);
					GameCenter.gameCenter.authenticateLocalUser();
				}
			}
		}
		
		/**
		 * User is logged in.
		 */		
		private static function onAuthenticationSuccess(event:GameCenterEvent = null):void
		{
			GameCenter.gameCenter.removeEventListener(GameCenterEvent.AUTH_SUCCEEDED, onAuthenticationSuccess);
			GameCenter.gameCenter.removeEventListener(GameCenterErrorEvent.AUTH_FAILED, onAuthenticationFailure);
			dispatcher.dispatchEventWith(LudoEventType.GAME_CENTER_AUTHENTICATION_SUCCESS);
		}
		
		/**
		 * User is NOT logged in.
		 * 
		 * <p>Error ID n°1009 = no internet connection.</p>
		 * <p>Error ID n°2 = operation cancelled or deactivated.</p>
		 */		
		private static function onAuthenticationFailure(event:GameCenterErrorEvent):void
		{
			GameCenter.gameCenter.removeEventListener(GameCenterEvent.AUTH_SUCCEEDED, onAuthenticationSuccess);
			GameCenter.gameCenter.removeEventListener(GameCenterErrorEvent.AUTH_FAILED, onAuthenticationFailure);
			dispatcher.dispatchEventWith(LudoEventType.GAME_CENTER_AUTHENTICATION_FAILURE);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Leaderboard
		
		/**
		 * Shows the leaderboard with the specified id.
		 * 
		 * @param leaderboardId The leaderboard id registered in iTunes Connect.
		 */		
		public static function showLeaderboard(leaderboardId:String):void
		{
			if( !available )
				return;
			
			GameCenter.gameCenter.showLeaderboardForCategory(leaderboardId);
		}
		
		public static function reportLeaderboardScore(leaderboardId:String, score:int):void
		{
			if( !available )
				return;
			
			GameCenter.gameCenter.reportScoreForCategory(score, leaderboardId);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Achievements
		
		/**
		 * Shows the achievements with the native ui.
		 */		
		public static function showAchievements():void
		{
			if( !available )
				return;
			
			GameCenter.gameCenter.showAchievements();
		}
		
		/**
		 * Reports an achievement.
		 * 
		 * @param achievementId The achievement id registered in iTunes Connect.
		 * @param value A Number from 0.0 to 100.0, representing the percentage to which this achievement has been completed
		 */		
		public static function reportAchievement(achievementId:String, value:Number = 100.0):void
		{
			if( !available )
				return;
			
			GameCenter.gameCenter.reportAchievement(achievementId, value);
		}
		
		/**
		 * Resets the achievements.
		 */		
		public static function resetAchievements():void
		{
			if( !available )
				return;
			
			GameCenter.gameCenter.resetAchievements();
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispatcher
		
		public static function get dispatcher():EventDispatcher
		{
			if( !_dispatcher )
				_dispatcher = new EventDispatcher();
			return _dispatcher;
		}
		
	}
}