/*
Copyright © 2006-2015 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 14 août 2013
*/
package com.ludofactory.common.utils
{
	import com.ludofactory.mobile.core.HeartBeat;
	
	import feathers.controls.Label;

	public class TextAnimationManager
	{
		static private var _label:Label;
		static private var _scoreToGo:int = 0;
		static private var _currentScore:int;
		public static const BASE_TIME:int = 30;
		private static var _currentTime:int;
		private static var _updateFunction:Function;
		private static var _completeFunction:Function;
		private static var _step:int;
		
		public function TextAnimationManager()
		{
		}
		
		/**
		 * Ajoute une animation de défilement de nombre au textfield passé en paramètre.
		 * 
		 * @param textfield Textfield à modifier.
		 * @param score Score à atteindre.
		 */ 
		static public function addTextNumberAnimation(textfield:Label, score:int, step:int = 1, updateFunction:Function = null, completeFunction:Function = null):void
		{
			stop();
			
			_label = textfield;
			_scoreToGo = score;
			_currentScore = int( _label.text );
			_updateFunction = updateFunction;
			_completeFunction = completeFunction;
			_step = step;
			
			if( _updateFunction )
				_updateFunction( _currentScore );
			
			HeartBeat.getInstance().registerFunction( updateTimer );
		}
		
		private static function updateTimer(elapsedTime:int):void
		{
			_currentTime -= elapsedTime;
			if( _currentTime <= 0)
			{
				increaseScore();
			}
		}
		
		static private function increaseScore():void
		{
			if( !_label )
				return;
			
			_currentTime = BASE_TIME;
			_currentScore += _step;
			_label.text = Utility.splitThousands( _currentScore );
			
			if( _updateFunction )
				_updateFunction(_currentScore);
			
			if(_currentScore >= _scoreToGo)
			{
				_currentScore = _scoreToGo;
				
				_label.text = Utility.splitThousands( _scoreToGo );
				
				onComplete()
			}
		}
		
		private static function onComplete():void
		{
			stop();
			
			if( _completeFunction )
				_completeFunction();
		}
		
		/**
		 * Stop le timer de défilement
		 */ 
		static public function stop():void
		{
			HeartBeat.getInstance().unregisterFunction( updateTimer );
		}
		
		public static function dispose():void
		{
			HeartBeat.getInstance().unregisterFunction( updateTimer );
			_updateFunction = null;
			_completeFunction = null;
			_label = null;
		}
	}
}