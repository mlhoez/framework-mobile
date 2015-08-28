/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Based on the work of Vincent Petithory https://github.com/vincent-petithory/as3-gettext
Framework mobile
Author  : Maxime Lhoez
Created : 7 mai 2014
*/
package com.ludofactory.common.gettext.aliases 
{
	
	/**
	 * Sometimes you can have content that is created at runtime as static properties.
	 * 
	 * Because of this, the data won't be recreated and the text won't change when the language is changed. To help
	 * managing this kind of content, the object must use gettext on a key, let's say something like _(trophyData.title);
	 * 
	 * The problem of this is that when we use POEdit to scan the project, it won't be able to retrieve the original
	 * keys and we will have missing translations.
	 * 
	 * To solve this problem, you can use this function like this : trophydata.title = _f(originalTitleKey). This way,
	 * POEdit will be able to scan the key and add it to the file.
	 */	
	public function _f(key:String):String
	{
		return key;
	}
}