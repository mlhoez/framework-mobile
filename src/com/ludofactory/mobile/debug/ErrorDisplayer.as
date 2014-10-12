/*
Copyright © 2006-2014 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 9 janv. 2014
*/
package com.ludofactory.mobile.debug
{
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.controls.AdvancedScreen;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import flash.text.TextFormat;
	
	import feathers.controls.ScrollText;
	
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.display.Quad;
	
	/**
	 * Displays a PHP error when it occurs.
	 * 
	 * <p>This static function is called in Remote when a PHP
	 * error occurs, so when the generic callback function is
	 * called (onQueryFail).</p>
	 * 
	 * @see com.ludofactory.mobile.core.remoting.Remote
	 */
	public class ErrorDisplayer
	{
		/**
		 * The current popup overlay. */		
		private static var _overlay:DisplayObject;
		
		/**
		 * The error message to display. */		
		private static var _errorMessage:ScrollText;
		
		/**
		 * Displays an error message above all content.
		 * 
		 * <p>When the message is displayed, the user is unable to
		 * do anything, the back button is locked for security reason.</p>
		 * 
		 * @param message The error message to display
		 */		
		public static function showError(message:String):void
		{
			// FIXME Envoyer automatiquement un message au service client ou en interne ?
			
			AdvancedScreen(AbstractEntryPoint.screenNavigator.activeScreen).canBack = false;
			
			_overlay = new Quad(100, 100, 0x000000);
			_overlay.alpha = 0.75;
			_overlay.width = GlobalConfig.stageWidth;
			_overlay.height = GlobalConfig.stageHeight;
			Starling.current.stage.addChild(_overlay);
			
			_errorMessage = new ScrollText();
			_errorMessage.text = message;
			_errorMessage.textFormat = new TextFormat("Arial", scaleAndRoundToDpi(20), Theme.COLOR_WHITE);
			_errorMessage.width = GlobalConfig.stageWidth;
			_errorMessage.height = GlobalConfig.stageHeight;
			_errorMessage.isHTML = true;
			Starling.current.stage.addChild(_errorMessage);
		}
	}
}