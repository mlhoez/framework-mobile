/*
Copyright © 2006-2015 Ludo Factory
Framework
Author  : Maxime Lhoez
Created : 11 déc. 2012
*/
package com.ludofactory.mobile.core
{
	
	import com.ludofactory.common.utils.logs.Logger;
	import com.ludofactory.common.utils.logs.log;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.manager.MemberManager;
	import com.ludofactory.mobile.core.remoting.Remote;
	
	/**
	 * report error in JS or PHP 
	 * 
	 * @param value Value to trace (can be anything)
	 *
	 * 
	 */
	public function reportError(...args):void
	{
		log("\n ------------------------------------------------------------------------------");
		
		//if(!AbstractServer.timerBeforeRecallErrorLogFunction)
		//	AbstractServer.timerBeforeRecallErrorLogFunction = new Timer(AbstractServer.timeBeforeRecallErrorLogFunction,1);
		
		// avoid to log too many errors
		//if(AbstractServer.timerBeforeRecallErrorLogFunction.running)
		//{
			//log(args, "TIMER RUNNING: reportError");
		//	log("Timer is running, no report");
		//	return
		//}
		
		//AbstractServer.timerBeforeRecallErrorLogFunction.start();
		
		var objCall:Object = {};
		objCall.game = AbstractGameInfo.GAME_NAME + " (v" + AbstractGameInfo.GAME_VERSION + " build " + AbstractGameInfo.GAME_BUILD_VERSION + ")";
		
		try
		{
			if(args.length == 1)
			{
				var arg:* = args[0];

				if(arg is Object && !(arg is Error))
					objCall = arg;
				

				if(Logger.textLogged != "")
					objCall.textLogged = Logger.textLogged;
				
				objCall.member = MemberManager.getInstance().id + " - Device id : " + GlobalConfig.deviceId;
				objCall.device = (GlobalConfig.isPhone ? "Smartphone":"Tablette") + " " + GlobalConfig.platformName;
				objCall.currentScreen = AbstractEntryPoint.screenNavigator ? AbstractEntryPoint.screenNavigator.activeScreenID : "";
				
				if(arg is String)
				{
					objCall.message = arg;
					log(arg,"reportError (String) in "+ objCall.game);
				}
				else if(arg is Error)
				{
					objCall.stackTrace = (arg as Error).getStackTrace();
					log((arg as Error).getStackTrace(),"reportError (Error) in " + objCall.game);
				}
				else if(arg is Object)
				{
					log(arg,"reportError (Object) in "+ objCall.game);
				}
			}
			else
			{
				objCall.reportError = args;
				log(args,"reportError args.length > 1 ");
			}
			
			Remote.getInstance().reportError(objCall);
		}
		catch(err:Error)
		{
			log(err,"Bug to reportError");
		}
		log(" ------------------------------------------------------------------------------\n");
	}
	
}