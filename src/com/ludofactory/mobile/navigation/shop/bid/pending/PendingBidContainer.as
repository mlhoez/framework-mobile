/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 26 août 2013
*/
package com.ludofactory.mobile.navigation.shop.bid.pending
{
	import com.freshplanet.nativeExtensions.AirNetworkInfo;
	import com.greensock.TweenMax;
	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.navigation.authentication.RetryContainer;
	import com.ludofactory.mobile.core.controls.PullToRefreshList;
	import com.ludofactory.mobile.core.events.LudoEventType;
	import com.ludofactory.mobile.core.manager.InfoContent;
	import com.ludofactory.mobile.core.manager.InfoManager;
	import com.ludofactory.mobile.core.remoting.Remote;
	
	import feathers.core.FeathersControl;
	import feathers.data.ListCollection;
	import feathers.layout.TiledRowsLayout;
	
	import starling.events.Event;
	
	public class PendingBidContainer extends FeathersControl
	{
		/**
		 * Pending bid list */		
		private var _list:PullToRefreshList;
		
		/**
		 * The retry container. */		
		private var _retryContainer:RetryContainer;
		
		public function PendingBidContainer()
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
			listLayout.useVirtualLayout = false; // necessary because of the timer
			
			_list = new PullToRefreshList();
			_list.layout = listLayout;
			_list.isSelectable = false;
			_list.paddingTop = scaleAndRoundToDpi(5);
			_list.itemRendererType = PendingBidItemRenderer;
			_list.addEventListener(LudoEventType.REFRESH_TOP, onRefreshTop);
			_list.addEventListener(Event.CHANGE, onItemSelected);
			addChild(_list);
			
			_retryContainer = new RetryContainer();
			_retryContainer.addEventListener(Event.TRIGGERED, onRetry);
			_retryContainer.visible = true;
			addChild(_retryContainer);
			
			if( AirNetworkInfo.networkInfo.isConnected() )
				Remote.getInstance().getPendingBids(onGetPendingEncheresSuccess, onGetPendingEncheresFailure, onGetPendingEncheresFailure, 2, AbstractEntryPoint.screenNavigator.activeScreenID);
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
				Remote.getInstance().getPendingBids(onGetPendingEncheresSuccess, onGetPendingEncheresFailure, onGetPendingEncheresFailure, 2, AbstractEntryPoint.screenNavigator.activeScreenID);
			}
			else
			{
				InfoManager.showTimed(_("Aucune connexion Internet."), InfoManager.DEFAULT_DISPLAY_TIME, InfoContent.ICON_CROSS);
			}
		}
		
		/**
		 * The refresh was requested by the user by scrolling up the list,
		 * in this case, we need to send a request to retreive a fresher
		 * content.
		 */		
		private function onRefreshTop(event:Event = null):void
		{
			Remote.getInstance().getPendingBids(onGetPendingEncheresSuccess, onGetPendingEncheresFailure, onGetPendingEncheresFailure, 2, AbstractEntryPoint.screenNavigator.activeScreenID);
		}
		
		/**
		 * The pending encheres have been returned, if 
		 */		
		private function onGetPendingEncheresSuccess(result:Object):void
		{
			if(result.code == 0)
			{
				_retryContainer.visible = true;
				_retryContainer.loadingMode = false;
				_retryContainer.message = result.txt;
				return;
			}
			
			_list.onRefreshComplete();
			
			if( _list.dataProvider )
				_list.dataProvider.removeAll();
			
			_retryContainer.visible = false;
			
			TweenMax.delayedCall(0, function():void
			{
				var i:int = 0;
				var len:int = (result.enchere_encours as Array).length;
				var arr:Array = [];
				for( i; i < len; i++)
					arr.push( new PendingBidItemData(result.enchere_encours[i]) );
				_list.dataProvider = new ListCollection( arr );
				_list.selectedIndex = -1;
			});
		}
		
		private function onGetPendingEncheresFailure(error:Object = null):void
		{
			_list.onRefreshComplete();
			
			// if something have been loaded before, this means that
			// all the ui elements have been removed, thus, we don't
			// need to display the message and button, we just leave
			// the list as it was before the call.
			
			if( !_list.dataProvider || _list.dataProvider.length == 0 )
			{
				_retryContainer.message = _("Une erreur est survenue, veuillez réessayer.");
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
		
		public function refreshList():void
		{
			onRefreshTop();
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