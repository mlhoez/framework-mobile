/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 5 août 2013
*/
package com.ludofactory.mobile.core.scoring
{
	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.manager.MemberManager;
	import com.ludofactory.mobile.core.storage.Storage;
	import com.ludofactory.mobile.core.storage.StorageConfig;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import feathers.controls.Label;
	import feathers.controls.LayoutGroup;
	import feathers.controls.List;
	import feathers.controls.ScrollContainer;
	import feathers.controls.Scroller;
	import feathers.data.ListCollection;
	
	import starling.display.Quad;
	import starling.utils.formatString;
	
	public class ScoreToStarsContainer extends ScrollContainer
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
		 * The points with credits list title */		
		private var _pointsWithCredits:Label;
		
		private var _exampleLabel:Label;
		
		/**
		 * List */		
		private var _list:List;
		
		public function ScoreToStarsContainer()
		{
			super();
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			//var vlayout:VerticalLayout = new VerticalLayout();
			//vlayout.verticalAlign = VerticalLayout.VERTICAL_ALIGN_TOP;
			//vlayout.horizontalAlign = VerticalLayout.HORIZONTAL_ALIGN_CENTER;
			//vlayout.gap = scaleAndRoundToDpi(20);
			//vlayout.paddingBottom = scaleAndRoundToDpi(50);
			
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
			if( MemberManager.getInstance().getGiftsEnabled() )
				_title.text = _("Les parties en Tournoi vous permettent d’affronter d’autres joueurs pendant une durée déterminée. Cumulez des Rubis et gagnez le cadeau de vos rêves en fonction de votre classement final.\n\nUne partie en tournoi vous rapporte + ou - de Rubis en fonction de votre score.");
			else
				_title.text = _("Les parties en Tournoi vous permettent d’affronter d’autres joueurs pendant une durée déterminée. Cumulez des Rubis et gagnez le lot de vos rêves en fonction de votre classement final.\n\nUne partie en tournoi vous rapporte + ou - de Rubis en fonction de votre score.");
			_titleContainer.addChild( _title );
			_title.textRendererProperties.textFormat = new TextFormat(Theme.FONT_ARIAL, scaleAndRoundToDpi(25), Theme.COLOR_LIGHT_GREY, false, true, null, null, null, TextFormatAlign.CENTER);
			
			_headerContainer = new LayoutGroup();
			_mainContainer.addChild(_headerContainer);
			
			_scoreTitle = new Label();
			_scoreTitle.text = _("Score");
			_headerContainer.addChild(_scoreTitle);
			_scoreTitle.textRendererProperties.textFormat = new TextFormat(Theme.FONT_ARIAL, scaleAndRoundToDpi(25), Theme.COLOR_LIGHT_GREY, true, true, null, null, null, TextFormatAlign.CENTER);
			
			_pointsWithCredits = new Label();
			_pointsWithCredits.text = _("Rubis");
			_headerContainer.addChild(_pointsWithCredits);
			_pointsWithCredits.textRendererProperties.textFormat = new TextFormat(Theme.FONT_ARIAL, scaleAndRoundToDpi(25), Theme.COLOR_ORANGE, true, true, null, null, null, TextFormatAlign.CENTER);
			
			_list = new List();
			_list.isSelectable = false;
			_list.itemRendererType = ScoreToStarsItemRenderer;
			_list.dataProvider = new ListCollection( Storage.getInstance().getProperty(StorageConfig.PROPERTY_STARS_TABLE) );
			_list.verticalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			_list.horizontalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			_mainContainer.addChild(_list);
			
			var scoreData:Array = Storage.getInstance().getProperty(StorageConfig.PROPERTY_STARS_TABLE);
			var scoreToStarsDataInf:ScoreToStarsData = scoreData[ int(scoreData.length / 2) ];
			var scoreToStarsDataSup:ScoreToStarsData = scoreData[ int(scoreData.length / 2) + 1 ];
				
			_exampleLabel = new Label();
			_exampleLabel.text = formatString(_("Par exemple : avec un score de {0}, vous gagnez {1} Rubis."), int(scoreToStarsDataInf.sup + (scoreToStarsDataSup.sup - scoreToStarsDataInf.sup) * 0.5), scoreToStarsDataSup.stars) + "\n\n";
			_mainContainer.addChild(_exampleLabel);
			_exampleLabel.textRendererProperties.textFormat = new TextFormat(Theme.FONT_ARIAL, scaleAndRoundToDpi(26), Theme.COLOR_LIGHT_GREY, false, true);
		}
		
		override protected function draw():void
		{
			super.draw();
			
			_mainContainer.width = _list.width = this.actualWidth;
			_mainContainer.height = this.actualHeight;
			
			_titleContainer.width = _title.width =  this.actualWidth * 0.9;
			
			_scoreTitle.width = _pointsWithCredits.width = this.actualWidth * 0.5;
			_pointsWithCredits.x = _scoreTitle.width;
			
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