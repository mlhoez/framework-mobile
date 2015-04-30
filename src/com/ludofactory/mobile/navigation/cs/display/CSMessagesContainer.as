/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 22 août 2013
*/
package com.ludofactory.mobile.navigation.cs.display
{
	import com.freshplanet.nativeExtensions.AirNetworkInfo;
	import com.greensock.TweenMax;
	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.manager.MemberManager;
	import com.ludofactory.mobile.navigation.authentication.NotLoggedInContainer;
	import com.ludofactory.mobile.navigation.authentication.RetryContainer;
	import com.ludofactory.mobile.core.controls.PullToRefreshList;
	import com.ludofactory.mobile.core.events.LudoEventType;
	import com.ludofactory.mobile.core.manager.InfoContent;
	import com.ludofactory.mobile.core.manager.InfoManager;
	import com.ludofactory.mobile.core.remoting.Remote;
	
	import feathers.core.FeathersControl;
	import feathers.data.ListCollection;
	
	import starling.events.Event;
	
	/**
	 * A container displaying customer service messages.
	 * 
	 * <p>This container is initialized with a type of messages
	 * to load, whether pending or solved messages.</p>
	 * 
	 * @see com.ludofactory.mobile.features.customerservice.CSState
	 */	
	public class CSMessagesContainer extends FeathersControl
	{
		/**
		 * The state of the messages to retreive. This variable
		 * can have two values : CSState.PENDING or CSState.SOLVED.
		 * @see com.ludofactory.mobile.features.customerservice.CSState */		
		private var _state:int;
		
		/**
		 * The messages list. */		
		private var _list:PullToRefreshList;
		
		/**
		 * The authentication container. */		
		private var _authenticationContainer:NotLoggedInContainer;
		/**
		 * The retry container. */		
		private var _retryContainer:RetryContainer;
		
		public function CSMessagesContainer(CSState:int)
		{
			super();
			
			_state = CSState;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			_list = new PullToRefreshList();
			_list.paddingTop = 10;
			_list.isSelectable = true;
			_list.visible = false;
			_list.itemRendererType = CSMessageItemRenderer;
			_list.addEventListener(Event.CHANGE, onItemSelected);
			_list.addEventListener(LudoEventType.REFRESH_TOP, onRefreshTop);
			addChild(_list);
			
			_authenticationContainer = new NotLoggedInContainer();
			_authenticationContainer.visible = false;
			addChild(_authenticationContainer);
			
			_retryContainer = new RetryContainer();
			_retryContainer.addEventListener(Event.TRIGGERED, onRetry);
			_retryContainer.visible = true;
			addChild(_retryContainer);
			
			if( MemberManager.getInstance().isLoggedIn() )
			{
				if( AirNetworkInfo.networkInfo.isConnected() )
					Remote.getInstance().getCustomerServiceThreads(_state, onGetMessagesSuccess, onGetMessagesFailure, onGetMessagesFailure, 2, AbstractEntryPoint.screenNavigator.activeScreenID);
				else
					_retryContainer.loadingMode = false;
			}
			else
			{
				_retryContainer.visible = false;
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
		 * The messages could be retreived but few cases here :
		 * 
		 * <p><strong>There was an error executing the request</strong>,
		 * thus we need to display the error message and a retry button.</p>
		 * 
		 * <p><strong>There were no messages to load</strong>, thus we only
		 * need to display a message indicating this fact.</p>
		 * 
		 * <p><strong>All the messages could be loaded, thus we hide every 
		 * ui component except the list, which will be initialized with the 
		 * loaded content.</p>
		 */		
		private function onGetMessagesSuccess(result:Object):void
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
					// reset alerts
					AbstractEntryPoint.alertData.numCustomerServiceAlerts = 0;
					AbstractEntryPoint.alertData.numCustomerServiceImportantAlerts = 0;
					if( MemberManager.getInstance().isLoggedIn() && AirNetworkInfo.networkInfo.isConnected() )
						Remote.getInstance().initCustomerService(null, null, null, 2, AbstractEntryPoint.screenNavigator.activeScreenID);
					
					if( (result.liste as Array).length == 0 )
					{
						// no messages
						
						_retryContainer.loadingMode = false;
						_retryContainer.singleMessageMode = true;
						_retryContainer.message = _("Aucune conversation à afficher.");
						_list.visible = false;
					}
					else
					{
						_retryContainer.visible = false;
						_list.visible = true;
						
						if( _list.dataProvider )
							_list.dataProvider.removeAll();
						
						// bug visuel sinon 
						TweenMax.delayedCall(0, function():void
						{
							var i:int = 0;
							var len:int = (result.liste as Array).length;
							var provider:Array = [];
							for( i; i < len; i++)
								provider.push( new CSMessageData( result.liste[i], _state ) );
							_list.dataProvider = new ListCollection( provider );
							_list.selectedIndex = -1;
						});
					}
					
					break;
				}
					
				default:
				{
					onGetMessagesFailure();
					break;
				}
			}
		}
		
		/**
		 * There was an error while trying to retreive the messages.
		 * 
		 * <p>In this case we display an error message and a button to retry.</p>
		 */		
		private function onGetMessagesFailure(error:Object = null):void
		{
			_list.onRefreshComplete();
			
			_retryContainer.message = _("Une erreur est survenue, veuillez réessayer.");
			_retryContainer.loadingMode = false;
		}
		
		/**
		 * If an error occurred while retreiving the messages or if the
		 * user was not connected when this componenent was created,
		 * we need to show a retry button so that he doesn't need to
		 * leave and come back to the view to load the messages.
		 */		
		private function onRetry(event:Event):void
		{
			if( AirNetworkInfo.networkInfo.isConnected() )
			{
				_retryContainer.loadingMode = true;
				Remote.getInstance().getCustomerServiceThreads(_state, onGetMessagesSuccess, onGetMessagesFailure, onGetMessagesFailure, 2, AbstractEntryPoint.screenNavigator.activeScreenID);
			}
			else
			{
				InfoManager.showTimed(_("Aucune connexion Internet."), InfoManager.DEFAULT_DISPLAY_TIME, InfoContent.ICON_CROSS);
			}
		}
		
		/**
		 * When an item is selected in the list, the component dispatches
		 * an event to the parent (which is the CSHomeScreen) which display
		 * the associated conversation in a new screen.
		 */		
		private function onItemSelected(event:Event):void
		{
			dispatchEvent(event);
		}
		
		/**
		 * The user requested a refresh of the list.
		 */		
		private function onRefreshTop():void
		{
			Remote.getInstance().getCustomerServiceThreads(_state, onGetMessagesSuccess, onGetMessagesFailure, onGetMessagesFailure, 2, AbstractEntryPoint.screenNavigator.activeScreenID);
		}
		
		/**
		 * This function is meant to be called outside by the CSHomeScreen when
		 * a new thread have been created, so that we can refresh the view and
		 * display the new message in the list.
		 */		
		public function refreshList():void
		{
			if( MemberManager.getInstance().isLoggedIn() )
			{
				_retryContainer.visible = true;
				_retryContainer.loadingMode = true;
				_list.visible = false;
				onRefreshTop();
			}
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
			
			_list.removeEventListener(Event.CHANGE, onItemSelected);
			_list.removeEventListener(LudoEventType.REFRESH_TOP, onRefreshTop);
			_list.removeFromParent(true);
			_list = null;
			
			super.dispose();
		}
	}
}