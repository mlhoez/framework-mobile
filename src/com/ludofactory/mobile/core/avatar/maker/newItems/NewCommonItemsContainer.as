/*
 Copyright © 2006-2015 Ludo Factory
 Avatar Maker - Ludokado
 Author  : Maxime Lhoez
 Created : 24 août 2015
*/
package com.ludofactory.mobile.core.avatar.maker.newItems
{
	
	import com.ludofactory.common.gettext.aliases._n;
	import com.ludofactory.common.utils.roundUp;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.avatar.AvatarMakerAssets;
	import com.ludofactory.mobile.core.avatar.maker.items.ItemManager;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import feathers.controls.List;
	import feathers.controls.PageIndicator;
	import feathers.controls.Scroller;
	import feathers.data.ListCollection;
	import feathers.events.FeathersEventType;
	import feathers.layout.TiledColumnsLayout;
	
	import flash.filters.DropShadowFilter;
	
	import starling.display.Button;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.text.TextField;
	
	public class NewCommonItemsContainer extends Sprite
	{
		
		private var _itemsList:List;
		
		//private var _leftArrow:Button;
		//private var _rightArrow:Button;
		
		/**
		 * Page indicator */
		private var _pageIndicator:PageIndicator;
		
		/**
		 * Helper used to calculate the state of the arrows. */
		private var _helperIndex:int;
		
		/**
		 * The popup title. */
		private var _title:TextField;
		/**
		 * The information message. */
		private var _messageLabel:TextField;
		private var _separator:Quad;
		
		public function NewCommonItemsContainer(refWidth:int, refHeight:int, isInBothLayout:Boolean = false)
		{
			super();
			
			_title = new TextField(scaleAndRoundToDpi(isInBothLayout ? 340: 400), scaleAndRoundToDpi(90), _n("NOUVEL OBJET !", "NOUVEAUX OBJETS !", ItemManager.getInstance().newCommonItems.length), Theme.FONT_OSWALD, scaleAndRoundToDpi(40), 0xff6600);
			//_title.nativeFilters = [ new DropShadowFilter(4, 45, 0x010101, 0.5, 3, 3, 3) ];
			_title.autoScale = true;
			_title.batchable = true;
			_title.touchable = false;
			//_title.border = true;
			_title.x = 0//roundUp((refWidth - _title.width) * 0.5);
			_title.y = 0//scaleAndRoundToDpi(60);
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
			//_itemsList.scrollBarDisplayMode = Scroller.SCROLL_BAR_DISPLAY_MODE_NONE;
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
			
			if( ItemManager.getInstance().newCommonItems.length > (isInBothLayout ? 2 : 3) )
			{
				_itemsList.validate();
				
				/*_leftArrow = new Button(AvatarMakerAssets.newItemsLeftArrow);
				_leftArrow.addEventListener(Event.TRIGGERED, onGoLeft);
				_leftArrow.x = _itemsList.x - _leftArrow.width;
				_leftArrow.y = _itemsList.y + (_itemsList.height - _leftArrow.height) * 0.5;
				addChild(_leftArrow);
				
				_rightArrow = new Button(AvatarMakerAssets.newItemsRightArrow);
				_rightArrow.addEventListener(Event.TRIGGERED, onGoRight);
				_rightArrow.x = _itemsList.x + _itemsList.width;
				_rightArrow.y = _itemsList.y + (_itemsList.height - _rightArrow.height) * 0.5;
				addChild(_rightArrow);*/
				
				_helperIndex = _itemsList.horizontalPageIndex;
				//_leftArrow.enabled = _helperIndex > 0;
				//_rightArrow.enabled = _helperIndex < (_itemsList.horizontalPageCount - 1);
			}
			
			/*var qd:Quad = new Quad(this.width, this.height, 0x00ffff);
			qd.alpha = 0.5;
			qd.touchable = false;
			addChildAt(qd, 0);*/
		}
		
//------------------------------------------------------------------------------------------------------------
//	Navigation
		
		/**
		 * Navigate to the left.
		 */
		private function onGoLeft(event:Event):void
		{
			checkArrows(true);
			_itemsList.scrollToPageIndex((_itemsList.horizontalPageIndex - 1) < 0 ? 0 : (_itemsList.horizontalPageIndex - 1), 0, 0.5);
		}
		
		/**
		 * Navigate to the right.
		 */
		private function onGoRight(event:Event):void
		{
			checkArrows(false);
			_itemsList.scrollToPageIndex((_itemsList.horizontalPageIndex + 1) > (_itemsList.horizontalPageCount - 1) ? (_itemsList.horizontalPageCount - 1) : (_itemsList.horizontalPageIndex + 1), 0, 0.5);
		}
		
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
		
		/**
		 * When the timer tick, we launch the auto scroll.
		 */
	/*	private function onScrollEnd(event:Event):void
		{
			_pageIndicator.selectedIndex = (_pageIndicator.selectedIndex == (_itemsList.horizontalPageCount - 1)) ? 0:(_pageIndicator.selectedIndex + 1);
			//_list.scrollToPageIndex(_pageIndicator.selectedIndex, 0, _list.pageThrowDuration);
		}*/
		
		/**
		 * Checks the state of the arrows.
		 */
		private function checkArrows(left:Boolean):void
		{
			_helperIndex = _itemsList.horizontalPageIndex + (left ? -1 : 1);
			//_leftArrow.enabled = _helperIndex > 0;
			//_rightArrow.enabled = _helperIndex < (_itemsList.horizontalPageCount - 1);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Memory and performance management
		
		/**
		 * Disable all stuff like particles.
		 */
		public function onMinimize():void
		{
			
		}
		
		/**
		 * Re-enable all stuff like particles.
		 */
		public function onMaximize():void
		{
			
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
		
		override public function dispose():void
		{
			_itemsList.removeFromParent(true);
			_itemsList = null;
			
			/*if(_leftArrow)
			{
				_leftArrow.removeEventListener(Event.TRIGGERED, onGoLeft);
				_leftArrow.removeFromParent(true);
				_leftArrow = null;
			}
			
			if(_rightArrow)
			{
				_rightArrow.removeEventListener(Event.TRIGGERED, onGoRight);
				_rightArrow.removeFromParent(true);
				_rightArrow = null;
			}*/
			
			_helperIndex = 0;
			
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