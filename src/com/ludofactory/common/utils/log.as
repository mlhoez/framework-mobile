/*
Copyright © 2006-2014 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 11 déc. 2012
*/
package com.ludofactory.common.utils
{
	import com.gamua.flox.Flox;
	import com.ludofactory.mobile.core.test.config.GlobalConfig;
	
	import flash.utils.getQualifiedClassName;

	/**
	 * Fonction permettant de formater un objet pour une sortie plus lisible (similaire a print_r PHP)
	 * 
	 * @param obj:Object a tracer (string,array,object...)
	 * @param name:String affiche un nom juste avant les valeurs
	 * @param showInTrace:Boolean Si on veut faire une trace de l'objet
	 * @param level:int Permet l'incrementation
	 * @return String 
	 * 
	 */		
	public function log(value:*, color:uint=0x000000, indentationLevel:int = 0):String
	{
		if( !GlobalConfig.DEBUG )
		{
			// log in Flox anyway
			Flox.logInfo(value);
			return "";
		}
		
		// create indentation
		var indentation:String = "";
		for(var i:int = 0; i < indentationLevel; i++)
			indentation += "\t";
		
		var output:String = "";
		for(var child:* in value)
		{
			if(value[child] is Array || value[child] is Vector || typeof(value[child]) == "object")
			{
				output += indentation +"["+ child +"] => "+ getQualifiedClassName(value[child]);
			}
			else
			{
				output += indentation +"["+ child +"] => "+ value[child];
			}
			
			var childOutput:String = log(value[child], color, indentationLevel + 1);
			if(childOutput != "")
			{
				output += "\n{\n" + indentation + childOutput + "\n}";
			}
			else if((value[child] is Array || value[child] is Vector || typeof(value[child]) == "object") && value[child] != null )
			{
				output += "\n{\n " + indentation + value[child] + "\n}";
			}
			
			output += "\n";
		}
		
		if(indentationLevel == 0 && output == "")
			output = String(value);
		
		if(indentationLevel == 0)
		{
			trace(output);
			Flox.logInfo(output);
		}
		
		return output;
	}
	
}