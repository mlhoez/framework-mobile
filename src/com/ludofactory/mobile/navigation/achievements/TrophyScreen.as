/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 31 août 2013
*/
package com.ludofactory.mobile.navigation.achievements
{
	
	import com.freshplanet.nativeExtensions.AirNetworkInfo;
	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.controls.AdvancedScreen;
	import com.ludofactory.mobile.core.manager.MemberManager;
	import com.ludofactory.mobile.core.remoting.Remote;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import feathers.controls.List;
	import feathers.controls.Scroller;
	import feathers.data.ListCollection;
	
	import starling.core.Starling;
	import starling.display.MovieClip;
	
	/**
	 * Screen displaying the in-game trophies.
	 */	
	public class TrophyScreen extends AdvancedScreen
	{
		/**
		 * Flag to indicate that the trophies list data provider have been updated. */
		public static const INVALIDATION_FLAG_TROPHIES:String = "trophies";
		
		/**
		 * List containing all trophies for this game. */
		private var _trophiesList:List;
		
		/**
		 * The loader. */
		private var _loader:MovieClip;
		
		public function TrophyScreen()
		{
			super();
			
			_whiteBackground = true;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			_headerTitle = _("Coupes");
			
			_trophiesList = new List();
			_trophiesList.isSelectable = false;
			_trophiesList.itemRendererType = TrophyItemRenderer;
			_trophiesList.scrollBarDisplayMode = Scroller.SCROLL_BAR_DISPLAY_MODE_FLOAT;
			_trophiesList.verticalScrollPolicy = Scroller.SCROLL_POLICY_AUTO;
			_trophiesList.horizontalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			addChild(_trophiesList);
			
			AbstractEntryPoint.alertData.numTrophiesAlerts = 0;
			if( AirNetworkInfo.networkInfo.isConnected() )
			{
				_loader = new MovieClip( Theme.blackLoaderTextures );
				_loader.scaleX = _loader.scaleY = GlobalConfig.dpiScale;
				_loader.alignPivot();
				Starling.juggler.add( _loader );
				addChild(_loader);
				
				if( MemberManager.getInstance().isLoggedIn() )
					Remote.getInstance().initTrophies(null, null, null, 2, advancedOwner.activeScreenID);
				Remote.getInstance().getTrophies(onGetTrophiesSuccess, onGetTrophiesFail, onGetTrophiesFail, 2, advancedOwner.activeScreenID);
			}
			else
			{
				initializeTrophies();
			}
		}
		
		override protected function draw():void
		{
			if( isInvalid(INVALIDATION_FLAG_SIZE) )
			{
				_trophiesList.width = this.actualWidth;
				_trophiesList.height = this.actualHeight;
				
				if( _loader )
				{
					_loader.x = this.actualWidth * 0.5;
					_loader.y = this.actualHeight * 0.5;
				}
			}
			
			if(isInvalid(INVALIDATION_FLAG_TROPHIES))
				scrollToLastWonTrophy();
			
			super.draw();
		}
		
//------------------------------------------------------------------------------------------------------------
//	
		
		/**
		 * The trophies have been successfully fetched from the server, in this case we can update then in the
		 * local storage and then initialize the list.
		 * 
		 * @param result
		 */
		private function onGetTrophiesSuccess(result:Object):void
		{
			// replace the stored trophies : we must replace it and not simply update because we may need to remove
			// some trophies at some time
			if( result.hasOwnProperty("tab_trophies") && result.tab_trophies != null )
				TrophyManager.getInstance().updateTrophies(result.tab_trophies as Array);
			initializeTrophies();
		}
		
		/**
		 * The trophies could not be updated, in this case we simply initialize the list with what we've stored
		 * previously in the local storage.
		 * 
		 * @param error
		 */
		private function onGetTrophiesFail(error:Object = null):void
		{
			initializeTrophies();
		}
		
		/**
		 * Called when the trophies have successfully been updated or when there is no network.
		 */
		private function initializeTrophies():void
		{
			if(_loader)
			{
				Starling.juggler.remove( _loader );
				_loader.removeFromParent(true);
				_loader = null;
			}
			
			_trophiesList.dataProvider = new ListCollection( TrophyManager.getInstance().trophiesData );
			invalidate(INVALIDATION_FLAG_TROPHIES);
		}
		
		/**
		 * Automatically scrolls to the last trophy won by the player.
		 */
		private function scrollToLastWonTrophy():void
		{
			if(_trophiesList.dataProvider)
			{
				for(var i:int = 0; i < _trophiesList.dataProvider.length; i++)
				{
					if( TrophyData(_trophiesList.dataProvider.getItemAt(i)).id == MemberManager.getInstance().lastTrophyWonId )
					{
						_trophiesList.scrollToDisplayIndex(i);
						break;
					}
				}
				MemberManager.getInstance().lastTrophyWonId = -1;
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
		
		override public function dispose():void
		{
			if( _loader )
			{
				Starling.juggler.remove( _loader );
				_loader.removeFromParent(true);
				_loader = null;
			}
			
			_trophiesList.removeFromParent(true);
			_trophiesList = null;
			
			super.dispose();
		}
	}
}