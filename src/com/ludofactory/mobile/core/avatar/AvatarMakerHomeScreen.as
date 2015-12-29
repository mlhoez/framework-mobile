/**
 * Created by Maxime on 22/12/15.
 */
package com.ludofactory.mobile.core.avatar
{
	
	import com.ludofactory.common.gettext.LanguageManager;
	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.common.utils.Utilities;
	import com.ludofactory.common.utils.logs.log;
	import com.ludofactory.common.utils.roundUp;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.ButtonFactory;
	import com.ludofactory.mobile.FacebookButton;
	import com.ludofactory.mobile.MobileButton;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.AbstractGameInfo;
	import com.ludofactory.mobile.core.avatar.maker.AvatarNameContainer;
	import com.ludofactory.mobile.core.avatar.test.config.AvatarDisplayerType;
	import com.ludofactory.mobile.core.avatar.test.events.LKAvatarMakerEventTypes;
	import com.ludofactory.mobile.core.avatar.test.manager.AvatarManager;
	import com.ludofactory.mobile.core.avatar.test.manager.LKConfigManager;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.controls.AdvancedScreen;
	import com.ludofactory.mobile.core.manager.InfoContent;
	import com.ludofactory.mobile.core.manager.InfoManager;
	import com.ludofactory.mobile.core.model.ScreenIds;
	
	import flash.filesystem.File;
	
	import starling.display.Image;
	
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.utils.formatString;
	
	public class AvatarMakerHomeScreen extends AdvancedScreen
	{
		/**
		 *  */
		public static const INVALIDATION_FLAG_AVATAR:String = "avatar";
		
		/**
		 * Avatars background. */
		private var _background:Image;
		
		/**
		 * Name container. */
		private var _avatarNameContainer:AvatarNameContainer;
		/**
		 * To change the gender. */
		private var _changeGenderButton:MobileButton;
		/**
		 * To update the avatar. */
		private var _modifyButton:MobileButton;
		/**
		 * Facebook share button. */
		private var _facebookButton:FacebookButton;
		
		public function AvatarMakerHomeScreen()
		{
			super();
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			new LKConfigManager();
			LKConfigManager.initialize(JSON.parse('{"pngWidth":860,"eyesColor":{"itemId":296,"frameId":"black","itemLinkageName":"eyesColor_0"},"nose":{"itemId":184,"frameId":"defaut","itemLinkageName":"nose_3"},"moustache":{"itemId":407,"frameId":"defaut","itemLinkageName":"moustache_2"},"pngHeight":660,"mouth":{"itemId":115,"frameId":"defaut","itemLinkageName":"mouth_6"},"beard":{"itemId":401,"frameId":"defaut","itemLinkageName":"beard_1"},"leftHand":{"itemId":129,"frameId":"level_1","itemLinkageName":"leftHand_2"},"hat":{"itemId":82,"frameId":"brown","itemLinkageName":"hat_3"},"rightHand":{"itemId":572,"frameId":"level_4","itemLinkageName":"rightHand_4"},"skinColor":{"itemId":262,"frameId":"white","itemLinkageName":"skinColor_0"},"shirt":{"itemId":206,"frameId":"red","itemLinkageName":"shirt_0"},"hair":{"itemId":35,"frameId":"defaut","itemLinkageName":"hair_0"},"pngRefHeight":660,"age":{"itemId":353,"frameId":"age_2","itemLinkageName":"age_2"},"pngRefWidth":860,"faceCustom":{"itemId":416,"frameId":"defaut","itemLinkageName":"faceCustom_2"},"eyebrows":{"itemId":1,"frameId":"defaut","itemLinkageName":"eyebrows_0"},"idGender":1,"eyes":{"itemId":15,"frameId":"defaut","itemLinkageName":"eyes_0"},"hairColor":{"itemId":253,"frameId":"black","itemLinkageName":"hairColor_5"}}'));
			
			InfoManager.show(_("Chargement..."));
			
			// load assets first
			var path:File = File.applicationDirectory.resolvePath("assets/avatars/avatar-maker/");
			AbstractEntryPoint.assets.enqueue( path.url + "/avatar-maker.png" );
			AbstractEntryPoint.assets.enqueue( path.url + "/avatar-maker.xml" );
			AbstractEntryPoint.assets.enqueue( path.url + "/avatars-background.jpg" );
			AbstractEntryPoint.assets.loadQueue( function onLoading(ratio:Number):void{ if(ratio == 1) initializeAvatar(); });
		}
		
		override protected function draw():void
		{
			super.draw();
			
			if(_avatarNameContainer && isInvalid(INVALIDATION_FLAG_AVATAR))
			{
				if(AbstractGameInfo.LANDSCAPE)
				{
					_background.width = actualWidth;
					_background.height = actualHeight;
					
					AvatarManager.getInstance().currentAvatar.display.scaleX = AvatarManager.getInstance().currentAvatar.display.scaleY = 1;
					AvatarManager.getInstance().currentAvatar.display.scaleX =
							AvatarManager.getInstance().currentAvatar.display.scaleY = Utilities.getScaleToFillHeight(AvatarManager.getInstance().currentAvatar.display.height, actualHeight * 0.75);
					
					_avatarNameContainer.x = roundUp(((actualWidth * 0.5) - _avatarNameContainer.width) * 0.5);
					AvatarManager.getInstance().currentAvatar.display.x = roundUp(actualWidth * 0.25);
					
					AvatarManager.getInstance().currentAvatar.display.y = roundUp((actualHeight - AvatarManager.getInstance().currentAvatar.display.height - _avatarNameContainer.height) * 0.5 + AvatarManager.getInstance().currentAvatar.display.height);
					_avatarNameContainer.y = AvatarManager.getInstance().currentAvatar.display.y;
					
					_changeGenderButton.width = _modifyButton.width = _facebookButton.width = Math.max(Math.max(_changeGenderButton.width, _modifyButton.width), _facebookButton.width);
					_changeGenderButton.x = _modifyButton.x = _facebookButton.x = roundUp(actualWidth * 0.5 + ((actualWidth * 0.5) - _changeGenderButton.width) * 0.5);
					
					_changeGenderButton.y = roundUp((actualHeight - _changeGenderButton.height - _modifyButton.height - _facebookButton.height - scaleAndRoundToDpi(GlobalConfig.isPhone ? 20 : 40)) * 0.5);
					_modifyButton.y = _changeGenderButton.y + _changeGenderButton.height + scaleAndRoundToDpi(GlobalConfig.isPhone ? 10 : 20);
					_facebookButton.y = _modifyButton.y + _modifyButton.height + scaleAndRoundToDpi(GlobalConfig.isPhone ? 10 : 20);
				}
				else
				{
					// TODO
					
				}
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Handlers
		
		private function initializeAvatar():void
		{
			AvatarAssets.build();
			
			_background = new Image(AbstractEntryPoint.assets.getTexture("avatars-background"));
			addChild(_background);
			
			AvatarManager.getInstance().addEventListener(LKAvatarMakerEventTypes.AVATAR_READY, onAvatarsReady);
			AvatarManager.getInstance().initialize();
		}
		
		/**
		 * 
		 * @param event
		 */
		private function onAvatarsReady(event:Event):void
		{
			AvatarManager.getInstance().removeEventListener(LKAvatarMakerEventTypes.AVATAR_READY, onAvatarsReady);
			
			InfoManager.hide(_("Avatar chargé."), InfoContent.ICON_CHECK);
			
			AvatarManager.getInstance().changeAvatar(AvatarDisplayerType.STARLING);
			addChild(AvatarManager.getInstance().currentAvatar.display as Sprite);
			AvatarManager.getInstance().currentAvatar.display.x = actualWidth * 0.5;
			AvatarManager.getInstance().currentAvatar.display.y = actualHeight;
			
			AvatarManager.getInstance().currentAvatar.display.scaleX = AvatarManager.getInstance().currentAvatar.display.scaleY = 1;
			AvatarManager.getInstance().currentAvatar.display.scaleX =
					AvatarManager.getInstance().currentAvatar.display.scaleY = Utilities.getScaleToFillHeight(AvatarManager.getInstance().currentAvatar.display.height, actualHeight * 0.8);
			
			_avatarNameContainer = new AvatarNameContainer();
			addChild(_avatarNameContainer);
			
			_changeGenderButton = ButtonFactory.getButton(_("Genre"), ButtonFactory.RED);
			_changeGenderButton.addEventListener(Event.TRIGGERED, onChangeGender);
			addChild(_changeGenderButton);
			
			_modifyButton = ButtonFactory.getButton(_("Modifier"), ButtonFactory.YELLOW);
			_modifyButton.addEventListener(Event.TRIGGERED, onModifiy);
			addChild(_modifyButton);
			
			_facebookButton = ButtonFactory.getFacebookButton(_("Partager"), ButtonFactory.FACEBOOK_TYPE_SHARE, _("Voici mon personnage !"),
					"",
					formatString(_("Vous aussi venez créer votre personnage sur {0} !"), AbstractGameInfo.GAME_NAME),
					_("http://www.ludokado.com/"),
					_("http://img.ludokado.com/imgAvatarJoueur/Avatar769/3846829_sd.png?v=1450861920"));
			addChild(_facebookButton);
			
			invalidate(INVALIDATION_FLAG_AVATAR);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Button handlers
		
		/**
		 * Change gender.
		 */
		private function onChangeGender(event:Event):void
		{
			advancedOwner.showScreen(ScreenIds.AVATAR_GENDER_CHOICE_SCREEN);
		}
		
		/**
		 * Update the aatar.
		 */
		private function onModifiy(event:Event):void
		{
			advancedOwner.showScreen(ScreenIds.AVATAR_MAKER_SCREEN);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
		
		override public function dispose():void
		{
			// just in case
			AvatarManager.getInstance().removeEventListener(LKAvatarMakerEventTypes.AVATAR_READY, onAvatarsReady);
			
			_avatarNameContainer.removeFromParent(true);
			_avatarNameContainer = null;
			
			_changeGenderButton.removeEventListener(Event.TRIGGERED, onChangeGender);
			_changeGenderButton.removeFromParent(true);
			_changeGenderButton = null;
			
			_modifyButton.removeEventListener(Event.TRIGGERED, onModifiy);
			_modifyButton.removeFromParent(true);
			_modifyButton = null;
			
			_facebookButton.removeFromParent(true);
			_facebookButton = null;
			
			super.dispose();
		}
		
	}
}