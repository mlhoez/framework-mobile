/**
 * Created by Maxime on 09/11/15.
 */
package com.ludofactory.mobile
{
	
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.manager.MemberManager;
	import com.ludofactory.mobile.core.theme.Theme;
	import com.ludofactory.mobile.navigation.FacebookPublicationData;
	
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
		public static const FACEBOOK_TYPE_SHARE:String = "facebook-type-share";
		public static const FACEBOOK_TYPE_CONNECT:String = "facebook-type-connect";
		public static const FACEBOOK_TYPE_NORMAL:String = "facebook-type-normal";
		
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
		/**
		 * White button. */
		public static const WHITE:String = "white";
		
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
					buttonToReturn = new MobileButton(Theme.buttonGreenSkinTextures, text);
					buttonToReturn.fontColor = 0xffffff;
					buttonToReturn.nativeFilters = [ new GlowFilter(0x1a7602, 1, scaleAndRoundToDpi(1.0), scaleAndRoundToDpi(1.0), scaleAndRoundToDpi(5), BitmapFilterQuality.LOW),
						new DropShadowFilter(2, 75, 0x1a7602, 0.6, scaleAndRoundToDpi(1), scaleAndRoundToDpi(1), scaleAndRoundToDpi(1), BitmapFilterQuality.LOW) ];
					break;
				}
				
				case RED:
				{
					buttonToReturn = new MobileButton(Theme.buttonRedSkinTextures, text);
					buttonToReturn.fontColor = 0xffffff;
					buttonToReturn.nativeFilters = [ new GlowFilter(0x8a0000, 1, scaleAndRoundToDpi(1.0), scaleAndRoundToDpi(1.0), scaleAndRoundToDpi(5), BitmapFilterQuality.LOW),
						new DropShadowFilter(2, 75, 0x8a0000, 0.6, scaleAndRoundToDpi(1), scaleAndRoundToDpi(1), scaleAndRoundToDpi(1), BitmapFilterQuality.LOW) ];
					break;
				}
				
				case BLUE:
				{
					buttonToReturn = new MobileButton(Theme.buttonBlueSkinTextures, text);
					buttonToReturn.fontColor = 0xffffff;
					buttonToReturn.nativeFilters = [ new GlowFilter(0x0170a9, 1, scaleAndRoundToDpi(1.0), scaleAndRoundToDpi(1.0), scaleAndRoundToDpi(5), BitmapFilterQuality.LOW),
						new DropShadowFilter(2, 75, 0x0170a9, 0.6, scaleAndRoundToDpi(1), scaleAndRoundToDpi(1), scaleAndRoundToDpi(1), BitmapFilterQuality.LOW) ];
					break;
				}

				case WHITE:
				{
					buttonToReturn = new MobileButton(Theme.buttonWhiteSkinTextures, text);
					buttonToReturn.fontColor = 0xffffff;
					buttonToReturn.nativeFilters = [ /*new GlowFilter(0x000000, 1, scaleAndRoundToDpi(1.0), scaleAndRoundToDpi(1.0), scaleAndRoundToDpi(5), BitmapFilterQuality.LOW),*/
						new DropShadowFilter(2, 75, 0x000000, 0.6, scaleAndRoundToDpi(1), scaleAndRoundToDpi(1), scaleAndRoundToDpi(1), BitmapFilterQuality.LOW) ];
					break;
				}
			}
			
			buttonToReturn.fontName = Theme.FONT_SANSITA;
			buttonToReturn.textPadding = scaleAndRoundToDpi(20);
			buttonToReturn.initialize();
			
			return buttonToReturn;
		}
		
		/**
		 * Creates a Faacebook button that will have different behaviors depending on the button type.
		 * 
		 * If we have a connect button, it will automatically display the Facebook popup in order to connect or
		 * associate the account with Facebook. Once done and if the connection / association was a success, the
		 * button will dispatch an event of type : FacebookManagerEventType.AUTHENTICATED.
		 * 
		 * If we have a share button, it will automatically publish on the user's wall of the player is logged in
		 * with Facebook (and retrieve a token first if necessary). Otherwise it will display the Facebook connect
		 * popup so that the player can authenticate before publishing. If the Facebook connect as a success, we will
		 * then automatically publish on the user's wall. Once done, the button will dispatch an event of type :
		 * FacebookManagerEventType.PUBLISHED.
		 * 
		 * @param buttonText
		 * @param buttonType
		 * @param title Title of the publication
		 * @param caption Caption
		 * @param description Description of the publication
		 * @param linkUrl The redirect link
		 * @param imageUrl url of the image
		 * @param extraParams Some extra params
		 * 
		 * @return The button
		 */
		public static function getFacebookButton(buttonText:String, buttonType:String = FACEBOOK_TYPE_CONNECT, title:String = null, caption:String = null, description:String = null, linkUrl:String = null, imageUrl:String = null, extraParams:Object = null):FacebookButton
		{
			// build the publication data
			var publicationData:FacebookPublicationData = new FacebookPublicationData(title, caption, description, linkUrl, imageUrl, extraParams);
			
			// then build the button
			var buttonToReturn:FacebookButton = new FacebookButton(Theme.facebookButtonSkinTextures, buttonText, null, null, null, buttonType, publicationData);
			buttonToReturn.fontColor = 0xffffff;
			buttonToReturn.fontName = Theme.FONT_ARIAL;
			buttonToReturn.textPadding = scaleAndRoundToDpi(20);
			buttonToReturn.validate();
			return buttonToReturn;
		}
		
	}
}