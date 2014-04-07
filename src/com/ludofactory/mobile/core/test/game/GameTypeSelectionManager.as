/*
Copyright © 2006-2014 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 2 déc. 2013
*/
package com.ludofactory.mobile.core.test.game
{
	import com.gamua.flox.Flox;
	import com.greensock.TweenMax;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.test.config.GlobalConfig;
	
	import starling.display.DisplayObject;
	import starling.display.Quad;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;

	public class GameTypeSelectionManager
	{
		/**
		 * The black overlay. */		
		private var _blackOverlay:Quad;
		
		/**
		 * The game type selection popup. */		
		private var _popup:GameTypeSelectionPopup;
		
		/**
		 * The saved root used to display the popup. */		
		private var _savedRoot:DisplayObject;
		
		public function GameTypeSelectionManager(root:DisplayObject)
		{
			_savedRoot = root;
			
			_blackOverlay = new Quad(GlobalConfig.stageWidth, GlobalConfig.stageHeight, 0x000000);
			_blackOverlay.alpha = 0;
			_blackOverlay.visible = false;
			(_savedRoot as AbstractEntryPoint).addChild(_blackOverlay);
			
			_popup = new GameTypeSelectionPopup();
			_popup.width = GlobalConfig.stageWidth * (GlobalConfig.isPhone ? 0.89 : 0.69);
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
			Flox.logInfo("Fermeture de la popup de choix du mode de jeu");
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