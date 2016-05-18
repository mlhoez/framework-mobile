/**
 * Created by Maxime on 22/04/2016.
 */
package com.ludofactory.mobileNew.core.splash
{
	
	import com.ludofactory.mobileNew.*;
	
	import com.ludofactory.common.utils.Utilities;
	import com.ludofactory.mobile.core.AbstractGameInfo;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	
	import feathers.controls.ImageLoader;
	import feathers.controls.ProgressBar;
	
	import flash.geom.Rectangle;
	
	import starling.display.Image;
	
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.textures.Texture;
	import starling.utils.deg2rad;
	
	/**
	 * Handles the splash screen
	 */
	public class SplashScreen extends Sprite
	{
		[Embed(source="progress-bar-background.png")]
		public static const ProgressBarBackgroundClass:Class;
		[Embed(source="progress-bar-fill.png")]
		public static const ProgressBarFillClass:Class;
		
		/**
		 * Loading background. */
		private var _loadingBackground:Image;
		/**
		 * Progress bar. */
		private var _progressBar:ProgressBar;
		
		/**
		 * 
		 * @param launchImageTexture This is the splash texture fetched from the device storage
		 */
		public function SplashScreen(launchImageTexture:Texture)
		{
			// there is a launchImageTexture when we test on a device
			// (it is the reference to the splash screen)
			if(launchImageTexture)
			{
				// OLD
				//_loadingBackground = new Image( launchImageTexture );
				//_loadingBackground.width = GlobalConfig.stageWidth;
				//_loadingBackground.height = GlobalConfig.stageHeight;
				//addChild( _loadingBackground );
				
				_loadingBackground = new Image( launchImageTexture );
				
				if(AbstractGameInfo.LANDSCAPE)
				{
					if(_loadingBackground.height > _loadingBackground.width)
					{
						// landscape but the image is portrait
						_loadingBackground.width = GlobalConfig.stageHeight;
						_loadingBackground.height = GlobalConfig.stageWidth;
						_loadingBackground.rotation = deg2rad(-90);
						_loadingBackground.x = 0;
						_loadingBackground.y = GlobalConfig.stageHeight;
					}
				}
				else
				{
					// portrait but the image is landscape
					if(_loadingBackground.width > _loadingBackground.height)
					{
						_loadingBackground.width = GlobalConfig.stageHeight;
						_loadingBackground.height = GlobalConfig.stageWidth;
						_loadingBackground.rotation = deg2rad(90);
						_loadingBackground.x = 0;
						_loadingBackground.y = 0;
					}
				}
				
				if( GlobalConfig.android )
				{
					//_loadingBackground.width = stage.stageWidth;
					//_loadingBackground.height = stage.stageHeight;
					_loadingBackground.scaleX = _loadingBackground.scaleY = 1;
					_loadingBackground.scaleX = _loadingBackground.scaleY = Utilities.getScaleToFill(_loadingBackground.width, _loadingBackground.height, GlobalConfig.stageWidth, GlobalConfig.stageHeight, true);
					_loadingBackground.x = (GlobalConfig.stageWidth - _loadingBackground.width) * 0.5;
					_loadingBackground.y = (GlobalConfig.stageHeight - _loadingBackground.height) * 0.5;
				}
				
				/*if( (AbstractGameInfo.LANDSCAPE && GlobalConfig.android) || (GlobalConfig.ios && AbstractGameInfo.LANDSCAPE && GlobalConfig.isPhone) )
				 {
				 _loadingBackground.width = GlobalConfig.stageHeight;
				 _loadingBackground.height = GlobalConfig.stageWidth;
				 _loadingBackground.rotation = deg2rad(-90);
				 _loadingBackground.x = 0;
				 _loadingBackground.y = GlobalConfig.stageHeight;
				 }*/
				
				addChild( _loadingBackground );
			}
			
			// Progress bar
			_progressBar = new ProgressBar();
			_progressBar.backgroundSkin = new Image(Texture.fromEmbeddedAsset(ProgressBarBackgroundClass, false, false, 1, "bgra", true));
			_progressBar.fillSkin = new Image(Texture.fromEmbeddedAsset(ProgressBarFillClass, false, false, 1, "bgra", true));
			Image(_progressBar.backgroundSkin).scale9Grid = new Rectangle(9, 8, 12, 1);
			Image(_progressBar.fillSkin).scale9Grid = new Rectangle(9, 8, 12, 1);
			_progressBar.width = GlobalConfig.stageWidth * (GlobalConfig.isPhone ? 0.3 : 0.3);
			addChild(_progressBar);
			
			_progressBar.validate();
			_progressBar.x = (GlobalConfig.stageWidth - _progressBar.width) * 0.5;
			_progressBar.y = GlobalConfig.stageHeight * 0.9;
		}
		
		/**
		 * Sets the progress bar value.
		 * 
		 * @param value
		 */
		public function setProgressBarValue(value:Number):void
		{
			_progressBar.value = value;
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
		
		override public function dispose():void
		{
			if(_loadingBackground)
			{
				_loadingBackground.texture.dispose();
				_loadingBackground.removeFromParent(true);
				_loadingBackground = null;
			}
			
			// manually dispose the texture because it does not come from an atlas and we won't use it later
			Image(_progressBar.backgroundSkin).texture.dispose();
			Image(_progressBar.fillSkin).texture.dispose();
			_progressBar.removeFromParent(true);
			_progressBar = null;
			
			super.dispose();
		}
		
	}
}