package com.nl.funkymonkey.android.deviceinfo
{
	import com.ludofactory.common.utils.log;
	
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;

	/*
	 * Copyright (c) 2010 Funky Monkey Studio, All Rights Reserved 
	 * 
	 * author   Sidney de Koning
	 * contact  sidney@funky-monkey.nl
	 * 
	 * Android-Native-Device-Info:
	 * 
	 * This class is used to grab a system file, parse it and store its values. 
	 * This information is mainly used for analytics and debugging 
	 * 
	 * 
	 * Usage:
	 * 
	 * 		NativeDeviceInfo.parse();
	 * 		
	 * 	   	trace(NativeDevicePropertiesData(NativeDeviceProperties.OS_NAME).label + " - " + NativeDevicePropertiesData(NativeDeviceProperties.OS_NAME).value);
	 * 	   	trace(NativeDevicePropertiesData(NativeDeviceProperties.OS_VERSION).label + " - " + NativeDevicePropertiesData(NativeDeviceProperties.OS_VERSION).value);
	 * 	   	trace(NativeDevicePropertiesData(NativeDeviceProperties.OS_BUILD).label + " - " + NativeDevicePropertiesData(NativeDeviceProperties.OS_BUILD).value);
	 * 	   	trace(NativeDevicePropertiesData(NativeDeviceProperties.OS_SDK_VERSION).label + " - " + NativeDevicePropertiesData(NativeDeviceProperties.OS_SDK_VERSION).value);
	 * 	   	trace(NativeDevicePropertiesData(NativeDeviceProperties.OS_SDK_DESCRIPTION).label + " - " + NativeDevicePropertiesData(NativeDeviceProperties.OS_SDK_DESCRIPTION).value);
	 * 	   	trace(NativeDevicePropertiesData(NativeDeviceProperties.PRODUCT_MODEL).label + " - " + NativeDevicePropertiesData(NativeDeviceProperties.PRODUCT_MODEL).value);
	 * 	   	trace(NativeDevicePropertiesData(NativeDeviceProperties.PRODUCT_BRAND).label + " - " + NativeDevicePropertiesData(NativeDeviceProperties.PRODUCT_BRAND).value);
	 * 	   	trace(NativeDevicePropertiesData(NativeDeviceProperties.PRODUCT_NAME).label + " - " + NativeDevicePropertiesData(NativeDeviceProperties.PRODUCT_NAME).value);
	 * 	   	trace(NativeDevicePropertiesData(NativeDeviceProperties.PRODUCT_VERSION).label + " - " + NativeDevicePropertiesData(NativeDeviceProperties.PRODUCT_VERSION).value);
	 * 	   	trace(NativeDevicePropertiesData(NativeDeviceProperties.PRODUCT_BOARD).label + " - " + NativeDevicePropertiesData(NativeDeviceProperties.PRODUCT_BOARD).value);
	 * 	   	trace(NativeDevicePropertiesData(NativeDeviceProperties.PRODUCT_CPU).label + " - " + NativeDevicePropertiesData(NativeDeviceProperties.PRODUCT_CPU).value);
	 * 	   	trace(NativeDevicePropertiesData(NativeDeviceProperties.PRODUCT_MANUFACTURER).label + " - " + NativeDevicePropertiesData(NativeDeviceProperties.PRODUCT_MANUFACTURER).value);
	 * 	   	trace(NativeDevicePropertiesData(NativeDeviceProperties.OPENGLES_VERSION).label + " - " + NativeDevicePropertiesData(NativeDeviceProperties.OPENGLES_VERSION).value);
	 * 	   	trace(NativeDevicePropertiesData(NativeDeviceProperties.LCD_DENSITY).label + " - " + NativeDevicePropertiesData(NativeDeviceProperties.LCD_DENSITY).value);
	 * 	   	trace(NativeDevicePropertiesData(NativeDeviceProperties.DALVIK_HEAPSIZE).label + " - " + NativeDevicePropertiesData(NativeDeviceProperties.DALVIK_HEAPSIZE).value);
	 * 
	 */
	public class NativeDeviceInfo
	{
		/**
		 * The device property file on the device. */		
		private static const PROP_FILE_ON_DEVICE : String = "/system/build.prop";

		/**
		 * Parses the device property file to retrieve more information about
		 * the device, such as the model, sdk, etc.
		 * 
		 * @param propfilename The file name of the property file on the device.
		 */		
		public static function parse(propfilename:String = PROP_FILE_ON_DEVICE):void
		{
			// split on newlines
			var pattern:RegExp = /\r?\n/;
			
			var propFile:File = new File();
			propFile.nativePath = propfilename;
			
			var fs:FileStream = new FileStream();
			fs.open(propFile, FileMode.READ);
			var lines:Array = fs.readUTFBytes(fs.bytesAvailable).replace(File.lineEnding, "\n").split(pattern);
			fs.close();
			fs = null;
			
			var line:String;
			var linesLength:int = lines.length;
			var propertiesLength:int = NativeDeviceProperties.DEVICE_PROPERTIES.length;
			for (var i:int = 0; i < linesLength; i++)
			{
				line = String(lines[i]);
				if ( line != "" && line.charAt(0) != "#" )
				{
					for (var j : int = 0; j < propertiesLength; j++)
					{
						if ( line.search(NativeDevicePropertiesData(NativeDeviceProperties.DEVICE_PROPERTIES[j]).configKey) != -1)
						{
							NativeDevicePropertiesData(NativeDeviceProperties.DEVICE_PROPERTIES[j]).value = line.split("=")[1];
							break;
						}
					}
				}
			}
		}
		
	}
}