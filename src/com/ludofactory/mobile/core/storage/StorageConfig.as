/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 7 août 2013
*/
package com.ludofactory.mobile.core.storage
{
	import com.ludofactory.mobile.core.scoring.ScoreToPointsData;
	import com.ludofactory.mobile.core.scoring.ScoreToStarsData;
	import com.ludofactory.mobile.core.storage.defaults.DefaultFaq;
	import com.ludofactory.mobile.core.storage.defaults.DefaultNews;
	import com.ludofactory.mobile.core.storage.defaults.DefaultTermsAndConditions;
	import com.ludofactory.mobile.core.storage.defaults.DefaultVip;
	import com.ludofactory.mobile.navigation.cs.CSThemeData;
	import com.ludofactory.mobile.navigation.settings.LanguageData;
	
	/**
	 * Each property...
	 */	
	public class StorageConfig
	{
		
		/**
		 * This is a global SharedObject (not associated to a user actually
		 * logged in) that will store many different kind of data associated
		 * to the application :
		 * 
		 * <p>Actually, this SharedObject will store :</p>
		 * 
		 * <p><strong>[firstLaunch] - Boolean</strong><br />
		 * Determines if this is the first launch of the application.
		 * Depending on this value, some default values will be set to most of
		 * the properties listed below.
		 * 
		 * <p><strong>[lang] - String</strong><br />
		 * This is the language actually choosed by
		 * the user and that needs to be loaded at launch. If it is the first
		 * time the application is launched, this value will be determined by
		 * the current device language (english by default). After, this value
		 * will be changed by the one choosed by the user in the preferences.</p>
		 * 
		 * <p><strong>[translations] - Dictionnary</strong><br />
		 * This is a Dictionnary containing all the languages actually parsed
		 * (from the files in the "lang/" folder in the application directory).
		 * The content of this property looks like this :<br />
		 * <i>	[fr] = { version:x, translation:dictionnary }</i><br />
		 * <i>	[en] = { version:x, translation:dictionnary }</i><br />
		 * <i>	etc.</i><br />
		 * The value of "translation" is a Dictionnary containing all the
		 * keys and their matching pair, used for translation.<br />
		 * <i>Ex : [COMMON.LOADING] = Loading...</i></p>
		 * 
		 * <p><strong>[pointsTable] - Array</strong><br />
		 * This is an array containing for each level of score (defined by
		 * an inferior and a superior limit) the corresponding value in terms
		 * of points (for both free and paid game sessions).<br />
		 * <i>Ex for one row : { credit:30, gratuit:5, inf:0, sup:500 }</i></p>
		 * 
		 * <p><strong>[starsTable] - Array</strong><br />
		 * This is an array containing for each level of score (defined by
		 * an inferior and a superior limit) the corresponding value in terms
		 * of stars (there is no difference for now whether you play with points,
		 * free or paid game session.<br />
		 * <i>Ex for one row : { items:1, inf:0, sup:250 }</i></p>
		 * 
		 * @see #PROPERTY_FIRST_LAUNCH
		 * 
		 */		
		internal static const GLOBAL_CONFIG_SO_NAME:String = "pyramid_config";
		
	// ----------------------- STAKES
		
		/**
		 * Number of tokens required to play in solo mode. */
		public static const NUM_TOKENS_IN_SOLO_MODE:String = "DEFAULT_NUM_TOKENS_IN_SOLO_MODE";
		public static const DEFAULT_NUM_TOKENS_IN_SOLO_MODE:int = 5;
		/**
		 * Number of credits required to play in solo mode. */
		public static const PROPERTY_NUM_CREDITS_IN_FREE_MODE:String = "DEFAULT_NUM_CREDITS_IN_FREE_MODE";
		public static const DEFAULT_NUM_CREDITS_IN_FREE_MODE:int = 1;
		
		/**
		 * Number of tokens required to play in tournament mode. Without VIP bonus, so 30 instead of 20 (30 -10 VIP). */
		public static const NUM_TOKENS_IN_TOURNAMENT_MODE:String = "DEFAULT_NUM_TOKENS_IN_TOURNAMENT_MODE";
 		public static const DEFAULT_NUM_TOKENS_IN_TOURNAMENT_MODE:int = 30;
		/**
		 * Number of points required to play in tournament mode. */
		public static const PROPERTY_NUM_POINTS_IN_TOURNAMENT_MODE:String = "DEFAULT_NUM_POINTS_IN_TOURNAMENT_MODE";
 		public static const DEFAULT_NUM_POINTS_IN_TOURNAMENT_MODE:int = 2000;
		/**
		 * Number of credits required to play in tournament mode. */
		public static const PROPERTY_NUM_CREDITS_IN_TOURNAMENT_MODE:String = "DEFAULT_NUM_CREDITS_IN_TOURNAMENT_MODE";
 		public static const DEFAULT_NUM_CREDITS_IN_TOURNAMENT_MODE:int = 5;
		
		/**
		 * The number of token allowed to use and that will allow the user to cumulate points when not authenticated. */
 		public static const DEFAULT_NUM_TOKENS_ALLOWED_TO_COUNT_POINTS:int = 100;
		
	// ----------------------- LANGUAGE
		
		/**
		 * Default loaded language. The default value is "unknown" so that the LanguageManager know it has to
		 * parse all available languages from the file system and determine to best one. */
		public static const DEFAULT_LANGUAGE:String = "unknown";
		
	// ----------------------- CONFIG
		
		/**
		 * Idle time after which we relaunch an "init" to keep the app up to date after a long idle time. */
		public static const PROPERTY_IDLE_TIME:String = "DEFAULT_IDLE_TIME";
		public static const DEFAULT_IDLE_TIME:Number = 3600000; // 1 hour by default
		
		/**
		 * The game trophies. It must be configured in the Main class with AbstractGameInfo.CUPS */
		public static const PROPERTY_TROPHIES:String = "DEFAULT_TROPHIES";
		public static const DEFAULT_TROPHIES:Array = []; // no trophies by default, they must be setup in the Main class with AbstractGameInfo.CUPS
		
	// ----------------------- Defaults
		
		/**
		 * The FAQ. */
		public static const PROPERTY_FAQ:String = "DEFAULT_FAQ";
		public static const DEFAULT_FAQ:Object = { fr:DefaultFaq.FR, en:DefaultFaq.EN };
		
		/**
		 * The NEWS. */
		public static const PROPERTY_NEWS:String = "DEFAULT_NEWS";
		public static const DEFAULT_NEWS:Object = { fr:DefaultNews.FR, en:DefaultNews.EN };
		
		/**
		 * The CGU. */
		public static const PROPERTY_TERMS_AND_CONDITIONS:String = "DEFAULT_TERMS_AND_CONDITIONS";
		public static const DEFAULT_TERMS_AND_CONDITIONS:Object = { fr:DefaultTermsAndConditions.FR, en:DefaultTermsAndConditions.EN };
		
		/**
		 * The VIP (must be by default without gifts). */
		public static const PROPERTY_VIP:String = "DEFAULT_VIP";
		public static const DEFAULT_VIP:Object = { fr:DefaultVip.FR, en:DefaultVip.EN };
		
//------------------------------------------------------------------------------------------------------------
//	Configuration default values
		
		/**
		 * <strong>This is the default value for the points table</strong><br />
		 * This is an array containing for each level of score (defined by
		 * an inferior and a superior limit) the corresponding value in terms
		 * of points (for both free and paid game sessions).<br />
		 * <i>Ex for one row : { credit:30, gratuit:5, inf:0, sup:500 }</i></p>
		 */		
		public static const DEFAULT_POINTS_TABLE:Array = [ new ScoreToPointsData( { credit:30,  gratuit:5,  inf:0,     sup:5000,    coef:[5,6] } ),
														   new ScoreToPointsData( { credit:60,  gratuit:10, inf:5001,  sup:10000,   coef:[5,6] } ),
														   new ScoreToPointsData( { credit:120, gratuit:20, inf:10001, sup:20000,   coef:[5,6] } ),
														   new ScoreToPointsData( { credit:180, gratuit:30, inf:20001, sup:30000,   coef:[5,6] } ),
														   new ScoreToPointsData( { credit:240, gratuit:40, inf:30001, sup:8388607, coef:[5,6] } ) ];
		
		/**
		 * <strong>This is the default value for the stars table</strong><br />
		 * This is an array containing for each level of score (defined by
		 * an inferior and a superior limit) the corresponding value in terms
		 * of points (for both free and paid game sessions).<br />
		 * <i>Ex for one row : { items:1, inf:0, sup:250 }</i></p>
		 */	
		public static const DEFAULT_STARS_TABLE:Array = [ new ScoreToStarsData( { items:1,  inf:0,      sup:5000 } ),
														  new ScoreToStarsData( { items:2,  inf:5001,   sup:10000 } ),
														  new ScoreToStarsData( { items:3,  inf:10001,  sup:15000 } ),
														  new ScoreToStarsData( { items:4,  inf:15001,  sup:23000 } ),
														  new ScoreToStarsData( { items:5,  inf:23001,  sup:31000 } ),
														  new ScoreToStarsData( { items:6,  inf:31001,  sup:39000 } ),
														  new ScoreToStarsData( { items:7,  inf:39001,  sup:47000 } ),
														  new ScoreToStarsData( { items:8,  inf:47001,  sup:55000 } ),
														  new ScoreToStarsData( { items:9,  inf:55001,  sup:63000 } ),
														  new ScoreToStarsData( { items:10, inf:63001,  sup:8388607 } ) ];
		
		
		
	
		
		/**
		 * <strong>This is the default value for the customer service themes</strong><br />Theses values are
		 * ordered so that we can change in which index each theme should be placed. Penser à changer en base
		 * T_ServiceClientMobilec si on change une clef ici.
		 * 
		 * // Hack for POEdit
		 * _("Partie Solo");
		 * _("Tournoi");
		 * _("Problème technique");
		 * _("Cadeaux");
		 * _("Mon Compte");
		 * _("Informations");
		 * _("Autre");
		 * 
		 * */	
		public static const DEFAULT_CUSTOMER_SERVICE_THEMES:Array = [ new CSThemeData( { id:1, key:"Partie Solo",        index:1 } ),
																	  new CSThemeData( { id:2, key:"Tournoi",            index:2 } ),
																	  new CSThemeData( { id:3, key:"Problème technique", index:3 } ),
																	  new CSThemeData( { id:4, key:"Cadeaux",            index:4 } ),
																	  new CSThemeData( { id:5, key:"Mon Compte",         index:5 } ),
																	  new CSThemeData( { id:6, key:"Informations",       index:6 } ),
																	  new CSThemeData( { id:7, key:"Autre",              index:7 } ) ];

        /**
         * Different version for the non-gift players
         */
        public static const DEFAULT_CUSTOMER_SERVICE_THEMES_WITHOUT_GIFTS:Array = [ new CSThemeData( { id:1, key:"Partie Solo",        index:1 } ),
                                                                                    new CSThemeData( { id:2, key:"Tournoi",            index:2 } ),
                                                                                    new CSThemeData( { id:3, key:"Problème technique", index:3 } ),
	                                                                                new CSThemeData( { id:5, key:"Mon Compte",         index:5 } ),
                                                                                    new CSThemeData( { id:6, key:"Informations",       index:6 } ),
                                                                                    new CSThemeData( { id:7, key:"Autre",              index:7 } ) ];

		
		
		
		
		
		
		
		
		public static const DEFAULT_SOUND_ENABLED:Boolean = true;
		
		public static const DEFAULT_MUSIC_ENABLED:Boolean = true;
		
		/**
		 * Hack for Poedit
		 * _("Français");
		 * _("Anglais");
		 * 
		 */		
		public static const DEFAULT_AVAILABLE_LANGUAGES:Array = [ new LanguageData( { id:1, key:"fr", translationKey:"Français" } ),
																  new LanguageData( { id:2, key:"en", translationKey:"Anglais" } ) ];
		
		/**
		 * <strong>This is the default value for the push
		 * notification.</strong><br />
		 * The first time the user will change the value in
		 * his account settings, he will be asked in ios if
		 * he wants to receive push from our application.
		 * 
		 * <p>This value will help us to determine if we can
		 * request a token at launch or not.</p> */	
		public static const DEFAULT_PUSH_INITIALIZED:Boolean = false;
		
		/**
		 * 
		 */		
		public static const DEFAULT_DISPLAY_ADS:Boolean = false;
		
		/**
		 * 
		 */		
		public static const DEFAULT_USE_SECURED_CALLS:Boolean = false;
		
		/**
		 * <strong>This is the default value for the sponsor
		 * reward value.</strong><br />
		 * Whether some points or money (ex : "40€" or "100 000").
		 * Default is "100000"
		 */		
		public static const DEFAULT_SPONSOR_REWARD_VALUE:String = "100 000";
		
		/**
		 * <strong>This is the default value for the sponsor
		 * reward type.</strong><br />
		 * 1 = display points
		 * 2 = display currency
		 * Default is 1 
		 */		
		public static const DEFAULT_SPONSOR_REWARD_TYPE:int = 1;
		
		/**
		 * Whether we need todisplay an arrow above the back arrow
		 * the first time the user will see this button. */		
		public static const DEFAULT_NEED_HELP_ARROW:Boolean = true;
		
		
		public static const DEFAULT_COEF:Array = [5, 6];
		
		/**
		 * Whether we need to force the user to update the application. */		
		public static const DEFAULT_FORCE_UPDATE:Boolean = false;
		/**
		 * The link of the application on the store. */		
		public static const DEFAULT_FORCE_UPDATE_LINK:String = "";
		/**
		 * The text to display. */		
		public static const DEFAULT_FORCE_UPDATE_TEXT:String = "";
		/**
		 * The text to display on the button. */
		public static const DEFAULT_FORCE_UPDATE_BUTTON_NAME:String = "";
		/**
		 * The old game version used to check if we can disable
		 * the force update value if it was enabled. */		
		public static const DEFAULT_GAME_VERSION:String = "1.0";
		
		public static const DEFAULT_NEW_LANGUAGES:Array = [];
		
//------------------------------------------------------------------------------------------------------------
// Configuration properties
		
		/**
		 * Determines if this is the first launch of the application. At the
		 * first launch, this property will be added to the SharedObject and
		 * initialized to <code>true</code>, then we initialize all the default
		 * properties needed for the application to work properly.
		 * 
		 * <p>Later, we can check this value so that we know that we don't need
		 * to initialize all the default properties again later.</p>
		 * 
		 * <p>See GLOBAL_CONFIG_SO_NAME for more informations about all the
		 * configuration properties</p>
		 * 
		 * @see #GLOBAL_CONFIG_SO_NAME
		 */		
		public static const PROPERTY_FIRST_LAUNCH:String = "first-launch";
		
		/**
		 * Access the score-to-points correspondance table.
		 */			
		public static const PROPERTY_POINTS_TABLE:String = "DEFAULT_POINTS_TABLE";
		
		/**
		 * Access the score-to-stars correspondance table.
		 */			
		public static const PROPERTY_STARS_TABLE:String = "DEFAULT_STARS_TABLE";
		
		/**
		 * Access the user's preferred language.
		 * 
		 * <p>See the Localizer's language constants for more informations
		 * about which kind of value this property can take.</p>
		 * 
		 * @see com.ludofactory.mobile.core.Localizer
		 */			
		public static const PROPERTY_LANGUAGE:String = "DEFAULT_LANGUAGE";
		
		/**
		 * Access all the loaded languages.
		 * <p>The content of this property looks like this :</p>
		 * <i>	[...]</i><br />
		 * <i>	[fr] = { version:x, translation:dictionnary }</i><br />
		 * <i>	[...]</i>
		 * 
		 * @see com.ludofactory.mobile.core.Localizer
		 */			
		public static const PROPERTY_TRANSLATIONS:String = "translations";
		
		
		
		/**
		 * Access the customer service themes. */		
		public static const PROPERTY_CUSTOMER_SERVICE_THEMES:String = "DEFAULT_CUSTOMER_SERVICE_THEMES";
        /**
		 * Access the customer service themes. */
		public static const PROPERTY_CUSTOMER_SERVICE_THEMES_WITHOUT_GIFTS:String = "DEFAULT_CUSTOMER_SERVICE_THEMES_WITHOUT_GIFTS";
		
		/**
		 * Access the sound. */		
		public static const PROPERTY_SOUND_ENABLED:String = "DEFAULT_SOUND_ENABLED";
		
		/**
		 * Access the music. */		
		public static const PROPERTY_MUSIC_ENABLED:String = "DEFAULT_MUSIC_ENABLED";
		
		/**
		 * Access the available languages. */		
		public static const PROPERTY_AVAILABLE_LANGUAGES:String = "DEFAULT_AVAILABLE_LANGUAGES";
		
		/**
		 * Access the push initialized value. */		
		public static const PROPERTY_PUSH_INITIALIZED:String = "DEFAULT_PUSH_INITIALIZED";
		
		/**
		 * Access the push initialized value. */		
		public static const PROPERTY_DISPLAY_ADS:String = "DEFAULT_DISPLAY_ADS";
		
		/**
		 * Access the push initialized value. */		
		public static const PROPERTY_USE_SECURED_CALLS:String = "DEFAULT_USE_SECURED_CALLS";
		
		/**
		 * Access the sponsor reward value. */		
		public static const PROPERTY_SPONSOR_REWARD_VALUE:String = "DEFAULT_SPONSOR_REWARD_VALUE";
		
		/**
		 * Access the sponsor reward type. */		
		public static const PROPERTY_SPONSOR_REWARD_TYPE:String = "DEFAULT_SPONSOR_REWARD_TYPE";
		
		public static const PROPERTY_NEED_HELP_ARROW:String = "DEFAULT_NEED_HELP_ARROW";
		
		
		public static const PROPERTY_COEF:String = "DEFAULT_COEF";
		
		public static const PROPERTY_FORCE_UPDATE:String = "DEFAULT_FORCE_UPDATE";
		public static const PROPERTY_FORCE_UPDATE_LINK:String = "DEFAULT_FORCE_UPDATE_LINK";
		public static const PROPERTY_FORCE_UPDATE_TEXT:String = "DEFAULT_FORCE_UPDATE_TEXT";
		public static const PROPERTY_FORCE_UPDATE_BUTTON_NAME:String = "DEFAULT_FORCE_UPDATE_BUTTON_NAME";
		public static const PROPERTY_GAME_VERSION:String = "DEFAULT_GAME_VERSION";
		
		public static const PROPERTY_NEW_LANGUAGES:String = "DEFAULT_NEW_LANGUAGES";
		
		
	}
}