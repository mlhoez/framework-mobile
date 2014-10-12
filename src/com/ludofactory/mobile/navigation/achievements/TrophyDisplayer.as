/*
Copyright © 2006-2014 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 4 nov. 2013
*/
package com.ludofactory.mobile.navigation.achievements
{
	import com.greensock.TweenLite;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	
	import starling.core.Starling;
	import starling.events.Event;
	import starling.events.EventDispatcher;

	public class TrophyDisplayer extends EventDispatcher
	{
		/**
		 * Vector of pending trophy messages. */		
		private var _pendingTrophyMessagesData:Vector.<TrophyData>;
		
		/**
		 * The current trophy message. */		
		private var _currentTrophyMessage:TrophyMessage;
		
		/**
		 * Whether a message is currently displaying. */		
		private var _isTrophyMessageDisplaying:Boolean = false;
		
		public function TrophyDisplayer()
		{
			_pendingTrophyMessagesData = new Vector.<TrophyData>();
		}
		
		/**
		 * A trophy was won, let's display a message on the screen.
		 * 
		 * <p>If a message is already displaying, we save the new one
		 * so that it can be displayed right after. This way we don't
		 * have many messages at the same time on the screen.</p>
		 */		
		public function onTrophyWon(trophyData:TrophyData):void
		{
			if( _isTrophyMessageDisplaying )
			{
				_pendingTrophyMessagesData.push(trophyData);
			}
			else
			{
				_isTrophyMessageDisplaying = true;
				
				_currentTrophyMessage = new TrophyMessage( trophyData );
				_currentTrophyMessage.validate();
				_currentTrophyMessage.x = GlobalConfig.stageWidth;
				_currentTrophyMessage.y = scaleAndRoundToDpi(10);
				Starling.current.stage.addChild( _currentTrophyMessage );
				//Starling.current.stage.setChildIndex( _currentTrophyMessage, int.MAX_VALUE );
				
				TweenLite.to(_currentTrophyMessage, 0.75, { delay:0.5, x:(GlobalConfig.stageWidth - _currentTrophyMessage.width) });
				TweenLite.to(_currentTrophyMessage, 0.75, { delay:5, x:GlobalConfig.stageWidth, onComplete:onTrophyDisplayed });
			}
		}
		
		/**
		 * The trophy message have been displayed, now we clear it
		 * and then display another one if there are some messages
		 * pending.
		 */		
		private function onTrophyDisplayed():void
		{
			_isTrophyMessageDisplaying = false;
			
			_currentTrophyMessage.removeFromParent(true);
			_currentTrophyMessage = null;
			
			if( _pendingTrophyMessagesData.length != 0 )
			{
				onTrophyWon( _pendingTrophyMessagesData.shift() );
			}
			else
			{
				dispatchEventWith(Event.COMPLETE);
			}
		}
		
		public function get isTrophyMessageDisplaying():Boolean { return _isTrophyMessageDisplaying; }
	}
}