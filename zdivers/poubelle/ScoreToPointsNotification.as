/*
LudoFactory
Framework mobile
Author  : Maxime Lhoez
Created : 19 Août 2013
*/
package com.ludofactory.mobile.core.notification.content
{
	import com.ludofactory.mobile.core.Localizer;
	import com.ludofactory.mobile.core.scoring.ScoreToPointsItemRenderer;
	import com.ludofactory.mobile.core.storage.Storage;
	import com.ludofactory.mobile.core.storage.StorageConfig;
	import com.ludofactory.mobile.core.theme.Theme;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.common.utils.scaleToDpi;
	
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import feathers.controls.Label;
	import feathers.controls.List;
	import feathers.controls.Scroller;
	import feathers.data.ListCollection;
	import feathers.layout.VerticalLayout;
	
	import starling.display.Quad;
	import starling.display.Sprite;
	
	/**
	 * Score to points notification.
	 */	
	public class ScoreToPointsNotification extends AbstractNotification
	{
		/**
		 * The title */		
		private var _notificationTitle:Label;
		
		/**
		 * The title container */		
		private var _titleContainer:Sprite;
		/**
		 * The title background (grey rectangle) */		
		private var _titleBackground:Quad;
		/**
		 * The title */		
		private var _title:Label;
		
		/**
		 * The list header */		
		private var _listHeader:Sprite;
		/**
		 * The score list title */		
		private var _scoreColumnTitle:Label;
		/**
		 * The points with credits list title */		
		private var _pointsWithCreditsColumnTitle:Label;
		/**
		 * The points with free list title */		
		private var _pointsWithFreeColumnTitle:Label;
		/**
		 * List */		
		private var _list:List;
		
		public function ScoreToPointsNotification()
		{
			super();
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			const layout:VerticalLayout = new VerticalLayout();
			layout.horizontalAlign = VerticalLayout.HORIZONTAL_ALIGN_CENTER;
			layout.verticalAlign = VerticalLayout.VERTICAL_ALIGN_MIDDLE;
			layout.gap = scaleToDpi(20);
			_container.layout = layout;
			
			_notificationTitle = new Label();
			_notificationTitle.text = Localizer.getInstance().translate("SCORE_TO_POINTS_NOTIFICATION.TITLE");
			_container.addChild(_notificationTitle);
			_notificationTitle.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA_ONE, scaleAndRoundToDpi(40), Theme.COLOR_DARK_GREY, null, null, null, null, null, TextFormatAlign.CENTER);
			
			_titleContainer = new Sprite();
			_container.addChild(_titleContainer);
			
			_titleBackground = new Quad(5, 5, 0xf3f3f3);
			_titleContainer.addChild(_titleBackground);
			
			_title = new Label();
			_title.nameList.add( Theme.LABEL_BLACK_CENTER );
			_title.text = Localizer.getInstance().translate("SCORE_TO_POINTS.TITLE");
			_titleContainer.addChild( _title );
			_title.textRendererProperties.textFormat = new TextFormat(Theme.FONT_ARIAL_ITALIC, scaleAndRoundToDpi(25), Theme.COLOR_LIGHT_GREY, null, null, null, null, null, TextFormatAlign.CENTER);
			
			_listHeader = new Sprite();
			_container.addChild( _listHeader );
			
			_scoreColumnTitle = new Label();
			_scoreColumnTitle.nameList.add( Theme.LABEL_BLACK_CENTER );
			_scoreColumnTitle.text = Localizer.getInstance().translate("SCORE_TO_POINTS.SCORE");
			_listHeader.addChild(_scoreColumnTitle);
			_scoreColumnTitle.textRendererProperties.textFormat = new TextFormat(Theme.FONT_ARIAL_BOLD_ITALIC, scaleAndRoundToDpi(25), Theme.COLOR_LIGHT_GREY, null, null, null, null, null, TextFormatAlign.CENTER);
			
			_pointsWithCreditsColumnTitle = new Label();
			_pointsWithCreditsColumnTitle.nameList.add( Theme.LABEL_BLACK_CENTER );
			_pointsWithCreditsColumnTitle.text = Localizer.getInstance().translate("SCORE_TO_POINTS.POINTS_WITH_CREDITS");
			_listHeader.addChild(_pointsWithCreditsColumnTitle);
			_pointsWithCreditsColumnTitle.textRendererProperties.textFormat = new TextFormat(Theme.FONT_ARIAL_BOLD_ITALIC, scaleAndRoundToDpi(25), Theme.COLOR_ORANGE, null, null, null, null, null, TextFormatAlign.CENTER);
			
			_pointsWithFreeColumnTitle = new Label();
			_pointsWithFreeColumnTitle.nameList.add( Theme.LABEL_BLACK_CENTER );
			_pointsWithFreeColumnTitle.text = Localizer.getInstance().translate("SCORE_TO_POINTS.POINTS_WITH_FREE");
			_listHeader.addChild(_pointsWithFreeColumnTitle);
			_pointsWithFreeColumnTitle.textRendererProperties.textFormat = new TextFormat(Theme.FONT_ARIAL_BOLD_ITALIC, scaleAndRoundToDpi(25), Theme.COLOR_ORANGE, null, null, null, null, null, TextFormatAlign.CENTER);
			
			_list = new List();
			_list.scrollerProperties.horizontalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			_list.scrollerProperties.verticalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			_list.isSelectable = false;
			_list.itemRendererType = ScoreToPointsItemRenderer;
			_list.dataProvider = new ListCollection( Storage.getInstance().getProperty(StorageConfig.PROPERTY_POINTS_TABLE) );
			_container.addChild(_list);
		}
		
		override protected function draw():void
		{
			_container.width = _notificationTitle.width = _list.width = this.actualWidth - padSide * 2;
			_container.x = padSide;
			
			_title.width = _container.width * 0.9;
			_title.validate();
			_titleBackground.width = _container.width * 0.95;
			_titleBackground.height = _title.height + scaleToDpi(20);
			
			_title.y = (_titleBackground.height - _title.height) * 0.5;
			_title.x = (_titleBackground.width - _title.width) * 0.5;
			
			const maxItemWidth:Number = _container.width / 3;
			_scoreColumnTitle.width = _pointsWithCreditsColumnTitle.width = _pointsWithFreeColumnTitle.width = maxItemWidth;
			_scoreColumnTitle.validate();
			_pointsWithCreditsColumnTitle.validate();
			_pointsWithFreeColumnTitle.validate();
			_pointsWithCreditsColumnTitle.x = maxItemWidth + padSide;
			_pointsWithFreeColumnTitle.x = maxItemWidth * 2 + padSide;
			
			super.draw();
		}
		
		override public function dispose():void
		{
			_notificationTitle.removeFromParent(true);
			_notificationTitle = null;
			
			_title.removeFromParent(true);
			_title = null;
			
			_titleBackground.removeFromParent(true);
			_titleBackground = null;
			
			_titleContainer.removeFromParent(true);
			_titleContainer = null;
			
			_scoreColumnTitle.removeFromParent(true);
			_scoreColumnTitle = null;
			
			_pointsWithFreeColumnTitle.removeFromParent(true);
			_pointsWithFreeColumnTitle = null;
			
			_pointsWithCreditsColumnTitle.removeFromParent(true);
			_pointsWithCreditsColumnTitle = null;
			
			_listHeader.removeFromParent(true);
			_listHeader = null;
			
			_list.removeFromParent(true);
			_list = null;
			
			super.dispose();
		}
	}
}