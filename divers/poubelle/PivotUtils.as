package com.ludofactory.common.utils
{
	/*_________________________________________________________________________________________
	|
	| Auteur      : Maxime Lhoez
	| Création    : 23 oct. 2012
	| Description : 
	|________________________________________________________________________________________*/
	
	import starling.display.DisplayObject;
	
	public class PivotUtils
	{
		
//------------------------------------------------------------------------------------------------------------
//	Pivot - Y axis
//------------------------------------------------------------------------------------------------------------
		
		/** Set pivotY in TOP */
		public static function setTop(element:DisplayObject):void    { element.pivotY = 0; }
		/** Set pivotY in MIDDLE */
		public static function setMiddle(element:DisplayObject):void { element.pivotY = element.height >> 1; }
		/** Set pivotY in BOTTOM */
		public static function setBottom(element:DisplayObject):void { element.pivotY = element.height; }

//------------------------------------------------------------------------------------------------------------
//	Pivot - X axis
//------------------------------------------------------------------------------------------------------------
		
		/** Set pivotX in LEFT */
		public static function setLeft(element:DisplayObject):void   { element.pivotX = 0; }
		/** Set pivotX in CENTER */
		public static function setCenter(element:DisplayObject):void { element.pivotX = element.width >> 1; }
		/** Set pivotX in RIGHT */
		public static function setRight(element:DisplayObject):void  { element.pivotX = element.width; }
		
		/** Set pivotX in CENTER and pivotY in MIDDLE*/
		public static function setCenterAndMiddle(element:DisplayObject):void { element.pivotX = element.width >> 1; element.pivotY = element.height >> 1; }
		
	}
}