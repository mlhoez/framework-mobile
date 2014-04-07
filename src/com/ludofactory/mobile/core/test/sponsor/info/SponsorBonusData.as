/*
Copyright © 2006-2014 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 27 sept. 2013
*/
package com.ludofactory.mobile.core.test.sponsor.info
{
	public class SponsorBonusData
	{
		private var _iconTextureName:String;
		
		private var _rank:String;
		
		private var _bonus:String;
		
		public function SponsorBonusData( data:Object )
		{
			_iconTextureName = data.iconTextureName;
			_rank = data.rank;
			_bonus = data.bonus;
		}
		
		public function get iconTextureName():String { return _iconTextureName; }
		public function get rank():String { return _rank; }
		public function get bonus():String { return _bonus; }
	}
}