/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 8 oct. 2013
*/
package com.ludofactory.mobile.navigation.sponsor.filleuls
{
	import com.freshplanet.nativeExtensions.AirNetworkInfo;
	import com.greensock.TweenMax;
	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.manager.MemberManager;
	import com.ludofactory.mobile.navigation.authentication.NotLoggedInContainer;
	import com.ludofactory.mobile.navigation.authentication.RetryContainer;
	import com.ludofactory.mobile.core.controls.AdvancedScreen;
	import com.ludofactory.mobile.core.manager.InfoContent;
	import com.ludofactory.mobile.core.manager.InfoManager;
	import com.ludofactory.mobile.core.remoting.Remote;
	
	import feathers.controls.List;
	import feathers.data.ListCollection;
	import feathers.layout.VerticalLayout;
	
	import starling.display.Quad;
	import starling.events.Event;
	
	public class FilleulsScreen extends AdvancedScreen
	{
		/**
		 * The list. */		
		private var _list:List;
		
		/**
		 * The authentication container. */		
		private var _authenticationContainer:NotLoggedInContainer;
		
		/**
		 * The retry container. */		
		private var _retryContainer:RetryContainer;
		
		public function FilleulsScreen()
		{
			super();
			
			_whiteBackground = true;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			_headerTitle = _("Suivi de mes filleuls");
			
			const vlayout:VerticalLayout = new VerticalLayout();
			vlayout.useVirtualLayout = false;
			
			_list = new List();
			_list.visible = false;
			_list.layout = vlayout;
			_list.backgroundSkin = new Quad(50, 50);
			_list.isSelectable = false;
			_list.itemRendererType = FilleulItemRenderer;
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
					TweenMax.delayedCall(1, Remote.getInstance().getFilleuls, [onGetFilleulsSuccess, onGetFilleulsFailure, onGetFilleulsFailure, 2, advancedOwner.activeScreenID]);
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
				_list.height = this.actualHeight - _list.y;
				
				_authenticationContainer.width = _retryContainer.width = actualWidth;
				_authenticationContainer.height = _retryContainer.height = actualHeight;
			}
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
		private function onGetFilleulsSuccess(result:Object):void
		{
			switch(result.code)
			{
				case 0: // invalid data
				{
					_retryContainer.loadingMode = false;
					_retryContainer.singleMessageMode = true;
					_retryContainer.message = result.txt;
					_list.visible = false;
					
					break;
				}
				case 1: // success
				{
					// reset alerts - le reset en base est fait dans la fonction suivi_filleul directement
					AbstractEntryPoint.alertData.numSponsorAlerts = 0;
					
					if( (result.filleuls as Array).length == 0 )
					{
						// no messages
						
						_retryContainer.loadingMode = false;
						_retryContainer.singleMessageMode = true;
						_retryContainer.message = _("Vous n'avez encore aucun filleul.");
						_list.visible = false;
					}
					else
					{
						_retryContainer.visible = false;
						_list.visible = true;
						
						_list.dataProvider = new ListCollection();
						for each(var filleulData:Object in result.filleuls)
						{
							_list.dataProvider.addItem( new FilleulData( filleulData ) );
						}
					}
					
					break;
				}
					
				default:
				{
					onGetFilleulsFailure();
					break;
				}
			}
		}
		
		/**
		 * There was an error while trying to retreive the account informations.
		 * 
		 * <p>In this case we display an error message and a button to retry.</p>
		 */		
		private function onGetFilleulsFailure(error:Object = null):void
		{
			_retryContainer.message = _("Une erreur est survenue, veuillez réessayer.");
			_retryContainer.loadingMode = false;
		}
		
		/**
		 * If an error occurred while retreiving the account informations or if
		 * the user was not connected when this componenent was created, we need
		 * to show a retry button so that he doesn't need to leave and come back
		 * to the view to load the data.
		 */		
		private function onRetry(event:Event):void
		{
			if( AirNetworkInfo.networkInfo.isConnected() )
			{
				_retryContainer.loadingMode = true;
				Remote.getInstance().getFilleuls(onGetFilleulsSuccess, onGetFilleulsFailure, onGetFilleulsFailure, 2, advancedOwner.activeScreenID);
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