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
	import starling.text.TextFormat;
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
		
		private var _isSD:Boolean = false;
		
		public function PromoDropAnimation(isSd:Boolean, percentText:String)
		{
			super();
			
			_isSD = isSd;
			
			_mainDrop = new Image(AbstractEntryPoint.assets.getTexture(_isSD ? "promo-main-drop" : "promo-main-drop-hd"));
			
			_mainDrop.alignPivot();
			addChild(_mainDrop);
			
			_topDrop = new Image(AbstractEntryPoint.assets.getTexture(_isSD ? "promo-top-drop" : "promo-top-drop-hd"));
			_topDrop.scaleX = _topDrop.scaleY = 0;
			_topDrop.alignPivot();
			addChild(_topDrop);
			
			_bottomLeftDrop = new Image(AbstractEntryPoint.assets.getTexture(_isSD ? "promo-bottom-left-drop" : "promo-bottom-left-drop-hd"));
			_bottomLeftDrop.scaleX = _bottomLeftDrop.scaleY = 0;
			_bottomLeftDrop.alignPivot();
			addChild(_bottomLeftDrop);
			
			_bottomRightDrop = new Image(AbstractEntryPoint.assets.getTexture(_isSD ? "promo-bottom-right-drop" : "promo-bottom-right-drop-hd"));
			_bottomRightDrop.scaleX = _bottomRightDrop.scaleY = 0;
			_bottomRightDrop.alignPivot();
			addChild(_bottomRightDrop);
			
			percentText = percentText.replace(/#size#/g, scaleToSize(GlobalConfig.isPhone ? 15 : 25).toString());
			
			_percent = new TextField((_mainDrop.width - scaleToSize(10)), (_mainDrop.height - scaleToSize(10)), percentText, new TextFormat(Theme.FONT_SANSITA, scaleToSize(GlobalConfig.isPhone ? 30 : 50), 0xe10000));
			_percent.isHtmlText = true;
			_percent.autoScale = true;
			//_percent.border = true;
			_percent.rotation = deg2rad(18);
			_percent.alignPivot();
			_percent.scaleX = _percent.scaleY = 0;
			addChild(_percent);
			
			_mainDrop.scaleX = _mainDrop.scaleY = 0;
			
			layout();
		}
		
		private function layout():void
		{
			_topDrop.x = scaleToSize(15);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Handlers
		
		/**
		 * Animates the drops.
		 */
		public function animate():void
		{
			TweenMax.to(_mainDrop, 0.25, { x:scaleToSize(-44), y:scaleToSize(-28), scaleX:GlobalConfig.dpiScale, scaleY:GlobalConfig.dpiScale });
			TweenMax.to(_percent, 0.25, { x:scaleToSize(-46), y:scaleToSize(-28), scaleX:GlobalConfig.dpiScale, scaleY:GlobalConfig.dpiScale });
			TweenMax.to(_topDrop, 0.25, { delay:0.1, x:scaleToSize(-12), y:scaleToSize(-48), scaleX:GlobalConfig.dpiScale, scaleY:GlobalConfig.dpiScale });
			TweenMax.to(_bottomRightDrop, 0.25, { delay:0.15, x:scaleToSize(-16), y:scaleToSize(12), scaleX:GlobalConfig.dpiScale, scaleY:GlobalConfig.dpiScale });
			TweenMax.to(_bottomLeftDrop, 0.25, { delay:0.2, x:scaleToSize(-40), y:scaleToSize(12), scaleX:GlobalConfig.dpiScale, scaleY:GlobalConfig.dpiScale });
		}
		
		private function scaleToSize(size:Number):int
		{
			if(!_isSD)
				size += (size * 50) / 100;
			return scaleAndRoundToDpi(size);
		}
		
		public function updateData(percentText:String):void
		{
			percentText = percentText.replace(/#size#/g, scaleToSize(15).toString());
			_percent.text = percentText;
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