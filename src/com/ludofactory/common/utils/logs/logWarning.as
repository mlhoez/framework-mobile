/*
 Copyright © 2006-2015 Ludo Factory
 Framework
 Author  : Maxime Lhoez
 Created : 11 déc. 2012
 */
package com.ludofactory.common.utils.logs
{
	
	import com.ludofactory.mobile.core.manager.MemberManager;
	
	/**
	 * Logs an object in the console (similar to print_r in PHP).
	 *
	 * @param property
	 * @param name
	 *
	 * @return String
	 */
	public function logWarning(property:Object, name:String = ""):String
	{
		if (MemberManager.getInstance().isAdmin || CONFIG::DEBUG)
			return Logger.getLog(property, name, Logger.YELLOW, Logger.REGULAR);
		return "";
	}
		
}