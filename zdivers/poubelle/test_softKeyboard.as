/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 25 août 2013
*/
package com.ludofactory.mobile.features.customerservice.thread
{
	import com.freshplanet.nativeExtensions.AirNetworkInfo;
	import com.greensock.TweenMax;
	import com.ludofactory.mobile.core.Localizer;
	import com.ludofactory.mobile.core.controls.AdvancedScreen;
	import com.ludofactory.mobile.core.controls.RefreshableList;
	import com.ludofactory.mobile.core.events.MobileEventTypes;
	import com.ludofactory.mobile.core.manager.AlertManager;
	import com.ludofactory.mobile.utils.log;
	
	import flash.events.SoftKeyboardEvent;
	import flash.geom.Point;
	import flash.text.ReturnKeyLabel;
	
	import app.AppEntryPoint;
	import app.MetalWorksMobileTheme;
	import app.config.Config;
	import app.remoting.Remote;
	import app.screens.ProgressPopup;
	
	import feathers.controls.Button;
	import feathers.controls.Scroller;
	import feathers.controls.TextInput;
	import feathers.data.ListCollection;
	import feathers.events.FeathersEventType;
	import feathers.layout.VerticalLayout;
	
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.QuadBatch;
	import starling.events.Event;
	import starling.events.TouchEvent;
	
	public class CSThreadScreen extends AdvancedScreen
	{
		/**
		 * The list. */		
		private var _list:RefreshableList;
		
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
		
		private var _oldScrollPosition:Number;
		
		public function CSThreadScreen()
		{
			super();
			
			_fullScreen = false;
			_appBackground = false;
			_tiledBackground = true;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			AbstractEntryPoint.showBackButton( onBack );
			//AbstractEntryPoint.setHeaderTitle("Super titre du la conversation en cours");
			
			const layout:VerticalLayout = new VerticalLayout();
			layout.hasVariableItemDimensions = true;
			layout.manageVisibility = true;
			layout.useVirtualLayout = true;
			
			_list = new RefreshableList();
			_list.layout = layout;
			_list.verticalScrollPolicy = Scroller.SCROLL_POLICY_ON;
			_list.horizontalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			_list.scrollerProperties.scrollBarDisplayMode = Scroller.SCROLL_BAR_DISPLAY_MODE_FLOAT;
			_list.isSelectable = false;
			_list.addEventListener(MobileEventTypes.REFRESH_TOP , onRefreshThread);
			_list.itemRendererType = CSThreadItemRenderer;
			addChild(_list);
			
			if( advancedOwner.screenData.thread.state == CSThreadData.STATE_PENDING )
			{
				// add textinput
				_inputBackground = new QuadBatch();
				var qd:Quad = new Quad(50, 110 * Config.dpiScale, 0x303030);
				_inputBackground.addQuad(qd);
				qd.color = 0x000000;
				qd.height = 30 * Config.dpiScale;
				qd.setVertexAlpha(0, 0.7);
				qd.setVertexAlpha(1, 0.7);
				qd.setVertexAlpha(2, 0);
				qd.setVertexColor(2, 0x303030);
				qd.setVertexAlpha(3, 0);
				qd.setVertexColor(3, 0x303030);
				_inputBackground.addQuad(qd);
				addChild(_inputBackground);
				
				_messageInput = new TextInput();
				_messageInput.prompt = Localizer.getInstance().translate("THREAD.MESSAGE_INPUT_PROMPT");
				_messageInput.textEditorProperties.returnKeyLabel = ReturnKeyLabel.DONE;
				_messageInput.addEventListener(FeathersEventType.ENTER, onSendMessage);
				addChild(_messageInput);
				
				_sendButtonIcon = new Image( AbstractEntryPoint.assets.getTexture("SendButtonIcon") );
				_sendButtonIcon.scaleX = _sendButtonIcon.scaleY = Config.dpiScale;
				_sendButton = new Button();
				_sendButton.defaultIcon = _sendButtonIcon;
				_sendButton.nameList.add( MetalWorksMobileTheme.BUTTON_EMPTY );
				_sendButton.addEventListener(Event.TRIGGERED, onSendMessage);
				addChild(_sendButton);
			}
			
			AlertManager.show( Localizer.getInstance().translate("COMMON.LOADING") );
			TweenMax.delayedCall(0.5, Remote.getInstance().getThread, [advancedOwner.screenData.thread.id, onGetThreadSuccess, 10, onGetThreadFailure, onGetThreadFailure]);
		}
		
		private function onTest(event:Event):void
		{
			event.stopImmediatePropagation();
			log(event);
			log("");
			log( Starling.current.nativeStage.softKeyboardRect );
			
			var qdY:Quad = new Quad(50, 50, 0xff0000);
			addChild(qdY);
			
			var pt:Point = globalToLocal(new Point(0, Starling.current.nativeStage.softKeyboardRect.y));
			qdY.y = pt.y;
		}
		
		override protected function draw():void
		{
			super.draw();
			
			if( advancedOwner.screenData.thread.state == CSThreadData.STATE_PENDING )
			{
				_inputBackground.width = this.actualWidth;
				_inputBackground.y = this.actualHeight - _inputBackground.height;
				
				_sendButton.validate();
				_sendButton.x = this.actualWidth - _sendButton.width - (10 * Config.dpiScale);
				_sendButton.y = _inputBackground.y + (_inputBackground.height - _sendButton.height) * 0.5;
				
				_messageInput.validate();
				_messageInput.textEditor.addEventListener(SoftKeyboardEvent.SOFT_KEYBOARD_ACTIVATE, onTest);
				_messageInput.width = _sendButton.x - (20 * Config.dpiScale);
				_messageInput.y = _inputBackground.y + (_inputBackground.height - _messageInput.height) * 0.5;
				_messageInput.x = 10 * Config.dpiScale;
			}
			
			_list.width = this.actualWidth;
			_list.height = _inputBackground.y;
		}
		
		override protected function onBack():void
		{
			this.advancedOwner.screenData.thread = null;
			this.advancedOwner.showScreen( AdvancedScreen.CUSTOMER_SERVICE_HOME_SCREEN );
		}
		
//------------------------------------------------------------------------------------------------------------
//	Handlers
//------------------------------------------------------------------------------------------------------------
		
		/**
		 * The thread could be retreived.
		 */		
		private function onGetThreadSuccess(result:Object):void
		{
			_list.topRefreshDone();
			switch(result.code)
			{
				case 0: // error
				{
					AlertManager.hide(result.txt, ProgressPopup.SUCCESS_ICON_CROSS, AlertManager.DEFAULT_ALERT_TIME);
					break;
				}
				case 1: // success
				{
					AlertManager.hide("", ProgressPopup.SUCCESS_ICON_NOTHING, 0);
					
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
			_list.topRefreshDone();
			AlertManager.hide(Localizer.getInstance().translate("COMMON.QUERY_FAILURE"), ProgressPopup.SUCCESS_ICON_CROSS, AlertManager.DEFAULT_ALERT_TIME);
		}
		
		/**
		 * Refresh the thread.
		 */		
		private function onRefreshThread(event:Event = null):void
		{
			AlertManager.show( Localizer.getInstance().translate("COMMON.LOADING") );
			Remote.getInstance().getThread( advancedOwner.screenData.thread.id, onGetThreadSuccess, 10, onGetThreadFailure, onGetThreadFailure );
		}
		
		/**
		 * When the user wants to send a message.
		 */		
		private function onSendMessage(event:Event):void
		{
			if( _messageInput.text == "" )
			{
				AlertManager.showTimed( Localizer.getInstance().translate("THREAD.INVALID_MESSAGE"), AlertManager.DEFAULT_ALERT_TIME, true, ProgressPopup.SUCCESS_ICON_CROSS );
				return;
			}
			
			if( AirNetworkInfo.networkInfo.isConnected() )
			{
				AlertManager.show( Localizer.getInstance().translate("COMMON.LOADING") );
				_messageInput.isEnabled = false;
				Remote.getInstance().createNewMessage( advancedOwner.screenData.thread.id, _messageInput.text, onSendMessageSuccess, 10, onSendMessageFailure, onSendMessageFailure );
			}
			else
			{
				AlertManager.showTimed(Localizer.getInstance().translate("COMMON.NOT_CONNECTED"), AlertManager.DEFAULT_ALERT_TIME, true, ProgressPopup.SUCCESS_ICON_CROSS);
			}
		}
		
		/**
		 * The message have been successfully sent.
		 */		
		private function onSendMessageSuccess(result:Object):void
		{
			_messageInput.isEnabled = true;
			switch(result.code)
			{
				case 0: // invalid data
				case 2: // Erreur d'insertion du message en base
				{
					AlertManager.hide(result.txt, ProgressPopup.SUCCESS_ICON_CROSS, AlertManager.DEFAULT_ALERT_TIME);
					break;
				}
					
				case 1: // success
				{
					AlertManager.hide("", ProgressPopup.SUCCESS_ICON_NOTHING, 0);
					_messageInput.text = "";
					Remote.getInstance().getThread( advancedOwner.screenData.thread.id, onGetThreadSuccess, 10, onGetThreadFailure, onGetThreadFailure );
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
			AlertManager.hide(Localizer.getInstance().translate("COMMON.QUERY_FAILURE"), ProgressPopup.SUCCESS_ICON_CROSS, AlertManager.DEFAULT_ALERT_TIME);
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
			
			_list.removeEventListener(MobileEventTypes.REFRESH_TOP , onRefreshThread);
			_list.removeFromParent(true);
			_list = null;
			
			super.dispose();
		}
	}
}