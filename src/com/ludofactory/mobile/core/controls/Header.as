/*
LudoFactory
Framework mobile
Author  : Maxime Lhoez
Created : 7 oct. 2013
*/
package com.ludofactory.mobile.core.controls
{
	import com.greensock.TweenMax;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.authentication.MemberManager;
	import com.ludofactory.mobile.core.events.LudoEventType;
	import com.ludofactory.mobile.core.test.config.GlobalConfig;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import flash.filters.DropShadowFilter;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import feathers.controls.ImageLoader;
	import feathers.controls.Label;
	import feathers.core.FeathersControl;
	import feathers.display.Scale3Image;
	import feathers.textures.Scale3Textures;
	
	import starling.events.Event;
	
	public class Header extends FeathersControl
	{
		/**
		 * Invalidation flag to indicate that the dimensions of the UI control
		 * have changed.
		 */
		public static const INVALIDATION_FLAG_TITLE:String = "title";
		public static const INVALIDATION_FLAG_FIRST_INIT:String = "firstInit";
		
		/**
		 * The background. */		
		private var _background:Scale3Image;
		
		/**
		 * The title. */		
		private var _title:Label;
		
		/**
		 * Alert button. */		
		private var _alertButton:BadgedButton;
		
		/**
		 * Alert icon. */		
		private var _alertIcon:ImageLoader;
		
		private var _isAlertDisplaying:Boolean = false;
		
		public function Header()
		{
			super();
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			this.height = scaleAndRoundToDpi(60);
			
			// FIXME Mettre le header en visible = false lorsqu'il n'est pas affiché
			
			_background = new Scale3Image( new Scale3Textures(AbstractEntryPoint.assets.getTexture("header-background-skin"), 20, 20), GlobalConfig.dpiScale );
			addChild(_background);
			
			_title = new Label();
			_title.text = "";
			addChild(_title);
			_title.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(30), Theme.COLOR_WHITE, false, false, null, null, null, TextFormatAlign.CENTER);
			_title.textRendererProperties.nativeFilters = [ new DropShadowFilter(0, 75, 0x000000, 0.75, 10, 10) ];
			
			_alertIcon = new ImageLoader();
			_alertIcon.source = AbstractEntryPoint.assets.getTexture("header-alert-icon");
			_alertIcon.snapToPixels = true;
			_alertIcon.scaleX = _alertIcon.scaleY = GlobalConfig.dpiScale;
			
			_alertButton = new BadgedButton();
			_alertButton.defaultIcon = _alertIcon;
			_alertButton.alpha = 0;
			_alertButton.visible = false;
			_alertButton.addEventListener(Event.TRIGGERED, onAlertButtonTouched);
			addChild(_alertButton);
		}
		
		override protected function draw():void
		{
			super.draw();
			
			_background.width = _title.width = this.actualWidth;
			_background.height = this.actualHeight;
			
			if( isInvalid( INVALIDATION_FLAG_FIRST_INIT ) )
			{
				_alertButton.validate();
				_alertButton.x = this.actualWidth;
			}
			
			if( isInvalid( INVALIDATION_FLAG_TITLE ) )
			{
				_title.validate();
				_title.y = (this.actualHeight - _title.height) * 0.5;
				TweenMax.to(_background, 0.5, { autoAlpha:((_title.text == "" && !_isAlertDisplaying) ? 0 : 1) });
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Utils
//------------------------------------------------------------------------------------------------------------
		
		/**
		 * Updates the header title.
		 */		
		public function setTitle(val:String):void
		{
			_title.text = val;
			invalidate( INVALIDATION_FLAG_TITLE );
		}
		
		/**
		 * Shows the alert button.
		 */		
		public function showAlertButton(count:int):void
		{
			updateAlertIcon();
			_isAlertDisplaying = true;
			TweenMax.to(_background, 0.5, { autoAlpha:((_title.text == "" && !_isAlertDisplaying) ? 0 : 1) });
			_alertButton.badgeCount = count;
			TweenMax.to(_alertButton, 0.5, { x:(this.actualWidth - _alertButton.width + scaleAndRoundToDpi(3)), autoAlpha:1 });
		}
		
		/**
		 * Hides the alert button.
		 */		
		public function hideAlertButton():void
		{
			_isAlertDisplaying = false;
			TweenMax.to(_background, 0.5, { autoAlpha:((_title.text == "" && !_isAlertDisplaying) ? 0 : 1) });
			_alertButton.badgeCount = 0;
			TweenMax.to(_alertButton, 0.5, { x:this.actualWidth, autoAlpha:0 });
		}
		
		/**
		 * The alert button was touched, let's open the drawer.
		 */		
		private function onAlertButtonTouched(event:Event):void
		{
			dispatchEventWith(LudoEventType.OPEN_ALERTS);
		}
		
		private function updateAlertIcon():void
		{
			var numChanges:int = 0;
			var sourceName:String;
			
			if( AbstractEntryPoint.alertData.numCustomerServiceImportantAlerts > 0 )
			{
				numChanges++;
				sourceName = "header-cs-icon";
			}
			
			if( AbstractEntryPoint.alertData.numGainAlerts )
			{
				numChanges++;
				sourceName = "header-gifts-icon";
			}
			
			if( AbstractEntryPoint.alertData.numSponsorAlerts )
			{
				numChanges++;
				sourceName = "header-sponsoring-icon";
			}
			
			if( AbstractEntryPoint.alertData.numTrophiesAlerts )
			{
				numChanges++;
				sourceName = "header-trophy-icon";
			}
			
			if( AbstractEntryPoint.pushManager.numGameSessionsToPush > 0 )
			{
				numChanges++;
				sourceName = "header-game-session-icon";
			}
			
			if( AbstractEntryPoint.pushManager.numCSMessagesToPush > 0 )
			{
				numChanges++;
				sourceName = "header-cs-icon";
			}
			
			if( AbstractEntryPoint.pushManager.numTrophiesToPush > 0 )
			{
				numChanges++;
				sourceName = "header-trophy-icon";
			}
			
			if( !MemberManager.getInstance().isLoggedIn() && MemberManager.getInstance().getNumStarsEarnedInAnonymousGameSessions() > 0 )
			{
				numChanges++;
				sourceName = "header-game-session-icon";
			}
			
			if( !MemberManager.getInstance().isLoggedIn() && MemberManager.getInstance().getNumTrophiesEarnedInAnonymousGameSessions() > 0 )
			{
				numChanges++;
				sourceName = "header-trophy-icon";
			}
			
			if( numChanges > 1 )
				sourceName = "header-alert-icon";
			
			_alertIcon.source = AbstractEntryPoint.assets.getTexture(sourceName);
		}
		
	}
}