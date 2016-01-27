/*
 Copyright © 2006-2015 Ludo Factory
 Avatar Maker - Ludokado
 Author  : Maxime Lhoez
 Created : 24 août 2015
*/
package com.ludofactory.mobile.core.avatar.maker.newItems
{
	
	import com.greensock.TweenMax;
	import com.greensock.easing.Linear;
	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.common.gettext.aliases._n;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.avatar.AvatarMakerAssets;
	import com.ludofactory.mobile.core.avatar.maker.items.ItemManager;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.manager.MemberManager;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import feathers.controls.List;
	import feathers.controls.PageIndicator;
	import feathers.controls.Scroller;
	import feathers.data.ListCollection;
	import feathers.layout.TiledColumnsLayout;
	
	import flash.filters.DropShadowFilter;
	
	import starling.display.Button;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.text.TextField;
	import starling.utils.deg2rad;
	
	public class NewVipItemsContainer extends Sprite
	{
		/**
		 * Icon of the new rank. */
		private var _newRankIcon:Image;
		/**
		 * Stripes displayed behing the rank icon. */
		private var _rankStripes:Image;
		
		/**
		 * Items list. */
		private var _itemsList:List;
		/**
		 * Left arrow used for the navigation in the list. */
		//private var _leftArrow:Button;
		/**
		 * Right arrow used for the navigation in the list. */
		//private var _rightArrow:Button;
		/**
		 * Helper used to calculate the state of the arrows. */
		private var _helperIndex:int;
		
		
		
		/**
		 * Page indicator */
		private var _pageIndicator:PageIndicator;
		
		/**
		 * The popup title. */
		private var _title:TextField;
		/**
		 * The information message. */
		private var _messageLabel:TextField;
		/**
		 * The tripe displayed between the title and the message. */
		private var _separator:Quad;
		
		public function NewVipItemsContainer(refWidth:int, refHeight:int, isInBothLayout:Boolean = false)
		{
			super();
			
			_rankStripes = new Image(AvatarMakerAssets.rankStripes);
			_rankStripes.scaleX = _rankStripes.scaleY = GlobalConfig.dpiScale;
			_rankStripes.alignPivot();
			addChild(_rankStripes);
			
			_newRankIcon = new Image(AvatarMakerAssets[("rank_" + MemberManager.getInstance().rank + "_texture")]);
			_newRankIcon.scaleX = _newRankIcon.scaleY = GlobalConfig.dpiScale;
			addChild(_newRankIcon);
			
			_rankStripes.x = _newRankIcon.x + (_newRankIcon.width * 0.5);
			_rankStripes.y = _newRankIcon.y + (_newRankIcon.height * 0.5);
			
			_title = new TextField(scaleAndRoundToDpi(isInBothLayout ? 340: 400), scaleAndRoundToDpi(90), _("NOUVEAU RANG !"), Theme.FONT_OSWALD, scaleAndRoundToDpi(40), 0xff6600);
			//_title.nativeFilters = [ new DropShadowFilter(4, 45, 0x010101, 0.5, 3, 3, 3) ];
			_title.autoScale = true;
			_title.batchable = true;
			_title.touchable = false;
			//_title.border = true;
			_title.x = _newRankIcon.x + _newRankIcon.width - scaleAndRoundToDpi(10);
			_title.y = scaleAndRoundToDpi(35);
			addChild(_title);
			
			_messageLabel = new TextField(scaleAndRoundToDpi(isInBothLayout ? 340: 400), scaleAndRoundToDpi(50), _n("Vous avez débloqué un nouvel objet !", "Vous avez débloqué de nouveaux objets !", ItemManager.getInstance().newVipItems.length), Theme.FONT_OSWALD, scaleAndRoundToDpi(23), 0x808080);
			_messageLabel.touchable = false;
			_messageLabel.batchable = true;
			_messageLabel.autoScale = true;
			//_messageLabel.border = true;
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
			listLayout.paging = ItemManager.getInstance().newVipItems.length > 3 ? TiledColumnsLayout.PAGING_HORIZONTAL : TiledColumnsLayout.PAGING_NONE;
			listLayout.tileHorizontalAlign = TiledColumnsLayout.TILE_HORIZONTAL_ALIGN_CENTER;
			listLayout.horizontalAlign = TiledColumnsLayout.HORIZONTAL_ALIGN_CENTER;
			listLayout.horizontalGap = scaleAndRoundToDpi(10);
			
			_itemsList = new List();
			_itemsList.isSelectable = false;
			_itemsList.dataProvider = new ListCollection(ItemManager.getInstance().newVipItems);
			_itemsList.layout = listLayout;
			_itemsList.itemRendererType = NewItemRenderer;
			_itemsList.snapToPages = true;
			//_itemsList.scrollBarDisplayMode = Scroller.SCROLL_BAR_DISPLAY_MODE_NONE;
			_itemsList.horizontalScrollPolicy = Scroller.SCROLL_POLICY_AUTO;
			_itemsList.width = scaleAndRoundToDpi(130*3+10*3);
			_itemsList.x = scaleAndRoundToDpi(50);
			_itemsList.height = scaleAndRoundToDpi(130);
			_itemsList.y = _messageLabel.y + _messageLabel.height + scaleAndRoundToDpi(10);
			addChild(_itemsList);
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
			
			if( ItemManager.getInstance().newVipItems.length > 3 )
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
		 * Checks the state of the arrows.
		 */
		private function checkArrows(left:Boolean):void
		{
			_helperIndex = _itemsList.horizontalPageIndex + (left ? -1 : 1);
			//_leftArrow.enabled = _helperIndex > 0;
			///_rightArrow.enabled = _helperIndex < (_itemsList.horizontalPageCount - 1);
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
		
//------------------------------------------------------------------------------------------------------------
//	Memory and performance management
		
		/**
		 * Disable all stuff like particles.
		 */
		public function onMinimize():void
		{
			TweenMax.killTweensOf(_rankStripes);
		}
		
		/**
		 * Re-enable all stuff like particles.
		 */
		public function onMaximize():void
		{
			_rankStripes.rotation = deg2rad(0);
			TweenMax.to(_rankStripes, 9, { rotation:deg2rad(360), repeat:-1, ease:Linear.easeNone });
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
		
		override public function dispose():void
		{
			_newRankIcon.removeFromParent(true);
			_newRankIcon = null;
			
			TweenMax.killTweensOf(_rankStripes);
			_rankStripes.removeFromParent(true);
			_rankStripes = null;
			
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