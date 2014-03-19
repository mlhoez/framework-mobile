/*
LudoFactory
Framework mobile
Author  : Maxime Lhoez
Created : 2 sept. 2013
*/
package com.ludofactory.mobile.core.test.faq
{
	public class FaqData
	{
		/**
		 * The category translation key. */		
		private var _categoryName:String;
		
		/**
		 * The array of questions and answers. */		
		private var _content:Vector.<FaqQuestionAnswerData>;
		
		public function FaqData(data:Object = null)
		{
			// this is necessary or Flash won"t be able to deserialize the object because
			// when we retreive a SharedObject containing this custom class, the parameter
			// of the constructor will (always ?) be null. So we need to set a default value
			// in the constructor and then, check if this value is equal to null or not.
			// The object will be juste fine after, like it was saved in the SharedObject, so
			// this is weird but works juste fine.
			if( !data ) return;
			
			_categoryName = data.titre;
			_content = new Vector.<FaqQuestionAnswerData>();
			for(var i:int = 0; i < data.articles.length; i++)
				_content.push( new FaqQuestionAnswerData(data.articles[i]) );
		}
		
		public function get categoryName():String { return _categoryName; }
		public function set categoryName(val:String):void { _categoryName = val; }
		
		public function get content():Vector.<FaqQuestionAnswerData> { return _content; }
		public function set content(val:Vector.<FaqQuestionAnswerData>):void { _content = val; }
	}
}