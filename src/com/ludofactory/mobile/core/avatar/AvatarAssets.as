/**
 * Created by Maxime on 23/12/15.
 */
package com.ludofactory.mobile.core.avatar
{
	
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	
	import feathers.textures.Scale3Textures;
	
	import starling.textures.Texture;
	
	public class AvatarAssets
	{
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
		
		public static var previewButtonTexture:Texture;
		
		public function AvatarAssets()
		{
			
		}
		
		public static function build():void
		{
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
			
			previewButtonTexture = AbstractEntryPoint.assets.getTexture("preview-button");
		}
		
		public static function dispose():void
		{
			// TODO
		}
		
	}
}