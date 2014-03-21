package com.ludofactory.mobile.core.manager
{
	/*_________________________________________________________________________________________
	|
	| Auteur      : Maxime Lhoez
	| Création    : 17 oct. 2012
	| Description : Gestionnaire des jugglers.
	|________________________________________________________________________________________*/
	
	import starling.animation.Juggler;
	
	public class JugglerManager
	{
		// few common names used
		public static const IN_GAME:String = "inGame";
		public static const GUI:String     = "gui";
		
		private static var _jugglers:Array = new Array(); // jugglers
		private static var _jugglersToPause:Vector.<String> = new Vector.<String>(); // the jugglers to pause / exclude from the update
		
		/**
		 * Returns a juggler whose name is passed as a parameter. If the juggler already exists, the function will
		 * simply return its instance. Otherwise, a new one will be created with this name.
		 * 
		 * @param jugglerName Name of the juggler to get.
		 * 
		 * @return A juggler.
		 */ 
		public static function getJuggler(jugglerName:String):Juggler 
		{
			if( !_jugglers.hasOwnProperty(jugglerName) )
				_jugglers[jugglerName] = new Juggler();
			return _jugglers[jugglerName];
		}
		
		/**
		 * Removes and destroys a juggler whose name is passed as a parameter.
		 * 
		 * @param jugglerName Name of the juggler to remove and delete.
		 */ 
		public static function removeJuggler(jugglerName:String):void
		{
			if( _jugglers.hasOwnProperty(jugglerName) )
			{
				(_jugglers[jugglerName] as Juggler).purge();
				_jugglers[jugglerName] = null;
				delete _jugglers[jugglerName];
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Pause - Resume
//------------------------------------------------------------------------------------------------------------
		
		/**
		 * Pauses a juggler if it exists.
		 * 
		 * @param jugglerName Name of the juggler to pause
		 */		
		public static function pauseJuggler(jugglerName:String):void
		{
			if( !_jugglers.hasOwnProperty(jugglerName) )
				return; // the juggler doesn't exist
			
			if( _jugglersToPause.indexOf(jugglerName) == -1 )
				_jugglersToPause.push(jugglerName); // this juggler has not already been paused
		}
		
		/**
		 * Pauses a juggler if it exists.
		 * 
		 * @param jugglerName Name of the juggler to pause
		 */		
		public static function resumeJuggler(jugglerName:String):void
		{
			if( !_jugglers.hasOwnProperty(jugglerName) )
				return; // the juggler doesn't exist
			
			if( _jugglersToPause.indexOf(jugglerName) != -1 )
				_jugglersToPause.splice(_jugglersToPause.indexOf(jugglerName), 1); // this juggler has been paused so we can remove it
		}
		
		/**
		 * Pauses all jugglers.
		 */		
		public static function pauseAllJugglers():void
		{
			for(var jugglerName:String in _jugglers)
			{
				pauseJuggler(jugglerName);
			}
		}
		
		/**
		 * Resumes all jugglers.
		 */		
		public static function resumeAllJugglers():void
		{
			_jugglersToPause = new Vector.<String>();
		}
		
//------------------------------------------------------------------------------------------------------------
//	Update
//------------------------------------------------------------------------------------------------------------
		
		public static function update(rawElapsedTime:Number):void
		{
			var juggler:Juggler;
			for(var jugglerName:String in _jugglers)
			{
				if( _jugglersToPause.indexOf(jugglerName) == -1)
				{
					// if the juggler has not been paused, we can call advanceTime on it
					juggler = _jugglers[jugglerName];
					juggler.advanceTime(rawElapsedTime);
				}
			}
		}
		
	}
}