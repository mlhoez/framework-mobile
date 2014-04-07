/*
Copyright © 2006-2014 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 17 sept. 2013
*/
package com.ludofactory.mobile.core.test.account.history.account
{
	import com.freshplanet.nativeExtensions.AirNetworkInfo;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.Localizer;
	import com.ludofactory.mobile.core.authentication.MemberManager;
	import com.ludofactory.mobile.core.authentication.NotLoggedInContainer;
	import com.ludofactory.mobile.core.authentication.RetryContainer;
	import com.ludofactory.mobile.core.controls.CustomGroupedList;
	import com.ludofactory.mobile.core.events.LudoEventType;
	import com.ludofactory.mobile.core.manager.InfoContent;
	import com.ludofactory.mobile.core.manager.InfoManager;
	import com.ludofactory.mobile.core.remoting.Remote;
	import com.ludofactory.mobile.core.test.account.history.HistoryHeaderItemRenderer;
	
	import feathers.core.FeathersControl;
	import feathers.data.HierarchicalCollection;
	
	import starling.events.Event;
	
	/**
	 * A container displaying the account activity history.
	 */	
	public class AccountHistoryContainer extends FeathersControl
	{
		/**
		 * The account activities list. */		
		private var _list:CustomGroupedList;
		
		/**
		 * The authentication container. */		
		private var _authenticationContainer:NotLoggedInContainer;
		
		/**
		 * The retry container. */		
		private var _retryContainer:RetryContainer;
		
		/**
		 * Whether the view is in update mode (come code won't be
		 * executed in this mode). */		
		private var _isInUpdateMode:Boolean = false;
		
		public function AccountHistoryContainer()
		{
			super();
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			_list = new CustomGroupedList();
			_list.isSelectable = false;
			_list.visible = false;
			_list.headerRendererType = HistoryHeaderItemRenderer;
			_list.itemRendererType = AccountHistoryItemRenderer;
			_list.addEventListener(LudoEventType.LIST_BOTTOM_UPDATE, onBottomUpdate);
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
					Remote.getInstance().getAccountHistory(0, 20, onGetAccountHistorySuccess, onGetAccountHistoryFailure, onGetAccountHistoryFailure, 2, AbstractEntryPoint.screenNavigator.activeScreenID);
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
			super.draw();
			
			_list.width = this.actualWidth;
			_list.height = this.actualHeight;
			
			_authenticationContainer.width = _retryContainer.width = actualWidth;
			_authenticationContainer.height = _retryContainer.height = actualHeight;
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
				case 0: // error
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
				case 3: // no action recorded
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
					if( result.historique_membre.length == 0 )
					{
						// no messages
						
						if( !_isInUpdateMode )
						{
							_retryContainer.loadingMode = false;
							_retryContainer.singleMessageMode = true;
							_retryContainer.message = Localizer.getInstance().translate("MY_ACCOUNT_ACCOUNT_HISTORY.NO_MESSAGES");
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
						var len:int = result.historique_membre.length;
						var childrenLen:int;
						
						if( !_list.dataProvider || _list.dataProvider.data.length == 0 )
						{
							// first add
							var newDataProvider:Array = [];
							
							for(i = 0; i < len; i++)
							{
								tempChildren = [];
								childrenLen = result.historique_membre[i][1].length;
								for(j = 0; j < childrenLen; j++)
									tempChildren.push( new AccountHistoryData( result.historique_membre[i][1][j] ) );
								newDataProvider.push( { header:result.historique_membre[i][0], children:tempChildren } );
							}
							_list.dataProvider = new HierarchicalCollection( newDataProvider );
							_list.isRefreshableDown = true;
						}
						else
						{
							var headerValue:String;
							var addNormally:Boolean = true;
							for each(var newGroup:Array in result.historique_membre)
							{
								headerValue = newGroup[0];
								childrenLen = newGroup[1].length;
								addNormally = true;
								tempChildren = [];
								
								for(j = 0; j < childrenLen; j++)
									tempChildren.push( new AccountHistoryData( newGroup[1][j] ) );
								
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
				Remote.getInstance().getAccountHistory(0, 20, onGetAccountHistorySuccess, onGetAccountHistoryFailure, onGetAccountHistoryFailure, 2, AbstractEntryPoint.screenNavigator.activeScreenID);
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
			Remote.getInstance().getAccountHistory(count, 20, onGetAccountHistorySuccess, onGetAccountHistoryFailure, onGetAccountHistoryFailure, 2, AbstractEntryPoint.screenNavigator.activeScreenID);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
//------------------------------------------------------------------------------------------------------------
		
		override public function dispose():void
		{
			_authenticationContainer.removeFromParent(true);
			_authenticationContainer = null;
			
			_retryContainer.removeEventListener(Event.TRIGGERED, onRetry);
			_retryContainer.removeFromParent(true);
			_retryContainer = null;
			
			_list.removeEventListener(LudoEventType.LIST_BOTTOM_UPDATE, onBottomUpdate);
			_list.removeFromParent(true);
			_list = null;
			
			super.dispose();
		}
	}
}