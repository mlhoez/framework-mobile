/*
LudoFactory
Framework mobile
Author  : Maxime Lhoez
Created : 22 nov. 2013
*/
package com.ludofactory.mobile
{
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.application.config.GlobalConfig;
	import com.ludofactory.mobile.core.manager.AlertManager;
	import com.ludofactory.mobile.core.membership.MemberManager;
	import com.ludofactory.mobile.core.storage.Storage;
	import com.ludofactory.mobile.core.theme.Theme;
	import com.milkmangames.nativeextensions.GoViral;
	
	import flash.data.EncryptedLocalStore;
	import flash.desktop.NativeApplication;
	import flash.text.TextFormat;
	
	import feathers.controls.Button;
	import feathers.controls.ScrollText;
	import feathers.core.FeathersControl;
	
	import starling.display.Quad;
	import starling.events.Event;
	
	public class DebugContainer extends FeathersControl
	{
		/**
		 * The background. */		
		private var _background:Quad;
		
		/**
		 * The debug console. */		
		private var _console:ScrollText;
		
		/**
		 * . */		
		private var _sendByMailButton:Button;
		/**
		 * The reset button. */		
		private var _resetButton:Button;
		
		public function DebugContainer()
		{ 
			super();
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			_background = new Quad(5, 5);
			_background.touchable = false;
			addChild(_background);
			
			_console = new ScrollText();
			addChild(_console);
			
			_resetButton = new Button();
			_resetButton.nameList.add( Theme.BUTTON_EMPTY );
			_resetButton.label = "Effacer les données";
			_resetButton.addEventListener(Event.TRIGGERED, onReset);
			addChild(_resetButton);
			_resetButton.defaultLabelProperties.textFormat = new TextFormat(Theme.FONT_ARIAL, scaleAndRoundToDpi(20), 0x000000);
			
			_sendByMailButton = new Button();
			_sendByMailButton.nameList.add( Theme.BUTTON_EMPTY );
			_sendByMailButton.label = "Envoyer par mail";
			_sendByMailButton.addEventListener(Event.TRIGGERED, onSendLogsByMail);
			addChild(_sendByMailButton);
			_sendByMailButton.defaultLabelProperties.textFormat = new TextFormat(Theme.FONT_ARIAL, scaleAndRoundToDpi(20), 0x000000);
			
			_sendByMailButton.minHeight = _sendByMailButton.height = _resetButton.minHeight = _resetButton.height = scaleAndRoundToDpi(50);
		}
		
		override protected function draw():void
		{
			super.draw();
			
			_background.width = this.actualWidth;
			_background.height = this.actualHeight;
			
			_console.width = actualWidth;
			_console.height = actualHeight * 0.5;
			
			_resetButton.width = actualWidth * 0.8;
			_resetButton.x = (actualWidth - _resetButton.width) * 0.5;
			_resetButton.y = actualHeight - _resetButton.height;
			
			_sendByMailButton.width = actualWidth * 0.8;
			_sendByMailButton.x = (actualWidth - _resetButton.width) * 0.5;
			_sendByMailButton.y = _resetButton.y - _sendByMailButton.height - scaleAndRoundToDpi(20);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Handlers
//------------------------------------------------------------------------------------------------------------
		
		override public function set visible(value:Boolean):void
		{
			super.visible = value;
			if( value )
				addChild(_console);
			else
				_console.removeFromParent();
		}
		
		public function addLog(log:String):void
		{
			_console.text = log + "\n" + _console.text;
		}
		
		private function onSendLogsByMail(event:Event):void
		{
			if( GoViral.isSupported() && GoViral.goViral.isEmailAvailable() )
			{
				var date:Date = new Date();
				GoViral.goViral.showEmailComposer("Bug sur Pyramid " + date.day + "-" + date.month + "-" + date.fullYear, "maxime.lhoez@ludokado.com,pierre.terrier@ludofactory.com", JSON.stringify(GlobalConfig.userHardwareData) + "\n\n" + JSON.stringify(MemberManager.getInstance().member) + "\n\n" + _console.text, false);
			}
		}
		
		private function onReset(event:Event):void
		{
			EncryptedLocalStore.reset();
			Storage.getInstance().clearStorage();
			
			if( GlobalConfig.ios )
			{
				AlertManager.show("Redémarrer l'application pour éviter tout bug.");
			}
			else
			{
				NativeApplication.nativeApplication.exit();
			}
		}
	}
}