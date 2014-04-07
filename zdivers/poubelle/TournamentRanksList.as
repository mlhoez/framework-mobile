/*
Copyright © 2006-2014 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 8 sept. 2013
*/
package com.ludofactory.mobile.tournament.listing
{
	import com.ludofactory.mobile.utils.scaleToDpi;
	
	import feathers.controls.List;
	import feathers.core.FeathersControl;
	import feathers.data.ListCollection;
	import feathers.layout.TiledColumnsLayout;
	
	public class TournamentRanksList extends FeathersControl
	{
		/**
		 * The top 3 list. */		
		private var _topThreeList:List;
		
		/**
		 * The list containing the other people. */		
		private var _rankingList:List;
		
		/**
		 * the data provider. */		
		private var _dataProvider:Array;
		
		public function TournamentRanksList()
		{
			super();
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			
			// TODO A retirer quand les écrans seront intégrés
			_dataProvider = [    new RankData(1, 4, "Jean Dupont", 999999),
				new RankData(1, 5, "Jean Dupont", 999999),
				new RankData(1, 6, "Jean Dupont", 999999),
				new RankData(1, 7, "Jean Dupont", 999999),
				new RankData(1, 8, "Jean Dupont", 999999),
				new RankData(1, 9, "Jean Dupont", 999999),
				new RankData(1, 10, "Jean Dupont", 999999),
				new RankData(2, 0,  "1000€", 0),
				new RankData(3, 0,  "Xbox 360", 0),
				new RankData(1, 11, "Jean Dupont", 999999),
				new RankData(1, 12, "Jean Dupont", 999999),
				new RankData(1, 13, "Jean Dupont", 999999),
				new RankData(1, 14, "Jean Dupont", 999999),
				new RankData(1, 15, "Jean Dupont", 999999),
				new RankData(1, 16, "Jean Dupont", 999999),
				new RankData(1, 17, "Jean Dupont", 999999),
				new RankData(1, 18, "Jean Dupont", 999999),
				new RankData(1, 19, "Jean Dupont", 999999),
				new RankData(1, 20, "Jean Dupont", 999999),
				new RankData(1, 21, "Jean Dupont", 999999),
				new RankData(1, 22, "Jean Dupont", 999999),
				new RankData(1, 23, "Jean Dupont", 999999),
				new RankData(1, 24, "Jean Dupont", 999999),
				new RankData(2, 0,  "Xbox 360", 0),
				new RankData(3, 0,  "Goodies", 0),
				new RankData(1, 25, "Jean Dupont", 999999),
				new RankData(1, 26, "Jean Dupont", 999999),
				new RankData(1, 27, "Jean Dupont", 999999),
				new RankData(1, 28, "Jean Dupont", 999999),
				new RankData(1, 29, "Jean Dupont", 999999),
				new RankData(1, 30, "Jean Dupont", 999999),
				new RankData(1, 31, "Jean Dupont", 999999),
				new RankData(1, 32, "Jean Dupont", 999999),
				new RankData(1, 33, "Jean Dupont", 999999),
				new RankData(1, 34, "Jean Dupont", 999999),
				new RankData(1, 35, "Jean Dupont", 999999),
				new RankData(1, 36, "Jean Dupont", 999999),
				new RankData(1, 37, "Jean Dupont", 999999),
				new RankData(1, 38, "Jean Dupont", 999999, true),
				new RankData(1, 39, "Jean Dupont", 999999),
				new RankData(1, 40, "Jean Dupont", 999999) ];
			
			const listLayout:TiledColumnsLayout = new  TiledColumnsLayout();
			listLayout.paging = TiledColumnsLayout.PAGING_NONE;
			listLayout.tileHorizontalAlign = TiledColumnsLayout.TILE_HORIZONTAL_ALIGN_CENTER;
			listLayout.horizontalAlign = TiledColumnsLayout.HORIZONTAL_ALIGN_CENTER;
			listLayout.useSquareTiles = false;
			listLayout.manageVisibility = true;
			
			_topThreeList = new List();
			_topThreeList.layout = listLayout;
			_topThreeList.itemRendererType = RankTopThreeItemRenderer;
			_topThreeList.dataProvider = new ListCollection( [ _dataProvider.shift(), _dataProvider.shift(), _dataProvider.shift() ] );
			addChild(_topThreeList);
			
			_rankingList = new List();
			_rankingList.itemRendererType = RankItemRenderer;
			_rankingList.dataProvider = new ListCollection( _dataProvider );
			addChild(_rankingList);
		}
		
		override protected function draw():void
		{
			super.draw();
			
			_topThreeList.width = this.actualWidth;
			_topThreeList.height = scaleToDpi(104);
			
			_rankingList.y = _topThreeList.height;
			_rankingList.width = this.actualWidth;
			_rankingList.height = this.actualHeight - _topThreeList.height;
		}
		
//------------------------------------------------------------------------------------------------------------
//	Utils
//------------------------------------------------------------------------------------------------------------
		
		//private function 
		
//------------------------------------------------------------------------------------------------------------
//	GET
//------------------------------------------------------------------------------------------------------------
		
		public function set dataProvider(val:Array):void
		{
			_dataProvider = val;
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
//------------------------------------------------------------------------------------------------------------
		
		override public function dispose():void
		{
			_topThreeList.removeFromParent(true);
			_topThreeList = null;
			
			_rankingList.removeFromParent(true);
			_rankingList = null;
			
			super.dispose();
		}
	}
}