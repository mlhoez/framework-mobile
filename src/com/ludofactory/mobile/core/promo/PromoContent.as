/**
 * Created by Maxime on 11/09/15.
 */
package com.ludofactory.mobile.core.promo
{
	
	import com.greensock.TweenMax;
	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.text.TextField;
	import starling.utils.HAlign;
	import starling.utils.VAlign;
	
	/**
	 * Used in the stake selection screen.
	 */
	public class PromoContent extends Sprite
	{
		/**
		 * Title container. */
		private var _titleContainer:Image;
		/**
		 * The title. */
		private var _title:TextField;
		
		/**
		 * The credit icon. */
		private var _creditIcon:Image;
		
		/**
		 * Timer container. */
		private var _timerContainer:Image;
		/**
		 * The timer. */
		private var _timer:TextField;
		
		/**
		 * Drop animation. */
		private var _dropAnimation:PromoDropAnimation;
		
		/**
		 * Message displayed in non-compact mode. */
		private var _message:TextField;
		
		/**
		 * Which style of promo we want. */
		private var _isCompact:Boolean;
		
		private var _helpQuad:Quad;
		
		public function PromoContent(promoData:PromoData, isCompact:Boolean)
		{
			super();
			
			_isCompact = isCompact;
			
			_dropAnimation = new PromoDropAnimation(promoData.percent);
			addChild(_dropAnimation);
			
			_timerContainer = new Image(AbstractEntryPoint.assets.getTexture("promo-timer-container"));
			_timerContainer.scaleX = _timerContainer.scaleY = GlobalConfig.dpiScale;
			addChild(_timerContainer);
			
			_timer = new TextField((_timerContainer.width - scaleAndRoundToDpi(20)), (_timerContainer.height - scaleAndRoundToDpi(5)), _("--:--"), Theme.FONT_SANSITA, scaleAndRoundToDpi(40), 0xa1a1a1);
			_timer.autoScale = true;
			//_timer.border = true;
			addChild(_timer);
			
			_titleContainer = new Image(AbstractEntryPoint.assets.getTexture("promo-title-container"));
			_titleContainer.scaleX = _titleContainer.scaleY = GlobalConfig.dpiScale;
			addChild(_titleContainer);
			
			// 8 = height of the shadow - 12 to adjust because of the design of the title background
			_title = new TextField((_titleContainer.width - scaleAndRoundToDpi(20)), (_titleContainer.height - scaleAndRoundToDpi(8)), promoData.title, Theme.FONT_SANSITA, scaleAndRoundToDpi(36), 0xffffff);
			_title.autoScale = true;
			//_title.border = true;
			addChild(_title);
			
			_creditIcon = new Image(AbstractEntryPoint.assets.getTexture("promo-credit-icon"));
			_creditIcon.scaleX = _creditIcon.scaleY = GlobalConfig.dpiScale;
			_creditIcon.alignPivot();
			addChild(_creditIcon);
			
			if(!_isCompact)
			{
				_message = new TextField((_titleContainer.width - scaleAndRoundToDpi(16)), (_titleContainer.height * 0.75), promoData.message, Theme.FONT_SANSITA, scaleAndRoundToDpi(20), 0xe10000);
				_message.isHtmlText = true;
				_message.autoScale = true;
				//_message.border = true;
				_message.vAlign = VAlign.TOP;
				_message.hAlign = HAlign.RIGHT;
				addChild(_message);
			}
			else
			{
				_helpQuad = new Quad((scaleAndRoundToDpi(80) + _titleContainer.width), 50, 0x00ff00);
				_helpQuad.alpha = 0;
				addChildAt(_helpQuad, 0);
			}
			
			layout();
			animate();
		}
		
		private function layout():void
		{
			_title.x = scaleAndRoundToDpi(8);
			
			if(_isCompact)
			{
				_titleContainer.x = _title.x = scaleAndRoundToDpi(80);
				
				_timerContainer.y = _titleContainer.height * 0.7;
				_timerContainer.x = _titleContainer.x + (_titleContainer.width - _timerContainer.width) * 0.5;
				
				_timer.x = _timerContainer.x + scaleAndRoundToDpi(20);
				_timer.y = _timerContainer.y + scaleAndRoundToDpi(5);
				
				_creditIcon.x = _timerContainer.x;
				_creditIcon.y = _timerContainer.y + (_timerContainer.height * 0.75);
				
				_dropAnimation.x = _creditIcon.x - (_creditIcon.width * 0.5);
				_dropAnimation.y = _creditIcon.y;
				
			}
			else
			{
				_timerContainer.y = _titleContainer.height * 0.6;
				_timerContainer.x = _titleContainer.width + scaleAndRoundToDpi(130);
				
				_timer.x = _timerContainer.x + scaleAndRoundToDpi(20);
				_timer.y = _timerContainer.y + scaleAndRoundToDpi(5);
				
				_creditIcon.x = _timerContainer.x;
				_creditIcon.y = _timerContainer.y + (_timerContainer.height * 0.5);
				
				_dropAnimation.x = _creditIcon.x - (_creditIcon.width * 0.5);
				_dropAnimation.y = _creditIcon.y;
				
				_message.y = _titleContainer.height;
			}
		}
		
		/**
		 * Animate everything.
		 */
		private function animate():void
		{
			TweenMax.delayedCall(0.5, _dropAnimation.animate);
		}
		
//------------------------------------------------------------------------------------------------------------
//	
		
		public function set timerLabelText(text:String):void
		{
			_timer.text = text;
		}
		
		public function onTimerOver():void
		{
			_timer.text = _("--:--");
			_title.text = _("Promotion terminée");
			if(_message)
				_message.text = _("Cette promotion est terminée.");
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
		
		override public function dispose():void
		{
			TweenMax.killDelayedCallsTo(_dropAnimation.animate);
			
			_titleContainer.removeFromParent(true);
			_titleContainer = null;
			
			_title.removeFromParent(true);
			_title = null;
			
			_creditIcon.removeFromParent(true);
			_creditIcon = null;
			
			_timerContainer.removeFromParent(true);
			_timerContainer = null;
			
			_timer.removeFromParent(true);
			_timer = null;
			
			_dropAnimation.removeFromParent(true);
			_dropAnimation = null;
			
			if(_message)
			{
				_message.removeFromParent(true);
				_message = null;
			}
			
			if(_helpQuad)
			{
				_helpQuad.removeFromParent(true);
				_helpQuad = null;
			}
			
			super.dispose();
		}
		
	}
}