/**
 * Created by Maxime on 15/12/15.
 */
package com.ludofactory.common.utils
{
	/**
	 * Checks if a property is in an object and non null.
	 * @param name
	 * @param data
	 * @return
	 */
	public function hasProperty(name:String, data:Object):Boolean
	{
		return (data && name in data && data[name] != null);
	}

}