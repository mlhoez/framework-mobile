/*
Copyright © 2006-2014 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 8 sept. 2013
*/
package com.ludofactory.mobile.core.test.sponsor.invite
{
	import com.freshplanet.ane.airaddressbook.AirAddressBook;
	import com.freshplanet.ane.airaddressbook.AirAddressBookContactsEvent;
	import com.freshplanet.nativeExtensions.AirNetworkInfo;
	import com.gamua.flox.Flox;
	import com.greensock.TweenMax;
	import com.greensock.easing.Bounce;
	import com.ludofactory.common.utils.Utility;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.AbstractGameInfo;
	import com.ludofactory.mobile.core.Localizer;
	import com.ludofactory.mobile.core.authentication.MemberManager;
	import com.ludofactory.mobile.core.authentication.NotLoggedInContainer;
	import com.ludofactory.mobile.core.authentication.RetryContainer;
	import com.ludofactory.mobile.core.controls.AdvancedScreen;
	import com.ludofactory.mobile.core.manager.InfoContent;
	import com.ludofactory.mobile.core.manager.InfoManager;
	import com.ludofactory.mobile.core.remoting.Remote;
	import com.ludofactory.mobile.core.test.config.GlobalConfig;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import flash.text.ReturnKeyLabel;
	import flash.text.SoftKeyboardType;
	import flash.text.TextFormat;
	import flash.utils.Dictionary;
	
	import feathers.controls.Button;
	import feathers.controls.Label;
	import feathers.controls.LayoutGroup;
	import feathers.controls.List;
	import feathers.controls.TextInput;
	import feathers.controls.supportClasses.ListDataViewPort;
	import feathers.data.ListCollection;
	import feathers.events.FeathersEventType;
	import feathers.layout.HorizontalLayout;
	import feathers.layout.VerticalLayout;
	
	import pl.mllr.extensions.contactEditor.ContactEditor;
	
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.MovieClip;
	import starling.display.Quad;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.utils.formatString;
	
	public class SponsorInviteScreen extends AdvancedScreen
	{
		/**
		 * The title. */		
		private var _title:Label;
		
		/**
		 * The invite all button. */		
		private var _inviteAllButton:Button;
		
		/**
		 * Thel ist background. */		
		private var _background:Quad;
		
		/**
		 * The list shadow */		
		private var _listShadow:Quad;
		
		/**
		 * The list shadow */		
		private var _listBottomShadow:Quad;
		
		/**
		 * The contacts list. */		
		private var _contactsList:List;
		
		/**
		 * Contact editor. */		
		private var _contactEditor:ContactEditor;
		
		/**
		 * Contacts. */		
		private var _contacts:Vector.<ContactData>;
		
		/**
		 * The loader. */		
		private var _loader:MovieClip;
		
		/**
		 * The retry container. */		
		private var _retryContainer:RetryContainer;
		
		private var _allContacts:Array;
		private var _temporaryContacts:Dictionary;
		
		/**
		 * The authentication container. */		
		private var _authenticationContainer:NotLoggedInContainer;
		
		/**
		 * The login group. */		
		private var _singleInviteGroup:LayoutGroup;
		/**
		 * The login arrow. */		
		private var _singleInviteArrow:Image;
		/**
		 * The login button. */		
		private var _singleInviteButton:Button;
		
		private var _validateSingleInviteButton:Button;
		
		public function SponsorInviteScreen()
		{
			super();
			
			_whiteBackground = true;
			_appClearBackground = false;
			_fullScreen = false;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			_headerTitle = Localizer.getInstance().translate("SPONSOR_INVITE.HEADER_TITLE");
			
			_loader = new MovieClip(AbstractEntryPoint.assets.getTextures("MiniLoader"));
			_loader.scaleX = _loader.scaleY = GlobalConfig.dpiScale;
			_loader.alignPivot();
			_loader.touchable = false;
			_loader.alpha = 0;
			_loader.visible = false;
			Starling.juggler.add(_loader);
			addChild(_loader);
			
			_title = new Label();
			_title.visible = false;
			_title.text = Localizer.getInstance().translate( advancedOwner.screenData.sponsorType == SponsorTypes.SMS ? "SPONSOR_INVITE.TITLE_WHEN_SMS":"SPONSOR_INVITE.TITLE_WHEN_EMAIL" );
			addChild(_title);
			_title.textRendererProperties.textFormat = new TextFormat(Theme.FONT_ARIAL, scaleAndRoundToDpi(24), 0x636363, true);
			
			_inviteAllButton = new Button();
			_inviteAllButton.visible = false
			_inviteAllButton.nameList.add( Theme.BUTTON_FLAT_GREEN );
			_inviteAllButton.label = Localizer.getInstance().translate("SPONSOR_INVITE.INVITE_ALL_BUTTON_LABEL");
			_inviteAllButton.addEventListener(Event.TRIGGERED, onInviteAll);
			addChild(_inviteAllButton);
			
			_background = new Quad(5, 5);
			addChild(_background);
			
			_listShadow = new Quad(50, scaleAndRoundToDpi(12), 0x000000);
			_listShadow.setVertexColor(0, 0xffffff);
			_listShadow.setVertexAlpha(0, 0);
			_listShadow.setVertexColor(1, 0xffffff);
			_listShadow.setVertexAlpha(1, 0);
			_listShadow.setVertexAlpha(2, 0.1);
			_listShadow.setVertexAlpha(3, 0.1);
			addChild(_listShadow);
			
			_listBottomShadow = new Quad(50, scaleAndRoundToDpi(12), 0x000000);
			_listBottomShadow.setVertexAlpha(0, 0.1);
			_listBottomShadow.setVertexAlpha(1, 0.1);
			_listBottomShadow.setVertexColor(2, 0xffffff);
			_listBottomShadow.setVertexAlpha(2, 0);
			_listBottomShadow.setVertexColor(3, 0xffffff);
			_listBottomShadow.setVertexAlpha(3, 0);
			addChild(_listBottomShadow);
			
			const vlayout:VerticalLayout = new VerticalLayout();
			vlayout.useVirtualLayout = false;
			
			_contactsList = new List();
			_contactsList.layout = vlayout;
			//_contactsList.backgroundSkin = new Quad(50, 50);
			_contactsList.isSelectable = false;
			_contactsList.itemRendererType = ContactItemRenderer;
			addChild(_contactsList);
			
			_retryContainer = new RetryContainer();
			_retryContainer.loadingMode = true;
			addChild(_retryContainer);
			
			_authenticationContainer = new NotLoggedInContainer();
			_authenticationContainer.visible = false;
			addChild(_authenticationContainer);
			
			var hlayout:HorizontalLayout = new HorizontalLayout();
			hlayout.horizontalAlign = HorizontalLayout.HORIZONTAL_ALIGN_LEFT;
			hlayout.verticalAlign = HorizontalLayout.VERTICAL_ALIGN_MIDDLE;
			hlayout.gap = scaleAndRoundToDpi(10);
			
			_singleInviteGroup = new LayoutGroup();
			_singleInviteGroup.visible = false;
			_singleInviteGroup.layout = hlayout;
			addChild(_singleInviteGroup);
			
			_singleInviteArrow = new Image( AbstractEntryPoint.assets.getTexture("arrow-right-dark"));
			_singleInviteArrow.scaleX = _singleInviteArrow.scaleY = GlobalConfig.dpiScale;
			_singleInviteGroup.addChild(_singleInviteArrow);
			
			_singleInviteButton = new Button();
			_singleInviteButton.nameList.add( Theme.BUTTON_EMPTY );
			_singleInviteButton.addEventListener(Event.TRIGGERED, onSingleInvite);
			_singleInviteButton.label = Localizer.getInstance().translate( advancedOwner.screenData.sponsorType == SponsorTypes.EMAIL ? "SPONSOR_INVITE.FILL_EMAIL" : "SPONSOR_INVITE.FILL_SMS");
			_singleInviteGroup.addChild(_singleInviteButton);
			_singleInviteButton.minHeight = _singleInviteButton.minTouchHeight = scaleAndRoundToDpi(70);
			_singleInviteButton.defaultLabelProperties.textFormat = new TextFormat(Theme.FONT_ARIAL, scaleAndRoundToDpi(30), Theme.COLOR_DARK_GREY, true, true);
			
			if( MemberManager.getInstance().isLoggedIn() )
			{
				_retryContainer.visible = true;
				TweenMax.delayedCall(1, initializeContacts);
			}
			else
			{
				_retryContainer.visible = false;
				_authenticationContainer.visible = true;
			}
		}
		
		private function initializeContacts():void
		{
			_temporaryContacts = new Dictionary();
			_singleInviteGroup.visible = true;
			
			if( AirAddressBook.isSupported )
			{
				if( GlobalConfig.ios )
				{
					if( AirAddressBook.getInstance().hasPermission() )
					{
						AirAddressBook.getInstance().addEventListener(AirAddressBook.CONTACTS_UPDATED, onContactsUpdated);
						AirAddressBook.getInstance().check(50);
						TweenMax.to(this, 5, { onComplete:onContactsRetreived });
					}
					else
					{
						_retryContainer.loadingMode = false;
						_retryContainer.singleMessageMode = true;
						_retryContainer.message = formatString(Localizer.getInstance().translate("SPONSOR_INVITE.PERMISSION_DENIED"), AbstractGameInfo.GAME_NAME);
					}
				}
				else
				{
					var contacts:Array;
					if( ContactEditor.isSupported )
					{
						_contactEditor = new ContactEditor();
						contacts = _contactEditor.getContacts();
					}
					
					_contacts = new Vector.<ContactData>();
					var singleContact:Object;
					var phoneNumberString:String;
					var tempPhoneNumbers:Array;
					for each(singleContact in contacts)
					{
						// for each contact, we need to check 
						switch(advancedOwner.screenData.sponsorType)
						{
							case SponsorTypes.EMAIL:
							{
								// if there is at least 1 email, then we can push this contact to the list
								if( singleContact.hasOwnProperty("emails") && singleContact.emails && (singleContact.emails as Array).length > 0)
									_contacts.push( new ContactData( singleContact, SponsorTypes.EMAIL ) );
								break;
							}
							case SponsorTypes.SMS:
							{
								// if there is at least 1 phone number, then we can start checking the numbers
								if( singleContact.hasOwnProperty("phones") && singleContact.phones && (singleContact.phones as Array).length > 0)
								{
									// display only valid french portables phone numbers
									tempPhoneNumbers = [];
									for each(phoneNumberString in singleContact.phones)
									{
										if( Utility.isFrenchPortableOnly( phoneNumberString ) )
											tempPhoneNumbers.push( Utility.isFrenchPortableOnly( phoneNumberString ) );
									}
									
									if( tempPhoneNumbers.length > 0 )
									{
										singleContact.phones = tempPhoneNumbers;
										_contacts.push( new ContactData( singleContact, SponsorTypes.SMS ) );
									}
								}
								break;
							}
						}
					}
					
					if( _contacts.length == 0 )
					{
						_retryContainer.loadingMode = false;
						_retryContainer.singleMessageMode = true;
						_retryContainer.message = Localizer.getInstance().translate("SPONSOR_INVITE.NO_CONTACT");
					}
					else
					{
						_retryContainer.visible = false;
					}
					
					_title.visible = true;
					_inviteAllButton.visible = true;
					
					_loader.alpha = 0;
					_loader.visible = false;
					_loader.x = _inviteAllButton.x;
					_loader.y = _inviteAllButton.y;
					
					_contactsList.dataProvider = new ListCollection( _contacts );
				}
			}
			else
			{
				_retryContainer.loadingMode = false;
				_retryContainer.singleMessageMode = true;
				_retryContainer.message = Localizer.getInstance().translate("SPONSOR_INVITE.CANNOT_ACCESS_CONTACTS");
			}
		}
		
		private function onContactsUpdated(event:AirAddressBookContactsEvent):void
		{
			TweenMax.killTweensOf(this);
			
			var contactData:Object;
			var temporaryPhoneNumber:String;
			var key:String;
			
			for(key in event.contactsData)
			{
				contactData = event.contactsData[key];
				
				if( !_temporaryContacts.hasOwnProperty(contactData.compositeName) )
					_temporaryContacts[contactData.compositeName] = { compositename:contactData.compositeName, phones:[], emails:[] };
				
				if( key.indexOf("phoneNumber_") != -1 )
				{
					temporaryPhoneNumber = key.split("_")[1];
					if( Utility.isFrenchPortableOnly( temporaryPhoneNumber ) )
						_temporaryContacts[contactData.compositeName].phones.push( Utility.isFrenchPortableOnly( temporaryPhoneNumber ) );
				}
				if( key.indexOf("email_") != -1 )
					_temporaryContacts[contactData.compositeName].emails.push( key.split("_")[1] );
			}
			
			if( event.isLastPacket )
			{
				AirAddressBook.getInstance().removeEventListener(AirAddressBook.CONTACTS_UPDATED, onContactsUpdated);
				_allContacts = [];
				for(key in _temporaryContacts)
					_allContacts.push( _temporaryContacts[key] );
				_allContacts.sortOn("compositename", Array.CASEINSENSITIVE);
				onContactsRetreived();
			}
		}
		
		private function onContactsRetreived():void
		{
			_contacts = new Vector.<ContactData>();
			var singleContact:Object;
			var phoneNumberString:String;
			var tempPhoneNumbers:Array;
			for each(singleContact in _allContacts)
			{
				// for each contact, we need to check 
				switch(advancedOwner.screenData.sponsorType)
				{
					case SponsorTypes.EMAIL:
					{
						// if there is at least 1 email, then we can push this contact to the list
						if( (singleContact.emails as Array).length > 0)
							_contacts.push( new ContactData( singleContact, SponsorTypes.EMAIL ) );
						break;
					}
					case SponsorTypes.SMS:
					{
						// if there is at least 1 phone number, then we can start checking the numbers
						if( (singleContact.phones as Array).length > 0)
							_contacts.push( new ContactData( singleContact, SponsorTypes.SMS ) );
						break;
					}
				}
			}
			
			if( _contacts.length == 0 )
			{
				_retryContainer.loadingMode = false;
				_retryContainer.singleMessageMode = true;
				_retryContainer.message = Localizer.getInstance().translate("SPONSOR_INVITE.NO_CONTACT");
			}
			else
			{
				_retryContainer.visible = false;
			}
			
			_temporaryContacts = null;
			_allContacts = [];
			_allContacts = null;
			
			_title.visible = true;
			_inviteAllButton.visible = true;
			
			_loader.alpha = 0;
			_loader.visible = false;
			_loader.x = _inviteAllButton.x;
			_loader.y = _inviteAllButton.y;
			
			_contactsList.dataProvider = new ListCollection( _contacts );
		}
		
		override protected function draw():void
		{
			if( isInvalid(INVALIDATION_FLAG_SIZE) )
			{
				_loader.x = this.actualWidth * 0.5;
				_loader.y = this.actualHeight * 0.5;
				
				_inviteAllButton.width = (this.actualWidth - scaleAndRoundToDpi(40)) * 0.3;
				_inviteAllButton.validate();
				_inviteAllButton.height = _inviteAllButton.height;
				_inviteAllButton.alignPivot();
				_inviteAllButton.y = scaleAndRoundToDpi(20) + (_inviteAllButton.height * 0.5);
				_inviteAllButton.x = this.actualWidth - scaleAndRoundToDpi(20) - (_inviteAllButton.width * 0.5);
				
				_title.x = scaleAndRoundToDpi(20);
				_title.width = (this.actualWidth - scaleAndRoundToDpi(40)) * 0.7;
				_title.validate();
				_title.y = (_inviteAllButton.height - _title.height) + scaleAndRoundToDpi(20);
				
				_listShadow.width = this.actualWidth;
				_listShadow.y = _inviteAllButton.y + (_inviteAllButton.height * 0.5) + scaleAndRoundToDpi(20);
				
				_singleInviteGroup.validate();
				_singleInviteGroup.y = actualHeight - _singleInviteGroup.height - scaleAndRoundToDpi(10);
				_singleInviteGroup.x = (actualWidth - _singleInviteGroup.width) * 0.5;
				
				_listBottomShadow.width = this.actualWidth;
				_listBottomShadow.y = _singleInviteGroup.y - _listBottomShadow.height - scaleAndRoundToDpi(20);
				
				_background.width = _contactsList.width = actualWidth;
				_contactsList.y = _background.y = _listShadow.y + _listShadow.height;
				_contactsList.height = _background.height = _listBottomShadow.y - _contactsList.y;
				
				_retryContainer.width = actualWidth * (GlobalConfig.isPhone ? 0.8 : 0.6);
				_retryContainer.height = actualHeight;
				
				_authenticationContainer.width = _retryContainer.width = actualWidth;
				_authenticationContainer.height = _retryContainer.height = actualHeight;
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Handlers
//------------------------------------------------------------------------------------------------------------
		
		/**
		 * Invite all possible contatcs in the list.
		 * 
		 * <p>When this button is touched, we check the <code>invited</code>
		 * property on each contact in the list to know if we can really invite
		 * this contact. If this property is set to true, this means that the user
		 * have invited this contact by touching the "invite" button in the item
		 * renderer. Otherwise, we display a loader in each item renderer that can
		 * be invited, only if it is not already processing (if the renderer <code>
		 * isInviting</code> property is set to true, we'll do nothing).</p>
		 * 
		 * <p>If all contact have already been invited, the "invite all"
		 * button is disabled.</p>
		 */		
		private function onInviteAll(event:Event):void
		{
			if( AirNetworkInfo.networkInfo.isConnected() )
			{
				var contactsToInvite:Array = [];
				var len:int = (_contactsList.viewPort as ListDataViewPort).numChildren;
				var contactItemRenderer:ContactItemRenderer;
				var contactData:ContactData;
				for(var i:int = 0; i < len; i++)
				{
					contactItemRenderer = ContactItemRenderer( (_contactsList.viewPort as ListDataViewPort).getChildAt(i) );
					if( !contactItemRenderer.isInvited && !contactItemRenderer.isInviting )
					{
						contactData = ContactData( contactItemRenderer.data );
						contactsToInvite.push( { identifiant:contactData.selectedContactElement, filleul:contactData.name } );
						contactItemRenderer.setInviteMode();
					}
				}
				
				if( contactsToInvite.length > 0 )
				{
					Flox.logInfo("Envoi d'un {0} de parrainage (via le bouton inviter tous) à <strong>{1}</strong> personnes", (advancedOwner.screenData.sponsorType == SponsorTypes.SMS ? "sms" : "email"), contactsToInvite.length);
					
					for(var k:int = 0; k < contactsToInvite.length; k++)
						Flox.logEvent("Parrainage par " + (advancedOwner.screenData.sponsorType == SponsorTypes.SMS ? "sms" : "email"), { Total:"Total" });
					
					TweenMax.to(_inviteAllButton, 0.75, { scaleX:0, scaleY:0, autoAlpha:0, ease:Bounce.easeOut });
					TweenMax.to(_loader, 0.75, { delay:0.5, scaleX:GlobalConfig.dpiScale, scaleY:GlobalConfig.dpiScale, autoAlpha:1, ease:Bounce.easeOut });
					TweenMax.delayedCall(1.25, Remote.getInstance().parrainer, [ advancedOwner.screenData.sponsorType, contactsToInvite, onParrainageSuccess, onParrainageFailure, onParrainageFailure, 2, advancedOwner.activeScreenID ]);
				}
				else
				{
					_inviteAllButton.isEnabled = false;
					_inviteAllButton.removeEventListener(Event.TRIGGERED, onInviteAll);
					_inviteAllButton.label = Localizer.getInstance().translate("SPONSOR_INVITE.SENT_ALL_BUTTON_LABEL");
				}
			}
			else
			{
				InfoManager.showTimed(Localizer.getInstance().translate("COMMON.NOT_CONNECTED"), InfoManager.DEFAULT_DISPLAY_TIME, InfoContent.ICON_CROSS);
			}
		}
		
		/**
		 * The parrainage was a success.
		 * 
		 * <p>If the <code>result.code</code> is 0, this means that the user
		 * could not be authenticated in the server side or that the parameters
		 * sent were invalid.</p>
		 * 
		 * <p>Otherwise if it is equal to 1, this means that the request ran fine
		 * but it doesn't mean that all the mails were sent. To check this, an array
		 * <code>result.tab_parrainage</code> is returned and we loop through it in
		 * order to change the state of each associated item renderer.</p>
		 */		
		private function onParrainageSuccess(result:Object):void
		{
			var contactItemRenderer:ContactItemRenderer;
			var len:int = (_contactsList.viewPort as ListDataViewPort).numChildren;
			var individualResult:Object;
			var i:int;
			
			switch(result.code)
			{
				case 0:
				{
					Flox.logEvent("Parrainage par " + (advancedOwner.screenData.sponsorType == SponsorTypes.SMS ? "sms" : "email"), { Etat:"Echec" });
					InfoManager.showTimed(result.txt, 1.5, InfoContent.ICON_CROSS);
					
					for(i = 0; i < len; i++)
					{
						contactItemRenderer = ContactItemRenderer( (_contactsList.viewPort as ListDataViewPort).getChildAt(i) );
						for each(individualResult in result.parrainages)
						{
							if( ContactData(contactItemRenderer.data).selectedContactElement == individualResult.identifiant )
								contactItemRenderer.hideInviteMode();
						}
					}
					
					TweenMax.to(_inviteAllButton, 0.75, { delay:0.5, scaleX:1, scaleY:1, autoAlpha:1, ease:Bounce.easeOut });
					TweenMax.to(_loader, 0.75, { scaleX:0, scaleY:0, autoAlpha:0, ease:Bounce.easeOut });
					
					break;
				}
				case 1:
				{
					var finished:Boolean = true;
					for(i = 0; i < len; i++)
					{
						contactItemRenderer = ContactItemRenderer( (_contactsList.viewPort as ListDataViewPort).getChildAt(i) );
						for each(individualResult in result.tab_parrainage)
						{
							if( ContactData(contactItemRenderer.data).selectedContactElement == individualResult.identifiant )
								contactItemRenderer.onParrainageSuccess( {code:result.code, txt:result.txt, tab_parrainage:[ individualResult ] } );
						}
						if( !contactItemRenderer.isInvited )
							finished = false;
					}
					
					if( finished )
					{
						_inviteAllButton.isEnabled = false;
						_inviteAllButton.removeEventListener(Event.TRIGGERED, onInviteAll);
						_inviteAllButton.label = Localizer.getInstance().translate("SPONSOR_INVITE.SENT_ALL_BUTTON_LABEL");
					}
					
					TweenMax.to(_inviteAllButton, 0.75, { delay:0.5, scaleX:1, scaleY:1, autoAlpha:1, ease:Bounce.easeOut });
					TweenMax.to(_loader, 0.75, { scaleX:0, scaleY:0, autoAlpha:0, ease:Bounce.easeOut });
					
					break;
				}
					
				default:
				{
					onParrainageFailure();
					break;
				}
			}
		}
		
		/**
		 * An error occurred while trying to send emails / sms.
		 */		
		private function onParrainageFailure(error:Object = null):void
		{
			Flox.logEvent("Parrainage par " + (advancedOwner.screenData.sponsorType == SponsorTypes.SMS ? "sms" : "email"), { Etat:"Echec" });
			TweenMax.to(_inviteAllButton, 0.75, { delay:0.5, scaleX:1, scaleY:1, autoAlpha:1, ease:Bounce.easeOut });
			TweenMax.to(_loader, 0.75, { scaleX:0, scaleY:0, autoAlpha:0, ease:Bounce.easeOut });
		}
		
		private var _singleInviteNameInput:TextInput;
		private var _singleInviteMailInput:TextInput;
		private var _overlay:Quad;
		
		private function onEnter(event:Event):void
		{
			_singleInviteMailInput.setFocus();
		}
		
		private function onSingleInvite(event:Event):void
		{
			_overlay = new Quad(actualWidth, actualHeight, 0x000000);
			_overlay.alpha = 0.75;
			_overlay.addEventListener(TouchEvent.TOUCH, onTouchOverlay);
			addChild(_overlay);
			
			_singleInviteNameInput = new TextInput();
			_singleInviteNameInput.prompt = Localizer.getInstance().translate("SPONSOR_INVITE.FILL_NAME_PROMPT");
			_singleInviteNameInput.textEditorProperties.returnKeyLabel = ReturnKeyLabel.GO;
			_singleInviteNameInput.addEventListener(FeathersEventType.SOFT_KEYBOARD_ACTIVATE, onSoftKeyboardActivated);
			_singleInviteNameInput.addEventListener(FeathersEventType.ENTER, onEnter);
			_singleInviteNameInput.setFocus();
			_singleInviteNameInput.alpha = 0;
			_singleInviteNameInput.nameList.add(Theme.TEXTINPUT_FIRST);
			addChild(_singleInviteNameInput);
			
			_singleInviteMailInput = new TextInput();
			_singleInviteMailInput.prompt = Localizer.getInstance().translate( advancedOwner.screenData.sponsorType == SponsorTypes.EMAIL ? "SPONSOR_INVITE.FILL_EMAIL_PROMPT" : "SPONSOR_INVITE.FILL_SMS_PROMPT");
			_singleInviteMailInput.textEditorProperties.softKeyboardType = advancedOwner.screenData.sponsorType == SponsorTypes.EMAIL ? SoftKeyboardType.EMAIL : SoftKeyboardType.CONTACT;
			_singleInviteMailInput.textEditorProperties.returnKeyLabel = ReturnKeyLabel.GO;
			_singleInviteMailInput.addEventListener(FeathersEventType.ENTER, onInvite);
			_singleInviteMailInput.alpha = 0;
			_singleInviteMailInput.nameList.add(Theme.TEXTINPUT_LAST);
			addChild(_singleInviteMailInput);
			
			_validateSingleInviteButton = new Button();
			_validateSingleInviteButton.addEventListener(Event.TRIGGERED, onInvite);
			_validateSingleInviteButton.label = Localizer.getInstance().translate("COMMON.VALIDATE");
			_validateSingleInviteButton.alpha = 0;
			addChild(_validateSingleInviteButton);
		}
		
		private function onTouchOverlay(event:TouchEvent):void
		{
			var touch:Touch = event.getTouch(_overlay);
			if( touch && touch.phase == TouchPhase.ENDED )
			{
				_overlay.removeEventListener(TouchEvent.TOUCH, onTouchOverlay);
				_overlay.removeFromParent(true);
				_overlay = null;
				
				_singleInviteNameInput.removeEventListener(FeathersEventType.SOFT_KEYBOARD_ACTIVATE, onSoftKeyboardActivated);
				_singleInviteNameInput.removeEventListener(FeathersEventType.ENTER, onEnter);
				_singleInviteNameInput.removeFromParent(true);
				_singleInviteNameInput = null;
				
				_singleInviteMailInput.removeEventListener(FeathersEventType.ENTER, onInvite);
				_singleInviteMailInput.removeFromParent(true);
				_singleInviteMailInput = null;
				
				_validateSingleInviteButton.removeEventListener(Event.TRIGGERED, onInvite);
				_validateSingleInviteButton.removeFromParent(true);
				_validateSingleInviteButton = null;
			}
		}
		
		private function onSoftKeyboardActivated(event:Event):void
		{
			_singleInviteMailInput.width = actualWidth * 0.8;
			_singleInviteMailInput.validate();
			_singleInviteMailInput.x = (actualWidth - _singleInviteMailInput.width) * 0.5;
			_singleInviteMailInput.y = (Starling.current.nativeStage.softKeyboardRect.y * 0.5) - _singleInviteMailInput.height;
			_singleInviteMailInput.alpha = 1;
			
			_singleInviteNameInput.width = actualWidth * 0.8;
			_singleInviteNameInput.validate();
			_singleInviteNameInput.x = (actualWidth - _singleInviteMailInput.width) * 0.5;
			_singleInviteNameInput.y = _singleInviteMailInput.y - _singleInviteMailInput.height;
			_singleInviteNameInput.alpha = 1;
			
			_validateSingleInviteButton.width = _singleInviteMailInput.width * 0.8;
			_validateSingleInviteButton.x = (actualWidth - _validateSingleInviteButton.width) * 0.5;
			_validateSingleInviteButton.y = Starling.current.nativeStage.softKeyboardRect.y * 0.5;
			_validateSingleInviteButton.alpha = 1;
		}
		
		/**
		 * Try to invite the contact, whether by email or sms.
		 */		
		private function onInvite(event:Event):void
		{
			if(_singleInviteNameInput.text == "")
			{
				InfoManager.showTimed( Localizer.getInstance().translate("SPONSOR_INVITE.INVALID_NAME"), InfoManager.DEFAULT_DISPLAY_TIME, InfoContent.ICON_CROSS );
				_singleInviteNameInput.setFocus();
				return;
			}
			
			if( advancedOwner.screenData.sponsorType == SponsorTypes.EMAIL )
			{
				if(_singleInviteMailInput.text == "" || !Utility.isValidMail(_singleInviteMailInput.text))
				{
					InfoManager.showTimed( Localizer.getInstance().translate("LOGIN.INVALID_MAIL"), InfoManager.DEFAULT_DISPLAY_TIME, InfoContent.ICON_CROSS );
					_singleInviteMailInput.setFocus();
					return;
				}
			}
			else
			{
				if(_singleInviteMailInput.text == "" || !Utility.isFrenchPortableOnly(_singleInviteMailInput.text))
				{
					InfoManager.showTimed( Localizer.getInstance().translate("SPONSOR_INVITE.INVALID_NUMBER"), InfoManager.DEFAULT_DISPLAY_TIME, InfoContent.ICON_CROSS );
					_singleInviteMailInput.setFocus();
					return;
				}
			}
			
			if( AirNetworkInfo.networkInfo.isConnected() )
			{
				InfoManager.show(Localizer.getInstance().translate("COMMON.LOADING"));
				Flox.logInfo("Envoi d'un {0} de parrainage (via la popup) à <strong>{1}</strong>", (advancedOwner.screenData.sponsorType == SponsorTypes.SMS ? "sms" : "email"), _singleInviteMailInput.text);
				Flox.logEvent("Parrainage par " + (advancedOwner.screenData.sponsorType == SponsorTypes.SMS ? "sms" : "email"), { Total:"Total" });
				_singleInviteNameInput.clearFocus();
				_singleInviteMailInput.clearFocus();
				Remote.getInstance().parrainer(advancedOwner.screenData.sponsorType, [ { identifiant:_singleInviteMailInput.text, filleul:_singleInviteNameInput.text } ], onSingleParrainageSuccess, onSingleParrainageFailure, onSingleParrainageFailure, 2, AbstractEntryPoint.screenNavigator.activeScreenID);
			}
			else
			{
				InfoManager.showTimed(Localizer.getInstance().translate("COMMON.NOT_CONNECTED"), InfoManager.DEFAULT_DISPLAY_TIME, InfoContent.ICON_CROSS);
			}
		}
		
		/**
		 * The parrainage was a success.
		 * 
		 * <p>If the <code>result.code</code> is 0, this means that the user
		 * could not be authenticated in the server side or that the parameters
		 * sent were invalid or that we could not send the email because it is 
		 * already in the database (existing account in Ludokado to we can't 
		 * invite him as a sponsor) or that the mail is not allowed. In this
		 * case, we disable the "invite" button and change the label to indicate
		 * that an error occurred.</p>
		 * 
		 * <p>Otherwise if it is equal to 1, this means that the email could
		 * be sent. In this case, we disable the "invite" button and change the
		 * label to indicate that the email / sms have been sent.</p>
		 */		
		public function onSingleParrainageSuccess(result:Object):void
		{
			switch(result.code)
			{
				case 0: // error
				{
					Flox.logEvent("Parrainage par " + (advancedOwner.screenData.sponsorType == SponsorTypes.SMS ? "sms" : "email"), { Etat:"Echec" });
					InfoManager.hide(result.txt, InfoContent.ICON_CROSS, InfoManager.DEFAULT_DISPLAY_TIME);
					_singleInviteMailInput.setFocus();
					break;
				}
				case 1: // success
				{
					var resultBis:Object = (result.tab_parrainage as Array)[0];
					switch(resultBis.code)
					{
						case 0:
						{
							InfoManager.hide(result.txt, InfoContent.ICON_CROSS, InfoManager.DEFAULT_DISPLAY_TIME);
							break;
						}
						case 1:
						{
							_singleInviteNameInput.text = "";
							_singleInviteMailInput.text = "";
							Flox.logEvent("Parrainage par " + (advancedOwner.screenData.sponsorType == SponsorTypes.SMS ? "sms" : "email"), { Etat:"Succes" });
							InfoManager.hide(result.txt, InfoContent.ICON_CHECK, InfoManager.DEFAULT_DISPLAY_TIME);
							break;
						}
							
						default:
						{
							InfoManager.hide(result.txt, InfoContent.ICON_CROSS, InfoManager.DEFAULT_DISPLAY_TIME);
							break;
						}
					}
					break;
				}
					
				default:
				{
					Flox.logEvent("Parrainage par " + (advancedOwner.screenData.sponsorType == SponsorTypes.SMS ? "sms" : "email"), { Etat:"Echec" });
					InfoManager.hide(result.txt, InfoContent.ICON_CROSS, InfoManager.DEFAULT_DISPLAY_TIME);
					break;
				}
			}
			_singleInviteMailInput.setFocus();
		}
		
		/**
		 * An error occurred while trying to send the email / sms.
		 */		
		private function onSingleParrainageFailure(error:Object = null):void
		{
			Flox.logEvent("Parrainage par " + (advancedOwner.screenData.sponsorType == SponsorTypes.SMS ? "sms" : "email"), { Etat:"Echec" });
			InfoManager.hide(Localizer.getInstance().translate("COMMON.QUERY_FAILURE"), InfoContent.ICON_CROSS, InfoManager.DEFAULT_DISPLAY_TIME);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
//------------------------------------------------------------------------------------------------------------
		
		override public function dispose():void
		{
			AirAddressBook.getInstance().removeEventListener(AirAddressBook.CONTACTS_UPDATED, onContactsUpdated);
			
			Starling.juggler.remove(_loader);
			_loader.removeFromParent(true);
			_loader = null;
			
			_title.removeFromParent(true);
			_title = null;
			
			_inviteAllButton.removeEventListener(Event.TRIGGERED, onInviteAll);
			_inviteAllButton.removeFromParent(true);
			_inviteAllButton = null;
			
			_listShadow.removeFromParent(true);
			_listShadow = null;
			
			if( _overlay )
			{
				_overlay.removeEventListener(TouchEvent.TOUCH, onTouchOverlay);
				_overlay.removeFromParent(true);
				_overlay = null;
			}
			
			if( _singleInviteMailInput )
			{
				_singleInviteMailInput.removeEventListener(FeathersEventType.ENTER, onInvite);
				_singleInviteMailInput.removeFromParent(true);
				_singleInviteMailInput = null;
			}
			
			if( _singleInviteNameInput )
			{
				_singleInviteNameInput.removeEventListener(FeathersEventType.ENTER, onEnter);
				_singleInviteNameInput.removeEventListener(FeathersEventType.SOFT_KEYBOARD_ACTIVATE, onSoftKeyboardActivated);
				_singleInviteNameInput.removeFromParent(true);
				_singleInviteNameInput = null;
			}
			
			if( _validateSingleInviteButton )
			{
				_validateSingleInviteButton.removeEventListener(Event.TRIGGERED, onInvite);
				_validateSingleInviteButton.removeFromParent(true);
				_validateSingleInviteButton = null;
			}
			
			if( _contacts )
			{
				_contacts.length = 0;
				_contacts = null;
			}
			
			if( _contactEditor )
			{
				_contactEditor.dispose();
				_contactEditor = null;
			}
			
			_contactsList.removeFromParent(true);
			_contactsList = null;
			
			super.dispose();
		}
	}
}