/*
Copyright © 2006-2014 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 27 sept. 2013
*/
package com.ludofactory.mobile.core.test.sponsor.info
{
	import com.ludofactory.common.utils.log;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.Localizer;
	import com.ludofactory.mobile.core.authentication.MemberManager;
	import com.ludofactory.mobile.core.notification.content.AbstractNotification;
	import com.ludofactory.mobile.core.storage.Storage;
	import com.ludofactory.mobile.core.storage.StorageConfig;
	import com.ludofactory.mobile.core.test.config.GlobalConfig;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import feathers.controls.Label;
	import feathers.controls.List;
	import feathers.controls.ScrollContainer;
	import feathers.controls.Scroller;
	import feathers.data.ListCollection;
	import feathers.layout.HorizontalLayout;
	import feathers.layout.VerticalLayout;
	
	public class SponsorNotification extends AbstractNotification
	{
		/**
		 * The title. */		
		private var _notificationTitle:Label;
		
		/**
		 * The bonus list. */		
		private var _bonusList:List;
		/**
		 * The bonus container. */		
		private var _bonusContainer:ScrollContainer;
		/**
		 * The bonus title. */		
		private var _bonusTitleLabel:Label;
		/**
		 * The bonus message. */		
		private var _bonusMessageLabel:Label;
		
		/**
		 * The info message if not logged in. */		
		private var _infoMessageLabel:Label;
		
		public function SponsorNotification()
		{
			super();
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			const layout:VerticalLayout = new VerticalLayout();
			layout.horizontalAlign = VerticalLayout.HORIZONTAL_ALIGN_CENTER;
			layout.verticalAlign = VerticalLayout.VERTICAL_ALIGN_MIDDLE;
			layout.gap = scaleAndRoundToDpi( GlobalConfig.isPhone ? 20:40 );
			_container.layout = layout;
			
			_notificationTitle = new Label();
			_notificationTitle.text = Localizer.getInstance().translate("SPONSOR_POPUP.TITLE");
			_container.addChild(_notificationTitle);
			_notificationTitle.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(38), Theme.COLOR_DARK_GREY, false, false, null, null, null, TextFormatAlign.CENTER);
			
			log("[SponsorNotification] Rank = " + MemberManager.getInstance().getRank() + "Type = " + Storage.getInstance().getProperty(StorageConfig.PROPERTY_SPONSOR_REWARD_TYPE));
			
			var dataProvider:Array;
			if( MemberManager.getInstance().isLoggedIn() )
			{
				dataProvider = [ new SponsorBonusData( { iconTextureName:"sponsor-bonus-icon-11", rank:"VIP_CATEGORY_11", bonus:(MemberManager.getInstance().getRank() >= 4 ? "SPONSOR_POPUP.BONUS_1_RANK_9":"SPONSOR_POPUP.BONUS_1") } ),
								 new SponsorBonusData( { iconTextureName:"sponsor-bonus-icon-10", rank:"VIP_CATEGORY_10", bonus:"SPONSOR_POPUP.BONUS_2" } ),
								 new SponsorBonusData( { iconTextureName:"sponsor-bonus-icon-4",  rank:"VIP_CATEGORY_4",  bonus:(Storage.getInstance().getProperty(StorageConfig.PROPERTY_SPONSOR_REWARD_TYPE) == 1 ? "SPONSOR_POPUP.BONUS_3_POINTS":"SPONSOR_POPUP.BONUS_3") } ),
								 new SponsorBonusData( { iconTextureName:"sponsor-bonus-icon-1",  rank:"VIP_CATEGORY_1",  bonus:(Storage.getInstance().getProperty(StorageConfig.PROPERTY_SPONSOR_REWARD_TYPE) == 1 ? "SPONSOR_POPUP.BONUS_4_POINTS":"SPONSOR_POPUP.BONUS_4") } ) ];
			}
			else
			{
				dataProvider = [ new SponsorBonusData( { iconTextureName:"sponsor-bonus-icon-11", rank:"VIP_CATEGORY_11", bonus:"SPONSOR_POPUP.BONUS_1_NOT_LOGGED_IN" } ),
								 new SponsorBonusData( { iconTextureName:"sponsor-bonus-icon-10", rank:"VIP_CATEGORY_10", bonus:"SPONSOR_POPUP.BONUS_2" } ),
								 new SponsorBonusData( { iconTextureName:"sponsor-bonus-icon-4",  rank:"VIP_CATEGORY_4",  bonus:(Storage.getInstance().getProperty(StorageConfig.PROPERTY_SPONSOR_REWARD_TYPE) == 1 ? "SPONSOR_POPUP.BONUS_3_POINTS":"SPONSOR_POPUP.BONUS_3") } ),
								 new SponsorBonusData( { iconTextureName:"sponsor-bonus-icon-1",  rank:"VIP_CATEGORY_1",  bonus:(Storage.getInstance().getProperty(StorageConfig.PROPERTY_SPONSOR_REWARD_TYPE) == 1 ? "SPONSOR_POPUP.BONUS_4_POINTS":"SPONSOR_POPUP.BONUS_4") } ) ];
			}
			
			var vlayout:VerticalLayout = new VerticalLayout();
			vlayout.gap = scaleAndRoundToDpi(5);
			
			_bonusList = new List();
			_bonusList.verticalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			_bonusList.horizontalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			_bonusList.layout = vlayout;
			_bonusList.itemRendererType = SponsorBonusItemRenderer;
			_bonusList.dataProvider = new ListCollection( dataProvider );
			_container.addChild( _bonusList );
			
			var hlayout:HorizontalLayout = new HorizontalLayout();
			hlayout.verticalAlign = HorizontalLayout.VERTICAL_ALIGN_MIDDLE;
			hlayout.horizontalAlign = HorizontalLayout.HORIZONTAL_ALIGN_CENTER;
			hlayout.padding = scaleAndRoundToDpi(5);
			_bonusContainer = new ScrollContainer();
			_bonusContainer.nameList.add( Theme.SCROLL_CONTAINER_WHITE );
			_bonusContainer.layout = hlayout;
			_container.addChild( _bonusContainer );
			
			_bonusTitleLabel = new Label();
			_bonusTitleLabel.text = Localizer.getInstance().translate("SPONSOR_POPUP.BONUS_POINTS_TITLE");
			_bonusContainer.addChild(_bonusTitleLabel);
			_bonusTitleLabel.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(44), Theme.COLOR_DARK_GREY, false, false, null, null, null, TextFormatAlign.CENTER);
			_bonusTitleLabel.textRendererProperties.wordWrap = false;
			
			_bonusMessageLabel = new Label();
			_bonusMessageLabel.text = Localizer.getInstance().translate("SPONSOR_POPUP.BONUS_POINTS_MESSAGE");
			_bonusContainer.addChild(_bonusMessageLabel);
			_bonusMessageLabel.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(28), Theme.COLOR_ORANGE, false, false, null, null, null, TextFormatAlign.RIGHT);
			
			if( !MemberManager.getInstance().isLoggedIn() )
			{
				_infoMessageLabel = new Label();
				_infoMessageLabel.text = Localizer.getInstance().translate("SPONSOR_POPUP.INFO");
				_container.addChild(_infoMessageLabel);
				_infoMessageLabel.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(24), Theme.COLOR_DARK_GREY);
			}
		}
		
		override protected function draw():void
		{
			_container.width = this.actualWidth - padSide * 2;
			_container.x = padSide;
			
			_notificationTitle.width = _bonusList.width = _bonusContainer.width = _container.width * 0.9;
			_bonusList.validate();
			
			_bonusTitleLabel.validate();
			_bonusContainer.validate();
			_bonusMessageLabel.width = _bonusContainer.width - _bonusTitleLabel.width - (_bonusContainer.padding * 6);
			
			if( _infoMessageLabel )
				_infoMessageLabel.width = _container.width * 0.9;
			
			super.draw();
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
//------------------------------------------------------------------------------------------------------------
		
		override public function dispose():void
		{
			_notificationTitle.removeFromParent(true);
			_notificationTitle = null;
			
			_bonusList.removeFromParent(true);
			_bonusList = null;
			
			_bonusTitleLabel.removeFromParent(true);
			_bonusTitleLabel = null;
			
			_bonusMessageLabel.removeFromParent(true);
			_bonusMessageLabel = null;
			
			_bonusContainer.removeFromParent(true);
			_bonusContainer = null;
			
			if( _infoMessageLabel )
			{
				_infoMessageLabel.removeFromParent(true);
				_infoMessageLabel = null;
			}
			
			super.dispose();
		}
	}
}