/**
 * Created by Maxime on 22/04/2016.
 */
package com.ludofactory.newClasses
{
	
	import com.ludofactory.mobile.core.config.GlobalConfig;
	
	import feathers.controls.ImageLoader;
	
	import flash.geom.Rectangle;
	
	import starling.display.Image;
	import starling.textures.Texture;
	
	/**
	 * Custom touchable container used to display a background and an icon very simply.
	 */
	public class IconButton extends TouchableContainer
	{
		/**
		 * Button background. */
		private var _background:Image;
		/**
		 * Button icon. */
		private var _icon:ImageLoader;
		
		/**
		 * Creates a button with a background and an icon
		 * 
		 * @param backgroundTexture The background texture
		 * @param backgroundTextureGrid A rectangle is using a scale9 texture.
		 * @param iconSource Can be an URL or a Starling Texture
		 */
		public function IconButton(backgroundTexture:Texture, backgroundTextureGrid:Rectangle = null, iconSource:Object = null)
		{
			super();
			
			_background = new Image(backgroundTexture);
			_background.scale = GlobalConfig.dpiScale;
			addChild(_background);
			
			if(iconSource)
			{
				_icon = new ImageLoader();
				_icon.maintainAspectRatio = true;
				_icon.source = iconSource;
				_icon.scale = GlobalConfig.dpiScale; // FIXME Sure ?
				addChild(_icon);
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Get - Set
		
		public function set iconSource(value:Object):void
		{
			if(value)
			{
				_icon = new ImageLoader();
				_icon.maintainAspectRatio = true;
				_icon.source = value;
				_icon.scale = GlobalConfig.dpiScale; // FIXME Sure ?
				addChild(_icon);
			}
			else
			{
				if(_icon)
				{
					_icon.removeFromParent(true);
					_icon = null;
				}
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
		
		override public function dispose():void
		{
			_background.removeFromParent(true);
			_background = null;
			
			if(_icon)
			{
				_icon.removeFromParent(true);
				_icon = null;
			}
			
			super.dispose();
		}
	}
}