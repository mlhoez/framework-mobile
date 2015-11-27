/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 17 Août 2013
*/
package com.ludofactory.mobile.navigation.game
{
	
	import com.ludofactory.common.gettext.aliases._n;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.events.MobileEventTypes;
	import com.ludofactory.mobile.core.manager.MemberManager;
	import com.ludofactory.mobile.core.model.ScreenIds;
	import com.ludofactory.mobile.core.notification.NotificationPopupManager;
	import com.ludofactory.mobile.core.notification.content.MarketingRegisterNotificationContent;
	import com.ludofactory.mobile.core.storage.Storage;
	import com.ludofactory.mobile.core.storage.StorageConfig;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import starling.events.Event;
	import starling.utils.formatString;
	
	public class StakeButtonPoint extends StakeButton
	{
		public function StakeButtonPoint()
		{
			super();
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			onUpdateData();
			MemberManager.getInstance().addEventListener(MobileEventTypes.MEMBER_UPDATED, onUpdateData);
		}
		
		override protected function draw():void
		{
			super.draw();
		}
		
		private function onUpdateData(event:Event = null):void
		{
			_isEnabled = (MemberManager.getInstance().points >= Storage.getInstance().getProperty(StorageConfig.PROPERTY_NUM_POINTS_IN_TOURNAMENT_MODE));
			
			_label.text = formatString( _n("{0} Points", "{0} Points", Storage.getInstance().getProperty(StorageConfig.PROPERTY_NUM_POINTS_IN_TOURNAMENT_MODE)),
				Storage.getInstance().getProperty(StorageConfig.PROPERTY_NUM_POINTS_IN_TOURNAMENT_MODE));
			
			_icon.texture = AbstractEntryPoint.assets.getTexture( (_isEnabled || !MemberManager.getInstance().isLoggedIn()) ? "GameTypeSelectionPointsIcon" : "GameTypeSelectionPointsIconDisabled" );
			_backgroundSkin.textures = (_isEnabled || !MemberManager.getInstance().isLoggedIn()) ? Theme.buttonBlueSkinTextures : Theme.buttonDisabledSkinTextures;
			
			_label.color = _isEnabled ? 0x002432 : 0x2d2d2d;
		}
		
		override protected function triggerButton():void
		{
			if( _isEnabled )
			{
				dispatchEventWith(Event.TRIGGERED);
			}
			else
			{
				if(!MemberManager.getInstance().isLoggedIn())
					NotificationPopupManager.addNotification( new MarketingRegisterNotificationContent(ScreenIds.GAME_TYPE_SELECTION_SCREEN) );
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
//------------------------------------------------------------------------------------------------------------
		
		override public function dispose():void
		{
			MemberManager.getInstance().removeEventListener(MobileEventTypes.MEMBER_UPDATED, onUpdateData);
			
			
			
			super.dispose();
		}
		
	}
}