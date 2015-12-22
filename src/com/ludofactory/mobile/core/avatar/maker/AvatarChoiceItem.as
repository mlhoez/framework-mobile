/**
 * Created by Maxime on 17/07/15.
 */
package com.ludofactory.mobile.core.avatar.maker
{
	
	import com.greensock.TweenMax;
	import com.ludofactory.desktop.core.AbstractServer;
	import com.ludofactory.desktop.tools.splitThousands;
	import com.ludofactory.globbies.events.AvatarMakerEventTypes;
	import com.ludofactory.ludokado.config.AvatarDisplayerType;
	import com.ludofactory.ludokado.manager.AvatarData;
	import com.ludofactory.ludokado.manager.AvatarManager;
	import com.ludofactory.ludokado.manager.LKAvatarConfig;
	import com.ludofactory.ludokado.manager.LKConfigManager;
	
	import dragonBones.Armature;
	import dragonBones.animation.WorldClock;
	
	import flash.display.DisplayObject;
	
	import starling.display.Button;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	
	public class AvatarChoiceItem extends Sprite
	{
		/**
		 * The associated gender. */
		private var _gender:int;
		
		/**
		 * The avatar to display. */
		private var _avatar:Armature;
		/**
		 * Choose button. */
		private var _chooseButton:SelectButton;
		private var _priceButton:PriceButton;
		
		private var _avatarConfig:LKAvatarConfig;
		
		public function AvatarChoiceItem(gender:int, isFirstChoice:Boolean = false)
		{
			super();
			
			_gender = gender;
			
			var delay:Number = 0;
			/*switch (LudokadoConfigurationManager.gender)
			{
				case AvatarGender.BOY : { delay = gender == AvatarGender.GIRL ? 0 : 0.5; break; }
				case AvatarGender.GIRL : { delay = gender == AvatarGender.BOY ? 0 : 0.25; break; }
				case AvatarGender.POTATO : { delay = gender == AvatarGender.BOY ? 0 : 0.25; break; }
			}*/
			
			_avatar = AvatarManager.getInstance().getAvatar(_gender, AvatarDisplayerType.STARLING);
			_avatar.display.scaleX = _avatar.display.scaleY = isFirstChoice ? 0.55 : 0.6;
			TweenMax.delayedCall(delay, WorldClock.clock.add, [_avatar]);
			if(AvatarData(_avatar.userData).displayType == AvatarDisplayerType.NATIVE)
				AbstractServer.contentLayer.addChild(_avatar.display as DisplayObject);
			else
			{
				addChildAt(_avatar.display as starling.display.DisplayObject, 0);
				(_avatar.display as Sprite).addEventListener(TouchEvent.TOUCH, onTouch);
				(_avatar.display as Sprite).touchGroup = true;
				(_avatar.display as Sprite).touchable = true;
				(_avatar.display as Sprite).useHandCursor = true;
			}
			
			_avatarConfig = LKConfigManager.getConfigByGender(_avatar.userData.genderId);
			
			if(isFirstChoice || _avatarConfig.isOwned)
			{
				/*_chooseButton = new Button(StarlingRoot.assets.getTexture("avatar-choice-button-background"), _("CHOISIR"), StarlingRoot.assets.getTexture("avatar-choice-button-over-background"), StarlingRoot.assets.getTexture("avatar-choice-button-over-background"));
				 _chooseButton.fontName = Theme.FONT_OSWALD;
				 _chooseButton.fontColor = 0x4a2800;
				 _chooseButton.fontBold = true;
				 _chooseButton.fontSize = 24;
				 _chooseButton.addEventListener(Event.TRIGGERED, onSelect);
				 _chooseButton.scaleWhenDown = 0.9;
				 _chooseButton.x = _chooseButton.width * -0.4;
				 _chooseButton.y = _chooseButton.height * -0.2;
				 addChild(_chooseButton);*/
				
				_chooseButton = new SelectButton();
				_chooseButton.addEventListener(Event.TRIGGERED, onSelect);
				_chooseButton.scaleWhenDown = 0.9;
				_chooseButton.x = _chooseButton.width * -0.4;
				_chooseButton.y = _chooseButton.height * -0.2;
				addChild(_chooseButton);
			}
			else
			{
				_priceButton = new PriceButton(splitThousands(_avatarConfig.price), _avatarConfig.priceType);
				_priceButton.addEventListener(Event.TRIGGERED, onSelect);
				_priceButton.scaleWhenDown = 0.9;
				_priceButton.x = _priceButton.width * -0.4;
				_priceButton.y = _priceButton.height * -0.2;
				addChild(_priceButton);
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Handlers
		
		private function onTouch(event:TouchEvent):void
		{
			var touch:Touch = event.getTouch(_avatar.display as Sprite);
			
			if(_priceButton) _priceButton.onTouch(event, null, touch);
			if(_chooseButton) _chooseButton.onTouch(event, null, touch);
			
			if(touch && touch.phase == TouchPhase.ENDED)
				onSelect();
		}
		
		private function onSelect(event:Event = null):void
		{
			isSelected = _chooseButton ? _chooseButton.isSelected : true;
			dispatchEventWith(AvatarMakerEventTypes.AVATAR_CHOSEN, true);
		}
		
		override public function set x(value:Number):void
		{
			if(AvatarData(_avatar.userData).displayType == AvatarDisplayerType.NATIVE)
				_avatar.display.x = value;
			super.x = value;	
		}
		
		override public function set y(value:Number):void
		{
			if(AvatarData(_avatar.userData).displayType == AvatarDisplayerType.NATIVE)
				_avatar.display.y = value;
			super.y = value;
		}
		
		private var _isSelected:Boolean = false;
		
		
		public function get isSelected():Boolean
		{
			return _isSelected;
		}
		
		public function set isSelected(value:Boolean):void
		{
			_isSelected = value;
			_chooseButton ? (_chooseButton.isSelected = _isSelected) : null;
		}
		
//------------------------------------------------------------------------------------------------------------
//	Get - Set
		
		public function get gender():int { return _gender; }
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
		
		override public function dispose():void
		{
			if(_priceButton)
			{
				_priceButton.removeEventListener(Event.TRIGGERED, onSelect);
				_priceButton.removeFromParent(true);
				_priceButton = null;
			}
			
			if(_chooseButton)
			{
				_chooseButton.removeEventListener(Event.TRIGGERED, onSelect);
				_chooseButton.removeFromParent(true);
				_chooseButton = null;
			}
			
			WorldClock.clock.remove(_avatar);
			if(AvatarManager.getInstance().currentAvatarDisplayType == AvatarDisplayerType.STARLING)
			{
				(_avatar.display as Sprite).removeEventListener(TouchEvent.TOUCH, onTouch);
				_avatar.display.removeFromParent(true);
			}
			else
			{
				_avatar.display.parent.removeChild(_avatar.display);
			}
			_avatar.dispose();
			_avatar = null;
			
			_avatarConfig = null;
			
			super.dispose();
		}
		
	}
}