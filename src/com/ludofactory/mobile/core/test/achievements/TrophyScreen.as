/*
Copyright © 2006-2014 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 31 août 2013
*/
package com.ludofactory.mobile.core.test.achievements
{
	import com.freshplanet.nativeExtensions.AirNetworkInfo;
	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.AbstractGameInfo;
	import com.ludofactory.mobile.core.authentication.MemberManager;
	import com.ludofactory.mobile.core.controls.AdvancedScreen;
	import com.ludofactory.mobile.core.remoting.Remote;
	
	import feathers.controls.List;
	import feathers.controls.Scroller;
	import feathers.data.ListCollection;
	
	/**
	 * Screen displaying the in-game trophies.
	 */	
	public class TrophyScreen extends AdvancedScreen
	{
		private var _list:List;
		
		public function TrophyScreen()
		{
			super();
			
			_whiteBackground = true;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			_headerTitle = _("Coupes");
			
			_list = new List();
			_list.isSelectable = false;
			_list.itemRendererType = TrophyItemRenderer;
			_list.dataProvider = new ListCollection( AbstractGameInfo.CUPS );
			_list.scrollBarDisplayMode = Scroller.SCROLL_BAR_DISPLAY_MODE_FLOAT;
			_list.verticalScrollPolicy = Scroller.SCROLL_POLICY_AUTO;
			_list.horizontalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			addChild(_list);
			
			AbstractEntryPoint.alertData.numTrophiesAlerts = 0;
			if( MemberManager.getInstance().isLoggedIn() && AirNetworkInfo.networkInfo.isConnected() )
				Remote.getInstance().initTrophies(null, null, null, 2, advancedOwner.activeScreenID);
		}
		
		override protected function draw():void
		{
			if( isInvalid(INVALIDATION_FLAG_SIZE) )
			{
				_list.width = this.actualWidth;
				_list.height = this.actualHeight;
				
				scrollToLastWonTrophy();
			}
		}
		
		private function scrollToLastWonTrophy():void
		{
			for(var i:int = 0; i < _list.dataProvider.length; i++)
			{
				if( TrophyData(_list.dataProvider.getItemAt(i)).id == MemberManager.getInstance().getLastTrophyWonId() )
				{
					_list.scrollToDisplayIndex(i);
					break;
				}
			}
			MemberManager.getInstance().setLastTrophyWonId(-1);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
//------------------------------------------------------------------------------------------------------------
		
		override public function dispose():void
		{
			_list.removeFromParent(true);
			_list = null;
			
			super.dispose();
		}
	}
}