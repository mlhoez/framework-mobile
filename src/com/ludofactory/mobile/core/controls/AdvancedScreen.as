/*
Copyright © 2006-2015 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 13 Juin 2013
*/
package com.ludofactory.mobile.core.controls
{
	import com.gamua.flox.Flox;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.manager.InfoContent;
	import com.ludofactory.mobile.core.manager.InfoManager;
	import com.ludofactory.mobile.core.notification.NotificationManager;
	import com.ludofactory.mobile.core.notification.NotificationPopupManager;
	import com.ludofactory.mobile.core.remoting.Remote;
	
	import eu.alebianco.air.extensions.analytics.Analytics;
	
	import feathers.controls.Screen;
	
	/**
	 * A more advanced screen that handles the tracking of the navigation (with
	 * Google Analytics and Flox) and the disposal of remote call when it is 
	 * disposed.
	 */	
	public class AdvancedScreen extends Screen
	{
		public function AdvancedScreen()
		{
			super();
		}
		
		override protected function initialize():void
		{
			// track screens with Google Analytics
			if( Analytics.isSupported() && AbstractEntryPoint.tracker )
				AbstractEntryPoint.tracker.buildView(screenID).track();
			
			// log the navigation in Flox
			Flox.logInfo("\t<strong>&rarr; " + screenID + "</strong>");
			
			this.backButtonHandler = onBack;
		}
		
		override public function set screenID(value:String):void
		{
			// if the value is nulled, it means that the screen have been disposed
			// in this case we can clear all the responders with this name before
			// it is been nulled
			if( value == null )
				Remote.getInstance().clearAllRespondersOfScreen( screenID );
			
			super.screenID = value;
		}
		
//------------------------------------------------------------------------------------------------------------
//	Android physical back button handler
		
		/**
		 * Called when the user presses the Android back button.
		 * 
		 * <p>The default behavior is to call the <code>showBackScreen</p> function
		 * of the <code>AdvancedScreenNavigator</code> (so the <code>advancedOwner</code>
		 * of the screen) which checks everything.</p>
		 * 
		 * <p>To replace this behavior, override this function in the subclass.</p>
		 */		
		public function onBack():void
		{
			if( NotificationManager.isNotificationDisplaying || NotificationPopupManager.isNotificationDisplaying )
			{
				NotificationManager.closeNotification();
				NotificationPopupManager.closeNotification();
				return;
			}

			InfoManager.hide("", InfoContent.ICON_NOTHING, 0); // just in case
			
			if( _canBack )
				advancedOwner.showBackScreen();
		}
		
//------------------------------------------------------------------------------------------------------------
//	Get / Set
		
		/**
		 * The title displayed in the header when this screen
		 * is displayed. */		
		protected var _headerTitle:String = "";
		
		public function get headerTitle():String
		{
			return this._headerTitle;
		}
		
		/**
		 * Whether the user can back while in this screen. */		
		protected var _canBack:Boolean = true;
		
		/**
		 * Only used by : ErrorDisplayer
		 */		
		public function set canBack(val:Boolean):void
		{
			_canBack = val;
		}
		
		public function get canBack():Boolean
		{
			return _canBack;
		}
		
		/**
		 * Returns the owner (AdvancedScreenNavigator).
		 */		
		public function get advancedOwner():AdvancedScreenNavigator
		{
			return this._owner as AdvancedScreenNavigator;
		}
		
		/**
		 * Whether this is a full screen. */		
		protected var _fullScreen:Boolean;
		
		public function get fullScreen():Boolean
		{
			return this._fullScreen;
		}
		
		/**
		 * Whether we need to use the white background. */		
		protected var _whiteBackground:Boolean = false;
		
		public function get whiteBackground():Boolean
		{
			return this._whiteBackground;
		}
		
		/**
		 * Whether we need to use the blue background. */		
		protected var _blueBackground:Boolean = false;
		
		public function get blueBackground():Boolean
		{
			return this._blueBackground;
		}
		
		/**
		 * Whether we need to use tha application's clear background. */		
		protected var _appClearBackground:Boolean = false;
		
		public function get appClearBackground():Boolean
		{
			return this._appClearBackground;
		}
		
		/**
		 * Whether we need to use the application's dark background. */		
		protected var _appDarkBackground:Boolean = false;
		
		public function get appDarkBackground():Boolean
		{
			return this._appDarkBackground;
		}
		
		/**
		 * Whether we need to use the "how to win gifts" background. */		
		protected var _howToWinGiftsBackground:Boolean = false;
		
		public function get howToWinGiftsBackground():Boolean
		{
			return this._howToWinGiftsBackground;
		}
		
		/**
		 * Whether the screen is in landscape mode. */		
		protected var _isLandscape:Boolean = false;
		
		public function get isLandscape():Boolean
		{
			return _isLandscape;
		}
		
	}
}