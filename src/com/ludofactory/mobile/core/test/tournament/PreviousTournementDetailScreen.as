/*
Copyright © 2006-2014 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 8 sept. 2013
*/
package com.ludofactory.mobile.core.test.tournament
{
	import com.freshplanet.nativeExtensions.AirNetworkInfo;
	import com.gamua.flox.Flox;
	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.common.utils.Utilities;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.authentication.RetryContainer;
	import com.ludofactory.mobile.core.controls.AdvancedScreen;
	import com.ludofactory.mobile.core.controls.CustomGroupedList;
	import com.ludofactory.mobile.core.events.LudoEventType;
	import com.ludofactory.mobile.core.manager.InfoContent;
	import com.ludofactory.mobile.core.manager.InfoManager;
	import com.ludofactory.mobile.core.remoting.Remote;
	import com.ludofactory.mobile.core.test.tournament.listing.RankData;
	import com.ludofactory.mobile.core.test.tournament.listing.RankHeaderData;
	import com.ludofactory.mobile.core.test.tournament.listing.RankHeaderItemRenderer;
	import com.ludofactory.mobile.core.test.tournament.listing.RankItemRenderer;
	import com.ludofactory.mobile.core.test.tournament.listing.TournamentListHeader;
	
	import feathers.data.HierarchicalCollection;
	import feathers.layout.VerticalLayout;
	
	import starling.display.Quad;
	import starling.events.Event;
	import starling.utils.formatString;
	
	public class PreviousTournementDetailScreen extends AdvancedScreen
	{
		/**
		 * The ad container */		
		private var _adContainer:PreviousTournamentGiftBloc;
		
		/**
		 * The list header. */		
		private var _listHeader:TournamentListHeader;
		
		/**
		 * The ranks list. */		
		private var _ranksList:CustomGroupedList;
		
		/**
		 * Whether we need to display the gift on this tournament
		 * for the actual player. */		
		private var _hasGiftToDisplay:Boolean = false;
		
		/**
		 * The list shadow */		
		private var _listShadow:Quad;
		
		/**
		 * Whether the view is in update mode (come code won't be
		 * executed in this mode). */		
		private var _isInUpdateMode:Boolean = false;
		
		/**
		 * The retry container. */		
		private var _retryContainer:RetryContainer;
		
		public function PreviousTournementDetailScreen()
		{
			super();
			
			_whiteBackground = true;
			_appClearBackground = false;
			_fullScreen = false;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			_headerTitle = formatString( _("Tournoi n°{0}"), Utilities.splitThousands( advancedOwner.screenData.previousTournementId ) );
			
			Flox.logInfo("Affichage de l'ancien tournoi n°{0}", advancedOwner.screenData.previousTournementId);
			
			_adContainer = new PreviousTournamentGiftBloc();
			addChild( _adContainer );
			
			_listHeader = new TournamentListHeader();
			_listHeader.visible = false;
			addChild(_listHeader);
			
			_ranksList = new CustomGroupedList();
			_ranksList.visible = false;
			_ranksList.headerRendererType = RankHeaderItemRenderer;
			_ranksList.itemRendererType = RankItemRenderer;
			_ranksList.addEventListener(LudoEventType.LIST_BOTTOM_UPDATE, onBottomUpdate);
			_ranksList.addEventListener(LudoEventType.LIST_TOP_UPDATE, onTopUpdate);
			addChild(_ranksList);
			
			const vlayout:VerticalLayout = new VerticalLayout();
			vlayout.horizontalAlign = VerticalLayout.HORIZONTAL_ALIGN_CENTER;
			vlayout.verticalAlign = VerticalLayout.VERTICAL_ALIGN_MIDDLE;
			vlayout.gap = scaleAndRoundToDpi(20);
			
			_listShadow = new Quad(50, scaleAndRoundToDpi(12), 0x000000);
			_listShadow.setVertexAlpha(0, 0.1);
			_listShadow.setVertexAlpha(1, 0.1);
			_listShadow.setVertexAlpha(2, 0);
			_listShadow.setVertexColor(2, 0xffffff);
			_listShadow.setVertexAlpha(3, 0);
			_listShadow.setVertexColor(3, 0xffffff);
			addChild(_listShadow);
			
			_retryContainer = new RetryContainer();
			_retryContainer.addEventListener(Event.TRIGGERED, onRetry);
			addChild(_retryContainer);
			
			if( AirNetworkInfo.networkInfo.isConnected() )
			{
				Remote.getInstance().getCurrentTournamentRanking(advancedOwner.screenData.previousTournementId, onGetPreviousTournamentDetailsSuccess, onGetPreviousTournamentDetailsFailure, onGetPreviousTournamentDetailsFailure, 2, advancedOwner.activeScreenID);
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
				_adContainer.visible = _hasGiftToDisplay;
				_adContainer.width = this.actualWidth;
				
				_listShadow.visible = _hasGiftToDisplay;
				_listShadow.width = this.actualWidth;
				_listShadow.y = _adContainer.height;
				
				_listHeader.width = this.actualWidth;
				_listHeader.y = _hasGiftToDisplay ? _adContainer.height : 0;
				_listHeader.validate();
				
				_ranksList.width = this.actualWidth;
				_ranksList.height = this.actualHeight - _listHeader.y - _listHeader.height;
				_ranksList.y = _listHeader.y + _listHeader.height;
				
				_retryContainer.width = actualWidth;
				_retryContainer.height = actualHeight - _listHeader.y;
				_retryContainer.y = _listHeader.y;
			}
		}
		
		// FIXME A voir pour overrider le onBack et rajouter ça ? advancedOwner.screenData.previousTournementId = -1;
		
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
		private function onGetPreviousTournamentDetailsSuccess(result:Object):void
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
						_ranksList.visible = false;
					}
					
					break;
				}
				case 1: // success
				{
					if( result.hasOwnProperty("lot") && result.lot )
					{
						_hasGiftToDisplay = true;
						
						_adContainer.title = Utilities.replaceCurrency(result.lot);
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
							
							invalidate( INVALIDATION_FLAG_SIZE );
							
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
					if( result.queryName == "LudoMobile.useClass.Tournoi.getClassementInf" )
						_ranksList.isRefreshableDown = false;
					else
						_ranksList.isRefreshableTop = false;
					
					break;
				}
					
				default:
				{
					onGetPreviousTournamentDetailsFailure();
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
		private function onGetPreviousTournamentDetailsFailure(error:Object = null):void
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
				Remote.getInstance().getCurrentTournamentRanking(advancedOwner.screenData.previousTournementId, onGetPreviousTournamentDetailsSuccess, onGetPreviousTournamentDetailsFailure, onGetPreviousTournamentDetailsFailure, 2, advancedOwner.activeScreenID);
			}
			else
			{
				InfoManager.showTimed(_("Aucune connexion Internet."), InfoManager.DEFAULT_DISPLAY_TIME, InfoContent.ICON_CROSS);
			}
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
			Remote.getInstance().getInfBloc(advancedOwner.screenData.previousTournementId, rankData.rank, rankData.stars, rankData.lastDateScore, onGetPreviousTournamentDetailsSuccess, onGetPreviousTournamentDetailsFailure, onGetPreviousTournamentDetailsFailure, 2, advancedOwner.activeScreenID);
		}
		/**
		 * The user scrolled until the end of the list. In this case
		 * we launch an update to retreive the next 20 elements.
		 */		
		private function onTopUpdate(event:Event):void
		{
			_isInUpdateMode = true;
			var rankData:RankData = (_ranksList.dataProvider.data[ 0 ]["children"] as Array)[ 0 ];
			Remote.getInstance().getSupBloc(advancedOwner.screenData.previousTournementId, rankData.rank, rankData.stars, rankData.lastDateScore, onGetPreviousTournamentDetailsSuccess, onGetPreviousTournamentDetailsFailure, onGetPreviousTournamentDetailsFailure, 2, advancedOwner.activeScreenID);
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
			_adContainer.removeFromParent(true);
			_adContainer = null;
			
			_listHeader.removeFromParent(true);
			_listHeader = null;
			
			_ranksList.removeEventListener(LudoEventType.LIST_BOTTOM_UPDATE, onBottomUpdate);
			_ranksList.removeEventListener(LudoEventType.LIST_TOP_UPDATE, onTopUpdate);
			_ranksList.removeFromParent(true);
			_ranksList = null;
			
			_listShadow.removeFromParent(true);
			_listShadow = null;
			
			super.dispose();
		}
	}
}