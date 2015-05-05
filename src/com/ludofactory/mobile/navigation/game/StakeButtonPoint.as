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
	import com.ludofactory.mobile.core.events.LudoEventType;
	import com.ludofactory.mobile.core.manager.MemberManager;
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
			MemberManager.getInstance().addEventListener(LudoEventType.UPDATE_SUMMARY, onUpdateData);
		}
		
		override protected function draw():void
		{
			super.draw();
			
		}
		
		private function onUpdateData(event:Event = null):void
		{
			_isEnabled = MemberManager.getInstance().isLoggedIn() ? (MemberManager.getInstance().getPoints() >= Storage.getInstance().getProperty(StorageConfig.PROPERTY_NUM_POINTS_IN_TOURNAMENT_MODE)) : false;
			
			_label.text = formatString( _n("Utiliser {0} Points", "{0} Points", Storage.getInstance().getProperty(StorageConfig.PROPERTY_NUM_POINTS_IN_TOURNAMENT_MODE)),
				Storage.getInstance().getProperty(StorageConfig.PROPERTY_NUM_POINTS_IN_TOURNAMENT_MODE));
			
			_icon.texture = AbstractEntryPoint.assets.getTexture( _isEnabled ? "GameTypeSelectionPointsIcon" : "GameTypeSelectionPointsIconDisabled" );
			_backgroundSkin.textures = _isEnabled ? Theme.buttonBlueSkinTextures : Theme.buttonDisabledSkinTextures;
			
			_label.color = _isEnabled ? 0x002432 : 0x2d2d2d;
		}
		
		override protected function triggerButton():void
		{
			if( _isEnabled )
				dispatchEventWith(Event.TRIGGERED);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
//------------------------------------------------------------------------------------------------------------
		
		override public function dispose():void
		{
			MemberManager.getInstance().removeEventListener(LudoEventType.UPDATE_SUMMARY, onUpdateData);
			
			
			
			super.dispose();
		}
		
	}
}