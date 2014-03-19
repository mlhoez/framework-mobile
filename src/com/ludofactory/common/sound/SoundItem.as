/*
LudoFactory
Framework mobile
Author  : Maxime Lhoez
Created : 20 nov. 2013
*/
package com.ludofactory.common.sound
{
	import com.greensock.TweenLite;
	import com.greensock.plugins.TweenPlugin;
	import com.greensock.plugins.VolumePlugin;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	
	public class SoundItem extends EventDispatcher
	{
		/**
		 * The sound name. */		
		private var _name:String;
		
		/**
		 * The sound instance. */		
		private var _sound:Sound;
		
		/**
		 * Chanels list for this sound. */		
		private var _chanelsList:Array = [];
		
		/**
		 * Whether the sound is muted. */		
		private var _isMuted:Boolean = false;
		
		public function SoundItem(soundName:String)
		{
			TweenPlugin.activate( [VolumePlugin] );
			_name = soundName;
		}
		
//--------------------------------------------------------------------------------------------------------
// PLAY METHOD
//--------------------------------------------------------------------------------------------------------
		
		/**
		 * Plays the sound.
		 * 
		 * @param loops How many times will loop the sound
		 * @param volume Volume of the sound
		 * @param fadeTime Time for fading
		 * @param unique Indicates if the chanel instance of this sound must be unique or not
		 */ 
		public function play(loops:int, volume:Number, fadeTime:Number, unique:Boolean):void
		{
			// stop the all channels if the sound is unique
			if(unique)
				stop();
			
			var sic:SoundItemChannel;
			if(_isMuted)
			{
				sic = new SoundItemChannel(_name, _sound.play(0, 0, new SoundTransform(0)), loops, new SoundTransform(volume));
			}
			else
			{
				if( fadeTime > 0 )
				{
					sic = new SoundItemChannel(_name, _sound.play(0, 0, new SoundTransform(0)), loops, new SoundTransform(volume));
					try
					{
						TweenLite.to(sic.channel, fadeTime, {volume:sic.soundTransform.volume});
					}
					catch(err:Error)
					{
						sic = new SoundItemChannel(_name, _sound.play(0, 0, new SoundTransform(volume)), loops, new SoundTransform(volume));
					}
				}
				else
				{
					sic = new SoundItemChannel(_name, _sound.play(0, 0, new SoundTransform(volume)), loops, new SoundTransform(volume));
				}
			}
			sic.channel.addEventListener(Event.SOUND_COMPLETE, onSoundComplete);
			_chanelsList.push(sic);
		}
		
//--------------------------------------------------------------------------------------------------------
// 	MUTE - UNMUTE METHODS
//--------------------------------------------------------------------------------------------------------
		
		/**
		 * Mutes all sound instances.
		 * 
		 * @param fadeTime Time for fading
		 */ 
		public function mute(fadeTime:Number):void
		{
			_isMuted = true;
			for each(var sic:SoundItemChannel in _chanelsList)
			{
				TweenLite.killTweensOf(sic.channel); // just in case tween is running
				TweenLite.to(sic.channel, fadeTime, {volume:0});
			}
		}
		
		/**
		 * Unmutes all sound instances to the associated volume.
		 * 
		 * @param fadeTime Time for fading
		 */ 
		public function unmute(fadeTime:Number):void
		{
			_isMuted = false;
			for each(var sic:SoundItemChannel in _chanelsList)
			{
				TweenLite.to(sic.channel, fadeTime, {volume:sic.soundTransform.volume});
			}
		}
		
//--------------------------------------------------------------------------------------------------------
// PAUSE - RESUME METHODS
//--------------------------------------------------------------------------------------------------------
		
		/**
		 * Pauses all sound instances.
		 * 
		 * @param fadeDuration The fade duration (0 = no fade).
		 */ 
		public function pause(fadeDuration:Number):void
		{
			for each(var sic:SoundItemChannel in _chanelsList)
			{
				sic.channel.removeEventListener(Event.SOUND_COMPLETE,onSoundComplete);
				if( fadeDuration > 0)
				{
					TweenLite.to(sic.channel, fadeDuration, {volume:0, onComplete:sic.pause});
				}
				else
				{
					sic.pause();
				}
			}
		}
		
		/**
		 * Resumes all sound instances.
		 * 
		 * @param fadeDuration The fade duration (0 = no fade).
		 */ 
		public function resume(fadeDuration:Number):void
		{
			pause(0);
			for each(var sic:SoundItemChannel in _chanelsList)
			{
				if( fadeDuration > 0)
				{
					sic.resume(_sound.play(sic.position, 0, new SoundTransform(0)));
					TweenLite.to(sic.channel, fadeDuration, {volume:sic.soundTransform.volume});
				}
				else
				{
					sic.resume(_sound.play(sic.position, 0, sic.soundTransform));
				}
				sic.channel.addEventListener(Event.SOUND_COMPLETE, onSoundComplete);
			}
		}
		
		/**
		 * Stops all sound instances.
		 * 
		 * @param fadeTime Time for fading (0 = no fade)
		 */ 
		public function stop(fadeDuration:Number = 0):void
		{
			for each(var sic:SoundItemChannel in _chanelsList)
			{
				sic.channel.removeEventListener(Event.SOUND_COMPLETE, onSoundComplete);
				if( fadeDuration > 0)
				{
					TweenLite.to(sic.channel, fadeDuration, {volume:0, onComplete:function():void{ sic.stop(); sic = null; }});
				}
				else
				{
					sic.stop();
					sic = null;
				}
			}
			_chanelsList = [];	
		}
		
//--------------------------------------------------------------------------------------------------------
// EVENT HANDLERS
//--------------------------------------------------------------------------------------------------------
		
		/**
		 * 
		 */ 
		private function onSoundComplete(evt:Event):void
		{
			//log("SoundComplete");
			var sic:SoundItemChannel = getSoundItemChannel(evt.target as SoundChannel);
			
			//TODO Checker ici, probleme de sic null
			if(!sic)
				return;
			
			sic.channel.removeEventListener(Event.SOUND_COMPLETE, onSoundComplete);
			
			
			
			if( sic.loops == -1 || sic.loops != 0 )
			{
				if( sic.loops != -1 )
					sic.loops--;
				
				//Continue looping
				if(_isMuted)
					sic.channel = _sound.play(0, 0, new SoundTransform(0));
				else
					sic.channel = _sound.play(0, 0, sic.soundTransform);
				sic.channel.addEventListener(Event.SOUND_COMPLETE, onSoundComplete);
			}
			else
			{
				_chanelsList.splice(_chanelsList.indexOf(sic,1));
				//TODO Dispatch event complete (sic.dispatchEvent...)
			}
			sic = null;
		}
		
		private function fadeComplete(stopOnComplete:Boolean):void
		{
			if (stopOnComplete) 
				stop();
		}
		
		private function getSoundItemChannel(soundChannel:SoundChannel):SoundItemChannel
		{
			for each(var sic:SoundItemChannel in _chanelsList)
			{
				if(sic.channel == soundChannel)
					return sic;
			}
			return null;
		}
		
//--------------------------------------------------------------------------------------------------------
// Get - Set
//--------------------------------------------------------------------------------------------------------
		
		public function get sound():Sound { return _sound; }
		public function set sound(val:Sound):void { _sound = val; }
		public function get name():String { return _name; }
		public function set isMuted(val:Boolean):void { _isMuted = val; }
		
	}
}