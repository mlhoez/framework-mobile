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
	import com.ludofactory.mobile.core.AbstractGameInfo;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.theme.Theme;
	import com.ludofactory.mobile.navigation.FacebookManager;
	import com.ludofactory.mobile.navigation.FacebookManagerEventType;
	
	import starling.events.Event;
	import starling.text.TextField;
	import starling.text.TextFieldAutoSize;
	
	public class FacebookNotificationContent extends AbstractPopupContent
	{
		/**
		 * The title. */		
		private var _notificationTitle:TextField;
		
		/**
		 * The yes button. */		
		private var _facebookButton:FacebookButton;
		
		public function FacebookNotificationContent()
		{
			super();
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			data = false;
			
			_notificationTitle = new TextField(10, 100, _("Connexion Facebook"), Theme.FONT_SANSITA, scaleAndRoundToDpi(50), Theme.COLOR_DARK_GREY);
			_notificationTitle.autoScale = AbstractGameInfo.LANDSCAPE;
			_notificationTitle.autoSize = AbstractGameInfo.LANDSCAPE ? TextFieldAutoSize.NONE : TextFieldAutoSize.VERTICAL;
			addChild(_notificationTitle);
			
			_facebookButton = ButtonFactory.getFacebookButton(_("Connexion Facebook"), ButtonFactory.FACEBOOK_TYPE_NORMAL);
			_facebookButton.addEventListener(Event.TRIGGERED, onConnectFacebook);
			addChild(_facebookButton);
		}
		
		override protected function draw():void
		{
			_notificationTitle.width = this.actualWidth;
			if( AbstractGameInfo.LANDSCAPE )
			{
				_notificationTitle.y = scaleAndRoundToDpi(20);
				
				_facebookButton.x = roundUp((actualWidth - _facebookButton.width) * 0.5);
				_facebookButton.y = roundUp(_notificationTitle.y + _notificationTitle.height + scaleAndRoundToDpi(20));
				
				paddingTop = paddingBottom = scaleAndRoundToDpi(40);
			}
			else
			{
				_notificationTitle.y = scaleAndRoundToDpi(20);
				
				_facebookButton.x = roundUp((actualWidth - _facebookButton.width) * 0.5);
				
				paddingBottom = scaleAndRoundToDpi(10);
			}
			
			super.draw();
		}
		
//------------------------------------------------------------------------------------------------------------
//	Handlers
		
		/**
		 * Connect with Facebook
		 */
		private function onConnectFacebook(event:Event):void
		{
			// FIXME A terminer !
			//FacebookManager.sponsorId = textInput.text == "" ? "0" ; textInput.text;
			
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
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
		
		override public function dispose():void
		{
			FacebookManager.getInstance().removeEventListener(FacebookManagerEventType.AUTHENTICATED, onConnectedWithFacebook);
			
			_notificationTitle.removeFromParent(true);
			_notificationTitle = null;
			
			_facebookButton.removeEventListener(Event.TRIGGERED, onConnectFacebook);
			_facebookButton.removeFromParent(true);
			_facebookButton = null;
			
			super.dispose();
		}
	}
}