package com.ludofactory.mobile.core
{
	import starling.events.Event;
	
	/**
	 * IGame interface that must be implemented in every GameScreen class.
	 */	
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
		 * 
		 * <p>You should start the game here, launching the timer, etc.</p>
		 */		
		function startLevel():void;
		
		/**
		 * Called when the player touches the "Resume" button within the pause view.
		 * 
		 * <p>Override this function if you need to do some special actions whenever
		 * the game is resume (i.e unhide cards).</p>
		 */		
		function resume(event:Event):void;
		/**
		 * Called when the player touches the "Give up" button within the pause view.
		 * 
		 * <p>This function will set up a variable that will determine whether the
		 * game session have been finished or not.</p>
		 */		
		function giveUp(event:Event):void;
		
		/**
		 * The game is over, whether because the player gave up, because the timer is
		 * over or because the player is stuck.
		 * 
		 * <p>Override this function to do some special treatement such as checking
		 * trophies.</p>
		 */		
		function gameOver():void;
	}
}