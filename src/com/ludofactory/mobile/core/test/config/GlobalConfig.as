/*
LudoFactory
Framework mobile
Author  : Maxime Lhoez
Created : 31 août 2013
*/
package com.ludofactory.mobile.core.test.config
{
	import com.ludofactory.mobile.core.model.MonthData;
	import com.ludofactory.mobile.core.test.highscore.CountryData;

    public class GlobalConfig
    {
		/**
		 * Debug variable */		
		public static const DEBUG:Boolean = true;
		
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
		 * The countries */		
		public static const COUNTRIES:Array = [ new CountryData( { id:0, nameTranslationKey:"INTERNATIONAL", diminutive:"",   textureName:"flag-international" } ),
												new CountryData( { id:1, nameTranslationKey:"FRANCE",        diminutive:"FR", textureName:"flag-france" } ),
												new CountryData( { id:2, nameTranslationKey:"BELGIUM",       diminutive:"BE", textureName:"flag-belgique" } ),
												new CountryData( { id:3, nameTranslationKey:"SWISS",         diminutive:"CH", textureName:"flag-suisse" } ),
												new CountryData( { id:4, nameTranslationKey:"CANADA",        diminutive:"CA", textureName:"flag-canada" } ),
												new CountryData( { id:5, nameTranslationKey:"UK",            diminutive:"GB", textureName:"flag-uk" } ),
												new CountryData( { id:6, nameTranslationKey:"SPAIN",         diminutive:"ES", textureName:"flag-espagne" } ) ];
		
		// personal settings
		public static const DAYS:Vector.<int>   = Vector.<int>( [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31] );
		public static const MONTHS:Vector.<MonthData> = Vector.<MonthData>( [ new MonthData( { id:1,  translationKey:"MONTH.JANUARY"} ),
																			  new MonthData( { id:2,  translationKey:"MONTH.FEBRUARY"} ),
																			  new MonthData( { id:3,  translationKey:"MONTH.MARCH"} ),
																			  new MonthData( { id:4,  translationKey:"MONTH.APRIL"} ),
																			  new MonthData( { id:5,  translationKey:"MONTH.MAY"} ),
																			  new MonthData( { id:6,  translationKey:"MONTH.JUNE"} ),
																			  new MonthData( { id:7,  translationKey:"MONTH.JULY"} ),
																			  new MonthData( { id:8,  translationKey:"MONTH.AUGUST"} ),
																			  new MonthData( { id:9,  translationKey:"MONTH.SEPTEMBER"} ),
																			  new MonthData( { id:10, translationKey:"MONTH.OCTOBER"} ),
																			  new MonthData( { id:11, translationKey:"MONTH.NOVEMBER"} ),
																			  new MonthData( { id:12, translationKey:"MONTH.DECEMBER"} ) ] );
		
		/**
		 * Current stage width (updated in Main when the orientation change). */		
		public static var stageWidth:Number;
		
		/**
		 * Current stage height (updated in Main when the orientation change). */		
		public static var stageHeight:Number;
    }
}