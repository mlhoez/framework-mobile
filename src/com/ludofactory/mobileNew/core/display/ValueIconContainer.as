/**
 * Created by Maxime on 25/04/2016.
 */
package com.ludofactory.mobileNew.core.display
{
	
	import com.ludofactory.mobileNew.*;
	
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import flash.geom.Rectangle;
	
	import starling.display.Image;
	import starling.text.TextField;
	import starling.text.TextFormat;
	import starling.textures.Texture;
	import starling.utils.Align;
	
	public class ValueIconContainer extends TouchableContainer
	{
		private static const MAX_WIDTH:int = 200;
		
		/**
		 * The icon. */
		private var _icon:Image;
		/**
		 * The background. */
		private var _background:Image;
		/**
		 * The value to display. */
		private var _valueLabel:TextField;
		
		public function ValueIconContainer(iconTexture:Texture, backgroundTexture:Texture, value:String = "")
		{
			super();
			
			_background = new Image(backgroundTexture);
			_background.scale9Grid = new Rectangle(41, 0, 9, _background.texture.frameHeight);
			_background.scale = GlobalConfig.dpiScale;
			addChild(_background);
			
			_icon = new Image(iconTexture);
			_icon.scale = GlobalConfig.dpiScale;
			addChild(_icon);
			
			_valueLabel = new TextField(5, _background.height, value, new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(30), 0xffffff));
			_valueLabel.x = _icon.width;
			_valueLabel.width = this.width - _valueLabel.x;
			_valueLabel.border = true;
			_valueLabel.wordWrap = false;
			_valueLabel.autoScale = true;
			addChild(_valueLabel);
		}
		
		override public function set width(value:Number):void
		{
			value = value > scaleAndRoundToDpi(MAX_WIDTH) ? scaleAndRoundToDpi(MAX_WIDTH) : value;
			_background.width = value;
			_valueLabel.width = this.width - _valueLabel.x;
			super.width = value;
		}
		
		override public function set height(value:Number):void
		{
			_background.height = value;
			super.height = value;
		}
		
		override public function dispose():void
		{
			
			
			super.dispose();
		}
	}
}