/**
 * Created by Maxime on 27/04/16.
 */
package com.ludofactory.mobileNew
{
	
	import com.ludofactory.common.utils.Utilities;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.text.TextField;
	import starling.text.TextFormat;
	import starling.utils.deg2rad;
	
	public class GameJaugeScoreLabel extends Sprite
	{
		/**
		 * The background. */
		private var _background:Image;
		/**
		 * The value to display above the background. */
		private var _value:TextField;
		
		public function GameJaugeScoreLabel()
		{
			super();
			
			_background = new Image(AbstractEntryPoint.assets.getTexture("update-score-container"));
			_background.scale = GlobalConfig.dpiScale;
			addChild(_background);
			
			_value = new TextField(_background.width - scaleAndRoundToDpi(5), _background.height - scaleAndRoundToDpi(10), "+999", new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(30), 0xfff000));
			//_value.border = true;
			_value.autoScale = true;
			_value.rotation = deg2rad(-5);
			_value.y = scaleAndRoundToDpi(5);
			addChild(_value);
		}
		
//------------------------------------------------------------------------------------------------------------
//	
		
		/**
		 * Updates the value dislayed.
		 * 
		 * @param value
		 */
		public function updateValue(value:int):void
		{
			_value.text = (value >= 0 ? "+" :"") + Utilities.splitThousands(value);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
		
		override public function dispose():void
		{
			_background.removeFromParent(true);
			_background = null;
			
			_value.removeFromParent(true);
			_value = null;
			
			super.dispose();
		}
		
	}
}