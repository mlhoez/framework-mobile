/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 2 déc. 2013
*/
package com.ludofactory.mobile.navigation.game
{
	
	import com.greensock.TweenMax;
	import com.greensock.easing.Back;
	import com.greensock.easing.Elastic;
	import com.greensock.easing.Linear;
	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.common.utils.Shaker;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.GameMode;
	import com.ludofactory.mobile.core.ScreenIds;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.manager.MemberManager;
	import com.ludofactory.mobile.core.manager.TimerManager;
	import com.ludofactory.mobile.core.notification.NotificationPopupManager;
	import com.ludofactory.mobile.core.notification.content.MarketingRegisterNotificationContent;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import feathers.controls.Button;
	import feathers.controls.Callout;
	import feathers.controls.Label;
	import feathers.controls.LayoutGroup;
	import feathers.core.FeathersControl;
	import feathers.display.Scale9Image;
	import feathers.display.TiledImage;
	import feathers.skins.IStyleProvider;
	
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import starling.display.Image;
	import starling.display.Quad;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.utils.deg2rad;
	
	/**
	 * The pop up used to select a game type.
	 */	
	public class GameModeSelectionPopup extends FeathersControl
	{
		/**
		 * The shadow thickness used to adjust the layout. */		
		private var _shadowThickness:Number;
		/**
		 * The close button height used to adjust the layout. */		
		private var _buttonAdjustment:Number;
		
		/**
		 * The background skin of the popup. */		
		private var _backgroundSkin:Scale9Image;
		/**
		 * The front skin of the popup. */		
		private var _frontSkin:Scale9Image;
		
		/**
		 * The leaves. */		
		private var _topLeftLeaves:Image;
		private var _bottomLeftLeaves:Image;
		private var _bottomMiddleLeaves:Image;
		private var _bottomRightLeaves:Image;
		
		
		private var _closeQuad:Quad;
		/**
		 * Solo game button. */		
		private var _soloButton:Button;
		/**
		 * Tournament button. */		
		private var _tournamentButton:Button;
		private var _leftLock:Image;
		private var _rightLock:Image;
		private var _lock:Image;
		private var _glow:Image;
		private var _tournamentButtonContainer:LayoutGroup;
		/**
		 * Rules button. */		
		private var _rulesButton:Button;
		
		/**
		 * Offset used to move the leaves. */		
		private var _offset:int;
		
		private var _tiledBackground:TiledImage;
		
		private var _topLeftLeavesSaveX:Number;
		private var _topLeftLeavesSaveY:Number;
		
		private var _bottomLeftLeavesSaveX:Number;
		private var _bottomLeftLeavesSaveY:Number;
		
		private var _bottomMiddleLeavesSaveY:Number;
		
		private var _bottomRightLeavesSaveX:Number;
		private var _bottomRightLeavesSaveY:Number;
		
		
		private var _canBeClosed:Boolean = true;
		
		private var _isCalloutDisplaying:Boolean = false;
		
		private var _calloutLabel:Label;
		
		private var _timer:TimerManager;
		
		private var _isShaking:Boolean = false;
		
		public function GameModeSelectionPopup()
		{
			super();
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			_shadowThickness = scaleAndRoundToDpi(10);
			_buttonAdjustment = scaleAndRoundToDpi(23);
			
			_backgroundSkin = new Scale9Image(Theme.gameModeSelectionBackgroundTextures, GlobalConfig.dpiScale);
			addChild(_backgroundSkin);
			
			_topLeftLeaves = new Image(Theme.topLeftLeavesTexture);
			_topLeftLeaves.pivotX = _topLeftLeaves.width * 0.35;
			_topLeftLeaves.pivotY = _topLeftLeaves.height * 0.35;
			_topLeftLeaves.scaleX = _topLeftLeaves.scaleY = GlobalConfig.dpiScale;
			addChild(_topLeftLeaves);
			
			_bottomLeftLeaves = new Image(Theme.bottomLeftLeavesTexture);
			_bottomLeftLeaves.pivotX = _bottomLeftLeaves.width * 0.35;
			_bottomLeftLeaves.pivotY = _bottomLeftLeaves.height * 0.6;
			_bottomLeftLeaves.scaleX = _bottomLeftLeaves.scaleY = GlobalConfig.dpiScale;
			addChild(_bottomLeftLeaves);
			
			_bottomMiddleLeaves = new Image(Theme.bottomMiddleLeavesTexture);
			_bottomMiddleLeaves.pivotX = _bottomMiddleLeaves.width * 0.5;
			_bottomMiddleLeaves.pivotY = _bottomMiddleLeaves.height * 0.6;
			_bottomMiddleLeaves.scaleX = _bottomMiddleLeaves.scaleY = GlobalConfig.dpiScale;
			addChild(_bottomMiddleLeaves);
			
			_bottomRightLeaves = new Image(Theme.bottomRightLeavesTexture);
			_bottomRightLeaves.pivotX = _bottomRightLeaves.width * 0.6;
			_bottomRightLeaves.pivotY = _bottomRightLeaves.height * 0.6;
			_bottomRightLeaves.scaleX = _bottomRightLeaves.scaleY = GlobalConfig.dpiScale;
			addChild(_bottomRightLeaves);
			
			_frontSkin = new Scale9Image(Theme.gameModeSelectionFrontTextures, GlobalConfig.dpiScale);
			_frontSkin.useSeparateBatch = false;
			addChild(_frontSkin);
			
			_tiledBackground = new TiledImage(Theme.gameModeSelectionTileTexture, GlobalConfig.dpiScale);
			_tiledBackground.useSeparateBatch = false;
			addChild(_tiledBackground);
			
			_soloButton = new Button();
			//_classicGamebutton.addEventListener(Event.TRIGGERED, onPlayClassic);
			_soloButton.label = _("Partie Solo");
			addChild(_soloButton);
			
			_tournamentButtonContainer = new LayoutGroup();
			addChild(_tournamentButtonContainer);
			
			_tournamentButton = new Button();
			_tournamentButton.label = _("Partie en Tournoi");
			_tournamentButtonContainer.addChild(_tournamentButton);
			
			_rulesButton = new Button();
			//_rulesButton.addEventListener(Event.TRIGGERED, onShowRules);
			_rulesButton.styleName = Theme.BUTTON_TRANSPARENT_BLUE_DARKER;
			_rulesButton.label = _("Règles du jeu");
			addChild(_rulesButton);
			
			_closeQuad = new Quad(scaleAndRoundToDpi(70), scaleAndRoundToDpi(70));
			_closeQuad.alpha = 0;
			_closeQuad.addEventListener(TouchEvent.TOUCH, onTouchCloseButton);
			addChild(_closeQuad);
			
			_leftLock = new Image(Theme.leftChainTexture);
			_leftLock.scaleX = _leftLock.scaleY = GlobalConfig.dpiScale;
			_leftLock.touchable = false;
			_tournamentButtonContainer.addChild(_leftLock);
			
			_glow = new Image(Theme.lockGlow);
			_glow.alignPivot();
			_glow.scaleX = _glow.scaleY = 0;
			_glow.touchable = false;
			_glow.alpha = 0;
			_glow.visible = false;
			_tournamentButtonContainer.addChild(_glow);
			
			_lock = new Image(Theme.lockClosed);
			_lock.scaleX = _lock.scaleY = GlobalConfig.dpiScale;
			_lock.touchable = false;
			_tournamentButtonContainer.addChild(_lock);
			
			_rightLock = new Image(Theme.rightChainTexture);
			_rightLock.scaleX = _rightLock.scaleY = GlobalConfig.dpiScale;
			_rightLock.touchable = false;
			_tournamentButtonContainer.addChild(_rightLock);
			
			/*if( !Storage.getInstance().getProperty(StorageConfig.PROPERTY_TOURNAMENT_UNLOCKED) || (Storage.getInstance().getProperty(StorageConfig.PROPERTY_TOURNAMENT_UNLOCKED) && Storage.getInstance().getProperty(StorageConfig.PROPERTY_TOURNAMENT_UNLOCKED_HOME_ANIM_PENDING)))
			{
				
			}*/
			/*else
			{
				if( !Storage.getInstance().getProperty(StorageConfig.PROPERTY_TOURNAMENT_UNLOCKED_HOME_ANIM_PENDING) )
					_tournamentButton.addEventListener(Event.TRIGGERED, onPlayTournament);
			}*/
			
			_timer = new TimerManager(3, -1, null, onShake);
			
			_offset = scaleAndRoundToDpi(50);
		}
		
		override protected function draw():void
		{
			super.draw();
			
			var sizeInvalid:Boolean = this.isInvalid(INVALIDATION_FLAG_SIZE);
			
			sizeInvalid = this.autoSizeIfNeeded() || sizeInvalid;
			
			if(sizeInvalid)
			{
				this.layout();
			}
		}
		
		protected function autoSizeIfNeeded():Boolean
		{
			const needsWidth:Boolean = isNaN(this.explicitWidth);
			const needsHeight:Boolean = isNaN(this.explicitHeight);
			if(!needsWidth && !needsHeight)
			{
				return false;
			}
			_soloButton.validate();
			_tournamentButton.validate();
			_rulesButton.validate();
			var newWidth:Number = this.explicitWidth;
			if(needsWidth)
			{
				//newWidth = _.width;
			}
			var newHeight:Number = this.explicitHeight;
			if(needsHeight)
			{
				newHeight = _soloButton.height + _tournamentButton.height + _rulesButton.height + scaleAndRoundToDpi(120) + scaleAndRoundToDpi(50);
			}
			return this.setSizeInternal(newWidth, newHeight, false);
		}
		
		private function layout():void
		{
			var halfWidth:Number;
			var halfHeight:Number;
			
			_backgroundSkin.width = actualWidth;
			_backgroundSkin.height = actualHeight;
			_backgroundSkin.alignPivot();
			_backgroundSkin.x = actualWidth * 0.5;
			_backgroundSkin.y = actualHeight * 0.5;
			
			_frontSkin.width = actualWidth * 0.98;
			_frontSkin.height = actualHeight * 0.98;
			_frontSkin.alignPivot();
			_frontSkin.x = actualWidth * 0.5 + _shadowThickness;
			_frontSkin.y = actualHeight * 0.5 - _shadowThickness;
			
			_tiledBackground.width = _frontSkin.width * 0.8;
			_tiledBackground.height = _frontSkin.height * 0.8;
			_tiledBackground.alignPivot();
			_tiledBackground.x = actualWidth  * 0.5;
			_tiledBackground.y = actualHeight * 0.5;
			
			halfWidth = _frontSkin.width * 0.5;
			halfHeight = _frontSkin.height * 0.5;
			
			_topLeftLeavesSaveX = _topLeftLeaves.x = int(_frontSkin.x + _shadowThickness - halfWidth + _offset);
			_topLeftLeavesSaveY = _topLeftLeaves.y = int(_frontSkin.y + _shadowThickness + _buttonAdjustment - halfHeight + _offset);
			
			_bottomLeftLeavesSaveX = _bottomLeftLeaves.x = int(_frontSkin.x + _shadowThickness - halfWidth + _offset);
			_bottomLeftLeavesSaveY = _bottomLeftLeaves.y = int(_frontSkin.y - _shadowThickness + halfHeight - _offset);
			
			_bottomMiddleLeaves.x = int(_frontSkin.x);
			_bottomMiddleLeavesSaveY = _bottomMiddleLeaves.y = int(_frontSkin.y + halfHeight - _offset);
			
			_bottomRightLeavesSaveX = _bottomRightLeaves.x = int(_frontSkin.x - _shadowThickness - _buttonAdjustment + halfWidth - _offset);
			_bottomRightLeavesSaveY = _bottomRightLeaves.y = int(_frontSkin.y - _shadowThickness + halfHeight - _offset);
			
			_soloButton.width = _frontSkin.width * 0.8;
			_soloButton.validate();
			_soloButton.alignPivot();
			_soloButton.y = _frontSkin.y + _shadowThickness + _buttonAdjustment + scaleAndRoundToDpi(40) - halfHeight + (_soloButton.height * 0.5);
			_soloButton.x = actualWidth * 0.5;
			
			_tournamentButton.width = _frontSkin.width * 0.8;
			_tournamentButtonContainer.validate();
			_tournamentButtonContainer.alignPivot();
			_tournamentButtonContainer.y = _soloButton.y +  (_soloButton.height * 0.5) + scaleAndRoundToDpi(20) + (_tournamentButtonContainer.height * 0.5) ;
			_tournamentButtonContainer.x = actualWidth * 0.5;
			
			_rulesButton.width = _frontSkin.width * 0.65;
			_rulesButton.validate();
			_rulesButton.alignPivot();
			_rulesButton.y = _tournamentButtonContainer.y + (_tournamentButtonContainer.height * 0.5) + scaleAndRoundToDpi(10) + (_rulesButton.height * 0.5);
			_rulesButton.x = actualWidth * 0.5;
			
			_closeQuad.x = _backgroundSkin.width - _closeQuad.width
			
			//if( !Storage.getInstance().getProperty(StorageConfig.PROPERTY_TOURNAMENT_UNLOCKED) || (Storage.getInstance().getProperty(StorageConfig.PROPERTY_TOURNAMENT_UNLOCKED) && Storage.getInstance().getProperty(StorageConfig.PROPERTY_TOURNAMENT_UNLOCKED_HOME_ANIM_PENDING)))
			//{
				_leftLock.alignPivot();
				_leftLock.y = int((_tournamentButton.height * 0.5) + scaleAndRoundToDpi(3));
				_leftLock.x = int((_leftLock.width * 0.5) + scaleAndRoundToDpi(40));
				
				_rightLock.alignPivot();
				_lock.alignPivot();
				_glow.alignPivot();
				_rightLock.y = _lock.y = int((_tournamentButton.height * 0.5) + scaleAndRoundToDpi(12));
				_rightLock.x = _lock.x = int(_tournamentButton.width - (_rightLock.width * 0.5));
				_glow.x = _lock.x - scaleAndRoundToDpi(25);
				_glow.y = _lock.y;
			//}
			
			_backgroundSkin.scaleX = _backgroundSkin.scaleY = 0;
			_frontSkin.scaleX = _frontSkin.scaleY = 0;
			_tiledBackground.scaleX = _tiledBackground.scaleY = 0;
			_topLeftLeaves.alpha = 0;
			_bottomLeftLeaves.alpha = 0;
			_bottomMiddleLeaves.alpha = 0;
			_bottomRightLeaves.alpha = 0;
			_soloButton.scaleX = _soloButton.scaleY = 0.7;
			_soloButton.alpha = 0;
			_tournamentButtonContainer.scaleX = _tournamentButtonContainer.scaleY = 0.7;
			_tournamentButtonContainer.alpha = 0;
			_rulesButton.scaleX = _rulesButton.scaleY = 0.7;
			_rulesButton.alpha = 0;
		}
		
//------------------------------------------------------------------------------------------------------------
//	Handlers
//------------------------------------------------------------------------------------------------------------
		
		/**
		 * Play classic mode.
		 */		
		private function onPlayClassic(event:Event):void
		{
			if( MemberManager.getInstance().isLoggedIn() )
			{
				AbstractEntryPoint.screenNavigator.screenData.displayPopupOnHome = true;
				AbstractEntryPoint.screenNavigator.screenData.gameType = GameMode.SOLO;
				AbstractEntryPoint.screenNavigator.showScreen( ScreenIds.GAME_TYPE_SELECTION_SCREEN );
			}
			else
			{
				if( MemberManager.getInstance().getNumTokens() == 0 )
				{
					AbstractEntryPoint.screenNavigator.screenData.displayPopupOnHome = true;
					//AbstractEntryPoint.screenNavigator.showScreen( AdvancedScreen.AUTHENTICATION_SCREEN );
					//NotificationManager.addNotification( new MarketingRegisterNotification(ScreenIds.HOME_SCREEN) );
					NotificationPopupManager.addNotification( new MarketingRegisterNotificationContent(ScreenIds.HOME_SCREEN) );
				}
				else
				{
					AbstractEntryPoint.screenNavigator.screenData.displayPopupOnHome = true;
					AbstractEntryPoint.screenNavigator.screenData.gameType = GameMode.SOLO;
					AbstractEntryPoint.screenNavigator.showScreen( ScreenIds.GAME_TYPE_SELECTION_SCREEN );
				}
				
				// Ancienne gestion sans passage à l'écran de mises
				/*if( MemberManager.getInstance().getNumFreeGameSessions() >= Storage.getInstance().getProperty( StorageConfig.NUM_TOKENS_IN_SOLO_MODE ) )
				{
					AbstractEntryPoint.screenNavigator.screenData.gameType = GameSession.TYPE_FREE;
					AbstractEntryPoint.screenNavigator.screenData.gamePrice = GameSession.PRICE_FREE;
					AbstractEntryPoint.screenNavigator.showScreen( MemberManager.getInstance().getDisplayRules() ? AdvancedScreen.SMALL_RULES_SCREEN : AdvancedScreen.GAME_SCREEN );
				}
				else
				{
					AbstractEntryPoint.screenNavigator.showScreen( AdvancedScreen.AUTHENTICATION_SCREEN );
				}*/
				
			}
			dispatchEventWith(Event.CLOSE);
		}
		
		/**
		 * Play tournament mode.
		 */		
		private function onPlayTournament(event:Event):void
		{
			if( MemberManager.getInstance().getTournamentUnlocked() == true )
			{
				AbstractEntryPoint.screenNavigator.screenData.displayPopupOnHome = true;
				AbstractEntryPoint.screenNavigator.showScreen( ScreenIds.TOURNAMENT_RANKING_SCREEN );
				
				dispatchEventWith(Event.CLOSE);
			}
			else
			{
				if( !_isShaking )
				{
					_timer.restart();
					onShake();
				}
				
				if( !_isCalloutDisplaying )
				{
					if( !_calloutLabel )
					{
						_calloutLabel = new Label();
						_calloutLabel.text = _("Pour débloquer les parties en Tournoi, il suffit de terminer une partie Solo !");
						_calloutLabel.width = _tournamentButton.width * 0.9;
						_calloutLabel.validate();
					}
					_isCalloutDisplaying = true;
					var callout:Callout = Callout.show(_calloutLabel, _tournamentButton, Callout.DIRECTION_DOWN, false);
					callout.disposeContent = false;
					callout.touchable = false;
					callout.addEventListener(Event.REMOVED_FROM_STAGE, onCalloutRemoved);
					_calloutLabel.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(26), Theme.COLOR_DARK_GREY, false, false, null, null, null, TextFormatAlign.CENTER);
				}
			}
		}
		
		private function onCalloutRemoved(event:Event):void
		{
			event.target.removeEventListener(Event.REMOVED_FROM_STAGE, onCalloutRemoved);
			_isCalloutDisplaying = false;
		}
		
		/**
		 * Show game rules.
		 */		
		private function onShowRules():void
		{
			AbstractEntryPoint.screenNavigator.screenData.displayPopupOnHome = true;
			AbstractEntryPoint.screenNavigator.showScreen( ScreenIds.RULES_AND_SCORES_SCREEN );
			dispatchEventWith(Event.CLOSE);
		}
		
		public function animateInSkip():void
		{
			_soloButton.label = _("Partie Solo");
			_tournamentButton.label = _("Partie en Tournoi");
			_rulesButton.label = _("Règles du jeu");
			
			_leftLock.visible = _lock.visible = _rightLock.visible = MemberManager.getInstance().getTournamentUnlocked() ? false : true;
			_leftLock.alpha = _lock.alpha = _rightLock.alpha = MemberManager.getInstance().getTournamentUnlocked() ? 0 : 1;
			
			_canBeClosed = true;
			
			TweenMax.killTweensOf([_backgroundSkin, _frontSkin, _tiledBackground, _topLeftLeaves, _bottomLeftLeaves, _bottomMiddleLeaves, _bottomRightLeaves, _soloButton, _tournamentButtonContainer, _rulesButton]);
			
			_offset *= -1;
			
			_backgroundSkin.scaleX = _backgroundSkin.scaleY = _frontSkin.scaleX = _frontSkin.scaleY = _tiledBackground.scaleX = _tiledBackground.scaleY = 1;
			
			_topLeftLeaves.alpha = 1;
			_topLeftLeaves.x = _topLeftLeavesSaveX + _offset;
			_topLeftLeaves.y = _topLeftLeavesSaveY + _offset;
			
			_bottomLeftLeaves.alpha = 1;
			_bottomLeftLeaves.x = _bottomLeftLeavesSaveX + _offset;
			_bottomLeftLeaves.y = _bottomLeftLeavesSaveY - _offset;
			
			_bottomMiddleLeaves.alpha = 1;
			_bottomMiddleLeaves.y = _bottomMiddleLeavesSaveY - _offset;
			
			_bottomRightLeaves.alpha = 1;
			_bottomRightLeaves.x = _bottomRightLeavesSaveX - _offset;
			_bottomRightLeaves.y = _bottomRightLeavesSaveY - _offset;
			
			_soloButton.scaleX = _soloButton.scaleY = _soloButton.alpha = _tournamentButtonContainer.scaleX = _tournamentButtonContainer.scaleY = _tournamentButtonContainer.alpha =
			_rulesButton.scaleX = _rulesButton.scaleY = _rulesButton.alpha = 1;
			_soloButton.visible = _tournamentButtonContainer.visible = _rulesButton.visible = true;
			
			if( MemberManager.getInstance().getTournamentUnlocked() && MemberManager.getInstance().getTournamentAnimPending() )
			{
				// si le tournoi est débloqué
				_canBeClosed = false;
				MemberManager.getInstance().setTournamentAnimPending(false);
				Shaker.dispatcher.addEventListener(Event.COMPLETE, onUnlockComplete);
				TweenMax.to(_glow, 1.25, { delay:1.5, scaleX:(GlobalConfig.dpiScale + 1.5), scaleY:(GlobalConfig.dpiScale + 1.5), ease:Elastic.easeOut });
				TweenMax.to(_glow, 0.75, { delay:1.5, autoAlpha:1 });
				TweenMax.to(_glow, 8, { rotation:deg2rad(360), ease:Linear.easeNone, repeat:-1 });
				TweenMax.delayedCall(2.5, Shaker.startShaking, [_lock, 5]);
			}
			else
			{
				enableListeners();
				if( _lock.visible )
					_timer.restart();
			}
			
			onAnimationInComplete();
		}
		
		public function animateIn():void
		{
			_soloButton.label = _("Partie Solo");
			_tournamentButton.label = _("Partie en Tournoi");
			_rulesButton.label = _("Règles du jeu");
			
			_leftLock.visible = _lock.visible = _rightLock.visible = (MemberManager.getInstance().getTournamentUnlocked() && !MemberManager.getInstance().getTournamentAnimPending()) ? false : true;
			_leftLock.alpha = _lock.alpha = _rightLock.alpha = (MemberManager.getInstance().getTournamentUnlocked() && !MemberManager.getInstance().getTournamentAnimPending()) ? 0 : 1;
			
			/*if( !_isOpening )
			{
				_isOpening = true;*/
				_canBeClosed = true;
				
				TweenMax.killTweensOf([_backgroundSkin, _frontSkin, _tiledBackground, _topLeftLeaves, _bottomLeftLeaves, _bottomMiddleLeaves, _bottomRightLeaves, _soloButton, _tournamentButtonContainer, _rulesButton]);
				
				_offset *= -1;
				
				TweenMax.allTo([_backgroundSkin, _frontSkin, _tiledBackground], 0.5, { scaleX:1, scaleY:1, ease:Back.easeOut });
				
				TweenMax.to(_topLeftLeaves,       1.25, { delay:0.4, alpha:1, x:(_topLeftLeavesSaveX + _offset), y:(_topLeftLeavesSaveY + _offset), ease:Elastic.easeOut });
				TweenMax.to(_bottomLeftLeaves,    1.25, { delay:0.4, alpha:1, x:(_bottomLeftLeavesSaveX + _offset), y:(_bottomLeftLeavesSaveY - _offset), ease:Elastic.easeOut, onComplete:onAnimationInComplete });
				TweenMax.to(_bottomMiddleLeaves,  1.25, { delay:0.4,  alpha:1, y:(_bottomMiddleLeavesSaveY - _offset), ease:Elastic.easeOut });
				TweenMax.to(_bottomRightLeaves,   1.25, { delay:0.4,  alpha:1, x:(_bottomRightLeavesSaveX - _offset), y:(_bottomRightLeavesSaveY - _offset), ease:Elastic.easeOut });
				
				TweenMax.allTo([_soloButton, _tournamentButtonContainer, _rulesButton], 0.75, { delay:0.6, autoAlpha:1, scaleX:1, scaleY:1, ease:Back.easeOut });
			//}
			
			if( MemberManager.getInstance().getTournamentUnlocked() && MemberManager.getInstance().getTournamentAnimPending() )
			{
				// si le tournoi est débloqué
				_canBeClosed = false;
				MemberManager.getInstance().setTournamentAnimPending(false);
				Shaker.dispatcher.addEventListener(Event.COMPLETE, onUnlockComplete);
				TweenMax.to(_glow, 0.5, { delay:1.5, autoAlpha:1, scaleX:(GlobalConfig.dpiScale + 1.5), scaleY:(GlobalConfig.dpiScale + 1.5), ease:Linear.easeNone });
				TweenMax.to(_glow, 0.75, { delay:1.5, autoAlpha:1 });
				TweenMax.to(_glow, 8, { rotation:deg2rad(360), ease:Linear.easeNone, repeat:-1 });
				TweenMax.delayedCall(2.5, Shaker.startShaking, [_lock, 5]);
			}
			else
			{
				enableListeners()
				if( _lock.visible )
					_timer.restart();
			}
			
		}
		
		private function onTouchCloseButton(event:TouchEvent):void
		{
			var touch:Touch = event.getTouch(_closeQuad);
			if( touch && touch.phase == TouchPhase.ENDED )
				dispatchEventWith(Event.CLOSE);
			touch = null;
		}
		
		private function onUnlockComplete(event:Event):void
		{
			Shaker.dispatcher.removeEventListener(Event.COMPLETE, onUnlockComplete);
			TweenMax.allTo([_leftLock, _rightLock], 0.75, { delay:0.5, autoAlpha:0 });
			TweenMax.to(_glow, 0.75, { delay:1, autoAlpha:0 } );
			TweenMax.to(_glow, 0.75, { delay:1, rotation:deg2rad(360) } );
			TweenMax.to(_lock, 0.75, { delay:1, autoAlpha:0, onComplete:enableButtons });
			
			_lock.texture = Theme.lockOpened;
		}
		
		private function enableButtons():void
		{
			_canBeClosed = true;
			_timer.stop();
			TweenMax.killTweensOf(_glow);
			enableListeners();
		}
		
		private function enableListeners():void
		{
			_tournamentButton.addEventListener(Event.TRIGGERED, onPlayTournament);
			_rulesButton.addEventListener(Event.TRIGGERED, onShowRules);
			_soloButton.addEventListener(Event.TRIGGERED, onPlayClassic);
		}
		
		private function disableListeners():void
		{
			_timer.stop();
			_tournamentButton.removeEventListener(Event.TRIGGERED, onPlayTournament);
			_rulesButton.removeEventListener(Event.TRIGGERED, onShowRules);
			_soloButton.removeEventListener(Event.TRIGGERED, onPlayClassic);
		}
		
		public function animateOut():void
		{
			TweenMax.killTweensOf([_backgroundSkin, _frontSkin, _tiledBackground, _topLeftLeaves, _bottomLeftLeaves, _bottomMiddleLeaves, _bottomRightLeaves, _soloButton, _tournamentButtonContainer, _rulesButton]);
			
			_offset *= -1;
			
			disableListeners();
			
			TweenMax.allTo([_backgroundSkin, _frontSkin, _tiledBackground], 0.25, { scaleX:0, scaleY:0, ease:Back.easeIn, onComplete:dispatchEventWith, onCompleteParams:[Event.COMPLETE] });
			
			TweenMax.to(_topLeftLeaves,       0.25, { alpha:0, x:(_topLeftLeavesSaveX + _offset), y:(_topLeftLeavesSaveY + _offset), ease:Back.easeIn });
			TweenMax.to(_bottomLeftLeaves,    0.25, { alpha:0, x:(_bottomLeftLeaves.x + _offset), y:(_bottomLeftLeavesSaveY - _offset), ease:Back.easeIn });
			TweenMax.to(_bottomMiddleLeaves,  0.25, { alpha:0, y:(_bottomMiddleLeavesSaveY - _offset), ease:Back.easeIn });
			TweenMax.to(_bottomRightLeaves,   0.25, { alpha:0, x:(_bottomRightLeavesSaveX - _offset), y:(_bottomRightLeavesSaveY - _offset), ease:Back.easeIn });
			
			TweenMax.allTo([_soloButton, _tournamentButtonContainer, _rulesButton], 0.25, { autoAlpha:0, scaleX:0.7, scaleY:0.7, ease:Back.easeIn });
		}
		
		/**
		 * 
		 */		
		private function onAnimationInComplete():void
		{
			dispatchEventWith(Event.COMPLETE);
		}
		
		private function onShake():void
		{
			if( !_isShaking )
			{
				_isShaking = true;
				Shaker.dispatcher.addEventListener(Event.COMPLETE, onShakeComplete);
				Shaker.startShaking(_lock, 5);
			}
		}
		
		private function onShakeComplete(event:Event):void
		{
			_isShaking = false;
			Shaker.dispatcher.removeEventListener(Event.COMPLETE, onShakeComplete);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Get / Set
//------------------------------------------------------------------------------------------------------------
		
		public function set backgroundSkin(val:Scale9Image):void { _backgroundSkin = val; }
		
		public function get glow():Image { return _glow; }
		public function set glow(val:Image):void { _glow = val; }
		
		public function get canBeClosed():Boolean { return _canBeClosed; }
		
		/**
		 * Required for the new Theme. */
		public static var globalStyleProvider:IStyleProvider;
		override protected function get defaultStyleProvider():IStyleProvider
		{
			return GameModeSelectionPopup.globalStyleProvider;
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
//------------------------------------------------------------------------------------------------------------
		
		override public function dispose():void
		{
			_backgroundSkin.removeFromParent(true);
			_backgroundSkin = null;
			
			_frontSkin.removeFromParent(true);
			_frontSkin = null;
			
			_tiledBackground.removeFromParent(true);
			_tiledBackground = null;
			
			_topLeftLeaves.removeFromParent(true);
			_topLeftLeaves = null;
			
			_bottomLeftLeaves.removeFromParent(true);
			_bottomLeftLeaves = null;
			
			_bottomMiddleLeaves.removeFromParent(true);
			_bottomMiddleLeaves = null;
			
			_bottomRightLeaves.removeFromParent(true);
			_bottomRightLeaves = null;
			
			_soloButton.removeFromParent(true);
			_soloButton = null;
			
			_tournamentButton.removeFromParent(true);
			_tournamentButton = null;
			
			_leftLock.removeFromParent(true);
			_leftLock = null;
			
			_rightLock.removeFromParent(true);
			_rightLock = null;
			
			_tournamentButtonContainer.removeFromParent(true);
			_tournamentButtonContainer = null;
			
			_rulesButton.removeFromParent(true);
			_rulesButton = null;
			
			super.dispose();
		}
		
	}
}