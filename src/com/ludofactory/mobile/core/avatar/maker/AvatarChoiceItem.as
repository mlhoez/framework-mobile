/**
 * Created by Maxime on 17/07/15.
 */
package com.ludofactory.mobile.core.avatar.maker
{
	
	import com.ludofactory.common.utils.Utilities;
	import com.ludofactory.common.utils.roundUp;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.avatar.AvatarMakerAssets;
	import com.ludofactory.mobile.core.avatar.test.config.AvatarDisplayerType;
	import com.ludofactory.mobile.core.avatar.test.manager.AvatarData;
	import com.ludofactory.mobile.core.avatar.test.manager.AvatarManager;
	import com.ludofactory.mobile.core.avatar.test.manager.LKAvatarConfig;
	import com.ludofactory.mobile.core.avatar.test.manager.LKConfigManager;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import dragonBones.Armature;
	import dragonBones.animation.WorldClock;
	
	import feathers.display.Scale3Image;
	
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.text.TextField;
	import starling.text.TextFieldAutoSize;
	import starling.utils.HAlign;
	import starling.utils.VAlign;
	
	public class AvatarChoiceItem extends Sprite
	{
		/**
		 * The associated gender id. */
		private var _genderId:int;
		/**
		 * The avatar configuration. */
		private var _avatarConfig:LKAvatarConfig;
		
		/**
		 * The avatar to display. */
		private var _avatar:Armature;
		
		/**
		 * Price background. */
		private var _priceBackground:Scale3Image;
		/**
		 * Price label. */
		private var _priceLabel:TextField;
		/**
		 * Price icon. */
		private var _priceIcon:Image;
		
		public function AvatarChoiceItem(genderId:int)
		{
			super();
			
			_genderId = genderId;
			_avatarConfig = LKConfigManager.getConfigByGender(_genderId);
			
			_priceBackground = new Scale3Image(AvatarMakerAssets.avatarChoicePriceBackground, GlobalConfig.dpiScale);
			_priceBackground.width = scaleAndRoundToDpi(GlobalConfig.isPhone ? 240 : 340);
			addChild(_priceBackground);
			_priceBackground.validate();
			
			alignPivot(HAlign.CENTER, VAlign.BOTTOM);
			
			// build the avatar
			_avatar = AvatarManager.getInstance().getAvatar(_genderId, AvatarDisplayerType.STARLING);
			(_avatar.display as Sprite).touchGroup = false;
			(_avatar.display as Sprite).touchable = false;
			addChildAt(_avatar.display as DisplayObject, 0);
			WorldClock.clock.add(_avatar);
			(_avatar.display as Sprite).x = _priceBackground.width * 0.45;
			(_avatar.display as Sprite).y = scaleAndRoundToDpi(10);
			
			_priceLabel = new TextField(5, _priceBackground.height, Utilities.splitThousands(_avatarConfig.price), Theme.FONT_OSWALD, scaleAndRoundToDpi(28), 0x221008, true);
			_priceLabel.autoSize = TextFieldAutoSize.HORIZONTAL;
			addChild(_priceLabel);
			
			_priceIcon = new Image(AvatarMakerAssets.cartPointBigIconTexture);
			_priceIcon.scaleX = _priceIcon.scaleY = Utilities.getScaleToFillHeight(_priceIcon.height, _priceBackground.height * 0.6);
			addChild(_priceIcon);
			
			_priceLabel.x = roundUp((_priceBackground.width - _priceLabel.width - _priceIcon.width) * 0.5);
			_priceIcon.x = _priceLabel.x + _priceLabel.width;
			_priceIcon.y = roundUp((_priceBackground.height - _priceIcon.height) *0.5);
			
			//_avatarConfig.priceType
		}
		
		public function resize(height:Number):void
		{
			_avatar.display.scaleX = _avatar.display.scaleY = 1;
			_avatar.display.scaleX = _avatar.display.scaleY = Utilities.getScaleToFillHeight(_avatar.display.height, (height - _priceBackground.height  *0.5));
		}
		
		public function test(scale:Number):void
		{
			_avatar.display.scaleX = _avatar.display.scaleY = 1;
			_avatar.display.scaleX = _avatar.display.scaleY = scale;
		}
		
		public function getScale():Number
		{
			return _avatar.display.scaleX;
		}
		
//------------------------------------------------------------------------------------------------------------
//	Get - Set
		
		public function get genderId():int { return _genderId; }
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
		
		override public function dispose():void
		{
			WorldClock.clock.remove(_avatar);
			_avatar.display.removeFromParent(true);
			_avatar.dispose();
			_avatar = null;
			
			_priceBackground.removeFromParent(true);
			_priceBackground = null;
			
			_priceLabel.removeFromParent(true);
			_priceLabel = null;
			
			_avatarConfig = null;
			
			super.dispose();
		}
		
	}
}