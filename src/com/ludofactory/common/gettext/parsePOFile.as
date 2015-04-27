/*
Copyright © 2006-2014 Ludo Factory
Based on the work of Vincent Petithory https://github.com/vincent-petithory/as3-gettext
Framework mobile
Author  : Maxime Lhoez
Created : 7 mai 2014
*/
package com.ludofactory.common.gettext
{
	import com.gamua.flox.Flox;
	import com.ludofactory.common.utils.log;
	
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.Dictionary;

	/**
	 * Parses the bytes representing a PO file, extracting the metadatas and
	 * the translations.
	 * 
	 * @param poFile The .po file on the device
	 * 
	 * @return A POFile instance containing the informations of the original .po file.
	 */
	public function parsePOFile(poFile:File):POFile
	{
		if( poFile == null || !poFile.exists )
			throw new Error("The <poFile> parameter must be non null et must exists on the device.");
		
		log("[parsePOFile] Parsing " + poFile.name);
		
		var stream:FileStream = new FileStream();
		stream.open(poFile, FileMode.READ);
		
		// read the given .po file content : the content is the cleaned version of
		// the original .po file used by translators (this cleaned version is created
		// before being uploaded on the server, but also here once downloaded by securty).
		var rawContent:String = stream.readUTFBytes(stream.bytesAvailable);
		
		// Important : use : (?>\r\n|[\r\n]) to match the \r or \n on all OS
		// /!\ this is needed here also (it was in LanguageManager) because the first time the app loads,
		// the file is not parsed correctly otherwise !
		// replace all the comments => /^#.*$/gm ----- or /^#.*$(\r|\n)|(\n|\r){3,}/gm
		rawContent = rawContent.replace(/^#.*$/gm, "");
		// then reconstruct the strings that are on 2 a more lines = /"(\r|\n)"/g
		rawContent = rawContent.replace(/"(?>\r\n|[\r\n])"/gm, "");
		// then replace the line breaks greater than 2 => /(\r|\n){2,}/g
		rawContent = rawContent.replace(/(?>\r\n|[\r\n]){2,}/gm, "\n\n");
		
		// split the content into an array : /\n{2,}/g splits the double (or more) line
		// breaks which defines a translation block
		var contentList:Array = rawContent.split(/(?>\r\n|[\r\n]){2,}/g);
		
		// POFile
		var parsedPOFile:POFile = new POFile();
		
		try
		{
			// the header is in the first line
			var header:String = contentList.shift();
			if( !header || header == "" || header == "msgid \"\"")
				header = contentList.shift();
			// Project-Id-Version
			parsedPOFile.projectIdVersion = header.match(PROJECT_ID_VERSION_PATTERN)[0];
			// POT-Creaation-Date - YYYY-MM-DD HH::MM(+|-HHMM)
			var rawPotCreationDate:String = header.match(POT_CREATION_DATE_PATTERN)[0];
			parsedPOFile.potCreationDate = new Date( Date.parse( rawPotCreationDate.replace(DATE_PATTERN, DATE_PATTERN_REPL) ) );
			// POT-Revision-Date - YYYY-MM-DD HH::MM(+|-HHMM)
			var rawPoRevisionDate:String = header.match(PO_REVISION_DATE_PATTERN)[0];
			parsedPOFile.potRevisionDate = new Date( Date.parse( rawPoRevisionDate.replace(DATE_PATTERN, DATE_PATTERN_REPL) ) );
			// Last-Translator
			parsedPOFile.lastTranslator = header.match(LAST_TRANSLATOR_PATTERN)[0];
			// Language-Team
			parsedPOFile.languageTeam = header.match(LANGUAGE_TEAM_PATTERN)[0];
			// Language
			parsedPOFile.language = header.match(LANGUAGE_PATTERN)[0];
			// MIME-Version
			parsedPOFile.mimeVersion = header.match(MIME_VERSION_PATTERN)[0];
			// Content-Type
			parsedPOFile.contentType = header.match(CONTENT_TYPE_PATTERN)[0];
			// Charset
			parsedPOFile.charset = header.match(CHARSET_PATTERN)[0];
			// Content-Transfert-Encoding
			parsedPOFile.contentTransfertEncoding = header.match(CONTENT_TRANSFER_ENCODING_PATTERN)[0];
			// Plural-Forms (nplurals)
			parsedPOFile.pluralFormsCount = header.match(PLURAL_FORMS_COUNT_PATTERN)[0];
			// Plural-Forms (expression)
			parsedPOFile.pluralFormsExpression = header.match(PLURAL_FORMS_EXPRESSION_PATTERN)[0];
			
			// translations
			var count:int = contentList.length;
			var translations:Dictionary = new Dictionary();
			var currentBlock:Array;
			for(var i:int = 0; i < count; i++)
			{
				currentBlock = contentList[i].match(CONTENT_PATTERN);
				if( currentBlock.length <= 2 ) // simple translation
					translations[currentBlock[0]] = currentBlock[1];
				else // plural included
					translations[currentBlock[0]] = currentBlock.length >= 4 ? currentBlock.splice(2) : [];
			}
			parsedPOFile.translations = translations;
		} 
		catch(error:Error) 
		{
			Flox.logWarning("Could not parse language file " + error);
		}
		
		return parsedPOFile;
	}
}

// header patterns
internal const PROJECT_ID_VERSION_PATTERN:RegExp = /(?<=Project-Id-Version: )([^\"]*?)(?=\\n)/ig;
internal const POT_CREATION_DATE_PATTERN:RegExp = /(?<=POT-Creation-Date: )([^\"]*?)(?=\\n)/ig;
internal const PO_REVISION_DATE_PATTERN:RegExp = /(?<=PO-Revision-Date: )([^\"]*?)(?=\\n)/ig;
internal const LAST_TRANSLATOR_PATTERN:RegExp = /(?<=Last-Translator: )([^\"]*?)(?=\\n)/ig;
internal const LANGUAGE_TEAM_PATTERN:RegExp = /(?<=Language-Team: )([^\"]*?)(?=\\n)/ig;
internal const LANGUAGE_PATTERN:RegExp = /(?<=Language: )([^\"]*?)(?=\\n)/ig;
internal const MIME_VERSION_PATTERN:RegExp = /(?<=MIME-Version: )([^\"]*?)(?=\\n)/ig;
internal const CONTENT_TYPE_PATTERN:RegExp = /(?<=Content-Type: )([^\"]*?)(?=;)/ig;
internal const CHARSET_PATTERN:RegExp = /(?<=charset=)([^\"]*?)(?=\\n)/ig;
internal const CONTENT_TRANSFER_ENCODING_PATTERN:RegExp = /(?<=Content-Transfer-Encoding: )([^\"]*?)(?=\\n)/ig;
internal const PLURAL_FORMS_COUNT_PATTERN:RegExp = /(?<=nplurals=)([^\"]*?)(?=\;)/ig;
internal const PLURAL_FORMS_EXPRESSION_PATTERN:RegExp = /(?<=plural=)([^\"]*?)(?=\\n)/ig;

/**
 * Strips out the text of each property (msgid, msgid_plural, msgstr, msgstr[n], etc.) */
internal const CONTENT_PATTERN:RegExp = /((?<=msgstr\s\")|(?<=msgid_plural\s\")|(?<=msgid\s\")|(?<=msgstr\[[0-9]\]\s\"))([^\"]*?)(?=\")/g;
internal const DATE_PATTERN:RegExp = /(\d+)-(\d+)-(\d+) (\d+):(\d+)(\+|-\d+)/g;
internal const DATE_PATTERN_REPL:String = "$1/$2/$3 $4:$5 GMT$6";