/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 1 septembre 2013
*/
package com.ludofactory.mobile.core.notification.content.neww.highscore
{
	
	import com.freshplanet.nativeExtensions.AirNetworkInfo;
	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.AbstractGameInfo;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.manager.InfoContent;
	import com.ludofactory.mobile.core.manager.InfoManager;
	import com.ludofactory.mobile.core.notification.CustomPopupManager;
	import com.ludofactory.mobile.core.notification.content.*;
	import com.ludofactory.mobile.core.remoting.Remote;
	import com.ludofactory.mobile.core.theme.Theme;
	import com.ludofactory.mobile.navigation.authentication.RetryContainer;
	import com.ludofactory.mobileNew.IconButton;
	
	import feathers.controls.List;
	import feathers.controls.Scroller;
	import feathers.data.ListCollection;
	
	import starling.events.Event;
	import starling.text.TextField;
	import starling.text.TextFieldAutoSize;
	import starling.text.TextFormat;
	
	public class HighscoreRankingPopupContent extends AbstractPopupContent
	{
		/**
		 * Flag to indicate that the trophies list data provider have been updated. */
		public static const INVALIDATION_FLAG_TROPHIES:String = "trophies";
		
		/**
		 * The title. */		
		private var _notificationTitle:TextField;
		
		/**
		 * List containing all trophies for this game. */
		private var _rankingList:List;
		
		/**
		 * The retry container. */
		private var _retryContainer:RetryContainer;
		
		/**
		 * Game Center button. */
		private var _gameCenterButton:IconButton;
		
		public function HighscoreRankingPopupContent()
		{
			super();
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			data = false;
			
			_notificationTitle = new TextField(10, scaleAndRoundToDpi(45), _("Meilleurs scores"), new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(50), Theme.COLOR_DARK_GREY));
			_notificationTitle.autoScale = AbstractGameInfo.LANDSCAPE;
			_notificationTitle.autoSize = AbstractGameInfo.LANDSCAPE ? TextFieldAutoSize.NONE : TextFieldAutoSize.VERTICAL;
			addChild(_notificationTitle);
			
			if(!GlobalConfig.ios)
			{
				_gameCenterButton = new IconButton(null, null, AbstractEntryPoint.assets.getTexture("game-center-icon"));
				addChild(_gameCenterButton);
			}
			
			_retryContainer = new RetryContainer();
			_retryContainer.addEventListener(Event.TRIGGERED, onRetry);
			addChild(_retryContainer);
			
			_rankingList = new List();
			_rankingList.isSelectable = false;
			_rankingList.itemRendererType = HighscoreRankingItemRenderer;
			_rankingList.scrollBarDisplayMode = Scroller.SCROLL_BAR_DISPLAY_MODE_FLOAT;
			_rankingList.verticalScrollPolicy = Scroller.SCROLL_POLICY_AUTO;
			_rankingList.horizontalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			addChild(_rankingList);
			
			if(AirNetworkInfo.networkInfo.isConnected())
			{
				_retryContainer.loadingMode = true;
				Remote.getInstance().getDuelRanking(onGetDuelRankingSuccess, onGetDuelRankingFail, onGetDuelRankingFail, 1, "getDuelRanking");
			}
			else
			{
				_retryContainer.message = _("Aucune connexion Internet.\nVeuillez réessayer.");
				_retryContainer.loadingMode = false;
			}
		}
		
		override protected function draw():void
		{
			if( isInvalid(INVALIDATION_FLAG_SIZE) )
			{
				if(_gameCenterButton)
					_gameCenterButton.x = actualWidth - _gameCenterButton.width;
				
				_notificationTitle.width = this.actualWidth;
				if(_gameCenterButton) _notificationTitle.height = Math.max(_notificationTitle.height, _gameCenterButton.height);
				
				_retryContainer.width = actualWidth;
				_retryContainer.y = _notificationTitle.height + scaleAndRoundToDpi(5);
				_retryContainer.height = CustomPopupManager.maxContentHeight - _notificationTitle.height - scaleAndRoundToDpi(5);
				
				_rankingList.y = _notificationTitle.height + scaleAndRoundToDpi(5);
				_rankingList.width = this.actualWidth;
				_rankingList.height = CustomPopupManager.maxContentHeight - _rankingList.y;
			}
			
			super.draw();
		}
		
//------------------------------------------------------------------------------------------------------------
//	Handlers
		
		/**
		 * If an error occurred while retreiving the account informations or if
		 * the user was not connected when this componenent was created, we need
		 * to show a retry button so that he doesn't need to leave and come back
		 * to the view to load the data.
		 */
		private function onRetry(event:Event):void
		{
			if(AirNetworkInfo.networkInfo.isConnected())
			{
				_retryContainer.loadingMode = true;
				Remote.getInstance().getDuelRanking(onGetDuelRankingSuccess, onGetDuelRankingFail, onGetDuelRankingFail, 1, "getDuelRanking");
			}
			else
			{
				InfoManager.showTimed(_("Aucune connexion Internet."), InfoManager.DEFAULT_DISPLAY_TIME, InfoContent.ICON_CROSS);
			}
		}
		
		/**
		 * The trophies have been successfully fetched from the server, in this case we can update then in the
		 * local storage and then initialize the list.
		 *
		 * @param result
		 */
		private function onGetDuelRankingSuccess(result:Object):void
		{
			// TODO
			_rankingList.dataProvider = new ListCollection(  );
		}
		
		/**
		 * The trophies could not be updated, in this case we simply initialize the list with what we've stored
		 * previously in the local storage.
		 *
		 * @param error
		 */
		private function onGetDuelRankingFail(error:Object = null):void
		{
			_retryContainer.visible = true;
			_retryContainer.loadingMode = false;
			
			_retryContainer.message = _("Une erreur est survenue.\nVeuillez réessayer.");
			
			// FIXME DEBUG SEULEMENT
			var data:Array = [ new HighscoreRankingData({classement:1, isMembre:false, pseudo:"tata", score:159}),
				new HighscoreRankingData({classement:2, isMembre:true, pseudo:"toto", score:200}) ];
			_rankingList.dataProvider = new ListCollection(data);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
		
		override public function dispose():void
		{
			Remote.getInstance().clearAllRespondersOfScreen("getDuelRanking");
			
			_notificationTitle.removeFromParent(true);
			_notificationTitle = null;
			
			_retryContainer.removeEventListener(Event.TRIGGERED, onRetry);
			_retryContainer.removeFromParent(true);
			_retryContainer = null;
			
			super.dispose();
		}
	}
}