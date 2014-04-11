/*
Copyright © 2006-2014 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 9 oct. 2013
*/
package com.ludofactory.mobile.core.controls
{
	import com.greensock.TweenMax;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.Localizer;
	import com.ludofactory.mobile.core.events.LudoEventType;
	import com.ludofactory.mobile.core.storage.Storage;
	import com.ludofactory.mobile.core.storage.StorageConfig;
	import com.ludofactory.mobile.core.test.config.GlobalConfig;
	import com.ludofactory.mobile.core.test.home.summary.SummaryContainer;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import flash.text.TextFormat;
	
	import feathers.controls.Button;
	import feathers.controls.ImageLoader;
	import feathers.controls.Label;
	import feathers.controls.ScrollContainer;
	import feathers.core.FeathersControl;
	import feathers.display.Scale3Image;
	import feathers.textures.Scale3Textures;
	
	import starling.core.Starling;
	import starling.display.BlendMode;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	
	public class Footer extends FeathersControl
	{
		private var _iconPadding:int;
		private var _decorationPadding:int;
		/**
		 * The base background. */		
		private var _backgroundImage:Scale3Image;
		
		private var _shadow:Scale3Image;
		
		
		private var _top:Scale3Image;
		
		/**
		 * The back button. */		
		private var _backButton:Button;
		/**
		 * The back icon. */		
		private var _backIcon:ImageLoader;
		
		/**
		 * The news button. */		
		private var _newsButton:Button;
		/**
		 * The news icon. */		
		private var _newsIcon:ImageLoader;
		
		/**
		 * The menu button. */		
		private var _menuButton:Button;
		/**
		 * The menu icon. */		
		private var _menuIcon:ImageLoader;
		
		/**
		 * The left decorations. */		
		private var _decorationLeft:ImageLoader;
		/**
		 * The right decorations. */		
		private var _decorationRight:ImageLoader;
		
		/**
		 * The summary container. */		
		private var _summaryContainer:SummaryContainer;
		
		public function Footer()
		{
			super();
			
			_iconPadding = scaleAndRoundToDpi(10);
			_decorationPadding = scaleAndRoundToDpi(4);
			this.height = scaleAndRoundToDpi(118);
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			// TODO Faire un simple scale9Image pour tout (ou presque) le footer pour optimiser ?
			
			_backgroundImage = new Scale3Image( new Scale3Textures(AbstractEntryPoint.assets.getTexture("footer-background-skin"), 10, 10), GlobalConfig.dpiScale );
			_backgroundImage.touchable = false;
			_backgroundImage.blendMode = BlendMode.NONE;
			addChild(_backgroundImage);
			
			_shadow = new Scale3Image( new Scale3Textures(AbstractEntryPoint.assets.getTexture("footer-shadow"), 30, 60), GlobalConfig.dpiScale );
			_shadow.touchable = false;
			//_shadow.blendMode = BlendMode.NONE;
			addChild(_shadow);
			
			_top = new Scale3Image( new Scale3Textures(AbstractEntryPoint.assets.getTexture("footer-top"), 60, 60), GlobalConfig.dpiScale );
			_top.touchable = false;
			//_top.blendMode = BlendMode.NONE
			addChild(_top);
			
			_backIcon = new ImageLoader();
			_backIcon.source = AbstractEntryPoint.assets.getTexture("footer-back-icon");
			_backIcon.scaleX = _backIcon.scaleY = GlobalConfig.dpiScale;
			_backIcon.snapToPixels = true;
			
			_backButton = new Button();
			_backButton.nameList.add( Theme.BUTTON_EMPTY );
			_backButton.defaultIcon = _backIcon;
			_backButton.addEventListener(Event.TRIGGERED, onBackButtonTouched);
			addChild(_backButton);
			
			_newsIcon = new ImageLoader();
			_newsIcon.source = AbstractEntryPoint.assets.getTexture("footer-news-icon");
			_newsIcon.scaleX = _newsIcon.scaleY = GlobalConfig.dpiScale;
			_newsIcon.snapToPixels = true;
			
			_newsButton = new Button();
			_newsButton.nameList.add( Theme.BUTTON_EMPTY );
			_newsButton.defaultIcon = _newsIcon;
			_newsButton.addEventListener(Event.TRIGGERED, onNewsButtonTouched);
			addChild(_newsButton);
			
			_menuIcon = new ImageLoader();
			_menuIcon.source = AbstractEntryPoint.assets.getTexture("footer-menu-icon");
			_menuIcon.scaleX = _menuIcon.scaleY = GlobalConfig.dpiScale;
			_menuIcon.snapToPixels = true;
			
			_menuButton = new Button();
			_menuButton.nameList.add( Theme.BUTTON_EMPTY );
			_menuButton.defaultIcon = _menuIcon;
			_menuButton.addEventListener(Event.TRIGGERED, onMainMenuTouched);
			addChild(_menuButton);
			
			_decorationLeft = new ImageLoader();
			_decorationLeft.touchable = false;
			_decorationLeft.source = AbstractEntryPoint.assets.getTexture("footer-decoration");
			_decorationLeft.scaleX = _decorationLeft.scaleY = GlobalConfig.dpiScale;
			_decorationLeft.snapToPixels = true;
			addChild(_decorationLeft);
			
			_decorationRight = new ImageLoader();
			_decorationRight.touchable = false;
			_decorationRight.source = AbstractEntryPoint.assets.getTexture("footer-decoration");
			_decorationRight.scaleX = _decorationRight.scaleY = GlobalConfig.dpiScale;
			_decorationRight.snapToPixels = true;
			addChild(_decorationRight);
			
			_summaryContainer = new SummaryContainer();
			addChild(_summaryContainer);
		}
		
		override protected function draw():void
		{
			super.draw();
			
			if( isInvalid(INVALIDATION_FLAG_SIZE) )
			{
				_backgroundImage.width = this.actualWidth;
				_backgroundImage.height = this.actualHeight;
				
				_backIcon.validate();
				_backButton.validate();
				_newsIcon.validate();
				_newsButton.validate();
				_backButton.x = _newsButton.x = _iconPadding;
				_backButton.y = (actualHeight - _backButton.height) * 0.5;
				_newsButton.y = (actualHeight - _newsButton.height) * 0.5;
				
				_menuIcon.validate();
				_menuButton.validate();
				_menuButton.x = actualWidth - _menuButton.width - _iconPadding;
				_menuButton.y = (actualHeight - _menuButton.height) * 0.5;
				
				_decorationLeft.validate();
				_decorationLeft.x = _backButton.x + _backButton.width + _decorationPadding;
				_decorationLeft.y = (actualHeight - _decorationLeft.height) * 0.5;
				
				_decorationRight.validate();
				_decorationRight.x = _menuButton.x - _decorationRight.width - _decorationPadding;
				_decorationRight.y = (actualHeight - _decorationRight.height) * 0.5;
				
				_shadow.height = actualHeight - scaleAndRoundToDpi(3);
				_shadow.width = _menuButton.x - (_backButton.x + _backButton.width);
				_shadow.x = _decorationLeft.x - _decorationLeft.width * 0.5;
				_shadow.y = scaleAndRoundToDpi(3);
				
				_top.x = _decorationLeft.x + _decorationLeft.width;
				_top.width = actualWidth - _decorationLeft.x - (actualWidth - _decorationRight.x + _decorationRight.width);
				
				_summaryContainer.x = _top.x;
				_summaryContainer.width = _top.width;
				_summaryContainer.validate();
				_summaryContainer.y = (actualHeight - _summaryContainer.height) * 0.4;
				//_summaryContainer.y = _top.height - scaleAndRoundToDpi(4);
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Handlers
		
		public function updateSummary():void
		{
			_summaryContainer.updateData();
		}
		
		public function animateSummary(data:Object):void
		{
			_summaryContainer.animateSummary(data);
		}
		
		private var _arrow:Image;
		private var _backInfoContainer:ScrollContainer;
		private var _backInfoLabel:Label;
		private var _transparentOverlay:Quad;
		private var _isBackInfoHelpDisplaying:Boolean = false;
		
		public function displayNewsIcon(val:Boolean, isMainMenu:Boolean = false):void
		{
			_newsButton.visible = val ? true:false;
			_backButton.visible = !_newsButton.visible;
			TweenMax.killTweensOf(_newsIcon);
			if( _isBackInfoHelpDisplaying )
				displayBackHelpIfNeeded(val, isMainMenu);
			else
				TweenMax.to(_newsIcon, 1, { onComplete:displayBackHelpIfNeeded, onCompleteParams:[val, isMainMenu] });
			//displayBackHelpIfNeeded(val, isMainMenu);
		}
		
		private function displayBackHelpIfNeeded(val:Boolean, isMainMenu:Boolean):void
		{
			if( !_isBackInfoHelpDisplaying )
			{
				if( val == false && !isMainMenu && Storage.getInstance().getProperty(StorageConfig.PROPERTY_NEED_HELP_ARROW) == true &&
					AbstractEntryPoint.screenNavigator.activeScreenID != ScreenIds.GAME_TYPE_SELECTION_SCREEN &&
					AbstractEntryPoint.screenNavigator.activeScreenID != ScreenIds.SMALL_RULES_SCREEN &&
					AbstractEntryPoint.screenNavigator.activeScreenID != ScreenIds.FREE_GAME_END_SCREEN &&
					AbstractEntryPoint.screenNavigator.activeScreenID != ScreenIds.TOURNAMENT_GAME_END_SCREEN &&
					AbstractEntryPoint.screenNavigator.activeScreenID != ScreenIds.FACEBOOK_END_SCREEN &&
					AbstractEntryPoint.screenNavigator.activeScreenID != ScreenIds.PODIUM_SCREEN &&
					AbstractEntryPoint.screenNavigator.activeScreenID != ScreenIds.NEW_HIGH_SCORE_SCREEN &&
					AbstractEntryPoint.screenNavigator.activeScreenID != ScreenIds.PSEUDO_CHOICE_SCREEN &&
					AbstractEntryPoint.screenNavigator.activeScreenID != ScreenIds.REGISTER_COMPLETE_SCREEN &&
					AbstractEntryPoint.screenNavigator.activeScreenID != ScreenIds.AUTHENTICATION_SCREEN &&
					AbstractEntryPoint.screenNavigator.activeScreenID != ScreenIds.LOGIN_SCREEN &&
					AbstractEntryPoint.screenNavigator.activeScreenID != ScreenIds.REGISTER_SCREEN &&
					AbstractEntryPoint.screenNavigator.activeScreenID != ScreenIds.FORGOT_PASSWORD_SCREEN &&
					AbstractEntryPoint.screenNavigator.activeScreenID != ScreenIds.SPONSOR_REGISTER_SCREEN &&
					AbstractEntryPoint.screenNavigator.activeScreenID != ScreenIds.UPDATE_SCREEN &&
					AbstractEntryPoint.screenNavigator.activeScreenID != ScreenIds.VIP_UP_SCREEN &&
					AbstractEntryPoint.screenNavigator.activeScreenID != ScreenIds.GAME_SCREEN)
				{
					_transparentOverlay = new Quad(GlobalConfig.stageWidth, GlobalConfig.stageHeight - this.actualHeight, 0x000000);
					_transparentOverlay.alpha = 0;
					_transparentOverlay.visible = false;
					_transparentOverlay.addEventListener(TouchEvent.TOUCH, onCloseHelp);
					(Starling.current.root as AbstractEntryPoint).addChild(_transparentOverlay);
						
					_backInfoContainer = new ScrollContainer();
					_backInfoContainer.alpha = 0;
					_backInfoContainer.visible = false;
					_backInfoContainer.touchable = false;
					_backInfoContainer.nameList.add( Theme.SCROLL_CONTAINER_RESULT_DARK_CORNER_TOP_LEFT );
					(Starling.current.root as AbstractEntryPoint).addChild(_backInfoContainer);
					_backInfoContainer.padding = 0;
					_backInfoContainer.layout["padding"] = scaleAndRoundToDpi(20);
					_backInfoContainer.layout["gap"] = 0;
					
					_backInfoLabel = new Label();
					_backInfoLabel.text = Localizer.getInstance().translate("COMMON.BACK_BUTTON_HELP");
					_backInfoContainer.addChild(_backInfoLabel);
					_backInfoLabel.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(30), Theme.COLOR_WHITE);
					_backInfoLabel.textRendererProperties.wordWrap = false;
					
					_arrow = new Image(AbstractEntryPoint.assets.getTexture("arrow"));
					_arrow.scaleX = _arrow.scaleY = GlobalConfig.dpiScale;
					_arrow.touchable = false;
					(Starling.current.root as AbstractEntryPoint).addChild(_arrow);
					_arrow.y = GlobalConfig.stageHeight - this.actualHeight - _arrow.height;
					_arrow.x = _backButton.x + (_backButton.width * 0.5) - _arrow.width * 0.5;
					
					_backInfoContainer.validate();
					_backInfoContainer.x = _arrow.x;
					_backInfoContainer.y = _arrow.y - scaleAndRoundToDpi(50) - _backInfoContainer.height;
					
					TweenMax.to(_arrow, 0.75, { y:(_arrow.y - 50), yoyo:true, repeat:-1 });
					
					Storage.getInstance().setProperty(StorageConfig.PROPERTY_NEED_HELP_ARROW, false);
					
					TweenMax.allTo([_backInfoContainer, _arrow], 0.25, { autoAlpha:1 });
					TweenMax.to(_transparentOverlay, 0.25, { autoAlpha:0.75 });
					
					_isBackInfoHelpDisplaying = true;
				}
			}
			else
			{
				_transparentOverlay.removeEventListener(TouchEvent.TOUCH, onCloseHelp);
				_transparentOverlay.removeFromParent(true);
				_transparentOverlay = null;
				
				_backInfoLabel.removeFromParent(true);
				_backInfoLabel = null;
				
				_backInfoContainer.removeFromParent(true);
				_backInfoContainer = null;
				
				TweenMax.killTweensOf(_arrow);
				_arrow.removeFromParent(true);
				_arrow = null;
				
				_isBackInfoHelpDisplaying = false;
			}
		}
		
		private function onCloseHelp(event:TouchEvent):void
		{
			var touch:Touch = event.getTouch(_transparentOverlay);
			if( touch && touch.phase == TouchPhase.ENDED )
				displayBackHelpIfNeeded(false, false);
			touch = null;
		}
		
		/**
		 * The main menu was touched.
		 */		
		private function onMainMenuTouched(event:Event):void
		{
			dispatchEventWith(LudoEventType.MAIN_MENU_TOUCHED);
		}
		
		/**
		 * The main menu was touched.
		 */		
		private function onBackButtonTouched(event:Event):void
		{
			dispatchEventWith(LudoEventType.BACK_BUTTON_TOUCHED);
		}
		
		/**
		 * The main menu was touched.
		 */		
		private function onNewsButtonTouched(event:Event):void
		{
			dispatchEventWith(LudoEventType.NEWS_BUTTON_TOUCHED);
		}
		
	}
}