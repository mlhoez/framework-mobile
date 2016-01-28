/*
 Copyright © 2006-2014 Ludo Factory
 Avatar Maker - Globbies
 Author  : Maxime Lhoez
 Created : 29 janvier 2015
*/
package com.ludofactory.mobile.core.avatar.maker
{
	
	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.avatar.AvatarMakerAssets;
	import com.ludofactory.mobile.core.config.GlobalConfig;
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
			
			_background = new Image(AvatarMakerAssets.avatarNameBackground);
			_background.scaleX = _background.scaleY = GlobalConfig.dpiScale;
			addChild(_background);
			
			_avatarName = new TextField(_background.width, _background.height, (MemberManager.getInstance().isLoggedIn() ? MemberManager.getInstance().pseudo : _("Pas d'avatar")), Theme.FONT_SANSITA, scaleAndRoundToDpi(34), 0x802b00);
			_avatarName.nativeFilters = [ new DropShadowFilter(4, 45, 0xffffff, 0.5, 3, 3, 3) ];
			_avatarName.batchable = true;
			_avatarName.touchable = false;
			_avatarName.autoScale = true;
			_avatarName.y = -3;
			addChild(_avatarName);
		}
		
		override public function dispose():void
		{
			_background.removeFromParent(true);
			_background = null;
			
			_avatarName.removeFromParent(true);
			_avatarName = null;
			
			super.dispose();
		}
		
	}
}