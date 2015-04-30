/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 3 sept. 2013
*/
package com.ludofactory.mobile.vip
{
	import com.ludofactory.mobile.core.controls.AdvancedScreen;
	
	import feathers.controls.List;
	import feathers.data.ListCollection;
	import feathers.layout.TiledRowsLayout;
	
	public class VipScreen extends AdvancedScreen
	{
		private var _list:List;
		
		public function VipScreen()
		{
			super();
			
			_appBackground = false;
			_tiledBackground = true;
			_fullScreen = false;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			const listLayout:TiledRowsLayout = new  TiledRowsLayout();
			listLayout.paging = TiledRowsLayout.PAGING_HORIZONTAL;
			//listLayout.tileHorizontalAlign = TiledRowsLayout.TILE_HORIZONTAL_ALIGN_CENTER;
			//listLayout.horizontalAlign = TiledRowsLayout.HORIZONTAL_ALIGN_CENTER;
			listLayout.useSquareTiles = false;
			listLayout.manageVisibility = true;
			
			
			_list = new List();
			//_list.pageWidth = 300;
			_list.snapToPages = true;
			_list.layout = listLayout;
			_list.itemRendererType = VipItemRenderer;
			_list.dataProvider = new ListCollection( [ { title:"1" }, { title:"2" }, { title:"3" }, { title:"4" }, { title:"5" }, { title:"6" }, { title:"7" } ] );
			addChild( _list );
		}
		
		override protected function draw():void
		{
			super.draw();
			
			_list.width = this.actualWidth;
			_list.height = this.actualHeight;
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
//------------------------------------------------------------------------------------------------------------
		
		override public function dispose():void
		{
			
			super.dispose();
		}
		
	}
}