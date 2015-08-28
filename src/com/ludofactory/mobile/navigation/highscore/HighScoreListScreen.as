/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 13 sept. 2013
*/
package com.ludofactory.mobile.navigation.highscore
{
	import com.freshplanet.nativeExtensions.AirNetworkInfo;
	import com.greensock.TweenMax;
	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.manager.MemberManager;
	import com.ludofactory.mobile.navigation.authentication.RetryContainer;
	import com.ludofactory.mobile.core.controls.AdvancedScreen;
	import com.ludofactory.mobile.core.controls.ArrowGroup;
	import com.ludofactory.mobile.core.controls.AutoRefreshableList;
	import com.ludofactory.mobile.core.events.MobileEventTypes;
	import com.ludofactory.mobile.core.manager.InfoContent;
	import com.ludofactory.mobile.core.manager.InfoManager;
	import com.ludofactory.mobile.core.remoting.Remote;
	import com.ludofactory.mobile.navigation.FacebookManager;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.theme.Theme;
	import com.milkmangames.nativeextensions.GAnalytics;
	
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import feathers.controls.GroupedList;
	import feathers.controls.Label;
	import feathers.controls.Scroller;
	import feathers.controls.popups.IPopUpContentManager;
	import feathers.controls.popups.VerticalCenteredPopUpContentManager;
	import feathers.data.HierarchicalCollection;
	import feathers.data.ListCollection;
	import feathers.layout.VerticalLayout;
	
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.QuadBatch;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	
	public class HighScoreListScreen extends AdvancedScreen
	{
		/**
		 * Country choice background */		
		private var _countryChoiceBackground:QuadBatch;
		/**
		 * Country choice container */		
		private var _countryChoiceContainer:Sprite;
		/**
		 * Country choice title */		
		private var _countryChoiceTitle:Label;
		/**
		 * Country choice value */		
		private var _countryChoiceValue:Label;
		/**
		 * The down arrow */		
		private var _arrowDown:Image;
		/**
		 * The list shadow */		
		private var _listShadow:Quad;
		
		/**
		 * The list header. */		
		private var _listHeader:HighScoreListHeader;
		/**
		 * HighScore list. */		
		private var _list:AutoRefreshableList;
		
		/**
		 * The sub categories list */		
		private var _countriesList:GroupedList;
		/**
		 * The popup content manager used to display the sub categories. */		
		private var _popUpContentManager:IPopUpContentManager;
		
		/**
		 * The selected country id (default is 0 : international). */		
		private var _selectedCountryId:int = 0;
		
		/**
		 * The retry container. */		
		private var _retryContainer:RetryContainer;
		
		/**
		 * Whether the user is in update mode. */		
		private var _isInUpdateMode:Boolean = false;
		
		
		/**
		 * Associate label. */		
		private var _associateLabel:Label;
		/**
		 * Associate button. */		
		private var _associateButton:ArrowGroup;
		
		public function HighScoreListScreen()
		{
			super();
			
			_whiteBackground = true;
			_appClearBackground = false;
			_fullScreen = false;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			_headerTitle = _("Meilleurs scores");
			
			_listHeader = new HighScoreListHeader();
			_listHeader.visible = false;
			addChild(_listHeader);
			
			_list = new AutoRefreshableList();
			_list.isSelectable = false;
			_list.visible = false;
			_list.itemRendererType = HighScoreItemRenderer;
			_list.addEventListener(MobileEventTypes.LIST_BOTTOM_UPDATE, onBottomUpdate);
			_list.addEventListener(MobileEventTypes.LIST_TOP_UPDATE, onTopUpdate);
			addChild(_list);
			
			_countriesList = new GroupedList();
			_countriesList.verticalScrollPolicy = Scroller.SCROLL_POLICY_AUTO;
			_countriesList.horizontalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			_countriesList.styleName = Theme.SUB_CATEGORY_GROUPED_LIST;
			_countriesList.isSelectable = true;
			var arr:Array = GlobalConfig.COUNTRIES.concat();
			arr.push(new CountryData( { id:-1, nameTranslationKey:_("Amis Facebook"), diminutive:"", textureName:"" } ));
			_countriesList.dataProvider = new HierarchicalCollection([ { header: "", children:arr } ]);
			_countriesList.setSelectedLocation(0,advancedOwner.screenData.highscoreRankingType == -1 ? (arr.length-1) : advancedOwner.screenData.highscoreRankingType);
			_countriesList.addEventListener(Event.CHANGE, onCountrySelected);
			
			_countryChoiceBackground = new QuadBatch();
			_countryChoiceBackground.addEventListener(TouchEvent.TOUCH, onShowCountries);
			const qd:Quad = new Quad(50, scaleAndRoundToDpi(74), 0xfbfbfb);
			_countryChoiceBackground.addQuad(qd);
			qd.height = scaleAndRoundToDpi(4);
			qd.color = 0xe6e6e6;
			qd.y = scaleAndRoundToDpi(74);
			_countryChoiceBackground.addQuad(qd);
			addChild(_countryChoiceBackground);
			
			_countryChoiceContainer = new Sprite();
			_countryChoiceContainer.touchable = false;
			addChild(_countryChoiceContainer);
			
			_countryChoiceTitle = new Label();
			_countryChoiceTitle.text = _("Pays : ");
			_countryChoiceContainer.addChild( _countryChoiceTitle );
			_countryChoiceTitle.textRendererProperties.textFormat = new TextFormat(Theme.FONT_ARIAL, scaleAndRoundToDpi(28), Theme.COLOR_DARK_GREY, true, false, null, null, null, TextFormatAlign.RIGHT);
			_countryChoiceTitle.textRendererProperties.wordWrap = false;
			
			_countryChoiceValue = new Label();
			_countryChoiceValue.text = arr[advancedOwner.screenData.highscoreRankingType == -1 ? (arr.length-1) : advancedOwner.screenData.highscoreRankingType];
			_countryChoiceContainer.addChild( _countryChoiceValue );
			_countryChoiceValue.textRendererProperties.textFormat = new TextFormat(Theme.FONT_ARIAL, scaleAndRoundToDpi(28), Theme.COLOR_LIGHT_GREY, true);
			_countryChoiceValue.textRendererProperties.wordWrap = false;
			
			_arrowDown = new Image( AbstractEntryPoint.assets.getTexture("arrow_down") );
			_arrowDown.scaleX = _arrowDown.scaleY = GlobalConfig.dpiScale;
			addChild(_arrowDown);
			
			_listShadow = new Quad(50, scaleAndRoundToDpi(12), 0x000000);
			_listShadow.setVertexAlpha(0, 0.1);
			_listShadow.setVertexAlpha(1, 0.1);
			_listShadow.setVertexAlpha(2, 0);
			_listShadow.setVertexColor(2, 0xffffff);
			_listShadow.setVertexAlpha(3, 0);
			_listShadow.setVertexColor(3, 0xffffff);
			addChild(_listShadow);
			
			const vlayout:VerticalLayout = new VerticalLayout();
			vlayout.horizontalAlign = VerticalLayout.HORIZONTAL_ALIGN_CENTER;
			vlayout.verticalAlign = VerticalLayout.VERTICAL_ALIGN_MIDDLE;
			vlayout.padding = scaleAndRoundToDpi(20);
			vlayout.gap = scaleAndRoundToDpi(40);
			
			const centerStage:VerticalCenteredPopUpContentManager = new VerticalCenteredPopUpContentManager();
			centerStage.marginTop = centerStage.marginRight = centerStage.marginBottom =
				centerStage.marginLeft = scaleAndRoundToDpi( GlobalConfig.isPhone ? 24:200 );
			_popUpContentManager = centerStage;
			
			_retryContainer = new RetryContainer();
			_retryContainer.addEventListener(Event.TRIGGERED, onRetry);
			addChild(_retryContainer);
			
			_associateButton = new ArrowGroup( _("Associer mon compte à Facebook") );
			_associateButton.visible = false;
			addChild(_associateButton);
			
			_associateLabel = new Label();
			_associateLabel.text = _("Vous devez associer votre compte à Facebook pour voir la progression de vos amis !");
			_associateLabel.visible = false;
			addChild(_associateLabel);
			_associateLabel.textRendererProperties.textFormat = new TextFormat(Theme.FONT_ARIAL, scaleAndRoundToDpi(GlobalConfig.isPhone ? 30 : 38), Theme.COLOR_LIGHT_GREY, true, true, null, null, null, TextFormatAlign.CENTER);
			
			_selectedCountryId = advancedOwner.screenData.highscoreRankingType;
			
			FacebookManager.getInstance().addEventListener(FacebookManager.ACCOUNT_ASSOCIATED, launchRequestAfterSuccessLoginFacebook);
			FacebookManager.getInstance().addEventListener(FacebookManager.AUTHENTICATED, launchRequestAfterSuccessLoginFacebook);
			
			if( AirNetworkInfo.networkInfo.isConnected() )
			{
				if( _selectedCountryId == -1 )
					connectFacebook();
				else
					TweenMax.delayedCall(0.5, Remote.getInstance().getHighScoreRanking, [_selectedCountryId, onGetHighScoreRankingSuccess, onGetHighScoreRankingFailure, onGetHighScoreRankingFailure, 2, advancedOwner.activeScreenID]);
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
				_countryChoiceBackground.width = this.actualWidth;
				
				_countryChoiceTitle.validate();
				_countryChoiceValue.validate();
				_countryChoiceValue.x = _countryChoiceTitle.width;
				_countryChoiceContainer.y = (_countryChoiceBackground.height - _countryChoiceContainer.height) * 0.5;
				_countryChoiceContainer.x = (this.actualWidth - _countryChoiceContainer.width) * 0.5;
				_arrowDown.x = this.actualWidth - _arrowDown.width - scaleAndRoundToDpi(30);
				_arrowDown.y = _countryChoiceBackground.y + (_countryChoiceBackground.height - _arrowDown.height) * 0.5;
				
				_countryChoiceValue.validate();
				_countryChoiceContainer.x = (this.actualWidth - _countryChoiceContainer.width) * 0.5;
				
				_listShadow.width = this.actualWidth;
				_listShadow.y = _countryChoiceBackground.height;
				
				_listHeader.width = this.actualWidth;
				_listHeader.y = _countryChoiceBackground.height;
				_listHeader.validate();
				
				_list.y = _listHeader.y + _listHeader.height;
				_list.width = this.actualWidth;
				_list.height = this.actualHeight - _list.y;
				
				_countriesList.width = this.actualWidth * 0.8;
				
				_retryContainer.width = actualWidth;
				_retryContainer.height = actualHeight - _listHeader.y;
				_retryContainer.y = _listHeader.y;
				
				_associateButton.validate();
				_associateButton.x = (actualWidth - _associateButton.width) * 0.5;
				_associateButton.y = ((actualHeight - _list.y) - _associateButton.height) * 0.5 + _list.y + scaleAndRoundToDpi(10);
				
				_associateLabel.width = actualWidth * 0.8;
				_associateLabel.validate();
				_associateLabel.x = (actualWidth - _associateLabel.width) * 0.5;
				_associateLabel.y = _associateButton.y - _associateLabel.height - scaleAndRoundToDpi(10);
			}
			
			super.draw();
		}
		
//------------------------------------------------------------------------------------------------------------
//	Handlers
//------------------------------------------------------------------------------------------------------------
		
		/**
		 * When the sub categories could be retreived.
		 */		
		private function onGetHighScoreRankingSuccess(result:Object):void
		{
			switch(result.code)
			{
				case 0: // invalid data
				case 2: // le tableau de correspondance des ids jeu n'existe pas
				case 3: // impossible de récupérer le classement du joueur
				case 4: // [Facebook] impossible de recuperer vos informations fb
				case 6: // id pays incorrecte (n'existe pas en base)
				{
					if( !_isInUpdateMode )
					{
						_retryContainer.loadingMode = false;
						_retryContainer.singleMessageMode = true;
						_retryContainer.message = result.txt;
					}
					else
					{
						if( result.code == 3 )
						{
							// no more players
							if( result.queryName == "LudoMobile.useClass.HighScore.getClassementSup" || result.queryName == "LudoMobile.useClass.HighScore.getClassementFacebookSup" )
								_list.isRefreshableTop = false;
							else
								_list.isRefreshableDown = false;
						}
					}
					
					break;
				}
				case 1: // ok
				{
					var len:int = (result.classement as Array).length;
					var i:int = 0;
					var newDataProvider:Array = [];
					
					if( !_isInUpdateMode )
					{
						if( _list.dataProvider )
							_list.dataProvider.removeAll();
					}
					
					if( len == 0 )
					{
						if( !_isInUpdateMode )
						{
							_retryContainer.loadingMode = false;
							_retryContainer.singleMessageMode = true;
							_retryContainer.message = _("Aucun joueur n'est classé\ndans ce pays.");
						}
						_list.isRefreshableDown = false;
						_list.isRefreshableTop = false;
					}
					else
					{
						_retryContainer.visible = false;
						_list.visible = true;
						_listHeader.visible = true;
						
						if( !_list.dataProvider || _list.dataProvider.data.length == 0 )
						{
							// first add
							for( i; i < len; i++)
								newDataProvider.push( new HighScoreData( result.classement[i] ) );
							
							_list.dataProvider = new ListCollection( newDataProvider );
							
							_list.isRefreshableDown = true;
							_list.isRefreshableTop = true;
							
							findMe();
						}
						else
						{
							for( i; i < len; i++)
								newDataProvider.push( new HighScoreData( result.classement[i] ) );
							
							if( result.queryName == "LudoMobile.useClass.HighScore.getClassementSup" || result.queryName == "LudoMobile.useClass.HighScore.getClassementFacebookSup")
							{
								//newDataProvider.reverse();
								_list.dataProvider.addAllAt( new ListCollection( newDataProvider ), 0);
							}
							else
							{
								_list.dataProvider.addAll( new ListCollection( newDataProvider ) );
							}
							_list.invalidate( INVALIDATION_FLAG_DATA );
						}
					}
					
					break;
				}
					
				default:
				{
					onGetHighScoreRankingFailure();
					break;
				}
			}
			
			if( _isInUpdateMode )
			{
				if( result.queryName == "LudoMobile.useClass.HighScore.getClassementSup" || result.queryName == "LudoMobile.useClass.HighScore.getClassementFacebookSup" )
					_list.onTopAutoUpdateFinished();
				else
					_list.onBottomAutoUpdateFinished();
			}
		}
		
		/**
		 * An error occurred while retreiving the sub categories.
		 */		
		private function onGetHighScoreRankingFailure(error:Object = null):void
		{
			if( error.queryName == "LudoMobile.useClass.HighScore.getClassementInf" || error.queryName == "LudoMobile.useClass.HighScore.getClassementFacebookInf" )
				_list.isRefreshableDown = false;
			else
				_list.isRefreshableTop = false;
			
			if( !_isInUpdateMode )
			{
				_retryContainer.message = _("Une erreur est survenue, veuillez réessayer.");
				_retryContainer.loadingMode = false;
			}
		}
		
		/**
		 * If an error occurred while retreiving the high score ranking
		 * or if the user was not connected when this componenent was created,
		 * we need to show a retry button so that he doesn't need to leave and
		 * come back to the view to load the list.
		 */		
		private function onRetry(event:Event = null):void
		{
			if( AirNetworkInfo.networkInfo.isConnected() )
			{
				_associateButton.visible = false;
				_associateLabel.visible = false;
				_retryContainer.loadingMode = true;
				if( _selectedCountryId == -1 )
					connectFacebook();
				else
					Remote.getInstance().getHighScoreRanking(_selectedCountryId, onGetHighScoreRankingSuccess, onGetHighScoreRankingFailure, onGetHighScoreRankingFailure, 2, advancedOwner.activeScreenID);
			}
			else
			{
				InfoManager.showTimed(_("Aucune connexion Internet."), InfoManager.DEFAULT_DISPLAY_TIME, InfoContent.ICON_CROSS);
			}
		}
		
		private function launchRequestAfterSuccessLoginFacebook(event:Event):void
		{
			if( AirNetworkInfo.networkInfo.isConnected() )
			{
				_associateButton.visible = false;
				_associateLabel.visible = false;
				_retryContainer.visible = true;
				_retryContainer.loadingMode = true;
				Remote.getInstance().getHighScoreRanking(_selectedCountryId, onGetHighScoreRankingSuccess, onGetHighScoreRankingFailure, onGetHighScoreRankingFailure, 2, advancedOwner.activeScreenID);
			}
			else
			{
				InfoManager.showTimed(_("Aucune connexion Internet."), InfoManager.DEFAULT_DISPLAY_TIME, InfoContent.ICON_CROSS);
			}
		}
		
		/**
		 * Show all the available countries.
		 */		
		private function onShowCountries(event:TouchEvent):void
		{
			var touch:Touch = event.getTouch(this);
			if( touch && touch.phase == TouchPhase.ENDED)
				_popUpContentManager.open(_countriesList, this);
			touch = null;
		}
		
		/**
		 * When a country is selected, we launch a request the get the
		 * global ranking for this contry.
		 */		
		private function onCountrySelected(event:Event):void
		{
			_popUpContentManager.close();
			
			_list.visible = false;
			_listHeader.visible = false;
			_retryContainer.loadingMode = true;
			_retryContainer.visible = true;
			
			_countryChoiceValue.text = _countriesList.selectedItem.toString();
			_selectedCountryId = _countriesList.selectedItem.id;
			
			if( GAnalytics.isSupported() )
				GAnalytics.analytics.defaultTracker.trackEvent("HighScores", "Affichage du classement " + _countryChoiceValue, null, NaN, MemberManager.getInstance().id);
			
			_isInUpdateMode = false;
			
			Remote.getInstance().clearAllRespondersOfScreen(advancedOwner.activeScreenID);
			_associateButton.visible = false;
			_associateLabel.visible = false;
			_associateButton.removeEventListener(Event.TRIGGERED, onAuthenticateFacebook);
			_associateButton.removeEventListener(Event.TRIGGERED, onAssociateAccount);
			if( _selectedCountryId == -1 )
			{
				connectFacebook();
			}
			else
			{
				if( AirNetworkInfo.networkInfo.isConnected() )
				{
					Remote.getInstance().getHighScoreRanking(_selectedCountryId, onGetHighScoreRankingSuccess, onGetHighScoreRankingFailure, onGetHighScoreRankingFailure, 2, advancedOwner.activeScreenID);
				}
				else
				{
					_retryContainer.loadingMode = false;
					_retryContainer.message = _("Vous ne pouvez pas afficher le contenu de cette page car vous n'êtes pas connecté à Internet.");
					_retryContainer.singleMessageMode = false;
				}
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
			var rankData:HighScoreData = HighScoreData(_list.dataProvider.getItemAt(_list.dataProvider.length - 1));
			Remote.getInstance().getHighScoreRankingInf(rankData.date, rankData.score, rankData.rank, _selectedCountryId, onGetHighScoreRankingSuccess, onGetHighScoreRankingFailure, onGetHighScoreRankingFailure, 2, advancedOwner.activeScreenID);
		}
		/**
		 * The user scrolled until the end of the list. In this case
		 * we launch an update to retreive the next 20 elements.
		 */		
		private function onTopUpdate(event:Event):void
		{
			_isInUpdateMode = true;
			var rankData:HighScoreData = HighScoreData(_list.dataProvider.getItemAt(0));
			Remote.getInstance().getHighScoreRankingSup(rankData.date, rankData.score, rankData.rank, _selectedCountryId, onGetHighScoreRankingSuccess, onGetHighScoreRankingFailure, onGetHighScoreRankingFailure, 2, advancedOwner.activeScreenID);
		}
		
		private function findMe():void
		{
			var len:int = _list.dataProvider.length;
			var rankData:HighScoreData;
			for(var i:int = 0; i < len; i++)
			{
				rankData = HighScoreData(_list.dataProvider.getItemAt(i));
				if( rankData.isMe )
					_list.scrollToDisplayIndex(i, 0);
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Facebook
		
		private function getToken(event:Event):void
		{
			FacebookManager.getInstance().getToken();
		}
		
		private function onAuthenticateFacebook(event:Event):void
		{
			FacebookManager.getInstance().register();
		}
		
		private function onAssociateAccount(event:Event):void
		{
			FacebookManager.getInstance().associate();
		}
		
		/**
		 * Publish on Facebook wall.
		 */		
		private function connectFacebook():void
		{
			_retryContainer.message = _("Vous ne pouvez pas afficher le contenu de cette page car vous n'êtes pas connecté à Internet.");
			_retryContainer.singleMessageMode = false;
			
			if( MemberManager.getInstance().isLoggedIn() )
			{
				if( MemberManager.getInstance().facebookId != 0 )
				{
					// check session first (if the Facebook ids are matching)
					_retryContainer.visible = false;
					_associateButton.visible = true;
					_associateLabel.visible = true;
					
					_associateButton.addEventListener(Event.TRIGGERED, getToken);
					
					_associateButton.label = _("Se connecter avec Facebook");
					_associateLabel.text = _("Connectez-vous avec Facebook pour voir la progression de vos amis !");
					
					invalidate(INVALIDATION_FLAG_SIZE);
					
					FacebookManager.getInstance().getToken();
				}
				else
				{
					// association
					_retryContainer.visible = false;
					_associateButton.visible = true;
					_associateLabel.visible = true;
					
					_associateButton.label = _("Associer mon compte à Facebook");
					_associateLabel.text = _("Vous devez associer votre compte à Facebook pour voir la progression de vos amis !");
					_associateButton.addEventListener(Event.TRIGGERED, onAssociateAccount);
					
					invalidate(INVALIDATION_FLAG_SIZE);
				}
			}
			else
			{
				// login or register
				_retryContainer.visible = false;
				_associateButton.visible = true;
				_associateLabel.visible = true;
				
				_associateButton.label = _("Se connecter avec Facebook");
				_associateLabel.text = _("Connectez-vous avec Facebook pour voir la progression de vos amis !");
				_associateButton.addEventListener(Event.TRIGGERED, onAuthenticateFacebook);
				
				invalidate(INVALIDATION_FLAG_SIZE);
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
		
		override public function dispose():void
		{
			FacebookManager.getInstance().removeEventListener(FacebookManager.ACCOUNT_ASSOCIATED, launchRequestAfterSuccessLoginFacebook);
			FacebookManager.getInstance().removeEventListener(FacebookManager.AUTHENTICATED, launchRequestAfterSuccessLoginFacebook);
			
			_associateButton.removeEventListener(Event.TRIGGERED, onAuthenticateFacebook);
			_associateButton.removeEventListener(Event.TRIGGERED, onAssociateAccount);
			_associateButton.removeEventListener(Event.TRIGGERED, getToken);
			_associateButton.removeFromParent(true);
			_associateButton = null;
			
			_countryChoiceBackground.removeEventListener(TouchEvent.TOUCH, onShowCountries);
			_countryChoiceBackground.reset();
			_countryChoiceBackground.removeFromParent(true);
			_countryChoiceBackground = null;
			
			_countryChoiceTitle.removeFromParent(true);
			_countryChoiceTitle = null;
			
			_countryChoiceValue.removeFromParent(true);
			_countryChoiceValue = null;
			
			_countryChoiceContainer.removeFromParent(true);
			_countryChoiceContainer = null;
			
			_arrowDown.removeFromParent(true);
			_arrowDown = null;
			
			_listHeader.removeFromParent(true);
			_listHeader = null;
			
			_list.removeEventListener(MobileEventTypes.LIST_BOTTOM_UPDATE, onBottomUpdate);
			_list.removeEventListener(MobileEventTypes.LIST_TOP_UPDATE, onTopUpdate);
			_list.removeFromParent(true);
			_list = null;
			
			_countriesList.removeEventListener(Event.CHANGE, onCountrySelected);
			_countriesList.removeFromParent(true);
			_countriesList = null;
			
			_popUpContentManager.close();
			_popUpContentManager.dispose();
			_popUpContentManager = null;
			
			_listShadow.removeFromParent(true);
			_listShadow = null;
			
			super.dispose();
		}
	}
}