/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 22 sept. 2013
*/
package com.ludofactory.mobile.core.purchases
{
	
	import com.amazon.nativeextensions.android.AmazonPurchase;
	import com.amazon.nativeextensions.android.AmazonPurchaseReceipt;
	import com.amazon.nativeextensions.android.events.AmazonPurchaseEvent;
	import com.freshplanet.nativeExtensions.AirNetworkInfo;
	import com.gamua.flox.Flox;
	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.common.utils.logs.log;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.AbstractGameInfo;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.events.MobileEventTypes;
	import com.ludofactory.mobile.core.manager.InfoContent;
	import com.ludofactory.mobile.core.manager.InfoManager;
	import com.ludofactory.mobile.core.manager.MemberManager;
	import com.ludofactory.mobile.core.remoting.Remote;
	import com.ludofactory.mobile.navigation.store.StoreData;
	import com.milkmangames.nativeextensions.android.AndroidIAB;
	import com.milkmangames.nativeextensions.android.AndroidItemDetails;
	import com.milkmangames.nativeextensions.android.events.AndroidBillingErrorEvent;
	import com.milkmangames.nativeextensions.android.events.AndroidBillingErrorID;
	import com.milkmangames.nativeextensions.android.events.AndroidBillingEvent;
	import com.milkmangames.nativeextensions.ios.StoreKit;
	import com.milkmangames.nativeextensions.ios.StoreKit;
	import com.milkmangames.nativeextensions.ios.events.StoreKitErrorEvent;
	import com.milkmangames.nativeextensions.ios.events.StoreKitEvent;
	
	import starling.events.EventDispatcher;
	
	/**
	 * Store that handles In-App Purchases for the Android, Amazon and Apple Store.
	 */	
	public class StoreManager extends EventDispatcher
	{
		/**
		 * MemberManager instance. */
		private static var _instance:StoreManager;
		
		public function StoreManager(sk:SecurityKey)
		{
			if( sk == null)
				throw new Error("[MemberManager] You must call MamberManager.getInstance instead of new.");
		}
		
		private function initialize():void
		{
			
		}
		
//------------------------------------------------------------------------------------------------------------
//	Singleton
		
		/**
		 * Return the MemberManager instance.
		 */
		public static function getInstance():StoreManager
		{
			if(_instance == null)
				_instance = new StoreManager( new SecurityKey() );
			return _instance;
		}
		
	}
}

internal class SecurityKey{}