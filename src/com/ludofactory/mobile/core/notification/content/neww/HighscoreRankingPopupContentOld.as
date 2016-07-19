/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 1 septembre 2013
*/
package com.ludofactory.mobile.core.notification.content.neww
{
	
	import com.freshplanet.nativeExtensions.AirNetworkInfo;
	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractGameInfo;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.manager.MemberManager;
	import com.ludofactory.mobile.core.notification.CustomPopupManager;
	import com.ludofactory.mobile.core.notification.content.*;
	import com.ludofactory.mobile.core.remoting.Remote;
	import com.ludofactory.mobile.core.theme.Theme;
	import com.ludofactory.mobileNew.core.achievements.TrophyData;
	import com.ludofactory.mobileNew.core.achievements.TrophyItemRenderer;
	import com.ludofactory.mobileNew.core.achievements.TrophyManager;
	
	import feathers.controls.List;
	import feathers.controls.Scroller;
	import feathers.data.ListCollection;
	
	import starling.core.Starling;
	import starling.display.MovieClip;
	import starling.text.TextField;
	import starling.text.TextFieldAutoSize;
	import starling.text.TextFormat;
	
	public class HighscoreRankingPopupContentOld extends AbstractPopupContent
	{
		/**
		 * Flag to indicate that the trophies list data provider have been updated. */
		public static const INVALIDATION_FLAG_TROPHIES:String = "trophies";
		
		/**
		 * The title. */		
		private var _notificationTitle:TextField;
		
		/**
		 * List containing all trophies for this game. */
		private var _highscoreList:List;
		
		/**
		 * The loader. */
		private var _loader:MovieClip;
		
		public function HighscoreRankingPopupContentOld()
		{
			super();
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			// TODO add the Game Center button here
			
			data = false;
			
			_notificationTitle = new TextField(10, scaleAndRoundToDpi(50), _("Meilleurs scores"), new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(50), Theme.COLOR_DARK_GREY));
			_notificationTitle.autoScale = AbstractGameInfo.LANDSCAPE;
			_notificationTitle.autoSize = AbstractGameInfo.LANDSCAPE ? TextFieldAutoSize.NONE : TextFieldAutoSize.VERTICAL;
			addChild(_notificationTitle);
			
			_highscoreList = new List();
			_highscoreList.isSelectable = false;
			_highscoreList.itemRendererType = TrophyItemRenderer;
			_highscoreList.scrollBarDisplayMode = Scroller.SCROLL_BAR_DISPLAY_MODE_FLOAT;
			_highscoreList.verticalScrollPolicy = Scroller.SCROLL_POLICY_AUTO;
			_highscoreList.horizontalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			addChild(_highscoreList);
			
			//AbstractEntryPoint.alertData.numTrophiesAlerts = 0;
			if( AirNetworkInfo.networkInfo.isConnected() )
			{
				_loader = new MovieClip( Theme.blackLoaderTextures );
				_loader.scaleX = _loader.scaleY = GlobalConfig.dpiScale;
				_loader.alignPivot();
				Starling.juggler.add( _loader );
				addChild(_loader);
				
				if( MemberManager.getInstance().isLoggedIn() )
					Remote.getInstance().initTrophies(null, null, null, 2, "amodifier"); // TODO à modifier
				Remote.getInstance().getTrophies(onGetTrophiesSuccess, onGetTrophiesFail, onGetTrophiesFail, 2, "amodifier"); // TODO à modifier
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
				_notificationTitle.width = this.actualWidth;
				
				if (_loader)
				{
					_loader.x = this.actualWidth * 0.5;
					_loader.y = CustomPopupManager.maxContentHeight * 0.5;
				}
				
				_highscoreList.y = _notificationTitle.y + _notificationTitle.height;
				_highscoreList.width = this.actualWidth;
				_highscoreList.height = CustomPopupManager.maxContentHeight - _highscoreList.y;
			}
			
			if(isInvalid(INVALIDATION_FLAG_TROPHIES))
				scrollToLastWonTrophy();
			
			super.draw();
		}
		
//------------------------------------------------------------------------------------------------------------
//	Handlers
		
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
			
			_highscoreList.dataProvider = new ListCollection( TrophyManager.getInstance().trophiesData );
			invalidate(INVALIDATION_FLAG_TROPHIES);
		}
		
		/**
		 * Automatically scrolls to the last trophy won by the player.
		 */
		private function scrollToLastWonTrophy():void
		{
			if(_highscoreList.dataProvider)
			{
				for(var i:int = 0; i < _highscoreList.dataProvider.length; i++)
				{
					if( TrophyData(_highscoreList.dataProvider.getItemAt(i)).id == MemberManager.getInstance().lastTrophyWonId )
					{
						_highscoreList.scrollToDisplayIndex(i);
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
			_notificationTitle.removeFromParent(true);
			_notificationTitle = null;
			
			super.dispose();
		}
	}
}