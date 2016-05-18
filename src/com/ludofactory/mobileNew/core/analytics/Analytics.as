/**
 * Created by Maxime on 21/04/2016.
 */
package com.ludofactory.mobileNew.core.analytics
{
	
	import com.ludofactory.common.utils.logs.logWarning;
	import com.ludofactory.mobile.core.AbstractGameInfo;
	import com.ludofactory.mobile.core.manager.MemberManager;
	import com.milkmangames.nativeextensions.GAnalytics;
	
	/**
	 * Analytics
	 */
	public class Analytics
	{
		private static var _isInitialized:Boolean = false;
		
		private static function initialize():void
		{
			if(!_isInitialized)
			{
				// initialize Google Analytics tracker
				if( GAnalytics.isSupported() )
				{
					GAnalytics.create(AbstractGameInfo.GOOGLE_ANALYTICS_TRACKER);
					GAnalytics.analytics.defaultTracker.setAdvertisingIdCollectionEnabled(true);
					logWarning("Install Referrer is : " + GAnalytics.analytics.getInstallReferrer());
				}
				
				_isInitialized = true;
			}
		}
		
		/**
		 * Tracks a screen view.
		 */
		public static function trackScreen(screenName:String):void
		{
			initialize();
			if(GAnalytics.isSupported())
				GAnalytics.analytics.defaultTracker.trackScreenView(screenName, MemberManager.getInstance().id);
		}
		
		/**
		 * Tracks an event.
		 */
		public static function trackEvent(title:String, description:String):void
		{
			initialize();
			if(GAnalytics.isSupported())
				GAnalytics.analytics.defaultTracker.trackEvent(title, description, null, NaN, MemberManager.getInstance().id);
		}
		
		/**
		 * Tracks an exception.
		 */
		public static function trackError(errorDescription:String):void
		{
			initialize();
			if(GAnalytics.isSupported())
				GAnalytics.analytics.defaultTracker.trackException(errorDescription, false, MemberManager.getInstance().id);
		}
		
	}
}