/*
Copyright © 2006-2015 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 19 Août 2013
*/
package com.ludofactory.mobile.core.notification.content
{
	import com.ludofactory.mobile.core.Localizer;
	import com.ludofactory.mobile.core.scoring.ScoreToPointsItemRenderer;
	import com.ludofactory.mobile.core.scoring.ScoreToStarsItemRenderer;
	import com.ludofactory.mobile.core.storage.Storage;
	import com.ludofactory.mobile.core.storage.StorageConfig;
	
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import com.ludofactory.mobile.core.theme.Theme;
	import com.ludofactory.mobile.application.config.GlobalConfig;
	
	import feathers.controls.Label;
	import feathers.controls.List;
	import feathers.controls.Scroller;
	import feathers.data.ListCollection;
	import feathers.layout.VerticalLayout;
	
	import starling.display.Quad;
	import starling.display.Sprite;
	
	/**
	 * Score to stars notification.
	 */	
	public class ScoreToStarsNotification extends AbstractNotification
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
		private var _starsColumnTitle:Label;
		/**
		 * List */		
		private var _list:List;
		
		public function ScoreToStarsNotification()
		{
			super();
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			const layout:VerticalLayout = new VerticalLayout();
			layout.horizontalAlign = VerticalLayout.HORIZONTAL_ALIGN_CENTER;
			layout.verticalAlign = VerticalLayout.VERTICAL_ALIGN_MIDDLE;
			layout.gap = 20 * GlobalConfig.dpiScale;
			_container.layout = layout;
			
			_notificationTitle = new Label();
			_notificationTitle.text = Localizer.getInstance().translate("SCORE_TO_STARS_NOTIFICATION.TITLE");
			_container.addChild(_notificationTitle);
			_notificationTitle.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA_ONE, 40 * GlobalConfig.dpiScale, Theme.COLOR_DARK_GREY, null, null, null, null, null, TextFormatAlign.CENTER);
			
			_titleContainer = new Sprite();
			_container.addChild(_titleContainer);
			
			_titleBackground = new Quad(5, 5, 0xf3f3f3);
			_titleContainer.addChild(_titleBackground);
			
			_title = new Label();
			_title.nameList.add( Theme.LABEL_BLACK_CENTER );
			_title.text = Localizer.getInstance().translate("SCORE_TO_STARS.TITLE");
			_titleContainer.addChild( _title );
			_title.textRendererProperties.textFormat = new TextFormat(Theme.FONT_ARIAL_ITALIC, 25 * GlobalConfig.dpiScale, Theme.COLOR_LIGHT_GREY, null, null, null, null, null, TextFormatAlign.CENTER);
			
			_listHeader = new Sprite();
			_container.addChild( _listHeader );
			
			_scoreColumnTitle = new Label();
			_scoreColumnTitle.nameList.add( Theme.LABEL_BLACK_CENTER );
			_scoreColumnTitle.text = Localizer.getInstance().translate("SCORE_TO_STARS.SCORE");
			_listHeader.addChild(_scoreColumnTitle);
			_scoreColumnTitle.textRendererProperties.textFormat = new TextFormat(Theme.FONT_ARIAL_BOLD_ITALIC, 25 * GlobalConfig.dpiScale, Theme.COLOR_LIGHT_GREY, null, null, null, null, null, TextFormatAlign.CENTER);
			
			_starsColumnTitle = new Label();
			_starsColumnTitle.nameList.add( Theme.LABEL_BLACK_CENTER );
			_starsColumnTitle.text = Localizer.getInstance().translate("SCORE_TO_STARS.STARS_WITH_ANY");
			_listHeader.addChild(_starsColumnTitle);
			_starsColumnTitle.textRendererProperties.textFormat = new TextFormat(Theme.FONT_ARIAL_BOLD_ITALIC, 25 * GlobalConfig.dpiScale, Theme.COLOR_ORANGE, null, null, null, null, null, TextFormatAlign.CENTER);
			
			_list = new List();
			_list.scrollerProperties.horizontalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			_list.scrollerProperties.verticalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			_list.isSelectable = false;
			_list.itemRendererType = ScoreToStarsItemRenderer;
			_list.dataProvider = new ListCollection( Storage.getInstance().getProperty(StorageConfig.PROPERTY_STARS_TABLE) );
			_container.addChild(_list);
		}
		
		override protected function draw():void
		{
			_container.width = _notificationTitle.width = _list.width = this.actualWidth - padSide * 2;
			_container.x = padSide;
			
			_title.width = _container.width * 0.9;
			_title.validate();
			_titleBackground.width = _container.width * 0.95;
			_titleBackground.height = _title.height + (20 * GlobalConfig.dpiScale);
			
			_title.y = (_titleBackground.height - _title.height) * 0.5;
			_title.x = (_titleBackground.width - _title.width) * 0.5;
			
			const maxItemWidth:Number = _container.width * 0.5;
			_scoreColumnTitle.width = _starsColumnTitle.width = maxItemWidth;
			_scoreColumnTitle.validate();
			_starsColumnTitle.validate();
			_starsColumnTitle.x = maxItemWidth + padSide;
			
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
			
			_starsColumnTitle.removeFromParent(true);
			_starsColumnTitle = null;
			
			_listHeader.removeFromParent(true);
			_listHeader = null;
			
			_list.removeFromParent(true);
			_list = null;
			
			super.dispose();
		}
	}
}