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
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.manager.InfoContent;
	import com.ludofactory.mobile.core.manager.InfoManager;
	import com.ludofactory.mobile.core.manager.MemberManager;
	import com.ludofactory.mobile.core.notification.NotificationPopupManager;
	import com.ludofactory.mobile.core.push.PushNewCSThread;
	import com.ludofactory.mobile.core.push.PushType;
	import com.ludofactory.mobile.core.remoting.Remote;
	import com.ludofactory.mobile.core.storage.Storage;
	import com.ludofactory.mobile.core.storage.StorageConfig;
	import com.ludofactory.mobile.core.theme.Theme;
	import com.ludofactory.mobile.navigation.cs.*;
	import com.milkmangames.nativeextensions.GAnalytics;
	
	import feathers.controls.Button;
	import feathers.controls.GroupedList;
	import feathers.controls.Scroller;
	import feathers.controls.TextInput;
	import feathers.controls.popups.IPopUpContentManager;
	import feathers.controls.popups.VerticalCenteredPopUpContentManager;
	import feathers.data.HierarchicalCollection;
	import feathers.events.FeathersEventType;
	import feathers.layout.VerticalLayout;
	
	import flash.text.ReturnKeyLabel;
	import flash.text.SoftKeyboardType;
	
	import starling.display.Image;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.text.TextField;
	
	public class CSNewThreadNotificationContent extends AbstractPopupContent
	{
		/**
		 *  */
		public static const INVALIDATION_FLAG_NEEDS_RESIZE_FOCUS:String = "needs-resize-focus";
		
		/**
		 * The title. */		
		private var _notificationTitle:TextField;
		
		/**
		 * The down arrow. */		
		private var _arrowDown:Image;
		
		/**
		 * The theme selection input (hack for now, should be replaced by a pickerList) */		
		private var _themeSelectionInput:TextInput;
		
		/**
		 * Mail input if the user is not logged in. */		
		private var _mailInput:TextInput;
		
		/**
		 * The message input. */		
		private var _messageInput:TextInput;
		
		/**
		 * The send button. */		
		private var _sendButton:Button;
		
		/**
		 * The themes list displayed in a popup. */		
		private var _themesList:GroupedList;
		
		/**
		 * The popup content manager used to display the list of themes. */		
		private var _popUpContentManager:IPopUpContentManager;

		/**
		 * The data used when the close event is dispatched. */
		protected var _data:Object;
		
		public function CSNewThreadNotificationContent()
		{
			super();
			
			_data = {};
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			const layout:VerticalLayout = new VerticalLayout();
			layout.horizontalAlign = VerticalLayout.HORIZONTAL_ALIGN_CENTER;
			layout.verticalAlign = VerticalLayout.VERTICAL_ALIGN_MIDDLE;
			layout.gap = scaleAndRoundToDpi( GlobalConfig.isPhone ? 20:40 );
			this.layout = layout;
			
			_notificationTitle = new TextField(5, scaleAndRoundToDpi(40), _("Nouveau message"), Theme.FONT_SANSITA, scaleAndRoundToDpi(26), Theme.COLOR_ORANGE);
			_notificationTitle.autoScale = true;
			addChild(_notificationTitle);
			
			_themeSelectionInput = new TextInput();
			_themeSelectionInput.addEventListener(TouchEvent.TOUCH, onShowThemeList);
			_themeSelectionInput.prompt = _("Partie Solo");
			_themeSelectionInput.isEditable = false;
			addChild(_themeSelectionInput);
			
			_arrowDown = new Image( AbstractEntryPoint.assets.getTexture("arrow_down") );
			_themeSelectionInput.addChild(_arrowDown);
			
			if( !MemberManager.getInstance().isLoggedIn() )
			{
				_mailInput = new TextInput();
				_mailInput.prompt = _("Votre email...");
				_mailInput.addEventListener(FeathersEventType.FOCUS_IN, onFocusIn);
				_mailInput.addEventListener(FeathersEventType.FOCUS_OUT, onFocusOut);
				_mailInput.addEventListener(FeathersEventType.ENTER, onEnterKeyPressed);
				_mailInput.textEditorProperties.returnKeyLabel = ReturnKeyLabel.NEXT;
				_mailInput.textEditorProperties.softKeyboardType = SoftKeyboardType.EMAIL;
				addChild(_mailInput);
			}
			
			_messageInput = new TextInput();
			_messageInput.prompt = _("Saisissez ici votre question...");
			addChild(_messageInput);
			_messageInput.addEventListener(FeathersEventType.FOCUS_IN, onFocusIn);
			_messageInput.addEventListener(FeathersEventType.FOCUS_OUT, onFocusOut);
			_messageInput.textEditorProperties.returnKeyLabel = ReturnKeyLabel.DEFAULT;
			_messageInput.textEditorProperties.autoCorrect = true;
			_messageInput.addEventListener(FeathersEventType.ENTER, onEnterKeyPressed);
			_messageInput.textEditorProperties.multiline = true;
			
			_sendButton = new Button();
			_sendButton.addEventListener(Event.TRIGGERED, onCreateMessage);
			_sendButton.label = _("Envoyer");
			addChild(_sendButton);
			_sendButton.validate();
			_sendButton.width = _sendButton.width + scaleAndRoundToDpi(40);
			
			const centerStage:VerticalCenteredPopUpContentManager = new VerticalCenteredPopUpContentManager();
			centerStage.marginTop = centerStage.marginRight = centerStage.marginBottom =
				centerStage.marginLeft = scaleAndRoundToDpi( GlobalConfig.isPhone ? 24:200 );
			_popUpContentManager = centerStage;
			
			_themesList = new GroupedList();
			_themesList.verticalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			_themesList.horizontalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			_themesList.styleName = Theme.SUB_CATEGORY_GROUPED_LIST;
			_themesList.dataProvider = new HierarchicalCollection([ { header:"", children:Storage.getInstance().getProperty( (MemberManager.getInstance().getGiftsEnabled() ? StorageConfig.PROPERTY_CUSTOMER_SERVICE_THEMES : StorageConfig.PROPERTY_CUSTOMER_SERVICE_THEMES_WITHOUT_GIFTS) ) } ]);
			_themesList.typicalItem = "Theme name";
			_themesList.isSelectable = true;
			_themesList.setSelectedLocation(0,0);
			_themesList.addEventListener(Event.CHANGE, onThemeSelected);
		}
		
		override protected function draw():void
		{
			//_container.width = this.actualWidth - padSide * 2 - scaleAndRoundToDpi( GlobalConfig.isPhone ? 40:60 );
			//_container.x = (this.actualWidth - _container.width) * 0.5;
			
			if(isInvalid(INVALIDATION_FLAG_SIZE))
			{
				if( _mailInput )
					_mailInput.width = this.actualWidth;
				
				_notificationTitle.width = _themeSelectionInput.width = _messageInput.width = this.actualWidth;
				_messageInput.height = scaleAndRoundToDpi(GlobalConfig.isPhone ? 100 /* 2 lines */ : 250);
				
				_themeSelectionInput.validate();
				_arrowDown.x = _themeSelectionInput.width - _arrowDown.width - scaleAndRoundToDpi(20);
				_arrowDown.y = (_themeSelectionInput.height - _arrowDown.height) * 0.5;
				
				_themesList.width = this.actualWidth;
			}
			
			if(isInvalid(INVALIDATION_FLAG_NEEDS_RESIZE_FOCUS))
			{
				if(!_messageInput.hasFocus && (_mailInput && !_mailInput.hasFocus))
					NotificationPopupManager.centerCurrent();
				else
					NotificationPopupManager.moveCurrentToTop();
			}
			
			super.draw();
		}
		
//------------------------------------------------------------------------------------------------------------
//	Handlers
//------------------------------------------------------------------------------------------------------------
		
		/**
		 * When one of the TextInputs gets the focus, we need to move the popup to the top.
		 */
		private function onFocusIn(event:Event):void
		{
			NotificationPopupManager.moveCurrentToTop();
		}
		
		/**
		 * When one of the TextInputs looses the focus, we need to move the popup to the center.
		 */
		private function onFocusOut(event:Event):void
		{
			TweenMax.delayedCall(0.1, invalidate, [INVALIDATION_FLAG_NEEDS_RESIZE_FOCUS]);
		}
		
		/**
		 * When the user validates the form, we try to create a new thread.
		 */		
		private function onCreateMessage(event:Event = null):void
		{
			if( _messageInput.text == "" )
			{
				InfoManager.showTimed( _("Le message ne peut être vide."), InfoManager.DEFAULT_DISPLAY_TIME, InfoContent.ICON_CROSS );
				return;
			}
			
			if( !MemberManager.getInstance().isLoggedIn() )
			{
				if( _mailInput.text == "" || !Utilities.isValidMail(_mailInput.text) )
				{
					InfoManager.showTimed( _("Email invalide."), InfoManager.DEFAULT_DISPLAY_TIME, InfoContent.ICON_CROSS );
					return;
				}
			}
			
			InfoManager.show(_("Chargement..."));
			if( AirNetworkInfo.networkInfo.isConnected() )
			{
				if( GAnalytics.isSupported() )
					GAnalytics.analytics.defaultTracker.trackEvent("Aide", "Validation de la demande du Service Client", null, NaN, MemberManager.getInstance().getId());
				Remote.getInstance().createNewCustomerServiceThread( CSThemeData(_themesList.selectedItem).id, (_mailInput ? _mailInput.text:null), _messageInput.text, onThreadCreateSuccess, onThreadCreateFailure, onThreadCreateFailure, 2, AbstractEntryPoint.screenNavigator.activeScreenID);
			}
			else
			{
				if( MemberManager.getInstance().isLoggedIn() )
				{
					// storing push in only available for logged in members
					AbstractEntryPoint.pushManager.addElementToPush( new PushNewCSThread(PushType.CUSTOMER_SERVICE_NEW_THREAD, CSThemeData(_themesList.selectedItem).id, CSThemeData(_themesList.selectedItem).translationKey, _messageInput.text) );
					InfoManager.hide(_("Vous n'êtes pas connecté à Internet. Votre message a été stocké et sera envoyé lorsque vous serez connecté."), InfoContent.ICON_CHECK, 10, requestClose);
				}
				else
				{
					InfoManager.hide(_("Aucune connexion Internet."), InfoContent.ICON_CROSS, InfoManager.DEFAULT_DISPLAY_TIME);
				}
			}
		}
		
		/**
		 * The new thread was successfully created.
		 */		
		private function onThreadCreateSuccess(result:Object):void
		{
			switch(result.code)
			{
				case 0: // invalid data
				case 2: // Impossible d'inserer une ligne t (sujet)
				case 3: // impossible de recuperer l'id de la ligne t (sujet)
				case 4: // impossible d'inserer ligne d (msg)
				case 5: // impossible de recuperer l'id de la ligne d (msg)
				case 6: // impossible de mettre a jour l'id du dernier message de la discussion dans le sujet (id D dans T)
				case 7: // joueur non connecté qui a soit pas rempli son email soit son email est incorrect
				{
					InfoManager.hide(result.txt, InfoContent.ICON_CROSS, InfoManager.DEFAULT_DISPLAY_TIME);
					break;
				}
				case 1: // success
				{
					_data = true;
					InfoManager.hide(result.txt, InfoContent.ICON_CHECK, InfoManager.DEFAULT_DISPLAY_TIME, requestClose);
					break;
				}
					
				default:
				{
					onThreadCreateFailure();
					break;
				}
			}
		}
		
		/**
		 * An error occurred while creatting the new thread.
		 */		
		private function onThreadCreateFailure(error:Object = null):void
		{
			InfoManager.hide(_("Une erreur est survenue, veuillez réessayer."), InfoContent.ICON_CROSS, InfoManager.DEFAULT_DISPLAY_TIME);
		}
		
		/**
		 * When we need to show the themes list.
		 */		
		private function onShowThemeList(event:TouchEvent):void
		{
			var touch:Touch = event.getTouch(_themeSelectionInput);
			if( touch && touch.phase == TouchPhase.ENDED)
				_popUpContentManager.open(_themesList, this);
			touch = null;
		}
		
		/**
		 * A theme was selected.
		 */		
		private function onThemeSelected(event:Event):void
		{
			_popUpContentManager.close();
			_themeSelectionInput.prompt = String(_themesList.selectedItem);
		}
		
		/**
		 * The user touched the "Enter" / "Next" key, so we validate the form or simply go to
		 * the next input depending on the current input.
		 */		
		private function onEnterKeyPressed(event:Event):void
		{
			if( event.target == _mailInput )
				_messageInput.setFocus();
			else
				onCreateMessage();
		}

		/**
		 * Close the notification.
		 */
		public function requestClose():void
		{
			//dispatchEventWith(LudoEventType.CLOSE_NOTIFICATION, false, _data);
			close();
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
//------------------------------------------------------------------------------------------------------------
		
		override public function dispose():void
		{
			_notificationTitle.removeFromParent(true);
			_notificationTitle = null;
			
			_arrowDown.removeFromParent(true);
			_arrowDown = null;
			
			_themeSelectionInput.removeEventListener(TouchEvent.TOUCH, onShowThemeList);
			_themeSelectionInput.removeFromParent(true);
			_themeSelectionInput = null;
			
			if( _mailInput )
			{
				_mailInput.removeEventListener(FeathersEventType.FOCUS_IN, onFocusIn);
				_mailInput.removeEventListener(FeathersEventType.FOCUS_OUT, onFocusOut);
				_mailInput.removeEventListener(FeathersEventType.ENTER, onEnterKeyPressed);
				_mailInput.removeFromParent(true);
				_mailInput = null;
			}
			
			_messageInput.removeEventListener(FeathersEventType.FOCUS_IN, onFocusIn);
			_messageInput.removeEventListener(FeathersEventType.FOCUS_OUT, onFocusOut);
			_messageInput.removeEventListener(FeathersEventType.ENTER, onEnterKeyPressed);
			_messageInput.removeFromParent(true);
			_messageInput = null;
			
			_sendButton.removeEventListener(Event.TRIGGERED, onCreateMessage);
			_sendButton.removeFromParent(true);
			_sendButton = null;
			
			_themesList.removeEventListener(Event.CHANGE, onThemeSelected);
			_themesList.removeFromParent(true);
			_themesList = null;
			
			_popUpContentManager.close();
			_popUpContentManager.dispose();
			_popUpContentManager = null;
			
			super.dispose();
		}
	}
}