/**
 * Created by Maxime on 11/09/15.
 */
package com.ludofactory.mobile.core.promo
{
	
	import com.greensock.TweenMax;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.text.TextField;
	import starling.utils.deg2rad;
	
	/**
	 * Drop animtion used for both the PromoContent and CompactPromoContent.
	 */
	public class PromoDropAnimation extends Sprite
	{
		/**
		 * The main drop containing the promo percentage. */
		private var _mainDrop:Image;
		/**
		 * Top drop animated. */
		private var _topDrop:Image;
		/**
		 * Bottom left drop animated. */
		private var _bottomLeftDrop:Image;
		/**
		 * Bottom right drop animated. */
		private var _bottomRightDrop:Image;
		/**
		 * Percentage textfield. */
		private var _percent:TextField;
		
		public function PromoDropAnimation(percentText:String)
		{
			super();
			
			_mainDrop = new Image(AbstractEntryPoint.assets.getTexture("promo-main-drop"));
			
			_mainDrop.alignPivot();
			addChild(_mainDrop);
			
			_topDrop = new Image(AbstractEntryPoint.assets.getTexture("promo-top-drop"));
			_topDrop.scaleX = _topDrop.scaleY = 0;
			_topDrop.alignPivot();
			addChild(_topDrop);
			
			_bottomLeftDrop = new Image(AbstractEntryPoint.assets.getTexture("promo-bottom-left-drop"));
			_bottomLeftDrop.scaleX = _bottomLeftDrop.scaleY = 0;
			_bottomLeftDrop.alignPivot();
			addChild(_bottomLeftDrop);
			
			_bottomRightDrop = new Image(AbstractEntryPoint.assets.getTexture("promo-bottom-right-drop"));
			_bottomRightDrop.scaleX = _bottomRightDrop.scaleY = 0;
			_bottomRightDrop.alignPivot();
			addChild(_bottomRightDrop);
			
			percentText = percentText.replace(/#size#/g, scaleAndRoundToDpi(15).toString());
			
			_percent = new TextField(_mainDrop.width, _mainDrop.height, percentText, Theme.FONT_SANSITA, scaleAndRoundToDpi(30), 0xe10000);
			_percent.isHtmlText = true;
			_percent.autoScale = true;
			_percent.rotation = deg2rad(18);
			_percent.alignPivot();
			_percent.scaleX = _percent.scaleY = 0;
			addChild(_percent);
			
			_mainDrop.scaleX = _mainDrop.scaleY = 0;
			
			layout();
		}
		
		private function layout():void
		{
			_topDrop.x = scaleAndRoundToDpi(15);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Handlers
		
		/**
		 * Animates the drops.
		 */
		public function animate():void
		{
			TweenMax.allTo([_mainDrop, _percent], 0.25, { x:scaleAndRoundToDpi(-44), y:scaleAndRoundToDpi(-28), scaleX:GlobalConfig.dpiScale, scaleY:GlobalConfig.dpiScale });
			TweenMax.to(_topDrop, 0.25, { delay:0.1, x:scaleAndRoundToDpi(-12), y:scaleAndRoundToDpi(-48), scaleX:GlobalConfig.dpiScale, scaleY:GlobalConfig.dpiScale });
			TweenMax.to(_bottomRightDrop, 0.25, { delay:0.15, x:scaleAndRoundToDpi(-16), y:scaleAndRoundToDpi(12), scaleX:GlobalConfig.dpiScale, scaleY:GlobalConfig.dpiScale });
			TweenMax.to(_bottomLeftDrop, 0.25, { delay:0.2, x:scaleAndRoundToDpi(-40), y:scaleAndRoundToDpi(12), scaleX:GlobalConfig.dpiScale, scaleY:GlobalConfig.dpiScale });
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
		
		override public function dispose():void
		{
			TweenMax.killTweensOf(_mainDrop);
			_mainDrop.removeFromParent(true);
			_mainDrop = null;
			
			TweenMax.killTweensOf(_percent);
			_percent.removeFromParent(true);
			_percent = null;
			
			TweenMax.killTweensOf(_topDrop);
			_topDrop.removeFromParent(true);
			_topDrop = null;
			
			TweenMax.killTweensOf(_bottomLeftDrop);
			_bottomLeftDrop.removeFromParent(true);
			_bottomLeftDrop = null;
			
			TweenMax.killTweensOf(_bottomRightDrop);
			_bottomRightDrop.removeFromParent(true);
			_bottomRightDrop = null;
			
			super.dispose();
		}
		
	}
}