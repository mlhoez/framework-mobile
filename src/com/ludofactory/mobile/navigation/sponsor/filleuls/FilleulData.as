/*
Copyright © 2006-2015 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 9 oct. 2013
*/
package com.ludofactory.mobile.navigation.sponsor.filleuls
{
	/**
	 * Filleul data.
	 */	
	public class FilleulData
	{
		/**
		 * "{Filleul Name}" */		
		private var _filleulName:String;
		
		/**
		 * "(Filleul {id})" */		
		private var _filleulId:String;
		
		/**
		 * Whether the email of phone number. */		
		private var _contact:String;
		
		/**
		 * The information about the actual state of
		 * this sponsoring. */		
		private var _information:String;
		
		/**
		 * The type used to display the correct state. */		
		private var _type:int;
		
		/**
		 * The date when the first reward was obtained. If not obtained
		 * yet, the value is "-". */		
		private var _firstRewardDate:String;
		/**
		 * The first reward name, ex : "10 000 Points" */		
		private var _firstRewardName:String;
		
		/**
		 * The date when the second reward was obtained. If not obtained
		 * yet, the value is "-". */		
		private var _secondRewardDate:String;
		/**
		 * The second reward name, ex : "10 000 Points" */		
		private var _secondRewardName:String;
		
		/**
		 * The date when the third reward was obtained. If not obtained
		 * yet, the value is "-". */		
		private var _thirdRewardDate:String;
		/**
		 * The third reward name, ex : "10 000 Points" */		
		private var _thirdRewardName:String;
		
		/**
		 * The date when the fourth reward was obtained. If not obtained
		 * yet, the value is "-". */		
		private var _fourthRewardDate:String;
		/**
		 * The fourth reward name, ex : "10 000 Points" */		
		private var _fourthRewardName:String;
		
		public function FilleulData(data:Object)
		{
			_type = int(data.etat);
			_filleulName = data.identite_filleul;
			_filleulId = data.identite_filleul_id;
			_contact = data.email_filleul;
			_information = data.commentaire;
			
			_firstRewardDate = data.gain1_date;
			_firstRewardName = data.gain1_nom;
			
			_secondRewardDate = data.gain2_date;
			_secondRewardName = data.gain2_nom;
			
			_thirdRewardDate = data.gain3_date;
			_thirdRewardName = data.gain3_nom;
			
			_fourthRewardDate = data.gain4_date;
			_fourthRewardName = data.gain4_nom;
		}
		
		public function get type():int { return _type; }
		public function get filleulName():String { return _filleulName; }
		public function get filleulId():String { return _filleulId; }
		public function get contact():String { return _contact; }
		public function get information():String { return _information; }
		public function get firstRewardDate():String { return _firstRewardDate; }
		public function get firstRewardName():String { return _firstRewardName; }
		public function get secondRewardDate():String { return _secondRewardDate; }
		public function get secondRewardName():String { return _secondRewardName; }
		public function get thirdRewardDate():String { return _thirdRewardDate; }
		public function get thirdRewardName():String { return _thirdRewardName; }
		public function get fourthRewardDate():String { return _fourthRewardDate; }
		public function get fourthRewardName():String { return _fourthRewardName; }
	}
}