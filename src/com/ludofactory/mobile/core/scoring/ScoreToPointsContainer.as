/*
Copyright © 2006-2014 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 5 août 2013
*/
package com.ludofactory.mobile.core.scoring
{
	import com.ludofactory.common.gettext.LanguageManager;
	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.common.utils.Utilities;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.authentication.MemberManager;
	import com.ludofactory.mobile.core.storage.Storage;
	import com.ludofactory.mobile.core.storage.StorageConfig;
	import com.ludofactory.mobile.core.test.config.GlobalConfig;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import feathers.controls.Label;
	import feathers.controls.LayoutGroup;
	import feathers.controls.List;
	import feathers.controls.ScrollContainer;
	import feathers.controls.Scroller;
	import feathers.data.ListCollection;
	import feathers.layout.HorizontalLayout;
	
	import starling.display.Image;
	import starling.display.Quad;
	import starling.utils.formatString;
	
	public class ScoreToPointsContainer extends ScrollContainer
	{
		/**
		 * The main container. */		
		private var _mainContainer:ScrollContainer;
		
		/**
		 * The title container */		
		private var _titleContainer:ScrollContainer;
		/**
		 * The title */		
		private var _title:Label;
		
		/**
		 * The header container. */		
		private var _headerContainer:LayoutGroup;
		/**
		 * The score list title */		
		private var _scoreTitle:Label;
		
		/**
		 * The points with free group. */		
		private var _pointsWithFreeGroup:LayoutGroup;
		/**
		 * The points with free list title */		
		private var _pointsWithFree:Label;
		/**
		 * The free icon. */		
		private var _freeIcon:Image
		
		/**
		 * The points with credits group. */		
		private var _pointsWithCreditsGroup:LayoutGroup;
		/**
		 * The points with credits list title */		
		private var _pointsWithCredits:Label;
		/**
		 * The credits icon */		
		private var _creditsIcon:Image;
		/**
		 *  */		
		private var _multiplySixIcon:Image;
		
		/**
		 * List */		
		private var _list:List;
		
		private var _exampleLabel:Label;
		
		public function ScoreToPointsContainer()
		{
			super();
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			/*var vlayout:VerticalLayout = new VerticalLayout();
			vlayout.verticalAlign = VerticalLayout.VERTICAL_ALIGN_TOP;
			vlayout.horizontalAlign = VerticalLayout.HORIZONTAL_ALIGN_CENTER;*/
			
			_mainContainer = new ScrollContainer();
			_mainContainer.paddingTop = scaleAndRoundToDpi(10);
			_mainContainer.verticalScrollPolicy = Scroller.SCROLL_POLICY_AUTO;
			_mainContainer.horizontalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			//_mainContainer.layout = vlayout;
			addChild(_mainContainer);
			
			_titleContainer = new ScrollContainer();
			_titleContainer.horizontalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			_titleContainer.verticalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			_titleContainer.padding = scaleAndRoundToDpi(5);
			_titleContainer.backgroundSkin = new Quad(5, 5, 0xf3f3f3);
			_mainContainer.addChild(_titleContainer);
			
			_title = new Label();
			_title.text = _("Les parties Classiques vous permettent de cumuler des points que vous pourrez ensuite convertir en cadeaux ou bien utiliser pour jouer en Tournoi.\n\nUne partie vous rapporte + ou - de Points en fonction de votre score et de votre mise.");
			_titleContainer.addChild( _title );
			_title.textRendererProperties.textFormat = new TextFormat(Theme.FONT_ARIAL, scaleAndRoundToDpi(25), Theme.COLOR_LIGHT_GREY, false, true, null, null, null, TextFormatAlign.CENTER);
			
			_headerContainer = new LayoutGroup();
			_mainContainer.addChild(_headerContainer);
			
			_scoreTitle = new Label();
			_scoreTitle.text = _("Score");
			_headerContainer.addChild(_scoreTitle);
			_scoreTitle.textRendererProperties.textFormat = new TextFormat(Theme.FONT_ARIAL, scaleAndRoundToDpi(25), Theme.COLOR_LIGHT_GREY, true, true, null, null, null, TextFormatAlign.CENTER);
			
			var hlayout:HorizontalLayout = new HorizontalLayout();
			hlayout.horizontalAlign = HorizontalLayout.HORIZONTAL_ALIGN_LEFT;
			hlayout.verticalAlign = HorizontalLayout.VERTICAL_ALIGN_MIDDLE;
			
			_pointsWithFreeGroup = new LayoutGroup();
			_pointsWithFreeGroup.layout = hlayout;
			_headerContainer.addChild(_pointsWithFreeGroup);
			
			_pointsWithFree = new Label();
			_pointsWithFree.text = _("Mise : 1");
			_pointsWithFreeGroup.addChild(_pointsWithFree);
			_pointsWithFree.textRendererProperties.textFormat = new TextFormat(Theme.FONT_ARIAL, scaleAndRoundToDpi(25), Theme.COLOR_ORANGE, true, true, null, null, null, TextFormatAlign.CENTER);
			_pointsWithFree.textRendererProperties.wordWrap = false;
			
			_freeIcon = new Image( AbstractEntryPoint.assets.getTexture("summary-icon-free") );
			_freeIcon.scaleX = _freeIcon.scaleY = GlobalConfig.dpiScale;
			_pointsWithFreeGroup.addChild( _freeIcon );
			
			_pointsWithCreditsGroup = new LayoutGroup();
			_pointsWithCreditsGroup.layout = hlayout;
			_headerContainer.addChild(_pointsWithCreditsGroup);
			
			_pointsWithCredits = new Label();
			_pointsWithCredits.text = _("Mise : 1");
			_pointsWithCreditsGroup.addChild(_pointsWithCredits);
			_pointsWithCredits.textRendererProperties.textFormat = new TextFormat(Theme.FONT_ARIAL, scaleAndRoundToDpi(25), Theme.COLOR_ORANGE, true, true, null, null, null, TextFormatAlign.CENTER);
			_pointsWithCredits.textRendererProperties.wordWrap = false;
			
			_creditsIcon = new Image( AbstractEntryPoint.assets.getTexture("summary-icon-credits") );
			_creditsIcon.scaleX = _creditsIcon.scaleY = GlobalConfig.dpiScale;
			_pointsWithCreditsGroup.addChild( _creditsIcon );
			
			_multiplySixIcon = new Image( AbstractEntryPoint.assets.getTexture( "WinMorePoints" + (MemberManager.getInstance().getRank() < 5 ? "X5" : "X6") + LanguageManager.getInstance().lang ) );
			_multiplySixIcon.scaleX = _multiplySixIcon.scaleY = Utilities.getScaleToFill(_multiplySixIcon.width, _multiplySixIcon.height, _creditsIcon.width, _creditsIcon.height);
			_pointsWithCreditsGroup.addChild( _multiplySixIcon );
			
			_list = new List();
			_list.isSelectable = false;
			_list.itemRendererType = ScoreToPointsItemRenderer;
			_list.dataProvider = new ListCollection( Storage.getInstance().getProperty(StorageConfig.PROPERTY_POINTS_TABLE) );
			_list.verticalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			_list.horizontalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			_mainContainer.addChild(_list);
			
			var scoreData:Array = Storage.getInstance().getProperty(StorageConfig.PROPERTY_POINTS_TABLE);
			var scoreToStarsDataInf:ScoreToPointsData = scoreData[ int(scoreData.length / 2) ];
			var scoreToStarsDataSup:ScoreToPointsData = scoreData[ int(scoreData.length / 2) + 1 ];
			
			_exampleLabel = new Label();
			_exampleLabel.text = formatString(_("Par exemple : avec un score de {0} vous gagnez {1} Points avec une partie gratuite ou {2} Points avec une partie à crédit."), int(scoreToStarsDataInf.sup + (scoreToStarsDataSup.sup - scoreToStarsDataInf.sup) * 0.5), scoreToStarsDataSup.pointsWithFree, (MemberManager.getInstance().getRank() < 5 ? scoreToStarsDataSup.pointsWithCreditsNormal : scoreToStarsDataSup.pointsWithCreditsVip)) + "\n\n" + (MemberManager.getInstance().getRank() < 5 ? (_("Avantage VIP : en devenant Aventurier II, multipliez vos gains par 6 au lieu de 5 !") + "\n\n") : "");
			_mainContainer.addChild(_exampleLabel);
			_exampleLabel.textRendererProperties.textFormat = new TextFormat(Theme.FONT_ARIAL, scaleAndRoundToDpi(26), Theme.COLOR_LIGHT_GREY, false, true);
		}
		
		override protected function draw():void
		{
			super.draw();
			
			_mainContainer.width = _list.width = this.actualWidth;
			_mainContainer.height = this.actualHeight;
			
			_titleContainer.width = _title.width =  this.actualWidth * 0.9;
			
			_scoreTitle.width = this.actualWidth / 3;
			
			_pointsWithCreditsGroup.validate();
			_pointsWithFreeGroup.x = _scoreTitle.width + (_scoreTitle.width - _pointsWithFreeGroup.width) * 0.5;
			_pointsWithCreditsGroup.x = (_scoreTitle.width * 2) + (_scoreTitle.width - _pointsWithCreditsGroup.width) * 0.5;
			
			_titleContainer.y = scaleAndRoundToDpi(20);
			_titleContainer.x = (actualWidth - _titleContainer.width) * 0.5;
			_titleContainer.validate();
			
			_headerContainer.y = _titleContainer.y + _titleContainer.height + scaleAndRoundToDpi(40);
			_headerContainer.validate();
			
			_list.y = _headerContainer.y + _headerContainer.height + scaleAndRoundToDpi(10);
			_list.validate();
			
			_exampleLabel.y = _list.y + _list.height + scaleAndRoundToDpi(20);
			_exampleLabel.width = actualWidth * 0.9;
			_exampleLabel.x = (actualWidth - _exampleLabel.width) * 0.5;
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
//------------------------------------------------------------------------------------------------------------
		
		override public function dispose():void
		{
			_title.removeFromParent(true);
			_title = null;
			
			_titleContainer.removeFromParent(true);
			_titleContainer = null;
			
			_scoreTitle.removeFromParent(true);
			_scoreTitle = null;
			
			_pointsWithCredits.removeFromParent(true);
			_pointsWithCredits = null;
			
			_pointsWithFree.removeFromParent(true);
			_pointsWithFree = null;
			
			_headerContainer.removeFromParent(true);
			_headerContainer = null;
			
			_list.removeFromParent(true);
			_list = null;
			
			_mainContainer.removeFromParent(true);
			_mainContainer = null;
			
			super.dispose();
		}
		
	}
}