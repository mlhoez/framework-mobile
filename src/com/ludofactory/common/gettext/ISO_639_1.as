/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Based on the work of Vincent Petithory https://github.com/vincent-petithory/as3-gettext
Framework mobile
Author  : Maxime Lhoez
Created : 7 mai 2014
*/
package com.ludofactory.common.gettext
{
    import flash.utils.describeType;
    
    /**
     * The ISO_639_1 class enumerates the country codes as defined by 
     * the ISO 639-1 standard.
     */
    public final class ISO_639_1 
    {
        
        /**
         * @private
         */
        private static var _codes:Object;
        
        /**
         * A hashtable that associates the constants to their language code.
         * <p>For example, ISO_639_1.FR returns the name of the language
         * (French).<br/>
         * ISO_639_1.codes[ISO_639_1.FR] returns the language code (fr).</p>
         * 
         */
        public static function get codes():Object
        {
            if (_codes != null)
                return _codes;
            var codeConstants:XMLList = describeType(ISO_639_1).constant;
            _codes = {};
            var codeConstant:XML;
            for each (codeConstant in codeConstants)
            {
                var name:String = codeConstant.@name;
                codes[ISO_639_1[name]] = name.toLowerCase();
            }
            return codes;
        }
        
		// _("Afar.")
        public static const AA:String = "Afar.";
		// _("Abkhazian")
        public static const AB:String = "Abkhazian";
		// _("Adangme")
        public static const AD:String = "Adangme";
		// _("Avestan")
        public static const AE:String = "Avestan";
		// _("Afrikaans")
        public static const AF:String = "Afrikaans";
		// _("Akan")
        public static const AK:String = "Akan";
		// _("Amharic")
        public static const AM:String = "Amharic";
		// _("Aragonese")
        public static const AN:String = "Aragonese";
		// _("Arabic")
        public static const AR:String = "Arabic";
		// _("Assamese")
        public static const AS:String = "Assamese";
		// _("Avaric")
        public static const AV:String = "Avaric";
		// _("Aymara")
        public static const AY:String = "Aymara";
		// _("Azerbaijani")
        public static const AZ:String = "Azerbaijani";
		// _("Bashkir")
        public static const BA:String = "Bashkir";
		// _("Byelorussian; Belarusian")
        public static const BE:String = "Byelorussian; Belarusian";
		// _("Bulgarian")
        public static const BG:String = "Bulgarian";
		// _("Bihari")
        public static const BH:String = "Bihari";
		// _("Bislama")
        public static const BI:String = "Bislama";
		// _("Bambara")
        public static const BM:String = "Bambara";
		// _("Bengali; Bangla")
        public static const BN:String = "Bengali; Bangla";
		// _("Tibetan")
        public static const BO:String = "Tibetan";
		// _("Breton")
        public static const BR:String = "Breton";
		// _("Bosnian")
        public static const BS:String = "Bosnian";
		// _("Catalan")
        public static const CA:String = "Catalan";
		// _(""Chechen)
        public static const CE:String = "Chechen";
		// _("Chamorro")
        public static const CH:String = "Chamorro";
		// _("Corsican")
        public static const CO:String = "Corsican";
		// _("Cree")
        public static const CR:String = "Cree";
		// _("Czech")
        public static const CS:String = "Czech";
		// _("Church Slavic")
        public static const CU:String = "Church Slavic";
		// _("Chuvash")
        public static const CV:String = "Chuvash";
		// _("Welsh")
        public static const CY:String = "Welsh";
		// _("Danish")
        public static const DA:String = "Danish";
		// _("German")
        public static const DE:String = "German";
		// _("Divehi; Maldivian")
        public static const DV:String = "Divehi; Maldivian";
		// _("Dzongkha; Bhutani")
        public static const DZ:String = "Dzongkha; Bhutani";
		// _("Ewe")
        public static const EE:String = "Ewe";
		// _("Greek")
        public static const EL:String = "Greek";
		// _("English")
        public static const EN:String = "English";
		// _("Esperanto")
        public static const EO:String = "Esperanto";
		// _("Spanish")
        public static const ES:String = "Spanish";
		// _("Estonian")
        public static const ET:String = "Estonian";
		// _("Basque")
        public static const EU:String = "Basque";
		// _("Persian")
        public static const FA:String = "Persian";
		// _("Fulah")
        public static const FF:String = "Fulah";
		// _("Finnish")
        public static const FI:String = "Finnish";
		// _("Fijian; Fiji")
        public static const FJ:String = "Fijian; Fiji";
		// _("Faroese")
        public static const FO:String = "Faroese";
		// _("French")
        public static const FR:String = "French";
		// _("Western Frisian")
        public static const FY:String = "Western Frisian";
		// _("Irish")
        public static const GA:String = "Irish";
		// _("Scots; Gaelic")
        public static const GD:String = "Scots; Gaelic";
		// _("Galician")
        public static const GL:String = "Galician";
		// _("Guarani")
        public static const GN:String = "Guarani";
		// _("Gujarati")
        public static const GU:String = "Gujarati";
		// _("Manx")
        public static const GV:String = "Manx";
		// _("Hausa")
        public static const HA:String = "Hausa";
		// _("Hebrew (formerly iw)")
        public static const HE:String = "Hebrew (formerly iw)";
		// _("Hindi")
        public static const HI:String = "Hindi";
		// _("Hiri Motu")
        public static const HO:String = "Hiri Motu";
		// _("Croatian")
        public static const HR:String = "Croatian";
		// _("Haitian; Haitian Creole")
        public static const HT:String = "Haitian; Haitian Creole";
		// _("Hungarian")
        public static const HU:String = "Hungarian";
		// _("Armenian")
        public static const HY:String = "Armenian";
		// _("Herero")
        public static const HZ:String = "Herero";
		// _("Interlingua")
        public static const IA:String = "Interlingua";
		// _("Indonesian (formerly in)")
        public static const ID:String = "Indonesian (formerly in)";
		// _("Interlingue")
        public static const IE:String = "Interlingue";
		// _("Igbo")
        public static const IG:String = "Igbo";
		// _("Inupiak; Inupiaq")
        public static const IK:String = "Inupiak; Inupiaq";
		// _("Ido")
        public static const IO:String = "Ido";
		// _("Icelandic")
        public static const IS:String = "Icelandic";
		// _("Italian")
        public static const IT:String = "Italian";
		// _("Inuktitut")
        public static const IU:String = "Inuktitut";
		// _("Japanese")
        public static const JA:String = "Japanese";
		// _("Javanese")
        public static const JV:String = "Javanese";
		// _("Georgian")
        public static const KA:String = "Georgian";
		// _(""Kongo)
        public static const KG:String = "Kongo";
		// _("Kikuyu; Gikuyu")
        public static const KI:String = "Kikuyu; Gikuyu";
		// _("Kuanyama; Kwanyama")
        public static const KJ:String = "Kuanyama; Kwanyama";
		// _("Kazakh")
        public static const KK:String = "Kazakh";
		// _("Kalaallisut; Greenlandic")
        public static const KL:String = "Kalaallisut; Greenlandic";
		// _("Khmer; Cambodian")
        public static const KM:String = "Khmer; Cambodian";
		// _("Kannada")
        public static const KN:String = "Kannada";
		// _("Korean")
        public static const KO:String = "Korean";
		// _("Kashmiri")
        public static const KS:String = "Kashmiri";
		// _("Kurdish")
        public static const KU:String = "Kurdish";
		// _("Komi")
        public static const KV:String = "Komi";
		// _("Cornish")
        public static const KW:String = "Cornish";
		// _("Kirghiz")
        public static const KY:String = "Kirghiz";
		// _("Latin")
        public static const LA:String = "Latin";
		// _("Letzeburgesch; Luxembourgish")
        public static const LB:String = "Letzeburgesch; Luxembourgish";
		// _("Ganda")
        public static const LG:String = "Ganda";
		// _("Limburgish; Limburger; Limburgan")
        public static const LI:String = "Limburgish; Limburger; Limburgan";
		// _("Lingala")
        public static const LN:String = "Lingala";
		// _("Lao; Laotian")
        public static const LO:String = "Lao; Laotian";
		// _("Lithuanian")
        public static const LT:String = "Lithuanian";
		// _("Luba-Katanga")
        public static const LU:String = "Luba-Katanga";
		// _("Latvian; Lettish")
        public static const LV:String = "Latvian; Lettish";
		// _("Malagasy")
        public static const MG:String = "Malagasy";
		// _("Marshallese")
        public static const MH:String = "Marshallese";
		// _("Maori")
        public static const MI:String = "Maori";
		// _("Macedonian")
        public static const MK:String = "Macedonian";
		// _("Malayalam")
        public static const ML:String = "Malayalam";
		// _("Mongolian")
        public static const MN:String = "Mongolian";
		// _("Moldavian")
        public static const MO:String = "Moldavian";
		// _("Marathi")
        public static const MR:String = "Marathi";
		// _("Malay")
        public static const MS:String = "Malay";
		// _("Maltese")
        public static const MT:String = "Maltese";
		// _("Burmese")
        public static const MY:String = "Burmese";
		// _("Nauru")
        public static const NA:String = "Nauru";
		// _("Norwegian Bokm�l")
        public static const NB:String = "Norwegian Bokm�l";
		// _("Ndebele; North")
        public static const ND:String = "Ndebele; North";
		// _("Nepali")
        public static const NE:String = "Nepali";
		// _("Ndonga")
        public static const NG:String = "Ndonga";
		// _("Dutch")
        public static const NL:String = "Dutch";
		// _("Norwegian Nynorsk")
        public static const NN:String = "Norwegian Nynorsk";
		// _("Norwegian")
        public static const NO:String = "Norwegian";
		// _("Ndebele; South")
        public static const NR:String = "Ndebele; South";
		// _("Navajo; Navaho")
        public static const NV:String = "Navajo; Navaho";
		// _("Chichewa; Nyanja")
        public static const NY:String = "Chichewa; Nyanja";
		// _("Occitan; Provençal")
        public static const OC:String = "Occitan; Provençal";
		// _("(Afan) Oromo")
        public static const OM:String = "(Afan) Oromo";
		// _("Oriya")
        public static const OR:String = "Oriya";
		// _("Ossetian; Ossetic")
        public static const OS:String = "Ossetian; Ossetic";
		// _("Panjabi; Punjabi")
        public static const PA:String = "Panjabi; Punjabi";
		// _("Pali")
        public static const PI:String = "Pali";
		// _("Polish")
        public static const PL:String = "Polish";
		// _("Pashto; Pushto")
        public static const PS:String = "Pashto; Pushto";
		// _("Portuguese")
        public static const PT:String = "Portuguese";
		// _("Quechua")
        public static const QU:String = "Quechua";
		// _("Rhaeto-Romance")
        public static const RM:String = "Rhaeto-Romance";
		// _("Rundi; Kirundi")
        public static const RN:String = "Rundi; Kirundi";
		// _("Romanian")
        public static const RO:String = "Romanian";
		// _("Russian")
        public static const RU:String = "Russian";
		// _("Kinyarwanda")
        public static const RW:String = "Kinyarwanda";
		// _("Sanskrit")
        public static const SA:String = "Sanskrit";
		// _("Sardinian")
        public static const SC:String = "Sardinian";
		// _("Sindhi")
        public static const SD:String = "Sindhi";
		// _("Northern Sami")
        public static const SE:String = "Northern Sami";
		// _("Sango; Sangro")
        public static const SG:String = "Sango; Sangro";
		// _("Sinhala; Sinhalese")
        public static const SI:String = "Sinhala; Sinhalese";
		// _("Slovak")
        public static const SK:String = "Slovak";
		// _("Slovenian")
        public static const SL:String = "Slovenian";
		// _("Samoan")
        public static const SM:String = "Samoan";
		// _("Shona")
        public static const SN:String = "Shona";
		// _("Somali")
        public static const SO:String = "Somali";
		// _("Albanian")
        public static const SQ:String = "Albanian";
		// _("Serbian")
        public static const SR:String = "Serbian";
		// _("Swati; Siswati")
        public static const SS:String = "Swati; Siswati";
		// _("Sesotho; Sotho; Southern")
        public static const ST:String = "Sesotho; Sotho; Southern";
		// _("Sundanese")
        public static const SU:String = "Sundanese";
		// _("Swedish")
        public static const SV:String = "Swedish";
		// _("Swahili")
        public static const SW:String = "Swahili";
		// _("Tamil")
        public static const TA:String = "Tamil";
		// _("Telugu")
        public static const TE:String = "Telugu";
		// _("Tajik")
        public static const TG:String = "Tajik";
		// _("Thai")
        public static const TH:String = "Thai";
		// _("Tigrinya")
        public static const TI:String = "Tigrinya";
		// _("Turkmen")
        public static const TK:String = "Turkmen";
		// _("Tagalog")
        public static const TL:String = "Tagalog";
		// _("Tswana; Setswana")
        public static const TN:String = "Tswana; Setswana";
		// _("Tonga")
        public static const TO:String = "Tonga";
		// _("Turkish")
        public static const TR:String = "Turkish";
		// _("Tsonga")
        public static const TS:String = "Tsonga";
		// _("Tatar")
        public static const TT:String = "Tatar";
		// _("Twi")
        public static const TW:String = "Twi";
		// _("Tahitian")
        public static const TY:String = "Tahitian";
		// _("Uighur")
        public static const UG:String = "Uighur";
		// _("Ukrainian")
        public static const UK:String = "Ukrainian";
		// _("Urdu")
        public static const UR:String = "Urdu";
		// _("Uzbek")
        public static const UZ:String = "Uzbek";
		// _("Vietnamese")
        public static const VI:String = "Vietnamese";
		// _("Volap�k; Volapuk")
        public static const VO:String = "Volap�k; Volapuk";
		// _("Walloon")
        public static const WA:String = "Walloon";
		// _("Wolof")
        public static const WO:String = "Wolof";
		// _("Xhosa")
        public static const XH:String = "Xhosa";
		// _("Yiddish (formerly ji)")
        public static const YI:String = "Yiddish (formerly ji)";
		// _("Yoruba")
        public static const YO:String = "Yoruba";
		// _("Zhuang")
        public static const ZA:String = "Zhuang";
		// _("Chinese")
        public static const ZH:String = "Chinese";
		// _("Zulu")
        public static const ZU:String = "Zulu";
		
    }
        
}
