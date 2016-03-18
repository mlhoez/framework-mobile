/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 13 Juin 2013
*/
package com.ludofactory.mobile.core.controls
{
	
	import com.ludofactory.mobile.core.manager.InfoContent;
	import com.ludofactory.mobile.core.manager.InfoManager;
	import com.ludofactory.mobile.core.notification.CustomPopupManager;
	import com.ludofactory.mobile.core.remoting.Remote;
	import com.ludofactory.newClasses.Analytics;
	
	import feathers.controls.Screen;
	
	import starling.display.Quad;
	
	/**
	 * A more advanced screen that handles the tracking of the navigation (with
	 * Google Analytics and Flox) and the disposal of remote call when it is 
	 * disposed.
	 */	
	public class AdvancedScreen extends Screen
	{
		/**
		 * Transparent quad used to help draging the screen back to the right when the push elements are displayed. */
		private var _touchQuad:Quad;
		
		public function AdvancedScreen()
		{
			super();
		}
		
		override protected function initialize():void
		{
			_touchQuad = new Quad(500, 500, 0x0000ff);
			_touchQuad.alpha = 0;
			addChildAt(_touchQuad, 0);
			
			// track screens with Google Analytics
			Analytics.trackScreen(screenID);
			
			this.backButtonHandler = onBack;
		}
		
		override protected function draw():void
		{
			super.draw();
			
			_touchQuad.width = actualWidth;
			_touchQuad.height = actualHeight;
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
			if( CustomPopupManager.isNotificationDisplaying )
			{
				CustomPopupManager.closePopup();
				return;
			}

			InfoManager.hide("", InfoContent.ICON_NOTHING, 0); // just in case
			
			if( _canBack )
				advancedOwner.showBackScreen();
		}
		
//------------------------------------------------------------------------------------------------------------
//	Get / Set
		
		
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
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
		
		override public function dispose():void
		{
			_touchQuad.removeFromParent(true);
			_touchQuad = null;
			
			super.dispose();
		}
		
	}
}