/*
 Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
 Framework mobile
 Author  : Maxime Lhoez
 Created : 28 septembre 2014
*/
package com.ludofactory.mobile.core.notification.content
{
	
	import com.ludofactory.mobile.core.notification.*;
	
	import com.ludofactory.mobile.core.controls.PullToRefreshScrollContainer;
	
	public class AbstractPopupContent extends PullToRefreshScrollContainer
	{
		/**
		 * Can be anything. Is mainly used as a parameter for the callback function when the popup is closed. */
		private var _data:Object = {};
		
		/**
		 * Abstract popup used to display popup content.
		 */
		public function AbstractPopupContent()
		{
			super();
			
			isRefreshable = false;
		}
		
		public function get data():Object
		{
			return _data;
		}

		public function set data(value:Object):void
		{
			_data = value;
		}
		
		protected function close():void
		{
			NotificationPopupManager.closeNotification();
			//dispatchEventWith(LudoEventType.CLOSE_NOTIFICATION, false, data);
		}
	}
}