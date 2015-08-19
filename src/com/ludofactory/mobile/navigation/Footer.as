/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 9 oct. 2013
*/
package com.ludofactory.mobile.navigation
{
	
	import com.greensock.TweenMax;
	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.common.utils.Utilities;
	import com.ludofactory.common.utils.roundUp;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.AbstractGameInfo;
	import com.ludofactory.mobile.core.AbstractGameInfo;
	import com.ludofactory.mobile.core.AbstractGameInfo;
	import com.ludofactory.mobile.core.GameSessionTimer;
	import com.ludofactory.mobile.core.ScreenIds;
	import com.ludofactory.mobile.core.model.StakeType;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.events.MobileEventTypes;
	import com.ludofactory.mobile.core.manager.MemberManager;
	import com.ludofactory.mobile.core.storage.Storage;
	import com.ludofactory.mobile.core.storage.StorageConfig;
	import com.ludofactory.mobile.core.theme.Theme;
	import com.ludofactory.mobile.navigation.home.summary.SummaryElement;
	
	import feathers.controls.Button;
	import feathers.controls.Label;
	import feathers.controls.ScrollContainer;
	import feathers.core.FeathersControl;
	import feathers.display.Scale9Image;
	import feathers.textures.Scale9Textures;
	
	import flash.geom.Rectangle;
	import flash.text.TextFormat;
	
	import starling.core.Starling;
	import starling.display.BlendMode;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	
	//------------------------------------------------------------------------------------------------------------
	//	TODO : Supprimer le summary container devenu useless
	//------------------------------------------------------------------------------------------------------------
	
	/**
	 * Application footer.
	 */	
	public class Footer extends FeathersControl
	{
		/**
		 * Side padding (used to position buttons). */		
		private var _sidePadding:int;
		/**
		 * The scaled height of the container (80 by default). */		
		private var _containerHeight:Number;
		
		/**
		 * The footer background. */		
		private var _backgroundImage:Scale9Image;
		
		/**
		 * The back button. */		
		private var _backButton:Button;
		/**
		 * The back icon. */		
		private var _backIcon:Image;
		
		/**
		 * The news button. */		
		private var _newsButton:Button;
		/**
		 * The news icon. */		
		private var _newsIcon:Image;
		
		/**
		 * The menu button. */		
		private var _menuButton:Button;
		/**
		 * The menu icon. */		
		private var _menuIcon:Image;
		
		/**
		 * The free container. */		
		private var _freeContainer:SummaryElement;
		/**
		 * The points container. */		
		private var _pointsContainer:SummaryElement;
		/**
		 * The credits container. */		
		private var _creditsContainer:SummaryElement;
		
		public function Footer()
		{
			super();
			
			_sidePadding = scaleAndRoundToDpi(AbstractGameInfo.LANDSCAPE ? 36 : 10);
			_containerHeight = scaleAndRoundToDpi(80);
			height = scaleAndRoundToDpi(AbstractGameInfo.LANDSCAPE ? 88 : 118);
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			var rect:Rectangle = (AbstractGameInfo.LANDSCAPE ? new Rectangle(190, 54, 10, 10) : new Rectangle(140, 54, 10, 10));
			_backgroundImage = new Scale9Image( new Scale9Textures(AbstractEntryPoint.assets.getTexture("footer-skin" + (AbstractGameInfo.LANDSCAPE ? "-landscape" : "")), rect), GlobalConfig.dpiScale );
			_backgroundImage.touchable = false;
			_backgroundImage.blendMode = BlendMode.NONE;
			_backgroundImage.useSeparateBatch = false;
			addChild(_backgroundImage);
			
			_backIcon = new Image( AbstractEntryPoint.assets.getTexture("footer-back-icon") );
			_backIcon.scaleX = _backIcon.scaleY = GlobalConfig.dpiScale;
			
			_backButton = new Button();
			_backButton.styleName = Theme.BUTTON_EMPTY;
			_backButton.defaultIcon = _backIcon;
			_backButton.addEventListener(Event.TRIGGERED, onBackButtonTouched);
			addChild(_backButton);
			
			_newsIcon = new Image( AbstractEntryPoint.assets.getTexture("footer-news-icon") );
			_newsIcon.scaleX = _newsIcon.scaleY = GlobalConfig.dpiScale;
			
			_newsButton = new Button();
			_newsButton.styleName = Theme.BUTTON_EMPTY;
			_newsButton.defaultIcon = _newsIcon;
			_newsButton.addEventListener(Event.TRIGGERED, onNewsButtonTouched);
			addChild(_newsButton);
			
			_menuIcon = new Image( AbstractEntryPoint.assets.getTexture("footer-menu-icon") );
			_menuIcon.scaleX = _menuIcon.scaleY = GlobalConfig.dpiScale;
			
			_menuButton = new Button();
			_menuButton.styleName = Theme.BUTTON_EMPTY;
			_menuButton.defaultIcon = _menuIcon;
			_menuButton.addEventListener(Event.TRIGGERED, onMainMenuTouched);
			addChild(_menuButton);
			
			_freeContainer = new SummaryElement( StakeType.TOKEN );
			addChild(_freeContainer);
			
			_pointsContainer = new SummaryElement( StakeType.POINT );
			addChild(_pointsContainer);
			
			_creditsContainer = new SummaryElement( StakeType.CREDIT );
			addChild(_creditsContainer);
			
			GameSessionTimer.registerFunction(_freeContainer.setLabelText);
			
			
			updateSummary();
		}
		
		override protected function draw():void
		{
			super.draw();
			
			if( isInvalid(INVALIDATION_FLAG_SIZE) )
			{
				_backgroundImage.width = actualWidth;
				_backgroundImage.height = actualHeight;
				
				_backButton.validate();
				_newsButton.validate();
				_backButton.x = _newsButton.x = _sidePadding;
				_backButton.y = ((actualHeight - _backButton.height) * 0.5) << 0;
				_newsButton.y = ((actualHeight - _newsButton.height) * 0.5) << 0;
				
				_menuButton.validate();
				_menuButton.x = (actualWidth - _menuButton.width - _sidePadding) << 0;
				_menuButton.y = ((actualHeight - _menuButton.height) * 0.5) << 0;
				
				var containersMaxWidth:int = actualWidth - scaleAndRoundToDpi(AbstractGameInfo.LANDSCAPE ? 330 : 200); // 100 + 100 padding on each side
				
				_freeContainer.height = _pointsContainer.height = _creditsContainer.height = _containerHeight;
				
				_freeContainer.width = _creditsContainer.width = containersMaxWidth * 0.3 - scaleAndRoundToDpi(10);
				_pointsContainer.width = containersMaxWidth * 0.4 - scaleAndRoundToDpi(10) * 2;
				
				_freeContainer.x = scaleAndRoundToDpi(AbstractGameInfo.LANDSCAPE ? 175 : 110);
				_pointsContainer.x = (_freeContainer.x + _freeContainer.width + scaleAndRoundToDpi(10)) << 0;
				_creditsContainer.x = (_pointsContainer.x + _pointsContainer.width + scaleAndRoundToDpi(10)) << 0;
				
				_freeContainer.validate();
				_freeContainer.y = _pointsContainer.y = _creditsContainer.y = roundUp(((actualHeight - _freeContainer.height) * 0.5)) + (AbstractGameInfo.LANDSCAPE ? scaleAndRoundToDpi(2) : 0);
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Summary containers functions
		
		/**
		 * Updates the labels in the summary elements.
		 * 
		 * <p>This is called whenever the number of free game sessions,
		 * points or credits have changed.</p>
		 */		
		public function updateSummary():void
		{
			GameSessionTimer.updateState();
			if( MemberManager.getInstance().isLoggedIn() )
			{
				_freeContainer.setLabelText( "" + Utilities.splitThousands( MemberManager.getInstance().getNumTokens() ) );
				_pointsContainer.setLabelText( "" + Utilities.splitThousands( MemberManager.getInstance().getPoints() ) );
				_creditsContainer.setLabelText( "" + Utilities.splitThousands( MemberManager.getInstance().getCredits() ) );
			}
			else
			{
				_pointsContainer.setLabelText( MemberManager.getInstance().getAnonymousGameSessionsAlreadyUsed() ? "???" : ("" + MemberManager.getInstance().getPoints()) );
				_creditsContainer.setLabelText( MemberManager.getInstance().getNumTokens() == 0 ? "???" : "-" );
			}
		}
		
		/**
		 * Animate a value above one of the containers.
		 */		
		public function animateSummary(data:Object):void
		{
			switch(data.type)
			{
				case StakeType.TOKEN:
				{
					_freeContainer.animateChange( data.value );
					break;
				}
				case StakeType.CREDIT:
				{
					_creditsContainer.animateChange( data.value );
					break;
				}
				case StakeType.POINT:
				{
					_pointsContainer.animateChange( data.value );
					break;
				}
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Buttons handlers
		
		/**
		 * The main menu button was touched.
		 */		
		private function onMainMenuTouched(event:Event):void
		{
			dispatchEventWith(MobileEventTypes.MAIN_MENU_TOUCHED);
		}
		
		/**
		 * The back button was touched.
		 */		
		private function onBackButtonTouched(event:Event):void
		{
			dispatchEventWith(MobileEventTypes.BACK_BUTTON_TOUCHED);
		}
		
		/**
		 * The new button was touched.
		 */		
		private function onNewsButtonTouched(event:Event):void
		{
			dispatchEventWith(MobileEventTypes.NEWS_BUTTON_TOUCHED);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Help
		
		private var _arrow:Image;
		private var _backInfoContainer:ScrollContainer;
		private var _backInfoLabel:Label;
		private var _transparentOverlay:Quad;
		private var _isBackInfoHelpDisplaying:Boolean = false;
		
		public function displayNewsIcon(val:Boolean, isMainMenu:Boolean = false):void
		{
			_newsButton.visible = val;
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
					AbstractEntryPoint.screenNavigator.activeScreenID != ScreenIds.SOLO_END_SCREEN &&
					AbstractEntryPoint.screenNavigator.activeScreenID != ScreenIds.TOURNAMENT_END_SCREEN &&
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
					_backInfoContainer.styleName = Theme.SCROLL_CONTAINER_RESULT_DARK_CORNER_TOP_LEFT;
					(Starling.current.root as AbstractEntryPoint).addChild(_backInfoContainer);
					_backInfoContainer.padding = 0;
					_backInfoContainer.layout["padding"] = scaleAndRoundToDpi(20);
					_backInfoContainer.layout["gap"] = 0;
					
					_backInfoLabel = new Label();
					_backInfoLabel.text = _("Pour revenir à l'écran précédent,\ntouchez le bouton de retour.");
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
					
					TweenMax.to(_arrow, 0.75, { y:(_arrow.y - scaleAndRoundToDpi(50)), yoyo:true, repeat:-1 });
					
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
		
	}
}