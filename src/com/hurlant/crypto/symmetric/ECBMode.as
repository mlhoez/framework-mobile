/*
 * This is a modified version of the ECBMode class from the AS3 Crypto Library:
 * -> http://code.google.com/p/as3crypto/
 * 
 * Modifications : Maxime Lhoez
 *
 * ECBMode
 * 
 * An ActionScript 3 implementation of the ECB confidentiality mode
 * Copyright (c) 2007 Henri Torgemane
 * 
 * See LICENSE.txt for full license information.
 */
package com.hurlant.crypto.symmetric
{
	import com.hurlant.util.Memory;
	
	import flash.utils.ByteArray;
	
	/**
	 * ECB mode.
	 * This uses a padding and a symmetric key.
	 * If no padding is given, PKCS#5 is used.
	 */
	public class ECBMode implements IMode, ICipher
	{
		private var key:ISymmetricKey;
		private var padding:IPad;
		
		public function ECBMode(key:ISymmetricKey, padding:IPad = null)
		{
			this.key = key;
			if (padding == null)
			{
				padding = new PKCS5(key.getBlockSize());
			}
			else
			{
				padding.setBlockSize(key.getBlockSize());
			}
			this.padding = padding;
		}
		
		public function getBlockSize():int
		{
			return key.getBlockSize();
		}
		
		public function encrypt(src:ByteArray):void
		{
			padding.pad(src);
			src.position = 0;
			var blockSize:int = key.getBlockSize();
			var tmp:ByteArray = new ByteArray();
			var dst:ByteArray = new ByteArray();
			var len:int = src.length;
			for (var i:int = 0; i < len; i += blockSize)
			{
				tmp.length = 0;
				src.readBytes(tmp, 0, blockSize);
				key.encrypt(tmp);
				dst.writeBytes(tmp);
			}
			src.length = 0;
			src.writeBytes(dst);
		}
		
		public function decrypt(src:ByteArray):void
		{
			src.position = 0;
			var blockSize:int = key.getBlockSize();
			var len:int = src.length;
			
			// sanity check.
			if (len%blockSize!=0) {
				throw new Error("ECB mode cipher length must be a multiple of blocksize "+blockSize);
			}
			
			var tmp:ByteArray = new ByteArray();
			var dst:ByteArray = new ByteArray();
			for (var i:int = 0; i < len; i += blockSize)
			{
				tmp.length=0;
				src.readBytes(tmp, 0, blockSize);
				
				key.decrypt(tmp);
				dst.writeBytes(tmp);
			}
			padding.unpad(dst);
			src.length = 0;
			src.writeBytes(dst);
		}
		
		public function dispose():void
		{
			key.dispose();
			key = null;
			padding = null;
			Memory.gc();
		}
		
		public function updateKey(val:ISymmetricKey):void
		{
			// FIXME Find a way to update the key instead of recreating
			// each time
			this.key.dispose();
			this.key = null;
			this.key = val;
		}
		
		public function toString():String
		{
			return key.toString() + "-ecb";
		}
	}
}