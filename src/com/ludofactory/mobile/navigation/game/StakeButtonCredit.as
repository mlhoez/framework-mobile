/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 17 Août 2013
*/
package com.ludofactory.mobile.navigation.game
{
	
	import com.ludofactory.common.gettext.LanguageManager;
	import com.ludofactory.common.gettext.aliases._n;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.events.MobileEventTypes;
	import com.ludofactory.mobile.core.manager.MemberManager;
	import com.ludofactory.mobile.core.model.GameMode;
	import com.ludofactory.mobile.core.storage.Storage;
	import com.ludofactory.mobile.core.storage.StorageConfig;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import starling.display.Image;
	import starling.events.Event;
	import starling.utils.formatString;
	
	public class StakeButtonCredit extends StakeButton
	{
		/**
		 * The add more credits icon. */		
		private var _addIcon:Image;
		/**
		 * The win more points image */
		private var _winMorePointsImage:Image;
		/**
		 * The game type. */		
		private var _gameType:int;
		
		public function StakeButtonCredit(gameType:int)
		{
			super();
			
			_gameType = gameType;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			_backgroundSkin.textures = MemberManager.getInstance().isLoggedIn() ? Theme.buttonYellowSkinTextures : Theme.buttonDisabledSkinTextures;

			_label.color = MemberManager.getInstance().isLoggedIn() ? 0x401800 : 0x2d2d2d;
			
			_addIcon = new Image( AbstractEntryPoint.assets.getTexture("GameTypeSelectionAddIcon") );
			_addIcon.scaleX = _addIcon.scaleY = GlobalConfig.dpiScale;
			_addIcon.alignPivot();
			_container.addChild(_addIcon);
			
			if( _gameType == GameMode.SOLO )
			{
				_winMorePointsImage = new Image( AbstractEntryPoint.assets.getTexture( "WinMorePoints" + (MemberManager.getInstance().getRank() < 5 ? "X5" : "X6") + LanguageManager.getInstance().lang ) );
				_winMorePointsImage.scaleX = _winMorePointsImage.scaleY = GlobalConfig.dpiScale;
				_winMorePointsImage.alignPivot();
				_winMorePointsImage.visible = MemberManager.getInstance().isLoggedIn();
				_container.addChild( _winMorePointsImage );
			}
			
			onUpdateData();
			MemberManager.getInstance().addEventListener(MobileEventTypes.UPDATE_SUMMARY, onUpdateData);
		}
		
		override protected function draw():void
		{
			super.draw();
			
			_addIcon.x = _shadowThickness;
			_addIcon.y = this.actualHeight - _shadowThickness;
			
			
			if( _winMorePointsImage )
			{
				_winMorePointsImage.y = -int(_shadowThickness * 0.5) + (_winMorePointsImage.height * 0.5);
				_winMorePointsImage.x = this.actualWidth;
			}
		}
		
		private function onUpdateData(event:Event = null):void
		{
			_isEnabled = MemberManager.getInstance().credits >= Storage.getInstance().getProperty(  AbstractEntryPoint.screenNavigator.screenData.gameType == GameMode.SOLO ? StorageConfig.PROPERTY_NUM_CREDITS_IN_FREE_MODE:StorageConfig.PROPERTY_NUM_CREDITS_IN_TOURNAMENT_MODE ) ? true:false;
			
			_label.text = formatString( _n("{0} Crédit", "{0} Crédits", Storage.getInstance().getProperty( _gameType == GameMode.SOLO ? StorageConfig.PROPERTY_NUM_CREDITS_IN_FREE_MODE:StorageConfig.PROPERTY_NUM_CREDITS_IN_TOURNAMENT_MODE )),
				Storage.getInstance().getProperty( _gameType == GameMode.SOLO ? StorageConfig.PROPERTY_NUM_CREDITS_IN_FREE_MODE:StorageConfig.PROPERTY_NUM_CREDITS_IN_TOURNAMENT_MODE ) );
			
			_icon.texture = MemberManager.getInstance().isLoggedIn() ? AbstractEntryPoint.assets.getTexture("GameTypeSelectionCreditsIcon") : AbstractEntryPoint.assets.getTexture("GameTypeSelectionCreditsIconDisabled");
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
			MemberManager.getInstance().removeEventListener(MobileEventTypes.UPDATE_SUMMARY, onUpdateData);
			
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