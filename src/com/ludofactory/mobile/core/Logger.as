/**
 * Created by olivier.chevarin on 02/06/2015.
 */
package com.ludofactory.mobile.core {
	
	import com.ludofactory.common.utils.LogDisplayer;
	import com.ludofactory.common.utils.Utilities;
	
	import flash.utils.getQualifiedClassName;
	
	public class Logger {
        
        static public var textLogged:String = "";
        public function Logger() {
            

        }
        
        public static function getLog(obj:*, name:String="", levelMax:int = 1 , forceLog:Boolean = false, level:int = 0){
            
            var output:String = "";
            var tabs:String = "";
            var bool:Boolean = false;

            if (name != "")
                tabs += "\t\t";

            for (var i = 0; i <= level; i++)
                tabs += "\t";

            var styles:Object = {
                'bold': ['\x1B[1m', '\x1B[22m'],
                'italic': ['\x1B[3m', '\x1B[23m'],
                'underline': ['\x1B[4m', '\x1B[24m'],
                'inverse': ['\x1B[7m', '\x1B[27m'],
                'hidden': ['\x1B[8m', '\x1B[28m'],
                'strikethrough': ['\x1B[9m', '\x1B[29m'],
                'white': ['\x1B[37m', '\x1B[39m'],
                'whiteitalichidden': ['\x1B[37;3;8m', '\x1B[39;23;28m'],
                'grey': ['\x1B[90m', '\x1B[39m'],
                'greyitalichidden': ['\x1B[90;8;3m', '\x1B[39;28;23m'],
                'black': ['\x1B[30m', '\x1B[39m'],
                'blue': ['\x1B[34m', '\x1B[39m'],
                'cyan': ['\x1B[36m', '\x1B[39m'],
                'green': ['\x1B[32m', '\x1B[39m'],
                'magenta': ['\x1B[35m', '\x1B[39m'],
                'red': ['\x1B[31m', '\x1B[39m'],
                'yellow': ['\x1B[33m', '\x1B[39m'],
                'whiteBG': ['\x1B[47m', '\x1B[49m'],
                'greyBG': ['\x1B[49;5;8m', '\x1B[49m'],
                'blackBG': ['\x1B[40m', '\x1B[49m'],
                'blueBG': ['\x1B[44m', '\x1B[49m'],
                'cyanBG': ['\x1B[46m', '\x1B[49m'],
                'greenBG': ['\x1B[42m', '\x1B[49m'],
                'magentaBG': ['\x1B[45m', '\x1B[49m'],
                'redBG': ['\x1B[41m', '\x1B[49m'],
                'yellowBG': ['\x1B[43m', '\x1B[49m']
            };

            var styleCount:Array = ["", ""];
            //		var styleClass:Array = ["",""];
            var normalStyle:Array = ["", ""];

            if (CONFIG::DEBUG) {
                styleCount = styles.whiteitalichidden;
                normalStyle = styles.white;
            }

            var child;
            var typeChild:String;
            var arrNameChild:Array;
            var nameClassChild:String;

            if (obj) {

                var typeObj = ( typeof obj == "object" ? (obj instanceof Array ? "array" : typeof obj ) : typeof obj);
                var arrName = getQualifiedClassName(obj).replace("__AS3__", "").match(/([A-Z])\w+/g);
                var nameClassObj:String = (arrName.length > 0 ? (arrName.length == 1 ? arrName[0] : arrName[0] + ".<" + arrName[1] + ">" ) : getQualifiedClassName(obj));

                if ((typeof obj == "array" || typeof obj == "object" || obj.toString() == "[object Object]") && typeObj != "function") {
                    if (CONFIG::DEBUG) {
                        try {
                            Utilities.enableEnumerableObject(obj);
                        } catch (err:Error) {
//							return log(err);
                        }

                    }

                    for (var key in obj) {
                        bool = true;
                        try {
                            child = obj[key];

                            if (child != null) {
                                typeChild = ( typeof child == "object" ? (child instanceof Array ? "array" : typeof child) : typeof child );
                                arrNameChild = getQualifiedClassName(child).replace("__AS3__", "").match(/([A-Z])\w+/g);
                                nameClassChild = (arrNameChild.length > 0 ? (arrNameChild.length == 1 ? arrNameChild[0] : arrNameChild[0] + ".<" + arrNameChild[1] + ">" ) : getQualifiedClassName(child))
                            }
                        } catch (e) {
                            output += tabs + (typeObj == "array" ? "[" : "{") + key + (typeObj == "array" ? "]" : "}") + " => " + e.message + "\n";
                            continue;
                        }

                        if (typeChild == "int" || typeChild == "string" || typeChild == "boolean" || typeChild == "number") {

                            if (child === "") {
                                child = '""';
                            }
                            output += tabs + (typeObj == "array" ? "[" : "{") + key + (typeObj == "array" ? "]" : "}") + " => " + ( typeChild == "string" ? '"' + child + '"' : child )  //+normalStyle[1]+ styleClass[0]+" (" +  nameClassChild + ")"+styleClass[1]+normalStyle[0];
                        } else {
                            output += tabs + (typeObj == "array" ? "[" : "{") + key + (typeObj == "array" ? "]" : "}") + " => " + nameClassChild // nameClassChild;
                        }

                        var childOutput = '';
                        if (child && ((typeChild == "array" || typeChild == "object" || child.toString() == "[object Object]" || typeChild == "int" || typeChild == "string" || typeChild == "boolean" || typeChild == "number"  ) && (level + 1 ) <= levelMax)) {
                            childOutput = getLog(child, name, levelMax, forceLog, level + 1);
                        }
                        if (!(typeChild == "int" || typeChild == "string" || typeChild == "boolean" || typeChild == "number"  ) && child != null && level < levelMax) {
                            if ((typeChild == "array" ? child.length : Utilities.countObject(child)) > 0)
                                output += normalStyle[1] + styleCount[0] + " (" + (typeChild == "array" ? child.length : Utilities.countObject(child)) + ")" + styleCount[1] + normalStyle[0];
                        }
                        if (childOutput != '')
                            output += (typeChild == "array" ? "[" : "{ ") + '\n' + childOutput + tabs + (typeChild == "array" ? "]" : "}");
                        else if (!(typeChild == "int" || typeChild == "string" || typeChild == "boolean" || typeChild == "number"  ) && child != null) {
                            output += ' ' + (typeChild == "array" ? "[" + normalStyle[1] + styleCount[0] + child.length + styleCount[1] + normalStyle[0] + "]" : "{" + normalStyle[1] + styleCount[0] + Utilities.countObject(child) + styleCount[1] + normalStyle[0] + "}")// +normalStyle[1]+ styleClass[0] +"(" +nameClassChild  + ")"+styleClass[1]+normalStyle[0];
                        }
                        output += "\n";
                    }
                }
            }


            if (level == 0) {

                if (output == "") {
                    if (typeObj == "undefined")
                        output = "undefined";

                    else if (typeObj == "int" || typeObj == "string" || typeObj == "boolean" || typeObj == "number" || !obj) {
                        // Si obj n'est pas un Array,Object, on retourne directement obj
                        output = String(obj);  // +"[ ("+ (typeof obj)[0].toUpperCase()+ (typeof obj).slice(1)+") ]" A rajouter si on veut le typage de variable lorsque l'on log un Number, String, boolean
                    }
                    else if (typeObj == "TypeError") {
                        output = obj
                    }
                    /*else {
                     output = (typeObj == "array" ? "[" +normalStyle[1]+styleCount[0]+ obj.length +styleCount[1]+normalStyle[0] + "]" : "{" + normalStyle[1]+styleCount[0]+Utilities.countObject(obj) +styleCount[1]+normalStyle[0]+ "}")
                     }*/
                }

                output = (name != "" ? name + " : " : "") + (bool ? (name != "" ? "\n\t" : "\n") + nameClassObj + normalStyle[1] + styleCount[0] + " (" + (typeObj == "array" ? obj.length : Utilities.countObject(obj)) + ")" + styleCount[1] + normalStyle[0] + (typeObj == "array" ? "[" : "{") + '\n' : "") + output + (bool ? (name != "" ? "\t" : "") + (typeObj == "array" ? "]" : "}") : "");

                trace(output);

                if(forceLog)
                    textLogged += output;
                
               LogDisplayer.getInstance().addLog(output);
            }
            return output;
        }
    }
}