/*
 * This is a modified version of the PKCS5 class from the AS3 Crypto Library:
 * -> http://code.google.com/p/as3crypto/
 *
 * Modifications : Maxime Lhoez
 * 
 * PKCS5
 * 
 * A padding implementation of PKCS5.
 * Copyright (c) 2007 Henri Torgemane
 * 
 * See LICENSE.txt for full license information.
 */
package com.hurlant.crypto.symmetric
{
	import flash.utils.ByteArray;
	
	public class PKCS5 implements IPad
	{
		private var blockSize:uint;
		
		public function PKCS5(blockSize:uint = 0)
		{
			this.blockSize = blockSize;
		}
		
		public function pad(a:ByteArray):void
		{
			var len:int = a.length;
			var c:uint = blockSize - len%blockSize;
			for (var i:uint = 0; i < c; i++)
			{
				a[len] = c; // add an element to the end of the array
				len++; // thus we need to increase de length manually after
			}
		}
		public function unpad(a:ByteArray):void
		{
			var len:int = a.length;
			var c:uint = len%blockSize;
			if (c != 0) throw new Error("PKCS#5::unpad: ByteArray.length isn't a multiple of the blockSize");
			c = a[len-1];
			var v:uint;
			for (var i:uint = c; i > 0; i--)
			{
				v = a[len-1];
				len--;
				a.length = len;
				if (c != v) throw new Error("PKCS#5:unpad: Invalid padding value. expected [" + c + "], found [" + v + "]");
			}
			// that is all.
		}

		public function setBlockSize(bs:uint):void
		{
			blockSize = bs;
		}
	}
}