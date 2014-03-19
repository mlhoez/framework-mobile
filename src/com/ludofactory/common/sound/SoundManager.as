/*
LudoFactory
Framework mobile
Author  : Maxime Lhoez
Created : 20 nov. 2013
*/
package com.ludofactory.common.sound
{
	import flash.media.Sound;
	import flash.media.SoundLoaderContext;
	import flash.net.URLRequest;
	
	import starling.events.EventDispatcher;
	
	/**
	 * A Sound Manager based on the work of Matt Przybylski [http://www.reintroducing.com]
	 */	
	public class SoundManager extends EventDispatcher
	{
		/**
		 * SoundManager instance. */		
		private static var _instance:SoundManager;
		
		/**
		 * Whether all the sounds have been loaded. */		
		private var _allSoundsLoaded:Boolean = false;
		
		public function SoundManager(singleton:Singleton)
		{
			
		}
		
		/**
		 * Returns SoundManager instance.
		 */ 
		public static function getInstance():SoundManager 
		{
			if(_instance == null)
				_instance = new SoundManager(new Singleton());
			return _instance;
		}
		
//------------------------------------------------------------------------------------------------------------
//	Loading methods
//------------------------------------------------------------------------------------------------------------
		
		/**
		 * Loads a sound.
		 * 
		 * @param soundName The string identifier of the sound to be used when calling other methods on the sound
		 * @param playlist The playlist name to wich we want to add the sound
		 * @param path A string representing the path where the sound is on the server
		 * @param buffer The number, in milliseconds, to buffer the sound before you can play it (default: 1000)
		 * @param checkPolicyFile A boolean that determines whether Flash Player should try to download a cross-domain policy file from the loaded sound's server before beginning to load the sound (default: false) 
		 * 
		 * @return Boolean A boolean value representing if the sound was added successfully
		 */
		public function addSound(soundName:String, path:String, playlist:String, buffer:Number = 1000, checkPolicyFile:Boolean = false):Boolean
		{
			if( PlaylistManager.getPlaylist(playlist).hasSound(soundName) )
				return false;
			
			var si:SoundItem = new SoundItem(soundName);
			si.sound = new Sound(new URLRequest(path), new SoundLoaderContext(buffer, checkPolicyFile));
			PlaylistManager.getPlaylist(playlist).addSound(si);
			return true;
		}

//--------------------------------------------------------------------------------------------------------
// PLAY METHODS
//--------------------------------------------------------------------------------------------------------
		
		/**
		 * Plays the specified sound in the specified playlist.
		 * 
		 * @param soundName Name of the sound to play
		 * @param playlistName Name of the playlist in which is the sound to play
		 * @param loops How many times will loop the sound
		 * @param volume Volume of the sound
		 * @param startTime Offset from de beginning of the sound
		 * @param fading Indicates if the sounds has to fade before resume
		 * @param fadeTime Time for fading
		 * @param unique Indicates if the chanel instance of this sound must be unique or not
		 */ 
		public function playSound(soundName:String, playlist:String, loops:int = 0, volume:Number = 1, fadeDuration:Number = 0, unique:Boolean = false):void
		{
			PlaylistManager.getPlaylist(playlist).play(soundName, loops, volume, fadeDuration, unique);
		}
		
		/**
		 * Plays a sound randomly in the specified playlist.
		 * 
		 * @param playlistName Name of the playlist where we will play a sound randomly.
		 * @param loops How many times will loop the sound
		 * @param volume Volume of the sound
		 * @param startTime Offset from de beginning of the sound
		 * @param fading Indicates if the sounds has to fade before resume
		 * @param fadeTime Time for fading
		 * @param unique Indicates if the chanel instance of this sound must be unique or not
		 */ 
		public function playRandomSound(playlistName:String, loops:int = 0, volume:Number = 1, fadeDuration:Number = 0, unique:Boolean = false):void
		{
			PlaylistManager.getPlaylist(playlistName).playRandomSound(loops, volume, fadeDuration, unique);
		}
		
//--------------------------------------------------------------------------------------------------------
// 	MUTE - UNMUTE METHODS
//--------------------------------------------------------------------------------------------------------
		
		/**
		 * Mutes a playlist.
		 * 
		 * @param playlistName The name of the playlist to mute.
		 * @param fadeDuration The fade duration (0 = no fade).
		 */ 
		public function mutePlaylist(playlistName:String, fadeDuration:Number = 0):void
		{
			PlaylistManager.getPlaylist(playlistName).mutePlaylist(fadeDuration);
		}
		
		/**
		 * Unmutes a playlist.
		 * 
		 * @param playlistName The name of the playlist to unmute.
		 * @param fadeDuration The fade duration (0 = no fade).
		 */ 
		public function unmutePlaylist(playlistName:String, fadeDuration:Number = 0):void
		{
			PlaylistManager.getPlaylist(playlistName).unmutePlaylist(fadeDuration);
		}
		
		/**
		 * Mutes a single sound in a playlist.
		 * 
		 * @param soundName The name of the sound to mute.
		 * @param playlistName The name of the playlist in which is the specified sound.
		 * @param fadeDuration The fade duration (0 = no fade).
		 */ 
		public function muteSound(soundName:String, playlistName:String, fadeDuration:Number = 0):void
		{
			PlaylistManager.getPlaylist(playlistName).muteSound(soundName, fadeDuration);
		}
		
		/**
		 * Unmutes a single sound in a playlist.
		 * 
		 * @param soundName The name of the sound to unmute.
		 * @param playlistName The name of the playlist in which is the specified sound.
		 * @param fadeDuration The fade duration (0 = no fade).
		 */ 
		public function unmuteSound(soundName:String, playlistName:String, fadeDuration:Number = 0):void
		{
			PlaylistManager.getPlaylist(playlistName).unmuteSound(soundName, fadeDuration);
		}
		
//--------------------------------------------------------------------------------------------------------
// 	PAUSE - RESUME METHODS
//--------------------------------------------------------------------------------------------------------
		
		/**
		 * Pauses a playlist.
		 * 
		 * @param playlistName The name of the playlist to pause.
		 * @param fadeDuration The fade duration (0 = no fade).
		 */ 
		public function pausePlaylist(playlistName:String, fadeDuration:Number = 0):void
		{
			PlaylistManager.getPlaylist(playlistName).pausePlaylist(fadeDuration);
		}
		
		/**
		 * Resumes a playlist.
		 * 
		 * @param playlistName The name of the playlist to resume.
		 * @param fadeDuration The fade duration (0 = no fade).
		 */ 
		public function resumePlaylist(playlistName:String, fadeDuration:Number = 0):void
		{
			PlaylistManager.getPlaylist(playlistName).resumePlaylist(fadeDuration);
		}
		
		/**
		 * Pauses a single sound in a playlist.
		 * 
		 * @param soundName The name of the sound to pause.
		 * @param playlistName The name of the playlist in which is the specified sound.
		 * @param fadeDuration The fade duration (0 = no fade).
		 */ 
		public function pauseSound(soundName:String, playlistName:String, fadeDuration:Number = 0):void
		{
			PlaylistManager.getPlaylist(playlistName).pauseSound(soundName, fadeDuration);
		}
		
		/**
		 * Resumes a sound in a playlist.
		 * 
		 * @param soundName The name of the sound to resume
		 * @param playlistName The name of the playlist in which is the specified sound
		 * @param fadeDuration The fade duration (0 = no fade).
		 */ 
		public function resumeSound(soundName:String, playlistName:String, fadeDuration:Number = 0):void
		{
			PlaylistManager.getPlaylist(playlistName).resumeSound(soundName, fadeDuration);
		}
		
//--------------------------------------------------------------------------------------------------------
// 	STOP METHODS
//--------------------------------------------------------------------------------------------------------
		
		/**
		 * Stops a playlist.
		 * 
		 * @param playlistName Name of the playlist to stop
		 * @param fading Indicates if the sounds have to fade before being stopped
		 * @param fadeTime Time for fading
		 */ 
		public function stopPlaylist(playlistName:String, fadeDuration:Number = 0):void
		{
			PlaylistManager.getPlaylist(playlistName).stopPlaylist(fadeDuration);
		}
		
		/**
		 * Stops a sound in a playlist.
		 * 
		 * @param soundName Name of the sound to stop
		 * @param playlistName Name of the playlist in which is the specified sound
		 * @param fading Indicates if the sound has to fade before being stopped
		 * @param fadeTime Time for fading
		 */ 
		public function stopSound(soundName:String, playlistName:String, fadeDuration:Number = 0):void
		{
			PlaylistManager.getPlaylist(playlistName).stopSound(soundName, fadeDuration);
		}
		
//--------------------------------------------------------------------------------------------------------
// 	REMOVE METHODS
//--------------------------------------------------------------------------------------------------------
		
		/**
		 * Removes a playlist.
		 * 
		 * @param playlistName Name of the playlist to stop
		 */ 
		public function removePlaylist(playlistName:String):void
		{
			//log("[SoundManager] removePlaylist ["+ playlistName +"]");
			//TODO
		}
		
		/**
		 * Removes a sound in a playlist.
		 * 
		 * @param soundName Name of the sound to remove
		 * @param playlistName Name of the playlist in which is the specified sound
		 */ 
		public function removeSound(soundName:String, playlistName:String):void
		{
			//log("[SoundManager] removeSound ["+ soundName +"] ["+ playlistName +"]");
			//TODO
		}
		
		public function set allSoundsLoaded(val:Boolean):void { _allSoundsLoaded = val; }
		public function get allSoundsLoaded():Boolean { return _allSoundsLoaded; }
	}
}

internal class Singleton{}