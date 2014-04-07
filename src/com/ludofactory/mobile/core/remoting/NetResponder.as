/*
Copyright © 2006-2014 Ludo Factory
Framework mobile
Author  : Olivier Chevarin - Maxime Lhoez
Created : 11 Décembre 2012
*/
package com.ludofactory.mobile.core.remoting
{
	import flash.net.Responder;
	
	/**
	 * Custom responder to match the needs ot the NetConnectionManager.
	 */	
	public class NetResponder extends Responder
	{
		/**
		 * The full command associated to this reponder.
		 * It is only used for debug/logging pruposes. */	
		private var _command:String;
		
		/**
		 * Parameters used in case of a non encrypted communication.
		 * It is an array containing the command to call, the responder
		 * and the parameters. */		
		private var _params:Array;
		/**
		 * Encrypted parameters used in case of an encrypted communication. */		
		private var _encryptedParams:String;
		/**
		 * The new encryption key which is generated when the NetResponder
		 * is created, and used to encrypt the parameters. */		
		private var _dynamicEncryptionKey:String;
		
		/**
		 * Callback in case of success */		
		private var _successCallback:Function;
		/**
		 * Callback in case of failure */		
		private var _failCallback:Function;
		/**
		 * Callback called when the max number of attempts is reached. */		
		private var _maxAttemptsCallback:Function;
		/**
		 * How many attempts maximum can be done. */		
		private var _maxAttempts:int;
		/**
		 * Current number of attempts */		
		private var _numAttempts:int;
		
		/**
		 * The associated screen name */		
		private var _associatedScreenName:String;
		
		public function NetResponder(success:Function, error:Function = null, maxAttempts:int = 1) 
		{
			_maxAttempts = maxAttempts;
			_numAttempts = 0;
			
			super(success, error);
		}
		
		public function set params(val:Array):void { _params = val; }
		public function get params():Array { return _params; }
		
		public function set encryptedParams(val:String):void { _encryptedParams = val; }
		public function get encryptedParams():String { return _encryptedParams; }
		
		public function set dynamicEncryptionKey(val:String):void { _dynamicEncryptionKey = val; }
		public function get dynamicEncryptionKey():String { return _dynamicEncryptionKey; }
		
		public function set command(val:String):void { _command = val; }
		public function get command():String { return _command; }
		
		public function set maxAttempts(val:int):void { _maxAttempts = val; }
		public function get maxAttempts():int { return _maxAttempts; }
		
		public function set numAttempts(val:int):void { _numAttempts = val; }
		public function get numAttempts():int { return _numAttempts; }
		
		public function get maxAttemptsCallback():Function { return _maxAttemptsCallback; }
		public function set maxAttemptsCallback(val:Function):void { _maxAttemptsCallback = val; }
		
		public function get successCallback():Function { return _successCallback; }
		public function set successCallback(val:Function):void { _successCallback = val; }
		
		public function get failCallback():Function { return _failCallback; }
		public function set failCallback(val:Function):void { _failCallback = val; }
		
		public function get associatedScreenName():String { return _associatedScreenName; }
		public function set associatedScreenName(val:String):void { _associatedScreenName = val; }
	}

}