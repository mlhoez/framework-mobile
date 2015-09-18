/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 27 sept. 2013
*/
package com.ludofactory.mobile.core.notification.content
{

	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.common.utils.log;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.manager.MemberManager;
	import com.ludofactory.mobile.core.notification.content.AbstractPopupContent;
	import com.ludofactory.mobile.core.storage.Storage;
	import com.ludofactory.mobile.core.storage.StorageConfig;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.navigation.sponsor.info.*;
	import com.ludofactory.mobile.core.theme.Theme;

	import feathers.controls.Label;
	import feathers.controls.List;
	import feathers.controls.ScrollContainer;
	import feathers.controls.Scroller;
	import feathers.data.ListCollection;
	import feathers.layout.HorizontalLayout;
	import feathers.layout.VerticalLayout;

	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	public class SponsorNotificationContent extends AbstractPopupContent
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
		
		public function SponsorNotificationContent()
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
			this.layout = layout;
			
			_notificationTitle = new Label();
			_notificationTitle.text = _("Gagnez ces récompenses quand vos filleuls changent de rang.");
			addChild(_notificationTitle);
			_notificationTitle.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(38), Theme.COLOR_DARK_GREY, false, false, null, null, null, TextFormatAlign.CENTER);
			
			//log("[SponsorNotification] Rank = " + MemberManager.getInstance().getRank() + "Type = " + Storage.getInstance().getProperty(StorageConfig.PROPERTY_SPONSOR_REWARD_TYPE));
			
			var dataProvider:Array;
			if( MemberManager.getInstance().isLoggedIn() )
			{
				dataProvider = [ new SponsorBonusData( { iconTextureName:"sponsor-bonus-icon-11", rank:_("Matelot"), bonus:(MemberManager.getInstance().rank >= 4 ? _("400 points"):_("200 points*")) } ),
								 new SponsorBonusData( { iconTextureName:"sponsor-bonus-icon-10", rank:_("Boucanier"), bonus:_("2 crédits") } ),
								 new SponsorBonusData( { iconTextureName:"sponsor-bonus-icon-4",  rank:_("Pirate III"),  bonus:(Storage.getInstance().getProperty(StorageConfig.PROPERTY_SPONSOR_REWARD_TYPE) == 1 ? _("25 000 points"):_("10 €")) } ),
								 new SponsorBonusData( { iconTextureName:"sponsor-bonus-icon-1",  rank:_("Pirate III"),  bonus:(Storage.getInstance().getProperty(StorageConfig.PROPERTY_SPONSOR_REWARD_TYPE) == 1 ? _("75 000 points"):_("30 €")) } ) ];
			}
			else
			{
				dataProvider = [ new SponsorBonusData( { iconTextureName:"sponsor-bonus-icon-11", rank:_("Matelot"), bonus:_("Jusqu'à 400 points*") } ),
								 new SponsorBonusData( { iconTextureName:"sponsor-bonus-icon-10", rank:_("Boucanier"), bonus:_("2 crédits") } ),
								 new SponsorBonusData( { iconTextureName:"sponsor-bonus-icon-4",  rank:_("Pirate III"),  bonus:(Storage.getInstance().getProperty(StorageConfig.PROPERTY_SPONSOR_REWARD_TYPE) == 1 ? _("25 000 points"):_("10 €")) } ),
								 new SponsorBonusData( { iconTextureName:"sponsor-bonus-icon-1",  rank:_("Capitaine"),  bonus:(Storage.getInstance().getProperty(StorageConfig.PROPERTY_SPONSOR_REWARD_TYPE) == 1 ? _("75 000 points"):_("30 €")) } ) ];
			}
			
			var vlayout:VerticalLayout = new VerticalLayout();
			vlayout.gap = scaleAndRoundToDpi(5);
			
			_bonusList = new List();
			_bonusList.verticalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			_bonusList.horizontalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			_bonusList.layout = vlayout;
			_bonusList.itemRendererType = SponsorBonusItemRenderer;
			_bonusList.dataProvider = new ListCollection( dataProvider );
			addChild( _bonusList );
			
			var hlayout:HorizontalLayout = new HorizontalLayout();
			hlayout.verticalAlign = HorizontalLayout.VERTICAL_ALIGN_MIDDLE;
			hlayout.horizontalAlign = HorizontalLayout.HORIZONTAL_ALIGN_CENTER;
			hlayout.padding = scaleAndRoundToDpi(5);
			_bonusContainer = new ScrollContainer();
			_bonusContainer.styleName = Theme.SCROLL_CONTAINER_WHITE;
			_bonusContainer.layout = hlayout;
			addChild( _bonusContainer );
			
			_bonusTitleLabel = new Label();
			_bonusTitleLabel.text = _("BONUS !");
			_bonusContainer.addChild(_bonusTitleLabel);
			_bonusTitleLabel.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(44), Theme.COLOR_DARK_GREY, false, false, null, null, null, TextFormatAlign.CENTER);
			_bonusTitleLabel.textRendererProperties.wordWrap = false;
			
			_bonusMessageLabel = new Label();
			_bonusMessageLabel.text = _("Gagnez 5% des points\ngagnés par vos filleuls !");
			_bonusContainer.addChild(_bonusMessageLabel);
			_bonusMessageLabel.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(28), Theme.COLOR_ORANGE, false, false, null, null, null, TextFormatAlign.RIGHT);
			
			if( !MemberManager.getInstance().isLoggedIn() || MemberManager.getInstance().rank < 4 )
			{
				_infoMessageLabel = new Label();
				_infoMessageLabel.text = _("*400 Points offerts à chaque parrainage si votre rang est supérieur ou égal à Aventurier I sinon vous gagnez 200 Points.");
				addChild(_infoMessageLabel);
				_infoMessageLabel.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(24), Theme.COLOR_DARK_GREY);
			}
		}
		
		override protected function draw():void
		{
			_notificationTitle.width = _bonusList.width = _bonusContainer.width = this.actualWidth;
			_bonusList.validate();
			
			_bonusTitleLabel.validate();
			_bonusContainer.validate();
			_bonusMessageLabel.width = _bonusContainer.width - _bonusTitleLabel.width - (_bonusContainer.padding * 6);
			
			if( _infoMessageLabel )
				_infoMessageLabel.width = this.actualWidth;
			
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