/*
Copyright © 2006-2015 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 26 août 2013
*/
package com.ludofactory.mobile.navigation.cs.thread
{
	/**
	 * Object used in the CSThreadScreen by each CSThreadItemRenderer
	 * to display the whole conversation.
	 */		
	public class CSThreadData
	{
		/**
		 * Determines if it's an incoming message or not */		
		private var _incoming:Boolean;
		
		/**
		 * The message id. */		
		private var _messageId:int;
		
		/**
		 * The message. */		
		private var _message:String;
		
		/**
		 * Date when the message was sent. */		
		private var _sendDate:String;
		
		/**
		 * Date when the message was read. */		
		private var _readDate:String;
		
		public function CSThreadData(data:Object)
		{
			_incoming = data.id_admin != 0 ? true:false;
			_messageId = data.id_msg;
			_message = data.msg;
			_sendDate = data.date_envoi;
			_readDate = data.date_lu;
		}
		
		public function get incoming():Boolean { return _incoming; }
		public function get messageId():int { return _messageId; }
		public function get message():String { return _message; }
		public function get sendDate():String { return _sendDate; }
		public function get readDate():String { return _readDate; }
	}
}