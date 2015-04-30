/*
Copyright © 2006-2015 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 18 sept. 2013
*/
package com.ludofactory.mobile.navigation.news
{
	import com.freshplanet.nativeExtensions.AirNetworkInfo;
	import com.greensock.TweenMax;
	import com.ludofactory.common.gettext.LanguageManager;
	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractGameInfo;
	import com.ludofactory.mobile.core.controls.AdvancedScreen;
	import com.ludofactory.mobile.core.ScreenIds;
	import com.ludofactory.mobile.core.remoting.Remote;
	import com.ludofactory.mobile.core.storage.Storage;
	import com.ludofactory.mobile.core.storage.StorageConfig;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import feathers.controls.Button;
	import feathers.controls.ImageLoader;
	import feathers.controls.Label;
	import feathers.controls.List;
	import feathers.controls.ScrollContainer;
	import feathers.controls.Scroller;
	import feathers.controls.supportClasses.ListDataViewPort;
	import feathers.data.ListCollection;
	import feathers.layout.VerticalLayout;
	
	import starling.core.Starling;
	import starling.display.MovieClip;
	import starling.events.Event;
	import starling.utils.formatString;
	
	public class NewsScreen extends AdvancedScreen
	{
		/**
		 * The main container. */		
		private var _mainCcontainer:ScrollContainer;
		/**
		 * The games list. */		
		private var _gamesList:List;
		/**
		 * The logo. */		
		private var _logo:ImageLoader;
		/**
		 * The copyright label. */		
		private var _copyrightLabel:Label;
		/**
		 * The cgu label. */		
		private var _cguLabel:Button;
		/**
		 * The version label. */		
		private var _versionLabel:Label;
		
		/**
		 * The loader. */		
		private var _loader:MovieClip;
		
		public function NewsScreen()
		{
			super();
			
			_appClearBackground = false;
			_whiteBackground = true;
			_fullScreen = false;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			_headerTitle = _("Nouveautés");
			
			_loader = new MovieClip( Theme.blackLoaderTextures );
			_loader.scaleX = _loader.scaleY = GlobalConfig.dpiScale;
			_loader.alignPivot();
			Starling.juggler.add(_loader);
			addChild(_loader);
			
			const vlayoutBis:VerticalLayout = new VerticalLayout();
			vlayoutBis.horizontalAlign = VerticalLayout.HORIZONTAL_ALIGN_CENTER;
			vlayoutBis.verticalAlign = VerticalLayout.VERTICAL_ALIGN_TOP;
			vlayoutBis.paddingTop = vlayoutBis.paddingBottom = scaleAndRoundToDpi(14);
			vlayoutBis.gap = scaleAndRoundToDpi(20);
			
			_mainCcontainer = new ScrollContainer();
			_mainCcontainer.visible = false;
			_mainCcontainer.verticalScrollPolicy = Scroller.SCROLL_POLICY_AUTO;
			_mainCcontainer.horizontalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			_mainCcontainer.layout = vlayoutBis;
			addChild(_mainCcontainer);
			
			_logo = new ImageLoader();
			_logo.source = Theme.ludokadoLogoTexture;
			_logo.textureScale = GlobalConfig.dpiScale;
			_logo.snapToPixels = true;
			_mainCcontainer.addChild( _logo );
			
			_gamesList = new List();
			_gamesList.verticalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			_gamesList.horizontalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			_gamesList.isSelectable = false;
			_gamesList.itemRendererType = NewsItemRenderer;
			_mainCcontainer.addChild(_gamesList);
			
			_copyrightLabel = new Label();
			_copyrightLabel.text = formatString(_("Ludokado site de la société LudoFactory\nCopyright {0} ADThink Media"), new Date().fullYear) + "\n\n"
					+ (GlobalConfig.ios ? _("Tous les jeux gratuits sans obligation d'achat présents dans cette application sont organisés par la société LudoFactory. La société Apple Inc. n'est ni partenaire, ni sponsor, ni impliquée dans l'organisation de ces jeux. Pour plus d'informations, voir le règlement complet dans l'application.")
					: _("Tous les jeux gratuits sans obligation d'achat présents dans cette application sont organisés par la société LudoFactory. Pour plus d'informations, voir le règlement complet dans l'application.") );
			_mainCcontainer.addChild(_copyrightLabel);
			_copyrightLabel.textRendererProperties.textFormat = new TextFormat(Theme.FONT_ARIAL, scaleAndRoundToDpi(24), Theme.COLOR_LIGHT_GREY, true, true, null, null, null, TextFormatAlign.CENTER);
			
			_cguLabel = new Button();
			_cguLabel.label = _("CGU");
			_cguLabel.styleName = Theme.BUTTON_EMPTY;
			_cguLabel.addEventListener(Event.TRIGGERED, onTouchCgu);
			_mainCcontainer.addChild(_cguLabel);
			_cguLabel.minHeight = _cguLabel.minTouchHeight = scaleAndRoundToDpi(50);
			_cguLabel.defaultLabelProperties.textFormat = new TextFormat(Theme.FONT_ARIAL, scaleAndRoundToDpi(24), Theme.COLOR_DARK_GREY, true, true, null, null, null, TextFormatAlign.CENTER);
			
			_versionLabel = new Label();
			_versionLabel.text = formatString( _("Version {0}"), AbstractGameInfo.GAME_VERSION);
			_mainCcontainer.addChild(_versionLabel);
			_versionLabel.textRendererProperties.textFormat = new TextFormat(Theme.FONT_ARIAL, scaleAndRoundToDpi(20), Theme.COLOR_LIGHT_GREY, true, true, null, null, null, TextFormatAlign.CENTER);
			
			if( AirNetworkInfo.networkInfo.isConnected() )
			{
				TweenMax.delayedCall(0.5, Remote.getInstance().getNews, [onGetNewsSuccess, onGetNewsFailure, onGetNewsFailure, 1, advancedOwner.activeScreenID]);
			}
			else
			{
				initializeContent();
			}
		}
		
		override protected function draw():void
		{
			if( isInvalid(INVALIDATION_FLAG_SIZE) )
			{
				_loader.x = this.actualWidth * 0.5;
				_loader.y = this.actualHeight * 0.5;
				
				_mainCcontainer.width = this.actualWidth;
				_mainCcontainer.height = this.actualHeight;
				
				if( AbstractGameInfo.LANDSCAPE )
					_logo.height = actualHeight * 0.4;
				else
					_logo.width = actualWidth * (GlobalConfig.isPhone ? 0.65 : 0.75);
				
				_gamesList.width = this.actualWidth;
				_gamesList.validate();
				
				_copyrightLabel.width = _cguLabel.width = _versionLabel.width = this.actualWidth * 0.9;
			}
		}
		
		private function initializeContent():void
		{
			_mainCcontainer.visible = true;
			_loader.visible = false;
			
			var news:Array = JSON.parse( Storage.getInstance().getProperty( StorageConfig.PROPERTY_NEWS )[LanguageManager.getInstance().lang] ) as Array;
			
			var formattedNews:Array = [];
			for(var i:int = 0; i < news.length; i++)
				formattedNews.push( new NewsData( news[i] ) );
			
			_gamesList.dataProvider = new ListCollection( formattedNews );
			
			var len:int = (_gamesList.viewPort as ListDataViewPort).numChildren;
			var gameItemRenderer:NewsItemRenderer;
			for(i = 0; i < len; i++)
			{
				gameItemRenderer = NewsItemRenderer( (_gamesList.viewPort as ListDataViewPort).getChildAt(i) );
				_mainCcontainer.addEventListener(Event.SCROLL, gameItemRenderer.onScroll);
			}
			gameItemRenderer = null;
		}
		
//------------------------------------------------------------------------------------------------------------
//	Handlers
//------------------------------------------------------------------------------------------------------------
		
		/**
		 * The news have been returned. We update the content stored internally
		 * and then intialize the screen.
		 */		
		private function onGetNewsSuccess(result:Object):void
		{
			if( result != null && result.hasOwnProperty("tab_actualites") && result.tab_actualites )
				Storage.getInstance().updateNews(result);
			
			initializeContent();
		}
		
		/**
		 * We could not get the news, then we load the default ones (the last
		 * saved).
		 */		
		private function onGetNewsFailure(error:Object = null):void
		{
			initializeContent();
		}
		
		/**
		 * Link to the CGU screen.
		 */		
		private function onTouchCgu(event:Event):void
		{
			advancedOwner.showScreen(ScreenIds.CGU_SCREEN);
			//navigateToURL( new URLRequest("http://www.ludokado.com/reglement-ludokado.html") );
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
//------------------------------------------------------------------------------------------------------------
		
		override public function dispose():void
		{
			_versionLabel.removeFromParent(true);
			_versionLabel = null;
			
			_cguLabel.removeEventListener(Event.TRIGGERED, onTouchCgu);
			_cguLabel.removeFromParent(true);
			_cguLabel = null;
			
			_copyrightLabel.removeFromParent(true);
			_copyrightLabel = null;
			
			_logo.removeFromParent(true);
			_logo = null;
			
			var len:int = (_gamesList.viewPort as ListDataViewPort).numChildren;
			var gameItemRenderer:NewsItemRenderer;
			for(var i:int = 0; i < len; i++)
			{
				gameItemRenderer = NewsItemRenderer( (_gamesList.viewPort as ListDataViewPort).getChildAt(i) );
				_mainCcontainer.removeEventListener(Event.SCROLL, gameItemRenderer.onScroll);
			}
			gameItemRenderer = null;
			_gamesList.removeFromParent(true);
			_gamesList = null;
			
			Starling.juggler.remove(_loader);
			_loader.removeFromParent(true);
			_loader = null;
			
			super.dispose();
		}
	}
}