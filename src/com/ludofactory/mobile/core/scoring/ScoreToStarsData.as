/*
Copyright © 2006-2014 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 7 août 2013
*/
package com.ludofactory.mobile.core.scoring
{
	public class ScoreToStarsData
	{
		/**
		 * The inferior level */		
		private var _inf:int;
		
		/**
		 * The superior level */		
		private var _sup:int;
		
		/**
		 * The number of stars earned with any type of game session */		
		private var _stars:int;
		
		public function ScoreToStarsData(data = null)
		{
			// this is necessary or Flash won"t be able to deserialize the object because
			// when we retreive a SharedObject containing this custom class, the parameter
			// of the constructor will (always ?) be null. So we need to set a default value
			// in the constructor and then, check if this value is equal to null or not.
			// The object will be juste fine after, like it was saved in the SharedObject, so
			// this is weird but works juste fine.
			if( !data ) return;
			
			_inf = data.inf;
			_sup = data.sup;
			_stars = data.etoiles;
		}
		
		public function get inf():int { return _inf; }
		public function set inf(val:int):void { _inf = val; }
		
		public function get sup():int { return _sup; }
		public function set sup(val:int):void { _sup = val; }
		
		public function get stars():int { return _stars; }
		public function set stars(val:int):void { _stars = val; }
		
		public function toString():String
		{
			return "Level : " + _inf + " → " + _sup + " étoiles = " + _stars;
		}
	}
}