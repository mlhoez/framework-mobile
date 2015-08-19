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
	import com.ludofactory.mobile.core.AbstractGameInfo;
	import com.ludofactory.mobile.core.controls.AdvancedScreen;
	import com.ludofactory.mobile.core.manager.MemberManager;
	import com.ludofactory.mobile.core.remoting.Remote;
	
	import feathers.controls.List;
	import feathers.controls.Scroller;
	import feathers.data.ListCollection;
	
	/**
	 * Screen displaying the in-game trophies.
	 */	
	public class TrophyScreen extends AdvancedScreen
	{
		/**
		 * List containing all trophies for this game.
		 */
		private var _trophiesList:List;
		
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
			_trophiesList.dataProvider = new ListCollection( AbstractGameInfo.CUPS );
			_trophiesList.scrollBarDisplayMode = Scroller.SCROLL_BAR_DISPLAY_MODE_FLOAT;
			_trophiesList.verticalScrollPolicy = Scroller.SCROLL_POLICY_AUTO;
			_trophiesList.horizontalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			addChild(_trophiesList);
			
			AbstractEntryPoint.alertData.numTrophiesAlerts = 0;
			if( MemberManager.getInstance().isLoggedIn() && AirNetworkInfo.networkInfo.isConnected() )
				Remote.getInstance().initTrophies(null, null, null, 2, advancedOwner.activeScreenID);
		}
		
		override protected function draw():void
		{
			if( isInvalid(INVALIDATION_FLAG_SIZE) )
			{
				super.draw();
				
				_trophiesList.width = this.actualWidth;
				_trophiesList.height = this.actualHeight;
				
				scrollToLastWonTrophy();
			}
		}
		
		/**
		 * Automatically scrolls to the last trophy won by the player.
		 */
		private function scrollToLastWonTrophy():void
		{
			for(var i:int = 0; i < _trophiesList.dataProvider.length; i++)
			{
				if( TrophyData(_trophiesList.dataProvider.getItemAt(i)).id == MemberManager.getInstance().getLastTrophyWonId() )
				{
					_trophiesList.scrollToDisplayIndex(i);
					break;
				}
			}
			MemberManager.getInstance().setLastTrophyWonId(-1);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
		
		override public function dispose():void
		{
			_trophiesList.removeFromParent(true);
			_trophiesList = null;
			
			super.dispose();
		}
	}
}