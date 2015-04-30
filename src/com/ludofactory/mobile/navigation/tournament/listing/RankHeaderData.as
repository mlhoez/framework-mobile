/*
Copyright © 2006-2015 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 25 nov. 2013
*/
package com.ludofactory.mobile.navigation.tournament.listing
{
	public class RankHeaderData
	{
		private var _name:String;
		
		private var _indice:int;
		
		public function RankHeaderData( data:Object )
		{
			_name = data.headerName;
			_indice = data.indice;
		}
		
		public function get headerName():String { return _name; }
		public function get indice():int { return _indice; }
		
		public function toString():String { return _name; }
	}
}