/*
Copyright © 2006-2014 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 24 juil. 2013
*/
package com.ludofactory.mobile.application.ads
{
	import com.ludofactory.mobile.core.Localizer;
	import com.ludofactory.mobile.core.theme.Theme;
	import com.ludofactory.common.utils.scaleToDpi;
	
	import com.ludofactory.mobile.application.config.GlobalConfig;
	import com.ludofactory.mobile.core.manager.TimerManager;
	
	import feathers.controls.List;
	import feathers.controls.PageIndicator;
	import feathers.controls.Scroller;
	import feathers.core.FeathersControl;
	import feathers.data.ListCollection;
	import feathers.events.FeathersEventType;
	import feathers.layout.TiledRowsLayout;
	
	import starling.events.Event;
	
	/**
	 * This is the main ad container.
	 * If no specific ad have been loaded in the application, it will display a more
	 * generic ad explaining how to play and win.
	 */	
	public class AdContainer extends FeathersControl
	{
		/**
		 * Page indicator */		
		private var _pageIndicator:PageIndicator;
		
		/**
		 * List */		
		private var _list:List;
		
		/**
		 * Loop timer */		
		private var _timer:TimerManager;
		
		public function AdContainer()
		{
			super();
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			initializeGenericAd();
		}
		
		override protected function draw():void
		{
			super.draw();
			
			_pageIndicator.width = this.actualWidth;
			_pageIndicator.validate();
			_pageIndicator.y = this.actualHeight - _pageIndicator.height - scaleToDpi(10);
			
			_list.width = this.actualWidth;
			_list.height = this.actualHeight;
			_list.validate();
			
			this._pageIndicator.pageCount = this._list.horizontalPageCount;
		}
		
//------------------------------------------------------------------------------------------------------------
//	Generic ad
//------------------------------------------------------------------------------------------------------------
		
		/**
		 * Initializes the generic ad.
		 */		
		private function initializeGenericAd():void
		{
			const listLayout:TiledRowsLayout = new  TiledRowsLayout();
			listLayout.paging = TiledRowsLayout.PAGING_HORIZONTAL;
			listLayout.tileHorizontalAlign = TiledRowsLayout.TILE_HORIZONTAL_ALIGN_CENTER;
			listLayout.horizontalAlign = TiledRowsLayout.HORIZONTAL_ALIGN_CENTER;
			listLayout.useSquareTiles = false;
			listLayout.manageVisibility = true;
			
			_list = new List();
			_list.isSelectable = false;
			_list.dataProvider = new ListCollection([ new AdData("basic-ad-play-icon",   Localizer.getInstance().translate("AD_CONTAINER.FIRST_GENERIC_AD"),  Localizer.getInstance().translate("AD_CONTAINER.GENERIC_BUTTON")),
													  new AdData("basic-ad-play-icon", Localizer.getInstance().translate("AD_CONTAINER.SECOND_GENERIC_AD"), Localizer.getInstance().translate("AD_CONTAINER.GENERIC_BUTTON")),
													  new AdData("basic-ad-play-icon",    Localizer.getInstance().translate("AD_CONTAINER.THIRD_GENERIC_AD"),  Localizer.getInstance().translate("AD_CONTAINER.GENERIC_BUTTON")) ]);
			_list.layout = listLayout;
			_list.itemRendererType = AdItemRenderer;
			_list.scrollerProperties.snapToPages = true;
			_list.scrollerProperties.scrollBarDisplayMode = Scroller.SCROLL_BAR_DISPLAY_MODE_NONE;
			_list.scrollerProperties.horizontalScrollPolicy = Scroller.SCROLL_POLICY_ON;
			_list.addEventListener(FeathersEventType.SCROLL_START, onScrollStart);
			_list.addEventListener(FeathersEventType.SCROLL_COMPLETE, onScrollEnd);
			_list.addEventListener(Event.SCROLL, onScrollList);
			addChild(_list);
			
			_pageIndicator = new PageIndicator();
			_pageIndicator.direction = PageIndicator.DIRECTION_HORIZONTAL;
			_pageIndicator.pageCount = 1;
			_pageIndicator.gap = 3;
			_pageIndicator.addEventListener(Event.CHANGE, onPageIndicatorChange);
			addChild(_pageIndicator);
			
			_timer = new TimerManager(4, -1, null, onAutoScroll);
			_timer.resume();
		}
		
		/**
		 * Allow the user to change the page by touching the page indicators.
		 */		
		protected function onPageIndicatorChange(event:Event):void
		{
			_list.scrollToPageIndex(_pageIndicator.selectedIndex, 0, _list.pageThrowDuration);
		}
		
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
		 * When the user scrolls in the list.
		 */		
		private function onScrollList(event:Event = null):void
		{
			//clearAllButtonsFlag(); // avoid purchase while the user scrolls
			_pageIndicator.selectedIndex = _list.horizontalPageIndex;
		}
		
		/**
		 * When the timer tick, we launch the auto scroll.
		 */		
		private function onAutoScroll():void
		{
			_pageIndicator.selectedIndex = (_pageIndicator.selectedIndex == (_list.horizontalPageCount - 1)) ? 0:(_pageIndicator.selectedIndex + 1);
			_list.scrollToPageIndex(_pageIndicator.selectedIndex, 0, _list.pageThrowDuration);
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
			_list.removeEventListener(Event.SCROLL, onScrollList);
			_list.removeFromParent(true);
			_list = null;
			
			_pageIndicator.removeEventListener(Event.CHANGE, onPageIndicatorChange);
			_pageIndicator.removeFromParent(true);
			_pageIndicator = null;
			
			super.dispose();
		}
		
	}
}