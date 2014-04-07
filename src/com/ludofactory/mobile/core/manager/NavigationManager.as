/*
Copyright © 2006-2014 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 27 oct. 2013
*/
package com.ludofactory.mobile.core.manager
{
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.controls.ScreenIds;
	
	/**
	 * The BackManager handles the way the navigation is done within
	 * the application.
	 */	
	public class NavigationManager
	{
		/**
		 * List of screens. */		
		private static var _screens:Array = [];
		
		/**
		 * The current back screen id. */		
		private static var _backScreenId:String;
		
//------------------------------------------------------------------------------------------------------------
//	Static functions
		
		/**
		 * Adds a screen id to the list.
		 * 
		 * <p>If the screens is already the last one added in the list,
		 * nothing will be done to avoid duplicate screens.</p>
		 */		
		public static function addScreenId(screenName:String):void
		{
			if( screenName == ScreenIds.HOME_SCREEN )
				_screens = [];
			
			if( _screens.length > 0 && _screens.indexOf(screenName) == (_screens.length - 1) )
				return;
			
			_screens.push( screenName );
		}
		
		/**
		 * Returns the previous screen id.
		 */		
		public static function getBackScreenId(currentScreenId:String):String
		{
			if( _screens.length == 1 )
			{
				_backScreenId = _screens.pop();
			}
			else
			{
				if( _screens.indexOf(currentScreenId) == (_screens.length - 1) )
					_screens.pop();
				_backScreenId = _screens.pop();
			}
			
			if( _screens.length == 0 )
				_screens.push( ScreenIds.HOME_SCREEN );
			
			if( _backScreenId == AbstractEntryPoint.screenNavigator.activeScreenID )
				_backScreenId = ScreenIds.HOME_SCREEN;
			
			return _backScreenId;
		}
		
		/**
		 * Resets the list of screens, adding the home screen and then the
		 * menu by default.
		 * 
		 * <p>This function is called by the FreeGameEndScreen, TournamentEndScreen
		 * and Menu.</p>
		 */		
		public static function resetNavigation(addMenu:Boolean = true):void
		{
			_screens = [];
			_screens.push( ScreenIds.HOME_SCREEN );
			if( addMenu )
				_screens.push( ScreenIds.SHOW_MENU );
		}
		
	}
}