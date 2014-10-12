/*
Copyright © 2006-2014 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 17 sept. 2013
*/
package com.ludofactory.mobile.navigation.account.history.payments
{
	import com.freshplanet.nativeExtensions.AirNetworkInfo;
	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.manager.MemberManager;
	import com.ludofactory.mobile.navigation.authentication.NotLoggedInContainer;
	import com.ludofactory.mobile.navigation.authentication.RetryContainer;
	import com.ludofactory.mobile.core.controls.CustomGroupedList;
	import com.ludofactory.mobile.core.manager.InfoContent;
	import com.ludofactory.mobile.core.manager.InfoManager;
	import com.ludofactory.mobile.core.remoting.Remote;
	import com.ludofactory.mobile.navigation.account.history.HistoryHeaderItemRenderer;
	
	import feathers.core.FeathersControl;
	import feathers.data.HierarchicalCollection;
	
	import starling.events.Event;
	
	/**
	 * A container displaying the account payments history.
	 */	
	public class PaymentsHistoryContainer extends FeathersControl
	{
		/**
		 * The payments list. */		
		private var _list:CustomGroupedList;
		
		/**
		 * The authentication container. */		
		private var _authenticationContainer:NotLoggedInContainer;
		/**
		 * The retry container. */		
		private var _retryContainer:RetryContainer;
		
		public function PaymentsHistoryContainer()
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
			_list.itemRendererType = PaymentHistoryItemRenderer;
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
					Remote.getInstance().getPaymentsHistory(onGetMessagesSuccess, onGetMessagesFailure, onGetMessagesFailure, 2, AbstractEntryPoint.screenNavigator.activeScreenID);
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
		 * The payments could be retreived.
		 * 
		 * <p>Because the request is heavy, we only display the
		 * last 20 elements from the history. We don't allow the
		 * user to request an update or load the next payments by
		 * scrolling at the end of the list.</p>
		 */		
		private function onGetMessagesSuccess(result:Object):void
		{
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
				case 2: // aucun paiement
				{
					_retryContainer.loadingMode = false;
					_retryContainer.singleMessageMode = true;
					_retryContainer.message = result.txt;
					_list.visible = false;
					
					break;
				}
				case 1: // success
				{
					if( result.historique_paiement.length == 0 )
					{
						// no messages
						
						_retryContainer.loadingMode = false;
						_retryContainer.singleMessageMode = true;
						_retryContainer.message = _("Vous n'avez pas encore acheté\nde Crédits sur l'application.");
						_list.visible = false;
					}
					else
					{
						_retryContainer.visible = false;
						_list.visible = true;
						
						var dp:Array = [];
						var tempChildren:Array = [];
						var len:int = result.historique_paiement.length;
						var childrenLen:int;
						for(var i:int = 0; i < len; i++)
						{
							tempChildren = [];
							childrenLen = result.historique_paiement[i][1].length;
							for(var j:int = 0; j < childrenLen; j++)
							{
								tempChildren.push( new PaymentHistoryData( result.historique_paiement[i][1][j] ) );
							}
							dp.push( { header:result.historique_paiement[i][0], children:tempChildren } );
						}
						_list.dataProvider = new HierarchicalCollection( dp );
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
		 * There was an error while trying to retreive the payments history.
		 * 
		 * <p>In this case we display an error message and a button to retry.</p>
		 */		
		private function onGetMessagesFailure(error:Object = null):void
		{
			_retryContainer.message = _("Une erreur est survenue, veuillez réessayer.");
			_retryContainer.loadingMode = false;
		}
		
		/**
		 * If an error occurred while retreiving the payments history or if the
		 * user was not connected when this componenent was created, we need to
		 * show a retry button so that he doesn't need to leave and come back to
		 * the view to load the messages.
		 */		
		private function onRetry(event:Event):void
		{
			if( AirNetworkInfo.networkInfo.isConnected() )
			{
				_retryContainer.loadingMode = true;
				Remote.getInstance().getPaymentsHistory(onGetMessagesSuccess, onGetMessagesFailure, onGetMessagesFailure, 2, AbstractEntryPoint.screenNavigator.activeScreenID);
			}
			else
			{
				InfoManager.showTimed(_("Aucune connexion Internet."), InfoManager.DEFAULT_DISPLAY_TIME, InfoContent.ICON_CROSS);
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
			
			_list.removeFromParent(true);
			_list = null;
			
			super.dispose();
		}
	}
}