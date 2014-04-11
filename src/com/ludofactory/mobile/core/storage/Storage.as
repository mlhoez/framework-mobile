/*
Copyright © 2006-2014 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 7 août 2013
*/
package com.ludofactory.mobile.core.storage
{
	import com.ludofactory.common.utils.log;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.Localizer;
	import com.ludofactory.mobile.core.authentication.MemberManager;
	import com.ludofactory.mobile.core.remoting.Remote;
	import com.ludofactory.mobile.core.scoring.ScoreToPointsData;
	import com.ludofactory.mobile.core.scoring.ScoreToStarsData;
	import com.ludofactory.mobile.core.test.achievements.TrophyData;
	import com.ludofactory.mobile.core.test.cs.CSThemeData;
	import com.ludofactory.mobile.core.test.faq.FaqData;
	import com.ludofactory.mobile.core.test.faq.FaqQuestionAnswerData;
	import com.ludofactory.mobile.core.test.home.HomeScreen;
	import com.ludofactory.mobile.core.test.news.NewsData;
	import com.ludofactory.mobile.core.test.settings.LanguageData;
	import com.ludofactory.mobile.core.test.vip.VipData;
	import com.ludofactory.mobile.core.test.vip.VipPrivilegeData;
	
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
				setProperty(StorageConfig.PROPERTY_FIRST_LAUNCH, true);
			}
			
			Localizer.getInstance();
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
			// parse languages
			if( result.hasOwnProperty( "langues" ) && result.langues != null )
				Localizer.getInstance().updateTranslations( result.langues );
			
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
				
				if( result.correspondance_score.hasOwnProperty( "etoiles" ) && result.correspondance_score.etoiles != null )
				{
					// parse stars table
					arr = [];
					for each(row in result.correspondance_score.etoiles)
						arr.push( new ScoreToStarsData( row ) );
					setProperty(StorageConfig.PROPERTY_STARS_TABLE, arr);
				}
			}
			
			// parse costs to play
			if( result.hasOwnProperty("participation") && result.participation != null )
			{
				if( result.participation.hasOwnProperty("libre") && result.participation.libre != null )
				{
					if( result.participation.libre.hasOwnProperty("credits") && result.participation.libre.credits != null )
						setProperty(StorageConfig.PROPERTY_NUM_CREDITS_IN_FREE_MODE, int(result.participation.libre.credits));
					
					if( result.participation.libre.hasOwnProperty("gratuit") && result.participation.libre.gratuit != null )
						setProperty(StorageConfig.PROPERTY_NUM_FREE_IN_FREE_MODE, int(result.participation.libre.gratuit));
				}
				
				if( result.participation.hasOwnProperty("tournoi") && result.participation.tournoi != null )
				{
					if( result.participation.tournoi.hasOwnProperty("credits") && result.participation.tournoi.credits != null )
						setProperty(StorageConfig.PROPERTY_NUM_CREDITS_IN_TOURNAMENT_MODE, int(result.participation.tournoi.credits));
					
					if( result.participation.tournoi.hasOwnProperty("points") && result.participation.tournoi.points != null )
						setProperty(StorageConfig.PROPERTY_NUM_POINTS_IN_TOURNAMENT_MODE, int(result.participation.tournoi.points));
					
					if( result.participation.tournoi.hasOwnProperty("gratuit") && result.participation.tournoi.gratuit != null )
						setProperty(StorageConfig.PROPERTY_NUM_FREE_IN_TOURNAMENT_MODE, int(result.participation.tournoi.gratuit));
				}
			}
			
			// parse skip how to win gifts screen value
			if( result.hasOwnProperty("param_affichage") )
			{
				if( result.param_affichage.hasOwnProperty( "afficher_gagner_cadeaux" ) && result.param_affichage.afficher_gagner_cadeaux != null )
					setProperty(StorageConfig.PROPERTY_DISPLAY_HOW_TO_WIN_GIFTS_SCREEN, int(result.param_affichage.afficher_gagner_cadeaux) == 1 ? true : false);
				
				if( result.param_affichage.hasOwnProperty( "afficher_publicite" ) && result.param_affichage.afficher_publicite != null )
					setProperty(StorageConfig.PROPERTY_DISPLAY_ADS, int(result.param_affichage.afficher_publicite) == 1 ? true : false);
				
				if( result.param_affichage.hasOwnProperty( "afficher_vip_cheque" ) && result.param_affichage.afficher_vip_cheque != null )
					setProperty(StorageConfig.PROPERTY_DISPLAY_VIP_CHEQUE, int(result.param_affichage.afficher_vip_cheque) == 1 ? true : false);
				
				if( result.param_affichage.hasOwnProperty("afficher_boutique") && result.param_affichage.afficher_boutique != null )
					setProperty(StorageConfig.PROPERTY_SHOP_ENABLED, int(result.param_affichage.afficher_boutique) == 1 ? true : false);
			}
			
			log("[Storage] Server configuration have been successfully loaded.");
			
			if( AbstractEntryPoint.screenNavigator && AbstractEntryPoint.screenNavigator.activeScreen is HomeScreen )
				HomeScreen(AbstractEntryPoint.screenNavigator.activeScreen).updateInterface();
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
			faq[Localizer.getInstance().lang] = JSON.stringify(data.tabFaq);
			Localizer.getInstance().setFaqVersion(int(data.version));
			Storage.getInstance().setProperty(StorageConfig.PROPERTY_FAQ, faq);
		}
		
		/**
		 * Updates the VIP.
		 */		
		public function updateVip(data:Object):void
		{
			var vip:Object = Storage.getInstance().getProperty(StorageConfig.PROPERTY_VIP);
			vip[Localizer.getInstance().lang] = JSON.stringify(data.tab_vip as Array);
			Localizer.getInstance().setVipVersion(int(data.version));
			Storage.getInstance().setProperty(StorageConfig.PROPERTY_VIP, vip);
		}
		
		/**
		 * Updates the NEWS.
		 */		
		public function updateNews(data:Object):void
		{
			var news:Object = getProperty(StorageConfig.PROPERTY_NEWS);
			news[Localizer.getInstance().lang] = JSON.stringify(data.tab_actualites);
			Localizer.getInstance().setNewsVersion(int(data.version));
			setProperty(StorageConfig.PROPERTY_NEWS, news);
		}
		
		/**
		 * Update the Terms And Conditions
		 */		
		public function updateTermsAndConditions(data:Object):void
		{
			var termsAndConditions:Object = getProperty(StorageConfig.PROPERTY_TERMS_AND_CONDITIONS);
			termsAndConditions[Localizer.getInstance().lang] = String(data.reglement);
			//Localizer.getInstance().setNewsVersion(int(data.version));
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
				// of free games required to play in tournament when the rank is equal or greater
				// than the rank 2 (which is : ...).
				if( propertyName == StorageConfig.PROPERTY_NUM_FREE_IN_TOURNAMENT_MODE && MemberManager.getInstance().getRank() >= 2)
					return int(_configurationSharedObject.data[propertyName]) - 1;
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