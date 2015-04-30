/*
Copyright © 2006-2015 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 20 nov. 2013
*/
package com.ludofactory.common.sound
{
	public class Playlist
	{
		/**
		 * The playlist name. */		
		private var _name:String;
		
		/**
		 * The sounds. */		
		private var _sounds:Object = {};
		
		/**
		 * The sounds names. */		
		private var _soundsNames:Array = [];
		
		/**
		 * Whether the playlist is muted. */		
		private var _isMuted:Boolean = false;
		
		/**
		 * Whether the playlist is paused. */		
		//private var _isPaused:Boolean = false;
		
		/**
		 * Whether the playlist is stopped. */		
		//private var _isStopped:Boolean = false;
		
		public function Playlist(playlistName:String)
		{
			_name = playlistName;
		}
		
		/**
		 * Adds a sounds to the playlist.
		 * <p><i>Example : PlaylistManager.getPlaylist("sfx").addSound(mySoundItem);</i></p>
		 * 
		 * @param soundItem The SoundItem to add.
		 * 
		 * @return True if the sound has successfully been added to the playlist.
		 */
		public function addSound(soundItem:SoundItem):Boolean
		{
			if( !soundItem )
				return false;
			
			soundItem.isMuted = _isMuted;
			_sounds[soundItem.name] = soundItem;
			_soundsNames.push(soundItem.name);
			
			return true;
		}
		
//--------------------------------------------------------------------------------------------------------
// Play methods
//--------------------------------------------------------------------------------------------------------
		
		/**
		 * Plays the specified sound. Throws an error if the sound doesn't exists.
		 * 
		 * @param soundName Name of the sound
		 * @param loops How many times will loop the sound
		 * @param volume Volume of the sound
		 * @param startTime Offset from the beginning of the sound
		 * @param fading Indicates if the sounds has to fade before resume
		 * @param fadeTime Time for fading
		 * @param unique Indicates if the chanel instance of this sound must be unique or not
		 */ 
		public function play(soundName:String, loops:int, volume:Number, fadeTime:Number, unique:Boolean):void
		{
			if( !(soundName in _sounds) )
				throw new Error("Sound [" + soundName + "] does not exist.");
			
			//TODO Gérer le fait que la playlist est peut être en pause, alors il ne faut pas jouer le son et penser à sauvegarder le bon volume
			//TODO Gérer le fait que la playlist est peut être en mute, alors il faut jouer le son avec le bon volume mais commencer en mute aussi		
			
			SoundItem(_sounds[soundName]).play(loops, volume, fadeTime, unique);
		}
		
		/**
		 * Plays a random sound of the playlist.
		 * 
		 * @param loops How many times the sound will loop
		 * @param volume Volume of the sound
		 * @param startTime Offset from de beginning of the sound
		 * @param fading Indicates if the sounds has to fade before resume
		 * @param fadeTime Time for fading
		 * @param unique Indicates if the chanel instance of this sound must be unique or not
		 */ 
		public function playRandomSound(loops:int, volume:Number, fadeTime:Number, unique:Boolean):void
		{
			play(_soundsNames[Math.round(Math.random() * (_soundsNames.length - 1))], loops, volume, fadeTime, unique);
		}
		
//--------------------------------------------------------------------------------------------------------
// 	Controls : mute
//--------------------------------------------------------------------------------------------------------
		
		/**
		 * Mutes the playlist.
		 * 
		 * @param fadeTime Time for fading
		 */ 
		public function mutePlaylist(fadeTime:Number):void
		{
			if( !_isMuted )
			{
				_isMuted = true;
				for each(var si:SoundItem in _sounds)
					si.mute(fadeTime);
			}
		}
		
		/**
		 * Unmutes the playlist.
		 * 
		 * @param fadeTime Time for fading
		 */ 
		public function unmutePlaylist(fadeTime:Number):void
		{
			if( _isMuted )
			{
				_isMuted = false;
				for each(var si:SoundItem in _sounds)
					si.unmute(fadeTime);
			}
		}
		
		/**
		 * Mutes a specific sound.
		 * 
		 * @param soundName Name of the sound to mute
		 * @param fadeTime Time for fading
		 */ 
		public function muteSound(soundName:String, fadeTime:Number):void
		{
			if( !_isMuted )
			{
				if( !(soundName in _sounds) )
					throw new Error("Sound [" + soundName + "] does not exist.");
				SoundItem(_sounds[soundName]).mute(fadeTime);
			}
		}
		
		/**
		 * Unmutes the specified sound.
		 * 
		 * @param soundName Name of the sound to unmute
		 * @param fadeTime Time for fading
		 */ 
		public function unmuteSound(soundName:String, fadeTime:Number):void
		{
			if( !_isMuted )
			{
				if( !(soundName in _sounds) )
					throw new Error("Sound [" + soundName + "] does not exist.");
				SoundItem(_sounds[soundName]).unmute(fadeTime);
			}
		}
		
//--------------------------------------------------------------------------------------------------------
// 	Controls : pause
//--------------------------------------------------------------------------------------------------------
		
		/**
		 * Pauses the playlist.
		 * 
		 * @param fadeDuration The fade duration (0 = no fade).
		 */ 
		public function pausePlaylist(fadeDuration:Number):void
		{
			/*if( _isPaused )
			{*/
				//_isPaused = true;
				for each(var si:SoundItem in _sounds)
					si.pause(fadeDuration);
			//}
		}
		
		/**
		 * Resumes the playlist.
		 * 
		 * @param fadeDuration The fade duration (0 = no fade).
		 */ 
		public function resumePlaylist(fadeDuration:Number):void
		{
			/*if( _isPaused )
			{*/
				//_isPaused = false;
				for each(var si:SoundItem in _sounds)
					si.resume(fadeDuration);
			//}
		}
		
		/**
		 * Pauses a single sound in a playlist.
		 * 
		 * @param soundName The name of the sound to pause.
		 * @param fadeDuration The fade duration (0 = no fade).
		 */ 
		public function pauseSound(soundName:String, fadeDuration:Number):void
		{
			/*if( !_isPaused )
			{*/
				if( !(soundName in _sounds) )
					throw new Error("Sound [" + soundName + "] does not exist.");
				SoundItem(_sounds[soundName]).pause(fadeDuration);
			//}
		}
		
		/**
		 * Resumes the specified sound in the playlist.
		 * 
		 * @param soundName The name of the sound to resume.
		 * @param fadeDuration The fade duration (0 = no fade).
		 */ 
		public function resumeSound(soundName:String, fadeDuration:Number):void
		{
			/*if( !_isPaused )
			{*/
				if( !(soundName in _sounds) )
					throw new Error("Sound [" + soundName + "] does not exist.");
				SoundItem(_sounds[soundName]).resume(fadeDuration);
			//}
		}
		
//--------------------------------------------------------------------------------------------------------
// 	STOP METHODS
//--------------------------------------------------------------------------------------------------------
		
		/**
		 * Stops the playlist.
		 * 
		 * @param fading Indicates if the sounds have to fade before being stopped
		 * @param fadeTime Time for fading
		 */ 
		public function stopPlaylist(fadeDuration:Number):void
		{
			/*if( !_isStopped )
			{*/
				//_isStopped = true;
				for each(var si:SoundItem in _sounds)
					si.stop(fadeDuration);
			//}
		}
		
		/**
		 * Stops the specified sound in the playlist.
		 * 
		 * @param soundName Name of the sound to stop
		 * @param fading Indicates if the sound has to fade before being stopped
		 * @param fadeTime Time for fading
		 */ 
		public function stopSound(soundName:String, fadeDuration:Number):void
		{
			/*if( _isStopped )
			{*/
				//_isStopped = false;
				if( !(soundName in _sounds) )
					return;
				SoundItem(_sounds[soundName]).stop(fadeDuration);
			//}
		}
		
		/**
		 * 
		 */		
		public function hasSound(soundName:String):Boolean
		{
			return _soundsNames.indexOf(soundName) != -1;
		}
		
//--------------------------------------------------------------------------------------------------------
// 	Dispose
//--------------------------------------------------------------------------------------------------------
		
		public function dispose():void
		{
			// TODO
			
			/*
			* for(var name:String in obj)
			* 		Renvoie les noms
			* 
			* for each(var snd:Sound in obj)
			* 		Renvoie le contenu
			*
			*/
			/*
			for each(var snd:SoundItem in __Sounds)
			{
				//stop all channels
				snd.stop();
				//snd.destroy() ?
			delete snd
			}
			
			__Sounds = null
				delete __Playlists[__Name];*/
		}
	}
}