/**
 * Created by Maxime on 22/04/2016.
 */
package com.ludofactory.newClasses
{
	
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.controls.AdvancedScreen;
	import com.ludofactory.mobile.core.notification.CustomPopupManager;
	import com.ludofactory.mobile.core.notification.content.neww.TrophiesPopupContent;
	
	import starling.display.Image;
	import starling.events.Event;
	import starling.events.Event;
	
	/**
	 * Home screen.
	 */
	public class HomeScreen extends AdvancedScreen
	{
		/**
		 * Background. */
		private var _background:Image;
		
		/**
		 * Header container, will hold the high score and number of trophies in duel mode. */
		private var _headerContainer:HeaderContainer;
		
		/**
		 * Trophies button. */
		private var _trophiesButton:IconButton;
		/**
		 * Trophies ranking button. */
		private var _trophiesRankingButton:IconButton;
		/**
		 * High scores ranking button. */
		private var _highscoresRankingButton:IconButton;
		/**
		 * Settings button. */
		private var _settingsButton:IconButton;
		
		public function HomeScreen()
		{
			super();
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			_background = new Image(AbstractEntryPoint.assets.getTexture("dark-background"));
			addChild(_background);
			
			_headerContainer = new HeaderContainer();
			addChild(_headerContainer);
			
			_trophiesButton = new IconButton(AbstractEntryPoint.assets.getTexture("trophies-button"));
			_trophiesButton.addEventListener(Event.TRIGGERED, onShowTrophies);
			addChild(_trophiesButton);
		}
		
		override protected function draw():void
		{
			if(isInvalid(INVALIDATION_FLAG_SIZE))
			{
				_background.width = actualWidth;
				_background.height = actualHeight;
				
				_headerContainer.x = _headerContainer.y = scaleAndRoundToDpi(5);
				_headerContainer.width = scaleAndRoundToDpi(400);
				
				_trophiesButton.y = scaleAndRoundToDpi(5);
				_trophiesButton.x = actualWidth - _trophiesButton.width - scaleAndRoundToDpi(5);
			}
			
			super.draw()
		}
		
//------------------------------------------------------------------------------------------------------------
//	Handlers
		
		private function onShowTrophies(event:Event):void
		{
			CustomPopupManager.addPopup(new TrophiesPopupContent());
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
		
		override public function dispose():void
		{
			_background.removeFromParent(true);
			_background = null;
			
			_headerContainer.removeFromParent(true);
			_headerContainer = null;
			
			_trophiesButton.removeEventListener(Event.TRIGGERED, onShowTrophies);
			_trophiesButton.removeFromParent(true);
			_trophiesButton = null;
			
			super.dispose();
		}
	}
}