/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 15 oct. 2012
*/
package com.ludofactory.mobile.core.pause
{
	
	import com.greensock.TweenMax;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.HeartBeat;
	import com.ludofactory.mobile.core.events.MobileEventTypes;
	
	import starling.core.Starling;
	import starling.events.Event;
	import starling.events.EventDispatcher;
	
	/**
	 * This class will manage the pause.
	 * 
	 * @author Maxime Lhoez
	 */	
	public class PauseManager
	{
		private static var _isPauseViewDisplaying:Boolean = false;
		private static var _isPlaying:Boolean = false;
		private static var _isPaused:Boolean = false;
		
		private static var _pauseView:PauseView;
		
		private static var _dispatcher:EventDispatcher = new EventDispatcher();
		
//------------------------------------------------------------------------------------------------------------
//	Pause - resume
		
		/**
		 * Pause the game.
		 * 
		 * <p>
		 * If the player is playing <i>(and not just navigating throughout views)</i>, this function will display a PauseView to
		 * indicate that the game was paused. <code>HeartBeat</code> and <code>TweenMax</code> will be paused.
		 * Once the PauseView has finished displaying, <code>Starling</code> is paused to save battery.
		 * </p>
		 * 
		 * <p>
		 * If the player was not playing, everything will be paused : <code>Starling, HeartBeat, TweenMax.</code>
		 * </p>
		 * 
		 * <p>
		 * <strong>Note : </strong>TweenLite won't be paused because we might need it for some animations in the PauseView and also because
		 * we can't use the pauseAll function since it doesn't exist on TweenLite.
		 * On contrary, TweenMax will always be paused because we must be using it for some in game animation.
		 * </p>
		 * 
		 * @param manualCall A Boolean that indicates if the function was called manually <i>(throughout the pause button)</i>
		 * so that we know if we need to pause <code>Starling</code> or not once the PauseView is displayed. <strong>Default false.</strong>
		 * 
		 * @see HeartBeat
		 */		
		public static function pause(manualCall:Boolean = false):void
		{
			if(!_isPaused)
			{
				//log("[PauseManager] pause - is playing ? " + _isPlaying + " and manual call (pause button) ? " + manualCall);
				
				_isPaused = true;
				
				HeartBeat.pause();
				TweenMax.pauseAll();
				
				if(_isPlaying && !_isPauseViewDisplaying)
				{
					// if the player is playing, we need to display the PauseView (only if it's not already displaying) before pausing Starling and TweenMax
					_isPauseViewDisplaying = true;
					if(_pauseView == null)
						_pauseView = new PauseView();
					(Starling.current.root as AbstractEntryPoint).addChild(_pauseView);
					if(!manualCall)
						_pauseView.addEventListener(MobileEventTypes.ANIMATION_IN_COMPLETE, onPauseViewDisplayed);
					_pauseView.addEventListener(MobileEventTypes.ANIMATION_OUT_COMPLETE, onPauseViewHidden);
					_pauseView.addEventListener(MobileEventTypes.RESUME, onResumeButtonClicked);
					_pauseView.addEventListener(MobileEventTypes.EXIT, onExitButtonClicked);
					_pauseView.animateIn(manualCall);
				}
				else
				{
					// if the player is not playing or if he is playing but the PauseView is already displayed, we simply stop Starling
					Starling.current.stop(true);
				}
			}
		}
		
		/**
		 * Resume the game.
		 * 
		 * <p>
		 * If the player was playing, we only need to resume <code>Starling</code> so that he is able to resume or leave
		 * the game.
		 * </p>
		 * 
		 * <p>
		 * Otherwise, we can resume everything : <code>Starling, HeartBeat and TweenMax</code>.
		 * </p>
		 * 
		 * @see HeartBeat
		 */		
		public static function resume():void
		{
			if(_isPaused)
			{
				//log("[PauseManager] resume - is playing ? " + _isPlaying);
				
				_isPaused = false;
				
				Starling.current.start();
				
				if(!_isPlaying)
				{
					// otherwise we resume everything
					HeartBeat.resume();
					TweenMax.resumeAll();
				}
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Handlers
//------------------------------------------------------------------------------------------------------------
		
		/**
		 * Call once the PauseView has finished displaying. This function will pause Starling so
		 * that battery life is saved.
		 * 
		 * @param evt
		 */		
		private static function onPauseViewDisplayed(evt:Event):void
		{
			Starling.current.stop();
		}
		
		/**
		 * Call once the PauseView has finished displaying. This function will pause Starling so
		 * that battery life is saved.
		 * 
		 * @param evt
		 */		
		private static function onPauseViewHidden(evt:Event):void
		{
			if(_pauseView != null && _isPauseViewDisplaying)
			{
				if(_pauseView.hasEventListener(MobileEventTypes.ANIMATION_IN_COMPLETE))
					_pauseView.removeEventListener(MobileEventTypes.ANIMATION_IN_COMPLETE, onPauseViewDisplayed);
				_pauseView.removeEventListener(MobileEventTypes.ANIMATION_OUT_COMPLETE, onPauseViewHidden);
				_pauseView.removeEventListener(MobileEventTypes.RESUME, onResumeButtonClicked);
				_pauseView.removeEventListener(MobileEventTypes.EXIT, onExitButtonClicked);
				
				_pauseView.removeFromParent(true);
				_pauseView = null;
			}
			_isPauseViewDisplaying = false;
			_isPaused = false;
			
			HeartBeat.resume();
			TweenMax.resumeAll();
		}
		
		/**
		 * When the resume button is clicked
		 * 
		 * @param evt
		 */		
		private static function onResumeButtonClicked(evt:Event):void
		{
			_dispatcher.dispatchEventWith(MobileEventTypes.RESUME);
		}
		
		/**
		 * When the exit button is clicked
		 * 
		 * @param evt
		 */		
		private static function onExitButtonClicked(evt:Event):void
		{
			_dispatcher.dispatchEventWith(MobileEventTypes.EXIT);
		}
		
//------------------------------------------------------------------------------------------------------------
//	GET - SET
		
		public static function get dispatcher():EventDispatcher
		{
			return _dispatcher;
		}
		
		public static function get isPaused():Boolean { return _isPaused; }
		
		public static function get isPlaying():Boolean { return _isPlaying; }
		public static function set isPlaying(val:Boolean):void { _isPlaying = val; }
	}
}