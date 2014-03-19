/*
LudoFactory
Framework mobile
Author  : Maxime Lhoez
Created : 25 oct. 2013
*/
package com.ludofactory.mobile.core.test.store
{
	import com.greensock.TweenMax;
	import com.greensock.easing.Back;
	import com.greensock.easing.Linear;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.test.config.GlobalConfig;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import feathers.controls.Label;
	import feathers.core.FeathersControl;
	
	import starling.display.Image;
	import starling.utils.deg2rad;
	
	public class StoreSuccessAnimationComponenent extends FeathersControl
	{
		/**
		 * The glow. */		
		private var _glow:Image;
		/**
		 * The image. */		
		private var _image:Image;
		/**
		 * The message. */		
		private var _message:Label;
		
		private var _textValue:String;
		
		public function StoreSuccessAnimationComponenent(textValue:String)
		{
			super();
			
			_textValue = textValue;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			_glow = new Image( AbstractEntryPoint.assets.getTexture("HighScoreGlow") );
			_glow.alpha = 0;
			_glow.scaleX = _glow.scaleY = GlobalConfig.stageWidth / _glow.width;
			_glow.alignPivot();
			addChild( _glow );
			
			_image = new Image( AbstractEntryPoint.assets.getTexture("menu-icon-credit") );
			_image.scaleX = _image.scaleY = GlobalConfig.dpiScale;
			_image.alignPivot();
			addChild( _image );
			
			_message = new Label();
			_message.alpha = 0;
			_message.text = _textValue;
			addChild(_message);
			_message.textRendererProperties.textFormat = Theme.labelMessageHighscorePodiumTextFormat;
		}
		
		override protected function draw():void
		{
			super.draw();
			
			_glow.x = this.actualWidth * 0.5;
			_glow.y = this.actualHeight * 0.4 + _image.height * 0.1;
			TweenMax.to(_glow, 0.75, { delay:0.75, alpha:1 } );
			TweenMax.to(_glow, 10, { delay:0.75, rotation:deg2rad(360), ease:Linear.easeNone, repeat:-1 } );
			
			_image.x = this.actualWidth * 0.5;
			_image.y = this.actualHeight * 0.4;
			
			_message.width = this.actualWidth;
			_message.validate();
			_message.y = (( (this.actualHeight - (_image.y + _image.height * 0.5)) - _message.height ) * 0.5) + _image.y + _image.height * 0.5;;
			TweenMax.to(_message, 0.75, { delay:1.5, alpha:1 } );
			
			_image.scaleX = _image.scaleY = 0;
			TweenMax.to(_image, 0.75, { delay:0.5, scaleX:GlobalConfig.dpiScale, scaleY:GlobalConfig.dpiScale, ease:Back.easeOut } );
			
			TweenMax.to(_glow, 0.5, { delay:5, alpha:0 } );
			TweenMax.to(_glow, 1, { delay:5, rotation:deg2rad(360) } );
			TweenMax.to(_message, 0.5, { delay:5, alpha:0 } );
			TweenMax.to(_image, 0.5, { delay:5, alpha:0, scaleX:0, scaleY:0, ease:Back.easeIn } );
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
//------------------------------------------------------------------------------------------------------------
		
		override public function dispose():void
		{
			TweenMax.killTweensOf(_glow);
			_glow.removeFromParent(true);
			_glow = null;
			
			TweenMax.killTweensOf(_message);
			_message.removeFromParent(true);
			_message = null;
			
			TweenMax.killTweensOf(_image);
			_image.removeFromParent(true);
			_image = null;
			
			super.dispose();
		}
	}
}