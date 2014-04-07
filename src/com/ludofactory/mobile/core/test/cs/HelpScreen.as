/*
LudoFactory
Framework mobile
Author  : Maxime Lhoez
Created : 25 août 2012
*/
package com.ludofactory.mobile.core.test.cs
{
	import com.gamua.flox.Flox;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.AbstractGameInfo;
	import com.ludofactory.mobile.core.Localizer;
	import com.ludofactory.mobile.core.controls.AdvancedScreen;
	import com.ludofactory.mobile.core.controls.OffsetTabBar;
	import com.ludofactory.mobile.core.controls.ScreenIds;
	import com.ludofactory.mobile.core.notification.NotificationManager;
	import com.ludofactory.mobile.core.test.config.GlobalConfig;
	import com.ludofactory.mobile.core.test.cs.display.CSMessageData;
	import com.ludofactory.mobile.core.test.cs.display.CSMessagesContainer;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import feathers.controls.Button;
	import feathers.controls.ImageLoader;
	import feathers.controls.Label;
	import feathers.data.ListCollection;
	
	import starling.display.Quad;
	import starling.events.Event;
	import starling.utils.formatString;
	
	public class HelpScreen extends AdvancedScreen
	{
		/**
		 * The FAQ icon. */		
		private var _faqIcon:ImageLoader;
		/**
		 * FAQ button */		
		private var _faqButton:Button;
		
		/**
		 * The FAQ icon. */		
		private var _csIcon:ImageLoader;
		/**
		 * The create new message button */		
		private var _contactCustomerServiceButton:Button;
		
		/**
		 * Application version label */		
		private var _appVersionLabel:Label;
		
		/**
		 * The main menu */		
		private var _menu:OffsetTabBar;
		
		/**
		 * List of pending messages */		
		private var _pendingMessagesContent:CSMessagesContainer;
		
		/**
		 * List of solved messages */		
		private var _solvedMessagesContent:CSMessagesContainer;
		
		/**
		 * Messages white background. */		
		private var _messagesBackground:Quad;
		
		public function HelpScreen()
		{
			super();
			
			_appClearBackground = false;
			_whiteBackground = true;
			_fullScreen = false;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			_headerTitle = Localizer.getInstance().translate("CUSTOMER_SERVICE_HOME.HEADER_TITLE");
			
			_faqIcon = new ImageLoader();
			_faqIcon.source = AbstractEntryPoint.assets.getTexture("help-icon");
			_faqIcon.scaleX = _faqIcon.scaleY = GlobalConfig.dpiScale;
			_faqIcon.snapToPixels = true;
			
			_faqButton = new Button();
			_faqButton.nameList.add( Theme.BUTTON_TRANSPARENT_BLUE );
			_faqButton.defaultIcon = _faqIcon;
			_faqButton.iconPosition = Button.ICON_POSITION_TOP;
			_faqButton.addEventListener(Event.TRIGGERED, onFaqSelected);
			_faqButton.label = Localizer.getInstance().translate("CUSTOMER_SERVICE_HOME.FAQ_BUTTON_LABEL");
			addChild(_faqButton);
			
			_csIcon = new ImageLoader();
			_csIcon.source = AbstractEntryPoint.assets.getTexture("cs-icon");
			_csIcon.scaleX = _csIcon.scaleY = GlobalConfig.dpiScale;
			_csIcon.snapToPixels = true;
			
			_contactCustomerServiceButton = new Button();
			_contactCustomerServiceButton.nameList.add( Theme.BUTTON_TRANSPARENT_BLUE );
			_contactCustomerServiceButton.defaultIcon = _csIcon;
			_contactCustomerServiceButton.iconPosition = Button.ICON_POSITION_TOP;
			_contactCustomerServiceButton.addEventListener(Event.TRIGGERED, onContactCustomerServiceSelected);
			_contactCustomerServiceButton.label = Localizer.getInstance().translate("CUSTOMER_SERVICE_HOME.CONTACT_BUTTON_LABEL");
			addChild(_contactCustomerServiceButton);
			
			_appVersionLabel = new Label();
			_appVersionLabel.text = formatString(Localizer.getInstance().translate("CUSTOMER_SERVICE_HOME.APP_VERSION_LABEL"), AbstractGameInfo.GAME_VERSION);
			addChild(_appVersionLabel);
			_appVersionLabel.textRendererProperties.textFormat = new TextFormat(Theme.FONT_ARIAL, scaleAndRoundToDpi(26), Theme.COLOR_LIGHT_GREY, true, true, null, null, null, TextFormatAlign.CENTER);
			
			_menu = new OffsetTabBar();
			_menu.addEventListener(Event.CHANGE, onChangeTab);
			_menu.dataProvider = new ListCollection([ Localizer.getInstance().translate("CUSTOMER_SERVICE_HOME.MENU_PENDING"),
													  Localizer.getInstance().translate("CUSTOMER_SERVICE_HOME.MENU_SOLVED") ]);
			addChild(_menu);
			
			_messagesBackground = new Quad(50, 50);
			addChild(_messagesBackground);
			
			_pendingMessagesContent = new CSMessagesContainer(CSState.PENDING);
			_pendingMessagesContent.addEventListener(Event.CHANGE, onMessageSelected);
			addChild(_pendingMessagesContent);
		}
		
		override protected function draw():void
		{
			if( isInvalid( INVALIDATION_FLAG_SIZE ) )
			{
				_faqButton.width = _contactCustomerServiceButton.width = this.actualWidth * 0.4;
				_faqButton.x = (actualWidth * 0.5) - _faqButton.width - scaleAndRoundToDpi(20);
				_contactCustomerServiceButton.x = (actualWidth * 0.5) + scaleAndRoundToDpi(20);
				_faqButton.y = _contactCustomerServiceButton.y = scaleAndRoundToDpi(GlobalConfig.isPhone ? 18 : 30);
				_faqButton.validate();
				_contactCustomerServiceButton.validate();
				_faqButton.height = _contactCustomerServiceButton.height = Math.max(_faqButton.height, _contactCustomerServiceButton.height);
				
				_contactCustomerServiceButton.validate();
				
				_appVersionLabel.width = this.actualWidth;
				_appVersionLabel.y = _contactCustomerServiceButton.y + _contactCustomerServiceButton.height + scaleAndRoundToDpi(GlobalConfig.isPhone ? 18 : 30);
				_appVersionLabel.validate();
				
				_menu.width = this.actualWidth;
				_menu.y = _appVersionLabel.y + _appVersionLabel.height + scaleAndRoundToDpi(GlobalConfig.isPhone ? 18 : 30);
				_menu.validate();
				
				_pendingMessagesContent.y = _messagesBackground.y = _menu.y + _menu.height;
				_pendingMessagesContent.width = _messagesBackground.width = this.actualWidth;
				_pendingMessagesContent.height = _messagesBackground.height = this.actualHeight - _pendingMessagesContent.y;
			}
		}
		
		private function layoutSolvedMessagesContainer():void
		{
			_solvedMessagesContent.y = _pendingMessagesContent.y;
			_solvedMessagesContent.width = this.actualWidth;
			_solvedMessagesContent.height = this.actualHeight - _solvedMessagesContent.y;
		}
		
		override public function onBack():void
		{
			if( NotificationManager.isNotificationDisplaying )
			{
				NotificationManager.closeNotification();
				return;
			}
			
			super.onBack();
		}
		
//------------------------------------------------------------------------------------------------------------
//	Handlers
//------------------------------------------------------------------------------------------------------------
		
		/**
		 * FAQ selected.
		 */		
		private function onFaqSelected(event:Event):void
		{
			advancedOwner.showScreen( ScreenIds.FAQ_SCREEN );
		}
		
		/**
		 * Create a new thread.
		 */		
		private function onContactCustomerServiceSelected(event:Event):void
		{
			Flox.logInfo("Ouverture de la popup de nouveau message au service client.");
			NotificationManager.addNotification( new CSNewThreadNotification(), onCloseNewMessageNotification );
		}
		
		/**
		 * When the new message notification is closed.
		 * 
		 * <p>If <code>event.data</code> is not null, this means that
		 * we need to refresh the list because a new thread have been
		 * added.</p>
		 */		
		private function onCloseNewMessageNotification(event:Event):void
		{
			if( event.data )
			{
				Flox.logInfo("Nouveau message envoyé au service client.");
				_pendingMessagesContent.refreshList();
			}
			else
			{
				Flox.logInfo("Annulation de l'envoi du nouveau message.");
			}
		}
		
		/**
		 * The user changed tab.
		 */		
		private function onChangeTab(event:Event):void
		{
			switch(_menu.selectedIndex)
			{
				case 0:
				{
					Flox.logInfo("\t\tAffichage de l'onglet [Problèmes en cours]");
					_pendingMessagesContent.visible = true;
					
					if( _solvedMessagesContent )
						_solvedMessagesContent.visible = false;
					
					break;
				}
				case 1:
				{
					Flox.logInfo("\t\tAffichage de l'onglet [Problèmes résolus]");
					_pendingMessagesContent.visible = false;
					
					if( !_solvedMessagesContent )
					{
						_solvedMessagesContent = new CSMessagesContainer(CSState.SOLVED);
						_solvedMessagesContent.addEventListener(Event.CHANGE, onMessageSelected);
						addChild(_solvedMessagesContent);
						layoutSolvedMessagesContainer();
					}
					_solvedMessagesContent.visible = true;
					
					break;
				}
			}
		}
		
		/**
		 * A message was selected in one of the lists.
		 */		
		private function onMessageSelected(event:Event):void
		{
			this.advancedOwner.screenData.thread = CSMessageData(event.data);
			this.advancedOwner.showScreen( ScreenIds.CUSTOMER_SERVICE_THREAD_SCREEN );
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
//------------------------------------------------------------------------------------------------------------
		
		override public function dispose():void
		{
			_faqButton.removeEventListener(Event.TRIGGERED, onFaqSelected);
			_faqButton.removeFromParent(true);
			_faqButton = null;
			
			_contactCustomerServiceButton.removeEventListener(Event.TRIGGERED, onContactCustomerServiceSelected);
			_contactCustomerServiceButton.removeFromParent(true);
			_contactCustomerServiceButton = null;
			
			_appVersionLabel.removeFromParent(true);
			_appVersionLabel = null;
			
			_menu.removeEventListener(Event.CHANGE, onChangeTab);
			_menu.removeFromParent(true);
			_menu = null;
			
			_messagesBackground.removeFromParent(true);
			_messagesBackground = null;
			
			_pendingMessagesContent.removeEventListener(Event.CHANGE, onMessageSelected);
			_pendingMessagesContent.removeFromParent(true);
			_pendingMessagesContent = null;
			
			if( _solvedMessagesContent )
			{
				_solvedMessagesContent.removeEventListener(Event.CHANGE, onMessageSelected);
				_solvedMessagesContent.removeFromParent(true);
				_solvedMessagesContent = null;
			}
			
			super.dispose();
		}
	}
}