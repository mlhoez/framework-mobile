/*
LudoFactory
Framework mobile
Author  : Maxime Lhoez
Created : 8 sept. 2013
*/
package com.ludofactory.mobile.core.test.sponsor.invite
{
	/**
	 * Contact data.
	 */	
	public class ContactData
	{
		/**
		 * The sponsor type whether email or sms. */		
		private var _sponsorType:String;
		
		/**
		 * Name of the contact. */		
		private var _name:String;
		
		/**
		 * Array of phone numbers. */		
		private var _phones:Array;
		
		/**
		 * Array of emails. */		
		private var _emails:Array;
		
		/**
		 * The selected contact element. */		
		private var _selectedContactElement:String;
		
		public function ContactData(data:Object, sponsorType:String)
		{
			_sponsorType = sponsorType;
			
			if( data.hasOwnProperty("compositename") && data.compositename )
				_name = String(data.compositename);
			
			if( data.hasOwnProperty("phones") && data.phones && (data.phones as Array).length > 0 )
			{
				_phones = data.phones;
				if( _sponsorType == SponsorTypes.SMS )
					_selectedContactElement = _phones[0];
			}
			
			if( data.hasOwnProperty("emails") && data.emails && (data.emails as Array).length > 0 )
			{
				_emails = data.emails;
				if( _sponsorType == SponsorTypes.EMAIL )
					_selectedContactElement = _emails[0];
			}
		}
		
		public function get sponsorType():String { return _sponsorType; }
		public function get name():String { return _name; }
		public function get phones():Array { return _phones; }
		public function get emails():Array { return _emails; }
		
		public function get selectedContactElement():String { return _selectedContactElement; }
		public function set selectedContactElement(val:String):void { _selectedContactElement = val; }
	}
}