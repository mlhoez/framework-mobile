/*
Copyright © 2006-2014 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 8 sept. 2013
*/
package com.ludofactory.mobile.core.test.tournament
{
	import com.freshplanet.nativeExtensions.AirNetworkInfo;
	import com.greensock.TweenMax;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.AbstractGameInfo;
	import com.ludofactory.mobile.core.Localizer;
	import com.ludofactory.mobile.core.authentication.RetryContainer;
	import com.ludofactory.mobile.core.controls.AdvancedScreen;
	import com.ludofactory.mobile.core.controls.PullToRefreshList;
	import com.ludofactory.mobile.core.controls.ScreenIds;
	import com.ludofactory.mobile.core.events.LudoEventType;
	import com.ludofactory.mobile.core.manager.InfoContent;
	import com.ludofactory.mobile.core.manager.InfoManager;
	import com.ludofactory.mobile.core.remoting.Remote;
	import com.ludofactory.mobile.core.test.config.GlobalConfig;
	
	import feathers.data.ListCollection;
	
	import starling.display.Image;
	import starling.display.Quad;
	import starling.events.Event;
	
	public class PreviousTournamentsScreen extends AdvancedScreen
	{
		/**
		 * The logo. */		
		private var _logo:Image;
		
		/**
		 * The list shadow */		
		private var _listShadow:Quad;
		
		/**
		 * The previous tournament list. */		
		private var _list:PullToRefreshList;
		
		/**
		 * The retry container. */		
		private var _retryContainer:RetryContainer;
		
		public function PreviousTournamentsScreen()
		{
			super();
			
			_whiteBackground = true;
			_appClearBackground = false;
			_fullScreen = false;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			_headerTitle = Localizer.getInstance().translate("PREVIOUS_TOURNAMENT.HEADER_TITLE");
			
			if( !AbstractGameInfo.LANDSCAPE )
			{
				_logo = new Image( AbstractEntryPoint.assets.getTexture( "menu-icon-tournaments" ) );
				_logo.scaleX = _logo.scaleY = GlobalConfig.dpiScale;
				addChild( _logo );
				
				_listShadow = new Quad(50, scaleAndRoundToDpi(12), 0x000000);
				_listShadow.setVertexColor(0, 0xffffff);
				_listShadow.setVertexAlpha(0, 0);
				_listShadow.setVertexColor(1, 0xffffff);
				_listShadow.setVertexAlpha(1, 0);
				_listShadow.setVertexAlpha(2, 0.1);
				_listShadow.setVertexAlpha(3, 0.1);
				addChild(_listShadow);
			}
			
			_list = new PullToRefreshList();
			_list.isSelectable = false;
			_list.backgroundSkin = new Quad(50, 50);
			_list.addEventListener(Event.CHANGE, onPreviousTournamentSelected);
			_list.addEventListener(LudoEventType.REFRESH_TOP, onRefreshTop);
			_list.itemRendererType = PreviousTournamentItemRenderer;
			addChild(_list);
			
			_retryContainer = new RetryContainer();
			_retryContainer.addEventListener(Event.TRIGGERED, onRetry);
			addChild(_retryContainer);
			
			if( AirNetworkInfo.networkInfo.isConnected() )
			{
				Remote.getInstance().getPreviousTournaments(onGetPreviousTournamentsSuccess, onGetPreviousTournamentsFailure, onGetPreviousTournamentsFailure, 2, advancedOwner.activeScreenID);
			}
			else
			{
				_retryContainer.loadingMode = false;
			}
		}
		
		override protected function draw():void
		{
			if( isInvalid(INVALIDATION_FLAG_SIZE) )
			{
				if( !AbstractGameInfo.LANDSCAPE )
				{
					_logo.x = (actualWidth - _logo.width) * 0.5;
					_logo.y = scaleAndRoundToDpi( GlobalConfig.isPhone ? 10 : 20 );
					
					_listShadow.y = _logo.y + _logo.height + scaleAndRoundToDpi( GlobalConfig.isPhone ? 10 : 20 );;
					_listShadow.width = this.actualWidth;
				}
				
				_list.y = AbstractGameInfo.LANDSCAPE ? 0 : (_listShadow.y + _listShadow.height);
				_list.width = this.actualWidth;
				_list.height = this.actualHeight - _list.y;
				
				_retryContainer.width = actualWidth;
				_retryContainer.height = actualHeight - _list.y;
				_retryContainer.y = _list.y;
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Handlers
//------------------------------------------------------------------------------------------------------------
		
		/**
		 * The pevious tournaments could be retreived but few cases here :
		 * 
		 * <p><strong>There was an error executing the request</strong>,
		 * thus we need to display the error message and a retry button.</p>
		 * 
		 * <p><strong>There were no previous tournament to load</strong>,
		 * thus we only need to display a message indicating this fact.</p>
		 * 
		 * <p><strong>All the previous tournaments could be loaded, thus we
		 * hide every ui component except the list, which will be initialized
		 * with the loaded content.</p>
		 */		
		private function onGetPreviousTournamentsSuccess(result:Object):void
		{
			_list.onRefreshComplete();
			switch(result.code)
			{
				case 0: // error
				{
					_retryContainer.loadingMode = false;
					_retryContainer.singleMessageMode = true;
					_retryContainer.message = result.txt;
					_list.visible = false;
					
					break;
				}
				case 1: // success
				{
					_retryContainer.visible = false;
					_list.visible = true;
					
					if( _list.dataProvider )
						_list.dataProvider.removeAll();
					
					// bug visuel sinon 
					TweenMax.delayedCall(0, function():void
					{
						var i:int = 0;
						var len:int = (result.tournoi as Array).length;
						var provider:Array = [];
						provider.push( new PreviousTournamentData( -1 ) );
						for( i; i < len; i++)
							provider.push( new PreviousTournamentData( int(result.tournoi[i]) ) );
						_list.dataProvider = new ListCollection( provider );
						_list.selectedIndex = -1;
					});
					
					break;
				}
				case 2: // no tournament
				{
					/*_retryContainer.loadingMode = false;
					_retryContainer.singleMessageMode = true;
					_retryContainer.message =  Localizer.getInstance().translate("PREVIOUS_TOURNAMENTS.NO_PREVIOUS_TOURNAMENTS");
					_list.visible = false;*/
					
					_retryContainer.visible = false;
					_list.visible = true;
					
					if( _list.dataProvider )
						_list.dataProvider.removeAll();
					
					var provider:Array = [];
					provider.push( new PreviousTournamentData( -1 ) );
					_list.dataProvider = new ListCollection( provider );
					_list.selectedIndex = -1;
					
					break;
				}
				
				default:
				{
					onGetPreviousTournamentsFailure();
					break;
				}
			}
		}
		
		/**
		 * There was an error while trying to retreive the previous tournaments.
		 * 
		 * <p>In this case we display an error message and a button to retry.</p>
		 */		
		private function onGetPreviousTournamentsFailure(error:Object = null):void
		{
			_list.onRefreshComplete();
			
			_retryContainer.message = Localizer.getInstance().translate("COMMON.QUERY_FAILURE");
			_retryContainer.loadingMode = false;
		}
		
		private function onPreviousTournamentSelected(event:Event):void
		{
			if( int(event.data) == -1 )
			{
				advancedOwner.showScreen( ScreenIds.TOURNAMENT_RANKING_SCREEN );
			}
			else
			{
				advancedOwner.screenData.previousTournementId = int(event.data);
				advancedOwner.showScreen( ScreenIds.PREVIOUS_TOURNAMENTS_DETAIL_SCREEN );
			}
		}
		
		/**
		 * If an error occurred while retreiving the previous tournaments
		 * or if the user was not connected when this componenent was created,
		 * we need to show a retry button so that he doesn't need to
		 * leave and come back to the view to load the previous tournaments.
		 */		
		private function onRetry(event:Event):void
		{
			if( AirNetworkInfo.networkInfo.isConnected() )
			{
				_retryContainer.loadingMode = true;
				Remote.getInstance().getPreviousTournaments(onGetPreviousTournamentsSuccess, onGetPreviousTournamentsFailure, onGetPreviousTournamentsFailure, 2, advancedOwner.activeScreenID);
			}
			else
			{
				InfoManager.showTimed(Localizer.getInstance().translate("COMMON.NOT_CONNECTED"), InfoManager.DEFAULT_DISPLAY_TIME, InfoContent.ICON_CROSS);
			}
		}
		
		/**
		 * The user requested a refresh of the list.
		 */		
		private function onRefreshTop():void
		{
			Remote.getInstance().getPreviousTournaments(onGetPreviousTournamentsSuccess, onGetPreviousTournamentsFailure, onGetPreviousTournamentsFailure, 2, advancedOwner.activeScreenID);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
//------------------------------------------------------------------------------------------------------------
		
		override public function dispose():void
		{
			if( _logo )
			{
				_logo.removeFromParent(true);
				_logo = null;
			}
			
			if( _listShadow )
			{
				_listShadow.removeFromParent(true);
				_listShadow = null;
			}
			
			_retryContainer.removeEventListener(Event.TRIGGERED, onRetry);
			_retryContainer.removeFromParent(true);
			_retryContainer = null;
			
			
			_list.removeEventListener(Event.CHANGE, onPreviousTournamentSelected);
			_list.removeEventListener(LudoEventType.REFRESH_TOP, onRefreshTop);
			_list.removeFromParent(true);
			_list = null;
			
			super.dispose();
		}
		
	}
}