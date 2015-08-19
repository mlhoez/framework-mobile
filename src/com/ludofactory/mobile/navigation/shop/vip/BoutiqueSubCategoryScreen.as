/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 22 août 2013
*/
package com.ludofactory.mobile.navigation.shop.vip
{
	
	import com.freshplanet.nativeExtensions.AirNetworkInfo;
	import com.gamua.flox.Flox;
	import com.greensock.TweenMax;
	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.AbstractGameInfo;
	import com.ludofactory.mobile.core.ScreenIds;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.controls.AdvancedScreen;
	import com.ludofactory.mobile.core.manager.InfoContent;
	import com.ludofactory.mobile.core.manager.InfoManager;
	import com.ludofactory.mobile.core.manager.MemberManager;
	import com.ludofactory.mobile.core.notification.NotificationPopupManager;
	import com.ludofactory.mobile.core.notification.content.BoutiqueItemDetailNotificationContent;
	import com.ludofactory.mobile.core.remoting.Remote;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import feathers.controls.Button;
	import feathers.controls.GroupedList;
	import feathers.controls.ImageLoader;
	import feathers.controls.Label;
	import feathers.controls.List;
	import feathers.controls.Scroller;
	import feathers.controls.popups.IPopUpContentManager;
	import feathers.controls.popups.VerticalCenteredPopUpContentManager;
	import feathers.data.HierarchicalCollection;
	import feathers.data.ListCollection;
	import feathers.display.TiledImage;
	import feathers.layout.TiledRowsLayout;
	
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import starling.display.Quad;
	import starling.events.Event;
	
	public class BoutiqueSubCategoryScreen extends AdvancedScreen
	{
		/**
		 * The down arrow */		
		private var _arrowDown:ImageLoader;
		
		private var _subCategoryChoiceButton:Button;
		
		private var _arrowLeft:ImageLoader;
		private var _previousSubCatButton:Button;
		
		private var _arrowRight:ImageLoader;
		private var _nextSubCatButton:Button;
		
		/**
		 * The list shadow */		
		private var _listShadow:Quad;
		/**
		 * List */		
		private var _list:List;
		
		/**
		 * Array of sub categories */		
		private var _subCategories:Array;
		/**
		 * The sub categories list */		
		private var _subCategoriesList:GroupedList;
		/**
		 * The popup content manager used to display the sub categories. */		
		private var _popUpContentManager:IPopUpContentManager;
		
		/**
		 * The information label. */		
		private var _informationLabel:Label;
		
		public function BoutiqueSubCategoryScreen()
		{
			super();
			
			_fullScreen = false;
			_appClearBackground = false;
			_whiteBackground = true;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			_headerTitle = advancedOwner.screenData.categoryName;
			
			_arrowDown = new ImageLoader();
			_arrowDown.source = AbstractEntryPoint.assets.getTexture("arrow-down-dark");
			_arrowDown.scaleX = _arrowDown.scaleY = GlobalConfig.dpiScale;
			_arrowDown.snapToPixels = true;
			
			_subCategoryChoiceButton = new Button();
			_subCategoryChoiceButton.styleName = Theme.BUTTON_TRANSPARENT_BLUE;
			_subCategoryChoiceButton.defaultIcon = _arrowDown;
			_subCategoryChoiceButton.iconPosition = Button.ICON_POSITION_RIGHT;
			_subCategoryChoiceButton.addEventListener(Event.TRIGGERED, onShowSubCategoriesListing);
			addChild(_subCategoryChoiceButton);
			_subCategoryChoiceButton.minHeight = scaleAndRoundToDpi(70);
			_subCategoryChoiceButton.defaultLabelProperties.textFormat = new TextFormat(Theme.FONT_ARIAL, scaleAndRoundToDpi(26), Theme.COLOR_DARK_GREY, true, false, null, null, null, TextFormatAlign.CENTER);
			_subCategoryChoiceButton.paddingTop = _subCategoryChoiceButton.paddingBottom = (GlobalConfig.isPhone ? 10 : 30) * GlobalConfig.dpiScale;
			
			_arrowLeft = new ImageLoader();
			_arrowLeft.source = AbstractEntryPoint.assets.getTexture("arrow-left-dark");
			_arrowLeft.scaleX = _arrowLeft.scaleY = GlobalConfig.dpiScale;
			_arrowLeft.snapToPixels = true;
			
			_previousSubCatButton = new Button();
			_previousSubCatButton.addEventListener(Event.TRIGGERED, onPreviousSubCat);
			_previousSubCatButton.styleName = Theme.BUTTON_TRANSPARENT_BLUE;
			_previousSubCatButton.defaultIcon = _arrowLeft;
			addChild(_previousSubCatButton);
			_previousSubCatButton.minHeight = scaleAndRoundToDpi(70);
			_previousSubCatButton.paddingTop = _previousSubCatButton.paddingBottom = (GlobalConfig.isPhone ? 10 : 30) * GlobalConfig.dpiScale;
			_previousSubCatButton.visible = false;
			
			_arrowRight = new ImageLoader();
			_arrowRight.source = AbstractEntryPoint.assets.getTexture("arrow-right-dark");
			_arrowRight.scaleX = _arrowRight.scaleY = GlobalConfig.dpiScale;
			_arrowRight.snapToPixels = true;
			
			_nextSubCatButton = new Button();
			_nextSubCatButton.addEventListener(Event.TRIGGERED, onNextSubCat);
			_nextSubCatButton.styleName = Theme.BUTTON_TRANSPARENT_BLUE;
			_nextSubCatButton.defaultIcon = _arrowRight;
			addChild(_nextSubCatButton);
			_nextSubCatButton.minHeight = scaleAndRoundToDpi(70);
			_nextSubCatButton.paddingTop = _nextSubCatButton.paddingBottom = (GlobalConfig.isPhone ? 10 : 30) * GlobalConfig.dpiScale;
			_nextSubCatButton.visible = false;
			
			_listShadow = new Quad(50, scaleAndRoundToDpi(12), 0x000000);
			_listShadow.setVertexColor(0, 0xffffff);
			_listShadow.setVertexAlpha(0, 0);
			_listShadow.setVertexColor(1, 0xffffff);
			_listShadow.setVertexAlpha(1, 0);
			_listShadow.setVertexAlpha(2, 0.1);
			_listShadow.setVertexAlpha(3, 0.1);
			addChild(_listShadow);
			
			const listLayout:TiledRowsLayout = new  TiledRowsLayout();
			listLayout.paging = TiledRowsLayout.PAGING_NONE;
			listLayout.tileHorizontalAlign = TiledRowsLayout.TILE_HORIZONTAL_ALIGN_CENTER;
			listLayout.horizontalAlign = TiledRowsLayout.HORIZONTAL_ALIGN_CENTER;
			listLayout.useSquareTiles = false;
			listLayout.manageVisibility = true;
			
			_list = new List();
			_list.backgroundSkin = new TiledImage(AbstractEntryPoint.assets.getTexture("MenuTile"), GlobalConfig.dpiScale);
			_list.isSelectable = false;
			_list.layout = listLayout;
			_list.snapToPages = false;
			_list.itemRendererType = BoutiqueItemRenderer;
			_list.addEventListener(Event.CHANGE, onItemSelected);
			addChild(_list);
			
			_subCategoriesList = new GroupedList();
			_subCategoriesList.verticalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			_subCategoriesList.horizontalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			_subCategoriesList.styleName = Theme.SUB_CATEGORY_GROUPED_LIST;
			_subCategoriesList.typicalItem = { nom: "Item 1000" };
			_subCategoriesList.isSelectable = true;
			_subCategoriesList.itemRendererProperties.labelField = "nom";
			
			_informationLabel = new Label();
			_informationLabel.visible = false;
			addChild(_informationLabel);
			_informationLabel.textRendererProperties.textFormat = new TextFormat(Theme.FONT_ARIAL, scaleAndRoundToDpi(36), Theme.COLOR_DARK_GREY, true, true, null, null, null, TextFormatAlign.CENTER);
			
			const centerStage:VerticalCenteredPopUpContentManager = new VerticalCenteredPopUpContentManager();
			centerStage.marginTop = centerStage.marginRight = centerStage.marginBottom =
				centerStage.marginLeft = scaleAndRoundToDpi( GlobalConfig.isPhone ? 24:200 );
			_popUpContentManager = centerStage;
			
			InfoManager.show(_("Chargement..."));
			TweenMax.delayedCall(0.5, Remote.getInstance().getSubCategories, [advancedOwner.screenData.idCategory, null, onGetSubCategoriesSuccess, onGetSubCategoriesFailure, onGetSubCategoriesFailure, 2, advancedOwner.activeScreenID]);
		}
		
		override protected function draw():void
		{
			if( isInvalid(INVALIDATION_FLAG_SIZE) )
			{
				super.draw();
				
				//_subCategoryChoiceButton.width = this.actualWidth * 0.8;
				_subCategoryChoiceButton.validate();
				_subCategoryChoiceButton.x = (actualWidth - _subCategoryChoiceButton.width) * 0.5;
				_subCategoryChoiceButton.y = scaleAndRoundToDpi(AbstractGameInfo.LANDSCAPE ? (GlobalConfig.isPhone ? 10 : 40) : (GlobalConfig.isPhone ? 20 : 40));
				
				_previousSubCatButton.x = scaleAndRoundToDpi(10);
				_previousSubCatButton.y = _subCategoryChoiceButton.y;
				
				_nextSubCatButton.validate();
				_nextSubCatButton.x = actualWidth - _nextSubCatButton.width - scaleAndRoundToDpi(10);
				_nextSubCatButton.y = _subCategoryChoiceButton.y;
				
				_listShadow.y = _subCategoryChoiceButton.y + _subCategoryChoiceButton.height + scaleAndRoundToDpi(AbstractGameInfo.LANDSCAPE ? (GlobalConfig.isPhone ? 5 : 40) : (GlobalConfig.isPhone ? 20 : 40));
				_listShadow.width = actualWidth;
				
				_list.y = _listShadow.y + _listShadow.height;
				_list.width = actualWidth;
				_list.height = actualHeight - _list.y;
				
				_informationLabel.width = actualWidth * 0.8;
				_informationLabel.x = (actualWidth - _informationLabel.width) * 0.5;
				_informationLabel.y = _list.y + (_list.height - _informationLabel.height) * 0.5;
			}
		}
		
		override public function onBack():void
		{
			advancedOwner.screenData.idSubCategory = -1;
			advancedOwner.screenData.selectedItemData = null;
			
			if( NotificationPopupManager.isNotificationDisplaying )
			{
				NotificationPopupManager.closeNotification();
				return;
			}
			
			// FIXME A checker s'il faut le remettre
			//this.advancedOwner.screenData.idCategory = -1;
			if( !MemberManager.getInstance().getGiftsEnabled() )
			{
				// otherwise bug becasue back = BoutiqueHomeScreen and because it's not
				// a gift athorized account => BoutiqueHomeScreen redirects to here again
				advancedOwner.showScreen(ScreenIds.BOUTIQUE_HOME);
			}
			else
			{
				super.onBack();
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Handlers
//------------------------------------------------------------------------------------------------------------
		
		/**
		 * When the sub categories could be retreived.
		 */		
		private function onGetSubCategoriesSuccess(result:Object):void
		{
			if( result.code == 0 )
			{
				_subCategoryChoiceButton.visible = false;
				
				_list.y = 0;
				_list.height = actualHeight;
				
				// pas de lots
				_informationLabel.visible = true;
				_informationLabel.text = result.txt;
				_informationLabel.validate();
				_informationLabel.y = _list.y + (_list.height - _informationLabel.height) * 0.5;
			}
			else
			{
				_subCategories = [];
				_subCategories = (result.sous_rubrique as Array).concat();
				
				_previousSubCatButton.visible = _subCategories.length > 1;
				_nextSubCatButton.visible = _subCategories.length > 1;
				
				_subCategoriesList.dataProvider = new HierarchicalCollection([ { header: "", children: _subCategories } ]);
				_subCategoriesList.width = this.actualWidth * 0.8;
				_subCategoriesList.setSelectedLocation(0,0);
				_subCategoriesList.addEventListener(Event.CHANGE, onCategorySelected);
				
				//_subCategoryChoiceButton.label = formatText( Localizer.getInstance().translate("BOUTIQUE_SUB_CATEGORY_LIST_SCREEN.CHOICE_LIST_TITLE"), _subCategoriesList.selectedItem.nom);
				//_subCategoryChoiceButton.validate();
				//_subCategoryChoiceButton.x = (actualWidth - _subCategoryChoiceButton.width) * 0.5;
				
				if(_subCategories.length > 0)
					Flox.logInfo("Affichage de la sous catégorie <strong>{0}</strong>", _subCategoriesList.selectedItem.nom);
				//dispatchEventWith(LudoEventType.UPDATE_HEADER_TITLE, true, _subCategoriesList.selectedItem.nom);
				
				_subCategoryChoiceButton.label = _subCategoriesList.selectedItem.nom;
				_subCategoryChoiceButton.validate();
				_subCategoryChoiceButton.x = (actualWidth - _subCategoryChoiceButton.width) * 0.5;
				
				_informationLabel.visible = false;
				
				//if( result.hasOwnProperty("articles") && result.articles != null )
				//{
					var items:Vector.<BoutiqueItemData> = new Vector.<BoutiqueItemData>();
					var length:int = (result.articles as Array).length;
					var i:int = 0;
					for( i; i < length; i++)
						items.push( new BoutiqueItemData( result.articles[i] ) );
					
					_list.dataProvider = new ListCollection( items );
					_list.selectedIndex = -1;
				//}
			}
			
			if( advancedOwner.screenData.idSubCategory != -1 )
			{
				//Flox.logInfo("Affichage de la sous catégorie <strong>{0}</strong>", _subCategoriesList.selectedItem.nom);
				if( AirNetworkInfo.networkInfo.isConnected() )
				{
					Remote.getInstance().getSubCategories(this.advancedOwner.screenData.idCategory, advancedOwner.screenData.idSubCategory, onArticlesLoadSuccess, onArticlesLoadFailure, onArticlesLoadFailure, 2, advancedOwner.activeScreenID);
					advancedOwner.screenData.idSubCategory = -1;
				}
				else
				{
					InfoManager.hide(_("Aucune connexion Internet."), InfoContent.ICON_CROSS);
				}
				
			}
			else
			{
				InfoManager.hide(result.txt, InfoContent.ICON_CHECK, 1);
			}
		}
		
		/**
		 * An error occurred while retreiving the sub categories.
		 */		
		private function onGetSubCategoriesFailure(error:Object = null):void
		{
			this.isEnabled = true;
			InfoManager.hide(_("Une erreur est survenue, veuillez réessayer."), InfoContent.ICON_CHECK, InfoManager.DEFAULT_DISPLAY_TIME);
		}
		
		/**
		 * When an item is selected in the list, we display its
		 * properties in a notification.
		 */		
		private function onItemSelected(event:Event):void
		{
			Flox.logInfo("Affichage du lot <strong>{0} - {1}</strong>", BoutiqueItemData(event.data).id, BoutiqueItemData(event.data).title);
			advancedOwner.screenData.selectedItemData = BoutiqueItemData(event.data);
			//NotificationManager.addNotification( new BoutiqueItemDetailNotification( BoutiqueItemData(event.data) ), null, false );
			NotificationPopupManager.addNotification( new BoutiqueItemDetailNotificationContent( BoutiqueItemData(event.data) ) );
		}
		
		/**
		 * When a sub category is selected, we run a request to retreive
		 * its content (list of associated gifts).
		 */		
		private function onCategorySelected(event:Event):void
		{
			_popUpContentManager.close();
			InfoManager.show(_("Chargement..."));
			Flox.logInfo("Affichage de la sous catégorie <strong>{0}</strong>", _subCategoriesList.selectedItem.nom);
			advancedOwner.screenData.selectedItemData = null;
			
			if( AirNetworkInfo.networkInfo.isConnected() )
			{
				Remote.getInstance().getSubCategories(this.advancedOwner.screenData.idCategory, _subCategoriesList.selectedItem.id, onArticlesLoadSuccess, onArticlesLoadFailure, onArticlesLoadFailure, 2, advancedOwner.activeScreenID);
			}
			else
			{
				_subCategoriesList.setSelectedLocation(0, _oldSubSactegoryIndexSelected);
				InfoManager.hide(_("Aucune connexion Internet."), InfoContent.ICON_CROSS);
			}
		}
		
		/**
		 * Called when the articles of a sub category have successfully
		 * been loaded.
		 */		
		private function onArticlesLoadSuccess(result:Object):void
		{
			InfoManager.hide(result.txt, InfoContent.ICON_NOTHING, 0.5);
			
			if( _list.dataProvider != null )
				_list.dataProvider.removeAll();
			
			//_subCategoryChoiceButton.label = formatText( Localizer.getInstance().translate("BOUTIQUE_SUB_CATEGORY_LIST_SCREEN.CHOICE_LIST_TITLE"), _subCategoriesList.selectedItem.nom);
			//_subCategoryChoiceButton.validate();
			//_subCategoryChoiceButton.x = (actualWidth - _subCategoryChoiceButton.width) * 0.5;
			
			//dispatchEventWith(LudoEventType.UPDATE_HEADER_TITLE, true, _subCategoriesList.selectedItem.nom);
			
			advancedOwner.screenData.idSubCategory = _subCategoriesList.selectedItem.id;
			
			// FIXME Mettre à jour la liste ici pour sélectionner le bon index + màj du bouton du label
				
			_subCategoryChoiceButton.label = _subCategoriesList.selectedItem.nom;
			_subCategoryChoiceButton.validate();
			_subCategoryChoiceButton.x = (actualWidth - _subCategoryChoiceButton.width) * 0.5;
			
			if( result.code == 0 )
			{
				// pas de lots
				_informationLabel.visible = true;
				_informationLabel.text = result.txt;
				_informationLabel.validate();
				_informationLabel.y = _list.y + (_list.height - _informationLabel.height) * 0.5;
			}
			else
			{
				// bug visuel sinon 
				_informationLabel.visible = false;
				TweenMax.delayedCall(0, function():void
				{
					if( _list.dataProvider == null )
						_list.dataProvider = new ListCollection( [] );
					
					var length:int = (result.articles as Array).length;
					var i:int = 0;
					for( i; i < length; i++)
						_list.dataProvider.addItem( new BoutiqueItemData( result.articles[i] ) );
					_list.selectedIndex = -1;
					
					if( advancedOwner.screenData.selectedItemData != null )
					{
						//NotificationManager.addNotification( new BoutiqueItemDetailNotification( advancedOwner.screenData.selectedItemData ), null, false );
						NotificationPopupManager.addNotification( new BoutiqueItemDetailNotificationContent( advancedOwner.screenData.selectedItemData ) );
						advancedOwner.screenData.selectedItemData = null;
					}
				});
			}
		}
		
		/**
		 * An error occurred while trying to load the sub category articles.
		 */		
		private function onArticlesLoadFailure(error:Object = null):void
		{
			this.isEnabled = true;
			InfoManager.hide(_("Une erreur est survenue, veuillez réessayer."), InfoContent.ICON_CHECK, InfoManager.DEFAULT_DISPLAY_TIME);
		}
		
		/**
		 * Show the sub categories list.
		 */		
		private function onShowSubCategoriesListing(event:Event):void
		{
			if( !_subCategories || _subCategories.length == 0 )
			{
				InfoManager.showTimed(_("Aucune sous catégorie à afficher."), InfoManager.DEFAULT_DISPLAY_TIME, InfoContent.ICON_CROSS);
			}
			else
			{
				_oldSubSactegoryIndexSelected = _subCategoriesList.selectedItemIndex;
				_popUpContentManager.open(_subCategoriesList, this);
			}
		}
		
		private var _oldSubSactegoryIndexSelected:int;
		
		private function onPreviousSubCat(event:Event):void
		{
			InfoManager.show(_("Chargement..."));
			advancedOwner.screenData.idSubCategory = -1;
			advancedOwner.screenData.selectedItemData = null;
			
			if( !_subCategories || _subCategories.length == 0 )
			{
				InfoManager.showTimed(_("Aucune sous catégorie à afficher."), InfoManager.DEFAULT_DISPLAY_TIME, InfoContent.ICON_CROSS);
			}
			else
			{
				if( AirNetworkInfo.networkInfo.isConnected() )
				{
					_subCategoriesList.setSelectedLocation(0, (_subCategoriesList.selectedItemIndex == 0 ? (_subCategoriesList.dataProvider.data[0].children.length - 1) : (_subCategoriesList.selectedItemIndex - 1)));
					Flox.logInfo("Affichage de la sous catégorie <strong>{0}</strong>", _subCategoriesList.selectedItem.nom);
					Remote.getInstance().getSubCategories(this.advancedOwner.screenData.idCategory, ( _subCategoriesList.selectedItemIndex == 0 ? (_subCategoriesList.dataProvider.data[0].children.length - 1) : (_subCategoriesList.selectedItemIndex - 1) ), onArticlesLoadSuccess, onArticlesLoadFailure, onArticlesLoadFailure, 2, advancedOwner.activeScreenID);
				}
				else
				{
					InfoManager.hide(_("Aucune connexion Internet."), InfoContent.ICON_CROSS);
				}
			}
		}
		
		private function onNextSubCat(event:Event):void
		{
			InfoManager.show(_("Chargement..."));
			advancedOwner.screenData.idSubCategory = -1;
			advancedOwner.screenData.selectedItemData = null;
			
			if( !_subCategories || _subCategories.length == 0 )
			{
				InfoManager.showTimed(_("Aucune sous catégorie à afficher."), InfoManager.DEFAULT_DISPLAY_TIME, InfoContent.ICON_CROSS);
			}
			else
			{
				if( AirNetworkInfo.networkInfo.isConnected() )
				{
					_subCategoriesList.setSelectedLocation(0, (_subCategoriesList.selectedItemIndex == (_subCategoriesList.dataProvider.data[0].children.length - 1) ? 0 : (_subCategoriesList.selectedItemIndex + 1)));
					Flox.logInfo("Affichage de la sous catégorie <strong>{0}</strong>", _subCategoriesList.selectedItem.nom);
					Remote.getInstance().getSubCategories(this.advancedOwner.screenData.idCategory, ( (_subCategoriesList.selectedItemIndex == (_subCategoriesList.dataProvider.data[0].children.length - 1) ? 0 : (_subCategoriesList.selectedItemIndex + 1)) ), onArticlesLoadSuccess, onArticlesLoadFailure, onArticlesLoadFailure, 2, advancedOwner.activeScreenID);
				}
				else
				{
					InfoManager.hide(_("Aucune connexion Internet."), InfoContent.ICON_CROSS);
				}
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
//------------------------------------------------------------------------------------------------------------
		
		override public function dispose():void
		{
			if( AbstractEntryPoint.screenNavigator.activeScreenID != ScreenIds.AUTHENTICATION_SCREEN )
			{
				AbstractEntryPoint.screenNavigator.screenData.idSubCategory = -1;
				AbstractEntryPoint.screenNavigator.screenData.selectedItemData = null;
			}
			
			_arrowDown.removeFromParent(true);
			_arrowDown = null;
			
			_subCategoryChoiceButton.removeEventListener(Event.TRIGGERED, onShowSubCategoriesListing);
			_subCategoryChoiceButton.removeFromParent(true);
			_subCategoryChoiceButton = null;
			
			_arrowLeft.removeFromParent(true);
			_arrowLeft = null;
			
			_previousSubCatButton.removeEventListener(Event.TRIGGERED, onPreviousSubCat);
			_previousSubCatButton.removeFromParent(true);
			_previousSubCatButton = null;
			
			_arrowRight.removeFromParent(true);
			_arrowRight = null;
			
			_nextSubCatButton.removeEventListener(Event.TRIGGERED, onNextSubCat);
			_nextSubCatButton.removeFromParent(true);
			_nextSubCatButton = null;
			
			_list.removeEventListener(Event.CHANGE, onItemSelected);
			_list.removeFromParent(true);
			_list = null;
			
			if( _subCategories )
			{
				_subCategories.length = 0;
				_subCategories = null;
			}
			
			_subCategoriesList.removeEventListener(Event.CHANGE, onCategorySelected);
			_subCategoriesList.removeFromParent(true);
			_subCategoriesList = null;
			
			_popUpContentManager.close();
			_popUpContentManager.dispose();
			_popUpContentManager = null;
			
			super.dispose();
		}
	}
}