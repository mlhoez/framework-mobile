/*
Copyright © 2006-2015 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 2 oct. 2013
*/
package com.ludofactory.mobile.core.push
{
	public class PushTrophy extends AbstractElementToPush
	{
		/**
		 * The trophy id. */		
		private var _trophyId:int;
		
		public function PushTrophy(pushType:String = null, trophyId:int = -1)
		{
			super(pushType);
			
			if( trophyId == -1 )
				return;
			
			_trophyId = trophyId;
		}
		
//------------------------------------------------------------------------------------------------------------
//	Get - Set
		
		// since this class is saved in the EncryptedLocalStore, everything has to be r/w !
		
		public function get trophyId():int { return _trophyId; }
		public function set trophyId(val:int):void { _trophyId = val; }
	}
}