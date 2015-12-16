/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 9 avril 2014
*/
package com.nl.funkymonkey.android.deviceinfo
{
	import com.gamua.flox.Flox;
	import com.ludofactory.common.utils.logs.log;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.system.Capabilities;
	
	/**
	 * Based on the work of Sidney de Koning - Funky Monkey Studio
	 * 
	 * This class is used to grab a system file (an Android), parse it and store its values. 
	 * This information is mainly used for analytics and debugging.
	 * 
	 * Usage:
	 * 
	 * 		NativeDeviceInfo.parse();
	 * 	   	NativeDevicePropertiesData(NativeDeviceProperties.OS_NAME).label / value;
	 * 	   	NativeDevicePropertiesData(NativeDeviceProperties.OS_VERSION).label / value);
	 * 	   	NativeDevicePropertiesData(NativeDeviceProperties.OS_BUILD).label / value);
	 * 	   	NativeDevicePropertiesData(NativeDeviceProperties.OS_SDK_VERSION).label / value);
	 * 	   	NativeDevicePropertiesData(NativeDeviceProperties.OS_SDK_DESCRIPTION).label / value);
	 * 	   	NativeDevicePropertiesData(NativeDeviceProperties.PRODUCT_MODEL).label / value);
	 * 	   	NativeDevicePropertiesData(NativeDeviceProperties.PRODUCT_BRAND).label / value);
	 * 	   	NativeDevicePropertiesData(NativeDeviceProperties.PRODUCT_NAME).label / value);
	 * 	   	NativeDevicePropertiesData(NativeDeviceProperties.PRODUCT_VERSION).label / value);
	 * 	   	NativeDevicePropertiesData(NativeDeviceProperties.PRODUCT_BOARD).label / value);
	 * 	   	NativeDevicePropertiesData(NativeDeviceProperties.PRODUCT_CPU).label / value);
	 * 	   	NativeDevicePropertiesData(NativeDeviceProperties.PRODUCT_MANUFACTURER).label / value);
	 * 	   	NativeDevicePropertiesData(NativeDeviceProperties.OPENGLES_VERSION).label / value);
	 * 	   	NativeDevicePropertiesData(NativeDeviceProperties.LCD_DENSITY).label / value);
	 * 	   	NativeDevicePropertiesData(NativeDeviceProperties.DALVIK_HEAPSIZE).label / value);
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
			if( GlobalConfig.android )
			{
				// only for android
				try
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
					
					log("<strong>Device informations :</strong><tr style='font-weight:bold;'>" +
						"<td style='width: 148px; color: black; text-align: right;'><strong>Device details :</strong></td>" +
						"<td style='word-break: break-all;'>" + NativeDevicePropertiesData(NativeDeviceProperties.PRODUCT_BRAND).value +  " " + NativeDevicePropertiesData(NativeDeviceProperties.PRODUCT_MODEL).value + " (" + NativeDevicePropertiesData(NativeDeviceProperties.PRODUCT_NAME).value + ")</td>" +
						"</tr>" +
						"<tr style='font-weight:bold;'>" +
						"<td />" + 
						"<td style='word-break: break-all;'>Manufactured by " + NativeDevicePropertiesData(NativeDeviceProperties.PRODUCT_MANUFACTURER).value + "</td>" +
						"</tr>" +
						"<tr style='font-weight:bold;'>" +
						"<td style='width: 148px; color: black; text-align: right;'><strong>OS details :</strong></td>" +
						"<td style='word-break: break-all;'>" + NativeDevicePropertiesData(NativeDeviceProperties.OS_NAME).value + ((GlobalConfig.android || GlobalConfig.ios) ? "" : "(Simulateur)") + " sur " + (GlobalConfig.isPhone ? "Smartphone" : "Tablette") + "</td>" +
						"</tr>" +
						"<tr style='font-weight:bold;'>" +
						"<td />" + 
						"<td style='word-break: break-all;'>OS version " + NativeDevicePropertiesData(NativeDeviceProperties.OS_VERSION).value + " (Build : " + NativeDevicePropertiesData(NativeDeviceProperties.OS_BUILD).value + ")</td>" +
						"</tr>" +
						"<tr style='font-weight:bold;'>" +
						"<td />" + 
						"<td style='word-break: break-all;'>SDK version " + NativeDevicePropertiesData(NativeDeviceProperties.OS_SDK_VERSION).value + " (" + NativeDevicePropertiesData(NativeDeviceProperties.OS_SDK_DESCRIPTION).value + ")</td>" +
						"</tr>" +
						"<tr style='font-weight:bold;'>" +
						"<td style='width: 148px; color: black; text-align: right;'><strong>Screen details :</strong></td>" +
						"<td style='word-break: break-all;'>Density " + NativeDevicePropertiesData(NativeDeviceProperties.LCD_DENSITY).value + " dpi - résolution " + Capabilities.screenResolutionX + "x" + Capabilities.screenResolutionY + "</td>" +
						"</tr>" +
						"<tr style='font-weight:bold;'>" +
						"<td style='width: 148px; color: black; text-align: right;'><strong>Other details :</strong></td>" +
						"<td style='word-break: break-all;'>Board : " +  NativeDevicePropertiesData(NativeDeviceProperties.PRODUCT_BOARD).value + "</td>" +
						"</tr>" +
						"<tr style='font-weight:bold;'>" +
						"<td />" + 
						"<td style='word-break: break-all;'>CPU : " +  NativeDevicePropertiesData(NativeDeviceProperties.PRODUCT_CPU).value + "</td>" +
						"<tr style='font-weight:bold;'>" +
						"<td />" + 
						"<td style='word-break: break-all;'>OpenGL ES version " +  NativeDevicePropertiesData(NativeDeviceProperties.OPENGLES_VERSION).value + "</td>" +
						"<tr style='font-weight:bold;'>" +
						"<td />" + 
						"<td style='word-break: break-all;'>Heap size : " +  NativeDevicePropertiesData(NativeDeviceProperties.DALVIK_HEAPSIZE).value + "</td>" +
						"</tr>"
					);
				} 
				catch(error:Error) 
				{
					Flox.logWarning("Impossible de parser le fichier build.prop du téléphone.");
					Flox.logInfo("Type d'appareil : <strong>{0} sur {1}</strong>", (GlobalConfig.isPhone ? "Smartphone" : "Tablette"), (GlobalConfig.ios ? "iOS" : (GlobalConfig.android ? "Android" : "Simulateur")));
				}
			}
			else
			{
				// for ios
				Flox.logInfo("Type d'appareil : <strong>{0} sur {1}</strong>", (GlobalConfig.isPhone ? "Smartphone" : "Tablette"), (GlobalConfig.ios ? "iOS" : (GlobalConfig.android ? "Android" : "Simulateur")));
			}
		}
		
	}
}