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
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.events.MobileEventTypes;
	import com.ludofactory.mobile.core.manager.MemberManager;
	import com.ludofactory.mobile.core.model.GameMode;
	import com.ludofactory.mobile.core.storage.Storage;
	import com.ludofactory.mobile.core.storage.StorageConfig;
	import com.ludofactory.mobile.core.theme.Theme;

	import flash.filters.BitmapFilterQuality;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;

	import starling.display.Image;
	import starling.events.Event;
	import starling.utils.formatString;
	
	public class StakeButtonCredit extends StakeButton
	{
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
			
			_backgroundSkin.textures = Theme.buttonYellowSkinTextures;

			_label.color = 0x622100;
			_label.nativeFilters = [ new GlowFilter(0xffe400, 1, scaleAndRoundToDpi(1.0), scaleAndRoundToDpi(1.0), scaleAndRoundToDpi(5), BitmapFilterQuality.LOW),
				new DropShadowFilter(2, 75, 0xffe400, 0.6, scaleAndRoundToDpi(1), scaleAndRoundToDpi(1), scaleAndRoundToDpi(1), BitmapFilterQuality.LOW) ];
			
			if( _gameType == GameMode.SOLO )
			{
				_winMorePointsImage = new Image( AbstractEntryPoint.assets.getTexture( "WinMorePoints" + (MemberManager.getInstance().rank < 5 ? "X5" : "X6") + LanguageManager.getInstance().lang ) );
				_winMorePointsImage.scaleX = _winMorePointsImage.scaleY = GlobalConfig.dpiScale;
				_winMorePointsImage.alignPivot();
				_container.addChild( _winMorePointsImage );
			}
			
			onUpdateData();
			MemberManager.getInstance().addEventListener(MobileEventTypes.MEMBER_UPDATED, onUpdateData);
		}
		
		override protected function draw():void
		{
			super.draw();
			
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
			
			_icon.texture = AbstractEntryPoint.assets.getTexture("stake-choice-credit-icon");
		}
		
		override protected function triggerButton():void
		{
			dispatchEventWith(Event.TRIGGERED);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
//------------------------------------------------------------------------------------------------------------
		
		override public function dispose():void
		{
			MemberManager.getInstance().removeEventListener(MobileEventTypes.MEMBER_UPDATED, onUpdateData);
			
			if( _winMorePointsImage )
			{
				_winMorePointsImage.removeFromParent(true);
				_winMorePointsImage = null;
			}
			
			super.dispose();
		}
		
	}
}