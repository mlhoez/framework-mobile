/*
 Copyright © 2006-2015 Ludo Factory
 Framework Ludokado
 Author  : Maxime Lhoez
 Created : 12 sept. 2014
*/
package com.ludofactory.common.utils.logs
{
	
	import com.ludofactory.common.utils.*;
	
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import feathers.controls.Button;
	import feathers.controls.ScrollText;
	import feathers.core.FeathersControl;
	
	import flash.text.TextFormat;
	
	import starling.display.Quad;
	import starling.display.Sprite;
	
	public class LogDisplayer extends FeathersControl
	{
		private static var _instance:LogDisplayer;
		
		/**
		 * Whether the log displayer is currently displaying. */
		private static var _isDisplaying:Boolean = false;
		
		private var _logs:ScrollText;
		
		private var _overlay:Quad;
		
		private var _logText:String = "";

		/**
		 * FIXME WARNING
		 * This class must be called after the value of BaseServerData.isAdmin have been set (so when the flash
		 * vars have been parsed and never before
		 */
	    public function LogDisplayer(sk:SecurityKey)
	    {
		    super();
		    
		    if(sk == null)
			    throw new Error("Erreur : Echec de l'instanciation : Utiliser LogDisplayer.getInstance() au lieu de new.");
	    }
		
		override protected function initialize():void
		{
			super.initialize();
			
			_overlay = new Quad(5, 5, 0x000000);
			_overlay.alpha = 0.75;
			addChild(_overlay);
			
			_logs = new ScrollText();
			_logs.isHTML = true;
			_logs.textFormat = new TextFormat("Arial", scaleAndRoundToDpi( GlobalConfig.isPhone ? 22 : 18 ), 0xffffff);
			addChild(_logs);
			_logs.paddingLeft = _logs.paddingRight = _logs.paddingBottom = scaleAndRoundToDpi(10);
			
			_logs.text = _logText;
		}
		
		override protected function draw():void
		{
			super.draw();
			
			_overlay.width = _logs.width = GlobalConfig.stageWidth;
			_overlay.height = _logs.height = GlobalConfig.stageHeight;
		}

//------------------------------------------------------------------------------------------------------------
//  
		
		/**
		 * Enables the debug console.
		 * 
		 * Automatically set in set setter of isAdmin in BaseServerData class.
		 */
		public static function enable():void
		{
			// TODO create scroll text
		}

		/**
		 * Disables the debug console.
		 *
		 * Automatically set in set setter of isAdmin in BaseServerData class.
		 */
		public static function disable():void
		{
			// TODO remove scroll text
		}

//------------------------------------------------------------------------------------------------------------
//	Handlers
		
		private static function onClearLogs():void
		{
			// TODO clear logs here
		}
		
//------------------------------------------------------------------------------------------------------------
//
		
		/**
		 * Only called by the log global static function.
		 */
	    public function addLog(log:String):void
	    {
		    _logText = log + "\n" + _logText;
		    if( _logText.length > 40000 )
			    _logText = _logText.slice(0, _logText.length * 0.25); // suppression du quart le plus ancien des logs
		    if( _logs) _logs.text = _logText;
	    }
		
		public static function getInstance():LogDisplayer
		{
			if(_instance == null)
				_instance = new LogDisplayer(new SecurityKey());
			return _instance;
		}
		
    }
}

internal class SecurityKey{}