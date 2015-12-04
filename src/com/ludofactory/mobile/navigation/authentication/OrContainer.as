/**
 * Created by Maxime on 02/12/15.
 */
package com.ludofactory.mobile.navigation.authentication
{
	
	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.common.utils.roundUp;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import feathers.controls.LayoutGroup;
	
	import feathers.core.FeathersControl;
	
	import starling.display.Image;
	
	import starling.display.Quad;
	import starling.text.TextField;
	
	public class OrContainer extends LayoutGroup
	{
		/**
		 * Top stripe. */
		private var _topStripe:Quad;
		/**
		 * Bottom stripe. */
		private var _bottomStripe:Quad;
		/**
		 * Ellipse containing the text. */
		private var _ellipse:Image;
		/**
		 * */
		private var _label:TextField;
		
		public function OrContainer()
		{
			super();
			
			this.touchable = false;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			_topStripe = new Quad(scaleAndRoundToDpi(2), 1, 0x9f9f9f);
			addChild(_topStripe);
			
			_bottomStripe = new Quad(scaleAndRoundToDpi(2), 1, 0x9f9f9f);
			addChild(_bottomStripe);
			
			_ellipse = new Image(AbstractEntryPoint.assets.getTexture("or-ellipse"));
			_ellipse.scaleX = _ellipse.scaleY = GlobalConfig.dpiScale;
			addChild(_ellipse);
			
			_label = new TextField(_ellipse.width, _ellipse.height, _("OU"), Theme.FONT_SANSITA, scaleAndRoundToDpi(25), 0xffffff);
			_label.autoScale = true;
			addChild(_label);
		}
		
		override protected function draw():void
		{
			super.draw();
			
			_ellipse.y = roundUp((actualHeight - _ellipse.height) * 0.5);
			_topStripe.x = _bottomStripe.x = roundUp(_ellipse.width * 0.5);
			_topStripe.height = _ellipse.y - scaleAndRoundToDpi(5);
			_bottomStripe.height = actualHeight - _ellipse.y - _ellipse.height - scaleAndRoundToDpi(5);
			_bottomStripe.y = _ellipse.y + _ellipse.height + scaleAndRoundToDpi(5);
			_label.x = _ellipse.x;
			_label.y = _ellipse.y;
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
		
		override public function dispose():void
		{
			_topStripe.removeFromParent(true);
			_topStripe = null;
			
			_bottomStripe.removeFromParent(true);
			_bottomStripe = null;
			
			_ellipse.removeFromParent(true);
			_ellipse = null;
			
			_label.removeFromParent(true);
			_label = null;
			
			super.dispose();
		}
		
	}
}