/**
 * Created by olivier.chevarin on 02/06/2015.
 */
package com.ludofactory.common.utils.logs
{
	
	import com.ludofactory.common.utils.Utilities;
	
	import flash.utils.getQualifiedClassName;
	
	/**
	 * Rule : use "\x1B[" then the font weight / font color / background color
	 * the order does not matter but you have to separate the styles with a ";" and finish by a m
	 * the last style don't need a ";"
	 * Ex : \x1B[1m
	 * 
	 * In the future, we can add th background colors
	 *
	 * Black : 40
	 * Red : 41
	 * Green : 42
	 * Yellow : 43
	 * Blue : 44
	 * Magenta :45
	 * Cyan : 46
	 * White : 47
	 * 
	 * Ref : http://bluesock.org/~willg/dev/ansi.html
	 */
    public class Logger
    {
	    /**
	     * No style (white regular). */
	    public static const NO_STYLE:String = "\x1B[0;0m";
	    
    // --------- Font weights
	    
	    /**
	     * Normal display. */
        public static const REGULAR:String = "0";
	    /**
	     * Bold. */
        public static const BOLD:String = "1";
	    /**
	     * Italic. */
        public static const ITALIC:String = "3";
	    /**
	     * Underlined (mono only). */
        public static const UNDERLINED:String = "4"; // marche pas
	    /**
	     * Bold italic. */
        public static const BOLD_ITALIC:String = "1;3";
	
    // --------- Font colors
	
	    /**
	     * Black. */
	    public static const BLACK:String = "30";
	    /**
	     * Red. */
	    public static const RED:String = "31";
	    /**
	     * Green. */
	    public static const GREEN:String = "32";
	    /**
	     * Yellow. */
	    public static const YELLOW:String = "33";
	    /**
	     * Blue. */
	    public static const BLUE:String = "34";
	    /**
	     * Magenta. */
	    public static const MAGENTA:String = "35";
	    /**
	     * Cyan. */
	    public static const CYAN:String = "36";
	    /**
	     * White. */
	    public static const WHITE:String = "37";
		
	// --------- Font colors
		
        /**
         * text added to log when error */
        static public var textLogged:String = "";
        /**
         * show/hide type of Object */
        static public var enableType:Boolean = true;
        /**
         * Permet de desactiver les textes de debug lorsque l'on a fini de debugué. evite de tout commenter */
        static public var enableTextDebug:Boolean = true;
		/**
		 *  */
		private static const levelMax:int = 99; // a remettre en param si besoin
        
        public function Logger()
        {
	        
        }
        
        public static function addTextLogger(str:String, init:Boolean = false):void
        {
            if (!enableTextDebug)
                return;
            
            if (init)
                textLogged = str;
            else
                textLogged += "\n" + str
        }
        
        public static function getLog(property:Object, name:String = "", fontColor:String = WHITE, fontWeight:String = REGULAR, indentationLevel:int = 0):String
        {
            var output:String = "";
            var tabs:String = "";
            var bool:Boolean = false;
	        var formattedColor:String = "\x1B[" + fontWeight + ";" + fontColor + "m";
	
	        var child:*;
	        var childType:String;
	        var arrNameChild:Array;
	        var nameClassChild:String;
	        
	        enableType = CONFIG::DEBUG;
	        
	        // if we have a name, we create one more indentation
            //if (name != "")
            //    tabs += "\t";
            
	        // then create the normal indentation
            for (var i:int = 0; i <= indentationLevel; i++)
                tabs += "\t";
	        
            if(property)
            {
                var propertyType:String = getQualifiedClassName(property);
	            //trace("Property type = " + propertyType);
	            
                if (CONFIG::DEBUG)
                {
                    try
                    {
                        Utilities.enableEnumerableObject(property);
                    }
                    catch (err:Error)
                    {
                        
                    }
                }
	            
	            if (Utilities.countObject(property) <= 1)
	            {
		            output += property;
	            }
                else
	            {
		            // it's a complex object, loop through its properties
		            for (var key in property)
		            {
			            bool = true;
			            try
			            {
				            child = property[key];
				
				            if (child != null)
				            {
					            childType = getQualifiedClassName(child);
					            arrNameChild = childType.replace("__AS3__", "").match(/([A-Z])\w+/g);
					            nameClassChild = (arrNameChild.length > 0 ? (arrNameChild.length == 1 ? arrNameChild[0] : arrNameChild[0] + ".<" + arrNameChild[1] + ">" ) : getQualifiedClassName(child))
				            }
			            }
			            catch (error:Error)
			            {
				            output += tabs + (propertyType == "Array" ? "[" : "{") + key + (propertyType == "Array" ? "]" : "}") + " => " + error.message + "\n";
				            continue;
			            }
			            
			            if(key == "anonymousGameSessions")
			                trace("sdfs");
			            
			            var childOutput:String = "";
			            if(Utilities.countObject(child) <= 1)
			            {
				            output += tabs + "[" + key + "]" + " => " + (childType == "String" ? '"' + child + '"' : ((childType == "Array" || childType == "Vector") ? (childType + " (empty)") : child) );
			            }
			            else
			            {
				            output += tabs + (propertyType == "Array" ? "[" : "{") + key + (propertyType == "Array" ? "]" : "}") + " => " + childType; //nameClassChild;
				            // it's a complex object so get the output of it
				            if((indentationLevel + 1) <= levelMax)
				            {
					            childOutput = getLog(child, name, fontColor, fontWeight, indentationLevel + 1);
			                    if ((childType == "Array" ? child.length : Utilities.countObject(child)) > 0)
					                output += " (" + (childType == "Array" ? child.length : Utilities.countObject(child)) + ")";
					            output += "\n" + tabs + (childType == "Array" ? "[" : "{") + '\n' + childOutput + tabs + (childType == "Array" ? "]" : "}");
				            }
			            }
			            
			            output += "\n";
		            }
	            }
            }
	        
	        // the recursivity is done, we can output the log
            if (indentationLevel == 0)
            {
                output = (name != "" ? (name + " ") : "") + (bool ? "\n" + propertyType + " (" + (propertyType == "Array" ? property.length : Utilities.countObject(property)) + ")" + "\n" + (propertyType == "Array" ? "[" : "{") + '\n' : "") + output + (bool ? (propertyType == "Array" ? "]" : "}") : "");
                
	            if (CONFIG::DEBUG)
	                trace(formattedColor + output + NO_STYLE);
                else
                    trace(output);
                
                LogDisplayer.getInstance().addLog(output);
            }
	        
            return output;
        }
    }
}