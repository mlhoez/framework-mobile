/*
Copyright © 2006-2014 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 4 sept. 2013
*/
package com.ludofactory.mobile.core.navigation.faq
{
	public class FaqQuestionAnswerData
	{
		/**
		 * The question translation key. */		
		private var _question:String;
		
		/**
		 * The answer translation key. */		
		private var _answer:String;
		
		public function FaqQuestionAnswerData(data:Object = null)
		{
			// this is necessary or Flash won"t be able to deserialize the object because
			// when we retreive a SharedObject containing this custom class, the parameter
			// of the constructor will (always ?) be null. So we need to set a default value
			// in the constructor and then, check if this value is equal to null or not.
			// The object will be juste fine after, like it was saved in the SharedObject, so
			// this is weird but works juste fine.
			if( !data ) return;
			
			_question = data.question;
			_answer = data.reponse;
		}
		
		public function get question():String { return _question; }
		public function set question(val:String):void { _question = val; }
		
		public function get answer():String { return _answer; }
		public function set answer(val:String):void { _answer = val; }
	}
}