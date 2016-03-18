/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 13 oct. 2013
*/
package com.ludofactory.mobile.navigation.engine
{
	
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import feathers.core.FeathersControl;
	
	import flash.geom.Rectangle;
	
	import starling.display.Image;
	import starling.text.TextField;
	import starling.text.TextFormat;
	import starling.utils.Align;
	import starling.utils.deg2rad;
	
	public class SoloEndElement extends FeathersControl
	{
		/**
		 * The background. */		
		private var _background:Image;
		
		/**
		 * The icon. */		
		private var _icon:Image;
		
		/**
		 * The message. */		
		private var _messageLabel:TextField;
		
		/**
		 *  */		
		private var _imageTextureName:String;
		
		/**
		 *  */		
		private var _message:String;
		
		/**
		 * The more icon. */		
		private var _arrow:Image;
		
		public function SoloEndElement(imageTextureName:String, message:String)
		{
			super();
			
			_imageTextureName = imageTextureName;
			_message = message;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			_background = new Image(AbstractEntryPoint.assets.getTexture("scroll-container-result-grey-background-skin"));
			_background.scale = GlobalConfig.dpiScale;
			_background.scale9Grid = new Rectangle(15, 15, 2, 2);
			addChild(_background);
			
			_icon = new Image( AbstractEntryPoint.assets.getTexture(_imageTextureName) );
			_icon.scaleX = _icon.scaleY = GlobalConfig.dpiScale * 0.6;
			_icon.alignPivot(Align.LEFT, Align.CENTER);
			addChild( _icon );
			
			_messageLabel =  new TextField(5, 5, _message, new TextFormat(Theme.FONT_ARIAL, scaleAndRoundToDpi(36), 0xffffff));
			_messageLabel.format.bold = true;
			_messageLabel.autoScale = true;
			addChild(_messageLabel);
			
			_arrow = new Image(AbstractEntryPoint.assets.getTexture("arrow_down"));
			_arrow.scaleX = _arrow.scaleY = GlobalConfig.dpiScale;
			_arrow.alignPivot();
			addChild(_arrow);
		}
		
		override protected function draw():void
		{
			super.draw();
			
			_background.width = this.actualWidth;
			_background.height = scaleAndRoundToDpi(70);
			
			_arrow.rotation = deg2rad(-90);
			_arrow.x = actualWidth - scaleAndRoundToDpi(10) - (_arrow.width * 0.5);
			
			_messageLabel.x = _icon.x + _icon.width + scaleAndRoundToDpi(5);
			_messageLabel.y = scaleAndRoundToDpi(5);
			_messageLabel.width = _arrow.x - _messageLabel.x - scaleAndRoundToDpi(10);
			_messageLabel.height = _background.height - scaleAndRoundToDpi(10);
			
			_icon.x = scaleAndRoundToDpi(10);
			_icon.y = _background.height * 0.5;
			
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