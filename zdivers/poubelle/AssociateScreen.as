/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 30 juil. 2013
*/
package com.ludofactory.mobile.navigation.authentication
{
	import com.ludofactory.common.utils.scaleToDpi;
	import com.ludofactory.mobile.application.config.GlobalConfig;
	import com.ludofactory.mobile.core.Localizer;
	import com.ludofactory.mobile.core.controls.AdvancedScreen;
	import com.ludofactory.mobile.core.manager.AlertManager;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import flash.text.ReturnKeyLabel;
	import flash.text.SoftKeyboardType;
	
	import app.AppEntryPoint;
	import com.ludofactory.mobile.application.ProgressPopup;
	
	import feathers.controls.Button;
	import feathers.controls.Label;
	import feathers.controls.ScrollContainer;
	import feathers.controls.Scroller;
	import feathers.controls.TextInput;
	import feathers.events.FeathersEventType;
	import feathers.layout.VerticalLayout;
	
	import starling.display.Image;
	import starling.events.Event;
	
	public class AssociateScreen extends AdvancedScreen
	{
		/**
		 * The main container */		
		private var _mainContainer:ScrollContainer;
		
		/**
		 * The logo */		
		private var _logo:Image;
		/**
		 * The title */		
		private var _title:Label;
		/**
		 * The message */		
		private var _message:Label;
		
		/**
		 * The mail input */		
		private var _passwordInput:TextInput;
		
		/**
		 * Validate button */		
		private var _validateButton:Button;
		
		public function AssociateScreen()
		{
			super();
			
			_whiteBackground = true;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			_headerTitle = Localizer.getInstance().translate("ASSOCIATE.HEADER_TITLE");
			
			const vlayout:VerticalLayout = new VerticalLayout();
			vlayout.horizontalAlign = VerticalLayout.HORIZONTAL_ALIGN_CENTER;
			vlayout.verticalAlign = VerticalLayout.VERTICAL_ALIGN_TOP;
			vlayout.padding = scaleToDpi(10);
			vlayout.gap = scaleToDpi(10);
			
			_mainContainer = new ScrollContainer();
			_mainContainer.layout = vlayout;
			_mainContainer.verticalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			_mainContainer.horizontalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			addChild( _mainContainer );
			
			_logo = new Image( AbstractEntryPoint.assets.getTexture("LogoLudokado") );
			_logo.scaleX = _logo.scaleY = GlobalConfig.dpiScalez;
			_mainContainer.addChild( _logo );
			
			_title = new Label();
			_title.text = Localizer.getInstance().translate("ASSOCIATE.TITLE");
			_title.nameList.add( Theme.LABEL_GLOBAL_TITLE );
			_mainContainer.addChild(_title);
			
			_message = new Label();
			_message.nameList.add( Theme.LABEL_BLACK_CENTER );
			_message.text = Localizer.getInstance().translate("ASSOCIATE.MESSAGE");
			_mainContainer.addChild(_message);
			
			_passwordInput = new TextInput();
			_passwordInput.prompt = Localizer.getInstance().translate("ASSOCIATE.PASSWORD_INPUT_HINT");
			_passwordInput.textEditorProperties.returnKeyLabel = ReturnKeyLabel.DONE;
			_passwordInput.textEditorProperties.softKeyboardType = SoftKeyboardType.DEFAULT;
			_passwordInput.addEventListener(FeathersEventType.ENTER, onValidate);
			_mainContainer.addChild(_passwordInput);
			
			_validateButton = new Button();
			_validateButton.label = Localizer.getInstance().translate("COMMON.VALIDATE");
			_validateButton.addEventListener(Event.TRIGGERED, onValidate);
			_mainContainer.addChild( _validateButton );
		}
		
		override protected function draw():void
		{
			if( isInvalid(INVALIDATION_FLAG_SIZE) )
			{
				_mainContainer.width = _title.width = _message.width = _passwordInput.width = this.actualWidth * (GlobalConfig.isPhone ? 0.8:0.6);
				_mainContainer.height = this.actualHeight;
				_mainContainer.x = (this.actualWidth - _mainContainer.width) * 0.5;
				
				_validateButton.width = _mainContainer.width * 0.9;
			}
		}
		
		override public function onBack():void
		{
			// we need to delete the member
			this.advancedOwner.screenData.tempMemberId = -1;
			this.advancedOwner.screenData.facebookId = -1;
			super.onBack();
		}
		
//------------------------------------------------------------------------------------------------------------
//	Handlers
//------------------------------------------------------------------------------------------------------------
		
		/**
		 * Validate form.
		 */		
		private function onValidate(event:Event):void
		{
			if( _passwordInput.text == "" )
			{
				AlertManager.showTimed( Localizer.getInstance().translate("ASSOCIATE.INVALID_PASSWORD"), AlertManager.DEFAULT_DISPLAY_TIME, true, ProgressPopup.ICON_CROSS );
				return;
			}
			
			this.isEnabled = false;
			AlertManager.show(Localizer.getInstance().translate("COMMON.LOADING"));
			//Remote.getInstance().associateAccount(this.advancedOwner.screenData.tempMemberId, this.advancedOwner.screenData.facebookId, "", onAssociateAccountSuccess, onAssociateAccountFailure, onAssociateAccountFailure, 2, advancedOwner.activeScreenID);
		}
		
		private function onAssociateAccountSuccess(result:Object):void
		{
			switch(result.code)
			{
				case 1: // ok
				{
					AlertManager.hide(result.txt, ProgressPopup.ICON_CHECK, AlertManager.DEFAULT_DISPLAY_TIME, this.advancedOwner.showScreen, [ AdvancedScreen.REGISTER_COMPLETE_SCREEN ]);
					break;
				}
				case 4: // Choix du pseudo
				{
					this.advancedOwner.screenData.defaultPseudo = result.pseudo_defaut;
					AlertManager.hide(result.txt, ProgressPopup.ICON_CHECK, AlertManager.DEFAULT_DISPLAY_TIME, this.advancedOwner.showScreen, [ AdvancedScreen.PSEUDO_CHOICE_SCREEN ]);
					break;
				}
					
				case 0: // données non valides
				case 2: // membre déjà parrainé
				case 3: // impossible de récupérer le membre avec son id
				{
					this.isEnabled = true;
					AlertManager.hide(result.txt, ProgressPopup.ICON_CROSS, AlertManager.DEFAULT_DISPLAY_TIME);
					break;
				}
					
				default:
				{
					onAssociateAccountFailure();
					break;
				}
			}
		}
		
		private function onAssociateAccountFailure(error:Object = null):void
		{
			this.isEnabled = true;
			AlertManager.hide(Localizer.getInstance().translate("COMMON.QUERY_FAILURE"), ProgressPopup.ICON_CROSS);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
//------------------------------------------------------------------------------------------------------------
		
		override public function dispose():void
		{
			_logo.removeFromParent(true);
			_logo = null;
			
			_title.removeFromParent(true);
			_title = null;
			
			_message.removeFromParent(true);
			_message = null;
			
			_passwordInput.removeEventListener(FeathersEventType.ENTER, onValidate);
			_passwordInput.removeFromParent(true);
			_passwordInput = null;
			
			_validateButton.removeEventListener(Event.TRIGGERED, onValidate);
			_validateButton.removeFromParent(true);
			_validateButton = null;
			
			_mainContainer.removeFromParent(true);
			_mainContainer = null;
			
			super.dispose();
		}
	}
}