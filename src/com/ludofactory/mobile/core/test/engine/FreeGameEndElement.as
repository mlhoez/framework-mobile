/*
Copyright © 2006-2014 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 13 oct. 2013
*/
package com.ludofactory.mobile.core.test.engine
{
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.test.config.GlobalConfig;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import flash.geom.Rectangle;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import feathers.controls.ImageLoader;
	import feathers.controls.Label;
	import feathers.core.FeathersControl;
	import feathers.display.Scale9Image;
	import feathers.textures.Scale9Textures;
	
	import starling.display.Image;
	import starling.utils.HAlign;
	import starling.utils.VAlign;
	import starling.utils.deg2rad;
	
	public class FreeGameEndElement extends FeathersControl
	{
		/**
		 * The background. */		
		private var _background:Scale9Image;
		
		/**
		 * The icon. */		
		private var _icon:Image;
		
		/**
		 * The message. */		
		private var _messageLabel:Label;
		
		/**
		 *  */		
		private var _imageTextureName:String;
		
		/**
		 *  */		
		private var _message:String;
		
		/**
		 * The more icon. */		
		private var _arrow:ImageLoader;
		
		public function FreeGameEndElement(imageTextureName:String, message:String)
		{
			super();
			
			_imageTextureName = imageTextureName;
			_message = message;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			_background = new Scale9Image( new Scale9Textures( AbstractEntryPoint.assets.getTexture("scroll-container-result-grey-background-skin"), new Rectangle(15, 15, 2, 2) ), GlobalConfig.dpiScale );
			addChild(_background);
			
			_icon = new Image( AbstractEntryPoint.assets.getTexture(_imageTextureName) );
			_icon.scaleX = _icon.scaleY = GlobalConfig.dpiScale;
			_icon.alignPivot(HAlign.LEFT, VAlign.CENTER);
			addChild( _icon );
			
			_messageLabel =  new Label();
			_messageLabel.text = _message;
			addChild(_messageLabel);
			_messageLabel.textRendererProperties.textFormat = new TextFormat(Theme.FONT_ARIAL, scaleAndRoundToDpi(GlobalConfig.isPhone ? 30 : 36), Theme.COLOR_WHITE, true, false, null, null, null, TextFormatAlign.CENTER);
			
			_arrow = new ImageLoader();
			_arrow.source = AbstractEntryPoint.assets.getTexture("arrow_down");
			_arrow.scaleX = _arrow.scaleY = GlobalConfig.dpiScale;
			_arrow.snapToPixels = true;
			addChild(_arrow);
		}
		
		override protected function draw():void
		{
			super.draw();
			
			_arrow.validate();
			_arrow.alignPivot();
			_arrow.rotation = deg2rad(-90);
			_arrow.x = actualWidth - scaleAndRoundToDpi(10) - (_arrow.width * 0.5);
			
			_messageLabel.x = _icon.x + _icon.width + scaleAndRoundToDpi(5);
			_messageLabel.width = _arrow.x - _messageLabel.x;
			_messageLabel.validate();
			
			_background.width = this.actualWidth;
			_background.height = _messageLabel.height + scaleAndRoundToDpi(40);
			
			_icon.x = scaleAndRoundToDpi(10);
			_icon.y = _background.height * 0.5;
			
			//_background.y = (_icon.height * 0.95) - _background.height;
			_messageLabel.y = /*(_icon.height * 0.95) - _message.height -*/ scaleAndRoundToDpi(20);
			_arrow.y = _background.y + (_background.height * 0.5);
			
			setSizeInternal(this.actualWidth, Math.max((_icon.y + (_icon.height * 0.5)), _background.height), false);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
//------------------------------------------------------------------------------------------------------------
		
		override public function dispose():void
		{
			_background.removeFromParent(true);
			_background = null;
			
			_icon.removeFromParent(true);
			_icon = null;
			
			_messageLabel.removeFromParent(true);
			_messageLabel = null;
			
			_arrow.removeFromParent(true);
			_arrow = null;
			
			super.dispose();
		}
		
	}
}