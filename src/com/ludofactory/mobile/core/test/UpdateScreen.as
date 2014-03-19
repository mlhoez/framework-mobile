/*
LudoFactory
Framework mobile
Author  : Maxime Lhoez
Created : 9 janv. 2014
*/
package com.ludofactory.mobile.core.test
{
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.Localizer;
	import com.ludofactory.mobile.core.controls.AdvancedScreen;
	import com.ludofactory.mobile.core.storage.Storage;
	import com.ludofactory.mobile.core.storage.StorageConfig;
	import com.ludofactory.mobile.core.test.config.GlobalConfig;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import flash.filters.DropShadowFilter;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import feathers.controls.Button;
	import feathers.controls.ImageLoader;
	import feathers.controls.Label;
	
	import starling.events.Event;
	
	public class UpdateScreen extends AdvancedScreen
	{
		/**
		 * The logo. */		
		private var _logo:ImageLoader;
		
		/**
		 * The message indicating that the player must download
		 * the new version of the application. */		
		private var _message:Label;
		
		/**
		 * The download button. */		
		private var _downloadButton:Button;
		
		public function UpdateScreen()
		{
			super();
			
			_fullScreen = true;
			_blueBackground = true;
			_canBack = false;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			_logo = new ImageLoader();
			_logo.touchable = false;
			_logo.source = Theme.gameLogoTexture;
			_logo.textureScale = GlobalConfig.dpiScale;
			addChild( _logo );
			
			_message = new Label();
			_message.text = Localizer.getInstance().translate("COMMON.FORCE_UPDATE_MESSAGE");
			_message.touchable = false;
			addChild(_message);
			_message.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(GlobalConfig.isPhone ? 40 : 60), Theme.COLOR_WHITE, false, false, null, null, null, TextFormatAlign.CENTER);
			_message.textRendererProperties.nativeFilters = [ new DropShadowFilter(0, 75, 0x000000, 1, 7, 7) ];
			
			_downloadButton = new Button();
			_downloadButton.label = Localizer.getInstance().translate("COMMON.DOWNLOAD");
			_downloadButton.addEventListener(Event.TRIGGERED, onDownload);
			addChild(_downloadButton);
		}
		
		override protected function draw():void
		{
			super.draw();
			
			_logo.width = actualWidth * (GlobalConfig.isPhone ? 0.75 : 0.65);
			_logo.validate();
			_logo.y = scaleAndRoundToDpi( GlobalConfig.isPhone ? 80 : 120 );
			_logo.x = ((actualWidth - _logo.width) * 0.5) << 0;
			
			_message.width = actualWidth * 0.8;
			_downloadButton.width = actualWidth * (GlobalConfig.isPhone ? 0.8 : 0.6);
			_message.validate();
			_downloadButton.validate();
			
			_message.x = (actualWidth - (actualWidth * 0.8)) * 0.5;
			_downloadButton.x = (actualWidth - (actualWidth * (GlobalConfig.isPhone ? 0.8 : 0.6))) * 0.5;
			_message.y = (_logo.y + _logo.height) + scaleAndRoundToDpi(GlobalConfig.isPhone ? 10 : 20) + ( ((actualHeight - _logo.x - _logo.height) - (_message.height + _downloadButton.height + scaleAndRoundToDpi(GlobalConfig.isPhone ? 70 : 140))) * 0.5) << 0;
			
			_downloadButton.y = _message.y + _message.height + scaleAndRoundToDpi(GlobalConfig.isPhone ? 60 : 120);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Handlers
//------------------------------------------------------------------------------------------------------------
		
		private function onDownload(event:Event):void
		{
			if( Storage.getInstance().getProperty(StorageConfig.PROPERTY_FORCE_UPDATE_LINK) != null && Storage.getInstance().getProperty(StorageConfig.PROPERTY_FORCE_UPDATE_LINK) != "" )
			{
				navigateToURL( new URLRequest( Storage.getInstance().getProperty(StorageConfig.PROPERTY_FORCE_UPDATE_LINK) ) );
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
//------------------------------------------------------------------------------------------------------------
		
		override public function dispose():void
		{
			_logo.removeFromParent(true);
			_logo = null;
			
			_message.removeFromParent(true);
			_message = null;
			
			_downloadButton.removeEventListener(Event.TRIGGERED, onDownload);
			_downloadButton.removeFromParent(true);
			_downloadButton = null;
			
			super.dispose();
		}
		
	}
}