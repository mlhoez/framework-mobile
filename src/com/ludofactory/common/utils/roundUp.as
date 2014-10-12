/*
Copyright © 2006-2014 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 14 août 2014
*/
package com.ludofactory.common.utils
{
	/**
	 * Round up to nearest.
	 */	
	public function roundUp(value:Number):int
	{
		// round UP to nearest - equals Math.ceil(value)
		return (value + 1) << 0;
	}
}