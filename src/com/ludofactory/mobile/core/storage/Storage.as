/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 7 août 2013
*/
package com.ludofactory.mobile.core.storage
{
	
	import com.ludofactory.common.gettext.LanguageManager;
	import com.ludofactory.common.utils.logs.log;
	import com.ludofactory.common.utils.logs.logWarning;
	import com.ludofactory.mobile.core.AbstractGameInfo;
	import com.ludofactory.mobile.core.remoting.Remote;
	import com.ludofactory.mobile.navigation.achievements.TrophyData;
	import com.ludofactory.mobile.navigation.achievements.TrophyManager;
	import com.ludofactory.mobile.navigation.faq.FaqData;
	import com.ludofactory.mobile.navigation.faq.FaqQuestionAnswerData;
	import com.ludofactory.mobile.navigation.news.NewsData;
	import com.ludofactory.mobile.navigation.settings.LanguageData;
	
	import flash.data.EncryptedLocalStore;
	import flash.net.SharedObject;
	import flash.net.registerClassAlias;
	import flash.utils.Dictionary;
	
	public class Storage
	{
		/**
		 * The singleton. */		
		private static var _instance:Storage;
		/**
		 * The configuration SharedObject. */		
		private var _configurationSharedObject:SharedObject;
			
		public function Storage(sk:SecurityKey)
		{
			registerClassAlias("DictionaryClass", Dictionary);
			registerClassAlias("TrophyDataClass", TrophyData);
			registerClassAlias("FaqDataClass", FaqData);
			registerClassAlias("FaqQuestionAnswerDataClass", FaqQuestionAnswerData);
			registerClassAlias("NewsGameDataClass", NewsData);
			registerClassAlias("LanguageDataClass", LanguageData);
			_configurationSharedObject = SharedObject.getLocal(StorageConfig.GLOBAL_CONFIG_SO_NAME);
		}
			
		/**
		 * Initializes the global storage.
		 * 
		 * <p>If this is the first time the application is launched or if its data have been deleted for some reason
		 * (not enough space on the phone for example), this function will first initialize each core property with a
		 * default  value stored by the StorageConfig class, and then try to retreive the newest configuration from the
		 * server in order to update the internal storage.</p>
		 * 
		 * <p>When the application in launched in debug mode and the property "clear data" is checked, the SharedObject
		 * will be deleted and then recreated here.</p>
		 * 
		 * <p>Because the EncryptedLocalStore's data seems to be persistent even if the application is deleted, we need
		 * to manualy clear its data in this function.</p>
		 */		
		public function initialize():void
		{
			if( !_configurationSharedObject.data.hasOwnProperty( StorageConfig.PROPERTY_FIRST_LAUNCH ) )
			{
				// if this is the first launch, we update the property so that we won't fall back here at each launch
				log("[Storage] This is the first launch of the app.");
				
				// reset the ELS by security
				EncryptedLocalStore.reset();
				// inform the app that it's the first launch
				setProperty(StorageConfig.PROPERTY_FIRST_LAUNCH, true);
				// Set up here all game-specific properties that need to be initialized at first launch
				setProperty(StorageConfig.PROPERTY_TROPHIES, AbstractGameInfo.CUPS);
			}
			
			// fetch newest data from the server
			Remote.getInstance().init(onLoadConfigSuccess, onLoadConfigFailure, onLoadConfigFailure, 5);
		}
		
		/**
		 * Returns Storage instance.
		 */		
		public static function getInstance():Storage
		{			
			if(_instance == null)
				_instance = new Storage( new SecurityKey() );			
			return _instance;
		}
		
//------------------------------------------------------------------------------------------------------------
//	Handlers
		
		/**
		 * The newest version of the data have been fetched from the server. 
		 */		
		private function onLoadConfigSuccess(result:Object):void
		{
			log("[Storage] Server configuration have been successfully loaded.");
			
			// maximum idle time after which we will fetch the data again
			if("maxIdleTime" in result && result.maxIdleTime != null && result.maxIdleTime > 10000) // min 10 sec
				Storage.getInstance().setProperty(StorageConfig.PROPERTY_IDLE_TIME, Number(result.maxIdleTime));
			
			// replace the stored trophies : we replace it because some of them could be removed
			if("tab_trophies" in result && result.tab_trophies != null)
				TrophyManager.getInstance().updateTrophies(result.tab_trophies as Array);
		}
		
		/**
		 * The global configuration could not be loaded from the server.
		 */		
		private function onLoadConfigFailure(error:Object = null):void
		{
			logWarning("[Storage] WARNING : The server configuration could not be loaded.");
		}
		
//------------------------------------------------------------------------------------------------------------
//	Specific updates for the FAQ, VIP, and NEWS
		
		/**
		 * Updates the FAQ.
		 */		
		public function updateFaq(data:Object):void
		{
			var faq:Object = Storage.getInstance().getProperty(StorageConfig.PROPERTY_FAQ);
			faq[LanguageManager.getInstance().lang] = JSON.stringify(data.tabFaq);
			setProperty(StorageConfig.PROPERTY_FAQ, faq);
		}
		
		/**
		 * Updates the NEWS.
		 */		
		public function updateNews(data:Object):void
		{
			var news:Object = getProperty(StorageConfig.PROPERTY_NEWS);
			news[LanguageManager.getInstance().lang] = JSON.stringify(data.tab_actualites);
			setProperty(StorageConfig.PROPERTY_NEWS, news);
		}
		
		/**
		 * Update the Terms And Conditions
		 */		
		public function updateTermsAndConditions(data:Object):void
		{
			var termsAndConditions:Object = getProperty(StorageConfig.PROPERTY_TERMS_AND_CONDITIONS);
			termsAndConditions[LanguageManager.getInstance().lang] = String(data.reglement);
			setProperty(StorageConfig.PROPERTY_TERMS_AND_CONDITIONS, termsAndConditions);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Utils
		
		/**
		 * <strong>[DEBUG ONLY] Beware that this function is intended to be used for debug purposes ONLY !</strong>
		 * 
		 * <p>Clears the storage, forcing the EncryptedLocalStore to be cleared at the same time at next launch.</p>
		 */		
		public function clearStorage():void
		{
			_configurationSharedObject.clear();
		}
		
		/**
		 * Updates a property in the configuration SharedObject.
		 * 
		 * @param property The property to update.
		 * @param value The value to assign to the property.
		 */		
		public function setProperty(property:String, value:*):*
		{
			_configurationSharedObject.data[property] = value;
			_configurationSharedObject.flush();
			return value;
		}
		
		/**
		 * Retrieves a property from the configuration SharedObject.
		 * 
		 * @param propertyName Name of the property to retrieve.
		 * 
		 * @return The value assigned to the property given in parameter.
		 */		
		public function getProperty(propertyName:String):*
		{
			if(propertyName in _configurationSharedObject.data && _configurationSharedObject.data[propertyName] != null)
			{
				return _configurationSharedObject.data[propertyName];
			}
			else
			{
				// the property could not be found or is for some reasons null, in this case we need to create
				// this property and assign its default value (the default value is retrieved thanks to the
				// name of the property like this : StorageConfig[propertyName])
				try
				{
					return setProperty(propertyName, StorageConfig[propertyName]);
				} 
				catch(error:Error) 
				{
					return null;
				}
			}
			
			return null;
		}
		
	}
}

internal class SecurityKey{}