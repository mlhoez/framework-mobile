/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 5 oct. 2013
*/
package com.ludofactory.mobile.core.push
{
	public class PushNewCSMessage extends AbstractElementToPush
	{
		/**
		 * The thread id. */		
		private var _threadId:int;
		
		/**
		 * The message. */		
		private var _message:String;
		
		public function PushNewCSMessage(pushType:String = null, threadId:int = -1, message:String = null)
		{
			super(pushType);
			
			if( threadId == -1 && message == null )
				return;
			
			_threadId = threadId;
			_message = message;
		}
		
//------------------------------------------------------------------------------------------------------------
//	Get - Set
		
		// since this class is saved in the EncryptedLocalStore, everything has to be r/w !
		
		public function get threadId():int { return _threadId; }
		public function set threadId(val:int):void { _threadId = val; }
		
		public function get message():String { return _message; }
		public function set message(val:String):void { _message = val; }
	}
}