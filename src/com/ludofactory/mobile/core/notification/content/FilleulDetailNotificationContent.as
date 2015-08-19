/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 9 oct. 2013
*/
package com.ludofactory.mobile.core.notification.content
{

	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.notification.AbstractPopupContent;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.navigation.sponsor.filleuls.*;
	import com.ludofactory.mobile.core.theme.Theme;

	import feathers.controls.Label;
	import feathers.controls.List;
	import feathers.controls.ScrollContainer;
	import feathers.controls.Scroller;
	import feathers.data.ListCollection;
	import feathers.layout.VerticalLayout;

	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	import starling.display.Quad;

	public class FilleulDetailNotificationContent extends AbstractPopupContent
	{
		/**
		 * The title. */		
		private var _notificationTitle:Label;
		
		/**
		 * The filleul data. */		
		private var _filleulData:FilleulData;
		
		private var _stateContainer:ScrollContainer;
		/**
		 * The state title. */		
		private var _stateTitle:Label;
		/**
		 *  The state message */		
		private var _stateMessage:Label;
		
		private var _stripe:Quad;
		
		private var _rewardContainer:ScrollContainer;
		
		private var _rewardTitle:Label;
		
		private var _headerContainer:ScrollContainer;
		private var _headerRewardTitle:Label;
		private var _headerDateLabel:Label;
		
		private var _list:List;
		
		
		
		public function FilleulDetailNotificationContent(filleulData:FilleulData)
		{
			super();
			_filleulData = filleulData;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			const layout:VerticalLayout = new VerticalLayout();
			layout.horizontalAlign = VerticalLayout.HORIZONTAL_ALIGN_CENTER;
			layout.verticalAlign = VerticalLayout.VERTICAL_ALIGN_MIDDLE;
			layout.gap = scaleAndRoundToDpi( GlobalConfig.isPhone ? 40:60 );
			this.layout = layout;
			
			_notificationTitle = new Label();
			_notificationTitle.text = _filleulData.filleulName + "\n" + _filleulData.filleulId;
			addChild(_notificationTitle);
			_notificationTitle.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(40), Theme.COLOR_DARK_GREY, false, false, null, null, null, TextFormatAlign.CENTER);
			
			const vlayout:VerticalLayout = new VerticalLayout();
			vlayout.gap = scaleAndRoundToDpi(10);
			
			_stateContainer = new ScrollContainer();
			_stateContainer.layout = vlayout;
			addChild(_stateContainer);
			
			_stateTitle = new Label();
			_stateTitle.text = _("Etat du parrainage :");
			_stateContainer.addChild( _stateTitle );
			_stateTitle.textRendererProperties.textFormat = new TextFormat(Theme.FONT_ARIAL, scaleAndRoundToDpi(28), Theme.COLOR_DARK_GREY, true);
			
			_stateMessage = new Label();
			_stateMessage.text = _filleulData.information;
			_stateContainer.addChild(_stateMessage);
			_stateMessage.textRendererProperties.textFormat = new TextFormat(Theme.FONT_ARIAL, scaleAndRoundToDpi(28), Theme.COLOR_WHITE, true);
			
			switch(_filleulData.type)
			{
				case 0:
				{
					TextFormat(_stateMessage.textRendererProperties.textFormat).color = 0xae1900;
					break;
				}
				case 1:
				{
					TextFormat(_stateMessage.textRendererProperties.textFormat).color = 0x43a01f;
					break;
				}
				case 2:
				{
					TextFormat(_stateMessage.textRendererProperties.textFormat).color = 0x00a7d1;
					break;
				}
			}
			
			/*_stripe = new Quad(5, scaleAndRoundToDpi(2), 0xbfbfbf);
			_container.addChild(_stripe);*/
			
			_rewardContainer = new ScrollContainer();
			_rewardContainer.layout = vlayout;
			addChild(_rewardContainer);
			
			_rewardTitle = new Label();
			_rewardTitle.text = _("Gains remportés grâce à lui :");
			_rewardContainer.addChild( _rewardTitle );
			_rewardTitle.textRendererProperties.textFormat = new TextFormat(Theme.FONT_ARIAL, scaleAndRoundToDpi(28), Theme.COLOR_DARK_GREY, true);
			
			_headerContainer = new ScrollContainer();
			_rewardContainer.addChild(_headerContainer);
			
			_headerRewardTitle = new Label();
			_headerRewardTitle.text = _("Lot");
			_headerContainer.addChild(_headerRewardTitle);
			_headerRewardTitle.textRendererProperties.textFormat = new TextFormat(Theme.FONT_ARIAL, scaleAndRoundToDpi(28), Theme.COLOR_LIGHT_GREY, true, false, null, null, null, TextFormatAlign.CENTER);
			
			_headerDateLabel = new Label();
			_headerDateLabel.text = _("Date du gain");
			_headerContainer.addChild(_headerDateLabel);
			_headerDateLabel.textRendererProperties.textFormat = new TextFormat(Theme.FONT_ARIAL, scaleAndRoundToDpi(28), Theme.COLOR_LIGHT_GREY, true, false, null, null, null, TextFormatAlign.CENTER);
			
			_list = new List();
			_list.itemRendererType = FilleulRewardItemRenderer;
			_list.verticalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			_list.dataProvider = new ListCollection( [ { reward:_filleulData.firstRewardName, date:_filleulData.firstRewardDate },
													   { reward:_filleulData.secondRewardName, date:_filleulData.secondRewardDate },
													   { reward:_filleulData.thirdRewardName, date:_filleulData.thirdRewardDate },
													   { reward:_filleulData.fourthRewardName, date:_filleulData.fourthRewardDate } ] );
			_rewardContainer.addChild(_list);
			
			
		}
		
		override protected function draw():void
		{
			_notificationTitle.width = _stateContainer.width = _stateTitle.width = _stateMessage.width = _list.width = _rewardContainer.width = _headerContainer.width = this.actualWidth * 0.9;
			_headerRewardTitle.width = _notificationTitle.width * 0.4;
			_headerDateLabel.x = _notificationTitle.width * 0.5;
			_headerDateLabel.width = _notificationTitle.width * 0.5;
			
			super.draw();
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
//------------------------------------------------------------------------------------------------------------
		
		override public function dispose():void
		{
			_notificationTitle.removeFromParent(true);
			_notificationTitle = null;
			
			_stateTitle.removeFromParent(true);
			_stateTitle = null;
			
			_stateMessage.removeFromParent(true);
			_stateMessage = null;
			
			super.dispose();
		}
	}
}