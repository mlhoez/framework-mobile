/**
 * Created by Maxime on 23/12/15.
 */
package com.ludofactory.mobile.core.avatar
{
	
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	
	import feathers.textures.Scale3Textures;
	import feathers.textures.Scale9Textures;
	
	import flash.geom.Rectangle;
	import flash.system.System;
	
	import starling.textures.Texture;
	
	public class AvatarMakerAssets
	{
		
//------------------------------------------------------------------------------------------------------------
//	Particles
		
		[Embed(source="particle-star.pex", mimeType="application/octet-stream")]
		protected static const PARTICLE_STARS_XML_CLASS:Class;
		public static var particleStarsXml:XML;
		
		public static var panelBackground:Scale9Textures;
		
		public static var itemListBackgroundTexture:Texture;
		
		public static var iconBuyableBackgroundTexture:Texture;
		public static var iconBoughtNotEquippedBackgroundTexture:Texture;
		public static var iconEquippedBackgroundTexture:Texture;
		public static var iconBehaviorBackgroundTexture:Texture;
		
		// arrow used in the list
		public static var expandTexture:Texture;
		public static var collapseTexture:Texture;
		public static var removeIconTexture:Texture;
		
		public static var behaviorListBackground:Scale3Textures;
		
		public static var newItemIconTexture:Texture;
		public static var newItemSmallIconTexture:Texture;
		
		public static var checkBoxArrow:Texture;
		
		public static var cartIconBackground:Texture;
		public static var cartPointsIcon:Texture;
		public static var cartIconForeground:Texture;
		
		public static var vip_locked_icon_rank_12:Texture;
		public static var vip_locked_icon_rank_11:Texture;
		public static var vip_locked_icon_rank_10:Texture;
		public static var vip_locked_icon_rank_9:Texture;
		public static var vip_locked_icon_rank_8:Texture;
		public static var vip_locked_icon_rank_7:Texture;
		public static var vip_locked_icon_rank_6:Texture;
		public static var vip_locked_icon_rank_5:Texture;
		public static var vip_locked_icon_rank_4:Texture;
		public static var vip_locked_icon_rank_3:Texture;
		public static var vip_locked_icon_rank_2:Texture;
		public static var vip_locked_icon_rank_1:Texture;
		
		public static var vip_locked_small_icon_rank_12:Texture;
		public static var vip_locked_small_icon_rank_11:Texture;
		public static var vip_locked_small_icon_rank_10:Texture;
		public static var vip_locked_small_icon_rank_9:Texture;
		public static var vip_locked_small_icon_rank_8:Texture;
		public static var vip_locked_small_icon_rank_7:Texture;
		public static var vip_locked_small_icon_rank_6:Texture;
		public static var vip_locked_small_icon_rank_5:Texture;
		public static var vip_locked_small_icon_rank_4:Texture;
		public static var vip_locked_small_icon_rank_3:Texture;
		public static var vip_locked_small_icon_rank_2:Texture;
		public static var vip_locked_small_icon_rank_1:Texture;
		
		public static var rank_1_texture:Texture;
		public static var rank_2_texture:Texture;
		public static var rank_3_texture:Texture;
		public static var rank_4_texture:Texture;
		public static var rank_5_texture:Texture;
		public static var rank_6_texture:Texture;
		public static var rank_7_texture:Texture;
		public static var rank_8_texture:Texture;
		public static var rank_9_texture:Texture;
		public static var rank_10_texture:Texture;
		public static var rank_11_texture:Texture;
		public static var rank_12_texture:Texture;
		
		public static var previewButtonTexture:Texture;
		
		public static var cartIrCheckboxBackground:Texture;
		public static var cartIrCheckboxCheck:Texture;
		
		public static var cartItemIconBackgroundTexture:Texture;
		public static var cartPointBigIconTexture:Texture;
		
		public static var cartConfirmationPopupBackgroundTexture:Texture;
		public static var notEnoughPointsPopupBackgroundTexture:Texture;
		public static var newItemsPopupBothBackground:Texture;
		public static var newItemsPopupSingleBackground:Texture;
		
		public static var listShadow:Texture;
		
		public static var closeButton:Texture;
		
		public static var newItemRendererBackgroundTexture:Texture;
		
		public static var newItemsLeftArrow:Texture;
		public static var newItemsRightArrow:Texture;
		
		public static var rankStripes:Texture;
		public static var newItemsStripes:Texture;
		
		public static var newItemsCloseButton:Texture;
		
		public static var starParticle:Texture;
		
		public static var avatarChoiceLeftArrow:Texture;
		public static var avatarChoiceRightArrow:Texture;
		
		public static var infoIcon:Texture;
		
		public static var avatarChoicePriceBackground:Scale3Textures;
		
		public static var paletteBackground:Texture;
		public static var paletteIcon:Texture;
		public static var paletteColorRed:Texture;
		public static var paletteColorYellow:Texture;
		public static var paletteColorBlue:Texture;
		public static var paletteColorGreen:Texture;
		
		public static var iconsMask:Texture;
		public static var iconsBackground:Texture;
		
		public static var sectionPlusButton:Texture;
		
		public static var section_button:Texture;
		public static var section_selected_button:Texture;
		public static var section_beard_button:Texture;
		public static var section_epaulet_button:Texture;
		public static var section_eyebrows_button:Texture;
		public static var section_eyes_button:Texture;
		public static var section_faceCustom_button:Texture;
		public static var section_hair_button:Texture;
		public static var section_hat_button:Texture;
		public static var section_leftHand_button:Texture;
		public static var section_moustache_button:Texture;
		public static var section_mouth_button:Texture;
		public static var section_nose_button:Texture;
		public static var section_rightHand_button:Texture;
		public static var section_shirt_button:Texture;
		public static var section_age_button:Texture;
		
		public static var sectionGlow:Texture;
		
		public static var backButton:Texture;
		
		public static var listColorButton:Texture;
		public static var listColorSelectedButton:Texture;
		public static var listSectionButton:Texture;
		public static var listSectionSelectedButton:Texture;
		
		public static var newItemsButton:Texture;
		
		public static var avatarNameBackground:Texture;
		
		private static var _isInitializd:Boolean = false;
		
		public function AvatarMakerAssets()
		{
			
		}
		
		public static function build():void
		{
			particleStarsXml = XML(new PARTICLE_STARS_XML_CLASS());
			
			panelBackground = new Scale9Textures(AbstractEntryPoint.assets.getTexture("panel-background"), new Rectangle(10, 10, 12, 12));
			
			itemListBackgroundTexture = AbstractEntryPoint.assets.getTexture("item-renderer-background");
			
			iconBuyableBackgroundTexture = AbstractEntryPoint.assets.getTexture("item-renderer-icon-background-buyable");
			iconBoughtNotEquippedBackgroundTexture = AbstractEntryPoint.assets.getTexture("item-renderer-icon-background-bought-not-equipped");
			iconEquippedBackgroundTexture = AbstractEntryPoint.assets.getTexture("item-renderer-icon-background-equipped");
			iconBehaviorBackgroundTexture = AbstractEntryPoint.assets.getTexture("item-renderer-icon-background-behavior");
			
			expandTexture = AbstractEntryPoint.assets.getTexture("expand-icon" + (GlobalConfig.isPhone ? "" : "-hd"));
			collapseTexture = AbstractEntryPoint.assets.getTexture("collapse-icon" + (GlobalConfig.isPhone ? "" : "-hd"));
			removeIconTexture = AbstractEntryPoint.assets.getTexture("remove-icon");
			
			//behaviorListBackground = new Scale3Textures(AbstractEntryPoint.assets.getTexture("behaviors-background"), 30, 10, Scale3Textures.DIRECTION_HORIZONTAL);
			behaviorListBackground = new Scale3Textures(AbstractEntryPoint.assets.getTexture("behaviors-background"), 30, 10, Scale3Textures.DIRECTION_HORIZONTAL);
			
			newItemIconTexture = AbstractEntryPoint.assets.getTexture("new-item-icon");
			newItemSmallIconTexture = AbstractEntryPoint.assets.getTexture("new-item-small-icon");
			
			checkBoxArrow = AbstractEntryPoint.assets.getTexture("checkbox-arrow");
			
			cartIconBackground = AbstractEntryPoint.assets.getTexture("basket-icon-background" + (GlobalConfig.isPhone ? "" : "-hd"));
			cartPointsIcon = AbstractEntryPoint.assets.getTexture("points-list-icon" + (GlobalConfig.isPhone ? "" : "-hd"));
			cartIconForeground = AbstractEntryPoint.assets.getTexture("basket-icon-foreground" + (GlobalConfig.isPhone ? "" : "-hd"));
			
			vip_locked_icon_rank_1 = AbstractEntryPoint.assets.getTexture("vip-locked-icon-rank-1");
			vip_locked_icon_rank_2 = AbstractEntryPoint.assets.getTexture("vip-locked-icon-rank-2");
			vip_locked_icon_rank_3 = AbstractEntryPoint.assets.getTexture("vip-locked-icon-rank-3");
			vip_locked_icon_rank_4 = AbstractEntryPoint.assets.getTexture("vip-locked-icon-rank-4");
			vip_locked_icon_rank_5 = AbstractEntryPoint.assets.getTexture("vip-locked-icon-rank-5");
			vip_locked_icon_rank_6 = AbstractEntryPoint.assets.getTexture("vip-locked-icon-rank-6");
			vip_locked_icon_rank_7 = AbstractEntryPoint.assets.getTexture("vip-locked-icon-rank-7");
			vip_locked_icon_rank_8 = AbstractEntryPoint.assets.getTexture("vip-locked-icon-rank-8");
			vip_locked_icon_rank_9 = AbstractEntryPoint.assets.getTexture("vip-locked-icon-rank-9");
			vip_locked_icon_rank_10 = AbstractEntryPoint.assets.getTexture("vip-locked-icon-rank-10");
			vip_locked_icon_rank_11 = AbstractEntryPoint.assets.getTexture("vip-locked-icon-rank-11");
			vip_locked_icon_rank_12 = AbstractEntryPoint.assets.getTexture("vip-locked-icon-rank-12");
			
			vip_locked_small_icon_rank_1 = AbstractEntryPoint.assets.getTexture("vip-locked-small-icon-rank-1");
			vip_locked_small_icon_rank_2 = AbstractEntryPoint.assets.getTexture("vip-locked-small-icon-rank-2");
			vip_locked_small_icon_rank_3 = AbstractEntryPoint.assets.getTexture("vip-locked-small-icon-rank-3");
			vip_locked_small_icon_rank_4 = AbstractEntryPoint.assets.getTexture("vip-locked-small-icon-rank-4");
			vip_locked_small_icon_rank_5 = AbstractEntryPoint.assets.getTexture("vip-locked-small-icon-rank-5");
			vip_locked_small_icon_rank_6 = AbstractEntryPoint.assets.getTexture("vip-locked-small-icon-rank-6");
			vip_locked_small_icon_rank_7 = AbstractEntryPoint.assets.getTexture("vip-locked-small-icon-rank-7");
			vip_locked_small_icon_rank_8 = AbstractEntryPoint.assets.getTexture("vip-locked-small-icon-rank-8");
			vip_locked_small_icon_rank_9 = AbstractEntryPoint.assets.getTexture("vip-locked-small-icon-rank-9");
			vip_locked_small_icon_rank_10 = AbstractEntryPoint.assets.getTexture("vip-locked-small-icon-rank-10");
			vip_locked_small_icon_rank_11 = AbstractEntryPoint.assets.getTexture("vip-locked-small-icon-rank-11");
			vip_locked_small_icon_rank_12 = AbstractEntryPoint.assets.getTexture("vip-locked-small-icon-rank-12");
			
			rank_1_texture = AbstractEntryPoint.assets.getTexture("rank-1");
			rank_2_texture = AbstractEntryPoint.assets.getTexture("rank-2");
			rank_3_texture = AbstractEntryPoint.assets.getTexture("rank-3");
			rank_4_texture = AbstractEntryPoint.assets.getTexture("rank-4");
			rank_5_texture = AbstractEntryPoint.assets.getTexture("rank-5");
			rank_6_texture = AbstractEntryPoint.assets.getTexture("rank-6");
			rank_7_texture = AbstractEntryPoint.assets.getTexture("rank-7");
			rank_8_texture = AbstractEntryPoint.assets.getTexture("rank-8");
			rank_9_texture = AbstractEntryPoint.assets.getTexture("rank-9");
			rank_10_texture = AbstractEntryPoint.assets.getTexture("rank-10");
			rank_11_texture = AbstractEntryPoint.assets.getTexture("rank-11");
			rank_12_texture = AbstractEntryPoint.assets.getTexture("rank-12");
			
			previewButtonTexture = AbstractEntryPoint.assets.getTexture("preview-button");
			
			cartIrCheckboxBackground = AbstractEntryPoint.assets.getTexture("cart-ir-checkbox-background");
			cartIrCheckboxCheck = AbstractEntryPoint.assets.getTexture("cart-ir-checkbox-check");
			
			cartItemIconBackgroundTexture = AbstractEntryPoint.assets.getTexture("cart-ir-item-background");
			cartPointBigIconTexture = AbstractEntryPoint.assets.getTexture("cart-ir-point-big-icon");
			newItemsPopupBothBackground = AbstractEntryPoint.assets.getTexture("new-items-popup-both-background");
			newItemsPopupSingleBackground = AbstractEntryPoint.assets.getTexture("new-items-popup-background");
			
			cartConfirmationPopupBackgroundTexture = AbstractEntryPoint.assets.getTexture("popup-cart-background");
			notEnoughPointsPopupBackgroundTexture = AbstractEntryPoint.assets.getTexture("popup-not-enough-points");
			
			listShadow = AbstractEntryPoint.assets.getTexture("avatar-list-shadow");
			
			closeButton = AbstractEntryPoint.assets.getTexture("close-button-background");
			
			newItemRendererBackgroundTexture = AbstractEntryPoint.assets.getTexture("new-item-ir-background");
			
			newItemsLeftArrow = AbstractEntryPoint.assets.getTexture("new-items-left-arrow");
			newItemsRightArrow = AbstractEntryPoint.assets.getTexture("new-items-right-arrow");
			
			rankStripes = AbstractEntryPoint.assets.getTexture("rank-stripes");
			newItemsStripes = AbstractEntryPoint.assets.getTexture("new-items-stripes");
			
			newItemsCloseButton = AbstractEntryPoint.assets.getTexture("new-items-close-button");
			
			starParticle = AbstractEntryPoint.assets.getTexture("star-particle");
			
			avatarChoiceLeftArrow = AbstractEntryPoint.assets.getTexture("avatar-left-arrow");
			avatarChoiceRightArrow = AbstractEntryPoint.assets.getTexture("avatar-right-arrow");
			
			infoIcon = AbstractEntryPoint.assets.getTexture("info-icon");
			
			avatarChoicePriceBackground = new Scale3Textures(AbstractEntryPoint.assets.getTexture("avatar-choice-price-background"), 10, 26, Scale3Textures.DIRECTION_HORIZONTAL);
			
			paletteBackground = AbstractEntryPoint.assets.getTexture("palette-background");
			paletteIcon = AbstractEntryPoint.assets.getTexture("palette-icon");
			paletteColorRed = AbstractEntryPoint.assets.getTexture("palette-color-red");
			paletteColorYellow = AbstractEntryPoint.assets.getTexture("palette-color-yellow");
			paletteColorBlue = AbstractEntryPoint.assets.getTexture("palette-color-blue");
			paletteColorGreen= AbstractEntryPoint.assets.getTexture("palette-color-green");
			
			iconsMask = AbstractEntryPoint.assets.getTexture("icons-mask");
			iconsBackground = AbstractEntryPoint.assets.getTexture("icons-background");
			
			sectionPlusButton = AbstractEntryPoint.assets.getTexture("add-item-icon" + (GlobalConfig.isPhone ? "" : "-hd"));
			
			section_button =  AbstractEntryPoint.assets.getTexture("section-button" + (GlobalConfig.isPhone ? "" : "-hd"));
			section_selected_button =  AbstractEntryPoint.assets.getTexture("section-selected-button" + (GlobalConfig.isPhone ? "" : "-hd"));
			
			section_beard_button = AbstractEntryPoint.assets.getTexture("section-beard-button" + (GlobalConfig.isPhone ? "" : "-hd"));
			section_epaulet_button = AbstractEntryPoint.assets.getTexture("section-epaulet-button" + (GlobalConfig.isPhone ? "" : "-hd"));
			section_eyebrows_button = AbstractEntryPoint.assets.getTexture("section-eyebrows-button" + (GlobalConfig.isPhone ? "" : "-hd"));
			section_eyes_button = AbstractEntryPoint.assets.getTexture("section-eyes-button" + (GlobalConfig.isPhone ? "" : "-hd"));
			section_faceCustom_button = AbstractEntryPoint.assets.getTexture("section-faceCustom-button" + (GlobalConfig.isPhone ? "" : "-hd"));
			section_hair_button = AbstractEntryPoint.assets.getTexture("section-hair-button" + (GlobalConfig.isPhone ? "" : "-hd"));
			section_hat_button = AbstractEntryPoint.assets.getTexture("section-hat-button" + (GlobalConfig.isPhone ? "" : "-hd"));
			section_leftHand_button = AbstractEntryPoint.assets.getTexture("section-leftHand-button" + (GlobalConfig.isPhone ? "" : "-hd"));
			section_moustache_button = AbstractEntryPoint.assets.getTexture("section-moustache-button" + (GlobalConfig.isPhone ? "" : "-hd"));
			section_mouth_button = AbstractEntryPoint.assets.getTexture("section-mouth-button" + (GlobalConfig.isPhone ? "" : "-hd"));
			section_nose_button = AbstractEntryPoint.assets.getTexture("section-nose-button" + (GlobalConfig.isPhone ? "" : "-hd"));
			section_rightHand_button = AbstractEntryPoint.assets.getTexture("section-rightHand-button" + (GlobalConfig.isPhone ? "" : "-hd"));
			section_shirt_button = AbstractEntryPoint.assets.getTexture("section-shirt-button" + (GlobalConfig.isPhone ? "" : "-hd"));
			section_age_button = AbstractEntryPoint.assets.getTexture("section-age-button" + (GlobalConfig.isPhone ? "" : "-hd"));
			
			sectionGlow = AbstractEntryPoint.assets.getTexture("section-glow");
			
			backButton = AbstractEntryPoint.assets.getTexture("avatar-maker-back-button");
			
			listColorButton = AbstractEntryPoint.assets.getTexture("list-color-button");
			listColorSelectedButton = AbstractEntryPoint.assets.getTexture("list-color-selected-button");
			listSectionButton = AbstractEntryPoint.assets.getTexture("list-section-button");
			listSectionSelectedButton = AbstractEntryPoint.assets.getTexture("list-section-selected-button");
			
			newItemsButton = AbstractEntryPoint.assets.getTexture("new-items-button");
			
			avatarNameBackground = AbstractEntryPoint.assets.getTexture("avatar-name-background");
			
			_isInitializd = true;
		}
		
		public static function dispose():void
		{
			// TODO
			panelBackground.texture.dispose();
			panelBackground = null;
			
			itemListBackgroundTexture.dispose();
			itemListBackgroundTexture = null;
			
			iconBuyableBackgroundTexture.dispose();
			iconBuyableBackgroundTexture = null;
			iconBoughtNotEquippedBackgroundTexture.dispose();
			iconBoughtNotEquippedBackgroundTexture = null;
			iconEquippedBackgroundTexture.dispose();
			iconEquippedBackgroundTexture = null;
			iconBehaviorBackgroundTexture.dispose();
			iconBehaviorBackgroundTexture = null;
			
			// arrow used in the list
			expandTexture.dispose();
			expandTexture = null;
			collapseTexture.dispose();
			collapseTexture = null;
			removeIconTexture.dispose();
			removeIconTexture = null;
			
			behaviorListBackground.texture.dispose();
			behaviorListBackground = null;
			
			newItemIconTexture.dispose();
			newItemIconTexture = null;
			newItemSmallIconTexture.dispose();
			newItemSmallIconTexture = null;
			
			checkBoxArrow.dispose();
			checkBoxArrow = null;
			
			cartIconBackground.dispose();
			cartIconBackground = null;
			cartPointsIcon.dispose();
			cartPointsIcon = null;
			cartIconForeground.dispose();
			cartIconForeground = null;
			
			vip_locked_icon_rank_12.dispose();
			vip_locked_icon_rank_12 = null;
			vip_locked_icon_rank_11.dispose();
			vip_locked_icon_rank_11 = null;
			vip_locked_icon_rank_10.dispose();
			vip_locked_icon_rank_10 = null;
			vip_locked_icon_rank_9.dispose();
			vip_locked_icon_rank_9 = null;
			vip_locked_icon_rank_8.dispose();
			vip_locked_icon_rank_8 = null;
			vip_locked_icon_rank_7.dispose();
			vip_locked_icon_rank_7 = null;
			vip_locked_icon_rank_6.dispose();
			vip_locked_icon_rank_6 = null;
			vip_locked_icon_rank_5.dispose();
			vip_locked_icon_rank_5 = null;
			vip_locked_icon_rank_4.dispose();
			vip_locked_icon_rank_4 = null;
			vip_locked_icon_rank_3.dispose();
			vip_locked_icon_rank_3 = null;
			vip_locked_icon_rank_2.dispose();
			vip_locked_icon_rank_2 = null;
			vip_locked_icon_rank_1.dispose();
			vip_locked_icon_rank_1 = null;
			
			vip_locked_small_icon_rank_12.dispose();
			vip_locked_small_icon_rank_12 = null;
			vip_locked_small_icon_rank_11.dispose();
			vip_locked_small_icon_rank_11 = null;
			vip_locked_small_icon_rank_10.dispose();
			vip_locked_small_icon_rank_10 = null;
			vip_locked_small_icon_rank_9.dispose();
			vip_locked_small_icon_rank_9 = null;
			vip_locked_small_icon_rank_8.dispose();
			vip_locked_small_icon_rank_8 = null;
			vip_locked_small_icon_rank_7.dispose();
			vip_locked_small_icon_rank_7 = null;
			vip_locked_small_icon_rank_6.dispose();
			vip_locked_small_icon_rank_6 = null;
			vip_locked_small_icon_rank_5.dispose();
			vip_locked_small_icon_rank_5 = null;
			vip_locked_small_icon_rank_4.dispose();
			vip_locked_small_icon_rank_4 = null;
			vip_locked_small_icon_rank_3.dispose();
			vip_locked_small_icon_rank_3 = null;
			vip_locked_small_icon_rank_2.dispose();
			vip_locked_small_icon_rank_2 = null;
			vip_locked_small_icon_rank_1.dispose();
			vip_locked_small_icon_rank_1 = null;
			
			rank_1_texture.dispose();
			rank_1_texture = null;
			rank_2_texture.dispose();
			rank_2_texture = null;
			rank_3_texture.dispose();
			rank_3_texture = null;
			rank_4_texture.dispose();
			rank_4_texture = null;
			rank_5_texture.dispose();
			rank_5_texture = null;
			rank_6_texture.dispose();
			rank_6_texture = null;
			rank_7_texture.dispose();
			rank_7_texture = null;
			rank_8_texture.dispose();
			rank_8_texture = null;
			rank_9_texture.dispose();
			rank_9_texture = null;
			rank_10_texture.dispose();
			rank_10_texture = null;
			rank_11_texture.dispose();
			rank_11_texture = null;
			rank_12_texture.dispose();
			rank_12_texture = null;
			
			previewButtonTexture.dispose();
			previewButtonTexture = null;
			
			cartIrCheckboxBackground.dispose();
			cartIrCheckboxBackground = null;
			cartIrCheckboxCheck.dispose();
			cartIrCheckboxCheck = null;
			
			cartItemIconBackgroundTexture.dispose();
			cartItemIconBackgroundTexture = null;
			cartPointBigIconTexture.dispose();
			cartPointBigIconTexture = null;
			
			cartConfirmationPopupBackgroundTexture.dispose();
			cartConfirmationPopupBackgroundTexture = null;
			notEnoughPointsPopupBackgroundTexture.dispose();
			notEnoughPointsPopupBackgroundTexture = null;
			newItemsPopupBothBackground.dispose();
			newItemsPopupBothBackground = null;
			newItemsPopupSingleBackground.dispose();
			newItemsPopupSingleBackground = null;
			
			listShadow.dispose();
			listShadow = null;
			
			closeButton.dispose();
			closeButton = null;
			
			newItemRendererBackgroundTexture.dispose();
			newItemRendererBackgroundTexture = null;
			
			newItemsLeftArrow.dispose();
			newItemsLeftArrow = null;
			newItemsRightArrow.dispose();
			newItemsRightArrow = null;
			
			rankStripes.dispose();
			rankStripes = null;
			newItemsStripes.dispose();
			newItemsStripes = null;
			
			newItemsCloseButton.dispose();
			newItemsCloseButton = null;
			
			starParticle.dispose();
			starParticle = null;
			
			avatarChoiceLeftArrow.dispose();
			avatarChoiceLeftArrow = null;
			avatarChoiceRightArrow.dispose();
			avatarChoiceRightArrow = null;
			
			infoIcon.dispose();
			infoIcon = null;
			
			avatarChoicePriceBackground.texture.dispose();
			avatarChoicePriceBackground = null;
			
			paletteBackground.dispose();
			paletteBackground = null;
			paletteIcon.dispose();
			paletteIcon = null;
			paletteColorRed.dispose();
			paletteColorRed = null;
			paletteColorYellow.dispose();
			paletteColorYellow = null;
			paletteColorBlue.dispose();
			paletteColorBlue = null;
			paletteColorGreen.dispose();
			paletteColorGreen = null;
			
			iconsMask.dispose();
			iconsMask = null;
			iconsBackground.dispose();
			iconsBackground = null;
			
			sectionPlusButton.dispose();
			sectionPlusButton = null;
			
			section_button.dispose();
			section_button = null;
			section_selected_button.dispose();
			section_selected_button = null;
			section_beard_button.dispose();
			section_beard_button = null;
			section_epaulet_button.dispose();
			section_epaulet_button = null;
			section_eyebrows_button.dispose();
			section_eyebrows_button = null;
			section_eyes_button.dispose();
			section_eyes_button = null;
			section_faceCustom_button.dispose();
			section_faceCustom_button = null;
			section_hair_button.dispose();
			section_hair_button = null;
			section_hat_button.dispose();
			section_hat_button = null;
			section_leftHand_button.dispose();
			section_leftHand_button = null;
			section_moustache_button.dispose();
			section_moustache_button = null;
			section_mouth_button.dispose();
			section_mouth_button = null;
			section_nose_button.dispose();
			section_nose_button = null;
			section_rightHand_button.dispose();
			section_rightHand_button = null;
			section_shirt_button.dispose();
			section_shirt_button = null;
			section_age_button.dispose();
			section_age_button = null;
			
			sectionGlow.dispose();
			sectionGlow = null;
			
			backButton.dispose();
			backButton= null;
			
			listColorButton.dispose();
			listColorButton = null;
			listColorSelectedButton.dispose();
			listColorSelectedButton = null;
			listSectionButton.dispose();
			listSectionButton = null;
			listSectionSelectedButton.dispose();
			listSectionSelectedButton = null;
			
			newItemsButton.dispose();
			newItemsButton = null;
			
			avatarNameBackground.dispose();
			avatarNameBackground = null;
			
			System.disposeXML(particleStarsXml);
			particleStarsXml = null;
			
			_isInitializd = false;
		}
		
		
		public static function get isInitializd():Boolean
		{
			return _isInitializd;
		}
	}
}