/*
LudoFactory
Framework mobile
Author  : Maxime Lhoez
Created : 17 Août 2013
*/
package com.ludofactory.mobile.core.test.game
{
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.Localizer;
	import com.ludofactory.mobile.core.authentication.MemberManager;
	import com.ludofactory.mobile.core.events.LudoEventType;
	import com.ludofactory.mobile.core.storage.Storage;
	import com.ludofactory.mobile.core.storage.StorageConfig;
	import com.ludofactory.mobile.core.test.config.GlobalConfig;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import flash.text.TextFormat;
	
	import feathers.controls.Label;
	
	import starling.display.Image;
	import starling.events.Event;
	import starling.utils.formatString;
	
	public class GamePriceSelectionButtonPoints extends GamePriceSelectionButton
	{
		/**
		 * The points icon. */		
		private var _icon:Image;
		/**
		 * The points disabled icon. */		
		private var _iconDisabled:Image;
		/**
		 * The main label */		
		private var _label:Label;
		
		public function GamePriceSelectionButtonPoints()
		{
			super();
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			_label = new Label();
			_container.addChild(_label);
			
			_icon = new Image( AbstractEntryPoint.assets.getTexture("GameTypeSelectionPointsIcon") );
			_icon.scaleX = _icon.scaleY = GlobalConfig.dpiScale;
			_container.addChild(_icon);
			
			_iconDisabled = new Image( AbstractEntryPoint.assets.getTexture("GameTypeSelectionPointsIconDisabled") );
			_iconDisabled.scaleX = _iconDisabled.scaleY = GlobalConfig.dpiScale;
			_container.addChild(_iconDisabled);
			
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
			
			_label.width = this.actualWidth - _icon.x - _icon.width - _shadowThickness;
			_label.x = _icon.x + _icon.width + scaleAndRoundToDpi(20);
			_label.validate();
			_label.y = (this.actualHeight - _label.height) * 0.5;
		}
		
		private function onUpdateData(event:Event = null):void
		{
			_isEnabled = MemberManager.getInstance().isLoggedIn() ? (MemberManager.getInstance().getPoints() >= Storage.getInstance().getProperty(StorageConfig.PROPERTY_NUM_POINTS_IN_TOURNAMENT_MODE) ? true:false) : false;
			
			_label.text = formatString( Localizer.getInstance().translate( Storage.getInstance().getProperty(StorageConfig.PROPERTY_NUM_POINTS_IN_TOURNAMENT_MODE) > 1 ? "GAME_TYPE_SELECTION.LABEL_ENABLED_POINTS_PLURAL":"GAME_TYPE_SELECTION.LABEL_ENABLED_POINTS_SINGULAR" ),
				Storage.getInstance().getProperty(StorageConfig.PROPERTY_NUM_POINTS_IN_TOURNAMENT_MODE));
			
			_icon.visible = _isEnabled;
			_iconDisabled.visible = !_icon.visible;
			
			_backgroundSkin.visible = _isEnabled;
			_backgroundDisabledSkin.visible = !_backgroundSkin.visible;
			
			if( _isEnabled )
			{
				_label.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(42), 0x002432);
			}
			else
			{
				_label.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(42), 0x2d2d2d);
			}
		}
		
		override protected function triggerButton():void
		{
			if( _isEnabled )
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
			
			super.dispose();
		}
		
	}
}