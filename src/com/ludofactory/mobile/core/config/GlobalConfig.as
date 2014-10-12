/*
Copyright © 2006-2014 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 31 août 2013
*/
package com.ludofactory.mobile.core.config
{
	import com.ludofactory.mobile.core.model.MonthData;
	import com.ludofactory.mobile.navigation.highscore.CountryData;

    public class GlobalConfig
    {
		/**
		 * Debug variable.
		 * 
		 * <strong>
		 * <p>When set to true, no log will be shown in the console (but it will
		 * be reported to Flow anyway.</p>
		 * 
		 * <p>When set to true, the PROD_PORT and PROD_URL will automatically be
		 * used in Remote.</p>
		 * </strong> 
		 * 
		 * @see com.ludofactory.mobile.core.remoting.Remote */		
		public static const DEBUG:Boolean = true;
		
		/**
		 * Enables the demo mode, displaying the touch inputs on the screen
		 * with the TouchMarkerManager. Is should be disabled when in production !
		 * 
		 * @see com.ludofactory.mobile.debug.TouchMarkerManager */		
		public static const DEMO_MODE:Boolean = false;
		
		/**
		 * Determines if we are on a phone or tablet */		
		public static var isPhone:Boolean;
		
		/**
		 * Determines if we are on an android device. */		
		public static var android:Boolean = false;
		/**
		 * Determines if we are on an iOS device. */		
		public static var ios:Boolean = false;
		
		/**
		 * Whether th application is compiled for the Amazon App Store. */		
		public static var amazon:Boolean = false;
		
		/**
		 * The user's hardware data */		
		public static var userHardwareData:Object;
		
		/**
		 * The dpiScale, defined in the theme and used to layout pretty much everything */		
		public static var dpiScale:Number = 1;
		
		/**
		 * This is the platform name (ios or android only for now) */		
		public static var platformName:String = "";
		
		/**
		 * This is the device id. */		
		public static var deviceId:String = "";
		
		/**
		 * The countries
		 * 
		 * Hack for Poedit
		 * _("International");
		 * _("France");
		 * _("Belgique");
		 * _("Suisse");
		 * _("Canada");
		 * _("Royaume-Uni");
		 * _("Espagne");
		 * 
		 * */		
		public static const COUNTRIES:Array = [ new CountryData( { id:0, nameTranslationKey:"International", diminutive:"",   textureName:"flag-international" } ),
												new CountryData( { id:1, nameTranslationKey:"France",        diminutive:"FR", textureName:"flag-france" } ),
												new CountryData( { id:2, nameTranslationKey:"Belgique",      diminutive:"BE", textureName:"flag-belgique" } ),
												new CountryData( { id:3, nameTranslationKey:"Suisse",        diminutive:"CH", textureName:"flag-suisse" } ),
												new CountryData( { id:4, nameTranslationKey:"Canada",        diminutive:"CA", textureName:"flag-canada" } ),
												new CountryData( { id:5, nameTranslationKey:"Royaume-Uni",   diminutive:"GB", textureName:"flag-uk" } ),
												new CountryData( { id:6, nameTranslationKey:"Espagne",       diminutive:"ES", textureName:"flag-espagne" } ) ];
		
		// personal settings
		public static const DAYS:Vector.<int>   = Vector.<int>( [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31] );
		/**
		 * The months
		 * 
		 * Hack for Poedit
		 * _("Jan.");
		 * _("Fév.");
		 * _("Mar.");
		 * _("Avr.");
		 * _("Mai");
		 * _("Juin");
		 * _("Juil.");
		 * _("Aou.");
		 * _("Sept.");
		 * _("Oct.");
		 * _("Nov.");
		 * _("Déc.");
		 * 
		 * */	
		public static const MONTHS:Vector.<MonthData> = Vector.<MonthData>( [ new MonthData( { id:1,  translationKey:"Jan."} ),
																			  new MonthData( { id:2,  translationKey:"Fév."} ),
																			  new MonthData( { id:3,  translationKey:"Mar."} ),
																			  new MonthData( { id:4,  translationKey:"Avr."} ),
																			  new MonthData( { id:5,  translationKey:"Mai"} ),
																			  new MonthData( { id:6,  translationKey:"Juin"} ),
																			  new MonthData( { id:7,  translationKey:"Juil."} ),
																			  new MonthData( { id:8,  translationKey:"Aou."} ),
																			  new MonthData( { id:9,  translationKey:"Sept."} ),
																			  new MonthData( { id:10, translationKey:"Oct."} ),
																			  new MonthData( { id:11, translationKey:"Nov."} ),
																			  new MonthData( { id:12, translationKey:"Déc."} ) ] );
		
		/**
		 * Current stage width (updated in Main when the orientation change). */		
		public static var stageWidth:Number;
		
		/**
		 * Current stage height (updated in Main when the orientation change). */		
		public static var stageHeight:Number;
		
		/**
		 * Scale factor used to scale the game logo at the home screen.
		 * Because the logos have different ratio, we need to customize
		 * these values for each game. */		
		public static var homeScreenLogoScaleWidthPhone:Number = 0.85;
		
		/**
		 * Scale factor used to scale the game logo at the home screen.
		 * Because the logos have different ratio, we need to customize
		 * these values for each game. */		
		public static var homeScreenLogoScaleWidthTablet:Number = 0.75;
    }
}