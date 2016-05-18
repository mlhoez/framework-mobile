/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 7 août 2013
*/
package com.ludofactory.mobile.core.storage
{
	
	import com.ludofactory.mobile.core.storage.defaults.DefaultFaq;
	import com.ludofactory.mobile.core.storage.defaults.DefaultNews;
	import com.ludofactory.mobile.core.storage.defaults.DefaultTermsAndConditions;
	import com.ludofactory.mobile.navigation.settings.LanguageData;
	
	/**
	 * Each property...
	 */	
	public class StorageConfig
	{
		
		/**
		 * This is a global SharedObject (not associated to a user actually logged in) that will
		 * store many different kind of data associated to the application. */		
		internal static const GLOBAL_CONFIG_SO_NAME:String = "pyramid-battle-config";
		
		/**
		 * Determines if this is the first launch of the application. At the first launch, this property
		 * will be added to the SharedObject and initialized to <code>true</code>, then we initialize all
		 * the default properties needed for the application to work properly.
		 *
		 * <p>Later, we can check this value so that we know that we don't need to initialize all the default
		 * properties again later.</p> */
		public static const PROPERTY_FIRST_LAUNCH:String = "first-launch";
		
	// ----- App language
		
		/**
		 * Access the app language. Default is "unknown" so that the LanguageManager knows it has to parse
		 * all available languages from the file system and determine the best one to pick up. */
		public static const PROPERTY_LANGUAGE:String = "DEFAULT_LANGUAGE";
		public static const DEFAULT_LANGUAGE:String = "unknown";
		
		/**
		 * Access all the available languages. Hack for Poedit :
		 * _("Français");
		 * _("Anglais"); */
		public static const PROPERTY_AVAILABLE_LANGUAGES:String = "DEFAULT_AVAILABLE_LANGUAGES";
		public static const DEFAULT_AVAILABLE_LANGUAGES:Array = [ new LanguageData( { id:1, key:"fr", translationKey:"Français" } ),
																  new LanguageData( { id:2, key:"en", translationKey:"Anglais" } ) ];
		
		/**
		 * The new languages. */
		public static const PROPERTY_NEW_LANGUAGES:String = "DEFAULT_NEW_LANGUAGES";
		public static const DEFAULT_NEW_LANGUAGES:Array = [];
		
	// ----- Global config
		
		/**
		 * Idle time after which we relaunch an "init" to keep the app up to date after a long idle time. */
		public static const PROPERTY_IDLE_TIME:String = "DEFAULT_IDLE_TIME";
		public static const DEFAULT_IDLE_TIME:Number = 3600000; // 1 hour by default
		
		/**
		 * The game trophies. It must be configured in the Main class with AbstractGameInfo.CUPS */
		public static const PROPERTY_TROPHIES:String = "DEFAULT_TROPHIES";
		public static const DEFAULT_TROPHIES:Array = []; // no trophies by default, they must be setup in the Main class with AbstractGameInfo.CUPS
		
	// ----- Defaults
		
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
		
	// ----- Sound and music
		
		/**
		 * Whether the sound is enabled. */
		public static const PROPERTY_SOUND_ENABLED:String = "DEFAULT_SOUND_ENABLED";
		public static const DEFAULT_SOUND_ENABLED:Boolean = true;
		
		/**
		 * Whether the music is enabled. */
		public static const PROPERTY_MUSIC_ENABLED:String = "DEFAULT_MUSIC_ENABLED";
		public static const DEFAULT_MUSIC_ENABLED:Boolean = true;
		
	// ----- Other
		
		/**
		 * Whether we need to use the https protocol. */
		public static const PROPERTY_USE_SECURED_CALLS:String = "DEFAULT_USE_SECURED_CALLS";
		public static const DEFAULT_USE_SECURED_CALLS:Boolean = false;
		
		/**
		 * Whether the push notifications have been initialized. */
		public static const PROPERTY_PUSH_INITIALIZED:String = "DEFAULT_PUSH_INITIALIZED";
		public static const DEFAULT_PUSH_INITIALIZED:Boolean = false;
		
		/**
		 * Whether we need to force the user to update the application. */		
		public static const PROPERTY_FORCE_UPDATE:String = "DEFAULT_FORCE_UPDATE";
		public static const DEFAULT_FORCE_UPDATE:Boolean = false;
		/**
		 * The link of the application on the store. */		
		public static const PROPERTY_FORCE_UPDATE_LINK:String = "DEFAULT_FORCE_UPDATE_LINK";
		public static const DEFAULT_FORCE_UPDATE_LINK:String = "";
		
		/**
		 * The old game version used to check if we can disable the force update value if it was enabled. */
		public static const PROPERTY_GAME_VERSION:String = "DEFAULT_GAME_VERSION";
		public static const DEFAULT_GAME_VERSION:String = "1.0";
		
	}
}