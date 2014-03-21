package com.ludofactory.mobile.core.controls
{
	import feathers.controls.IScreen;
	import com.ludofactory.mobile.core.model.ScreenData;
	
	public interface IAdvancedScreen extends IScreen
	{
		/**
		 * The screen data
		 */
		function get data():ScreenData;
		
		/**
		 * @private
		 */
		function set data(value:ScreenData):void;
	}
}
