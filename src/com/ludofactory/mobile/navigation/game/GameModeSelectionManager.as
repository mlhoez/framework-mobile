/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 2 déc. 2013
*/
package com.ludofactory.mobile.navigation.game
{
	import com.gamua.flox.Flox;
	import com.greensock.TweenMax;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.AbstractGameInfo;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.manager.MemberManager;
	import com.milkmangames.nativeextensions.GAnalytics;
	
	import starling.display.DisplayObject;
	import starling.display.Quad;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;

	public class GameModeSelectionManager
	{
		/**
		 * The black overlay. */		
		private var _blackOverlay:Quad;
		
		/**
		 * The game type selection popup. */		
		private var _popup:GameModeSelectionPopup;
		
		/**
		 * The saved root used to display the popup. */		
		private var _savedRoot:DisplayObject;
		
		public function GameModeSelectionManager(root:DisplayObject)
		{
			_savedRoot = root;
			
			_blackOverlay = new Quad(GlobalConfig.stageWidth, GlobalConfig.stageHeight, 0x000000);
			_blackOverlay.alpha = 0;
			_blackOverlay.visible = false;
			(_savedRoot as AbstractEntryPoint).addChild(_blackOverlay);
			
			_popup = new GameModeSelectionPopup();
			_popup.width = GlobalConfig.stageWidth * (GlobalConfig.isPhone ? (AbstractGameInfo.LANDSCAPE ? 0.7: 0.9) : (AbstractGameInfo.LANDSCAPE ? 0.5 : 0.7));
			_popup.x = (GlobalConfig.stageWidth - _popup.width) * 0.5;
			(_savedRoot as AbstractEntryPoint).addChild(_popup);
			_popup.validate();
			_popup.y = (GlobalConfig.stageHeight - _popup.height) * 0.5;
			_popup.visible = false;
		}
		
//------------------------------------------------------------------------------------------------------------
//	Utils
//------------------------------------------------------------------------------------------------------------
		
		public function show(skipAnim:Boolean = false):void
		{
			_blackOverlay.addEventListener(TouchEvent.TOUCH, onClose);
			TweenMax.to(_blackOverlay, 0.25, { autoAlpha:0.75 });
			
			_popup.visible = true;
			_popup.addEventListener(Event.CLOSE, onClosePopup);
			if( skipAnim )
				_popup.animateInSkip();
			else
				_popup.animateIn();
			
			if( GAnalytics.isSupported() )
				GAnalytics.analytics.defaultTracker.trackEvent("Accueil", "Affichage du choix du mode de jeu", null, NaN, MemberManager.getInstance().id);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Handlers
//------------------------------------------------------------------------------------------------------------
		
		/**
		 * The user touched the black overlay, thus we need to
		 * close the popup.
		 */		
		private function onClose(event:TouchEvent):void
		{
			if( _popup.canBeClosed )
			{
				var touch:Touch = event.getTouch(_blackOverlay);
				if( touch && touch.phase == TouchPhase.ENDED )
					onClosePopup();
				touch = null;
			}
		}
		
		/**
		 * Close the popup.
		 */		
		private function onClosePopup():void
		{
			Flox.logInfo("<strong>&rarr; Fermeture du choix du mode de jeu</strong>");
			_blackOverlay.removeEventListener(TouchEvent.TOUCH, onClose);
			TweenMax.to(_blackOverlay, 0.25, { autoAlpha:0 });
			
			_popup.removeEventListener(Event.CLOSE, onClosePopup);
			_popup.addEventListener(Event.COMPLETE, onAnimationOutComplete);
			_popup.animateOut();
		}
		
		/**
		 * 
		 */		
		private function onAnimationOutComplete(event:Event):void
		{
			_popup.removeEventListener(Event.COMPLETE, onAnimationOutComplete);
			_popup.visible = false;
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
//------------------------------------------------------------------------------------------------------------
		
		public function dispose():void
		{
			_savedRoot = null;
		}
	}
}