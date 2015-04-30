/*
Copyright © 2006-2015 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 1 oct. 2013
*/
package com.ludofactory.mobile.core.push
{
	/**
	 * An abstract element to push. Each element that can be save in the
	 * push manager must extend this class.
	 */	
	public class AbstractElementToPush
	{
		/**
		 * The state of the push, default is "wainting" when the element is created.
		 * 
		 * @see com.ludofactory.mobile.push.PushState */		
		private var _state:String;
		
		/**
		 * The type of the element to push.
		 * 
		 * @see com.ludofactory.mobile.push.PushType */		
		protected var _pushType:String;
		
		/**
		 * Creation date. */		
		protected var _creationDate:Date;
		
		/**
		 * The push success message. */		
		protected var _pushSuccessMessage:String = "";
		
		public function AbstractElementToPush(pushType:String = null)
		{
			if( pushType == null )
				return;
			
			_creationDate = new Date();
			
			_state = PushState.WAITING;
			_pushType = pushType;
		}
		
//------------------------------------------------------------------------------------------------------------
//	Get - Set
		
		// since this class is saved in the EncryptedLocalStore, everything has to be r/w !
		
		public function get creationDate():Date { return _creationDate; }
		public function set creationDate(val:Date):void { _creationDate = val; }
		
		public function get state():String { return _state; }
		public function set state(val:String):void { _state = val; }
		
		public function get pushType():String { return _pushType; }
		public function set pushType(val:String):void { _pushType = val; }
		
		public function get pushSuccessMessage():String { return _pushSuccessMessage; }
		public function set pushSuccessMessage(val:String):void { _pushSuccessMessage = val; }
	}
}