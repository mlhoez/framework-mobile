/*
Copyright © 2006-2015 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 28 oct. 2013
*/
package com.ludofactory.mobile.navigation.authentication
{
	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.controls.ArrowGroup;
	import com.ludofactory.mobile.core.manager.AuthenticationManager;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import feathers.controls.Label;
	import feathers.core.FeathersControl;
	import feathers.layout.HorizontalLayout;
	
	import starling.events.Event;
	
	public class NotLoggedInContainer extends FeathersControl
	{
		/**
		 * The message. */		
		private var _message:Label;
		
		/**
		 * The login group. */		
		private var _loginGroup:ArrowGroup;
		
		public function NotLoggedInContainer()
		{
			super();
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			_message = new Label();
			_message.touchable = false;
			_message.text = _("Vous devez être identifié\npour accéder à cet écran.");
			addChild(_message);
			_message.textRendererProperties.textFormat = Theme.notLoggedInMessageTextFormat;
			
			var hlayout:HorizontalLayout = new HorizontalLayout();
			hlayout.horizontalAlign = HorizontalLayout.HORIZONTAL_ALIGN_LEFT;
			hlayout.verticalAlign = HorizontalLayout.VERTICAL_ALIGN_MIDDLE;
			hlayout.gap = scaleAndRoundToDpi(10);
			
			_loginGroup = new ArrowGroup(_("S'identifier"));
			_loginGroup.addEventListener(Event.TRIGGERED, onAuthenticate);
			addChild(_loginGroup);
		}
		
		override protected function draw():void
		{
			super.draw();
			
			if( isInvalid(INVALIDATION_FLAG_SIZE) )
			{
				_message.width = actualWidth;
				_message.validate();
				_message.y = (actualHeight * 0.5) - _message.height - scaleAndRoundToDpi(10);
				
				_loginGroup.validate();
				_loginGroup.x = (actualWidth - _loginGroup.width) * 0.5;
				_loginGroup.y = actualHeight * 0.5 + scaleAndRoundToDpi(10);
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Handlers
		
		/**
		 * Start authentication process.
		 */		
		private function onAuthenticate(event:Event):void
		{
			AuthenticationManager.startAuthenticationProcess(AbstractEntryPoint.screenNavigator, AbstractEntryPoint.screenNavigator.activeScreenID);
		}
		
//------------------------------------------------------------------------------------------------------------
//	GET - SET
		
		public function set message(val:String):void
		{
			_message.text = val;
			invalidate( INVALIDATION_FLAG_SIZE );
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
		
		override public function dispose():void
		{
			_message.removeFromParent(true);
			_message = null;
			
			_loginGroup.removeEventListener(Event.TRIGGERED, onAuthenticate);
			_loginGroup.removeFromParent(true);
			_loginGroup = null;
			
			super.dispose();
		}
	}
}