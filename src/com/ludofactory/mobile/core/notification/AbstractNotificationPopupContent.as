/**
 * Created by Max on 28/09/2014.
 */
package com.ludofactory.mobile.core.notification
{

	import com.ludofactory.mobile.core.controls.PullToRefreshScrollContainer;
	import com.ludofactory.mobile.core.events.MobileEventTypes;

	public class AbstractNotificationPopupContent extends PullToRefreshScrollContainer
	{
		/**
		 * Can be anything. Is mainly used as a parameter for the callback
		 * function when the NotificationPopup is closed. */
		private var _data:Object = {};
		
		public function AbstractNotificationPopupContent()
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