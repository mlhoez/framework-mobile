/*
 Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
 Framework mobile
 Author  : Maxime Lhoez
 Created : 24 Août 2015
*/
package com.ludofactory.mobile.core.avatar.maker.newItems
{
	
	import com.ludofactory.common.gettext.aliases._n;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.avatar.maker.items.ItemManager;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import feathers.controls.List;
	import feathers.controls.PageIndicator;
	import feathers.controls.Scroller;
	import feathers.data.ListCollection;
	import feathers.layout.TiledColumnsLayout;
	
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.text.TextField;
	
	public class NewCommonItemsContainer extends Sprite
	{
		/**
		 * New common items list. */
		private var _itemsList:List;
		/**
		 * List page indicator */
		private var _pageIndicator:PageIndicator;
		
		/**
		 * The popup title. */
		private var _title:TextField;
		/**
		 * The information message. */
		private var _messageLabel:TextField;
		/**
		 * The separator. */
		private var _separator:Quad;
		
		public function NewCommonItemsContainer(isInBothLayout:Boolean = false)
		{
			super();
			
			_title = new TextField(scaleAndRoundToDpi(isInBothLayout ? 340: 400), scaleAndRoundToDpi(90), _n("NOUVEL OBJET !", "NOUVEAUX OBJETS !", ItemManager.getInstance().newCommonItems.length), Theme.FONT_OSWALD, scaleAndRoundToDpi(40), 0xff6600);
			//_title.nativeFilters = [ new DropShadowFilter(4, 45, 0x010101, 0.5, 3, 3, 3) ];
			_title.autoScale = true;
			_title.batchable = true;
			_title.touchable = false;
			//_title.border = true;
			addChild(_title);
			
			_messageLabel = new TextField(scaleAndRoundToDpi(isInBothLayout ? 340 : 400), scaleAndRoundToDpi(50), _n("Un nouvel objet est disponbile !", "De nouveaux objets sont disponibles", ItemManager.getInstance().newCommonItems.length), Theme.FONT_OSWALD, scaleAndRoundToDpi(40), 0x808080);
			_messageLabel.touchable = false;
			_messageLabel.batchable = true;
			_messageLabel.autoScale = true;
			_messageLabel.border = false;
			_messageLabel.touchable = false;
			_messageLabel.x = _title.x;
			_messageLabel.y = _title.y + _title.height;
			addChild(_messageLabel);
			
			_separator = new Quad(5, scaleAndRoundToDpi(1), 0xb3b3b3);
			_separator.y = _title.y + _title.height - scaleAndRoundToDpi(5);
			_separator.width = _title.width * 0.6;
			_separator.x = _title.x + ((_title.width - _separator.width) * 0.5);
			addChild(_separator);
			
			const listLayout:TiledColumnsLayout = new  TiledColumnsLayout();
			listLayout.paging = ItemManager.getInstance().newCommonItems.length > (isInBothLayout ? 2 : 3) ? TiledColumnsLayout.PAGING_HORIZONTAL : TiledColumnsLayout.PAGING_NONE;
			listLayout.tileHorizontalAlign = TiledColumnsLayout.TILE_HORIZONTAL_ALIGN_CENTER;
			listLayout.horizontalAlign = TiledColumnsLayout.HORIZONTAL_ALIGN_CENTER;
			listLayout.horizontalGap = scaleAndRoundToDpi(10);
			
			_itemsList = new List();
			_itemsList.isSelectable = false;
			_itemsList.dataProvider = new ListCollection(ItemManager.getInstance().newCommonItems);
			_itemsList.layout = listLayout;
			_itemsList.itemRendererType = NewItemRenderer;
			_itemsList.snapToPages = true;
			_itemsList.horizontalScrollPolicy = Scroller.SCROLL_POLICY_AUTO;
			
			_itemsList.height = scaleAndRoundToDpi(130); // height of the item renderer
			_itemsList.y = _messageLabel.y + _messageLabel.height + scaleAndRoundToDpi(10);
			addChild(_itemsList);
			_itemsList.width = isInBothLayout ? scaleAndRoundToDpi(130*2+10*2) : scaleAndRoundToDpi(130*3+10*3);
			_itemsList.x = _title.x + (_title.width - _itemsList.width) * 0.5;
			_itemsList.validate();
			_itemsList.addEventListener(Event.SCROLL, onScrollList);
			
			_pageIndicator = new PageIndicator();
			_pageIndicator.direction = PageIndicator.DIRECTION_HORIZONTAL;
			_pageIndicator.pageCount = _itemsList.horizontalPageCount;
			_pageIndicator.gap = 3;
			_pageIndicator.addEventListener(Event.CHANGE, onPageIndicatorChange);
			addChild(_pageIndicator);
			
			_pageIndicator.width = _itemsList.width;
			_pageIndicator.x = _itemsList.x;
			_pageIndicator.validate();
			_pageIndicator.y = _itemsList.y + _itemsList.height;
		}
		
//------------------------------------------------------------------------------------------------------------
//	Navigation
		
		
		/**
		 * Allow the user to change the page by touching the page indicators.
		 */
		protected function onPageIndicatorChange(event:Event):void
		{
			_itemsList.scrollToPageIndex(_pageIndicator.selectedIndex, 0, _itemsList.pageThrowDuration);
		}
		
		/**
		 * When the user scrolls in the list.
		 */
		private function onScrollList(event:Event = null):void
		{
			//clearAllButtonsFlag(); // avoid purchase while the user scrolls
			_pageIndicator.selectedIndex = _itemsList.horizontalPageIndex;
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
		
		override public function dispose():void
		{
			_itemsList.removeEventListener(Event.SCROLL, onScrollList);
			_itemsList.removeFromParent(true);
			_itemsList = null;
			
			_pageIndicator.removeEventListener(Event.CHANGE, onPageIndicatorChange);
			_pageIndicator.removeFromParent(true);
			_pageIndicator = null;
			
			_title.removeFromParent(true);
			_title = null;
			
			_messageLabel.removeFromParent(true);
			_messageLabel = null;
			
			_separator.removeFromParent(true);
			_separator = null;
			
			super.dispose();
		}
		
	}
}