/*
Copyright © 2006-2016 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 13 Juin 2013
*/
package com.ludofactory.mobile.core.controls
{
	
	import com.ludofactory.mobile.core.manager.InfoManager;
	import com.ludofactory.mobile.core.notification.CustomPopupManager;
	import com.ludofactory.mobile.core.remoting.Remote;
	import com.ludofactory.newClasses.Analytics;
	
	import feathers.controls.Screen;
	
	/**
	 * A more advanced screen that handles the tracking of the navigation (with Google Analytics)
	 * and the cancellation of the asociated remote calls when it is disposed.
	 */	
	public class AdvancedScreen extends Screen
	{
		/**
		 * Whether the user can back while on this screen. */
		protected var _canBack:Boolean = true;
		
		public function AdvancedScreen()
		{
			super();
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			// track screens with Google Analytics
			Analytics.trackScreen(screenID);
			
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
			// close any popup by security
			if(CustomPopupManager.isNotificationDisplaying)
			{
				CustomPopupManager.closePopup();
				return;
			}
			
			// also close all informations displaying on screen
			InfoManager.forceClose();
			
			// finally, check if the user can back (it may be locked for some reasons)
			if( _canBack )
				advancedOwner.showBackScreen();
		}
		
//------------------------------------------------------------------------------------------------------------
//	Get / Set
		
		public function set canBack(val:Boolean):void { _canBack = val; }
		public function get canBack():Boolean { return _canBack; }
		
		public function get advancedOwner():AdvancedScreenNavigator { return AdvancedScreenNavigator(this._owner); }
		
	}
}