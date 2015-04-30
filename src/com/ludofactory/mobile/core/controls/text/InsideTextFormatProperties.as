/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 26 sept. 2013
*/
package com.ludofactory.mobile.core.controls.text
{
	import flash.text.TextFormat;

	/**
	 * This object is used by the CustomTextFieldTextRenderer in order
	 * to apply a certain text format to a part of a label.
	 */	
	public class InsideTextFormatProperties
	{
		private var _textFormat:TextFormat;
		
		private var _beginIndex:int = -1;
		
		private var _endIndex:int = -1;
		
		public function InsideTextFormatProperties(textFormat:TextFormat, beginIndex:int = -1, endIndex:int = -1)
		{
			_textFormat = textFormat;
			_beginIndex = beginIndex;
			_endIndex = endIndex;
		}
		
		public function get textFormat():TextFormat
		{
			return _textFormat;
		}
		
		public function get beginIndex():int
		{
			return _beginIndex;
		}
		
		public function get endIndex():int
		{
			return _endIndex;
		}
	}
}