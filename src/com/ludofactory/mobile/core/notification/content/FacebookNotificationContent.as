/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 1 septembre 2013
*/
package com.ludofactory.mobile.core.notification.content
{

	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.common.utils.roundUp;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.ButtonFactory;
	import com.ludofactory.mobile.FacebookButton;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.AbstractGameInfo;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.manager.MemberManager;
	import com.ludofactory.mobile.core.theme.Theme;
	import com.ludofactory.mobile.navigation.FacebookManager;
	import com.ludofactory.mobile.navigation.FacebookManagerEventType;
	import com.ludofactory.mobile.navigation.sponsor.info.FacebookBonusData;
	import com.ludofactory.mobile.navigation.sponsor.info.FacebookBonusItemRenderer;

	import feathers.controls.Callout;
	import feathers.controls.List;
	import feathers.controls.Scroller;
	import feathers.controls.TextInput;
	import feathers.data.ListCollection;
	import feathers.events.FeathersEventType;
	import feathers.layout.VerticalLayout;

	import flash.text.ReturnKeyLabel;
	import flash.text.SoftKeyboardType;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	import starling.display.Button;
	import starling.events.Event;
	import starling.text.TextField;
	import starling.text.TextFieldAutoSize;

	public class FacebookNotificationContent extends AbstractPopupContent
	{
		/**
		 * The title. */		
		private var _notificationTitle:TextField;

		/**
		 * The bonus list. */
		private var _bonusList:List;
		
		/**
		 * The sponsor input */
		private var _sponsorInput:TextInput;
		/**
		 * The sponsor information button. */
		private var _infoButton:Button;

		/**
		 * The yes button. */
		private var _facebookButton:FacebookButton;
		/**
		 * Warning message displayed below the Facebook button. */
		private var _warningLabel:TextField;
		
		/**
		 * Whether the callout is displaying. */
		private var _isCalloutDisplaying:Boolean = false;
		/**
		 * The callout label. */
		private var _calloutLabel:TextField;
		
		public function FacebookNotificationContent()
		{
			super();
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			data = false;
			
			_notificationTitle = new TextField(5, 5, _("Connexion Facebook"), Theme.FONT_SANSITA, scaleAndRoundToDpi(34), Theme.COLOR_DARK_GREY);
			_notificationTitle.autoSize = TextFieldAutoSize.VERTICAL;
			addChild(_notificationTitle);

			var dataProvider:Array;
			dataProvider = [ new FacebookBonusData( { iconTextureName:"facebook-bonus-credit-icon", title:_("5 Crédits OFFERTS") } ),
							 new FacebookBonusData( { iconTextureName:"facebook-bonus-friends-icon", title:_("Dépassez vos amis !") } ),
							 new FacebookBonusData( { iconTextureName:"facebook-bonus-devices-icon",  title:_("Jouez sur plusieurs appareils !") } ) ];
			
			var vlayout:VerticalLayout = new VerticalLayout();
			vlayout.gap = scaleAndRoundToDpi(5);

			_bonusList = new List();
			_bonusList.clipContent = false;
			_bonusList.verticalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			_bonusList.horizontalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			_bonusList.layout = vlayout;
			_bonusList.itemRendererType = FacebookBonusItemRenderer;
			_bonusList.dataProvider = new ListCollection( dataProvider );
			addChild( _bonusList );
			
			if(!MemberManager.getInstance().isLoggedIn())
			{
				_sponsorInput = new TextInput();
				_sponsorInput.prompt = _("Code parrain... (facultatif)");
				_sponsorInput.textEditorProperties.returnKeyLabel = ReturnKeyLabel.GO;
				_sponsorInput.textEditorProperties.restrict = "0-9";
				_sponsorInput.textEditorProperties.softKeyboardType = SoftKeyboardType.NUMBER;
				_sponsorInput.addEventListener(FeathersEventType.ENTER, onEnterKeyPressed);
				addChild(_sponsorInput);

				_infoButton = new Button(AbstractEntryPoint.assets.getTexture("info-icon"));
				_infoButton.scaleX = _infoButton.scaleY = GlobalConfig.dpiScale;
				_infoButton.addEventListener(Event.TRIGGERED, onInfoTouched);
				addChild(_infoButton);
			}
			
			_facebookButton = ButtonFactory.getFacebookButton(_("Connexion"), ButtonFactory.FACEBOOK_TYPE_NORMAL);
			_facebookButton.addEventListener(Event.TRIGGERED, onConnectFacebook);
			addChild(_facebookButton);

			_warningLabel = new TextField(5, 5, _("Nous ne publierons jamais sur votre mur sans votre accord"), Theme.FONT_ARIAL, scaleAndRoundToDpi(25), 0x6d6d6d, true);
			_warningLabel.autoSize = TextFieldAutoSize.VERTICAL;
			addChild(_warningLabel);
		}
		
		override protected function draw():void
		{
			_notificationTitle.width = this.actualWidth;
			if( AbstractGameInfo.LANDSCAPE )
			{
				_bonusList.width = actualWidth;
				_bonusList.validate();
				_bonusList.x = roundUp((actualWidth - _bonusList.width) * 0.5);
				_bonusList.y = roundUp(_notificationTitle.y + _notificationTitle.height) + scaleAndRoundToDpi(10);
						
				if(_sponsorInput)
				{
					/*
					_sponsorInput.x = roundUp((actualWidth - _sponsorInput.width) * 0.5);
					_sponsorInput.y = roundUp(_bonusList.y + _bonusList.height + scaleAndRoundToDpi(10));
					
					_sponsorInput.validate();
					_facebookButton.x = roundUp((actualWidth - _facebookButton.width) * 0.5);
					_facebookButton.y = roundUp(_sponsorInput.y + _sponsorInput.height + scaleAndRoundToDpi(5));
					*/
					
					_sponsorInput.width = _facebookButton.width = actualWidth * 0.5;
					_sponsorInput.validate();
					_sponsorInput.x = roundUp((actualWidth - _sponsorInput.width - _facebookButton.width - (actualWidth * 0.)) * 0.5);
					_facebookButton.x = _sponsorInput.x + _sponsorInput.width + (actualWidth * 0.);
					_sponsorInput.y = _facebookButton.y = roundUp(_bonusList.y + _bonusList.height + scaleAndRoundToDpi(10));
					_sponsorInput.y += scaleAndRoundToDpi(13);

					_infoButton.x = _sponsorInput.x + _sponsorInput.width - _infoButton.width;
					_infoButton.y = _sponsorInput.y + (_sponsorInput.height - _infoButton.height) * 0.5;
				}
				else
				{
					_facebookButton.x = roundUp((actualWidth - _facebookButton.width) * 0.5);
					_facebookButton.y = roundUp(_bonusList.y + _bonusList.height + scaleAndRoundToDpi(10));
				}
				
				_warningLabel.width = actualWidth * 0.7;
				_warningLabel.x = roundUp((actualWidth - _warningLabel.width) * 0.5);
				_warningLabel.y = _facebookButton.y + _facebookButton.height;
				
				//paddingTop = paddingBottom = scaleAndRoundToDpi(10);
			}
			else
			{
				_notificationTitle.y = scaleAndRoundToDpi(5);
				
				_facebookButton.x = roundUp((actualWidth - _facebookButton.width) * 0.5);
				
				paddingBottom = scaleAndRoundToDpi(10);
			}
			
			super.draw();
		}
		
//------------------------------------------------------------------------------------------------------------
//	Handlers
		
		/**
		 * The user touched the "Enter" / "Next" key, so we validate the form or simply go to
		 * the next input depending on the current input.
		 */
		private function onEnterKeyPressed(event:Event):void
		{
			onConnectFacebook();
		}
		
		/**
		 * Connect with Facebook
		 */
		private function onConnectFacebook(event:Event = null):void
		{
			if(_sponsorInput)
			{
				_sponsorInput.clearFocus();
				FacebookManager.sponsorId = _sponsorInput.text == "" ? "0" : _sponsorInput.text;
			}
			
			FacebookManager.getInstance().addEventListener(FacebookManagerEventType.AUTHENTICATED, onConnectedWithFacebook);
			FacebookManager.getInstance().connect();
		}
		
		/**
		 * Used successfully connected with Facebook
		 */
		private function onConnectedWithFacebook(event:Event):void
		{
			FacebookManager.getInstance().removeEventListener(FacebookManagerEventType.AUTHENTICATED, onConnectedWithFacebook);
			data = true;
			
			// TODO if event.data.bonusAdded ...
			// it will mean that we need to animate the bonus
			// else, bonus already granted
			
			close();
		}

		/**
		 * The user touched the "I already have an account" link. He is redirected
		 * the the LoginScreen.
		 */
		private function onInfoTouched(event:Event):void
		{
			//NotificationPopupManager.addNotification( new FaqNotificationContent(new FaqQuestionAnswerData({question:_("Qu'est-ce que le code parrain ?"), reponse:})));
			if( !_isCalloutDisplaying )
			{
				if( !_calloutLabel )
				{
					_calloutLabel = new TextField(actualWidth * 0.9, 5,
							_("Le code parrain est un numéro correspondant à l'identifiant d'un joueur sur l'application.\n\nLorsqu'un joueur ou un ami souhaite vous parrainer, il vous envoie son code joueur que vous pouvez saisir dans ce champ en vous inscrivant."),
							Theme.FONT_SANSITA, scaleAndRoundToDpi(26), Theme.COLOR_DARK_GREY);
					_calloutLabel.autoSize = TextFieldAutoSize.VERTICAL;
				}
				_isCalloutDisplaying = true;
				var callout:Callout = Callout.show(_calloutLabel, _infoButton, Callout.DIRECTION_UP, false);
				callout.disposeContent = false;
				callout.touchable = false;
				callout.addEventListener(Event.REMOVED_FROM_STAGE, onCalloutRemoved);
			}
		}

		private function onCalloutRemoved(event:Event):void
		{
			event.target.removeEventListener(Event.REMOVED_FROM_STAGE, onCalloutRemoved);
			_isCalloutDisplaying = false;
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
		
		override public function dispose():void
		{
			FacebookManager.getInstance().removeEventListener(FacebookManagerEventType.AUTHENTICATED, onConnectedWithFacebook);
			
			_notificationTitle.removeFromParent(true);
			_notificationTitle = null;
			
			_bonusList.removeFromParent(true);
			_bonusList = null;
			
			if(_sponsorInput)
			{
				_sponsorInput.removeEventListener(FeathersEventType.ENTER, onEnterKeyPressed);
				_sponsorInput.removeFromParent(true);
				_sponsorInput = null;
			}
			
			if(_infoButton)
			{
				_infoButton.removeEventListener(Event.TRIGGERED, onInfoTouched);
				_infoButton.removeFromParent(true);
				_infoButton = null;
			}
			
			_facebookButton.removeEventListener(Event.TRIGGERED, onConnectFacebook);
			_facebookButton.removeFromParent(true);
			_facebookButton = null;

			_warningLabel.removeFromParent(true);
			_warningLabel = null;
			
			if(_calloutLabel)
			{
				_calloutLabel.removeFromParent(true);
				_calloutLabel = null;
			}
			
			super.dispose();
		}
	}
}