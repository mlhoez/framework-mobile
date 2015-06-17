/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 25 août 2013
*/
package com.ludofactory.mobile.navigation.cs.thread
{
	import com.freshplanet.nativeExtensions.AirNetworkInfo;
	import com.greensock.TweenMax;
	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.AbstractGameInfo;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.controls.AdvancedScreen;
	import com.ludofactory.mobile.core.controls.ImageLoaderCache;
	import com.ludofactory.mobile.core.controls.PullToRefreshList;
	import com.ludofactory.mobile.core.events.LudoEventType;
	import com.ludofactory.mobile.core.manager.InfoContent;
	import com.ludofactory.mobile.core.manager.InfoManager;
	import com.ludofactory.mobile.core.remoting.Remote;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.navigation.cs.CSState;
	import com.ludofactory.mobile.core.push.PushNewCSMessage;
	import com.ludofactory.mobile.core.push.PushType;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import flash.text.ReturnKeyLabel;
	
	import feathers.controls.Button;
	import feathers.controls.Scroller;
	import feathers.controls.TextInput;
	import feathers.data.ListCollection;
	import feathers.events.FeathersEventType;
	import feathers.layout.VerticalLayout;
	
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.MovieClip;
	import starling.display.Quad;
	import starling.display.QuadBatch;
	import starling.events.Event;
	import starling.utils.formatString;
	
	public class CSThreadScreen extends AdvancedScreen
	{
		/**
		 * The list. */		
		private var _list:PullToRefreshList;
		
		/**
		 * The textinput background. */		
		private var _inputBackground:QuadBatch;
		
		/**
		 * The message text input. */		
		private var _messageInput:TextInput;
		
		/**
		 * The send button icon */		
		private var _sendButtonIcon:Image;
		/**
		 * The send button. */		
		private var _sendButton:Button;
		
		/**
		 * The loader. */		
		private var _loader:MovieClip;
		
		/**
		 * The old scroll position, used to tween the list
		 * to the message that was just sent. */		
		private var _oldScrollPosition:Number;
		
		public function CSThreadScreen()
		{
			super();
			
			_fullScreen = false;
			_appClearBackground = false;
			_whiteBackground = true;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			_headerTitle = formatString(_("Problème sur {0}"), _(advancedOwner.screenData.thread.title));
			
			const layout:VerticalLayout = new VerticalLayout();
			layout.hasVariableItemDimensions = true;
			layout.manageVisibility = true;
			layout.useVirtualLayout = true;
			
			_list = new PullToRefreshList();
			_list.layout = layout;
			_list.verticalScrollPolicy = Scroller.SCROLL_POLICY_ON;
			_list.horizontalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			_list.scrollBarDisplayMode = Scroller.SCROLL_BAR_DISPLAY_MODE_FLOAT;
			_list.isSelectable = false;
			_list.addEventListener(LudoEventType.REFRESH_TOP , onRefreshThread);
			_list.itemRendererType = CSThreadItemRenderer;
			addChild(_list);
			
			if( advancedOwner.screenData.thread.state == CSState.PENDING )
			{
				// add textinput
				_inputBackground = new QuadBatch();
				var qd:Quad = new Quad(50, scaleAndRoundToDpi(110), 0x303030);
				_inputBackground.addQuad(qd);
				qd.color = 0x000000;
				qd.height = scaleAndRoundToDpi(30);
				qd.setVertexAlpha(0, 0.7);
				qd.setVertexAlpha(1, 0.7);
				qd.setVertexAlpha(2, 0);
				qd.setVertexColor(2, 0x303030);
				qd.setVertexAlpha(3, 0);
				qd.setVertexColor(3, 0x303030);
				_inputBackground.addQuad(qd);
				addChild(_inputBackground);
				
				_messageInput = new TextInput();
				_messageInput.prompt = _("Votre message...");
				_messageInput.textEditorProperties.returnKeyLabel = ReturnKeyLabel.GO;
				_messageInput.addEventListener(FeathersEventType.ENTER, onSendMessage);
				_messageInput.isEnabled = false;
				addChild(_messageInput);
				
				_sendButtonIcon = new Image( AbstractEntryPoint.assets.getTexture("cs-send-button-icon") );
				_sendButtonIcon.scaleX = _sendButtonIcon.scaleY = GlobalConfig.dpiScale + scaleAndRoundToDpi(AbstractGameInfo.LANDSCAPE ? 0.2 : 0);
				_sendButton = new Button();
				_sendButton.defaultIcon = _sendButtonIcon;
				_sendButton.styleName = Theme.BUTTON_EMPTY;
				_sendButton.visible = false;
				_sendButton.addEventListener(Event.TRIGGERED, onSendMessage);
				addChild(_sendButton);
				
				_loader = new MovieClip( AbstractEntryPoint.assets.getTextures("Loader") );
				_loader.scaleX = _loader.scaleY = GlobalConfig.dpiScale;
				Starling.juggler.add(_loader);
				addChild(_loader);
			}
			
			InfoManager.show( _("Chargement...") );
			TweenMax.delayedCall(0.5, Remote.getInstance().getThread, [advancedOwner.screenData.thread.id, onGetThreadSuccess, onGetThreadFailure, onGetThreadFailure, 2, advancedOwner.activeScreenID]);
		}
		
		override protected function draw():void
		{
			if( isInvalid(INVALIDATION_FLAG_SIZE) )
			{
				if( advancedOwner.screenData.thread.state == CSState.PENDING )
				{
					_inputBackground.width = this.actualWidth;
					_inputBackground.y = this.actualHeight - _inputBackground.height;
					
					_sendButton.validate();
					_sendButton.x = this.actualWidth - _sendButton.width - scaleAndRoundToDpi(AbstractGameInfo.LANDSCAPE ? 40 : 20);
					_sendButton.y = _inputBackground.y + (_inputBackground.height - _sendButton.height) * 0.5;
					
					_messageInput.validate();
					_messageInput.width = _sendButton.x - scaleAndRoundToDpi(AbstractGameInfo.LANDSCAPE ? 80 : 40);
					_messageInput.y = _inputBackground.y + (_inputBackground.height - _messageInput.height) * 0.5;
					_messageInput.x = scaleAndRoundToDpi(20);
					
					_loader.x = (_messageInput.x + _messageInput.width) + (this.actualWidth - (_messageInput.x + _messageInput.width) - _loader.width) * 0.5;
					_loader.y = _inputBackground.y + (_inputBackground.height - _loader.height) * 0.5;
				}
				
				_list.width = this.actualWidth;
				_list.height = advancedOwner.screenData.thread.state == CSState.PENDING ? _inputBackground.y : actualHeight;
			}
		}
		
		override public function onBack():void
		{
			super.onBack();
			ImageLoaderCache.clear();
		}
		
//------------------------------------------------------------------------------------------------------------
//	Get thread
//------------------------------------------------------------------------------------------------------------
		
		/**
		 * The thread could be retreived.
		 */		
		private function onGetThreadSuccess(result:Object):void
		{
			_list.onRefreshComplete();
			switch(result.code)
			{
				case 0: // error
				{
					_messageInput.isEnabled = false;
					_sendButton.visible = false;
					_loader.visible = false;
					
					InfoManager.hide(result.txt, InfoContent.ICON_CROSS, InfoManager.DEFAULT_DISPLAY_TIME);
					break;
				}
				case 1: // success
				{
					InfoManager.hide(result.txt, InfoContent.ICON_CHECK, 0.75);
					
					if( advancedOwner.screenData.thread.state == CSState.PENDING )
					{
						_loader.visible = false;
						_sendButton.visible = true;
						_messageInput.isEnabled = true;
					}
					
					_oldScrollPosition = _list.verticalScrollPosition;
					
					var i:int = 0;
					var len:int = (result.discussion as Array).length;
					var dp:Array = [];
					for( i; i < len; i++)
					{
						dp.push( new CSThreadData( result.discussion[i] ) );
					}
					_list.dataProvider = new ListCollection( dp );
					_list.validate();
					_list.scrollToPosition(0, _oldScrollPosition);
					TweenMax.delayedCall( 0, _list.scrollToPosition, [0, _list.maxVerticalScrollPosition, 0.75] );
					
					break;
				}
					
				default:
				{
					onGetThreadFailure();
					break;
				}
			}
		}
		
		/**
		 * An error occurred while retreiving the thread.
		 */		
		private function onGetThreadFailure(error:Object = null):void
		{
			_list.onRefreshComplete();
			InfoManager.hide(_("Une erreur est survenue, veuillez réessayer."), InfoContent.ICON_CROSS, InfoManager.DEFAULT_DISPLAY_TIME);
		}
		
		/**
		 * Refresh the thread.
		 */		
		private function onRefreshThread(event:Event = null):void
		{
			InfoManager.show( _("Chargement...") );
			Remote.getInstance().getThread( advancedOwner.screenData.thread.id, onGetThreadSuccess, onGetThreadFailure, onGetThreadFailure, 2, advancedOwner.activeScreenID );
		}
		
//------------------------------------------------------------------------------------------------------------
//	Send messages
//------------------------------------------------------------------------------------------------------------
		
		/**
		 * When the user wants to send a message.
		 */		
		private function onSendMessage(event:Event):void
		{
			if( _messageInput.text == "" )
			{
				InfoManager.showTimed( _("Votre message ne peut être vide."), InfoManager.DEFAULT_DISPLAY_TIME, InfoContent.ICON_CROSS );
				Starling.current.nativeStage.focus = null;
				return;
			}
			
			if( AirNetworkInfo.networkInfo.isConnected() )
			{
				_messageInput.isEnabled = false;
				_sendButton.visible = false;
				_loader.visible = true;
				Remote.getInstance().createNewMessage( advancedOwner.screenData.thread.id, _messageInput.text, onSendMessageSuccess, onSendMessageFailure, onSendMessageFailure, 2, advancedOwner.activeScreenID );
			}
			else
			{
				// FIXME créer un message temporaire avec un id +1 par rapport au dernier, de ce fait on peut le placer dans la conversation
				// Et au refresh du thread, ne pas recréer le dataProvider à chaque fois, mais plutôt checker les ids pour pouvoir placer
				// les éléments manquants à la fin, tout en pouvant ajouter les éléments temporaires au milieu
				// voir pour faire une fonction spéciale côté php comme pour le classement pour récupérer les éléments en fonction d'un id
				// (le dernier en l'occurrence la), comme ça on a même pas besoin de faire un loop, on peut directement ajouter les nouveaux
				// éléments à la suite puis scroller
				
				//log( "Last message id = " + CSThreadData(_list.dataProvider.getItemAt(_list.dataProvider.length -1)).messageId );
				
				AbstractEntryPoint.pushManager.addElementToPush( new PushNewCSMessage(PushType.CUSTOMER_SERVICE_NEW_MESSAGE, advancedOwner.screenData.thread.id, _messageInput.text) );
				_messageInput.text = "";
				createAlert(false);
				Starling.current.nativeStage.focus = null;
			}
		}
		
		/**
		 * The message have been successfully sent.
		 */		
		private function onSendMessageSuccess(result:Object):void
		{
			_messageInput.isEnabled = true;
			_sendButton.visible = true;
			_loader.visible = false;
			
			switch(result.code)
			{
				case 0: // invalid data
				case 2: // Erreur d'insertion du message en base
				{
					createAlert(false);
					break;
				}
					
				case 1: // success
				{
					createAlert(true);
					
					_messageInput.text = "";
					Remote.getInstance().getThread( advancedOwner.screenData.thread.id, onGetThreadSuccess, onGetThreadFailure, onGetThreadFailure, 2, advancedOwner.activeScreenID );
					break;
				}
					
				default:
				{
					break;
				}
			}
		}
		
		/**
		 * An error occurred while sending the message.
		 */		
		private function onSendMessageFailure(error:Object = null):void
		{
			_messageInput.isEnabled = true;
			_sendButton.visible = true;
			_loader.visible = false;
			
			createAlert(false);
		}
		
		private function createAlert(success:Boolean):void
		{
			var alert:CSThreadAlert = new CSThreadAlert( success ? _("Votre message a bien été envoyé. Nous vous répondrons sous 7 jours ouvrés.") : _("Aucune connexion Internet. Votre message a été stocké et sera envoyé lorsque vous serez connecté."), success);
			alert.width = this.actualWidth;
			addChild(alert);
			alert.validate();
			alert.y = -alert.height;
			TweenMax.to(alert, 0.5, { delay:0.5, y:0, yoyo:true, repeatDelay:4, repeat:1, onComplete:function():void{ alert.removeFromParent(true); alert = null; } });
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
//------------------------------------------------------------------------------------------------------------
		
		override public function dispose():void
		{
			if( _inputBackground )
			{
				_inputBackground.reset();
				_inputBackground.removeFromParent(true);
				_inputBackground = null;
			}
			
			if( _messageInput )
			{
				_messageInput.removeEventListener(FeathersEventType.ENTER, onSendMessage);
				_messageInput.removeFromParent(true);
				_messageInput = null;
			}
			
			if( _sendButtonIcon )
			{
				_sendButtonIcon.removeFromParent(true);
				_sendButtonIcon = null;
			}
			
			if( _sendButton )
			{
				_sendButton.removeEventListener(Event.TRIGGERED, onSendMessage);
				_sendButton.removeFromParent(true);
				_sendButton = null;
			}
			
			if( _loader )
			{
				Starling.juggler.remove(_loader);
				_loader.removeFromParent(true);
				_loader = null;
			}
			
			_list.removeEventListener(LudoEventType.REFRESH_TOP , onRefreshThread);
			_list.removeFromParent(true);
			_list = null;
			
			super.dispose();
		}
	}
}