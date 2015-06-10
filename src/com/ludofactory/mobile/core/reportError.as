/*
Copyright © 2006-2015 Ludo Factory
Framework
Author  : Maxime Lhoez
Created : 11 déc. 2012
*/
package com.ludofactory.mobile.core
{
	
	import com.ludofactory.common.utils.log;
	import com.ludofactory.mobile.core.manager.MemberManager;
	
	import flash.utils.Timer;
	
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
		
		try
		{
			var location:String ="";
			location += AbstractGameInfo.GAME_NAME + " (v" + AbstractGameInfo.GAME_VERSION + ")";
		}
		catch(err:Error)
		{
			log(err,"[reportError] error get Location ");
			location = "undefined" ;
		}
		
		try
		{			
			var objCall:Object = new Object();
			
			if(args.length == 1)
			{
				var arg:* = args[0];

				if(arg is Object && !(arg is Error))
				{
					objCall = arg
				}
				objCall.location = location;
				

				if(Logger.textLogged != "")
					objCall.textLogged = Logger.textLogged;
				
				objCall.memberId = MemberManager.getInstance().getId();
				objCall.gameName = AbstractGameInfo.GAME_NAME;
				
				if(arg is String)
				{
					objCall.message = arg;
					log(arg,"reportError (String) in "+location);
				}
				else if(arg is Error)
				{
					objCall.errorID = (arg as Error).errorID;
					objCall.stackTrace = (arg as Error).getStackTrace();
					log((arg as Error).getStackTrace(),"reportError (Error) in " + location);
				}
				else if(arg is Object)
				{
					log(arg,"reportError (Object) in "+location);
				}
			}
			else
			{
				objCall.reportError = args;
				objCall.location = location;
				log(args,"reportError args.length > 1 ");
			}
			// TODO remote call here
			//ExternalInterfaceManager.call(AbstractServer.LogErrorJSFunctionName,false,objCall);
			
		}
		catch(err:Error)
		{
			log(err,"Bug to reportError");
		}
		log(" ------------------------------------------------------------------------------\n");
	}
	
}