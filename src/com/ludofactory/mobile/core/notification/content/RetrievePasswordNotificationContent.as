/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 25 août 2013
*/
package com.ludofactory.mobile.core.notification.content
{
	
	import com.freshplanet.nativeExtensions.AirNetworkInfo;
	import com.greensock.TweenMax;
	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.common.utils.Utilities;
	import com.ludofactory.common.utils.roundUp;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.ButtonFactory;
	import com.ludofactory.mobile.MobileButton;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.manager.InfoContent;
	import com.ludofactory.mobile.core.manager.InfoManager;
	import com.ludofactory.mobile.core.notification.CustomPopupManager;
	import com.ludofactory.mobile.core.remoting.Remote;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import feathers.controls.TextInput;
	import feathers.events.FeathersEventType;
	
	import flash.text.ReturnKeyLabel;
	import flash.text.SoftKeyboardType;
	
	import starling.core.Starling;
	import starling.events.Event;
	import starling.text.TextField;
	import starling.text.TextFieldAutoSize;
	import starling.text.TextFormat;
	
	public class RetrievePasswordNotificationContent extends AbstractPopupContent
	{
		/**
		 *  */
		public static const INVALIDATION_FLAG_NEEDS_RESIZE_FOCUS:String = "needs-resize-focus";
		
		/**
		 * The title. */		
		private var _title:TextField;
		
		/**
		 * The message input. */		
		private var _mailInput:TextInput;
		
		/**
		 * The send button. */		
		private var _validateButton:MobileButton;

		/**
		 * The data used when the close event is dispatched. */
		protected var _data:Object;
		
		public function RetrievePasswordNotificationContent()
		{
			super();
			
			_data = {};
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			_title = new TextField(5, 5, _("Entrez l'email de votre compte pour recevoir dans quelques minutes votre mot de passe."), new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(GlobalConfig.isPhone ? 26 : 40), 0x6d6d6d));
			_title.autoSize = TextFieldAutoSize.VERTICAL;
			addChild(_title);
			
			_mailInput = new TextInput();
			_mailInput.prompt = _("Email...");
			addChild(_mailInput);
			_mailInput.textEditorProperties.returnKeyLabel = ReturnKeyLabel.GO;
			_mailInput.textEditorProperties.softKeyboardType = SoftKeyboardType.EMAIL;
			_mailInput.addEventListener(FeathersEventType.FOCUS_IN, onFocusIn);
			_mailInput.addEventListener(FeathersEventType.FOCUS_OUT, onFocusOut);
			_mailInput.addEventListener(FeathersEventType.ENTER, onValidate);
			
			_validateButton = ButtonFactory.getButton(_("Envoyer"), ButtonFactory.YELLOW);
			_validateButton.addEventListener(Event.TRIGGERED, onValidate);
			addChild(_validateButton);
		}
		
		override protected function draw():void
		{
			if(isInvalid(INVALIDATION_FLAG_SIZE))
			{
				_title.width = this.actualWidth * 0.9;
				_title.x = roundUp((actualWidth - _title.width) * 0.5);
				
				_mailInput.width = this.actualWidth * 0.8;
				_mailInput.x = roundUp((actualWidth - _mailInput.width) * 0.5);
				_mailInput.y = _title.y + _title.height + scaleAndRoundToDpi(GlobalConfig.isPhone ? 40:40);
				
				_validateButton.x = roundUp((this.actualWidth - _validateButton.width) * 0.5);
				_validateButton.y = _mailInput.y + _mailInput.height + scaleAndRoundToDpi(GlobalConfig.isPhone ? 40:40);
			}
			
			if(isInvalid(INVALIDATION_FLAG_NEEDS_RESIZE_FOCUS))
			{
				if(_mailInput.hasFocus)
					CustomPopupManager.moveCurrentToTop();
				else
					CustomPopupManager.centerCurrent();
			}
			
			super.draw();
		}
		
//------------------------------------------------------------------------------------------------------------
//	Handlers
		
		/**
		 * When one of the TextInputs gets the focus, we need to move the popup to the top.
		 */
		private function onFocusIn(event:Event):void
		{
			CustomPopupManager.moveCurrentToTop();
		}
		
		/**
		 * When one of the TextInputs looses the focus, we need to move the popup to the center.
		 */
		private function onFocusOut(event:Event):void
		{
			TweenMax.delayedCall(0.1, invalidate, [INVALIDATION_FLAG_NEEDS_RESIZE_FOCUS]);
		}
		
		/**
		 * Validate form.
		 */
		private function onValidate(event:Event):void
		{
			if( _mailInput.text == "" || !Utilities.isValidMail(_mailInput.text) )
			{
				InfoManager.showTimed( _("Email invalide."), InfoManager.DEFAULT_DISPLAY_TIME, InfoContent.ICON_CROSS );
				Starling.current.nativeStage.focus = null;
				return;
			}
			
			if( AirNetworkInfo.networkInfo.isConnected() )
			{
				this.isEnabled = false;
				InfoManager.show(_("Chargement..."));
				_mailInput.clearFocus();
				Starling.current.nativeStage.focus = null;
				Remote.getInstance().retreivePassword( _mailInput.text, onRetreivePasswordSuccess, onRetreivePasswordFailure, onRetreivePasswordFailure, 1, AbstractEntryPoint.screenNavigator.activeScreenID);
			}
			else
			{
				InfoManager.showTimed(_("Aucune connexion Internet."), InfoManager.DEFAULT_DISPLAY_TIME, InfoContent.ICON_CROSS);
			}
		}
		
		/**
		 * On retreive password success.
		 */
		private function onRetreivePasswordSuccess(result:Object):void
		{
			switch(result.code)
			{
				case 0:
				case 2:
				case 3:
				{
					this.isEnabled = true;
					InfoManager.hide(result.txt, InfoContent.ICON_CROSS, InfoManager.DEFAULT_DISPLAY_TIME);
					break;
				}
				case 1:
				{
					InfoManager.hide(result.txt, InfoContent.ICON_CHECK, 2, close);
					break;
				}
				
				default:
				{
					onRetreivePasswordFailure();
					break;
				}
			}
		}
		
		/**
		 * On retreive password failure.
		 */
		private function onRetreivePasswordFailure(error:Object = null):void
		{
			this.isEnabled = true;
			InfoManager.hide(_("Une erreur est survenue, veuillez réessayer."), InfoContent.ICON_CROSS, InfoManager.DEFAULT_DISPLAY_TIME);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
		
		override public function dispose():void
		{
			_title.removeFromParent(true);
			_title = null;
			
			_mailInput.removeEventListener(FeathersEventType.FOCUS_IN, onFocusIn);
			_mailInput.removeEventListener(FeathersEventType.FOCUS_OUT, onFocusOut);
			_mailInput.removeEventListener(FeathersEventType.ENTER, onValidate);
			_mailInput.removeFromParent(true);
			_mailInput = null;
			
			_validateButton.removeEventListener(Event.TRIGGERED, onValidate);
			_validateButton.removeFromParent(true);
			_validateButton = null;
			
			super.dispose();
		}
	}
}