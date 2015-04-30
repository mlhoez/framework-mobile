/*
Copyright © 2006-2015 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 8 sept. 2013
*/
package com.ludofactory.common.utils
{
	import com.ludofactory.mobile.core.config.GlobalConfig;
	
	/**
	 * Scales to the current dpi value and round the result to avoid
	 * blury effects when positioning objects with this function.
	 * 
	 * <p>Note that << 0 will always round the value of the parameter down
	 * to the nearest integer. In this case, for some devices it could
	 * cause some errors when creating Quads for stripes, because the dpiScale
	 * was less than 0.5, to the rounded result was 0 which is not an allowed
	 * size for a Quad creation.</p>
	 */	
	public function scaleAndRoundToDpi(value:Number):int
	{
		// Round DOWN to nearest - equals Math.floor(value)
		//return (value * GlobalConfig.dpiScale) << 0;
		
		// round UP to nearest - equals Math.ceil(value)
		return ((value * GlobalConfig.dpiScale) + 1) << 0;
	}
}