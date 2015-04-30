/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 5 août 2013
*/
package com.ludofactory.mobile.core.scoring
{
	public class ScoreToPointsData
	{
		/**
		 * The inferior level */		
		private var _inf:int;
		
		/**
		 * The superior level */		
		private var _sup:int;
		
		/**
		 * The number of points earned with a paid game session, without
		 * a certain VIP rank (the one required is Aventurier II). */		
		private var _pointsWithCreditsNormal:int;
		
		/**
		 * The number of points earned with a paid game session, with a certain
		 * VIP rank (Aventurier II). */		
		private var _pointsWithCreditsVip:int;
		
		/**
		 * The number of points earned with a free game session */		
		private var _pointsWithFree:int;
		
		public function ScoreToPointsData(data = null)
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
			_pointsWithFree = int(data.gratuit);
			_pointsWithCreditsNormal = int(_pointsWithFree * data.coef[0]);
			_pointsWithCreditsVip = int(_pointsWithFree * data.coef[1]);
		}
		
		public function get inf():int { return _inf; }
		public function set inf(val:int):void { _inf = val; }
		
		public function get sup():int { return _sup; }
		public function set sup(val:int):void { _sup = val; }
		
		public function get pointsWithCreditsNormal():int { return _pointsWithCreditsNormal; }
		public function set pointsWithCreditsNormal(val:int):void { _pointsWithCreditsNormal = val; }
		
		public function get pointsWithCreditsVip():int { return _pointsWithCreditsVip; }
		public function set pointsWithCreditsVip(val:int):void { _pointsWithCreditsVip = val; }
		
		public function get pointsWithFree():int { return _pointsWithFree; }
		public function set pointsWithFree(val:int):void { _pointsWithFree = val; }
		
		/*public function toString():String
		{
			return "Level : " + _inf + " → " + _sup + " crédits = " + _pointsWithCredits + " - gratuit = " + _pointsWithFree;
		}*/
	}
}