/**
 * Created by Maxime on 23/10/15.
 */
package com.ludofactory.common.utils
{
	
	public class Dimension extends Object
	{
		/**
		 * Width. */
		private var _width:Number;
		/**
		 * Height. */
		private var _height:Number;
		
		public function Dimension(width:Number = 0, height:Number = 0)
		{
			_width = width;
			_height = height;
		}
		
		public function get width():Number { return _width; }
		public function set width(value:Number):void { _width = value; }
		
		public function get height():Number { return _height; }
		public function set height(value:Number):void { _height = value; }
		
	}
}