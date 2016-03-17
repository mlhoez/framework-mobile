/**
 * Created by Maxime on 22/12/14.
 */
package com.ludofactory.mobile.core.avatar.maker
{
	
	import com.greensock.TweenMax;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.avatar.AvatarMakerAssets;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	
	import starling.display.Image;
	import starling.display.Sprite;
	
	public class CoinsAndBasket extends Sprite
	{
		private static var BASKET_TARGET_X:int = 30;
		
		/**
		 * Basket background icon. */
		private var _basketBackgroundIcon:Image;
		/**
		 * Basket foreground icon. */
		private var _basketForegroundIcon:Image;
		/**
		 * Cookie icon. */
		private var _cookieIcon:Image;
		
		public function CoinsAndBasket()
		{
			super();
			
			_cookieIcon = new Image(AvatarMakerAssets.cartPointsIcon);
			_cookieIcon.scaleX = _cookieIcon.scaleY = GlobalConfig.dpiScale;
			addChild(_cookieIcon);
			
			return;

			_basketBackgroundIcon = new Image(AvatarMakerAssets.cartIconBackground);
			_basketBackgroundIcon.visible = false;
			_basketBackgroundIcon.scaleX = _basketBackgroundIcon.scaleY = GlobalConfig.dpiScale;
			addChild(_basketBackgroundIcon);

			_cookieIcon = new Image(AvatarMakerAssets.cartPointsIcon);
			_cookieIcon.scaleX = _cookieIcon.scaleY = GlobalConfig.dpiScale;
			addChild(_cookieIcon);

			_basketForegroundIcon = new Image(AvatarMakerAssets.cartIconForeground);
			_basketForegroundIcon.visible = false;
			_basketForegroundIcon.scaleX = _basketForegroundIcon.scaleY = GlobalConfig.dpiScale;
			addChild(_basketForegroundIcon);
			
			BASKET_TARGET_X = scaleAndRoundToDpi(GlobalConfig.isPhone ? 30 : 50);
			
			this.touchable = false;
		}

		/**
		 * Animates the cookie in the basket.
		 */
		public function animateInBasket(skipAnimation:Boolean = false):void
		{
			return;
			
			TweenMax.killTweensOf(_basketBackgroundIcon);
			TweenMax.killTweensOf(_basketForegroundIcon);
			TweenMax.killTweensOf(_cookieIcon);
			if( skipAnimation )
			{
				// if the commitData is a consequence of a category change, a filter, or a scroll we need to skip
				// the cookie and basket animation
				_basketBackgroundIcon.visible = true;
				_basketForegroundIcon.visible = true;
				_basketBackgroundIcon.alpha = 1;
				_basketForegroundIcon.alpha = 1;
				_basketBackgroundIcon.x = 0;
				_basketForegroundIcon.x = 0;
				_cookieIcon.y = 0;
				_cookieIcon.x = scaleAndRoundToDpi(GlobalConfig.isPhone ? 4 : 24);
			}
			else
			{
				// otherwise, it's the result of a item change within the same category, so we can animate it
				if( _cookieIcon.y != 0 )
				{
					_basketBackgroundIcon.visible = true;
					_basketForegroundIcon.visible = true;
					_basketBackgroundIcon.alpha = 0;
					_basketForegroundIcon.alpha = 0;
					TweenMax.to(_cookieIcon, 0.25, { x:scaleAndRoundToDpi(GlobalConfig.isPhone ? 4 : 24), y:scaleAndRoundToDpi(GlobalConfig.isPhone ? -5 : -25) });
					TweenMax.to(_cookieIcon, 0.25, { delay:0.25, y:0 });
					TweenMax.allTo([_basketBackgroundIcon, _basketForegroundIcon], 0.25, { delay: 0.15, autoAlpha:1, x:0 });
				}
			}
		}

		/**
		 * Animates the cookie out of the basket.
		 */
		public function animateOutBasket(skipAnimation:Boolean = false):void
		{
			return;
			
			TweenMax.killTweensOf(_basketBackgroundIcon);
			TweenMax.killTweensOf(_basketForegroundIcon);
			TweenMax.killTweensOf(_cookieIcon);
			if( skipAnimation )
			{
				_basketBackgroundIcon.visible = false;
				_basketForegroundIcon.visible = false;
				_basketBackgroundIcon.alpha = 0;
				_basketForegroundIcon.alpha = 0;
				_basketBackgroundIcon.x = BASKET_TARGET_X;
				_basketForegroundIcon.x = BASKET_TARGET_X;
				_cookieIcon.y = (scaleAndRoundToDpi(GlobalConfig.isPhone ? 30 : 50) - _cookieIcon.height - scaleAndRoundToDpi(GlobalConfig.isPhone ? 8 : 28));
				_cookieIcon.x = 2;
			}
			else
			{
				if( _cookieIcon.y != (scaleAndRoundToDpi(GlobalConfig.isPhone ? 30 : 50) - _cookieIcon.height - scaleAndRoundToDpi(GlobalConfig.isPhone ? 8 : 28)) )
				{
					TweenMax.to(_cookieIcon, 0.25, { x:scaleAndRoundToDpi(GlobalConfig.isPhone ? 2 : 22), y:scaleAndRoundToDpi(GlobalConfig.isPhone ? -5 : -25) });
					TweenMax.to(_cookieIcon, 0.25, { delay:0.25, y:(scaleAndRoundToDpi(GlobalConfig.isPhone ? 30 : 50) - _cookieIcon.height - scaleAndRoundToDpi(GlobalConfig.isPhone ? 8 : 28)) });
					TweenMax.allTo([_basketBackgroundIcon, _basketForegroundIcon], 0.25, { delay:0.15, autoAlpha:0, x:BASKET_TARGET_X, onComplete:function():void
						{
							_basketBackgroundIcon.visible = _basketForegroundIcon.visible = false;
						} });
				}
			}
		}
		
	}
}