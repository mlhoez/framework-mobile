/*
 * This is a modified version of the Memory class from the AS3 Crypto Library:
 * -> http://code.google.com/p/as3crypto/
 * 
 * Modifications : Maxime Lhoez
 *
 * Memory
 * 
 * A class with a few memory-management methods, as much as 
 * such a thing exists in a Flash player.
 * Copyright (c) 2007 Henri Torgemane
 * 
 * See LICENSE.txt for full license information.
 */
package com.hurlant.util
{
	import com.ludofactory.mobile.core.config.GlobalConfig;
	
	import flash.net.LocalConnection;
	import flash.system.System;
	
	public class Memory
	{
		/**
		 * As stated by gskinner in his blog, this hack should never be used
		 * in production, only in developement !
		 * 
		 * See : http://gskinner.com/blog/archives/2006/08/as3_resource_ma_2.html
		 * 
		 */		
		public static function gc():void
		{
			if( CONFIG::DEBUG )
			{
				// force a GC only in debug mode !
				try
				{
				   new LocalConnection().connect('foo');
				   new LocalConnection().connect('foo');
				} catch (e:*) {}
			}
		}
		
		public static function get used():uint
		{
			return System.totalMemory;
		}
	}
}