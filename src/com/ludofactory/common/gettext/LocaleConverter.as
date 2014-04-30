/*
Copyright © 2006-2014 Ludo Factory
Based on the work of Vincent Petithory https://github.com/vincent-petithory/as3-gettext
Framework mobile
Author  : Maxime Lhoez
Created : 7 mai 2014
*/
package com.ludofactory.common.gettext
{
	import flash.system.Capabilities;

	public class LocaleConverter
	{
		/**
		 * @private
		 */
		private static const __FP_ISO639_TO_LOCALE__:Object = { 
			'cs'    : 'cs_CZ',
			'da'    : 'da_DK',
			'nl'    : 'nl_NL',
			'en'    : 'en_US',
			'fi'    : 'fi_FI',
			'fr'    : 'fr_FR',
			'de'    : 'de_DE',
			'hu'    : 'hu_HU',
			'it'    : 'it_IT',
			'ja'    : 'ja_JP',
			'ko'    : 'ko_KR',
			'no'    : 'no_NO',
			'xu'    : 'en_US',
			'pl'    : 'pl_PL',
			'pt'    : 'pt_PT',
			'ru'    : 'ru_RU',
			'zh-CN' : 'zh_CN',
			'es'    : 'es_ES',
			'sv'    : 'sv_SE',
			'zh-TW' : 'zh_TW',
			'tr'    : 'tr_TR' 
		};
		
		/**
		 * The native locale of the system, which defaults to the language 
		 * Flash Player determines (see the table below).
		 * 
		 * <p>As Flash Player only determines a language code, not a full locale, 
		 * a locale is made out of that language code. When Flash Player 
		 * encounters an unknown locale, then en_US is used by default.
		 * The following table 
		 * shows the mapping between flash player language codes and locales 
		 * (an ISO 639-1 code, followed by a _ character, followed by an 
		 * ISO 3166 code) :</p>
		 * <table class="innertable">
		 *     <tr><th>Flash Player language code</th><th>Locale</th></tr>
		 *     <tr><td>cs</td><td>cs_CZ</td></tr>
		 *     <tr><td>da</td><td>da_DK</td></tr>
		 *     <tr><td>nl</td><td>nl_NL</td></tr>
		 *     <tr><td>en</td><td>en_US</td></tr>
		 *     <tr><td>fi</td><td>fi_FI</td></tr>
		 *     <tr><td>fr</td><td>fr_FR</td></tr>
		 *     <tr><td>de</td><td>de_DE</td></tr>
		 *     <tr><td>hu</td><td>hu_HU</td></tr>
		 *     <tr><td>it</td><td>it_IT</td></tr>
		 *     <tr><td>ja</td><td>ja_JP</td></tr>
		 *     <tr><td>ko</td><td>ko_KR</td></tr>
		 *     <tr><td>no</td><td>no_NO</td></tr>
		 *     <tr><td>xu</td><td>en_US</td></tr>
		 *     <tr><td>pl</td><td>pl_PL</td></tr>
		 *     <tr><td>pt</td><td>pt_PT</td></tr>
		 *     <tr><td>ru</td><td>ru_RU</td></tr>
		 *     <tr><td>zh-CN</td><td>zh_CN</td></tr>
		 *     <tr><td>es</td><td>es_ES</td></tr>
		 *     <tr><td>sv</td><td>sv_SE</td></tr>
		 *     <tr><td>zh-TW</td><td>zh_TW</td></tr>
		 *     <tr><td>tr</td><td>tr_TR</td></tr>
		 * </table>
		 * 
		 */
		public static const LANG:String = __FP_ISO639_TO_LOCALE__[Capabilities.language];
	}
}