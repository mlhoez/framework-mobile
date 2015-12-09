/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 23 Juillet 2013
*/
package com.ludofactory.mobile.navigation.game
{
	
	import com.greensock.TweenMax;
	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.common.utils.roundUp;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.ButtonFactory;
	import com.ludofactory.mobile.MobileButton;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.AbstractGameInfo;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.controls.AdvancedScreen;
	import com.ludofactory.mobile.core.events.MobileEventTypes;
	import com.ludofactory.mobile.core.manager.MemberManager;
	import com.ludofactory.mobile.core.model.GameMode;
	import com.ludofactory.mobile.core.model.ScreenIds;
	import com.ludofactory.mobile.core.model.StakeType;
	import com.ludofactory.mobile.core.promo.PromoContent;
	import com.ludofactory.mobile.core.promo.PromoManager;
	import com.ludofactory.mobile.core.storage.Storage;
	import com.ludofactory.mobile.core.storage.StorageConfig;
	import com.ludofactory.mobile.core.theme.Theme;
	import com.ludofactory.mobile.navigation.ads.AdManager;
	import com.milkmangames.nativeextensions.GAnalytics;
	
	import feathers.controls.Label;

	import flash.filters.BitmapFilterQuality;

	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Rectangle;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import starling.display.Button;
	import starling.events.Event;
	import starling.text.TextField;
	import starling.text.TextFieldAutoSize;
	import starling.utils.HAlign;
	import starling.utils.VAlign;

	/**
	 * The screen used to select a price for the next game session.
	 * 
	 * <p>Whether free, with credits and in tournament mode, with points.</p>
	 */	
	public class StakeSelectionScreen extends AdvancedScreen
	{
		/**
		 * Title */		
		private var _title:TextField;
		
		/**
		 * Play with free credits */		
		private var _withTokens:StakeButtonToken;
		
		/**
		 * Play with points (only in tournament mode) */		
		private var _withPoints:StakeButtonPoint;
		
		/**
		 * Play with credits */		
		private var _withCredits:StakeButtonCredit;
		
		/**
		 * In tournament mode, a button to see the ranking. */
		private var _tournamentRankingButton:MobileButton;
		
		/**
		 * The promo content displayed when there is a promo. */
		private var _promoContent:PromoContent;
		
		public function StakeSelectionScreen()
		{
			super();
			
			_appClearBackground = true;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			_title = new TextField(5, 5, _("Choisissez votre mise"), Theme.FONT_SANSITA, scaleAndRoundToDpi(GlobalConfig.isPhone ? 50 : 70), 0x313131);
			_title.touchable = false;
			_title.autoSize = TextFieldAutoSize.VERTICAL;
			_title.hAlign = HAlign.CENTER;
			_title.vAlign = VAlign.CENTER;
			addChild(_title);
			_title.nativeFilters = [ new GlowFilter(0xffffff, 1, scaleAndRoundToDpi(1.0), scaleAndRoundToDpi(1.0), scaleAndRoundToDpi(5), BitmapFilterQuality.LOW),
				new DropShadowFilter(2, 75, 0xffffff, 0.6, scaleAndRoundToDpi(1), scaleAndRoundToDpi(1), scaleAndRoundToDpi(1), BitmapFilterQuality.LOW) ];
			
			_withTokens = new StakeButtonToken( this.advancedOwner.screenData.gameType );
			_withTokens.addEventListener(Event.TRIGGERED, onPlayWithTokens);
			addChild(_withTokens);
			
			_withCredits = new StakeButtonCredit(this.advancedOwner.screenData.gameType);
			_withCredits.addEventListener(Event.TRIGGERED, onPlayWithCredits);
			addChild(_withCredits);
			
			if( MemberManager.getInstance().isLoggedIn() )
				MemberManager.getInstance().updateVidCoinData();
			
			if( advancedOwner.screenData.gameType == GameMode.TOURNAMENT )
			{
				_withPoints = new StakeButtonPoint();
				_withPoints.addEventListener(Event.TRIGGERED, onPlayWithPoints);
				addChild(_withPoints);
				
				_tournamentRankingButton = ButtonFactory.getButton(_("Voir le classement"), ButtonFactory.WHITE);
				_tournamentRankingButton.addEventListener(Event.TRIGGERED, onGoTournamentRanking);
				addChild(_tournamentRankingButton);
			}
			
			if(PromoManager.getInstance().isPromoPending)
			{
				_promoContent = PromoManager.getInstance().getPromoContent(true);
				_promoContent.visible = !AbstractGameInfo.LANDSCAPE;
				addChild(_promoContent);
			}
		}
		
		override protected function draw():void
		{
			if( isInvalid(INVALIDATION_FLAG_SIZE) )
			{
				var buttonGap:int;
				var titleGap:int;
				var padding:int;
				var maxButtonHeight:int;
				var maxButtonWidth:int;
				if( AbstractGameInfo.LANDSCAPE )
				{
					padding = scaleAndRoundToDpi(GlobalConfig.isPhone ? 10 : 20);
					buttonGap = scaleAndRoundToDpi(GlobalConfig.isPhone ? 15 : 30);
					titleGap = scaleAndRoundToDpi(_withTokens ? 40 : 120);
						
					_title.width = actualWidth;
					
					_withTokens.height = _withCredits.height = scaleAndRoundToDpi(GlobalConfig.isPhone ? 180 : 200);
					if( _withPoints ) _withPoints.height = _withTokens.height;
					
					maxButtonWidth = (actualWidth - buttonGap * (_withPoints ? 2 : 1) - scaleAndRoundToDpi(20)) / (_withPoints ? 3.25 : 3);
					_withTokens.width = _withCredits.width = maxButtonWidth;
					if( _withPoints ) _withPoints.width = _withTokens.width;
					
					_withTokens.x = ((actualWidth - scaleAndRoundToDpi(20) - (maxButtonWidth * (_withPoints ? 3 : 2))) * 0.5) << 0;
					if( _withPoints ) _withPoints.x = _withTokens.x + maxButtonWidth + buttonGap;
					_withCredits.x = (_withPoints ? _withPoints.x : _withTokens.x) + maxButtonWidth + buttonGap;
					
					_withTokens.validate();
					
					_title.y = padding + (actualHeight - _title.height - (titleGap * (_withPoints ? 2: 1)) - buttonGap - (padding * 2) - _withTokens.height - (_tournamentRankingButton ? _tournamentRankingButton.height : 0)) * 0.5;
					
					_withTokens.y = _withCredits.y = _title.y + _title.height + titleGap;
					if( _withPoints ) _withPoints.y = _withTokens.y;
					
					if(_tournamentRankingButton)
					{
						_tournamentRankingButton.x = roundUp((actualWidth - _tournamentRankingButton.width) * 0.5);
						_tournamentRankingButton.y = _withCredits.y + _withCredits.height + titleGap;
					}
				}
				else
				{
					if(_promoContent)
					{
						_promoContent.x = actualWidth - _promoContent.width - scaleAndRoundToDpi(GlobalConfig.isPhone ? 30 : 60);
						_promoContent.y = scaleAndRoundToDpi(GlobalConfig.isPhone ? 38 : 68);
						_promoContent.animate();
					}
					
					padding = scaleAndRoundToDpi(GlobalConfig.isPhone ? 10 : 20);
					buttonGap = scaleAndRoundToDpi(GlobalConfig.isPhone ? 30 : 60) * ((_promoContent && _withPoints) ? 0.5 : 1);
					titleGap = scaleAndRoundToDpi(_promoContent ? (_withPoints ? 20 : 50) : 50);
					
					_title.width = actualWidth;
					
					maxButtonHeight = ( actualHeight - _title.height - titleGap - (padding * 2) - (_tournamentRankingButton ? _tournamentRankingButton.height : 0) - (_promoContent ? _promoContent.height : 0) - (buttonGap * (_withPoints ? 3 : 2)) ) / (_withPoints ? 3 : 2);
					_withTokens.height = _withCredits.height = scaleAndRoundToDpi(GlobalConfig.isPhone ? 130 : 150) > maxButtonHeight ? maxButtonHeight : scaleAndRoundToDpi(GlobalConfig.isPhone ? 130 : 150);
					if( _withPoints ) _withPoints.height = _withTokens.height;
					
					_withTokens.width = _withCredits.width = actualWidth * (GlobalConfig.isPhone ? 0.7 : 0.55);
					if( _withPoints ) _withPoints.width = _withTokens.width;
					
					_withTokens.x = _withCredits.x = ((actualWidth - _withTokens.width) * 0.5) << 0;
					if( _withPoints ) _withPoints.x = _withTokens.x;
					
					_withTokens.validate();
					
					_title.y = padding + ((_promoContent ? (_promoContent.y + _promoContent.height) : 0) + actualHeight - _title.height - titleGap - (buttonGap * (_withPoints ? 3 : 2)) - (_tournamentRankingButton ? _tournamentRankingButton.height : 0) - (padding * 2) - (_withTokens.height * (_withPoints ? 3 : 2))) * 0.5;
					
					_withTokens.y = _title.y + _title.height + titleGap;
					_withCredits.y = _withTokens.y + _withTokens.height + buttonGap;
					
					if( _withPoints )
						_withPoints.y = _withCredits.y + _withTokens.height + buttonGap;
					
					if(_tournamentRankingButton)
					{
						_tournamentRankingButton.x = _withPoints.x + ((_withPoints.width - _tournamentRankingButton.width) * 0.5);
						_tournamentRankingButton.y = _withPoints.y + _withPoints.height + buttonGap + scaleAndRoundToDpi(GlobalConfig.isPhone ? 10 : 20);
					}
				}
			}
			
			super.draw();
		}
		
//------------------------------------------------------------------------------------------------------------
//	Handlers
//------------------------------------------------------------------------------------------------------------
		
		/**
		 * Play with points (tournament mode only).
		 * 
		 * <p>No verification is needed here because this listener is not set if
		 * the user doesn't have enough points.</p>
		 */		
		private function onPlayWithPoints(event:Event):void
		{
			if( GAnalytics.isSupported() )
				GAnalytics.analytics.defaultTracker.trackEvent("Choix des mises (mode " + this.advancedOwner.screenData.gameType +  ")", "Choix de la mise Points", null, NaN, MemberManager.getInstance().id);
			
			this.advancedOwner.screenData.gamePrice = StakeType.POINT;
			advancedOwner.dispatchEventWith(MobileEventTypes.ANIMATE_FOOTER, false, { type:StakeType.POINT, value:-Storage.getInstance().getProperty( StorageConfig.PROPERTY_NUM_POINTS_IN_TOURNAMENT_MODE ) });
			handleNextScreen();
		}
		
		/**
		 * Play with free game session.
		 * 
		 * <p>No verification is needed here because this listener is not set if
		 * the user doesn't have free game sessions left.</p>
		 */		
		private function onPlayWithTokens(event:Event):void
		{
			if( GAnalytics.isSupported() )
				GAnalytics.analytics.defaultTracker.trackEvent("Choix des mises (mode " + this.advancedOwner.screenData.gameType +  ")", "Choix de la mise Jetons", null, NaN, MemberManager.getInstance().id);
			
			this.advancedOwner.screenData.gamePrice = StakeType.TOKEN;
			advancedOwner.dispatchEventWith(MobileEventTypes.ANIMATE_FOOTER, false, { type:StakeType.TOKEN, value:-Storage.getInstance().getProperty( this.advancedOwner.screenData.gameType == GameMode.SOLO ? StorageConfig.NUM_TOKENS_IN_SOLO_MODE:StorageConfig.NUM_TOKENS_IN_TOURNAMENT_MODE ) });
			handleNextScreen();
		}
		
		/**
		 * Play with credits.
		 * 
		 * <p>If the user doesn't have enough credits, he will be redirected
		 * to the store.</p>
		 */		
		private function onPlayWithCredits(event:Event):void
		{
			if( _withCredits.isEnabled )
			{
				if( GAnalytics.isSupported() )
					GAnalytics.analytics.defaultTracker.trackEvent("Choix des mises (mode " + this.advancedOwner.screenData.gameType +  ")", "Choix de la mise Crédits", null, NaN, MemberManager.getInstance().id);
				
				this.advancedOwner.screenData.gamePrice = StakeType.CREDIT;
				advancedOwner.dispatchEventWith(MobileEventTypes.ANIMATE_FOOTER, false, { type:StakeType.CREDIT, value:-Storage.getInstance().getProperty( this.advancedOwner.screenData.gameType == GameMode.SOLO ? StorageConfig.PROPERTY_NUM_CREDITS_IN_FREE_MODE:StorageConfig.PROPERTY_NUM_CREDITS_IN_TOURNAMENT_MODE ) });
				handleNextScreen();
			}
			else
			{
				this.advancedOwner.showScreen( ScreenIds.STORE_SCREEN );
			}
		}
		
		private function onGoTournamentRanking(event:Event):void
		{
			AbstractEntryPoint.screenNavigator.showScreen( ScreenIds.TOURNAMENT_RANKING_SCREEN );
		}
		
		private function handleNextScreen():void
		{
			_withCredits.touchable = false;
			if( _withPoints )
				_withPoints.touchable = false;
			_withTokens.touchable = false;
			_canBack = false;
			if(_tournamentRankingButton)
				_tournamentRankingButton.touchable = false;
			
			if( this.advancedOwner.screenData.gamePrice == StakeType.TOKEN && MemberManager.getInstance().canDisplayInterstitial() )
			{
				AdManager.showInterstitial();
			}
			
			TweenMax.delayedCall(2, changeScreen);
		}
		
		private function changeScreen():void
		{
			TweenMax.killDelayedCallsTo(changeScreen); // just in case
			advancedOwner.showScreen( ScreenIds.GAME_SCREEN );
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
		
		override public function dispose():void
		{
			_title.removeFromParent(true);
			_title = null;
			
			if( _withPoints )
			{
				_withPoints.removeEventListener(Event.TRIGGERED, onPlayWithPoints);
				_withPoints.removeFromParent(true);
				_withPoints = null;
			}
			
			_withTokens.removeEventListener(Event.TRIGGERED, onPlayWithTokens);
			_withTokens.removeFromParent(true);
			_withTokens = null;
			
			_withCredits.removeEventListener(Event.TRIGGERED, onPlayWithCredits);
			_withCredits.removeFromParent(true);
			_withCredits = null;
			
			if(_tournamentRankingButton)
			{
				_tournamentRankingButton.removeEventListener(Event.TRIGGERED, onGoTournamentRanking);
				_tournamentRankingButton.removeFromParent(true);
				_tournamentRankingButton = null;
			}
			
			if(_promoContent)
			{
				PromoManager.getInstance().removePromo(_promoContent);
				_promoContent.removeFromParent(true);
			}
			_promoContent = null;
			
			super.dispose();
		}
		
	}
}