/*
Copyright © 2006-2014 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 27 août 2013
*/
package com.ludofactory.mobile.core.shop.bid.finished
{
	import com.freshplanet.nativeExtensions.AirNetworkInfo;
	import com.greensock.TweenMax;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.Localizer;
	import com.ludofactory.mobile.core.authentication.RetryContainer;
	import com.ludofactory.mobile.core.controls.PullToRefreshList;
	import com.ludofactory.mobile.core.events.LudoEventType;
	import com.ludofactory.mobile.core.manager.InfoContent;
	import com.ludofactory.mobile.core.manager.InfoManager;
	import com.ludofactory.mobile.core.remoting.Remote;
	
	import feathers.core.FeathersControl;
	import feathers.data.ListCollection;
	import feathers.layout.TiledRowsLayout;
	
	import starling.events.Event;
	
	public class FinishedBidContainer extends FeathersControl
	{
		/**
		 * Finished encheres list */		
		private var _list:PullToRefreshList;
		
		/**
		 * The retry container. */		
		private var _retryContainer:RetryContainer;
		
		public function FinishedBidContainer()
		{
			super();
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			const listLayout:TiledRowsLayout = new  TiledRowsLayout();
			listLayout.paging = TiledRowsLayout.PAGING_NONE;
			listLayout.tileHorizontalAlign = TiledRowsLayout.TILE_HORIZONTAL_ALIGN_CENTER;
			listLayout.horizontalAlign = TiledRowsLayout.HORIZONTAL_ALIGN_CENTER;
			listLayout.useSquareTiles = false;
			listLayout.manageVisibility = true;
			listLayout.useVirtualLayout = true;
			
			_list = new PullToRefreshList();
			_list.layout = listLayout;
			_list.isSelectable = false;
			_list.paddingTop = scaleAndRoundToDpi(5);
			_list.itemRendererType = FinishedBidItemRenderer;
			_list.addEventListener(LudoEventType.REFRESH_TOP, onRefreshTop);
			_list.addEventListener(Event.CHANGE, onItemSelected);
			addChild(_list);
			
			_retryContainer = new RetryContainer();
			_retryContainer.addEventListener(Event.TRIGGERED, onRetry);
			_retryContainer.visible = true;
			addChild(_retryContainer);
			
			if( AirNetworkInfo.networkInfo.isConnected() )
				Remote.getInstance().getFinishedBids(onGetFinishedBidsSuccess, onGetFinishedBidsFailure, onGetFinishedBidsFailure, 2, AbstractEntryPoint.screenNavigator.activeScreenID);
			else
				_retryContainer.loadingMode = false;
		}
		
		override protected function draw():void
		{
			super.draw();
			
			_list.width = _retryContainer.width = actualWidth;
			_list.height = _retryContainer.height = actualHeight;
		}
		
//-----------------------------------------------------------------------------------------------------------
//	Handlers
//------------------------------------------------------------------------------------------------------------
		
		/**
		 * The user was not connected when this content was displayed, thus
		 * we could not retreive the pending encheres. This button will try
		 * to send the request again so that we can display the content.
		 */		
		private function onRetry(event:Event):void
		{
			if( AirNetworkInfo.networkInfo.isConnected() )
			{
				_retryContainer.loadingMode = true;
				Remote.getInstance().getFinishedBids(onGetFinishedBidsSuccess, onGetFinishedBidsFailure, onGetFinishedBidsFailure, 2, AbstractEntryPoint.screenNavigator.activeScreenID);
			}
			else
			{
				InfoManager.showTimed(Localizer.getInstance().translate("COMMON.NOT_CONNECTED"), InfoManager.DEFAULT_DISPLAY_TIME, InfoContent.ICON_CROSS);
			}
		}
		
		/**
		 * The refresh was requested by the user by scrolling up the list,
		 * in this case, we need to send a request to retreive a fresher
		 * content.
		 */		
		private function onRefreshTop(event:Event):void
		{
			Remote.getInstance().getFinishedBids(onGetFinishedBidsSuccess, onGetFinishedBidsFailure, onGetFinishedBidsFailure, 2, AbstractEntryPoint.screenNavigator.activeScreenID);
		}
		
		/**
		 * The pending encheres have been returned, if 
		 */		
		private function onGetFinishedBidsSuccess(result:Object):void
		{
			_list.onRefreshComplete();
			
			if( _list.dataProvider )
				_list.dataProvider.removeAll();
			
			_retryContainer.visible = false;
			
			TweenMax.delayedCall(0, function():void
			{
				var i:int = 0;
				var len:int = (result.enchere_terminer as Array).length;
				var arr:Array = [];
				for( i; i < len; i++)
					arr.push( new FinishedBidItemData(result.enchere_terminer[i]) );
				_list.dataProvider = new ListCollection( arr );
				_list.selectedIndex = -1;
			});
		}
		
		private function onGetFinishedBidsFailure(error:Object = null):void
		{
			_list.onRefreshComplete();
			
			// if something have been loaded before, this means that
			// all the ui elements have been removed, thus, we don't
			// need to display the message and button, we just leave
			// the list as it was before the call.
			
			if( !_list.dataProvider || _list.dataProvider.length == 0 )
			{
				_retryContainer.message = Localizer.getInstance().translate("COMMON.QUERY_FAILURE");
				_retryContainer.loadingMode = false;
			}
		}
		
		private function onItemSelected(event:Event):void
		{
			// use this one if the list is selectable and the touchHander in the item renderer
			// does not dispatch an event but just sets isSelected to true
			//dispatchEventWith(Event.CHANGE, false, _list.selectedItem);
			dispatchEventWith(Event.CHANGE, false, event.data);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
//------------------------------------------------------------------------------------------------------------
		
		override public function dispose():void
		{
			_retryContainer.removeEventListener(Event.TRIGGERED, onRetry);
			_retryContainer.removeFromParent(true);
			_retryContainer = null;
			
			_list.removeEventListener(Event.CHANGE, onItemSelected);
			_list.removeEventListener(LudoEventType.REFRESH_TOP, onRefreshTop);
			_list.removeFromParent(true);
			_list = null;
			
			super.dispose();
		}
	}
}