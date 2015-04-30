/*
Copyright © 2006-2015 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 2 oct. 2013
*/
package com.ludofactory.mobile.navigation.home
{
	import com.ludofactory.mobile.core.events.LudoEventType;
	
	import starling.events.EventDispatcher;
	
	/**
	 * Alert data.
	 */	
	public class AlertData extends EventDispatcher
	{
		/**
		 *  */		
		private var _numGainAlerts:int = 0;
		
		/**
		 *  */		
		private var _numSponsorAlerts:int = 0;
		
		/**
		 *  */		
		private var _numCustomerServiceAlerts:int = 0;
		
		/**
		 *  */		
		private var _numCustomerServiceImportantAlerts:int = 0;
		
		/**
		 *  */		
		private var _numTrophiesAlerts:int = 0;
		
		public function AlertData()
		{
			
		}
		
		/**
		 * Parse the alert data.
		 */		
		public function parse(val:Object):void
		{
			if( val )
			{
				_numGainAlerts = int(val.gains);
				_numSponsorAlerts = int(val.parrainage);
				_numCustomerServiceAlerts = int(val.service_client);
				_numCustomerServiceImportantAlerts = int(val.service_client_important);
				_numTrophiesAlerts = int(val.coupe);
			}
		}
		
		public function onUserLoggedOut():void
		{
			_numGainAlerts = 0;
			_numSponsorAlerts = 0;
			_numCustomerServiceAlerts = 0;
			_numCustomerServiceImportantAlerts = 0;
			_numTrophiesAlerts = 0;
			dispatchEventWith(LudoEventType.ALERT_COUNT_UPDATED);
		}
		
		public function get numGainAlerts():int { return _numGainAlerts; }
		public function set numGainAlerts(val:int):void
		{
			_numGainAlerts = val;
			dispatchEventWith(LudoEventType.ALERT_COUNT_UPDATED);
		}
		
		public function get numSponsorAlerts():int { return _numSponsorAlerts; }
		public function set numSponsorAlerts(val:int):void
		{
			_numSponsorAlerts = val;
			dispatchEventWith(LudoEventType.ALERT_COUNT_UPDATED);
		}
		
		public function get numCustomerServiceAlerts():int { return _numCustomerServiceAlerts; }
		public function set numCustomerServiceAlerts(val:int):void
		{
			_numCustomerServiceAlerts = val;
			dispatchEventWith(LudoEventType.ALERT_COUNT_UPDATED);
		}
		
		public function get numCustomerServiceImportantAlerts():int { return _numCustomerServiceImportantAlerts; }
		public function set numCustomerServiceImportantAlerts(val:int):void
		{
			_numCustomerServiceImportantAlerts = val;
			dispatchEventWith(LudoEventType.ALERT_COUNT_UPDATED);
		}
		
		public function get numTrophiesAlerts():int { return _numTrophiesAlerts; }
		public function set numTrophiesAlerts(val:int):void
		{
			_numTrophiesAlerts = val;
			dispatchEventWith(LudoEventType.ALERT_COUNT_UPDATED);
		}
		
		public function get numAlerts():int { return (_numGainAlerts + _numSponsorAlerts + _numCustomerServiceImportantAlerts + _numTrophiesAlerts) }
		
	}
}