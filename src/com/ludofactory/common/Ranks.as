/**
 * Created by Maxime on 27/07/15.
 */
package com.ludofactory.common
{
	
	import com.ludofactory.common.gettext.aliases._;
	
	public class Ranks
	{
		/** Capitaine - requiert 2500 Crédits. */
		public static const CAPITAINE:int = 12;
		
		/** 2nd Maître - requiert 1200 Crédits. */
		public static const SECOND_MAITRE:int = 11;
		
		/** 1er Maître - requiert 600 Crédits. */
		public static const PREMIER_MAITRE:int = 10;
		
		/** Pirate III - requiert 400 Crédits. */
		public static const PIRATE_III:int = 9;
		
		/** Pirate II - requiert 300 Crédits. */
		public static const PIRATE_II:int = 8;
		
		/** Pirate I - Requiert 200 Crédits. */
		public static const PIRATE_I:int = 7;
		
		/**  Aventurier III - requiert 150 Crédits. */
		public static const AVENTURIER_III:int = 6;
		
		/** Aventurier II - requiert 100 Crédits. */
		public static const AVENTURIER_II:int = 5;
		
		/** Aventurier I - requiert 50 Crédits. */
		public static const AVENTURIER_I:int = 4;
		
		/** Boucanier - requiert 10 Crédits. */
		public static const BOUCANIER:int = 3;
		
		/** Matelot - requiert le mail validé. */
		public static const MATELOT:int = 2;
		
		/**Moussaillon - rang par défaut. */
		public static const MOUSSAILLON:int = 1;
		
		public static function getRankName(rank:int):String
		{
			switch (rank)
			{
				case MOUSSAILLON:    { return _("Moussaillon"); }
				case MATELOT:        { return _("Matelot"); }
				case BOUCANIER:      { return _("Boucanier"); }
				case AVENTURIER_I:   { return _("Aventurier I"); }
				case AVENTURIER_II:  { return _("Aventurier II"); }
				case AVENTURIER_III: { return _("Aventurier III"); }
				case PIRATE_I:       { return _("Pirate I"); }
				case PIRATE_II:      { return _("Pirate II"); }
				case PIRATE_III:     { return _("Pirate III"); }
				case PREMIER_MAITRE: { return _("Premier Maître"); }
				case SECOND_MAITRE:  { return _("Second Maître"); }
				case CAPITAINE:      { return _("Capitaine"); }
				default:             { return _("Inconnu"); }
			}
		}
		
	}
}