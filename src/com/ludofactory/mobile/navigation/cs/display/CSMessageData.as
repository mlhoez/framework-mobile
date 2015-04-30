/*
Copyright © 2006-2014 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 25 août 2013
*/
package com.ludofactory.mobile.navigation.cs.display
{
	/**
	 * Object used in the CSMessagesContainer by each CSMessageItemRenderer
	 * to display a list of customer services threads.
	 */		
	public class CSMessageData
	{
		/**
		 * The thread id */		
		private var _id:int;
		
		/**
		 * The thread creation date. */		
		private var _date:String;
		
		/**
		 * Determines if the thread have been read or not :
		 * 0 if not read, 1 otherwise. */		
		private var _read:Boolean;
		
		/**
		 * The preview of the last message sent (only 75 chars). */
		private var _title:String;
		
		/**
		 * The preview of the last message sent (only 75 chars). */		
		private var _message:String;
		
		/**
		 * State of the message. Whether a pending or a solved one. 
		 * @see com.ludofactory.mobile.features.customerservice.CSState */		
		private var _state:int;
		
		public function CSMessageData(data:Object, state:int)
		{
			_id = data.id;
			_date = data.date;
			_read = data.lu == 0 ? false:true;
			_title = data.titre;
			_message = data.msg;
			_state = state;
		}
		
		public function get id():int { return _id; }
		public function get date():String { return _date; }
		public function get read():Boolean { return _read; }
		public function get title():String { return _title; }
		public function get message():String { return _message; }
		public function get state():int { return _state; }
	}
}