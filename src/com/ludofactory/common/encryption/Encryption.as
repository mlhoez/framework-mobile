/*
Copyright © 2006-2014 Ludo Factory
Framework mobile
Author  : Olivier Chevarin - Maxime Lhoez
Created : 11 déc. 2012
*/
package com.ludofactory.common.encryption
{
	import com.hurlant.crypto.symmetric.DESKey;
	import com.hurlant.crypto.symmetric.ECBMode;
	import com.hurlant.crypto.symmetric.PKCS5;
	import com.hurlant.util.Hex;
	
	import flash.utils.ByteArray;
	
	/**
	 * Encryption class.
	 * 
	 * <p>The process have been highly simplified in order to
	 * avoid at maximum new instanciations. Now we use only one
	 * pad and one mode for each encryption / decryption. In case
	 * of a dynamic encryption (so when the key is ofeten updated
	 * just like in the NetConnectionManager), a new DESKey is
	 * recreated each time so that the encryption is valid.</p>
	 * 
	 * <p>Below is the old version for reference :
	 * 
	 * private var _type:String='simple-des-ecb';
	 * 
	 * Within each function (encryption / decryption) we had :
	 * var pad:IPad = new PKCS5();
	 * var mode:ICipher = Crypto.getCipher(_type, key, pad); // ECBMode
	 * </p>
	 * 
	 */	
	public class Encryption 
	{
		/**
		 * Available characters for the encryption key generation. */		
		private var _possibleCharacters:String;
		/**
		 * The length of the available characters (for optimization). */		
		private var _possibleCharactersLength:int;
		
		/**
		 * The current encryption key. */		
        private var key:ByteArray;
		public var KK:String;
		
		private var _pad:PKCS5;
		private var _mode:ECBMode;

		public function Encryption(k:String = ""):void 
		{
			KK = k;
			key = Hex.toArray(Hex.fromString(k)); // can only be 8 characters long
			
			_possibleCharacters = "abcdefghijklmnopqrstuvwxyzABDEFCDEFGHIJKMNPQRSTUVWXY0123456789";
			_possibleCharactersLength = _possibleCharacters.length;
			
			_pad = new PKCS5();
			_mode = new ECBMode(new DESKey(key), _pad);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Encryption
		
		/**
		 * Encrypts a String.
		 * 
		 * <p>This function creates a ByteArray from the string, whose
		 * content will be encrypted, and then returns a Base64 encoded
		 * string of the encrypted ByteArray.</p>
		 * 
		 * @param value The String to encrypt.
		 * @return The encrypted value.
		 */		
		public function encrypt(value:String = ""):String
		{
			var data:ByteArray = Hex.toArray(Hex.fromString(value));
			_pad.setBlockSize(_mode.getBlockSize());
			_mode.encrypt(data);
			return Base64.encodeByteArray(data);
		}
		
		/**
		 * Encrypts a ByteArray.
		 * 
		 * <p>This function takes the ByteArray and encrypt its content,
		 * then returns a Base64 encoded string of the encrypted ByteArray.</p>
		 * 
		 * @param value The ByteArray to encrypt.
		 * @return The encrypted value.
		 */		
		public function encryptByteArray(value:ByteArray):String
		{
			_pad.setBlockSize(_mode.getBlockSize());
			_mode.encrypt(value);
			return Base64.encodeByteArray(value);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Decryption
		
		/**
		 * Decrypts a value to a String.
		 * 
		 * @param value The value to decrypt.
		 * @return The decrypted value.
		 */		
		public function decrypt(value:String = ""):String
		{
			var data:ByteArray = Base64.decodeToByteArray(value);
			_pad.setBlockSize(_mode.getBlockSize());
			_mode.decrypt(data);
			return Hex.toString(Hex.fromArray(data));
		}
		
		/**
		 * Decrypts a value to a ByteArray.
		 * 
		 * @param value The value to decrypt.
		 * @return The decrypted ByteArray.
		 */		
		public function decryptToByteArray(value:String = ""):ByteArray
		{
			var data:ByteArray = Base64.decodeToByteArray(value);
			_pad.setBlockSize(_mode.getBlockSize());
			_mode.decrypt(data);
			data.position = 0;
			return data;
		}
		
//------------------------------------------------------------------------------------------------------------
//	Key management
		
		/**
		 * Updates the current encryption key.
		 */		
		public function updateKey(value:String):void 
		{
			KK = value;
			key = Hex.toArray(Hex.fromString(value)); // can only be 8 characters long
			_mode.updateKey(new DESKey(key));
		}
		
		/**
		 * Generates a new encryption key.
		 * 
		 * <p>Note that this WON'T update the current key. Once the new
		 * key is generated, you need to call <code>updateKey</code> in
		 * order to use it for further encryptions.</p>
		 */		
		public function createNewKey():String
		{
			var id:int;
			var pass:String = "";
			for (var i:int = 0; i < 8; i++ )
			{
				id = (Math.random() * _possibleCharactersLength) << 0;
				pass += _possibleCharacters.substr(id, 1);
			}
			return pass;
		}		
	}
}