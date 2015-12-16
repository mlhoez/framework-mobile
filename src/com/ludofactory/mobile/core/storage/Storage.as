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
	import com.ludofactory.mobile.core.AbstractGameInfo;
	import com.ludofactory.mobile.core.manager.MemberManager;
	import com.ludofactory.mobile.core.remoting.Remote;
	import com.ludofactory.mobile.core.scoring.ScoreToPointsData;
	import com.ludofactory.mobile.core.scoring.ScoreToStarsData;
	import com.ludofactory.mobile.navigation.achievements.TrophyData;
	import com.ludofactory.mobile.navigation.achievements.TrophyManager;
	import com.ludofactory.mobile.navigation.cs.CSThemeData;
	import com.ludofactory.mobile.navigation.faq.FaqData;
	import com.ludofactory.mobile.navigation.faq.FaqQuestionAnswerData;
	import com.ludofactory.mobile.navigation.news.NewsData;
	import com.ludofactory.mobile.navigation.settings.LanguageData;
	import com.ludofactory.mobile.navigation.vip.VipData;
	import com.ludofactory.mobile.navigation.vip.VipPrivilegeData;
	
	import flash.data.EncryptedLocalStore;
	import flash.net.SharedObject;
	import flash.net.registerClassAlias;
	import flash.utils.Dictionary;
	
	public class Storage
	{
		/**
		 * Thr singleton. */		
		private static var _instance:Storage;
		
		/**
		 * The SharedObject of configuration */		
		private var _configurationSharedObject:SharedObject;
			
		public function Storage(sk:SecurityKey)
		{
			// TODO Si la version actuelle est supériure à l'ancienne version, faire un
			// reset du storage pour récupérer les bonnes valeurs ?
			
			registerClassAlias("DictionaryClass", Dictionary);
			registerClassAlias("ScoreToPointsDataClass", ScoreToPointsData);
			registerClassAlias("ScoreToStarsDataClass", ScoreToStarsData);
			registerClassAlias("CSThemeDataClass", CSThemeData);
			registerClassAlias("TrophyDataClass", TrophyData);
			registerClassAlias("FaqDataClass", FaqData);
			registerClassAlias("FaqQuestionAnswerDataClass", FaqQuestionAnswerData);
			registerClassAlias("VipDataClass", VipData);
			registerClassAlias("VipPrivilegeDataClass", VipPrivilegeData);
			registerClassAlias("NewsGameDataClass", NewsData);
			registerClassAlias("LanguageDataClass", LanguageData);
			_configurationSharedObject = SharedObject.getLocal( StorageConfig.GLOBAL_CONFIG_SO_NAME );
		}
			
		/**
		 * Initializes the global storage.
		 * 
		 * <p>If this is the first time the application is launched or if its data
		 * have been deleted for some reason, this function will first initialize
		 * each property with a default value stored by the StorageConfig class, and
		 * then try to retreive the newest configuration from the server in order
		 * to update the internal storage.</p>
		 * 
		 * <p>When the application in launched in debug mode and the property "clear
		 * data" is checked, the SharedObject will be deleted and then recreated here.</p>
		 * 
		 * <p>Because the EncryptedLocalStore's data seems to be persistent even if the
		 * application is deleted, we need to manualy clear its data in this function.</p>
		 */		
		public function initialize():void
		{
			if( !_configurationSharedObject.data.hasOwnProperty( StorageConfig.PROPERTY_FIRST_LAUNCH ) )
			{
				// if this is the first launch, we update the property so that we won't
				// get here at each launch., all other properties will be initialized the
				// first time they are used.
				
				log("[Storage] This is the first launch of the app.");
				EncryptedLocalStore.reset();
				
				// inform the app that it's the first launch
				setProperty(StorageConfig.PROPERTY_FIRST_LAUNCH, true);
				
				// /!\ Set up here all game-specific properties that need to be initialized at first launch, like cups
				// set up trophies
				setProperty(StorageConfig.PROPERTY_TROPHIES, AbstractGameInfo.CUPS);
			}
			
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
//------------------------------------------------------------------------------------------------------------
		
		/**
		 * The global configuration have been returned. This includes : translations
		 * updates, score-to-points table, score-to-stars table.
		 * 
		 * @param result
		 * 
		 */		
		private function onLoadConfigSuccess(result:Object):void
		{
			if( result.hasOwnProperty( "maxIdleTime" ) && result.maxIdleTime != null && result.maxIdleTime > 10000 ) // min 10 sec
				Storage.getInstance().setProperty(StorageConfig.PROPERTY_IDLE_TIME, Number(result.maxIdleTime));
			
			if( result.hasOwnProperty( "correspondance_score" ) && result.correspondance_score != null )
			{
				var arr:Array;
				var row:Object;
				if( result.correspondance_score.hasOwnProperty( "points" ) && result.correspondance_score.points != null )
				{
					// parse points table
					arr = [];
					for each(row in result.correspondance_score.points)
					{
						row.coef = result.correspondance_score.coef;
						arr.push( new ScoreToPointsData( row ) );
					}
					setProperty(StorageConfig.PROPERTY_POINTS_TABLE, arr);
					setProperty(StorageConfig.PROPERTY_COEF, result.correspondance_score.coef as Array);
				}
				
				if( result.correspondance_score.hasOwnProperty( "items" ) && result.correspondance_score.items != null )
				{
					// parse stars table
					arr = [];
					for each(row in result.correspondance_score.items)
						arr.push( new ScoreToStarsData( row ) );
					setProperty(StorageConfig.PROPERTY_STARS_TABLE, arr);
				}
			}
			
			// parse costs to play
			if( result.hasOwnProperty("participation") && result.participation != null )
			{
				if( result.participation.hasOwnProperty("solo") && result.participation.solo != null )
				{
					if( result.participation.solo.hasOwnProperty("credits") && result.participation.solo.credits != null )
						setProperty(StorageConfig.PROPERTY_NUM_CREDITS_IN_FREE_MODE, int(result.participation.solo.credits));
					
					if( result.participation.solo.hasOwnProperty("jetons") && result.participation.solo.jetons != null )
						setProperty(StorageConfig.NUM_TOKENS_IN_SOLO_MODE, int(result.participation.solo.jetons));
				}
				
				if( result.participation.hasOwnProperty("tournoi") && result.participation.tournoi != null )
				{
					if( result.participation.tournoi.hasOwnProperty("credits") && result.participation.tournoi.credits != null )
						setProperty(StorageConfig.PROPERTY_NUM_CREDITS_IN_TOURNAMENT_MODE, int(result.participation.tournoi.credits));
					
					if( result.participation.tournoi.hasOwnProperty("points") && result.participation.tournoi.points != null )
						setProperty(StorageConfig.PROPERTY_NUM_POINTS_IN_TOURNAMENT_MODE, int(result.participation.tournoi.points));
					
					if( result.participation.tournoi.hasOwnProperty("jetons") && result.participation.tournoi.jetons != null )
						setProperty(StorageConfig.NUM_TOKENS_IN_TOURNAMENT_MODE, int(result.participation.tournoi.jetons));
				}
			}
			
			// replace the stored trophies : we must replace it and not simply update because we may need to remove
			// some trophies at some time
			if( result.hasOwnProperty("tab_trophies") && result.tab_trophies != null )
				TrophyManager.getInstance().updateTrophies(result.tab_trophies as Array);
			
			// parse skip how to win gifts screen value
			if( result.hasOwnProperty("param_affichage") )
			{
				if( result.param_affichage.hasOwnProperty( "afficher_publicite" ) && result.param_affichage.afficher_publicite != null )
					setProperty(StorageConfig.PROPERTY_DISPLAY_ADS, int(result.param_affichage.afficher_publicite) == 1);
			}
			
			// social
			if("facebookConnectReward" in result)
			{
				// retrieve and update the facebook connect reward
				setProperty(StorageConfig.PROPERTY_FACEBOOK_CONNECT_REWARD, result.facebookConnectReward);
			}
			
			if("facebookPublishReward" in result)
			{
				// retrieve and update the facebook publish reward
				setProperty(StorageConfig.PROPERTY_FACEBOOK_SHARE_REWARD, result.facebookPublishReward);
			}
			
			log("[Storage] Server configuration have been successfully loaded.");
			
			/*if( AbstractEntryPoint.screenNavigator && AbstractEntryPoint.screenNavigator.activeScreen is HomeScreen )
				HomeScreen(AbstractEntryPoint.screenNavigator.activeScreen).updateInterface();*/
		}
		
		/**
		 * The global configuration could not be loaded from the server.
		 */		
		private function onLoadConfigFailure(error:Object = null):void
		{
			log("[Storage] WARNING : The global configuration could not be loaded from the server.");
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
		 * Updates the VIP.
		 */		
		public function updateVip(data:Object):void
		{
			var vip:Object = Storage.getInstance().getProperty(StorageConfig.PROPERTY_VIP);
			vip[LanguageManager.getInstance().lang] = JSON.stringify(data.tab_vip as Array);
			setProperty(StorageConfig.PROPERTY_VIP, vip);
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
		 * <strong>[DEBUG ONLY]</strong>
		 * 
		 * <strong><p>Beware that this function is intended to be used
		 * for debug purposes ONLY !</p></strong>
		 * 
		 * <p>Clears the storage, forcing the EncryptedLocalStore to be
		 * cleared at the same time at next launch.</p>
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
		 * 
		 * @see 
		 */		
		public function setProperty(property:String, value:*):*
		{
			_configurationSharedObject.data[property] = value;
			_configurationSharedObject.flush();
			return value;
		}
		
		/**
		 * Retrieve a property from the configuration SharedObject.
		 * 
		 * @param propertyName Name of the property to retrieve.
		 * 
		 * @return The value assigned to the property given in parameter.
		 */		
		public function getProperty(propertyName:String):*
		{
			if( propertyName in _configurationSharedObject.data && _configurationSharedObject.data[propertyName] != null )
			{
				// FIXME This is a temporary hack in order to change the value of the number
				// of tokens required to play in tournament when the rank is equal or greater
				// than the rank 2 (which is : ...).
				if( propertyName == StorageConfig.NUM_TOKENS_IN_TOURNAMENT_MODE && MemberManager.getInstance().rank >= 2)
					return int(_configurationSharedObject.data[propertyName]) - 10; // -10 jetons si le grade est ok
				else
					return _configurationSharedObject.data[propertyName];
			}
			else
			{
				// the property could not be found or is for some reasons null
				// in this case we need to create this property and assign its
				// default value (the default value is retrieved thanks to the
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

internal class SecurityKey{};