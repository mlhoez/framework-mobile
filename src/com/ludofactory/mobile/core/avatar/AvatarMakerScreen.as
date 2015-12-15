/**
 * Created by Maxime on 14/12/15.
 */
package com.ludofactory.mobile.core.avatar
{
	
	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.common.utils.log;
	import com.ludofactory.mobile.core.avatar.test.config.AvatarDisplayerType;
	import com.ludofactory.mobile.core.avatar.test.config.AvatarGenderType;
	import com.ludofactory.mobile.core.avatar.test.events.LKAvatarMakerEventTypes;
	import com.ludofactory.mobile.core.avatar.test.manager.AvatarManager;
	import com.ludofactory.mobile.core.avatar.test.manager.LKConfigManager;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.controls.AdvancedScreen;
	import com.ludofactory.mobile.core.manager.InfoContent;
	import com.ludofactory.mobile.core.manager.InfoManager;
	
	import dragonBones.Armature;
	
	import starling.display.Sprite;
	
	import starling.events.Event;
	
	public class AvatarMakerScreen extends AdvancedScreen
	{
		
		
		
		public function AvatarMakerScreen()
		{
			super();
			
			_appDarkBackground = true;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			InfoManager.show(_("Chargement..."));
			
			new LKConfigManager();
			LKConfigManager.initialize(JSON.parse('{"pngWidth":860,"eyesColor":{"itemId":296,"frameId":"black","itemLinkageName":"eyesColor_0"},"nose":{"itemId":184,"frameId":"defaut","itemLinkageName":"nose_3"},"moustache":{"itemId":407,"frameId":"defaut","itemLinkageName":"moustache_2"},"pngHeight":660,"mouth":{"itemId":115,"frameId":"defaut","itemLinkageName":"mouth_6"},"beard":{"itemId":401,"frameId":"defaut","itemLinkageName":"beard_1"},"leftHand":{"itemId":129,"frameId":"level_1","itemLinkageName":"leftHand_2"},"hat":{"itemId":82,"frameId":"brown","itemLinkageName":"hat_3"},"rightHand":{"itemId":572,"frameId":"level_4","itemLinkageName":"rightHand_4"},"skinColor":{"itemId":262,"frameId":"white","itemLinkageName":"skinColor_0"},"shirt":{"itemId":206,"frameId":"red","itemLinkageName":"shirt_0"},"hair":{"itemId":35,"frameId":"defaut","itemLinkageName":"hair_0"},"pngRefHeight":660,"age":{"itemId":353,"frameId":"age_2","itemLinkageName":"age_2"},"pngRefWidth":860,"faceCustom":{"itemId":416,"frameId":"defaut","itemLinkageName":"faceCustom_2"},"eyebrows":{"itemId":1,"frameId":"defaut","itemLinkageName":"eyebrows_0"},"idGender":1,"eyes":{"itemId":15,"frameId":"defaut","itemLinkageName":"eyes_0"},"hairColor":{"itemId":253,"frameId":"black","itemLinkageName":"hairColor_5"}}'));
			
			AvatarManager.getInstance().initialize("http://ludokado.mlhoez.ludofactory.dev/app/assets/flash/avatars/armatures/ludokado-armatures.dbswf",
					JSON.parse('[{"genderId":1,"assetsUrl":"http://ludokado.mlhoez.ludofactory.dev/app/assets/flash/avatars/assets/boy-assets.swf"},{"genderId":2,"assetsUrl":"http://ludokado.mlhoez.ludofactory.dev/app/assets/flash/avatars/assets/girl-assets.swf"},{"genderId":3,"assetsUrl":"http://ludokado.mlhoez.ludofactory.dev/app/assets/flash/avatars/assets/potato-assets.swf"}]') as Array,
					GlobalConfig.dpiScale);
			AvatarManager.getInstance().addEventListener(LKAvatarMakerEventTypes.AVATAR_READY, onAvatarsReady);
		}
		
		private function onAvatarsReady(event:Event):void
		{
			InfoManager.hide(_("Avatar chargé"), InfoContent.ICON_CHECK);
			
			AvatarManager.getInstance().removeEventListener(LKAvatarMakerEventTypes.AVATAR_READY, onAvatarsReady);
			
			//var arm:Armature = AvatarManager.getInstance().getAvatar(AvatarGenderType.BOY, AvatarDisplayerType.STARLING);
			AvatarManager.getInstance().changeAvatar(AvatarDisplayerType.STARLING);
			var arm:Armature = AvatarManager.getInstance().currentAvatar;
			addChild(AvatarManager.getInstance().currentAvatar.display as Sprite);
			arm.display.x = (actualWidth - arm.display.width) * 0.5;
			arm.display.y = actualHeight;
		}
		
		override protected function draw():void
		{
			super.draw();
			
			
		}
		
//------------------------------------------------------------------------------------------------------------
//	
		
		override public function dispose():void
		{
			
			super.dispose();
		}
		
	}
}