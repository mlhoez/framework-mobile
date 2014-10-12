/*
Copyright © 2006-2014 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 9 janv. 2014
*/
package com.ludofactory.mobile.navigation
{
	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.controls.AdvancedScreen;
	import com.ludofactory.mobile.core.storage.Storage;
	import com.ludofactory.mobile.core.storage.StorageConfig;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import flash.filters.DropShadowFilter;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import feathers.controls.Button;
	import feathers.controls.ImageLoader;
	import feathers.controls.Label;

	import starling.display.DisplayObject;

	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;

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
			_message.text = Storage.getInstance().getProperty(StorageConfig.PROPERTY_FORCE_UPDATE_TEXT); //_("Une mise à jour de l'application est disponible !\n\nMerci de la télécharger pour assurer son bon fonctionnement.");
			_message.touchable = false;
			addChild(_message);
			_message.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(GlobalConfig.isPhone ? 40 : 60), Theme.COLOR_WHITE, false, false, null, null, null, TextFormatAlign.CENTER);
			_message.textRendererProperties.nativeFilters = [ new DropShadowFilter(0, 75, 0x000000, 1, 7, 7) ];
			
			if( Storage.getInstance().getProperty(StorageConfig.PROPERTY_FORCE_UPDATE_BUTTON_NAME) != "" )
			{
				_downloadButton = new Button();
				_downloadButton.label = Storage.getInstance().getProperty(StorageConfig.PROPERTY_FORCE_UPDATE_BUTTON_NAME); //_("Télécharger");
				addChild(_downloadButton);
			}
			
			addEventListener(TouchEvent.TOUCH, onDownload);
		}
		
		override protected function draw():void
		{
			if( isInvalid(INVALIDATION_FLAG_SIZE) )
			{
				super.draw();
				
				_logo.width = actualWidth * (GlobalConfig.isPhone ? 0.75 : 0.65);
				_logo.validate();
				_logo.y = scaleAndRoundToDpi( GlobalConfig.isPhone ? 80 : 120 );
				_logo.x = ((actualWidth - _logo.width) * 0.5) << 0;
				
				if( _downloadButton )
				{
					_downloadButton.width = actualWidth * (GlobalConfig.isPhone ? 0.8 : 0.6);
					_downloadButton.x = (actualWidth - (actualWidth * (GlobalConfig.isPhone ? 0.8 : 0.6))) * 0.5;
					_downloadButton.validate();
					_downloadButton.y = actualHeight - _downloadButton.height - scaleAndRoundToDpi(10);
				}
				
				var maxMessageHeight:int = (_downloadButton ? _downloadButton.y : actualHeight) - (_logo.y + _logo.height) - scaleAndRoundToDpi(20); /* 10 + 10 padding on top and bottom */
				
				_message.width = actualWidth * 0.8;
				_message.x = (actualWidth - (actualWidth * 0.8)) * 0.5;
				_message.validate();
				
				if( _message.height > maxMessageHeight )
				{
					_message.height = maxMessageHeight;
					_message.y = (_logo.y + _logo.height) + scaleAndRoundToDpi(10);
				}
				else
				{
					_message.y = (_logo.y + _logo.height) + scaleAndRoundToDpi(10) + ( (((_downloadButton ? _downloadButton.y : actualHeight) - _logo.x - _logo.height) - (_message.height + scaleAndRoundToDpi(10))) * 0.5) << 0;
				}
				
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Handlers
//------------------------------------------------------------------------------------------------------------
		
		private function onDownload(event:TouchEvent):void
		{
			var touch:Touch = event.getTouch(this);
			if( touch && touch.phase == TouchPhase.ENDED )
			{
				if( Storage.getInstance().getProperty(StorageConfig.PROPERTY_FORCE_UPDATE_LINK) != null && Storage.getInstance().getProperty(StorageConfig.PROPERTY_FORCE_UPDATE_LINK) != "" )
				{
					navigateToURL( new URLRequest( Storage.getInstance().getProperty(StorageConfig.PROPERTY_FORCE_UPDATE_LINK) ) );
				}
			}
			touch = null;
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
//------------------------------------------------------------------------------------------------------------
		
		override public function dispose():void
		{
			removeEventListener(TouchEvent.TOUCH, onDownload);
			
			_logo.removeFromParent(true);
			_logo = null;
			
			_message.removeFromParent(true);
			_message = null;
			
			if( _downloadButton )
			{
				_downloadButton.removeFromParent(true);
				_downloadButton = null;
			}
			
			super.dispose();
		}
		
	}
}