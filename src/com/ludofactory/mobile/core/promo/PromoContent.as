/**
 * Created by Maxime on 11/09/15.
 */
package com.ludofactory.mobile.core.promo
{
	
	import com.greensock.TweenMax;
	import com.greensock.easing.ElasticOut;
	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.model.ScreenIds;
	import com.ludofactory.mobile.core.notification.NotificationPopupManager;
	import com.ludofactory.mobile.core.notification.content.CreditsNotificationContent;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.extensions.PDParticleSystem;
	import starling.text.TextField;
	import starling.textures.TextureSmoothing;
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
		private var _isSD:Boolean = false;
		
		private var _helpQuad:Quad;
		
		/**
		 * Logo particles. */
		private var _particles:PDParticleSystem;
		
		public function PromoContent(promoData:PromoData, isCompact:Boolean)
		{
			super();
			
			_isCompact = isCompact;
			_isSD = GlobalConfig.isPhone && !_isCompact;
			
			_dropAnimation = new PromoDropAnimation(_isSD, promoData.percent);
			addChild(_dropAnimation);
			
			_timerContainer = new Image(AbstractEntryPoint.assets.getTexture(_isSD ? "promo-timer-container" : "promo-timer-container-hd"));
			_timerContainer.scaleX = _timerContainer.scaleY = GlobalConfig.dpiScale;
			addChild(_timerContainer);
			
			_timer = new TextField((_timerContainer.width - scaleToSize(_isCompact ? 35 : 45)), (_timerContainer.height - scaleToSize(_isCompact ? 5 : 0)), _("--:--"), Theme.FONT_SANSITA, scaleAndRoundToDpi(GlobalConfig.isPhone ? 40 : 50), 0xa1a1a1);
			_timer.autoScale = true;
			//_timer.border = true;
			addChild(_timer);
			
			_titleContainer = new Image(AbstractEntryPoint.assets.getTexture(_isSD ? "promo-title-container" : "promo-title-container-hd"));
			_titleContainer.scaleX = _titleContainer.scaleY = GlobalConfig.dpiScale;
			addChild(_titleContainer);
			
			// 8 = height of the shadow - 12 to adjust because of the design of the title background
			_title = new TextField((_titleContainer.width - scaleToSize(30)), (_titleContainer.height - scaleToSize(8)), promoData.title, Theme.FONT_SANSITA, scaleAndRoundToDpi(GlobalConfig.isPhone ? 36 : 46), 0xffffff);
			_title.autoScale = true;
			//_title.border = true;
			addChild(_title);
			
			_creditIcon = new Image(AbstractEntryPoint.assets.getTexture(_isSD ? "promo-credit-icon" : "promo-credit-icon-hd"));
			_creditIcon.scaleX = _creditIcon.scaleY = GlobalConfig.dpiScale;
			_creditIcon.smoothing = TextureSmoothing.TRILINEAR;
			_creditIcon.alignPivot();
			addChild(_creditIcon);
			
			if(!_isCompact)
			{
				_particles = new PDParticleSystem(Theme.particleStarsXml, Theme.particleStarTexture);
				_particles.touchable = false;
				_particles.maxNumParticles = 100;
				_particles.scaleX = _particles.scaleY = GlobalConfig.dpiScale;
				addChildAt(_particles, this.getChildIndex(_creditIcon));
				Starling.juggler.add(_particles);
				
				_message = new TextField((_titleContainer.width - scaleToSize(16)), (_titleContainer.height * 0.75), promoData.message, Theme.FONT_SANSITA, scaleAndRoundToDpi(GlobalConfig.isPhone ? 20 : 40), 0xe10000);
				_message.isHtmlText = true;
				_message.autoScale = true;
				//_message.border = true;
				_message.vAlign = VAlign.TOP;
				_message.hAlign = HAlign.RIGHT;
				addChild(_message);
			}
			else
			{
				_helpQuad = new Quad((scaleToSize(80) + _titleContainer.width), 50, 0x00ff00);
				_helpQuad.alpha = 0;
				addChildAt(_helpQuad, 0);
				
				if(GlobalConfig.isPhone)
				{
					this.scaleX -= 0.15 * GlobalConfig.dpiScale;
					this.scaleY -= 0.15 * GlobalConfig.dpiScale;
				}
			}
			
			addEventListener(TouchEvent.TOUCH, onTouch);
			
			layout();
		}
		
		private function layout():void
		{
			if(_isCompact)
			{
				_titleContainer.x = scaleToSize(80);
				_title.x = _titleContainer.x + scaleToSize(10);
				
				_timerContainer.y = _titleContainer.height * 0.7;
				_timerContainer.x = _titleContainer.x + (_titleContainer.width - _timerContainer.width) * 0.5;
				
				_timer.x = _timerContainer.x + scaleToSize(35);
				_timer.y = _timerContainer.y + scaleToSize(5);
				
				_creditIcon.x = _timerContainer.x;
				_creditIcon.y = _timerContainer.y + (_timerContainer.height * (_isSD ? 0.75 : 0.8));
				
				_dropAnimation.x = _creditIcon.x - (_creditIcon.width * 0.5);
				_dropAnimation.y = _creditIcon.y;
			}
			else
			{
				_title.x = scaleToSize(10);
				
				_timerContainer.y = _titleContainer.height * 0.6;
				_timerContainer.x = _titleContainer.width + scaleToSize(130);
				
				_timer.x = _timerContainer.x + scaleToSize(40);
				_timer.y = _timerContainer.y + scaleToSize(2);
				
				_creditIcon.x = _timerContainer.x;
				_creditIcon.y = _timerContainer.y + (_timerContainer.height * 0.5);
				
				_dropAnimation.x = _creditIcon.x - (_creditIcon.width * 0.5);
				_dropAnimation.y = _creditIcon.y;
				
				_message.y = _titleContainer.height;
				
				_particles.x = _creditIcon.x;
				_particles.y = _creditIcon.y;
				_particles.emitterXVariance = _creditIcon.width * 0.5;
				_particles.emitterYVariance = _creditIcon.height * 0.5;
			}
		}
		
		/**
		 * Animate everything.
		 */
		public function animate():void
		{
			_creditIcon.scaleX = _creditIcon.scaleY = GlobalConfig.dpiScale + (0.4 * GlobalConfig.dpiScale);
			_creditIcon.alpha = 0;
			
			TweenMax.delayedCall(0.65, _dropAnimation.animate);
			TweenMax.to(_creditIcon, 1, { delay:0.5, scaleX:GlobalConfig.dpiScale, scaleY:GlobalConfig.dpiScale, autoAlpha:1, ease:new ElasticOut(1, 0.6) });
			if(!_isCompact)
			{
				TweenMax.delayedCall(0.75, _particles.start, [0.2]);
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	
		
		public function set timerLabelText(text:String):void
		{
			_timer.text = text;
		}
		
		public function updateLabelColor():void
		{
			_timer.color = 0xe10000;
		}
		
		public function onTimerOver():void
		{
			_timer.text = _("Terminée");
		}
		
		private function scaleToSize(size:Number):int
		{
			if(!_isSD)
				size += (size * 50) / 100;
			return scaleAndRoundToDpi(size);
		}
		
		private function onTouch(event:TouchEvent):void
		{
			var touch:Touch = event.getTouch(this);
			if( touch && touch.phase == TouchPhase.ENDED )
			{
				if(_isCompact) // else it's full size in the credits popup
					NotificationPopupManager.addNotification( new CreditsNotificationContent() );
			}
			touch = null;
		}
		
		public function updateData(promoData:PromoData):void
		{
			_dropAnimation.updateData(promoData.percent);
			_title.text = promoData.title;
			if(_message)
				_message.text = promoData.message;
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
		
		override public function dispose():void
		{
			removeEventListener(TouchEvent.TOUCH, onTouch);
			
			_titleContainer.removeFromParent(true);
			_titleContainer = null;
			
			_title.removeFromParent(true);
			_title = null;
			
			TweenMax.killTweensOf(_creditIcon);
			_creditIcon.removeFromParent(true);
			_creditIcon = null;
			
			_timerContainer.removeFromParent(true);
			_timerContainer = null;
			
			_timer.removeFromParent(true);
			_timer = null;
			
			TweenMax.killDelayedCallsTo(_dropAnimation.animate);
			_dropAnimation.removeFromParent(true);
			_dropAnimation = null;
			
			if(_particles)
			{
				TweenMax.killDelayedCallsTo(_particles.start);
				Starling.juggler.remove( _particles );
				_particles.stop(true);
				_particles.removeFromParent(true);
				_particles = null;
			}
			
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