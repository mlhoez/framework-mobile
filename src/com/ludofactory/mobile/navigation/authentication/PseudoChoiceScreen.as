/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 12 Juin 2013
*/
package com.ludofactory.mobile.navigation.authentication
{
	import com.freshplanet.nativeExtensions.AirNetworkInfo;
	import com.gamua.flox.Flox;
	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.AbstractGameInfo;
	import com.ludofactory.mobile.core.controls.AdvancedScreen;
	import com.ludofactory.mobile.core.ScreenIds;
	import com.ludofactory.mobile.core.manager.InfoContent;
	import com.ludofactory.mobile.core.manager.InfoManager;
	import com.ludofactory.mobile.core.manager.MemberManager;
	import com.ludofactory.mobile.core.remoting.Remote;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import flash.text.ReturnKeyLabel;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import eu.alebianco.air.extensions.analytics.Analytics;
	
	import feathers.controls.Button;
	import feathers.controls.ImageLoader;
	import feathers.controls.Label;
	import feathers.controls.Radio;
	import feathers.controls.ScrollContainer;
	import feathers.controls.Scroller;
	import feathers.controls.TextInput;
	import feathers.events.FeathersEventType;
	
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	
	/**
	 * This is the screen displayed when the user must choose a pseudo.
	 */	
	public class PseudoChoiceScreen extends AdvancedScreen
	{
		/**
		 * The logo */		
		private var _logo:ImageLoader;
		/**
		 * The message */		
		private var _message:Label;
		
		/**
		 * Default choice container */		
		private var _defaultChoiceContainer:ScrollContainer;
		/**
		 * Default choice label */		
		private var _defaultChoiceLabel:Label;
		/**
		 * Default choice radio */		
		private var _defaultChoiceRadio:Radio;
		
		/**
		 * Custom choice container */		
		private var _customChoiceContainer:ScrollContainer;
		/**
		 * Custom choice input */		
		private var _customChoiceInput:TextInput;
		/**
		 * Custom choice radio */		
		private var _customChoiceRadio:Radio;
		
		/**
		 * Validate button */		
		private var _validateButton:Button;
		
		public function PseudoChoiceScreen()
		{
			super();
			
			_whiteBackground = true;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			_headerTitle = _("Inscription");
			AbstractEntryPoint.isSelectingPseudo = true;
			
			_logo = new ImageLoader();
			_logo.source = Theme.ludokadoLogoTexture;
			_logo.textureScale = GlobalConfig.dpiScale;
			_logo.snapToPixels = true;
			_logo.touchable = false;
			addChild( _logo );
			
			_message = new Label();
			_message.touchable = false;
			_message.text =  this.advancedOwner.screenData.defaultPseudo ? _("Marre des pseudos avec des chiffres ?\nCréez votre pseudo !") : _("Vous n'avez pas encore de pseudo ?\n\nChoisissez-le dès maintenant pour vous reconnaitre dans le classement des tournois !");
			addChild(_message);
			_message.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(GlobalConfig.isPhone ? 28 : 38), Theme.COLOR_DARK_GREY, false, false, null, null, null, TextFormatAlign.CENTER);
			
			_defaultChoiceContainer = new ScrollContainer();
			_defaultChoiceContainer.styleName = Theme.SCROLL_CONTAINER_LABEL;
			_defaultChoiceContainer.verticalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			_defaultChoiceContainer.horizontalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			addChild(_defaultChoiceContainer);
			
			_defaultChoiceLabel = new Label();
			_defaultChoiceLabel.text = this.advancedOwner.screenData.defaultPseudo ? this.advancedOwner.screenData.defaultPseudo:"";
			_defaultChoiceLabel.addEventListener(TouchEvent.TOUCH, onTouchLabel);
			_defaultChoiceContainer.addChild(_defaultChoiceLabel);
			
			_defaultChoiceRadio = new Radio();
			_defaultChoiceContainer.addChild(_defaultChoiceRadio);
			
			_customChoiceContainer = new ScrollContainer();
			_customChoiceContainer.verticalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			_customChoiceContainer.horizontalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			addChild(_customChoiceContainer);
			
			_customChoiceInput = new TextInput();
			_customChoiceInput.prompt = _("Votre pseudo...");
			_customChoiceInput.textEditorProperties.returnKeyLabel = ReturnKeyLabel.GO;
			_customChoiceInput.addEventListener(FeathersEventType.ENTER, onValidate);
			_customChoiceInput.addEventListener(FeathersEventType.FOCUS_IN, onFocusIn);
			_customChoiceInput.textEditorProperties.maxChars = 25;
			_customChoiceContainer.addChild(_customChoiceInput);
			
			_customChoiceRadio = new Radio();
			_customChoiceRadio.includeInLayout = false;
			_customChoiceContainer.addChild(_customChoiceRadio);
			
			_validateButton = new Button();
			_validateButton.label = _("Confirmer");
			_validateButton.addEventListener(Event.TRIGGERED, onValidate);
			addChild( _validateButton );
			
			if( !this.advancedOwner.screenData.defaultPseudo )
			{
				// if _data.defaultPseudo is null, it means that the user has subscribed but not completed
				// the pseudo, in this case, we need to request a default pseudo to display
				if( !AirNetworkInfo.networkInfo.isConnected() )
				{
					InfoManager.show(_("Chargement..."));
					Remote.getInstance().getDefaultPseudo(onDefaultPseudoSuccess, onDefaultPseudoFailure, onDefaultPseudoFailure, 2, advancedOwner.activeScreenID);
				}
				else
				{
					onDefaultPseudoFailure();
				}
			}
		}
		
		override protected function draw():void
		{
			super.draw();
			
			if( isInvalid(INVALIDATION_FLAG_SIZE) )
			{
				if( AbstractGameInfo.LANDSCAPE )
				{
					_logo.height = actualHeight * (GlobalConfig.isPhone ? 0.3 : 0.5);
					_logo.validate();
					_logo.y = scaleAndRoundToDpi( GlobalConfig.isPhone ? 5 : 15 );
					_logo.x = (((actualWidth * (GlobalConfig.isPhone ? 0.4 : 0.5)) - _logo.width) * 0.5) << 0;
					
					_message.width = actualWidth * (GlobalConfig.isPhone ? 0.6 : 0.5);
					_message.validate();
					_message.x = _logo.x + _logo.width;
					_message.y = _logo.y + ((_logo.height - _message.height) * 0.5) << 0;
					
					if( _defaultChoiceContainer )
					{
						_customChoiceContainer.validate();
						_defaultChoiceContainer.validate();
						_validateButton.validate();
						
						_defaultChoiceContainer.width = _customChoiceContainer.width = _customChoiceInput.width = _defaultChoiceLabel.width = _validateButton.width = actualWidth * (GlobalConfig.isPhone ? 0.8 : 0.6);
						_defaultChoiceContainer.x = _customChoiceContainer.x = _validateButton.x = (actualWidth - (actualWidth * (GlobalConfig.isPhone ? 0.8 : 0.6))) * 0.5;
						_defaultChoiceContainer.y = (_logo.y + _logo.height) + scaleAndRoundToDpi(GlobalConfig.isPhone ? 10 : 20) + ( ((actualHeight - _logo.y - _logo.height) - (_defaultChoiceContainer.height + _customChoiceContainer.height + _validateButton.height + scaleAndRoundToDpi(GlobalConfig.isPhone ? 30 : 60))) * 0.5) << 0;
						
						_customChoiceContainer.y = _defaultChoiceContainer.y + _defaultChoiceContainer.height + scaleAndRoundToDpi(GlobalConfig.isPhone ? 10 : 20);
						_validateButton.y = _customChoiceContainer.y + _customChoiceContainer.height + scaleAndRoundToDpi(GlobalConfig.isPhone ? 20 : 40);
						
						_customChoiceRadio.validate();
						_defaultChoiceLabel.validate();
						_customChoiceRadio.x = _defaultChoiceRadio.x = _customChoiceContainer.width - _customChoiceRadio.width - scaleAndRoundToDpi(20);
						_customChoiceRadio.y = _defaultChoiceRadio.y = (_customChoiceInput.height - _customChoiceRadio.height) * 0.5;
						_defaultChoiceLabel.y = (_defaultChoiceContainer.height - _defaultChoiceLabel.height) * 0.5;
						_defaultChoiceLabel.x = scaleAndRoundToDpi(14);
						
						_defaultChoiceRadio.isSelected = true;
						_customChoiceRadio.isSelected = false;
					}
					else
					{
						_customChoiceContainer.validate();
						_validateButton.validate();
						
						_customChoiceContainer.width = _customChoiceInput.width = _validateButton.width = actualWidth * (GlobalConfig.isPhone ? 0.8 : 0.6);
						_customChoiceContainer.x = _validateButton.x = (actualWidth - (actualWidth * (GlobalConfig.isPhone ? 0.8 : 0.6))) * 0.5;
						_customChoiceContainer.y = (_logo.y + _logo.height) + scaleAndRoundToDpi(GlobalConfig.isPhone ? 10 : 20) + ( ((actualHeight - _logo.y - _logo.height) - (_customChoiceContainer.height + _validateButton.height + scaleAndRoundToDpi(GlobalConfig.isPhone ? 20 : 40))) * 0.5) << 0;
						
						//_customChoiceContainer.y = _defaultChoiceContainer.y + _defaultChoiceContainer.height + scaleAndRoundToDpi(GlobalConfig.isPhone ? 10 : 20);
						_validateButton.y = _customChoiceContainer.y + _customChoiceContainer.height + scaleAndRoundToDpi(GlobalConfig.isPhone ? 20 : 40);
					}
				}
				else
				{
					_logo.width = actualWidth * (GlobalConfig.isPhone ? 0.65 : 0.75);
					_logo.validate();
					_logo.y = scaleAndRoundToDpi( GlobalConfig.isPhone ? 15 : 30 );
					_logo.x = ((actualWidth - _logo.width) * 0.5) << 0;
					
					if( _defaultChoiceContainer )
					{
						_message.validate();
						_customChoiceContainer.validate();
						_defaultChoiceContainer.validate();
						_validateButton.validate();
						
						_message.width = actualWidth;
						_defaultChoiceContainer.width = _customChoiceContainer.width = _customChoiceInput.width = _defaultChoiceLabel.width = _validateButton.width = actualWidth * (GlobalConfig.isPhone ? 0.8 : 0.6);
						_defaultChoiceContainer.x = _customChoiceContainer.x = _validateButton.x = (actualWidth - (actualWidth * (GlobalConfig.isPhone ? 0.8 : 0.6))) * 0.5;
						_message.y = (_logo.y + _logo.height) + scaleAndRoundToDpi(GlobalConfig.isPhone ? 10 : 20) + ( ((actualHeight - _logo.y - _logo.height) - (_message.height + _defaultChoiceContainer.height + _customChoiceContainer.height + _validateButton.height + scaleAndRoundToDpi(GlobalConfig.isPhone ? 60 : 120))) * 0.5) << 0;
						
						_defaultChoiceContainer.y = _message.y + _message.height + scaleAndRoundToDpi(GlobalConfig.isPhone ? 20 : 40);
						_customChoiceContainer.y = _defaultChoiceContainer.y + _defaultChoiceContainer.height + scaleAndRoundToDpi(GlobalConfig.isPhone ? 10 : 20);
						_validateButton.y = _customChoiceContainer.y + _customChoiceContainer.height + scaleAndRoundToDpi(GlobalConfig.isPhone ? 20 : 40);
						
						_customChoiceRadio.validate();
						_defaultChoiceLabel.validate();
						_customChoiceRadio.x = _defaultChoiceRadio.x = _customChoiceContainer.width - _customChoiceRadio.width - scaleAndRoundToDpi(20);
						_customChoiceRadio.y = _defaultChoiceRadio.y = (_customChoiceInput.height - _customChoiceRadio.height) * 0.5;
						_defaultChoiceLabel.y = (_defaultChoiceContainer.height - _defaultChoiceLabel.height) * 0.5;
						_defaultChoiceLabel.x = scaleAndRoundToDpi(14);
						
						_defaultChoiceRadio.isSelected = true;
						_customChoiceRadio.isSelected = false;
					}
					else
					{
						_message.validate();
						_customChoiceContainer.validate();
						_validateButton.validate();
						
						_message.width = _customChoiceContainer.width = _customChoiceInput.width = _validateButton.width = actualWidth * (GlobalConfig.isPhone ? 0.8 : 0.6);
						_message.x = _customChoiceContainer.x = _validateButton.x = (actualWidth - (actualWidth * (GlobalConfig.isPhone ? 0.8 : 0.6))) * 0.5;
						_message.y = (_logo.y + _logo.height) + scaleAndRoundToDpi(GlobalConfig.isPhone ? 10 : 20) + ( ((actualHeight - _logo.y - _logo.height) - (_message.height + _customChoiceContainer.height + _validateButton.height + scaleAndRoundToDpi(GlobalConfig.isPhone ? 50 : 100))) * 0.5) << 0;
						
						_customChoiceContainer.y = _message.y + _message.height + scaleAndRoundToDpi(GlobalConfig.isPhone ? 20 : 40);
						//_customChoiceContainer.y = _defaultChoiceContainer.y + _defaultChoiceContainer.height + scaleAndRoundToDpi(GlobalConfig.isPhone ? 10 : 20);
						_validateButton.y = _customChoiceContainer.y + _customChoiceContainer.height + scaleAndRoundToDpi(GlobalConfig.isPhone ? 20 : 40);
					}
				}
				
			}
		}
		
		override public function onBack():void
		{
			InfoManager.showTimed(_("Vous devez choisir un pseudo !"), InfoManager.DEFAULT_DISPLAY_TIME, InfoContent.ICON_CROSS);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Handlers
//------------------------------------------------------------------------------------------------------------
		
		/**
		 * Validate form.
		 */		
		private function onValidate(event:Event):void
		{
			var defaultChoosed:Boolean;
			if( !_defaultChoiceRadio )
				defaultChoosed = false;
			else
				defaultChoosed = _defaultChoiceRadio.isSelected ? true:false;
			
			if( !defaultChoosed && _customChoiceInput.text == "")
			{
				InfoManager.showTimed( _("Le pseudo ne peut être vide !"), InfoManager.DEFAULT_DISPLAY_TIME, InfoContent.ICON_CROSS );
				return;
			}
			
			if( AirNetworkInfo.networkInfo.isConnected() )
			{
				this.isEnabled = false;
				InfoManager.show(_("Chargement..."));
				_customChoiceInput.clearFocus();
				Remote.getInstance().createPseudo(defaultChoosed ? _defaultChoiceLabel.text:_customChoiceInput.text, onPseudoCreateSuccess, onPseudoCreateFailure, onPseudoCreateFailure, 2, advancedOwner.activeScreenID);
			}
			else
			{
				InfoManager.showTimed(_("Aucune connexion Internet."), InfoManager.DEFAULT_DISPLAY_TIME, InfoContent.ICON_CROSS);
			}
		}
		
		/**
		 * Focus in.
		 */		
		private function onFocusIn(event:Event):void
		{
			_customChoiceRadio.isSelected = true;
		}
		
		/**
		 * Focus in.
		 */		
		private function onTouchLabel(event:TouchEvent):void
		{
			var touch:Touch = event.getTouch(this);
			if( touch && touch.phase == TouchPhase.BEGAN)
			{
				_defaultChoiceRadio.isSelected = true;
			}
			touch = null;
		}
		
		/**
		 * The pseudo was updated successfully.
		 */		
		private function onPseudoCreateSuccess(result:Object):void
		{
			switch(result.code)
			{
				case 0: // données en entrée non valides
				case 2: // Champ pseudo ou membre vide
				case 3: // Le pseudo existe déjà
				case 4: // Erreur d'update du pseudo
				case 5: // au moins 3 caractères
				{
					this.isEnabled = true;
					InfoManager.hide(result.txt, InfoContent.ICON_CROSS, InfoManager.DEFAULT_DISPLAY_TIME);
					break;
				}
					
				case 1: // ok
				{
					AbstractEntryPoint.isSelectingPseudo = false;
					if( MemberManager.getInstance().getFacebookId() != 0 )
					{
						// Track subscription
						if( Analytics.isSupported() && AbstractEntryPoint.tracker )
							AbstractEntryPoint.tracker.buildEvent("Inscription", "Inscription").withLabel("Inscription").track();
						
						Flox.logWarning("Nouvelle inscription Facebook du membre : (" + MemberManager.getInstance().getId() + ")");
						Flox.logEvent("Inscriptions", { Type:"Facebook" });
					}
					InfoManager.hide(result.txt, InfoContent.ICON_CHECK, InfoManager.DEFAULT_DISPLAY_TIME, this.advancedOwner.showScreen, [ ((MemberManager.getInstance().getFacebookId() != 0) ? ScreenIds.HOME_SCREEN : ScreenIds.REGISTER_COMPLETE_SCREEN) ]);
					break;
				}
					
				default:
				{
					onPseudoCreateFailure();
					break;
				}
			}
		}
		
		/**
		 * There was an error executing the Amfphp request.
		 */		
		private function onPseudoCreateFailure(error:Object = null):void
		{
			this.isEnabled = true;
			InfoManager.hide(_("Une erreur est survenue, veuillez réessayer."), InfoContent.ICON_CROSS, InfoManager.DEFAULT_DISPLAY_TIME);
		}
		
		
		/**
		 * Default pseudo could be generated.
		 */		
		private function onDefaultPseudoSuccess(result:Object):void
		{
			if( result.code == 0 )
			{
				onDefaultPseudoFailure();
				return;
			}
			
			InfoManager.hide("", InfoContent.ICON_NOTHING, 0);
			_defaultChoiceLabel.text = result.pseudo_defaut;
			invalidate(INVALIDATION_FLAG_SIZE);
		}
		
		/**
		 * There was an error executing the Amfphp request.
		 */		
		private function onDefaultPseudoFailure(error:Object = null):void
		{
			// the default pseudo could not be generated or there was an error, hide the radio buttons
			_defaultChoiceRadio.removeFromParent(true);
			_defaultChoiceRadio = null;
			
			_customChoiceInput.removeEventListener(FeathersEventType.FOCUS_IN, onFocusIn);
			_customChoiceRadio.removeFromParent(true);
			_customChoiceRadio = null;
			
			_defaultChoiceLabel.removeEventListener(TouchEvent.TOUCH, onTouchLabel);
			_defaultChoiceLabel.removeFromParent(true);
			_defaultChoiceLabel = null;
			
			_defaultChoiceContainer.removeFromParent(true);
			_defaultChoiceContainer = null;
			
			// we don"t need to display an error message
			InfoManager.hide("", InfoContent.ICON_NOTHING, 0);
			
			invalidate(INVALIDATION_FLAG_SIZE);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
		
		override public function dispose():void
		{
			_logo.removeFromParent(true);
			_logo = null;
			
			_message.removeFromParent(true);
			_message = null;
			
			if( _defaultChoiceLabel )
			{
				_defaultChoiceLabel.removeEventListener(TouchEvent.TOUCH, onTouchLabel);
				_defaultChoiceLabel.removeFromParent(true);
				_defaultChoiceLabel = null;
			}
			
			if( _defaultChoiceRadio )
			{
				_defaultChoiceRadio.removeFromParent(true);
				_defaultChoiceRadio = null;
			}
			
			if( _defaultChoiceContainer )
			{
				_defaultChoiceContainer.removeFromParent(true);
				_defaultChoiceContainer = null;
			}
			
			_customChoiceInput.removeEventListener(FeathersEventType.ENTER, onValidate);
			_customChoiceInput.removeEventListener(FeathersEventType.FOCUS_IN, onFocusIn);
			_customChoiceInput.removeFromParent(true);
			_customChoiceInput = null;
			
			if( _customChoiceRadio )
			{
				_customChoiceRadio.removeFromParent(true);
				_customChoiceRadio = null;
			}
			
			_customChoiceContainer.removeFromParent(true);
			_customChoiceContainer = null;
			
			_validateButton.removeEventListener(Event.TRIGGERED, onValidate);
			_validateButton.removeFromParent(true);
			_validateButton = null;
			
			super.dispose();
		}
	}
}