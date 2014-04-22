/*
Copyright © 2006-2014 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 4 nov. 2013
*/
package com.ludofactory.mobile.core.test.achievements
{
	import com.greensock.TweenLite;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.Localizer;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.text.TextFormat;
	
	import feathers.controls.ImageLoader;
	import feathers.controls.Label;
	import feathers.core.FeathersControl;
	import feathers.display.Scale9Image;
	
	import starling.core.Starling;
	import starling.extensions.PDParticleSystem;
	
	/**
	 * A trophy message.
	 */	
	public class TrophyMessage extends FeathersControl
	{
		/**
		 * The common text format for the message. */
		private var _textFormatMessage:TextFormat;
		/**
		 * The common text format for the gain. */
		private var _textFormatGain:TextFormat;
		
		/**
		 * The trophy background. */		
		private var _background:Scale9Image;
		
		/**
		 * The trophy image. */		
		private var _image:ImageLoader;
		
		/**
		 * The trophy message. */		
		private var _message:Label;
		
		/**
		 * The trophy data. */		
		private var _trophyData:TrophyData;
		
		/**
		 * Particles */		
		private var _particles:PDParticleSystem;
		
		public function TrophyMessage( trophyData:TrophyData )
		{
			super();
			_trophyData = trophyData;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			addChild(_background);
			
			_particles = new PDParticleSystem(Theme.particleSlowXml, Theme.particleRoundTexture);
			_particles.touchable = false;
			_particles.maxNumParticles = 100;
			_particles.startSizeVariance = 15;
			_particles.endSize = 10;
			_particles.endSizeVariance = 10;
			_particles.speed = 10;
			addChild(_particles);
			Starling.juggler.add(_particles);
			
			_image = new ImageLoader();
			_image.source = AbstractEntryPoint.assets.getTexture( _trophyData.textureName );
			_image.snapToPixels = true;
			addChild(_image);
			
			_message = new Label();
			_message.text = /*formatText(Localizer.getInstance().translate("TROPHY.WIN_MESSAGE"), */Localizer.getInstance().translate( _trophyData.descriptionTranslationKey )/*)*/;
			addChild(_message);
			_message.textRendererProperties.textFormat = _textFormatMessage;
		}
		
		override protected function draw():void
		{
			super.draw();
			
			_background.width = actualWidth;
			_background.height = actualHeight;
			
			_image.height = actualHeight - scaleAndRoundToDpi(6); // background stroke
			_image.validate();
			_image.x = actualWidth - _image.width - scaleAndRoundToDpi(5);
			_image.y = (actualHeight - _image.height) * 0.5;
			
			_message.x = scaleAndRoundToDpi(10);
			_message.width = _image.x - _message.x - scaleAndRoundToDpi(5);
			_message.validate();
			_message.y = (Math.max(actualHeight, _message.height) - Math.min(actualHeight, _message.height)) * 0.5;
			
			_particles.emitterX = (actualWidth * 0.5);
			_particles.emitterY = (actualHeight * 0.5);
			_particles.emitterXVariance = (actualWidth * 0.5);
			_particles.emitterYVariance = (actualHeight * 0.5);
			_particles.start();
			
			TweenLite.to(_message, 0.5, { delay:3, alpha:0, onComplete:displayReward });
		}
		
		/**
		 * Replaces the trophy description by the rewerd.
		 */		
		private function displayReward():void
		{
			_message.text = Localizer.getInstance().translate( _trophyData.rewardTranslationKey );
			_message.textRendererProperties.textFormat = _textFormatGain;
			_message.validate();
			_message.y = (Math.max(actualHeight, _message.height) - Math.min(actualHeight, _message.height)) * 0.5;
			TweenLite.to(_message, 0.5, { alpha:1 });
		}
		
//------------------------------------------------------------------------------------------------------------
//	Get / Set
//------------------------------------------------------------------------------------------------------------
		
		public function set background(val:Scale9Image):void
		{
			_background = val;
		}
		
		public function set textFormatMessage(val:TextFormat):void
		{
			_textFormatMessage = val;
		}
		
		public function set textFormatGain(val:TextFormat):void
		{
			_textFormatGain = val;
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
//------------------------------------------------------------------------------------------------------------
		
		override public function dispose():void
		{
			Starling.juggler.remove(_particles);
			_particles.stop(true);
			_particles.removeFromParent(true);
			_particles = null;
			
			_background.removeFromParent(true);
			_background = null;
			
			_image.removeFromParent(true);
			_image = null;
			
			_message.removeFromParent(true);
			_message = null;
			
			_trophyData = null;
			
			super.dispose();
		}
		
	}
}