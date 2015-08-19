/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 13 Juin 2013
*/
package com.ludofactory.mobile.core.controls
{
	
	import com.ludofactory.mobile.core.ScreenIds;
	import com.ludofactory.mobile.core.events.MobileEventTypes;
	import com.ludofactory.mobile.core.manager.NavigationManager;
	import com.ludofactory.mobile.core.model.ScreenData;
	import com.ludofactory.mobile.core.storage.Storage;
	import com.ludofactory.mobile.core.storage.StorageConfig;
	
	import feathers.controls.ScreenNavigator;
	import feathers.controls.ScreenNavigatorItem;
	
	import starling.display.DisplayObject;
	
	/**
	 * A more advanced screen navigator.
	 */	
	public class AdvancedScreenNavigator extends ScreenNavigator
	{
		/**
		 * Some data that can be used by the displayed screen. */		
		private var _screenData:ScreenData;
		
		/**
		 * Reference of the back screen id (avoid too much memory allocation) */		
		private var _backScreenId:String;
		
		public function AdvancedScreenNavigator()
		{
			super();
			
			_screenData = new ScreenData();
		}
		
		override public function showScreen(id:String, transition:Function = null):DisplayObject
		{
			// a new version have been released and must be forced
			if( Boolean(Storage.getInstance().getProperty(StorageConfig.PROPERTY_FORCE_UPDATE)) == true )
			{
				return super.showScreen(ScreenIds.UPDATE_SCREEN, transition);
			}
			else
			{
				NavigationManager.addScreenId( id );
				return super.showScreen(id, transition);
			}
		}
		
		public function showBackScreen():void
		{
			_backScreenId = NavigationManager.getBackScreenId( _activeScreenID );
			
			// a new version have been released and must be forced
			if( Boolean(Storage.getInstance().getProperty(StorageConfig.PROPERTY_FORCE_UPDATE)) == true )
			{
				super.showScreen(ScreenIds.UPDATE_SCREEN);
			}
			else
			{
				if( _backScreenId == ScreenIds.SHOW_MENU )
				{
					dispatchEventWith(MobileEventTypes.SHOW_MAIN_MENU, false, true);
				}
				else
				{
					if( _activeScreenID == _backScreenId )
					{
						dispatchEventWith(MobileEventTypes.HIDE_MAIN_MENU);
					}
					else
					{
						super.showScreen( _backScreenId );
					}
				}
				NavigationManager.addScreenId( _activeScreenID ); // FIXME A vérifier
			}
		}
		
		/**
		 * Add screens from array.
		 * 
		 * <p>All screens must have the following structure : { id:screenId, clazz:screenClass }</p>
		 * 
		 * @param screens
		 */		
		public function addScreensFromArray(screens:Array):void
		{
			var len:int = screens.length;
			for(var i:int = 0; i < len; i++)
				addScreen(screens[i].id, new ScreenNavigatorItem(screens[i].clazz));
		}
		
//------------------------------------------------------------------------------------------------------------
//	Get / Set
		
		public function get screenData():ScreenData
		{
			return _screenData;
		}
		
	}
}