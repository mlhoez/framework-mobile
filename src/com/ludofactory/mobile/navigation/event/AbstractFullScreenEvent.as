/**
 * Created by Maxime on 11/09/15.
 */
package com.ludofactory.mobile.navigation.event
{
	
	import com.ludofactory.common.utils.log;
	
	import feathers.core.FeathersControl;
	
	import starling.events.Event;
	
	public class AbstractFullScreenEvent extends FeathersControl
	{
		public function AbstractFullScreenEvent()
		{
			super();
		}
		
		public function enableEvent():void
		{
			// msut be overridden in sublcass and don't call super.enableEvent() !
			log("[AbstractFullScreenEvent] WARNING : the 'enableEvent' function have not been overridden in subclass !");
			dispatchEventWith(Event.CLOSE);
		}
	}
}