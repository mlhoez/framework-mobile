/**
 * Created by Max on 28/09/2014.
 */
package com.ludofactory.mobile.core.notification
{

	import feathers.controls.ScrollContainer;

	public class AbstractNotificationPopupContent extends ScrollContainer
	{
		/**
		 * Can be anything. Is mainly used as a parameter for the callback
		 * function when the NotificationPopup is closed. */
		private var _data:Object = {};
		
		public function AbstractNotificationPopupContent()
		{
			super();
		}


		public function get data():Object
		{
			return _data;
		}

		public function set data(value:Object):void
		{
			_data = value;
		}
	}
}