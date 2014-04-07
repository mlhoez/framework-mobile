/*
Copyright © 2006-2014 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 25 nov. 2013
*/
package com.ludofactory.mobile.core.test.ads.store
{
	import com.ludofactory.mobile.core.manager.TimerManager;
	
	import feathers.controls.List;
	import feathers.controls.Scroller;
	import feathers.core.FeathersControl;
	import feathers.data.ListCollection;
	import feathers.events.FeathersEventType;
	import feathers.layout.TiledRowsLayout;
	
	import starling.events.Event;
	
	/**
	 * A specific ad container for the current tournament.
	 */	
	public class AdStoreContainer extends FeathersControl
	{
		/**
		 * List */		
		private var _list:List;
		
		/**
		 * Loop timer */		
		private var _timer:TimerManager;
		
		/**
		 * The data provider. */		
		private var _dataProvider:Array;
		
		public function AdStoreContainer()
		{
			super();
			
			//this.height = scaleToDpi(200);
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			const listLayout:TiledRowsLayout = new  TiledRowsLayout();
			listLayout.paging = TiledRowsLayout.PAGING_HORIZONTAL;
			listLayout.tileHorizontalAlign = TiledRowsLayout.TILE_HORIZONTAL_ALIGN_CENTER;
			listLayout.horizontalAlign = TiledRowsLayout.HORIZONTAL_ALIGN_CENTER;
			listLayout.useSquareTiles = false;
			listLayout.manageVisibility = true;
			
			_list = new List();
			_list.isSelectable = false;
			_list.dataProvider = new ListCollection(_dataProvider);
			_list.layout = listLayout;
			_list.itemRendererType = AdStoreItemRenderer;
			_list.snapToPages = true;
			_list.scrollBarDisplayMode = Scroller.SCROLL_BAR_DISPLAY_MODE_NONE;
			_list.horizontalScrollPolicy = Scroller.SCROLL_POLICY_ON;
			_list.addEventListener(FeathersEventType.SCROLL_START, onScrollStart);
			_list.addEventListener(FeathersEventType.SCROLL_COMPLETE, onScrollEnd);
			addChild(_list);
			
			_timer = new TimerManager(4, -1, null, onAutoScroll);
			_timer.resume();
		}
		
		override protected function draw():void
		{
			super.draw();
			
			_list.width = this.actualWidth;
			_list.height = this.actualHeight;
			_list.validate();
		}
		
//------------------------------------------------------------------------------------------------------------
//	Handlers
//------------------------------------------------------------------------------------------------------------
		
		/**
		 * When the user starts to scroll, we need to pause the timer so that
		 * it won't change page automatically.
		 */		
		private function onScrollStart(event:Event):void
		{
			_timer.pause();
		}
		
		/**
		 * When the user has finished scrolling, we need to restart the timer
		 * so that the loop can keep going. We don't simply resume the timer because
		 * if there was only half a second left, it will change page directly after
		 * the suer displayed what he wanted to see.
		 */		
		private function onScrollEnd(event:Event):void
		{
			_timer.restart();
		}
		
		/**
		 * When the timer tick, we launch the auto scroll.
		 */		
		private function onAutoScroll():void
		{
			_list.scrollToPageIndex( (_list.horizontalPageIndex == (_list.horizontalPageCount - 1)) ? 0:(_list.horizontalPageIndex + 1) , 0, _list.pageThrowDuration);
		}
		
		public function set dataProvider(val:Array):void
		{
			for(var i:int = 0; i < val.length; i++)
				val[i] = new AdStoreData( val[i] );
			_dataProvider = val;
			
			if( _list && _list.dataProvider )
			{
				_list.dataProvider.removeAll();
				_list.dataProvider = new ListCollection(_dataProvider);
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
//------------------------------------------------------------------------------------------------------------
		
		override public function dispose():void
		{
			_timer.dispose();
			_timer = null;
			
			_list.removeEventListener(FeathersEventType.SCROLL_START, onScrollStart);
			_list.removeEventListener(FeathersEventType.SCROLL_COMPLETE, onScrollEnd);
			_list.removeFromParent(true);
			_list = null;
			
			super.dispose();
		}
		
	}
}