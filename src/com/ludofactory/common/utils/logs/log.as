/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 11 déc. 2012
*/
package com.ludofactory.common.utils.logs
{
	
	import com.ludofactory.mobile.core.manager.MemberManager;
	
	/**
	 * Fonction permettant de formater un objet pour une sortie plus lisible (similaire a print_r PHP)
	 *
	 * @param property
	 * @param name
	 * @param fontColor
	 * @param fontWeight
	 * @return
	 */
	public function log(property:Object, name:String = "", fontColor:String = Logger.WHITE, fontWeight:String = Logger.REGULAR):String
	{
		if (MemberManager.getInstance().isAdmin() || CONFIG::DEBUG)
			return Logger.getLog(property, name, fontColor, fontWeight);
		return "";
	}
	
	/*public function log(value:*, color:uint=0x000000, indentationLevel:int = 0):String
	 {
	 if( !CONFIG::DEBUG )
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
	 }*/

}