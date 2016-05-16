/**
 * Created by Maxime on 12/05/16.
 */
package com.ludofactory.newClasses
{
	
	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.common.utils.logs.log;
	import com.ludofactory.common.utils.roundUp;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.ButtonFactory;
	import com.ludofactory.mobile.MobileButton;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.AbstractGameInfo;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.events.MobileEventTypes;
	import com.ludofactory.mobile.core.theme.Theme;
	import com.ludofactory.mobile.navigation.ads.AdManager;
	
	import feathers.core.FeathersControl;
	
	import flash.geom.Rectangle;
	
	import starling.display.Image;
	import starling.events.Event;
	import starling.text.TextField;
	import starling.text.TextFormat;
	
	public class PremiumContainer extends FeathersControl
	{
		/**
		 * The background. */
		private var _background:Image;
		
		/**
		 * The title. */
		private var _title:TextField;
		/**
		 * The description. */
		private var _description:TextField;
		
		/**
		 * Watch video button. */
		private var _watchVideoButton:MobileButton;
		/**
		 * Become premium button. */
		private var _becomePremiumButton:MobileButton;
		
		public function PremiumContainer()
		{
			super();
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			_background = new Image(AbstractEntryPoint.assets.getTexture("store-background"));
			_background.scale = GlobalConfig.dpiScale;
			_background.scale9Grid = new Rectangle(20, 55, 20, 30);
			_background.width = scaleAndRoundToDpi(200);
			addChild(_background);
			
			_title = new TextField(5, 5, _("Statistiques"), new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(30), 0xffffff));
			_title.wordWrap = false;
			_title.autoScale = true;
			//_title.border = true;
			addChild(_title);
			
			_description = new TextField(5, 5, _("Améliorez votre jeu en comparant vos performances à celle de vos adversaires."), new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(30), 0x000000));
			_description.autoScale = true;
			//_description.border = true;
			addChild(_description);
			
			_watchVideoButton = ButtonFactory.getButton(_("Afficher gratuitement"), ButtonFactory.BLUE);
			_watchVideoButton.addEventListener(Event.TRIGGERED, onWatchVideo);
			_watchVideoButton.enabled = AdManager.getInstance().isVideoAvailableForZone(AdManager.VIDEO_ZONE_STATS);
			AdManager.getInstance().addEventListener(MobileEventTypes.VIDEO_AVAILABILITY_UPDATE, onVideoAvailabilityUpdate);
			addChild(_watchVideoButton);
			
			_becomePremiumButton = ButtonFactory.getButton(_("Devenir premium"));
			addChild(_becomePremiumButton);
		}
		
		override protected function draw():void
		{
			super.draw();
			
			if(isInvalid(INVALIDATION_FLAG_SIZE))
			{
				_background.width = actualWidth;
				
				_title.width = actualWidth;
				_title.height = scaleAndRoundToDpi(50);
				
				_description.width = actualWidth;
				_description.height = scaleAndRoundToDpi(80);
				_description.y = _title.height + scaleAndRoundToDpi(10);
				
				_watchVideoButton.y = _becomePremiumButton.y = _description.y + _description.height + scaleAndRoundToDpi(10);
				
				_watchVideoButton.width = _becomePremiumButton.width = actualWidth * 0.45;
				_watchVideoButton.x = roundUp((actualWidth - _watchVideoButton.width - _becomePremiumButton.width) * 0.5);
				_becomePremiumButton.x = _watchVideoButton.x + _watchVideoButton.width + scaleAndRoundToDpi(5);
				
				_background.height = _becomePremiumButton.y + _becomePremiumButton.height + scaleAndRoundToDpi(10);
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Handlers
		
		/**
		 * Watch a video.
		 */
		private function onWatchVideo(event:Event):void
		{
			AdManager.getInstance().playVideoForZone(AdManager.VIDEO_ZONE_STATS);
		}
		
		private function onVideoAvailabilityUpdate(event:Event):void
		{
			_watchVideoButton.enabled = AdManager.getInstance().isVideoAvailableForZone(AdManager.VIDEO_ZONE_STATS);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
		
		override public function dispose():void
		{
			AdManager.getInstance().removeEventListener(MobileEventTypes.VIDEO_AVAILABILITY_UPDATE, onVideoAvailabilityUpdate);
			
			_watchVideoButton.removeEventListener(Event.TRIGGERED, onWatchVideo);
			_watchVideoButton.removeFromParent(true);
			_watchVideoButton = null;
			
			super.dispose();
		}
		
	}
}