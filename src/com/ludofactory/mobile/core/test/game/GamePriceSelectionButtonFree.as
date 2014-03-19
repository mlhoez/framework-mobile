/*
LudoFactory
Framework mobile
Author  : Maxime Lhoez
Created : 17 Août 2013
*/
package com.ludofactory.mobile.core.test.game
{
	import com.ludofactory.common.utils.Utility;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.HeartBeat;
	import com.ludofactory.mobile.core.Localizer;
	import com.ludofactory.mobile.core.authentication.MemberManager;
	import com.ludofactory.mobile.core.events.LudoEventType;
	import com.ludofactory.mobile.core.storage.Storage;
	import com.ludofactory.mobile.core.storage.StorageConfig;
	import com.ludofactory.mobile.core.test.config.GlobalConfig;
	import com.ludofactory.mobile.core.test.home.summary.SummaryContainer;
	import com.ludofactory.mobile.core.test.push.GameSession;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.getTimer;
	
	import feathers.controls.Callout;
	import feathers.controls.Label;
	
	import starling.display.Image;
	import starling.events.Event;
	import starling.utils.formatString;
	
	public class GamePriceSelectionButtonFree extends GamePriceSelectionButton
	{
		public static var IS_TIMER_OVER_AND_REQUEST_FAILED:Boolean = false;
		
		/**
		 * The free icon. */		
		private var _icon:Image;
		/**
		 * The free disabled icon. */ 		
		private var _iconDisabled:Image;
		/**
		 * The main label */		
		private var _label:Label;
		/**
		 * The clock icon. */		
		private var _iconClock:Image;
		
		/**
		 * The timer variables. */		
		private var _previousTime:Number;
		private var _elapsedTime:Number;
		private var _totalTime:Number;
		
		private var _h:int;
		private var _m:int;
		private var _s:int;
		
		private var _isCalloutDisplaying:Boolean = false;
		
		private var _calloutLabel:Label;
		
		/**
		 *  The game type. */		
		private var _gameType:String;
		
		public function GamePriceSelectionButtonFree(gameType:String)
		{
			super();
			
			_gameType = gameType;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			_label = new Label();
			_container.addChild(_label);
			
			_icon = new Image( AbstractEntryPoint.assets.getTexture("GameTypeSelectionFreeIcon") );
			_icon.scaleX = _icon.scaleY = GlobalConfig.dpiScale;
			_container.addChild(_icon);
			
			_iconDisabled = new Image( AbstractEntryPoint.assets.getTexture("GameTypeSelectionFreeIconDisabled") );
			_iconDisabled.scaleX = _iconDisabled.scaleY = GlobalConfig.dpiScale;
			_container.addChild(_iconDisabled);
			
			_iconClock = new Image( AbstractEntryPoint.assets.getTexture("GameTypeSelectionClockIcon") );
			_iconClock.scaleX = _iconClock.scaleY = GlobalConfig.dpiScale;
			_iconClock.alignPivot();
			_container.addChild(_iconClock);
			
			onUpdateData();
			MemberManager.getInstance().addEventListener(LudoEventType.UPDATE_SUMMARY, onUpdateData);
		}
		
		override protected function draw():void
		{
			super.draw();
			
			if( _iconClock )
			{
				_iconClock.x = _shadowThickness;
				_iconClock.y = this.actualHeight - _shadowThickness;
			}
			
			_backgroundSkin.width = _backgroundDisabledSkin.width = this.actualWidth;
			_backgroundSkin.height = _backgroundDisabledSkin.height = this.actualHeight;
			
			_icon.x = _iconDisabled.x = scaleAndRoundToDpi(40);
			_icon.y = _iconDisabled.y = (this.actualHeight - _icon.height) * 0.5;
			
			_label.width = actualWidth - _icon.x - _icon.width - _shadowThickness - scaleAndRoundToDpi(20);
			_label.x = _icon.x + _icon.width + scaleAndRoundToDpi(20);
			_label.validate();
			_label.y = (actualHeight - _label.height) * 0.5;
		}
		
		/**
		 * Update data.
		 */		
		private function onUpdateData(event:Event = null):void
		{
			_isEnabled = MemberManager.getInstance().getNumFreeGameSessions() >= Storage.getInstance().getProperty( AbstractEntryPoint.screenNavigator.screenData.gameType == GameSession.TYPE_FREE ? StorageConfig.PROPERTY_NUM_FREE_IN_FREE_MODE:StorageConfig.PROPERTY_NUM_FREE_IN_TOURNAMENT_MODE ) ? true:false;
			
			HeartBeat.unregisterFunction(update);
			
			_iconClock.visible = false;
			_icon.visible = _isEnabled;
			_iconDisabled.visible = !_icon.visible;
			_backgroundSkin.visible = _isEnabled;
			_backgroundDisabledSkin.visible = !_backgroundSkin.visible;
			
			if( _isEnabled )
			{
				_label.text = formatString( Localizer.getInstance().translate( Storage.getInstance().getProperty( _gameType == GameSession.TYPE_FREE ? StorageConfig.PROPERTY_NUM_FREE_IN_FREE_MODE:StorageConfig.PROPERTY_NUM_FREE_IN_TOURNAMENT_MODE) > 1 ? "GAME_TYPE_SELECTION.LABEL_ENABLED_FREE_PLURAL":"GAME_TYPE_SELECTION.LABEL_ENABLED_FREE_SINGULAR"),
					Storage.getInstance().getProperty( _gameType == GameSession.TYPE_FREE ? StorageConfig.PROPERTY_NUM_FREE_IN_FREE_MODE:StorageConfig.PROPERTY_NUM_FREE_IN_TOURNAMENT_MODE ));
				_label.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(42), 0x0d2701);
			}
			else
			{
				if( MemberManager.getInstance().getNumFreeGameSessions() != 0 || !MemberManager.getInstance().isLoggedIn() )
				{
					_label.text = formatString( Localizer.getInstance().translate( Storage.getInstance().getProperty( _gameType == GameSession.TYPE_FREE ? StorageConfig.PROPERTY_NUM_FREE_IN_FREE_MODE:StorageConfig.PROPERTY_NUM_FREE_IN_TOURNAMENT_MODE) > 1 ? "GAME_TYPE_SELECTION.LABEL_ENABLED_FREE_PLURAL":"GAME_TYPE_SELECTION.LABEL_ENABLED_FREE_SINGULAR"),
						Storage.getInstance().getProperty( _gameType == GameSession.TYPE_FREE ? StorageConfig.PROPERTY_NUM_FREE_IN_FREE_MODE:StorageConfig.PROPERTY_NUM_FREE_IN_TOURNAMENT_MODE ));
					_label.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(42), 0x2d2d2d);
				}
				else
				{
					if( SummaryContainer.IS_TIMER_OVER_AND_REQUEST_FAILED )
					{
						_label.text = "???";
						_label.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(56), Theme.COLOR_WHITE);
					}
					else
					{
						// mettre texte normal + timer
						_label.text = formatString(Localizer.getInstance().translate("GAME_TYPE_SELECTION.LABEL_DISABLED_FREE"), MemberManager.getInstance().getNumFreeGameSessionsTotal());
						_label.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(42), Theme.COLOR_WHITE);
						
						var nowInFrance:Date = Utility.getLocalFrenchDate();
						_totalTime = (86400 - (nowInFrance.hours * 60 * 60) - (nowInFrance.minutes * 60) - nowInFrance.seconds) * 1000;
						_previousTime = getTimer();
						HeartBeat.registerFunction(update);
					}
					_iconClock.visible = true;
				}
			}
		}
		
		private function update(elapsedTime:Number):void
		{
			_elapsedTime = getTimer() - _previousTime;
			_previousTime = getTimer();
			_totalTime -= _elapsedTime;
			
			_h = Math.round(_totalTime / 1000) / 3600;
			_m = (Math.round(_totalTime / 1000) / 60) % 60;
			_s = Math.round(_totalTime / 1000) % 60;
			
			if( _h <= 0 && _m <= 0 && _s <= 0 )
			{
				HeartBeat.unregisterFunction(update);
				if( _label )
					_label.text = formatString(Localizer.getInstance().translate("GAME_TYPE_SELECTION.LABEL_DISABLED_FREE"), MemberManager.getInstance().getNumFreeGameSessionsTotal()) + (_h < 10 ? "0":"") + _h + ":" + (_m < 10 ? "0":"") + _m + ":" + (_s < 10 ? "0":"") + _s;
			}
			else
			{
				if( _label )
					_label.text = formatString(Localizer.getInstance().translate("GAME_TYPE_SELECTION.LABEL_DISABLED_FREE"), MemberManager.getInstance().getNumFreeGameSessionsTotal()) + (_h < 10 ? "0":"") + _h + ":" + (_m < 10 ? "0":"") + _m + ":" + (_s < 10 ? "0":"") + _s;
			}
		}
		
		private function onCalloutRemoved(event:Event):void
		{
			event.target.removeEventListener(Event.REMOVED_FROM_STAGE, onCalloutRemoved);
			_isCalloutDisplaying = false;
		}
		
		override protected function triggerButton():void
		{
			if( _isEnabled )
			{
				dispatchEventWith(Event.TRIGGERED);
			}
			else
			{
				if( SummaryContainer.IS_TIMER_OVER_AND_REQUEST_FAILED )
				{
					if( !_isCalloutDisplaying )
					{
						if( !_calloutLabel )
						{
							_calloutLabel = new Label();
							_calloutLabel.text = formatString(Localizer.getInstance().translate("SUMMARY.TIMER_OVER_AND_REQUEST_FAILED"), MemberManager.getInstance().getNumFreeGameSessionsTotal());
							_calloutLabel.width = actualWidth * 0.9;
							_calloutLabel.validate();
						}
						_isCalloutDisplaying = true;
						var callout:Callout = Callout.show(_calloutLabel, this, Callout.DIRECTION_UP, false);
						callout.disposeContent = false;
						callout.touchable = false;
						callout.addEventListener(Event.REMOVED_FROM_STAGE, onCalloutRemoved);
						_calloutLabel.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(26), Theme.COLOR_DARK_GREY, false, false, null, null, null, TextFormatAlign.CENTER);
					}
				}
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
//------------------------------------------------------------------------------------------------------------
		
		override public function dispose():void
		{
			MemberManager.getInstance().removeEventListener(LudoEventType.UPDATE_SUMMARY, onUpdateData);
			HeartBeat.unregisterFunction(update);
			
			_label.removeFromParent(true);
			_label = null;
			
			_icon.removeFromParent(true);
			_icon = null;
			
			_iconDisabled.removeFromParent(true);
			_iconDisabled = null;
			
			if( _iconClock )
			{
				_iconClock.removeFromParent(true);
				_iconClock = null;
			}
			
			super.dispose();
		}
		
	}
}