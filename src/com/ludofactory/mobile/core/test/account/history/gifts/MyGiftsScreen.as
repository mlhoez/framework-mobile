/*
LudoFactory
Framework mobile
Author  : Maxime Lhoez
Created : 17 sept. 2013
*/
package com.ludofactory.mobile.core.test.account.history.gifts
{
	import com.freshplanet.nativeExtensions.AirNetworkInfo;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.Localizer;
	import com.ludofactory.mobile.core.authentication.MemberManager;
	import com.ludofactory.mobile.core.authentication.NotLoggedInContainer;
	import com.ludofactory.mobile.core.authentication.RetryContainer;
	import com.ludofactory.mobile.core.controls.AdvancedScreen;
	import com.ludofactory.mobile.core.controls.CustomGroupedList;
	import com.ludofactory.mobile.core.events.LudoEventType;
	import com.ludofactory.mobile.core.manager.InfoContent;
	import com.ludofactory.mobile.core.manager.InfoManager;
	import com.ludofactory.mobile.core.remoting.Remote;
	import com.ludofactory.mobile.core.test.account.history.HistoryHeaderItemRenderer;
	import com.ludofactory.mobile.core.test.config.GlobalConfig;
	
	import feathers.data.HierarchicalCollection;
	
	import starling.display.Image;
	import starling.display.Quad;
	import starling.events.Event;
	
	public class MyGiftsScreen extends AdvancedScreen
	{
		/**
		 * The list shadow */		
		private var _listShadow:Quad;
		
		/**
		 * The account activities list. */		
		private var _list:CustomGroupedList;
		
		/**
		 * The logo. */		
		private var _logo:Image;
		
		/**
		 * Whether the view is in update mode (come code won't be
		 * executed in this mode). */		
		private var _isInUpdateMode:Boolean = false;
		
		/**
		 * The authentication container. */		
		private var _authenticationContainer:NotLoggedInContainer;
		
		/**
		 * The retry container. */		
		private var _retryContainer:RetryContainer;
		
		public function MyGiftsScreen()
		{
			super();
			
			_fullScreen = false;
			_appClearBackground = false;
			_whiteBackground = true;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			_headerTitle = Localizer.getInstance().translate("MY_GIFTS.HEADER_TITLE");
			
			_logo = new Image( AbstractEntryPoint.assets.getTexture( "menu-icon-my-gifts" ) );
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
			
			_list = new CustomGroupedList();
			_list.isSelectable = false;
			_list.visible = false;
			_list.headerRendererType = HistoryHeaderItemRenderer;
			_list.itemRendererType = GiftHistoryItemRenderer;
			_list.addEventListener(LudoEventType.LIST_BOTTOM_UPDATE, onBottomUpdate);
			_list.addEventListener(LudoEventType.REFRESH_GIFTS_LIST, onRefreshList);
			addChild(_list);
			
			_authenticationContainer = new NotLoggedInContainer();
			_authenticationContainer.visible = false;
			addChild(_authenticationContainer);
			
			_retryContainer = new RetryContainer();
			_retryContainer.addEventListener(Event.TRIGGERED, onRetry);
			_retryContainer.visible = false;
			addChild(_retryContainer);
			
			if( MemberManager.getInstance().isLoggedIn() )
			{
				_retryContainer.visible = true;
				if( AirNetworkInfo.networkInfo.isConnected() )
				{
					Remote.getInstance().getGiftsHistory(0, 20, onGetAccountHistorySuccess, onGetAccountHistoryFailure, onGetAccountHistoryFailure, 2, advancedOwner.activeScreenID);
				}
				else
				{
					_retryContainer.loadingMode = false;
				}
			}
			else
			{
				_authenticationContainer.visible = true;
			}
		}
		
		override protected function draw():void
		{
			if( isInvalid(INVALIDATION_FLAG_SIZE) )
			{
				_logo.x = (actualWidth - _logo.width) * 0.5;
				_logo.y = scaleAndRoundToDpi( GlobalConfig.isPhone ? 10 : 20 );
				
				_listShadow.y = _logo.y + _logo.height + scaleAndRoundToDpi( GlobalConfig.isPhone ? 10 : 20 );;
				_listShadow.width = this.actualWidth;
				
				_list.y = _listShadow.y + _listShadow.height;
				_list.width = this.actualWidth;
				_list.height = this.actualHeight - _list.y;
				
				_authenticationContainer.width = _retryContainer.width = actualWidth;
				_authenticationContainer.height = _retryContainer.height = actualHeight - _list.y;
				_authenticationContainer.y = _retryContainer.y = _list.y;
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Handlers
//------------------------------------------------------------------------------------------------------------
		
		/**
		 * The account activity could be retreived.
		 * 
		 * <p>If it is the first time we populate the data provider, we simply
		 * add the data in the list.>/p>
		 * 
		 * <p>Otherwise, we need to update the data provider to add the new
		 * elements taking in account that some of them might be added to an
		 * existing header / group. That's why we first need to check if the
		 * header we got already exists and if so, add the new content at the
		 * end of its children's array.</p>
		 */		
		private function onGetAccountHistorySuccess(result:Object):void
		{
			_list.onBottomAutoUpdateFinished();
			
			switch(result.code)
			{
				case 0: // ?
				case 2: // invalid data
				{
					if( !_isInUpdateMode )
					{
						_retryContainer.loadingMode = false;
						_retryContainer.singleMessageMode = true;
						_retryContainer.message = result.txt;
						_list.visible = false;
					}
					
					break;
				}
				case 1: // success
				{
					// reset alerts
					AbstractEntryPoint.alertData.numGainAlerts = 0;
					if( MemberManager.getInstance().isLoggedIn() && AirNetworkInfo.networkInfo.isConnected() )
						Remote.getInstance().initGifts(null, null, null, 2, advancedOwner.activeScreenID);
					
					if( result.gains.length == 0 )
					{
						// no messages
						
						if( !_isInUpdateMode )
						{
							_retryContainer.loadingMode = false;
							_retryContainer.singleMessageMode = true;
							_retryContainer.message = Localizer.getInstance().translate("MY_GIFTS.NO_MESSAGES");
							_list.visible = false;
						}
						
						_list.isRefreshableDown = false;
					}
					else
					{
						_retryContainer.visible = false;
						_list.visible = true;
						
						var i:int;
						var j:int;
						var tempChildren:Array = [];
						var len:int = result.gains.length;
						var childrenLen:int;
						
						if( !_list.dataProvider || _list.dataProvider.data.length == 0 )
						{
							// first add
							var newDataProvider:Array = [];
							
							for(i = 0; i < len; i++)
							{
								tempChildren = [];
								childrenLen = result.gains[i][1].length;
								for(j = 0; j < childrenLen; j++)
									tempChildren.push( new GiftHistoryData( result.gains[i][1][j] ) );
								newDataProvider.push( { header:result.gains[i][0], children:tempChildren } );
							}
							_list.dataProvider = new HierarchicalCollection( newDataProvider );
							_list.isRefreshableDown = true;
						}
						else
						{
							var headerValue:String;
							var addNormally:Boolean = true;
							for each(var newGroup:Array in result.gains)
							{
								headerValue = newGroup[0];
								childrenLen = newGroup[1].length;
								addNormally = true;
								tempChildren = [];
								
								for(j = 0; j < childrenLen; j++)
									tempChildren.push( new GiftHistoryData( newGroup[1][j] ) );
								
								for each(var existingGroup:Object in _list.dataProvider.data)
								{
									if( headerValue == existingGroup.header )
									{
										addNormally = false;
										existingGroup.children = (existingGroup.children as Array).concat( tempChildren );
									}
								}
								
								if( addNormally )
									_list.dataProvider.data.push( { header:headerValue, children:tempChildren } );
							}
							_list.invalidate( INVALIDATION_FLAG_DATA );
						}
					}
					
					break;
				}
				case 3: // no gifts won yet
				{
					if( !_isInUpdateMode )
					{
						
						_retryContainer.loadingMode = false;
						_retryContainer.singleMessageMode = true;
						_retryContainer.message =  Localizer.getInstance().translate("MY_GIFTS.NO_GIFTS_WON_YET");
						_list.visible = false;
						
						//if( !Storage.getInstance().getProperty(StorageConfig.PROPERTY_SKIP_HOW_TO_WIN_GIFTS_SCREEN) )
						//	advancedOwner.showScreen( AdvancedScreen.HOW_TO_WIN_GIFTS_SCREEN );
					}
					
					_list.isRefreshableDown = false;
					
					
					
					break;
				}
				case 4: // plus de gains
				{
					_list.isRefreshableDown = false;
				}
					
				default:
				{
					onGetAccountHistoryFailure();
					break;
				}
			}
		}
		
		/**
		 * There was an error while trying to retreive the account activity history.
		 * 
		 * <p>In this case we display an error message and a button to retry.</p>
		 */		
		private function onGetAccountHistoryFailure(error:Object = null):void
		{
			_list.onBottomAutoUpdateFinished();
			
			if( !_isInUpdateMode )
			{
				_retryContainer.message = Localizer.getInstance().translate("COMMON.QUERY_FAILURE");
				_retryContainer.loadingMode = false;
			}
		}
		
		/**
		 * If an error occurred while retreiving the account activity history
		 * or if the user was not connected when this componenent was created,
		 * we need to show a retry button so that he doesn't need to leave and
		 * come back to the view to load the messages.
		 */		
		private function onRetry(event:Event):void
		{
			if( AirNetworkInfo.networkInfo.isConnected() )
			{
				_retryContainer.loadingMode = true;
				Remote.getInstance().getGiftsHistory(0, 20, onGetAccountHistorySuccess, onGetAccountHistoryFailure, onGetAccountHistoryFailure, 2, advancedOwner.activeScreenID);
			}
			else
			{
				InfoManager.showTimed(Localizer.getInstance().translate("COMMON.NOT_CONNECTED"), InfoManager.DEFAULT_DISPLAY_TIME, InfoContent.ICON_CROSS);
			}
		}
		
		/**
		 * The user scrolled until the end of the list. In this case
		 * we launch an update to retreive the next 20 elements.
		 */		
		private function onBottomUpdate(event:Event):void
		{
			_isInUpdateMode = true;
			var count:int = 0;
			for each(var obj:Object in _list.dataProvider.data)
				count += obj.children.length;
			Remote.getInstance().getGiftsHistory(count, 20, onGetAccountHistorySuccess, onGetAccountHistoryFailure, onGetAccountHistoryFailure, 2, advancedOwner.activeScreenID);
		}
		
		/**
		 * 
		 */		
		private function onRefreshList(event:Event):void
		{
			if( AirNetworkInfo.networkInfo.isConnected() )
			{
				_isInUpdateMode = false;
				_list.dataProvider = null;
				_retryContainer.visible = true;
				_retryContainer.loadingMode = true;
				Remote.getInstance().getGiftsHistory(0, 20, onGetAccountHistorySuccess, onGetAccountHistoryFailure, onGetAccountHistoryFailure, 2, advancedOwner.activeScreenID);
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
//------------------------------------------------------------------------------------------------------------
		
		override public function dispose():void
		{
			_logo.removeFromParent(true);
			_logo = null;
			
			_listShadow.removeFromParent(true);
			_listShadow = null;
			
			_list.removeEventListener(LudoEventType.LIST_BOTTOM_UPDATE, onBottomUpdate);
			_list.removeFromParent(true);
			_list = null;
			
			super.dispose();
		}
	}
}