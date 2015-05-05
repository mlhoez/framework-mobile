/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 7 août 2013
*/
package com.ludofactory.mobile.core.storage
{
	import com.ludofactory.mobile.core.scoring.ScoreToPointsData;
	import com.ludofactory.mobile.core.scoring.ScoreToStarsData;
	import com.ludofactory.mobile.core.storage.test.DefaultFaq;
	import com.ludofactory.mobile.core.storage.test.DefaultTermsAndConditions;
	import com.ludofactory.mobile.core.storage.test.DefaultVip;
	import com.ludofactory.mobile.navigation.cs.CSThemeData;
	import com.ludofactory.mobile.navigation.settings.LanguageData;
	
	/**
	 * Each property...
	 */	
	public class StorageConfig
	{
		
		/**
		 * This is a global SharedObject (not associated to a user actually
		 * logged in) that will store many different kind of data associated
		 * to the application :
		 * 
		 * <p>Actually, this SharedObject will store :</p>
		 * 
		 * <p><strong>[firstLaunch] - Boolean</strong><br />
		 * Determines if this is the first launch of the application.
		 * Depending on this value, some default values will be set to most of
		 * the properties listed below.
		 * 
		 * <p><strong>[lang] - String</strong><br />
		 * This is the language actually choosed by
		 * the user and that needs to be loaded at launch. If it is the first
		 * time the application is launched, this value will be determined by
		 * the current device language (english by default). After, this value
		 * will be changed by the one choosed by the user in the preferences.</p>
		 * 
		 * <p><strong>[translations] - Dictionnary</strong><br />
		 * This is a Dictionnary containing all the languages actually parsed
		 * (from the files in the "lang/" folder in the application directory).
		 * The content of this property looks like this :<br />
		 * <i>	[fr] = { version:x, translation:dictionnary }</i><br />
		 * <i>	[en] = { version:x, translation:dictionnary }</i><br />
		 * <i>	etc.</i><br />
		 * The value of "translation" is a Dictionnary containing all the
		 * keys and their matching pair, used for translation.<br />
		 * <i>Ex : [COMMON.LOADING] = Loading...</i></p>
		 * 
		 * <p><strong>[pointsTable] - Array</strong><br />
		 * This is an array containing for each level of score (defined by
		 * an inferior and a superior limit) the corresponding value in terms
		 * of points (for both free and paid game sessions).<br />
		 * <i>Ex for one row : { credit:30, gratuit:5, inf:0, sup:500 }</i></p>
		 * 
		 * <p><strong>[starsTable] - Array</strong><br />
		 * This is an array containing for each level of score (defined by
		 * an inferior and a superior limit) the corresponding value in terms
		 * of stars (there is no difference for now whether you play with points,
		 * free or paid game session.<br />
		 * <i>Ex for one row : { items:1, inf:0, sup:250 }</i></p>
		 * 
		 * @see #PROPERTY_FIRST_LAUNCH
		 * 
		 */		
		internal static const GLOBAL_CONFIG_SO_NAME:String = "pyramid_config";
		
//------------------------------------------------------------------------------------------------------------
//	Configuration default values
		
		/**
		 * <strong>This is the default value for the points table</strong><br />
		 * This is an array containing for each level of score (defined by
		 * an inferior and a superior limit) the corresponding value in terms
		 * of points (for both free and paid game sessions).<br />
		 * <i>Ex for one row : { credit:30, gratuit:5, inf:0, sup:500 }</i></p>
		 */		
		public static const DEFAULT_POINTS_TABLE:Array = [ new ScoreToPointsData( { credit:30,  gratuit:5,  inf:0,     sup:5000,    coef:[5,6] } ),
														   new ScoreToPointsData( { credit:60,  gratuit:10, inf:5001,  sup:10000,   coef:[5,6] } ),
														   new ScoreToPointsData( { credit:120, gratuit:20, inf:10001, sup:20000,   coef:[5,6] } ),
														   new ScoreToPointsData( { credit:180, gratuit:30, inf:20001, sup:30000,   coef:[5,6] } ),
														   new ScoreToPointsData( { credit:240, gratuit:40, inf:30001, sup:8388607, coef:[5,6] } ) ];
		
		/**
		 * <strong>This is the default value for the stars table</strong><br />
		 * This is an array containing for each level of score (defined by
		 * an inferior and a superior limit) the corresponding value in terms
		 * of points (for both free and paid game sessions).<br />
		 * <i>Ex for one row : { items:1, inf:0, sup:250 }</i></p>
		 */	
		public static const DEFAULT_STARS_TABLE:Array = [ new ScoreToStarsData( { items:1,  inf:0,      sup:5000 } ),
														  new ScoreToStarsData( { items:2,  inf:5001,   sup:10000 } ),
														  new ScoreToStarsData( { items:3,  inf:10001,  sup:15000 } ),
														  new ScoreToStarsData( { items:4,  inf:15001,  sup:23000 } ),
														  new ScoreToStarsData( { items:5,  inf:23001,  sup:31000 } ),
														  new ScoreToStarsData( { items:6,  inf:31001,  sup:39000 } ),
														  new ScoreToStarsData( { items:7,  inf:39001,  sup:47000 } ),
														  new ScoreToStarsData( { items:8,  inf:47001,  sup:55000 } ),
														  new ScoreToStarsData( { items:9,  inf:55001,  sup:63000 } ),
														  new ScoreToStarsData( { items:10, inf:63001,  sup:8388607 } ) ];
		
		/**
		 * <strong>This is the default value for the preferred language</strong><br />
		 * The default is "unknown" so that the Localizer know it has to parse all
		 * available languages from the file system.
		 * 
		 * @see com.ludofactory.mobile.core.Localizer
		 */		
		public static const DEFAULT_LANGUAGE:String = "unknown";
		
		/**
		 * <strong>This is the default value for the number of free game sessions
		 * required to play in free play mode.</strong> */		
		public static const DEFAULT_NUM_FREE_IN_FREE_MODE:int = 1;
		/**
		 * <strong>This is the default value for the number of free game sessions
		 * required to play in tournament mode.</strong> */	
		public static const DEFAULT_NUM_FREE_IN_TOURNAMENT_MODE:int = 4;
		/**
		 * <strong>This is the default value for the number of points
		 * required to play in tournament mode.</strong> */	
		public static const DEFAULT_NUM_POINTS_IN_TOURNAMENT_MODE:int = 1200;
		/**
		 * <strong>This is the default value for the number of credits
		 * required to play in free play mode.</strong> */	
		public static const DEFAULT_NUM_CREDITS_IN_FREE_MODE:int = 1;
		/**
		 * <strong>This is the default value for the number of credits
		 * required to play in tournament mode.</strong> */	
		public static const DEFAULT_NUM_CREDITS_IN_TOURNAMENT_MODE:int = 3;
		
		/**
		 * <strong>This is the default value for the customer service themes</strong><br />Theses values are
		 * ordered so that we can change in which index each theme should be placed. Penser à changer en base
		 * T_ServiceClientMobilec si on change une clef ici.
		 * 
		 * // Hack for POEdit
		 * _("Partie Solo");
		 * _("Tournoi");
		 * _("Problème technique");
		 * _("Cadeaux");
		 * _("Mon Compte");
		 * _("Informations");
		 * _("Autre");
		 * 
		 * */	
		public static const DEFAULT_CUSTOMER_SERVICE_THEMES:Array = [ new CSThemeData( { id:1, key:"Partie Solo",        index:1 } ),
																	  new CSThemeData( { id:2, key:"Tournoi",            index:2 } ),
																	  new CSThemeData( { id:3, key:"Problème technique", index:3 } ),
																	  new CSThemeData( { id:4, key:"Cadeaux",            index:4 } ),
																	  new CSThemeData( { id:5, key:"Mon Compte",         index:5 } ),
																	  new CSThemeData( { id:6, key:"Informations",       index:6 } ),
																	  new CSThemeData( { id:7, key:"Autre",              index:7 } ) ];

        /**
         * Different version for the non-gift players
         */
        public static const DEFAULT_CUSTOMER_SERVICE_THEMES_WITHOUT_GIFTS:Array = [ new CSThemeData( { id:1, key:"Partie Solo",        index:1 } ),
                                                                                    new CSThemeData( { id:2, key:"Tournoi",            index:2 } ),
                                                                                    new CSThemeData( { id:3, key:"Problème technique", index:3 } ),
	                                                                                new CSThemeData( { id:5, key:"Mon Compte",         index:5 } ),
                                                                                    new CSThemeData( { id:6, key:"Informations",       index:6 } ),
                                                                                    new CSThemeData( { id:7, key:"Autre",              index:7 } ) ];

		
		/**
		 * <strong>This is the default value for the game
		 * faq</strong><br />
		 * 
		 * <p>Go to the debug screen to get the default values
		 * for the current language. You just need to copy and
		 * paste here the values prompted in the console. </p> */	
		public static const DEFAULT_FAQ:Object = { fr : DefaultFaq.FR,
												   en : DefaultFaq.EN };
		public static const DEFAULT_FAQ_VERSION:int = 1;
		
		/**
		 * <strong>This is the default value for the vip
		 * ranks</strong><br />
		 * 
		 * <p>Go to the debug screen to get the default values
		 * for the current language. You just need to copy and
		 * paste here the values prompted in the console. </p> */	
		public static const DEFAULT_VIP:Object = { fr : DefaultVip.FR,
												   en : DefaultVip.EN  };

        public static const DEFAULT_VIP_WITHOUT_GIFTS:Object = { fr : '[{"presentation":"Dès maintenant, faites évoluer votre rang VIP et obtenez de nombreux avantages pour jouer plus longtemps et gagner plus facilement des cadeaux !","condition":"Il suffit de s\'inscrire","rang":1,"nom_rang":"Moussaillon","acces":-1,"tab_privileges":[]},{"acces":-1,"condition":"Il suffit de cliquer sur le lien du mail reçu lors de l\'inscription.","rang":2,"nom_rang":"Matelot","tab_privileges":[{"titre":"25% d\'économie sur les Tournois","description":"En tournoi, au lieu d\'utiliser 4 parties gratuites vous n\'en utilisez plus que 3."}]},{"acces":10,"condition":"Rechargez votre compte de {0} Crédits\\npour obtenir ce rang !","rang":3,"nom_rang":"Boucanier","tab_privileges":[{"titre":"1 partie gratuite en plus","description":"Vous pouvez faire une partie supplémentaire gratuite par jour."}]},{"acces":50,"condition":"Rechargez votre compte de {0} Crédits\\npour obtenir ce rang !","rang":4,"nom_rang":"Aventurier I","tab_privileges":[{"titre":"Accès Boutique VIP","description":"Avec ce rang, vous pouvez accèder à la boutique VIP. Echangez directement vos Points contre le cadeau de vos rêves."},{"titre":"400 Points par filleuls","description":"En parrainant de futurs pirates, vous obtiendrez non plus 200 Points mais 400 Points par tête !"}]},{"acces":100,"condition":"Rechargez votre compte de {0} Crédits\\npour obtenir ce rang !","rang":5,"nom_rang":"Aventurier II","tab_privileges":[{"titre":"Gain X6 en utilisant un crédit","description":"Vos Points sont multipliés par 6 quand vous utilisez un crédit."}]},{"acces":150,"condition":"Rechargez votre compte de {0} Crédits\\npour obtenir ce rang !","rang":6,"nom_rang":"Aventurier III","tab_privileges":[{"titre":"5% des gains des filleuls","description":"Désormais avec ce rang, vous gagnez des Points même les jours où vous ne jouez pas. C\'est simple à chaque fois qu\'un de vos filleuls gagne des Points sur une partie classique, votre solde de Points est augmenté de 5% des points qu\'il fera. Ces Points seront ajoutés chaque jour à Minuit à votre solde de Points."},{"titre":"50 Points max par partie gratuite","description":"Grâce à ce rang, quand vous atteignez le dernier palier de score pour les parties gratuites, vous gagnez 50 Points au lieu de 40 Points."}]},{"acces":200,"condition":"Rechargez votre compte de {0} Crédits\\npour obtenir ce rang !","rang":7,"nom_rang":"Pirate I","tab_privileges":[{"titre":"10% sur toutes les parties","description":"Avec ce rang, vous gagnez 10% de Points supplémentaires sur vos parties classiques. Ces Points seront ajoutés à votre solde de Points tous les jours à Minuit."}]},{"acces":300,"condition":"Rechargez votre compte de {0} Crédits\\npour obtenir ce rang !","rang":8,"nom_rang":"Pirate II","tab_privileges":[{"titre":"5% sur la boutique","description":"Avec ce rang, la valeur des lots de la boutique est diminuée. Vous économisez 5% de vos Points pour en profiter sur les autres lots ou en Tournoi."}]},{"acces":400,"condition":"Rechargez votre compte de {0} Crédits\\npour obtenir ce rang !","rang":9,"nom_rang":"Pirate III","tab_privileges":[{"titre":"5% sur les crédits","description":"Avec ce rang, vous gagnez 5 Crédits supplémentaires tous les 100 Crédits achetés. Agréable pour rejouer à vos jeux préférés ou devenir le premier à un tournoi !!!"}]},{"acces":600,"condition":"Rechargez votre compte de {0} Crédits\\npour obtenir ce rang !","rang":10,"nom_rang":"1er Maître","tab_privileges":[{"titre":"10% sur la boutique","description":"Avec ce rang, la valeur des lots de la boutique est diminuée. Vous économisez 10% de vos Points pour en profiter sur les autres lots ou en Tournoi."}]},{"acces":1200,"condition":"Rechargez votre compte de {0} Crédits\\npour obtenir ce rang !","rang":11,"nom_rang":"2nd Maître","tab_privileges":[{"titre":"10% sur les crédits","description":"Avec ce rang, vous gagnez 10 Crédits supplémentaires tous les 100 Crédits achetés. Agréable pour rejouer à vos jeux préférés ou devenir le premier à un tournoi !!!"}]},{"acces":2400,"condition":"Rechargez votre compte de {0} Crédits\\npour obtenir ce rang !","rang":12,"nom_rang":"Capitaine","tab_privileges":[{"titre":"Relation privilégiée","description":"Avec ce rang, Ludokado n\'aura plus de secret pour vous. Vous devenez un véritable acteur du site. Ludokado vous sollicitera pour avoir votre avis sur les futures évolutions du site. Palpitant !!!"}]}]',
                                                                 en : '[{"condition":"You just need to register","rang":1,"nom_rang":"Midshipman","presentation":"Reach new VIP levels and get lots of advantages to play longer and win prizes easily right now !","acces":-1,"tab_privileges":[]},{"condition":"You just need to click on the link in the email you received when registering.","acces":-1,"rang":2,"nom_rang":"Seaman","tab_privileges":[{"titre":"Save 25% on Tournaments","description":"When playing tournaments, you only use 3 free games instead of 4."}]},{"condition":"Top up your account with {0} Credits\\nto reach this level !","acces":10,"rang":3,"nom_rang":"Buccaneer","tab_privileges":[{"titre":"1 extra free game","description":"You can play an extra free game every day."}]},{"condition":"Top up your account with {0} Credits\\nto reach this level !","acces":50,"rang":4,"nom_rang":"Explorer I ","tab_privileges":[{"titre":"Go to the VIP shop","description":"In this level, you can access our VIP shop. Exchange your Points for amazing gifts."},{"titre":"400 Points per friend","description":"When referring future pirates, you will get 400 Points per friend instead of 200 !"}]},{"condition":"Top up your account with {0} Credits\\nto reach this level !","acces":100,"rang":5,"nom_rang":"Explorer II","tab_privileges":[{"titre":"Winnings X6 when using a credit","description":"You win 6 times more Points when you use a credit."}]},{"condition":"Top up your account with {0} Credits\\nto reach this level !","acces":150,"rang":6,"nom_rang":"Explorer III","tab_privileges":[{"titre":"5% on your friends\' winnings","description":"In this level, you win Points even when you don\'t play. Indeed, each time one of your friends win Points on a classic game, the number of your Points increases by 5% of the points won by your friend. These Points are added to your account every day at midnight."},{"titre":"50 Points max per free game","description":"In this level, when you reach the last level of score on free games, you win 50 Points instead of 40."}]},{"condition":"Top up your account with {0} Credits\\nto reach this level !","acces":200,"rang":7,"nom_rang":"Pirate I","tab_privileges":[{"titre":"10% on all games","description":"In this level, you win 10% extra Points on your classic games. These Points are added to your Points balance every day at midnight."}]},{"condition":"Top up your account with {0} Credits\\nto reach this level !","acces":300,"rang":8,"nom_rang":"Pirate II","tab_privileges":[{"titre":"5% in the shop","description":"In this level, the value of the prizes available in our shop decreases. You save 5% of your Points to use them for other prizes or for Tournaments."}]},{"condition":"Top up your account with {0} Credits\\nto reach this level !","acces":400,"rang":9,"nom_rang":"Pirate III","tab_privileges":[{"titre":"5% on credits","description":"In this level, you win 5 extra Credits every 100 Credits you buy. This is great news to play your favourite games or to become first in a tournament !!!"}]},{"condition":"Top up your account with {0} Credits\\nto reach this level !","acces":600,"rang":10,"nom_rang":"1st Master","tab_privileges":[{"titre":"10% on the shop","description":"In this level, the value of the prizes available in our shop decreases. You save 10% of your Points to use them for other prizes or for Tournaments."}]},{"condition":"Top up your account with {0} Credits\\nto reach this level !","acces":1200,"rang":11,"nom_rang":"2nd Master","tab_privileges":[{"titre":"10% on credits","description":"In this level, you win 10 extra Credits every 100 Credits you buy. This is great news to play again your favourite games or to become first in a tournament !!!"}]},{"condition":"Top up your account with {0} Credits\\nto reach this level !","acces":2400,"rang":12,"nom_rang":"Captain","tab_privileges":[{"titre":"Special relationship","description":"In this level, LudoKado has no secret for you. Thus, you become a real actor on our website. LudoKado might ask you your opinion about future changes in the website. Thrilling !!!"}]}]'  };
        public static const DEFAULT_VIP_VERSION:int = 1;
		
		/**
		 * <strong>This is the default value for the game
		 * news.</strong><br /> */	
		public static const DEFAULT_NEWS:Object = { fr : '[{"id":1, "titre":"Découvrez Ludokado", "description":"Touchez ici pour découvrir Ludokado.com et... description à trouver.", "url_image":"default-news-ludokado", "lien":"http://www.ludokado.com"},' +
                                                          '{"id":-1, "titre":"Lancement de Pyramid", "description":"Lancement de la première application de Ludokado pour tablettes et mobiles.", "url_image":"default-news"}]',
													en : '[{"id":1, "titre":"Discover Ludokado", "description":"Tap here to discover Ludokado and... find a description", "url_image":"default-news-ludokado", "lien":"http://www.ludokado.com"},' +
                                                          '{"id":-1, "titre":"Launch of Pyramid", "description":"Launch of the first LudoKado\'s application available for tablets and smartphones.", "url_image":"default-news"}]' };
		
		/**
		 * <strong>This is the default value for the terms
		 * and conditions.</strong><br /> */	
		public static const DEFAULT_TERMS_AND_CONDITIONS:Object = { fr : DefaultTermsAndConditions.FR,
																	en : DefaultTermsAndConditions.EN };
		public static const DEFAULT_NEWS_VERSION:int = 1;
		
		public static const DEFAULT_SOUND_ENABLED:Boolean = true;
		
		public static const DEFAULT_MUSIC_ENABLED:Boolean = true;
		
		/**
		 * Hack for Poedit
		 * _("Français");
		 * _("Anglais");
		 * 
		 */		
		public static const DEFAULT_AVAILABLE_LANGUAGES:Array = [ new LanguageData( { id:1, key:"fr", translationKey:"Français" } ),
																  new LanguageData( { id:2, key:"en", translationKey:"Anglais" } ) ];
		
		/**
		 * <strong>This is the default value for the push
		 * notification.</strong><br />
		 * The first time the user will change the value in
		 * his account settings, he will be asked in ios if
		 * he wants to receive push from our application.
		 * 
		 * <p>This value will help us to determine if we can
		 * request a token at launch or not.</p> */	
		public static const DEFAULT_PUSH_INITIALIZED:Boolean = false;
		
		/**
		 * 
		 */		
		public static const DEFAULT_DISPLAY_ADS:Boolean = false;
		
		/**
		 * 
		 */		
		public static const DEFAULT_USE_SECURED_CALLS:Boolean = false;
		
		/**
		 * <strong>This is the default value for the sponsor
		 * reward value.</strong><br />
		 * Whether some points or money (ex : "40€" or "100 000").
		 * Default is "100000"
		 */		
		public static const DEFAULT_SPONSOR_REWARD_VALUE:String = "100 000";
		
		/**
		 * <strong>This is the default value for the sponsor
		 * reward type.</strong><br />
		 * 1 = display points
		 * 2 = display currency
		 * Default is 1 
		 */		
		public static const DEFAULT_SPONSOR_REWARD_TYPE:int = 1;
		
		/**
		 * Whether we need todisplay an arrow above the back arrow
		 * the first time the user will see this button. */		
		public static const DEFAULT_NEED_HELP_ARROW:Boolean = true;
		
		
		public static const DEFAULT_COEF:Array = [5, 6];
		
		/**
		 * Whether we need to force the user to update the application. */		
		public static const DEFAULT_FORCE_UPDATE:Boolean = false;
		/**
		 * The link of the application on the store. */		
		public static const DEFAULT_FORCE_UPDATE_LINK:String = "";
		/**
		 * The text to display. */		
		public static const DEFAULT_FORCE_UPDATE_TEXT:String = "";
		/**
		 * The text to display on the button. */
		public static const DEFAULT_FORCE_UPDATE_BUTTON_NAME:String = "";
		/**
		 * The old game version used to check if we can disable
		 * the force update value if it was enabled. */		
		public static const DEFAULT_GAME_VERSION:String = "1.0";
		
		
		
		public static const DEFAULT_CAN_LAUNCH_INTERSTITIAL:Boolean = false;
		
		public static const DEFAULT_NEW_LANGUAGES:Array = [];
		
//------------------------------------------------------------------------------------------------------------
// Configuration properties
		
		/**
		 * Determines if this is the first launch of the application. At the
		 * first launch, this property will be added to the SharedObject and
		 * initialized to <code>true</code>, then we initialize all the default
		 * properties needed for the application to work properly.
		 * 
		 * <p>Later, we can check this value so that we know that we don't need
		 * to initialize all the default properties again later.</p>
		 * 
		 * <p>See GLOBAL_CONFIG_SO_NAME for more informations about all the
		 * configuration properties</p>
		 * 
		 * @see #GLOBAL_CONFIG_SO_NAME
		 */		
		public static const PROPERTY_FIRST_LAUNCH:String = "first-launch";
		
		/**
		 * Access the score-to-points correspondance table.
		 */			
		public static const PROPERTY_POINTS_TABLE:String = "DEFAULT_POINTS_TABLE";
		
		/**
		 * Access the score-to-stars correspondance table.
		 */			
		public static const PROPERTY_STARS_TABLE:String = "DEFAULT_STARS_TABLE";
		
		/**
		 * Access the user's preferred language.
		 * 
		 * <p>See the Localizer's language constants for more informations
		 * about which kind of value this property can take.</p>
		 * 
		 * @see com.ludofactory.mobile.core.Localizer
		 */			
		public static const PROPERTY_LANGUAGE:String = "DEFAULT_LANGUAGE";
		
		/**
		 * Access all the loaded languages.
		 * <p>The content of this property looks like this :</p>
		 * <i>	[...]</i><br />
		 * <i>	[fr] = { version:x, translation:dictionnary }</i><br />
		 * <i>	[...]</i>
		 * 
		 * @see com.ludofactory.mobile.core.Localizer
		 */			
		public static const PROPERTY_TRANSLATIONS:String = "translations";
		
		/**
		 * Access the number of free game sessions required to play in free play mode. */		
		public static const PROPERTY_NUM_FREE_IN_FREE_MODE:String = "DEFAULT_NUM_FREE_IN_FREE_MODE";
		/**
		 * Access the number of free game sessions required to tournament mode. */		
		public static const PROPERTY_NUM_FREE_IN_TOURNAMENT_MODE:String = "DEFAULT_NUM_FREE_IN_TOURNAMENT_MODE";
		/**
		 * Access the number of points required to play in tournament mode. */		
		public static const PROPERTY_NUM_POINTS_IN_TOURNAMENT_MODE:String = "DEFAULT_NUM_POINTS_IN_TOURNAMENT_MODE";
		/**
		 * Access the number of credits required to play in free play mode. */		
		public static const PROPERTY_NUM_CREDITS_IN_FREE_MODE:String = "DEFAULT_NUM_CREDITS_IN_FREE_MODE";
		/**
		 * Access the number of credits required to play in tournament mode. */		
		public static const PROPERTY_NUM_CREDITS_IN_TOURNAMENT_MODE:String = "DEFAULT_NUM_CREDITS_IN_TOURNAMENT_MODE";
		
		/**
		 * Access the customer service themes. */		
		public static const PROPERTY_CUSTOMER_SERVICE_THEMES:String = "DEFAULT_CUSTOMER_SERVICE_THEMES";
        /**
		 * Access the customer service themes. */
		public static const PROPERTY_CUSTOMER_SERVICE_THEMES_WITHOUT_GIFTS:String = "DEFAULT_CUSTOMER_SERVICE_THEMES_WITHOUT_GIFTS";
		
		/**
		 * Access the faq. */		
		public static const PROPERTY_FAQ:String = "DEFAULT_FAQ";
		public static const PROPERTY_FAQ_VERSION:String = "DEFAULT_FAQ_VERSION";
		
		/**
		 * Access the vip. */		
		public static const PROPERTY_VIP:String = "DEFAULT_VIP";
        /**
         * Access the vip. */
        public static const PROPERTY_VIP_WITHOUT_GIFTS:String = "DEFAULT_VIP_WITHOUT_GIFTS";
		public static const PROPERTY_VIP_VERSION:String = "DEFAULT_VIP_VERSION";
		
		/**
		 * Access the news. */		
		public static const PROPERTY_NEWS:String = "DEFAULT_NEWS";
		public static const PROPERTY_NEWS_VERSION:String = "DEFAULT_NEWS_VERSION";
		
		/**
		 * Access the terms and conditions. */		
		public static const PROPERTY_TERMS_AND_CONDITIONS:String = "DEFAULT_TERMS_AND_CONDITIONS";
		
		/**
		 * Access the sound. */		
		public static const PROPERTY_SOUND_ENABLED:String = "DEFAULT_SOUND_ENABLED";
		
		/**
		 * Access the music. */		
		public static const PROPERTY_MUSIC_ENABLED:String = "DEFAULT_MUSIC_ENABLED";
		
		/**
		 * Access the available languages. */		
		public static const PROPERTY_AVAILABLE_LANGUAGES:String = "DEFAULT_AVAILABLE_LANGUAGES";
		
		/**
		 * Access the push initialized value. */		
		public static const PROPERTY_PUSH_INITIALIZED:String = "DEFAULT_PUSH_INITIALIZED";
		
		/**
		 * Access the push initialized value. */		
		public static const PROPERTY_DISPLAY_ADS:String = "DEFAULT_DISPLAY_ADS";
		
		/**
		 * Access the push initialized value. */		
		public static const PROPERTY_USE_SECURED_CALLS:String = "DEFAULT_USE_SECURED_CALLS";
		
		/**
		 * Access the sponsor reward value. */		
		public static const PROPERTY_SPONSOR_REWARD_VALUE:String = "DEFAULT_SPONSOR_REWARD_VALUE";
		
		/**
		 * Access the sponsor reward type. */		
		public static const PROPERTY_SPONSOR_REWARD_TYPE:String = "DEFAULT_SPONSOR_REWARD_TYPE";
		
		public static const PROPERTY_NEED_HELP_ARROW:String = "DEFAULT_NEED_HELP_ARROW";
		
		
		public static const PROPERTY_COEF:String = "DEFAULT_COEF";
		
		public static const PROPERTY_FORCE_UPDATE:String = "DEFAULT_FORCE_UPDATE";
		public static const PROPERTY_FORCE_UPDATE_LINK:String = "DEFAULT_FORCE_UPDATE_LINK";
		public static const PROPERTY_FORCE_UPDATE_TEXT:String = "DEFAULT_FORCE_UPDATE_TEXT";
		public static const PROPERTY_FORCE_UPDATE_BUTTON_NAME:String = "DEFAULT_FORCE_UPDATE_BUTTON_NAME";
		public static const PROPERTY_GAME_VERSION:String = "DEFAULT_GAME_VERSION";
		
		public static const PROPERTY_CAN_LAUNCH_INTERSTITIAL:String = "DEFAULT_CAN_LAUNCH_INTERSTITIAL";
		
		public static const PROPERTY_NEW_LANGUAGES:String = "DEFAULT_NEW_LANGUAGES";
	}
}