/*
Copyright © 2006-2014 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 30 juil. 2013
*/
package com.ludofactory.mobile.core.authentication
{
	import com.ludofactory.common.utils.Utility;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.Localizer;
	import com.ludofactory.mobile.core.controls.AdvancedScreen;
	import com.ludofactory.mobile.core.controls.ScreenIds;
	import com.ludofactory.mobile.core.manager.InfoContent;
	import com.ludofactory.mobile.core.manager.InfoManager;
	import com.ludofactory.mobile.core.remoting.Remote;
	import com.ludofactory.mobile.core.test.config.GlobalConfig;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import flash.text.ReturnKeyLabel;
	import flash.text.SoftKeyboardType;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import feathers.controls.Button;
	import feathers.controls.ImageLoader;
	import feathers.controls.Label;
	import feathers.controls.TextInput;
	import feathers.events.FeathersEventType;
	
	import starling.events.Event;
	
	public class SponsorScreen extends AdvancedScreen
	{
		/**
		 * The logo */		
		private var _logo:ImageLoader;
		/**
		 * The message */		
		private var _message:Label;
		
		/**
		 * The mail input */		
		private var _sponsorInput:TextInput;
		
		/**
		 * Validate button */		
		private var _validateButton:Button;
		
		/**
		 * Validate button */		
		private var _cancelButton:Button;
		
		public function SponsorScreen()
		{
			super();
			
			_whiteBackground = true;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			AbstractEntryPoint.isSelectingPseudo = true;
			
			_headerTitle = Localizer.getInstance().translate("SPONSOR.HEADER_TITLE");
			
			_logo = new ImageLoader();
			_logo.source = Theme.ludokadoLogoTexture;
			_logo.textureScale = GlobalConfig.dpiScale;
			_logo.snapToPixels = true;
			_logo.touchable = false;
			addChild( _logo );
			
			_message = new Label();
			_message.touchable = false;
			_message.text = Localizer.getInstance().translate("SPONSOR.MESSAGE");
			addChild(_message);
			_message.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(28), Theme.COLOR_DARK_GREY, false, false, null, null, null, TextFormatAlign.CENTER);
			
			_sponsorInput = new TextInput();
			_sponsorInput.prompt = Localizer.getInstance().translate("SPONSOR.SPONSOR_INPUT_HINT");
			_sponsorInput.textEditorProperties.returnKeyLabel = ReturnKeyLabel.GO;
			_sponsorInput.textEditorProperties.restrict = "0-9";
			_sponsorInput.textEditorProperties.softKeyboardType = SoftKeyboardType.NUMBER;
			_sponsorInput.addEventListener(FeathersEventType.ENTER, onValidate);
			addChild(_sponsorInput);
			
			_validateButton = new Button();
			_validateButton.label = Localizer.getInstance().translate("COMMON.VALIDATE");
			_validateButton.addEventListener(Event.TRIGGERED, onValidate);
			addChild( _validateButton );
			
			_cancelButton = new Button();
			_cancelButton.label = Localizer.getInstance().translate("SPONSOR.CANCEL_BUTTON_LABEL");
			_cancelButton.styleName = Theme.BUTTON_BLUE;
			_cancelButton.addEventListener(Event.TRIGGERED, onIgnoreStep);
			addChild( _cancelButton );
		}
		
		override protected function draw():void
		{
			super.draw();
			
			if( isInvalid(INVALIDATION_FLAG_SIZE) )
			{
				_logo.width = actualWidth * (GlobalConfig.isPhone ? 0.65 : 0.75);
				_logo.validate();
				_logo.y = scaleAndRoundToDpi( GlobalConfig.isPhone ? 15 : 30 );
				_logo.x = ((actualWidth - _logo.width) * 0.5) << 0;
				
				_message.width = _validateButton.width = _sponsorInput.width = _cancelButton.width = actualWidth * (GlobalConfig.isPhone ? 0.8 : 0.6);
				_message.validate();
				_sponsorInput.validate();
				_validateButton.validate();
				_cancelButton.validate();
				_message.x = _validateButton.x = _sponsorInput.x = _cancelButton.x = (actualWidth - (actualWidth * (GlobalConfig.isPhone ? 0.8 : 0.6))) * 0.5;
				_message.y = (_logo.y + _logo.height) + ( ((actualHeight - _logo.x - _logo.height) - (_message.height + _validateButton.height + _sponsorInput.height + _cancelButton.height + scaleAndRoundToDpi(GlobalConfig.isPhone ? 50 : 100))) * 0.5) << 0;
				
				_sponsorInput.y = _message.y + _message.height + scaleAndRoundToDpi(GlobalConfig.isPhone ? 20 : 40);
				_validateButton.y = _sponsorInput.y + _sponsorInput.height + scaleAndRoundToDpi(GlobalConfig.isPhone ? 20 : 40);
				_cancelButton.y = _validateButton.y + _validateButton.height + scaleAndRoundToDpi(GlobalConfig.isPhone ? 10 : 20);
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Handlers
//------------------------------------------------------------------------------------------------------------
		
		/**
		 * Validate form.
		 */		
		private function onValidate(event:Event):void
		{
			if( _sponsorInput.text == "" || !Utility.isNumberOnly(_sponsorInput.text))
			{
				InfoManager.showTimed( Localizer.getInstance().translate("SPONSOR.INVALID_SPONSOR"), InfoManager.DEFAULT_DISPLAY_TIME, InfoContent.ICON_CROSS );
				return;
			}
			
			this.isEnabled = false;
			InfoManager.show(Localizer.getInstance().translate("COMMON.LOADING"));
			_sponsorInput.clearFocus();
			Remote.getInstance().setParrainage(_sponsorInput.text, onSetParrainageSuccess, onSetParrainageFailure, onSetParrainageFailure, 2, advancedOwner.activeScreenID);
		}
		
		private function onSetParrainageSuccess(result:Object):void
		{
			switch(result.code)
			{
				case 1: // ok
				{
					AbstractEntryPoint.isSelectingPseudo = false;
					InfoManager.hide(result.txt, InfoContent.ICON_CHECK, InfoManager.DEFAULT_DISPLAY_TIME, this.advancedOwner.showScreen, [ ScreenIds.PSEUDO_CHOICE_SCREEN ]);
					break;
				}
					
				case 0: // données non valides
				case 2: // membre déjà parrainé
				case 3: // impossible de récupérer le membre avec son id
				{
					this.isEnabled = true;
					InfoManager.hide(result.txt, InfoContent.ICON_CHECK, InfoManager.DEFAULT_DISPLAY_TIME);
					break;
				}
					
				default:
				{
					onSetParrainageFailure();
					break;
				}
			}
		}
		
		private function onSetParrainageFailure(error:Object = null):void
		{
			this.isEnabled = true;
			InfoManager.hide(Localizer.getInstance().translate("COMMON.QUERY_FAILURE"), InfoContent.ICON_CROSS);
		}
		
		/**
		 * Ignore step.
		 */		
		private function onIgnoreStep(event:Event):void
		{
			AbstractEntryPoint.isSelectingPseudo = false;
			this.advancedOwner.showScreen( ScreenIds.PSEUDO_CHOICE_SCREEN );
		}
		
		override public function onBack():void
		{
			AbstractEntryPoint.isSelectingPseudo = false;
			this.advancedOwner.showScreen( ScreenIds.PSEUDO_CHOICE_SCREEN );
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
		
		override public function dispose():void
		{
			_logo.removeFromParent(true);
			_logo = null;
			
			_message.removeFromParent(true);
			_message = null;
			
			_sponsorInput.removeEventListener(FeathersEventType.ENTER, onValidate);
			_sponsorInput.removeFromParent(true);
			_sponsorInput = null;
			
			_validateButton.removeEventListener(Event.TRIGGERED, onValidate);
			_validateButton.removeFromParent(true);
			_validateButton = null;
			
			_cancelButton.removeEventListener(Event.TRIGGERED, onIgnoreStep);
			_cancelButton.removeFromParent(true);
			_cancelButton = null;
			
			super.dispose();
		}
		
	}
}