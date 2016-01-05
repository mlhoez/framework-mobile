/**
 * Created by Maxime on 23/12/15.
 */
package com.ludofactory.mobile.core.avatar
{
	
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	
	import feathers.textures.Scale3Textures;
	
	import flash.system.System;
	
	import starling.textures.Texture;
	
	public class AvatarAssets
	{
		
//------------------------------------------------------------------------------------------------------------
//	Particles
		
		[Embed(source="particle-star.pex", mimeType="application/octet-stream")]
		protected static const PARTICLE_STARS_XML_CLASS:Class;
		public static var particleStarsXml:XML;
		
		public static var panelBackground:Texture;
		
		public static var itemListBackgroundTexture:Texture;
		
		public static var iconBuyableBackgroundTexture:Texture;
		public static var iconBoughtNotEquippedBackgroundTexture:Texture;
		public static var iconEquippedBackgroundTexture:Texture;
		
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
		
		public function AvatarAssets()
		{
			
		}
		
		public static function build():void
		{
			particleStarsXml = XML(new PARTICLE_STARS_XML_CLASS());
			
			panelBackground = AbstractEntryPoint.assets.getTexture("panel-background");
			
			itemListBackgroundTexture = AbstractEntryPoint.assets.getTexture("item-renderer-background");
			
			iconBuyableBackgroundTexture = AbstractEntryPoint.assets.getTexture("item-renderer-icon-background-buyable");
			iconBoughtNotEquippedBackgroundTexture = AbstractEntryPoint.assets.getTexture("item-renderer-icon-background-bought-not-equipped");
			iconEquippedBackgroundTexture = AbstractEntryPoint.assets.getTexture("item-renderer-icon-background-equipped");
			
			expandTexture = AbstractEntryPoint.assets.getTexture("expand-icon");
			collapseTexture = AbstractEntryPoint.assets.getTexture("collapse-icon");
			removeIconTexture = AbstractEntryPoint.assets.getTexture("remove-icon");
			
			behaviorListBackground = new Scale3Textures(AbstractEntryPoint.assets.getTexture("behaviors-background"), 30, 10, Scale3Textures.DIRECTION_VERTICAL);
			
			newItemIconTexture = AbstractEntryPoint.assets.getTexture("new-item-icon");
			newItemSmallIconTexture = AbstractEntryPoint.assets.getTexture("new-item-small-icon");
			
			checkBoxArrow = AbstractEntryPoint.assets.getTexture("checkbox-arrow");
			
			cartIconBackground = AbstractEntryPoint.assets.getTexture("basket-icon-background");
			cartPointsIcon = AbstractEntryPoint.assets.getTexture("points-list-icon");
			cartIconForeground = AbstractEntryPoint.assets.getTexture("basket-icon-foreground");
			
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
			
			listShadow = AbstractEntryPoint.assets.getTexture("list-shadow");
			
			closeButton = AbstractEntryPoint.assets.getTexture("close-button-background");
			
			newItemRendererBackgroundTexture = AbstractEntryPoint.assets.getTexture("new-item-ir-background");
			
			newItemsLeftArrow = AbstractEntryPoint.assets.getTexture("new-items-left-arrow");
			newItemsRightArrow = AbstractEntryPoint.assets.getTexture("new-items-right-arrow");
			
			rankStripes = AbstractEntryPoint.assets.getTexture("rank-stripes");
			newItemsStripes = AbstractEntryPoint.assets.getTexture("new-items-stripes");
			
			newItemsCloseButton = AbstractEntryPoint.assets.getTexture("new-items-close-button");
			
			starParticle = AbstractEntryPoint.assets.getTexture("star-particle");
		}
		
		public static function dispose():void
		{
			// TODO
			
			System.disposeXML(particleStarsXml);
			particleStarsXml = null;
		}
		
	}
}