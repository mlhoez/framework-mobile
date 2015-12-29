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
		}
		
		public static function dispose():void
		{
			
		}
		
	}
}