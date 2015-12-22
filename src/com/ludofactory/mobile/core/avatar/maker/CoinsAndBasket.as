/**
 * Created by Maxime on 22/12/14.
 */
package com.ludofactory.mobile.core.avatar.maker
{

	import com.greensock.TweenMax;
	import com.ludofactory.server.starling.theme.Theme;

	import starling.display.Image;
	import starling.display.Sprite;

	public class CoinsAndBasket extends Sprite
	{
		private static const BASKET_TARGET_X:int = 30;
		
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

			_basketBackgroundIcon = new Image(Theme.basketBackgroundIconTexture);
			_basketBackgroundIcon.visible = false;
			addChild(_basketBackgroundIcon);

			_cookieIcon = new Image(Theme.pointsSmallIconTexture);
			addChild(_cookieIcon);

			_basketForegroundIcon = new Image(Theme.basketForegroundIconTexture);
			_basketForegroundIcon.visible = false;
			addChild(_basketForegroundIcon);
			
			this.touchable = false;
			
		}

		/**
		 * Animates the cookie in the basket.
		 */
		public function animateInBasket(skipAnimation:Boolean = false):void
		{
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
				_cookieIcon.x = 4;
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
					TweenMax.to(_cookieIcon, 0.25, { x:4, y:-5 });
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
				_cookieIcon.y = (30 - _cookieIcon.height - 8);
				_cookieIcon.x = 2;
			}
			else
			{
				if( _cookieIcon.y != (30 - _cookieIcon.height - 8) )
				{
					TweenMax.to(_cookieIcon, 0.25, { x:2, y:-5 });
					TweenMax.to(_cookieIcon, 0.25, { delay:0.25, y:(30 - _cookieIcon.height - 8) });
					TweenMax.allTo([_basketBackgroundIcon, _basketForegroundIcon], 0.25, { delay:0.15, autoAlpha:0, x:BASKET_TARGET_X, onComplete:function():void
						{
							_basketBackgroundIcon.visible = _basketForegroundIcon.visible = false;
						} });
				}
			}
		}
		
	}
}