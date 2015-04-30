/*
Copyright © 2006-2015 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 20 nov. 2013
*/
package com.ludofactory.common.sound
{
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	
	public class SoundItemChannel
	{
		/**
		 * The sound name. */		
		private var _name:String;
		/**
		 * The sound channel. */		
		private var _channel:SoundChannel;
		/**
		 * Thr number of loops. */		
		private var _loops:int;
		/**
		 * The current positio when paused. */		
		private var _position:Number;
		/**
		 * The sound transform instance. */		
		private var _soundTransform:SoundTransform;
		
		public function SoundItemChannel(soundName:String, channel:SoundChannel, loops:int, sndTransform:SoundTransform)
		{
			_name = soundName;
			_channel = channel;
			_loops = loops;
			_soundTransform = sndTransform;
		}
		
		/**
		 * Pauses the channel.
		 */		
		public function pause():void
		{
			_position = _channel.position;
			_channel.stop();
		}
		
		/**
		 * Resumes the channel.
		 */		
		public function resume(channel:SoundChannel):void
		{
			_channel = channel;
		}
		
		/**
		 * Stops the channel.
		 */		
		public function stop():void
		{
			_channel.stop();
		}
		
//------------------------------------------------------------------------------------------------------------
//	Get / Set
//------------------------------------------------------------------------------------------------------------
		
		public function get channel():SoundChannel { return _channel; }
		public function set channel(val:SoundChannel):void { _channel = val; }
		public function get loops():int { return _loops; }
		public function set loops(val:int):void { _loops = val; }
		public function get position():Number { return _position; }
		public function get soundTransform():SoundTransform { return _soundTransform; }
	}
}