/*
LudoFactory
Framework mobile
Author  : Maxime Lhoez
Created : 8 sept. 2013
*/
package com.ludofactory.common.utils
{
	import com.ludofactory.mobile.core.test.config.GlobalConfig;
	
	/**
	 * Scales to the current dpi value and round the result to avoid
	 * blury effects when positioning objects with this function.
	 * 
	 * Note that << 0 will always round the value of the parameter down
	 * to the nearest integer.
	 */	
	public function scaleAndRoundToDpi(value:Number):int
	{
		return (value * GlobalConfig.dpiScale) << 0;
	}
}