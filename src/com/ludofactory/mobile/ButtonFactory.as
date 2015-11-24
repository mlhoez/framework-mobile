/**
 * Created by Maxime on 09/11/15.
 */
package com.ludofactory.mobile
{
	
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import flash.filters.BitmapFilterQuality;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	
	/**
	 * Button Factory
	 * 
	 * But : avoir du scale 9 + un texte qui se scale suivant la tailel du bouton
	 * Utiliser également les filtres natifs
	 */
	public class ButtonFactory
	{
		/**
		 * Yellow button. */
		public static const YELLOW:String = "yellow";
		/**
		 * Special button, customized for each app. */
		public static const SPECIAL:String = "special";
		/**
		 * Green button. */
		public static const GREEN:String = "green";
		/**
		 * Red button. */
		public static const RED:String = "red";
		/**
		 * Blue button. */
		public static const BLUE:String = "blue";
		
		public static var SPECIAL_FONT_COLOR:uint = 0xffffff;
		public static var SPECIAL_FILTER_COLOR:uint = 0xffffff;
		
		/**
		 * Glow filter used to outline the text. */
		private static const GLOW_FILTER:GlowFilter = new GlowFilter(0x0170a9, 1, scaleAndRoundToDpi(1.0), scaleAndRoundToDpi(1.0), scaleAndRoundToDpi(5), BitmapFilterQuality.LOW);
		
		private static const DROP_SHADOW_FILTER:DropShadowFilter = new DropShadowFilter(2, 75, 0x0170a9, 0.6, scaleAndRoundToDpi(1), scaleAndRoundToDpi(1), scaleAndRoundToDpi(1), BitmapFilterQuality.LOW);
		
		public function ButtonFactory()
		{
			
		}
		
		/**
		 * Returns a button.
		 */
		public static function getButton(text:String = "", buttonColorStyle:String = YELLOW):MobileButton
		{
			var buttonToReturn:MobileButton;
			switch (buttonColorStyle)
			{
				case SPECIAL:
				{
					buttonToReturn = new MobileButton(Theme.buttonSpecialSkinTextures, text);
					buttonToReturn.fontColor = SPECIAL_FONT_COLOR;
					buttonToReturn.nativeFilters = [ new GlowFilter(SPECIAL_FILTER_COLOR, 1, scaleAndRoundToDpi(1.0), scaleAndRoundToDpi(1.0), scaleAndRoundToDpi(5), BitmapFilterQuality.LOW),
						new DropShadowFilter(2, 75, SPECIAL_FILTER_COLOR, 0.6, scaleAndRoundToDpi(1), scaleAndRoundToDpi(1), scaleAndRoundToDpi(1), BitmapFilterQuality.LOW) ];
					break;
				}
				
				case YELLOW:
				{
					buttonToReturn = new MobileButton(Theme.buttonYellowSkinTextures, text);
					buttonToReturn.fontColor = 0x622100;
					buttonToReturn.nativeFilters = [ new GlowFilter(0xffe400, 1, scaleAndRoundToDpi(1.0), scaleAndRoundToDpi(1.0), scaleAndRoundToDpi(5), BitmapFilterQuality.LOW),
						new DropShadowFilter(2, 75, 0xffe400, 0.6, scaleAndRoundToDpi(1), scaleAndRoundToDpi(1), scaleAndRoundToDpi(1), BitmapFilterQuality.LOW) ];
					break;
				}
				
				case GREEN:
				{
					buttonToReturn = new MobileButton(Theme.buttonYellowSkinTextures, text);
					buttonToReturn.fontColor = 0xffffff;
					buttonToReturn.nativeFilters = [ new GlowFilter(0x1a7602, 1, scaleAndRoundToDpi(1.0), scaleAndRoundToDpi(1.0), scaleAndRoundToDpi(5), BitmapFilterQuality.LOW),
						new DropShadowFilter(2, 75, 0x1a7602, 0.6, scaleAndRoundToDpi(1), scaleAndRoundToDpi(1), scaleAndRoundToDpi(1), BitmapFilterQuality.LOW) ];
					break;
				}
				
				case RED:
				{
					buttonToReturn = new MobileButton(Theme.buttonYellowSkinTextures, text);
					buttonToReturn.fontColor = 0xffffff;
					buttonToReturn.nativeFilters = [ new GlowFilter(0x8a0000, 1, scaleAndRoundToDpi(1.0), scaleAndRoundToDpi(1.0), scaleAndRoundToDpi(5), BitmapFilterQuality.LOW),
						new DropShadowFilter(2, 75, 0x8a0000, 0.6, scaleAndRoundToDpi(1), scaleAndRoundToDpi(1), scaleAndRoundToDpi(1), BitmapFilterQuality.LOW) ];
					break;
				}
				
				case BLUE:
				{
					buttonToReturn = new MobileButton(Theme.buttonYellowSkinTextures, text);
					buttonToReturn.fontColor = 0xffffff;
					buttonToReturn.nativeFilters = [ new GlowFilter(0x0170a9, 1, scaleAndRoundToDpi(1.0), scaleAndRoundToDpi(1.0), scaleAndRoundToDpi(5), BitmapFilterQuality.LOW),
						new DropShadowFilter(2, 75, 0x0170a9, 0.6, scaleAndRoundToDpi(1), scaleAndRoundToDpi(1), scaleAndRoundToDpi(1), BitmapFilterQuality.LOW) ];
					break;
				}
			}
			
			buttonToReturn.fontName = Theme.FONT_SANSITA;
			buttonToReturn.textPadding = scaleAndRoundToDpi(20);
			buttonToReturn.initialize();
			
			return buttonToReturn;
		}
		
	}
}