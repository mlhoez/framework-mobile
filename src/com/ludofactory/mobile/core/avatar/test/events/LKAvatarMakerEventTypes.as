/**
 * Created by Maxime on 12/10/15.
 */
package com.ludofactory.mobile.core.avatar.test.events
{
	
	/**
	 * Events used for the Ludokado Avtar Maker.
	 */
	public class LKAvatarMakerEventTypes
	{
		
	// ---------- 
		
		/**
		 * Event dispatched when the armature and assets could be updated. */
		public static const ASSETS_UPDATED:String = "assets-updated";
		/**
		 * When all the assets have been loaded and the avatar is ready. */
		public static const AVATAR_READY:String = "avatar-ready";
		/**
		 * When the new items popup is closed. */
		public static const CLOSE_NEW_ITEMS_POPUP:String = "close-new-items-popup";
		/**
		 * When an item is selected from the new items popup. */
		public static const ON_NEW_ITEM_SELECTED:String = "new-item-selected";
		
		public static const ALL_FACTORIES_READY:String = "all-factories-ready";
		public static const AVATAR_IMAGE_CREATED:String = "avatar-image-created";
		public static const ITEM_SELECTED_OR_DESELECTED:String = "item-selected-or-deselected";
		public static const UPDATED_BONE:String = "updated-bone";
		
	// ---------- Errors
		
		/**
		 * Error event dispatched when the armature could not be downloaded. */
		public static const ARMATURE_NOT_LOADED:String = "armature-not-loaded";
		/**
		 * Error event dispatched when one of the assets could not be downloaded. */
		public static const ASSET_NOT_LOADED:String = "asset-not-loaded";
		
	}
}