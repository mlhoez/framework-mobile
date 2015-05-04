/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 7 oct. 2013
*/
package com.ludofactory.mobile.navigation
{
	
	import com.greensock.TweenMax;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.controls.*;
	import com.ludofactory.mobile.core.events.LudoEventType;
	import com.ludofactory.mobile.core.manager.MemberManager;
	import com.ludofactory.mobile.core.storage.Storage;
	import com.ludofactory.mobile.core.storage.StorageConfig;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import flash.filters.DropShadowFilter;
	
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.text.TextField;
	
	/**
	 * Application header.
	 */	
	public class Header extends Sprite
	{
		/**
		 * The AlertButton position when visible. */		
		private var _alertButtonPosition:int;
		
		/**
		 * The background. */		
		private var _background:Image;
		/**
		 * The title. */		
		private var _title:TextField;
		
		/**
		 * Alert button. */		
		private var _alertButton:BadgedButton;
		/**
		 * Alert icon. */		
		private var _alertIcon:Image;
		
		/**
		 * Whether the alert button is displaying (no by default). */		
		private var _isAlertDisplaying:Boolean = false;
		
		/**
		 * Whether the title is displaying (no by default). */		
		private var _isTitleDisplaying:Boolean = false;
		
		public function Header()
		{
			super();
			addEventListener(Event.ADDED_TO_STAGE, initialize);
		}
		
		/**
		 * Initializes the component.
		 */		
		private function initialize(event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, initialize);
			
			// hidden by default
			this.visible = false;
			
			_background = new Image( AbstractEntryPoint.assets.getTexture("header-background-skin") );
			_background.scaleX = _background.scaleY = GlobalConfig.dpiScale;
			_background.touchable = false;
			_background.visible = false;
			_background.alpha = 0;
			addChild(_background);
			
			_title = new TextField(GlobalConfig.stageWidth, _background.height, "_", Theme.FONT_SANSITA, scaleAndRoundToDpi(30), Theme.COLOR_WHITE);
			_title.nativeFilters = [ new DropShadowFilter(0, 75, 0x000000, 0.75, 10, 10) ];
			_title.touchable = false;
			_title.autoScale = true;
			_title.text = "_";
			addChild(_title);
			
			_alertIcon = new Image( AbstractEntryPoint.assets.getTexture("header-alert-icon") );
			_alertIcon.scaleX = _alertIcon.scaleY = GlobalConfig.dpiScale;
			
			_alertButton = new BadgedButton();
			_alertButton.defaultIcon = _alertIcon;
			_alertButton.visible = false;
			_alertButton.alpha = 0;
			_alertButton.addEventListener(Event.TRIGGERED, onAlertButtonTouched);
			addChild(_alertButton);
			
			draw();
		}
		
		private function draw():void
		{
			_background.width = _title.width = GlobalConfig.stageWidth;
			
			_title.y = ((_background.height - _title.height) * 0.5) << 0;
			_title.text = "";
			
			// off screen by default
			_alertButton.validate();
			_alertButton.x = GlobalConfig.stageWidth;
			_alertButtonPosition = (GlobalConfig.stageWidth - _alertButton.width + scaleAndRoundToDpi(3)) << 0;
		}
		
//------------------------------------------------------------------------------------------------------------
//	Utilities
		
		/**
		 * Shows the title.
		 */		
		public function showTitle(val:String):void
		{
			_title.text = val;
			if( !_isAlertDisplaying && !_isTitleDisplaying )
			{
				_background.visible = this.visible = true;
				_background.alpha = 1;
			}
			_isTitleDisplaying = true;
		}
		
		/**
		 * Hides the title.
		 */		
		public function hideTitle():void
		{
			_title.text = "";
			if( !_isAlertDisplaying && _isTitleDisplaying )
			{
				_background.visible = this.visible = false;
				_background.alpha = 0;
			}
			_isTitleDisplaying = false;
		}
		
		/**
		 * Shows the alert button.
		 */		
		public function showAlertButton(count:int):void
		{
			updateAlertIcon();
			_alertButton.badgeCount = count;
			
			if( !_isAlertDisplaying )
			{
				_isAlertDisplaying = true;
				
				if( !_isTitleDisplaying )
				{
					// title was not displaying then we can tween the header's background
					this.visible = true;
					TweenMax.to(_background, 0.5, { autoAlpha:1 });
				}
				TweenMax.to(_alertButton, 0.5, { x:_alertButtonPosition, autoAlpha:1 });
			}
		}
		
		/**
		 * Hides the alert button.
		 */		
		public function hideAlertButton():void
		{
			if( _isAlertDisplaying )
			{
				_isAlertDisplaying = false;
				_alertButton.badgeCount = 0;
				if( !_isTitleDisplaying )
				{
					// title was not displaying then we can fade out the header's background
					TweenMax.to(_background, 0.5, { autoAlpha:0, onComplete:hideHeader });
				}
				TweenMax.to(_alertButton, 0.5, { x:GlobalConfig.stageWidth, autoAlpha:0 });
			}
		}
		
		private function hideHeader():void
		{
			this.visible = false;
		}
		
		/**
		 * Updates the alert icon, depending
		 */		
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
			
			if( (Storage.getInstance().getProperty(StorageConfig.PROPERTY_NEW_LANGUAGES) as Array).length > 0 )
			{
				numChanges++;
				sourceName = "header-language-icon";
			}
			
			if( numChanges > 1 )
				sourceName = "header-alert-icon";
			
			if( sourceName )
				_alertIcon.texture = AbstractEntryPoint.assets.getTexture(sourceName);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Handlers
		
		/**
		 * The alert button was touched, let's open the drawer.
		 */		
		private function onAlertButtonTouched(event:Event):void
		{
			dispatchEventWith(LudoEventType.OPEN_ALERTS_FROM_HEADER);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Get / Set
		
		/**
		 * Whether the header is displaying.
		 */		
		public function get isDisplaying():Boolean { return (_isTitleDisplaying || _isAlertDisplaying); }
		
		/**
		 * When the visibility have changed, we can resize the screen navigator accordingly
		 * to fit the entire available space.
		 */		
		override public function set visible(value:Boolean):void
		{
			super.visible = value;
			dispatchEventWith(LudoEventType.HEADER_VISIBILITY_CHANGED);
		}
		
	}
}