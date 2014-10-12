/*
Copyright © 2006-2014 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 17 Août 2013
*/
package com.ludofactory.mobile.core.navigation.game
{
	import com.ludofactory.common.gettext.LanguageManager;
	import com.ludofactory.common.gettext.aliases._n;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.authentication.MemberManager;
	import com.ludofactory.mobile.core.events.LudoEventType;
	import com.ludofactory.mobile.core.storage.Storage;
	import com.ludofactory.mobile.core.storage.StorageConfig;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.push.GameSession;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import flash.text.TextFormat;
	
	import feathers.controls.Label;
	
	import starling.display.Image;
	import starling.events.Event;
	import starling.utils.formatString;
	
	public class StakeButtonCredit extends StakeButton
	{
		/**
		 * The credit icon. */		
		private var _icon:Image;
		/**
		 * The free disabled icon. */ 		
		private var _iconDisabled:Image;
		/**
		 * The main label */		
		private var _label:Label;
		/**
		 * The add more credits icon. */		
		private var _addIcon:Image;
		/**
		 * The win more points image */
		private var _winMorePointsImage:Image;
		/**
		 * The game type. */		
		private var _gameType:String;
		
		public function StakeButtonCredit(gameType:String)
		{
			super();
			
			_gameType = gameType;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			_backgroundDisabledSkin.visible = MemberManager.getInstance().isLoggedIn() ? false : true;
			
			_label = new Label();
			_container.addChild(_label);
			_label.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(42), (MemberManager.getInstance().isLoggedIn() ? 0x401800 : 0x2d2d2d));
			
			_icon = new Image( AbstractEntryPoint.assets.getTexture("GameTypeSelectionCreditsIcon") );
			_icon.scaleX = _icon.scaleY = GlobalConfig.dpiScale;
			_container.addChild(_icon);
			
			_iconDisabled = new Image( AbstractEntryPoint.assets.getTexture("GameTypeSelectionCreditsIconDisabled") );
			_iconDisabled.scaleX = _iconDisabled.scaleY = GlobalConfig.dpiScale;
			_container.addChild(_iconDisabled);
			
			_addIcon = new Image( AbstractEntryPoint.assets.getTexture("GameTypeSelectionAddIcon") );
			_addIcon.scaleX = _addIcon.scaleY = GlobalConfig.dpiScale;
			_addIcon.alignPivot();
			_container.addChild(_addIcon);
			
			if( _gameType == GameSession.TYPE_CLASSIC )
			{
				_winMorePointsImage = new Image( AbstractEntryPoint.assets.getTexture( "WinMorePoints" + (MemberManager.getInstance().getRank() < 5 ? "X5" : "X6") + LanguageManager.getInstance().lang ) );
				_winMorePointsImage.scaleX = _winMorePointsImage.scaleY = GlobalConfig.dpiScale;
				_winMorePointsImage.alignPivot();
				_winMorePointsImage.visible = MemberManager.getInstance().isLoggedIn();
				_container.addChild( _winMorePointsImage );
			}
			
			onUpdateData();
			MemberManager.getInstance().addEventListener(LudoEventType.UPDATE_SUMMARY, onUpdateData);
		}
		
		override protected function draw():void
		{
			super.draw();
			
			_backgroundSkin.width = _backgroundDisabledSkin.width = this.actualWidth;
			_backgroundSkin.height = _backgroundDisabledSkin.height = this.actualHeight;
			
			_icon.x = _iconDisabled.x = scaleAndRoundToDpi(40);
			_icon.y = _iconDisabled.y = (this.actualHeight - _icon.height) * 0.5;
			
			_addIcon.x = _shadowThickness;
			_addIcon.y = this.actualHeight - _shadowThickness;
			
			_label.width = this.actualWidth - _icon.x - _icon.width - _shadowThickness;
			_label.x = _icon.x + _icon.width + scaleAndRoundToDpi(20);
			_label.validate();
			_label.y = (this.actualHeight - _label.height) * 0.5;
			
			if( _winMorePointsImage )
			{
				_winMorePointsImage.y = -int(_shadowThickness * 0.5) + (_winMorePointsImage.height * 0.5);
				_winMorePointsImage.x = this.actualWidth - (_winMorePointsImage.width * 0.5) + int(_shadowThickness * 0.5);
			}
		}
		
		private function onUpdateData(event:Event = null):void
		{
			_isEnabled = MemberManager.getInstance().getCredits() >= Storage.getInstance().getProperty(  AbstractEntryPoint.screenNavigator.screenData.gameType == GameSession.TYPE_CLASSIC ? StorageConfig.PROPERTY_NUM_CREDITS_IN_FREE_MODE:StorageConfig.PROPERTY_NUM_CREDITS_IN_TOURNAMENT_MODE ) ? true:false;
			
			_label.text = formatString( _n("{0} crédit", "{0} crédits", Storage.getInstance().getProperty( _gameType == GameSession.TYPE_CLASSIC ? StorageConfig.PROPERTY_NUM_CREDITS_IN_FREE_MODE:StorageConfig.PROPERTY_NUM_CREDITS_IN_TOURNAMENT_MODE )),
				Storage.getInstance().getProperty( _gameType == GameSession.TYPE_CLASSIC ? StorageConfig.PROPERTY_NUM_CREDITS_IN_FREE_MODE:StorageConfig.PROPERTY_NUM_CREDITS_IN_TOURNAMENT_MODE ) );
			
			_icon.visible = MemberManager.getInstance().isLoggedIn();
			_iconDisabled.visible = !_icon.visible;
			_addIcon.visible = MemberManager.getInstance().isLoggedIn() ? !_isEnabled : false;
		}
		
		override protected function triggerButton():void
		{
			// if the user is not logged in and the button is disabled, we won't redirect
			// to the store screen
			if( !MemberManager.getInstance().isLoggedIn() && !_isEnabled )
				return;
			
			dispatchEventWith(Event.TRIGGERED);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
//------------------------------------------------------------------------------------------------------------
		
		override public function dispose():void
		{
			MemberManager.getInstance().removeEventListener(LudoEventType.UPDATE_SUMMARY, onUpdateData);
			
			_label.removeFromParent(true);
			_label = null;
			
			_icon.removeFromParent(true);
			_icon = null;
			
			_iconDisabled.removeFromParent(true);
			_iconDisabled = null;
			
			_addIcon.removeFromParent(true);
			_addIcon = null;
			
			if( _winMorePointsImage )
			{
				_winMorePointsImage.removeFromParent(true);
				_winMorePointsImage = null;
			}
			
			super.dispose();
		}
		
	}
}