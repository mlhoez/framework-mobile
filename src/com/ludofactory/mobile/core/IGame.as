package com.ludofactory.mobile.core
{
	import starling.events.Event;

	public interface IGame
	{
		/**
		 * Initializes all the game sounds. This function is automatically called
		 * by the function <code>initializeContent</code> when the assets have been
		 * all loaded.
		 * 
		 * <p>Override this function in the GameScreen in order to load all the
		 * necessary sounds.</p>
		 */		
		function initializeSounds():void;
			
		/**
		 * Initializes the base content (only once).
		 * 
		 * <p>Override this function to create the base content of the game and then,
		 * DO NOT forget to call this function by doing a super.initializeBaseContent
		 * in order to remove the loader and create the overlay and play button.</p>
		 */		
		function initializeContent():void;
		
		/**
		 * Starts the level.
		 */		
		function startLevel():void;
		
		/**
		 * Resumes the game.
		 */		
		function resume(event:Event):void;
		
		/**
		 * Game over.
		 */		
		function gameOver(event:Event = null):void;
	}
}