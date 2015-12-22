/**
 * Created by Maxime on 18/12/14.
 */
package com.ludofactory.mobile.core.avatar.maker
{
	
	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.desktop.core.AbstractServer;
	import com.ludofactory.desktop.core.LoaderManager;
	import com.ludofactory.desktop.core.StarlingRoot;
	import com.ludofactory.desktop.gettext.aliases._;
	import com.ludofactory.desktop.tools.log;
	import com.ludofactory.globbies.events.AvatarMakerEventTypes;
	import com.ludofactory.ludokado.config.AvatarGenderType;
	import com.ludofactory.ludokado.config.AvatarGenderType;
	import com.ludofactory.ludokado.manager.LKConfigManager;
	import com.ludofactory.mobile.core.theme.Theme;
	import com.ludofactory.server.remoting.Remote;
	import com.ludofactory.server.starling.theme.Theme;
	
	import flash.filters.DropShadowFilter;
	
	import starling.display.BlendMode;
	import starling.display.Button;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.text.TextField;
	import starling.text.TextFieldAutoSize;
	
	/**
	 * Reset confirmation popup.
	 * 
	 * This popup is displayed when the user requested a reset.
	 */
	public class AvatarChangePopup extends Sprite
	{
		/**
		 * The popup background. */
		private var _background:Image;
		/**
		 * The black overlay. */
		private var _overlay:Quad;
		/**
		 * The popup title. */
		private var _title:TextField;
		/**
		 * The information message. */
		private var _messageLabel:TextField;
		/**
		 * The close button. */
		private var _cancelButton:Button;
		
		/**
		 * First gender choice. */
		private var _gender1Choice:AvatarChoiceItem;
		/**
		 * Second gender choice. */
		private var _gender2Choice:AvatarChoiceItem;
		
		public function AvatarChangePopup()
		{
			super();
			
			_background = new Image(StarlingRoot.assets.getTexture("main-background"));
			_background.width = AbstractServer.stageWidth;
			_background.height = AbstractServer.stageHeight;
			_background.blendMode = BlendMode.NONE;
			addChild(_background);
			
			_overlay = new Quad(AbstractServer.stageWidth, AbstractServer.stageHeight, 0x000000);
			_overlay.alpha = 0.5;
			addChild(_overlay);

			_title = new TextField(AbstractServer.stageWidth, 100, _("Changer de personnage"), Theme.FONT_MOUSE_MEMOIRS, 55, 0xfff600);
			_title.autoSize = TextFieldAutoSize.VERTICAL;
			_title.nativeFilters = [ new DropShadowFilter(4, 45, 0x010101, 0.5, 3, 3, 3) ];
			_title.batchable = true;
			_title.touchable = false;
			_title.y = 10;
			addChild(_title);
			
			_messageLabel = new TextField(AbstractServer.stageWidth, 30, _("Vous pourrez changer de personnage à tout moment et les objets déjà acquis seront conservés !"), Theme.FONT_MOUSE_MEMOIRS, 25, 0xffffff, true);
			_messageLabel.autoSize = TextFieldAutoSize.VERTICAL;
			_messageLabel.touchable = false;
			_messageLabel.batchable = true;
			_messageLabel.y = 530;
			_messageLabel.touchable = false;
			addChild(_messageLabel);
			
			_cancelButton = new Button(StarlingRoot.assets.getTexture("cancel-button-background"), _("RETOUR"), StarlingRoot.assets.getTexture("cancel-button-over-background"), StarlingRoot.assets.getTexture("cancel-button-over-background"));
			_cancelButton.fontName = Theme.FONT_OSWALD;
			_cancelButton.fontColor = 0xffffff;
			_cancelButton.fontBold = true;
			_cancelButton.fontSize = 20;
			_cancelButton.addEventListener(Event.TRIGGERED, onClose);
			_cancelButton.scaleWhenDown = 0.9;
			_cancelButton.x = AbstractServer.stageWidth - _cancelButton.width - 20;
			_cancelButton.y = AbstractServer.stageHeight - _cancelButton.height - 20;
			addChild(_cancelButton);
			
			var genders:Array = [ AvatarGenderType.BOY, AvatarGenderType.GIRL, AvatarGenderType.POTATO ];
			genders.splice(genders.indexOf(LKConfigManager.currentGenderId), 1);
			
			_gender1Choice = new AvatarChoiceItem(genders.shift());
			_gender1Choice.x = 275;
			_gender1Choice.y = 450;
			addChild(_gender1Choice);
			
			_gender2Choice = new AvatarChoiceItem(genders.shift());
			_gender2Choice.x = 625;
			_gender2Choice.y = 450;
			addChild(_gender2Choice);
			
			genders = null;
			
			addEventListener(AvatarMakerEventTypes.AVATAR_CHOSEN, onAvatarChosen);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Handlers
		
		
		/**
		 * When the purchase button have been triggered.
		 */
		private function onAvatarChosen(event:Event):void
		{
			log("[ResetConfirmationPopup] Avatar chosen : " + AvatarGenderType.gerGenderNameById(AvatarChoiceItem(event.target).gender));
			LoaderManager.getInstance().showLoader(_("Chargement"));
			dispatchEventWith(AvatarMakerEventTypes.CONFIRM_RESET_POPUP, false, AvatarChoiceItem(event.target).gender);
		}

		/**
		 * Closes the popup.
		 */
		private function onClose(event:Event):void
		{
			dispatchEventWith(AvatarMakerEventTypes.CLOSE_RESET_POPUP);
		}

//------------------------------------------------------------------------------------------------------------
//	Dispose
		
		override public function dispose():void
		{
			removeEventListener(AvatarMakerEventTypes.AVATAR_CHOSEN, onAvatarChosen);
			
			_background.removeFromParent(true);
			_background = null;
			
			_overlay.removeFromParent(true);
			_overlay = null;
			
			_title.removeFromParent(true);
			_title = null;
			
			_messageLabel.removeFromParent(true);
			_messageLabel = null;

			_cancelButton.removeEventListener(Event.TRIGGERED, onClose);
			_cancelButton.removeFromParent(true);
			_cancelButton = null;
			
			_gender1Choice.removeFromParent(true);
			_gender1Choice = null;
			
			_gender2Choice.removeFromParent(true);
			_gender2Choice = null;
			
			super.dispose();
		}
		
	}
}