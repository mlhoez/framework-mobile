/**
 * Created by Maxime on 23/12/15.
 */
package com.ludofactory.mobile.core.avatar
{
	
	import com.greensock.TweenMax;
	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.common.utils.roundUp;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.ButtonFactory;
	import com.ludofactory.mobile.MobileButton;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.AbstractGameInfo;
	import com.ludofactory.mobile.core.avatar.maker.AvatarChoiceItem;
	import com.ludofactory.mobile.core.avatar.test.config.AvatarGenderType;
	import com.ludofactory.mobile.core.avatar.test.events.LKAvatarMakerEventTypes;
	import com.ludofactory.mobile.core.avatar.test.manager.AvatarManager;
	import com.ludofactory.mobile.core.avatar.test.manager.LKConfigManager;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.controls.AdvancedScreen;
	import com.ludofactory.mobile.core.manager.InfoContent;
	import com.ludofactory.mobile.core.manager.InfoManager;
	import com.ludofactory.mobile.core.remoting.Remote;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import starling.display.Button;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.events.Event;
	import starling.text.TextField;
	import starling.text.TextFieldAutoSize;
	
	public class AvatarGenderChoiceScreen extends AdvancedScreen
	{
		/**
		 * Background. */
		private var _background:Image;
		/**
		 * Black overlay. */
		private var _blackOverlay:Quad;
		
		/**
		 * Info icon. */
		private var _infoIcon:Image;
		/**
		 * Info label. */
		private var _infoLabel:TextField;
		
		/**
		 * Cancel button. */
		private var _cancelButton:MobileButton;
		/**
		 * Validate button. */
		private var _validateButton:MobileButton;
		
		/**
		 * Left arrow used to select the avatar. */
		private var _leftArrow:Button;
		/**
		 * Right arrow used to select the avatar. */
		private var _righttArrow:Button;
		
		private var _avatars:Array = [];
		private var _currentIndex:int = 0;
		private var _maxIndex:int = 0;
		
		public function AvatarGenderChoiceScreen()
		{
			super();
			
			_fullScreen = true;
		}
		
		override  protected function initialize():void
		{
			super.initialize();
			
			_background = new Image(AbstractEntryPoint.assets.getTexture("avatars-background"));
			addChild(_background);
			
			_blackOverlay = new Quad(5, 5, 0x000000);
			_blackOverlay.alpha = 0.75;
			addChild(_blackOverlay);
			
			_cancelButton = ButtonFactory.getButton(_("Annuler"), ButtonFactory.RED);
			_cancelButton.addEventListener(Event.TRIGGERED, onCancel);
			addChild(_cancelButton);
			
			_validateButton = ButtonFactory.getButton(_("Choisir"), ButtonFactory.GREEN);
			_validateButton.addEventListener(Event.TRIGGERED, onValidate);
			addChild(_validateButton);
			
			var genders:Array = [ AvatarGenderType.BOY, AvatarGenderType.GIRL, AvatarGenderType.POTATO ];
			if(LKConfigManager.currentGenderId != 0) // first choice
				genders.splice(genders.indexOf(LKConfigManager.currentGenderId), 1);
			
			for (var i:int = 0; i < genders.length; i++)
			{
				_avatars.push(new AvatarChoiceItem(genders[i]));
				addChild(_avatars[i]);
			}
			genders.length = 0;
			genders = null;
			
			_maxIndex = _avatars.length - 1;
			
			_leftArrow = new Button(AvatarMakerAssets.avatarChoiceLeftArrow);
			_leftArrow.scaleX = _leftArrow.scaleY = GlobalConfig.dpiScale;
			_leftArrow.addEventListener(Event.TRIGGERED, onLeftArrowTouched);
			addChild(_leftArrow);
			
			_righttArrow = new Button(AvatarMakerAssets.avatarChoiceRightArrow);
			_righttArrow.scaleX = _righttArrow.scaleY = GlobalConfig.dpiScale;
			_righttArrow.addEventListener(Event.TRIGGERED, onRightArrowTouched);
			addChild(_righttArrow);
			
			_leftArrow.visible = _currentIndex != 0;
			_righttArrow.visible = _currentIndex != _maxIndex;
			
			_infoIcon = new Image(AvatarMakerAssets.infoIcon);
			_infoIcon.scaleX = _infoIcon.scaleY = GlobalConfig.dpiScale;
			addChild(_infoIcon);
			
			_infoLabel = new TextField(5, 5, _("Vous pouvez changer de personnage à tout moment et conserver vos objets déjà acquis."), Theme.FONT_OSWALD, scaleAndRoundToDpi(25), 0xffffff);
			_infoLabel.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
			addChild(_infoLabel);
			
			if(_infoLabel.width > (GlobalConfig.stageWidth - scaleAndRoundToDpi(20) - _infoIcon.width))
			{
				_infoLabel.autoSize = TextFieldAutoSize.NONE;
				_infoLabel.autoScale = true;
				_infoLabel.width = (GlobalConfig.stageWidth - scaleAndRoundToDpi(20) - _infoIcon.width);
			}
			else
			{
				_infoLabel.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
				_infoLabel.autoScale = false;
			}
		}
		
		override protected function draw():void
		{
			super.draw();
			
			if(isInvalid(INVALIDATION_FLAG_SIZE))
			{
				_background.width = _blackOverlay.width = actualWidth;
				_background.height = _blackOverlay.height = actualHeight;
				
				if(AbstractGameInfo.LANDSCAPE)
				{
					_infoLabel.y = actualHeight - _infoLabel.height - scaleAndRoundToDpi(5);
					_infoIcon.x = roundUp((actualWidth - _infoIcon.width - _infoLabel.width) * 0.5);
					_infoLabel.x = _infoIcon.x + _infoIcon.width;
					_infoIcon.y = roundUp(_infoLabel.y + (_infoLabel.height - _infoIcon.height) * 0.5);
					
					_cancelButton.width = _validateButton.width = Math.max(_cancelButton.width, _validateButton.width);
					_cancelButton.y = _validateButton.y = roundUp(_infoLabel.y - _cancelButton.height);
					_cancelButton.x = roundUp((actualWidth - _cancelButton.width - _validateButton.width) * 0.5);
					_validateButton.x = _cancelButton.x + _cancelButton.width;
					
					var i:int;
					for (i = 0; i < _avatars.length; i++)
					{
						_avatars[i].resize(_cancelButton.y * 0.9);
						_avatars[i].alpha = i == 0 ? 1 : 0;
						_avatars[i].visible = i == 0;
						_avatars[i].x = roundUp(actualWidth * 0.5);
						_avatars[i].y = roundUp((_cancelButton.y - _avatars[i].height) * 0.5 + (_avatars[i].height));
					}
					
					var minScaleX:Number;
					for (i = 0; i < _avatars.length; i++)
					{
						if(i == 0) minScaleX = _avatars[i].getScale();
						else minScaleX = _avatars[i].getScale() < minScaleX ? _avatars[i].getScale() : minScaleX;
					}
					
					for (i = 0; i < _avatars.length; i++)
					{
						_avatars[i].test(minScaleX);
					}
					
					_leftArrow.x = _avatars[0].x - (_avatars[0].width * 0.5) -_leftArrow.width;
					_righttArrow.x = _avatars[0].x + (_avatars[0].width * 0.5);
					_leftArrow.y = _righttArrow.y = roundUp((actualHeight * 0.5) - (_leftArrow.height * 0.5));
				}
				else
				{
					
				}
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Handlers
		
		private function onLeftArrowTouched(event:Event):void
		{
			if(_currentIndex > 0)
			{
				_currentIndex--;
				_leftArrow.visible = _currentIndex != 0;
				_righttArrow.visible = _currentIndex != _maxIndex;
				
				TweenMax.to(_avatars[_currentIndex+1], 0.25, { autoAlpha:0});
				TweenMax.to(_avatars[_currentIndex], 0.25, { autoAlpha:1});
			}
		}
		
		private function onRightArrowTouched(event:Event):void
		{
			if(_currentIndex < _maxIndex)
			{
				_currentIndex++;
				_leftArrow.visible = _currentIndex != 0;
				_righttArrow.visible = _currentIndex != _maxIndex;
				
				TweenMax.to(_avatars[_currentIndex-1], 0.25, { autoAlpha:0});
				TweenMax.to(_avatars[_currentIndex], 0.25, { autoAlpha:1});
			}
		}
		
		private function onCancel(event:Event = null):void
		{
			advancedOwner.showBackScreen();
		}
		
		private var _savedGenderId:int = 0;
		private function onValidate(event:Event):void
		{
			// TODO différencer premier choix du reset
			
			InfoManager.show(_("Chargement..."));
			
			_savedGenderId = AvatarChoiceItem(_avatars[_currentIndex]).genderId;
			
			AvatarManager.getInstance().addEventListener(LKAvatarMakerEventTypes.AVATAR_IMAGE_CREATED, onImageCreatedForReset);
			AvatarManager.getInstance().getPng(_savedGenderId, false);
		}
		
		private function onImageCreatedForReset(event:Event):void
		{
			AvatarManager.getInstance().removeEventListener(LKAvatarMakerEventTypes.AVATAR_IMAGE_CREATED, onImageCreatedForReset);
			Remote.getInstance().confirmAvatarChange(String(event.data), _savedGenderId, onConfirmResetSuccess, onConfirmResetFail, onConfirmResetFail, 1);
		}
		
		private function onConfirmResetSuccess(result:Object = null):void
		{
			if(result.code == 1)
			{
				// set the default values
				LKConfigManager.currentGenderId = _savedGenderId;
				InfoManager.hide(_("Votre personnage a bien été changé."), InfoContent.ICON_CHECK, InfoManager.DEFAULT_DISPLAY_TIME, onCancel);
			}
			else
			{
				InfoManager.hide(_("Une erreur est survenue.\n\nVeuillez réessayer."), InfoContent.ICON_CROSS);
			}
		}
		
		private function onConfirmResetFail(error:Object = null):void
		{
			_savedGenderId = 0;
			InfoManager.hide(_("Une erreur est survenue.\n\nVeuillez réessayer."), InfoContent.ICON_CROSS);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
		
		override public function dispose():void
		{
			_background.removeFromParent(true);
			_background = null;
			
			_blackOverlay.removeFromParent(true);
			_blackOverlay = null;
			
			_infoIcon.removeFromParent(true);
			_infoIcon = null;
			
			_infoLabel.removeFromParent(true);
			_infoLabel = null;
			
			_cancelButton.removeEventListener(Event.TRIGGERED, onCancel);
			_cancelButton.removeFromParent(true);
			_cancelButton = null;
			
			_validateButton.addEventListener(Event.TRIGGERED, onValidate);
			_validateButton.removeFromParent(true);
			_validateButton = null;
			
			_leftArrow.removeEventListener(Event.TRIGGERED, onLeftArrowTouched);
			_leftArrow.removeFromParent(true);
			_leftArrow = null;
			
			_righttArrow.removeEventListener(Event.TRIGGERED, onRightArrowTouched);
			_righttArrow.removeFromParent(true);
			_righttArrow = null;
			
			var av:AvatarChoiceItem;
			while(_avatars.length != 0)
			{
				av = _avatars.pop();
				av.removeFromParent(true);
				av = null;
			}
			_avatars = null;
			
			super.dispose();
		}
		
	}
}