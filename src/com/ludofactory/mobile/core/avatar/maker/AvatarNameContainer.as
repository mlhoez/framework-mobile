/*
 Copyright © 2006-2014 Ludo Factory
 Avatar Maker - Globbies
 Author  : Maxime Lhoez
 Created : 29 janvier 2015
*/
package com.ludofactory.mobile.core.avatar.maker
{
	
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.manager.MemberManager;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import flash.filters.DropShadowFilter;
	
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.text.TextField;
	
	/**
	 * Avatar maker name container.
	 */
	public class AvatarNameContainer extends Sprite
	{
		/**
		 * Background. */
		private var _background:Image;
		/**
		 * Avatar name. */
		private var _avatarName:TextField;
		
		public function AvatarNameContainer()
		{
			super();
			
			touchable = false;
			
			_background = new Image(AbstractEntryPoint.assets.getTexture("avatar-name-background"));
			addChild(_background);
			
			_avatarName = new TextField(_background.width, _background.height, MemberManager.getInstance().pseudo, Theme.FONT_SANSITA, 34, 0x802b00);
			_avatarName.nativeFilters = [ new DropShadowFilter(4, 45, 0xffffff, 0.5, 3, 3, 3) ];
			_avatarName.batchable = true;
			_avatarName.touchable = false;
			_avatarName.autoScale = true;
			_avatarName.y = -3;
			addChild(_avatarName);
		}
		
	}
}