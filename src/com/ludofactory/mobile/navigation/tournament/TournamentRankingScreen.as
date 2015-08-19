/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 24 juil. 2013
*/
package com.ludofactory.mobile.navigation.tournament
{
	
	import com.freshplanet.nativeExtensions.AirNetworkInfo;
	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.common.utils.Shaker;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.AbstractGameInfo;
	import com.ludofactory.mobile.core.GameMode;
	import com.ludofactory.mobile.core.ScreenIds;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.controls.AdvancedScreen;
	import com.ludofactory.mobile.core.controls.CustomGroupedList;
	import com.ludofactory.mobile.core.events.MobileEventTypes;
	import com.ludofactory.mobile.core.manager.InfoContent;
	import com.ludofactory.mobile.core.manager.InfoManager;
	import com.ludofactory.mobile.core.manager.MemberManager;
	import com.ludofactory.mobile.core.manager.TimerManager;
	import com.ludofactory.mobile.core.notification.NotificationPopupManager;
	import com.ludofactory.mobile.core.notification.content.MarketingRegisterNotificationContent;
	import com.ludofactory.mobile.core.remoting.Remote;
	import com.ludofactory.mobile.core.storage.Storage;
	import com.ludofactory.mobile.core.storage.StorageConfig;
	import com.ludofactory.mobile.core.theme.Theme;
	import com.ludofactory.mobile.navigation.ads.tournament.AdTournamentContainer;
	import com.ludofactory.mobile.navigation.authentication.RetryContainer;
	import com.ludofactory.mobile.navigation.tournament.listing.RankData;
	import com.ludofactory.mobile.navigation.tournament.listing.RankHeaderData;
	import com.ludofactory.mobile.navigation.tournament.listing.RankHeaderItemRenderer;
	import com.ludofactory.mobile.navigation.tournament.listing.RankItemRenderer;
	import com.ludofactory.mobile.navigation.tournament.listing.TournamentListHeader;
	
	import feathers.controls.Button;
	import feathers.controls.Callout;
	import feathers.controls.Label;
	import feathers.data.HierarchicalCollection;
	
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import starling.display.Image;
	import starling.display.Quad;
	import starling.events.Event;
	import starling.filters.BlurFilter;
	
	public class TournamentRankingScreen extends AdvancedScreen
	{
		//private static const FAKE_RANKNG:String = '{"15":["Du 8ème au 15ème : Carte Cadeau Amazon 20/euro/",{"8":{"pays":"FR","classement":8,"isMembre":false,"score":"751","pseudo":"","lastDateScore":"2013-08-10 19:44:31"},"9":{"pays":"FR","classement":9,"isMembre":false,"score":"693","pseudo":"","lastDateScore":"2013-08-10 16:44:31"},"10":{"pays":"FR","classement":10,"isMembre":false,"score":"682","pseudo":"","lastDateScore":"2013-08-10 16:44:31"},"11":{"pays":"FR","classement":11,"isMembre":false,"score":"552","pseudo":"","lastDateScore":"2013-08-09 16:44:31"}}],"1":["1er : PlayStation 4",{"1":{"pays":"FR","classement":1,"isMembre":false,"score":"987","pseudo":"Milune","lastDateScore":"2013-08-10 16:44:31"}}],"2":["2ème : Console Wii U",{"2":{"pays":"FR","classement":2,"isMembre":false,"score":"985","pseudo":"Piolet","lastDateScore":"2013-08-10 16:44:31"}}],"3":["3ème : Carte Cadeau Amazon 150/euro/",{"3":{"pays":"FR","classement":3,"isMembre":false,"score":"963","pseudo":"Jack","lastDateScore":"2013-08-10 16:44:31"}}],"7":["Du 4ème au 7ème : Carte Cadeau Amazon 50/euro/",{"4":{"pays":"FR","classement":4,"isMembre":false,"score":"951","pseudo":"","lastDateScore":"2013-08-10 16:44:31"},"5":{"pays":"FR","classement":5,"isMembre":false,"score":"856","pseudo":"","lastDateScore":"2013-08-10 16:44:31"},"6":{"pays":"FR","classement":6,"isMembre":false,"score":"789","pseudo":"","lastDateScore":"2013-08-10 16:44:31"},"7":{"pays":"FR","classement":7,"isMembre":false,"score":"753","pseudo":"","lastDateScore":"2013-08-10 16:44:31"}}]}';
		private static const FAKE_RANKNG:String = '{"7":["Du 4ème au 7ème : Carte Cadeau Amazon 50/euro/",{"4":{"pays":"FR","classement":4,"isMembre":false,"score":"951","pseudo":"","lastDateScore":"2013-08-10 16:44:31"},"5":{"pays":"FR","classement":5,"isMembre":false,"score":"856","pseudo":"","lastDateScore":"2013-08-10 16:44:31"},"6":{"pays":"FR","classement":6,"isMembre":false,"score":"789","pseudo":"","lastDateScore":"2013-08-10 16:44:31"},"7":{"pays":"FR","classement":7,"isMembre":false,"score":"753","pseudo":"","lastDateScore":"2013-08-10 16:44:31"},"8":{"pays":"FR","classement":8,"isMembre":false,"score":"753","pseudo":"","lastDateScore":"2013-08-10 16:44:31"},"9":{"pays":"FR","classement":9,"isMembre":false,"score":"753","pseudo":"","lastDateScore":"2013-08-10 16:44:31"},"10":{"pays":"FR","classement":10,"isMembre":false,"score":"753","pseudo":"","lastDateScore":"2013-08-10 16:44:31"},"11":{"pays":"FR","classement":11,"isMembre":false,"score":"753","pseudo":"","lastDateScore":"2013-08-10 16:44:31"},"12":{"pays":"FR","classement":12,"isMembre":false,"score":"753","pseudo":"","lastDateScore":"2013-08-10 16:44:31"},"13":{"pays":"FR","classement":13,"isMembre":false,"score":"753","pseudo":"","lastDateScore":"2013-08-10 16:44:31"},"14":{"pays":"FR","classement":14,"isMembre":false,"score":"753","pseudo":"","lastDateScore":"2013-08-10 16:44:31"},"15":{"pays":"FR","classement":15,"isMembre":false,"score":"753","pseudo":"","lastDateScore":"2013-08-10 16:44:31"},"16":{"pays":"FR","classement":16,"isMembre":false,"score":"753","pseudo":"","lastDateScore":"2013-08-10 16:44:31"},"17":{"pays":"FR","classement":17,"isMembre":false,"score":"753","pseudo":"","lastDateScore":"2013-08-10 16:44:31"},"18":{"pays":"FR","classement":18,"isMembre":false,"score":"753","pseudo":"","lastDateScore":"2013-08-10 16:44:31"},"19":{"pays":"FR","classement":19,"isMembre":false,"score":"753","pseudo":"","lastDateScore":"2013-08-10 16:44:31"},"20":{"pays":"FR","classement":20,"isMembre":false,"score":"753","pseudo":"","lastDateScore":"2013-08-10 16:44:31"}}]}';
		
		/**
		 * The ad container */		
		private var _adContainer:AdTournamentContainer;
		
		/**
		 * The play button */		
		private var _playButton:Button;
		
		/**
		 * The locks when the tournament is locked. */		
		private var _leftLock:Image;
		private var _rightLock:Image;
		private var _lock:Image;
		
		/**
		 * The list header. */		
		private var _listHeader:TournamentListHeader;
		/**
		 * Ranks list. */		
		private var _ranksList:CustomGroupedList;
		
		/**
		 * The list shadow */		
		private var _listShadow:Quad;
		
		/**
		 * The current tournamenet id returned at the first request. */		
		private var _currentTournamentId:int; // FIXME stocker ça quelque part dans l'appli ?
		
		/**
		 * Whether the view is in update mode (come code won't be
		 * executed in this mode). */		
		private var _isInUpdateMode:Boolean = false;
		
		/**
		 * The retry container. */		
		private var _retryContainer:RetryContainer;
		
		private var _isCalloutDisplaying:Boolean = false;
		
		private var _calloutLabel:Label;
		
		private var _timer:TimerManager;
		
		private var _isShaking:Boolean = false;
		
		/**
		 * The list shadow */		
		private var _listBottomShadow:Quad;
		
		public function TournamentRankingScreen()
		{
			super();
			
			_whiteBackground = true;
			_appClearBackground = false;
			_fullScreen = false;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			_headerTitle = _("Tournoi en cours");
			
			_listHeader = new TournamentListHeader();
			_listHeader.visible = false;
			addChild(_listHeader);
			
			if( AbstractGameInfo.LANDSCAPE )
				RankItemRenderer.ITEM_WIDTH = RankHeaderItemRenderer.ITEM_WIDTH = !AirNetworkInfo.networkInfo.isConnected() ? GlobalConfig.stageWidth : (GlobalConfig.stageWidth - scaleAndRoundToDpi(350)); // size of the ad container in landscape mode
			else
				RankItemRenderer.ITEM_WIDTH = RankHeaderItemRenderer.ITEM_WIDTH = GlobalConfig.stageWidth;
			
			_ranksList = new CustomGroupedList();
			_ranksList.isSelectable = false;
			_ranksList.headerRendererType = RankHeaderItemRenderer;
			_ranksList.itemRendererType = RankItemRenderer;
			_ranksList.addEventListener(MobileEventTypes.LIST_BOTTOM_UPDATE, onBottomUpdate);
			_ranksList.addEventListener(MobileEventTypes.LIST_TOP_UPDATE, onTopUpdate);
			addChild(_ranksList);
			
			_playButton = new Button();
			_playButton.addEventListener(Event.TRIGGERED, onPlay);
			_playButton.label = _("Participer");
			addChild(_playButton);
			
			if( MemberManager.getInstance().getTournamentUnlocked() == false )
			{
				_leftLock = new Image( AbstractEntryPoint.assets.getTexture("lock-left") );
				_leftLock.scaleX = _leftLock.scaleY = GlobalConfig.dpiScale;
				_leftLock.touchable = false;
				addChild( _leftLock );
				
				_lock = new Image( AbstractEntryPoint.assets.getTexture("lock") );
				_lock.scaleX = _lock.scaleY = GlobalConfig.dpiScale;
				_lock.touchable = false;
				addChild( _lock );
				
				_rightLock = new Image( AbstractEntryPoint.assets.getTexture("lock-right") );
				_rightLock.scaleX = _rightLock.scaleY = GlobalConfig.dpiScale;
				_rightLock.touchable = false;
				addChild( _rightLock );
				
				_timer = new TimerManager(3, -1, null, onShake);
				_timer.restart();
			}
			
			if( !AbstractGameInfo.LANDSCAPE )
			{
				_listShadow = new Quad(50, scaleAndRoundToDpi(12), 0x000000);
				_listShadow.setVertexAlpha(0, 0.1);
				_listShadow.setVertexAlpha(1, 0.1);
				_listShadow.setVertexAlpha(2, 0);
				_listShadow.setVertexColor(2, 0xffffff);
				_listShadow.setVertexAlpha(3, 0);
				_listShadow.setVertexColor(3, 0xffffff);
				addChild(_listShadow);
			}
			
			if( AbstractGameInfo.LANDSCAPE )
			{
				_listBottomShadow = new Quad(scaleAndRoundToDpi(12), 50, 0x000000);
				_listBottomShadow.touchable = false;
				_listBottomShadow.setVertexColor(0, 0xffffff);
				_listBottomShadow.setVertexAlpha(0, 0);
				_listBottomShadow.setVertexColor(2, 0xffffff);
				_listBottomShadow.setVertexAlpha(2, 0);
				_listBottomShadow.setVertexAlpha(1, 0.2);
				_listBottomShadow.setVertexAlpha(3, 0.2);
				addChild(_listBottomShadow);
			}
			else
			{
				_listBottomShadow = new Quad(50, scaleAndRoundToDpi(12), 0x000000);
				_listBottomShadow.touchable = false;
				_listBottomShadow.setVertexColor(0, 0xffffff);
				_listBottomShadow.setVertexAlpha(0, 0);
				_listBottomShadow.setVertexColor(1, 0xffffff);
				_listBottomShadow.setVertexAlpha(1, 0);
				_listBottomShadow.setVertexAlpha(2, 0.1);
				_listBottomShadow.setVertexAlpha(3, 0.1);
				addChild(_listBottomShadow);
			}
			
			/*_listBottomShadow = new Quad(50, scaleAndRoundToDpi(12), 0x000000);
			_listBottomShadow.setVertexAlpha(0, 0.1);
			_listBottomShadow.setVertexAlpha(1, 0.1);
			_listBottomShadow.setVertexColor(2, 0xffffff);
			_listBottomShadow.setVertexAlpha(2, 0);
			_listBottomShadow.setVertexColor(3, 0xffffff);
			_listBottomShadow.setVertexAlpha(3, 0);
			addChild(_listBottomShadow);*/
			
			_retryContainer = new RetryContainer(true);
			_retryContainer.addEventListener(Event.TRIGGERED, onRetry);
			addChild(_retryContainer);
			
			if( AirNetworkInfo.networkInfo.isConnected() )
			{
				Remote.getInstance().getCurrentTournamentRanking(null, onGetCurrentTournamentRankingSuccess, onGetCurrentTournamentRankingFailure, onGetCurrentTournamentRankingFailure, 2, advancedOwner.activeScreenID);
			}
			else
			{
				_ranksList.filter = new BlurFilter(5, 5);
				_listHeader.filter = new BlurFilter(5, 5);
				
				var fakeRankingArray:Array = processDataBeforeUpdate( JSON.parse(FAKE_RANKNG) );
				var newDataProvider:Array = [];
				var tempChildren:Array = [];
				var len:int = fakeRankingArray.length;
				var childrenLen:int;
				for(var i:int = 0; i < len; i++)
				{
					tempChildren = [];
					childrenLen = fakeRankingArray[i][1].length;
					for(var j:int = 0; j < childrenLen; j++)
						tempChildren.push( new RankData( fakeRankingArray[i][1][j] ) );
					newDataProvider.push( { header:fakeRankingArray[i][0], children:tempChildren } );
				}
				_ranksList.dataProvider = new HierarchicalCollection( newDataProvider );
				_ranksList.isRefreshableDown = false;
				_ranksList.isRefreshableTop = false;
				_ranksList.touchable = false;
				_ranksList.alpha = 0.2;
				
				_retryContainer.loadingMode = false;
				
				fakeRankingArray = [];
				fakeRankingArray = null;
				
				tempChildren = [];
				tempChildren = null;
				
				newDataProvider = [];
				newDataProvider = null;
			}
		}
		
		override protected function draw():void
		{
			if( isInvalid(INVALIDATION_FLAG_SIZE) )
			{
				if( AbstractGameInfo.LANDSCAPE )
				{
					if( _adContainer )
					{
						_adContainer.height = actualHeight;
						_adContainer.width = scaleAndRoundToDpi(350);
						_adContainer.x = actualWidth - _adContainer.width;
					}
					
					_playButton.width = scaleAndRoundToDpi(300);
					_playButton.validate();
					_playButton.y = actualHeight - _playButton.height - scaleAndRoundToDpi(10);
					_playButton.x = _adContainer ? (_adContainer.x + (((actualWidth - _adContainer.x) - _playButton.width) * 0.5)) : ((actualWidth - _playButton.width) * 0.5);//(_adContainer ? _adContainer.x : actualWidth) + scaleAndRoundToDpi(25);
					
					_listHeader.width = _adContainer ? (actualWidth - _adContainer.width) : actualWidth;
					_listHeader.validate();
					
					_ranksList.width = _listHeader.width;
					_ranksList.height = actualHeight - _listHeader.height;
					_ranksList.y = _listHeader.y + _listHeader.height;
					
					_listBottomShadow.height = actualHeight;
					_listBottomShadow.x = (_adContainer ? _adContainer.x : 0) - _listBottomShadow.width;
					
					_retryContainer.width = actualWidth;
					_retryContainer.y = _ranksList.y;
					_retryContainer.height = _playButton.y - _ranksList.y;
					
					if( MemberManager.getInstance().getTournamentUnlocked() == false )
					{
						_leftLock.alignPivot();
						_leftLock.y = int(_playButton.y + (_playButton.height * 0.5) + scaleAndRoundToDpi(3));
						_leftLock.x = int(_playButton.x + (_leftLock.width * 0.5) + scaleAndRoundToDpi(40));
						
						_rightLock.alignPivot();
						_lock.alignPivot();
						_rightLock.y = _lock.y = int(_playButton.y + (_playButton.height * 0.5) + scaleAndRoundToDpi(12));
						_rightLock.x = _lock.x = int(_playButton.x + _playButton.width - (_rightLock.width * 0.5));
					}
				}
				else
				{
					if( _adContainer )
						_adContainer.width = this.actualWidth;
					
					_listShadow.width = this.actualWidth;
					_listShadow.y = _adContainer ? _adContainer.height : 0;
					
					_playButton.width = this.actualWidth * 0.8;
					_playButton.validate();
					_playButton.y = this.actualHeight - _playButton.height - scaleAndRoundToDpi(20);
					_playButton.x = (this.actualWidth - _playButton.width) * 0.5;
					
					_listHeader.width = this.actualWidth;
					_listHeader.y = _adContainer ? _adContainer.height : 0;
					_listHeader.validate();
					
					_ranksList.width = this.actualWidth;
					_ranksList.height = _playButton.y - _listHeader.y - _listHeader.height - _listBottomShadow.height - scaleAndRoundToDpi(10);
					_ranksList.y = _listHeader.y + _listHeader.height;
					
					_listBottomShadow.width = this.actualWidth;
					_listBottomShadow.y = _ranksList.y + _ranksList.height;
					
					_retryContainer.width = actualWidth;
					_retryContainer.y = _ranksList.y;
					_retryContainer.height = _playButton.y - _ranksList.y;
					
					if( MemberManager.getInstance().getTournamentUnlocked() == false )
					{
						_leftLock.alignPivot();
						_leftLock.y = int(_playButton.y + (_playButton.height * 0.5) + scaleAndRoundToDpi(3));
						_leftLock.x = int(_playButton.x + (_leftLock.width * 0.5) + scaleAndRoundToDpi(40));
						
						_rightLock.alignPivot();
						_lock.alignPivot();
						_rightLock.y = _lock.y = int(_playButton.y + (_playButton.height * 0.5) + scaleAndRoundToDpi(12));
						_rightLock.x = _lock.x = int(_playButton.x + _playButton.width - (_rightLock.width * 0.5));
					}
				}
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Handlers
//------------------------------------------------------------------------------------------------------------
		
		/**
		 * The pevious tournament details could be retreived but few cases here :
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
		private function onGetCurrentTournamentRankingSuccess(result:Object):void
		{
			switch(result.code)
			{
				case 0: // error
				{
					if( !_isInUpdateMode )
					{
						_retryContainer.loadingMode = false;
						_retryContainer.singleMessageMode = true;
						_retryContainer.message = result.txt;
						_listHeader.visible = false;
						_ranksList.visible = false;
					}
					
					break;
				}
				case 1: // success
				{
					if( result.id_tournoi )
						_currentTournamentId = int(result.id_tournoi);
					
					if( result.hasOwnProperty("podium") && !_adContainer )
					{
						_adContainer = new AdTournamentContainer();
						_adContainer.dataProvider = result.podium as Array;
						_adContainer.width = actualWidth;
						addChildAt(_adContainer, getChildIndex(_playButton) - 1);
						
						invalidate( INVALIDATION_FLAG_SIZE );
					}
					
					if( result.classement.length == 0 )
					{
						// no messages
						
						if( !_isInUpdateMode )
						{
							_retryContainer.loadingMode = false;
							_retryContainer.singleMessageMode = true;
							_retryContainer.message = _("Personne n'est encore classé !");
						}
						
						_ranksList.isRefreshableDown = false;
						_ranksList.isRefreshableTop = false;
					}
					else
					{
						_retryContainer.visible = false;
						_ranksList.visible = true;
						_listHeader.visible = true;
						_playButton.visible = true;
						_ranksList.touchable = true;
						_ranksList.alpha = 1;
						
						result.classement = processDataBeforeUpdate( result.classement );
						if( result.queryName == "LudoMobile.useClass.Tournoi.getClassementSup" )
							(result.classement as Array).reverse();
						
						var i:int;
						var j:int;
						var tempChildren:Array = [];
						var len:int = result.classement.length;
						var childrenLen:int;
						
						if( !_ranksList.dataProvider || _ranksList.dataProvider.data.length == 0 )
						{
							if( _ranksList.filter )
							{
								_ranksList.filter.dispose();
								_ranksList.filter = null;
							}
							
							if( _listHeader.filter )
							{
								_listHeader.filter.dispose();
								_listHeader.filter = null;
							}
							
							// first add
							var newDataProvider:Array = [];
							
							for(i = 0; i < len; i++)
							{
								tempChildren = [];
								childrenLen = result.classement[i][1].length;
								for(j = 0; j < childrenLen; j++)
									tempChildren.push( new RankData( result.classement[i][1][j] ) );
								newDataProvider.push( { header:result.classement[i][0], children:tempChildren } );
							}
							_ranksList.dataProvider = new HierarchicalCollection( newDataProvider );
							_ranksList.isRefreshableDown = true;
							_ranksList.isRefreshableTop = true;
							
							findMe();
						}
						else
						{
							var headerValue:RankHeaderData;
							var addNormally:Boolean = true;
							for each(var newGroup:Array in result.classement)
							{
								headerValue = newGroup[0];
								childrenLen = newGroup[1].length;
								addNormally = true;
								tempChildren = [];
								
								for(j = 0; j < childrenLen; j++)
									tempChildren.push( new RankData( newGroup[1][j] ) );
								
								for each(var existingGroup:Object in _ranksList.dataProvider.data)
								{
									if( headerValue.indice == existingGroup.header.indice )
									{
										addNormally = false;
										
										if( result.queryName == "LudoMobile.useClass.Tournoi.getClassementInf" )
											existingGroup.children = (existingGroup.children as Array).concat( tempChildren );
										else
											existingGroup.children = tempChildren.concat( (existingGroup.children as Array) );
									}
								}
								
								if( addNormally )
								{
									if( result.queryName == "LudoMobile.useClass.Tournoi.getClassementInf" )
										_ranksList.dataProvider.data.push( { header:headerValue, children:tempChildren } );
									else
										_ranksList.dataProvider.data.unshift( { header:headerValue, children:tempChildren } );
								}
							}
							_ranksList.invalidate( INVALIDATION_FLAG_DATA );
						}
					}
					
					break;
				}
				case 3: // for an update, if we have no more players
				{
					try
					{
						if( result.queryName == "LudoMobile.useClass.Tournoi.getClassementInf" )
							_ranksList.isRefreshableDown = false;
						else
							_ranksList.isRefreshableTop = false;
					} 
					catch(error:Error) 
					{
						
					}
					
					break;
				}
					
				default:
				{
					onGetCurrentTournamentRankingFailure();
					break;
				}
			}
			
			if( _isInUpdateMode )
			{
				if( result.queryName == "LudoMobile.useClass.Tournoi.getClassementInf" )
					_ranksList.onBottomAutoUpdateFinished();
				else
					_ranksList.onTopAutoUpdateFinished();
			}
		}
		
		/**
		 * There was an error while trying to retreive the previous tournament details.
		 * 
		 * <p>In this case we display an error message and a button to retry.</p>
		 */		
		private function onGetCurrentTournamentRankingFailure(error:Object = null):void
		{
			if( error.queryName == "LudoMobile.useClass.Tournoi.getClassementInf" )
				_ranksList.isRefreshableDown = false;
			else
				_ranksList.isRefreshableTop = false;
			
			if( !_isInUpdateMode )
			{
				_retryContainer.message = _("Une erreur est survenue, veuillez réessayer.");
				_retryContainer.loadingMode = false;
			}
		}
		
		/**
		 * If an error occurred while retreiving the previous tournament
		 * details or if the user was not connected when this componenent 
		 * was created, we need to show a retry button so that he doesn't
		 * need to leave and come back to the view to load the previous
		 * tournament details.
		 */		
		private function onRetry(event:Event):void
		{
			if( AirNetworkInfo.networkInfo.isConnected() )
			{
				_retryContainer.loadingMode = true;
				// clear fake data if necessary
				if( _ranksList.dataProvider )
					_ranksList.dataProvider = new HierarchicalCollection([]);
				Remote.getInstance().getCurrentTournamentRanking(null, onGetCurrentTournamentRankingSuccess, onGetCurrentTournamentRankingFailure, onGetCurrentTournamentRankingFailure, 2, advancedOwner.activeScreenID);
			}
			else
			{
				InfoManager.showTimed(_("Aucune connexion Internet."), InfoManager.DEFAULT_DISPLAY_TIME, InfoContent.ICON_CROSS);
			}
		}
		
		/**
		 * Play
		 */		
		private function onPlay(event:Event):void
		{
			if( MemberManager.getInstance().getTournamentUnlocked() == true )
			{
				if( MemberManager.getInstance().isLoggedIn() )
				{
					advancedOwner.screenData.gameType = GameMode.TOURNAMENT;
					advancedOwner.showScreen( ScreenIds.GAME_TYPE_SELECTION_SCREEN );
				}
				else
				{
					// si pas de passage à la page de sélection de mise
					/*if( (MemberManager.getInstance().getNumFreeGameSessions() >= Storage.getInstance().getProperty( StorageConfig.NUM_TOKENS_IN_TOURNAMENT_MODE ))
						// || (MemberManager.getInstance().getPoints() >= Storage.getInstance().getProperty(StorageConfig.PROPERTY_NUM_POINTS_IN_TOURNAMENT_MODE))
					)
					{
						AbstractEntryPoint.screenNavigator.screenData.gameType = GameSession.TYPE_TOURNAMENT;
						AbstractEntryPoint.screenNavigator.screenData.gamePrice = GameSession.PRICE_FREE;
						AbstractEntryPoint.screenNavigator.showScreen( MemberManager.getInstance().getNeedSmallRules() ? AdvancedScreen.SMALL_RULES_SCREEN : AdvancedScreen.GAME_SCREEN );
					}
					else
					{
						AbstractEntryPoint.screenNavigator.showScreen( AdvancedScreen.AUTHENTICATION_SCREEN );
					}*/
					
					if( MemberManager.getInstance().getNumTokens() < int(Storage.getInstance().getProperty(StorageConfig.NUM_TOKENS_IN_TOURNAMENT_MODE)) )
					{
						//AbstractEntryPoint.screenNavigator.showScreen( AdvancedScreen.AUTHENTICATION_SCREEN );
						//NotificationManager.addNotification( new MarketingRegisterNotification(ScreenIds.TOURNAMENT_RANKING_SCREEN) );
						NotificationPopupManager.addNotification( new MarketingRegisterNotificationContent(ScreenIds.TOURNAMENT_RANKING_SCREEN) );
					}
					else
					{
						advancedOwner.screenData.gameType = GameMode.TOURNAMENT;
						advancedOwner.showScreen( ScreenIds.GAME_TYPE_SELECTION_SCREEN );
					}
				}
			}
			else
			{
				if( !_isShaking )
				{
					_timer.restart();
					onShake();
				}
				
				if( !_isCalloutDisplaying )
				{
					if( !_calloutLabel )
					{
						_calloutLabel = new Label();
						_calloutLabel.text = _("Pour débloquer les parties en Tournoi, il suffit de terminer une partie Solo !");
						_calloutLabel.width = GlobalConfig.stageWidth * 0.9;
						_calloutLabel.validate();
					}
					_isCalloutDisplaying = true;
					var callout:Callout = Callout.show(_calloutLabel, _playButton, Callout.DIRECTION_UP, false);
					callout.disposeContent = false;
					callout.touchable = false;
					callout.addEventListener(Event.REMOVED_FROM_STAGE, onCalloutRemoved);
					_calloutLabel.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(26), Theme.COLOR_DARK_GREY, false, false, null, null, null, TextFormatAlign.CENTER);
				}
			}
		}
		
		private function onCalloutRemoved(event:Event):void
		{
			event.target.removeEventListener(Event.REMOVED_FROM_STAGE, onCalloutRemoved);
			_isCalloutDisplaying = false;
		}
		
		private function onShake():void
		{
			if( !_isShaking )
			{
				_isShaking = true;
				Shaker.dispatcher.addEventListener(Event.COMPLETE, onShakeComplete);
				Shaker.startShaking(_lock, 5);
			}
		}
		
		private function onShakeComplete(event:Event):void
		{
			_isShaking = false;
			Shaker.dispatcher.removeEventListener(Event.COMPLETE, onShakeComplete);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Auto update handlers
//------------------------------------------------------------------------------------------------------------
		
		/**
		 * The user scrolled until the end of the list. In this case
		 * we launch an update to retreive the next 20 elements.
		 */		
		private function onBottomUpdate(event:Event):void
		{
			_isInUpdateMode = true;
			var rankData:RankData = (_ranksList.dataProvider.data[ _ranksList.dataProvider.data.length - 1 ]["children"] as Array)[ (_ranksList.dataProvider.data[ _ranksList.dataProvider.data.length - 1 ]["children"] as Array).length - 1 ];
			Remote.getInstance().getInfBloc(_currentTournamentId, rankData.rank, rankData.stars, rankData.lastDateScore, onGetCurrentTournamentRankingSuccess, onGetCurrentTournamentRankingFailure, onGetCurrentTournamentRankingFailure, 2, advancedOwner.activeScreenID);
		}
		/**
		 * The user scrolled until the end of the list. In this case
		 * we launch an update to retreive the next 20 elements.
		 */		
		private function onTopUpdate(event:Event):void
		{
			_isInUpdateMode = true;
			var rankData:RankData = (_ranksList.dataProvider.data[ 0 ]["children"] as Array)[ 0 ];
			Remote.getInstance().getSupBloc(_currentTournamentId, rankData.rank, rankData.stars, rankData.lastDateScore, onGetCurrentTournamentRankingSuccess, onGetCurrentTournamentRankingFailure, onGetCurrentTournamentRankingFailure, 2, advancedOwner.activeScreenID);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Utils
//------------------------------------------------------------------------------------------------------------
		
		private function sortObjectAndConvertToArray(objectToSort:Object):Array
		{
			var sortedArray:Array = [];
			var indices:Array = [];
			
			for( var key:String in objectToSort )
				indices.push( key );
			indices.sort(Array.NUMERIC);
			
			for(var i:int = 0; i < indices.length; i++)
			{
				objectToSort[indices[i]][0] = new RankHeaderData( { headerName:objectToSort[indices[i]][0], indice:int(indices[i]) } );
				sortedArray.push( objectToSort[indices[i]] );
			}
			
			return sortedArray;
		}
		
		/**
		 * Because indexed array (considered as objects in AS3) are not processed
		 * in the correct way when we use a for each, we need to convert the object
		 * into an array and sort it to be able to use it for the list.
		 */		
		private function processDataBeforeUpdate( data:Object ):Array
		{
			// sort main array
			var sortedArray:Array = sortObjectAndConvertToArray( data );
			
			// then sort children
			for(var i:int = 0; i < sortedArray.length; i++)
				sortedArray[i][1] = sortObjectAndConvertToArray( sortedArray[i][1] );
			
			return sortedArray;
		}
		
		private function findMe():void
		{
			var len:int;
			var groupId:int;
			var userData:RankData;
			for(groupId in _ranksList.dataProvider.data)
			{
				len = _ranksList.dataProvider.data[groupId].children.length;
				for(var i:int = 0; i < len; i++)
				{
					userData = _ranksList.dataProvider.data[groupId].children[i];
					if( userData.isMe )
						_ranksList.scrollToDisplayIndex(groupId, i, 0.5);
				}
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
//------------------------------------------------------------------------------------------------------------
		
		override public function dispose():void
		{
			if( _adContainer )
			{
				_adContainer.removeFromParent(true);
				_adContainer = null;
			}
			
			if( _calloutLabel )
			{
				_calloutLabel.removeFromParent(true);
				_calloutLabel = null;
			}
			
			if( _timer )
			{
				_timer.dispose();
				_timer = null;
			}
			
			if( _leftLock )
			{
				_leftLock.removeFromParent(true);
				_leftLock = null;
			}
			
			if( _rightLock )
			{
				_rightLock.removeFromParent(true);
				_rightLock = null;
			}
			
			if( _lock )
			{
				_lock.removeFromParent(true);
				_lock = null;
			}
			
			if( _listHeader.filter )
			{
				_listHeader.filter.dispose();
				_listHeader.filter = null;
			}
			
			_listHeader.removeFromParent(true);
			_listHeader = null;
			
			if( _ranksList.filter )
			{
				_ranksList.filter.dispose();
				_ranksList.filter = null;
			}
			
			_ranksList.removeEventListener(MobileEventTypes.LIST_BOTTOM_UPDATE, onBottomUpdate);
			_ranksList.removeEventListener(MobileEventTypes.LIST_TOP_UPDATE, onTopUpdate);
			_ranksList.removeFromParent(true);
			_ranksList = null;
			
			_playButton.removeEventListener(Event.TRIGGERED, onPlay);
			_playButton.removeFromParent(true);
			_playButton = null;
			
			if( _listShadow )
			{
				_listShadow.removeFromParent(true);
				_listShadow = null;
			}
			
			_listBottomShadow.removeFromParent(true);
			_listBottomShadow = null;
			
			super.dispose();
		}
	}
}