/*
Copyright © 2006-2014 Ludo Factory
Framework mobile - Globbies
Author  : Maxime Lhoez
Created : 15 Décembre 2014
*/
package com.ludofactory.mobile.core.avatar.maker.items
{
	
	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.common.utils.Utilities;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.avatar.AvatarAssets;
	import com.ludofactory.mobile.core.avatar.maker.CoinsAndBasket;
	import com.ludofactory.mobile.core.avatar.maker.CustomDefaultListItemRenderer;
	import com.ludofactory.mobile.core.avatar.maker.data.AvatarFrameData;
	import com.ludofactory.mobile.core.avatar.maker.data.AvatarItemData;
	import com.ludofactory.mobile.core.avatar.test.config.LudokadoBones;
	import com.ludofactory.mobile.core.avatar.test.events.LKAvatarMakerEventTypes;
	import com.ludofactory.mobile.core.avatar.test.manager.LKConfigManager;
	import com.ludofactory.mobile.core.avatar.test.manager.LudokadoBoneConfiguration;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import feathers.controls.ImageLoader;
	import feathers.controls.List;
	import feathers.controls.Scroller;
	import feathers.data.ListCollection;
	import feathers.display.Scale3Image;
	import feathers.events.FeathersEventType;
	import feathers.layout.VerticalLayout;
	
	import flash.geom.Rectangle;
	
	import starling.display.ButtonState;
	import starling.display.Image;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.text.TextField;
	import starling.utils.HAlign;
	import starling.utils.VAlign;
	
	/**
	 * Ludokado item renderer.
	 */	
	public class AvatarItemRenderer extends CustomDefaultListItemRenderer
	{
		
	// ---------- Constants
		
		/**
		 * Color used when the item is owned but not equipped (dark orange). */
		public static const OWNED_ITEM_COLOR:uint = 0xb94d05;
		/**
		 * Color used when the item is equipped (dark green). */
		public static const EQUIPPED_ITEM_COLOR:uint = 0x1d7c12;
		/**
		 * Color used when the item is buyable (dark grey). */
		public static const BUYABLE_ITEM_COLOR:uint = 0x6E6E6E;
		/**
		 * Color used for the price label (light grey). */
		public static const PRICE_ITEM_COLOR:uint = 0x838383;
		/**
		 * Color used when the item is locked. */
		public static const LOCKED_ITEM_COLOR:uint = 0xEE0700;
		
		/**
		 * Max drag distance after the touch is released. */
		private static const MAX_DRAG_DIST:Number = 50;
		/**
		 * Current touch state. */
		protected var _currentTouchState:String;
		/**
		 * Whether the user is over this item renderer. */
		protected var _isOver:Boolean = false;
		
		/**
		 * Helper used in the commit function. */
		private var HELPER_FRAME_DATA:AvatarFrameData;
		/**
		 * Helper used in the commit function. */
		private var HELPER_SELECTED_FRAME_DATA:AvatarFrameData;
		
	// ---------- Layout properties
		
		/**
		 * Maximum height of an item in the list. */		
		//public static const MAX_ITEM_HEIGHT:int = 87;
		public static const MAX_ITEM_WIDTH:int = 87;

	// ---------- Common properties

		/**
		 * The item renderer background. */
		private var _background:Image;
		/**
		 * The icon background. */
		private var _iconBackground:Image;
		/**
		 * Item icon. */
		private var _itemIcon:ImageLoader;
 		/**
		 * Item name. */		
		private var _itemNameLabel:TextField;
		/**
		 * Item price (if not already owned). */
		private var _itemPriceLabel:TextField;
		/**
		 * The animated basket and points. */
		private var _basket:CoinsAndBasket;
		/**
		 * New icon displayed when it's a new item or when one of the behaviors is new. */
		private var _isNewIcon:Image;
		/**
		 * Vip icon background displayed when the item is locked. */
		private var _vipIconBackground:Image;
		
	// ---------- Behaviors properties
		
		/**
		 * Expand or collapse icon. */
		private var _expandOrCollapseIcon:Image;
		/**
		 * Behaviors list (when available). */
		private var _behaviorsList:List;
		/**
		 * Background displayed behing the behaviors list. */
		private var _behaviorListBackground:Scale3Image;
		
		public function AvatarItemRenderer()
		{
			super();
			
			//this.height = MAX_ITEM_HEIGHT;
			this.width = scaleAndRoundToDpi(MAX_ITEM_WIDTH);
			useHandCursor = true;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			_background = new Image(AvatarAssets.itemListBackgroundTexture);
			addChild(_background);
			
			_iconBackground = new Image(AvatarAssets.iconBuyableBackgroundTexture);
			_iconBackground.touchable = false;
			_iconBackground.alignPivot();
			addChild(_iconBackground);
			
			_itemIcon = new ImageLoader();
			_itemIcon.addEventListener(FeathersEventType.ERROR, onIOError);
			_itemIcon.addEventListener(Event.COMPLETE, onImageloaded);
			_itemIcon.snapToPixels = true;
			_itemIcon.maintainAspectRatio = true;
			_itemIcon.touchable = false;
			addChild(_itemIcon);
			
			_basket = new CoinsAndBasket();
			_basket.visible = false;
			addChild(_basket);

			const layout:VerticalLayout = new VerticalLayout();
			layout.verticalAlign = VerticalLayout.VERTICAL_ALIGN_TOP;
			layout.horizontalAlign = VerticalLayout.HORIZONTAL_ALIGN_JUSTIFY;

			_behaviorsList = new List();
			_behaviorsList.dataProvider = new ListCollection();
			_behaviorsList.isSelectable = false;
			_behaviorsList.layout = layout;
			_behaviorsList.itemRendererType = BehaviorItemRenderer;
			_behaviorsList.verticalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			_behaviorsList.horizontalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			_behaviorsList.paddingTop = 10;
			_behaviorsList.paddingBottom = 4;
			addChild(_behaviorsList);
			
			_behaviorListBackground = new Scale3Image(AvatarAssets.behaviorListBackground);
			_behaviorsList.backgroundSkin = _behaviorListBackground;
			
			_expandOrCollapseIcon = new Image(AvatarAssets.expandTexture);
			_expandOrCollapseIcon.visible = false;
			_expandOrCollapseIcon.touchable = false;
			_expandOrCollapseIcon.alignPivot();
			addChild(_expandOrCollapseIcon);
			
			_isNewIcon = new Image(AvatarAssets.newItemIconTexture);
			_isNewIcon.touchable = false;
			_isNewIcon.visible = false;
			addChild(_isNewIcon);
			
			_vipIconBackground = new Image(AbstractEntryPoint.assets.getTexture("Rank-12"));
			_vipIconBackground.touchable = false;
			_vipIconBackground.visible = false;
			addChild(_vipIconBackground);
			
			_itemNameLabel = new TextField(100, 48, "", Theme.FONT_OSWALD, 14, BUYABLE_ITEM_COLOR);
			_itemNameLabel.autoScale = true;
			_itemNameLabel.hAlign = HAlign.RIGHT;
			_itemNameLabel.vAlign = VAlign.BOTTOM;
			_itemNameLabel.touchable = false;
			addChild(_itemNameLabel);
			
			_itemPriceLabel = new TextField(100, 26, "", Theme.FONT_OSWALD, 14, PRICE_ITEM_COLOR);
			_itemPriceLabel.hAlign = HAlign.RIGHT;
			_itemPriceLabel.touchable = false;
			_itemPriceLabel.autoScale = true;
			addChild(_itemPriceLabel);
			
			_background.addEventListener(TouchEvent.TOUCH, onTouch);
		}
		
		override protected function draw():void
		{
			var dataInvalid:Boolean = this.isInvalid(INVALIDATION_FLAG_DATA);
			var sizeInvalid:Boolean = this.isInvalid(INVALIDATION_FLAG_SIZE);
			
			if(dataInvalid)
			{
				this.commitData();
			}
			
			if(dataInvalid || sizeInvalid)
			{
				if(!_data) return;
				
				_background.width = MAX_ITEM_WIDTH;
				
				_iconBackground.x = (_iconBackground.width * 0.5) + 5;
				_iconBackground.y = (_iconBackground.height * 0.5) + 5;
				
				_itemIcon.validate();
				_itemIcon.alignPivot();
				_itemIcon.x = _iconBackground.x;
				_itemIcon.y = _iconBackground.y;
				
				// texts
				
				_itemNameLabel.x = _iconBackground.x + (_iconBackground.width * 0.5) + 5;
				_itemNameLabel.y = 5;
				_itemNameLabel.width = MAX_ITEM_WIDTH - _itemNameLabel.x - 8;
				
				_itemPriceLabel.x = _iconBackground.x + (_iconBackground.width * 0.5) + 5;
				_itemPriceLabel.y = actualHeight - _itemPriceLabel.height - 7;
				_itemPriceLabel.width = MAX_ITEM_WIDTH - _itemPriceLabel.x - (_basket.visible ? 30 : 8);
				
				_basket.x = (MAX_ITEM_WIDTH - 30); // 30 = largeur du basket icon
				_basket.y = actualHeight - _basket.height - 7;
				
				// icons
				
				_expandOrCollapseIcon.x = _iconBackground.x + _iconBackground.width * 0.35;
				_expandOrCollapseIcon.y = _iconBackground.y + _iconBackground.height * 0.34;
				
				_isNewIcon.x = 5;
				_isNewIcon.y = 5;
				
				_vipIconBackground.x = _iconBackground.x + (_iconBackground.width * 0.5) - _vipIconBackground.width;
				_vipIconBackground.y = _iconBackground.y + (_iconBackground.height * 0.5) - _vipIconBackground.height;
				
				// behaviors
				
				if( _data && _data.isExpanded && _data.behaviors.length > 0 )
				{
					_behaviorsList.y = actualHeight + 6;
					_behaviorsList.width = MAX_ITEM_WIDTH;
					_behaviorsList.validate();
					
					setSize(this.width, (actualHeight + 6 + _behaviorsList.height));
				}
				else
				{
					setSize(this.width, actualHeight);
				}
			}
		}

		/**
		 * Commits the data.
		 */
		protected function commitData():void
		{
			if(this._owner && _data)
			{
				// if this item has behaviors and at least one is owned, we automatically expand it
				//expandIfBehaviorSelected();
				
				// item price
				_itemPriceLabel.visible = !_data.isEmptyable;
				_itemPriceLabel.text = _data.hasBehaviors ? (_("+ de déclinaisons")) : (_data.isLocked ? _("Rang insuffisant") : (_data.isSelected ? (_data.isOwned ? _("Equipé") : (_data.price == 0 ? _("GRATUIT") : Utilities.splitThousands(_data.price))) : (_data.isOwned ? _("Acquis") : (_data.price == 0 ? _("GRATUIT") : Utilities.splitThousands(_data.price)))));
				_itemPriceLabel.color = _data.isLocked ? LOCKED_ITEM_COLOR : PRICE_ITEM_COLOR;
				
				_vipIconBackground.texture = _data.isLocked ? Theme["vip_locked_icon_rank_" + _data.rank] : _vipIconBackground.texture;
				_vipIconBackground.visible = _data.isLocked;
				
				// the new icon is displayed when it's a new item or when one of the behaviors is new
				_isNewIcon.visible = _data.isNew || _data.isNewVip;
				
				// check icon visibility
				_expandOrCollapseIcon.visible = _data.hasBehaviors;
				_expandOrCollapseIcon.texture = _data.isExpanded ? AvatarAssets.collapseTexture : AvatarAssets.expandTexture;
				
				if(_data.hasBehaviors) // there are behaviors to display
				{
					_basket.visible = false;
					
					_behaviorsList.addEventListener(LKAvatarMakerEventTypes.BEHAVIOR_SELECTED, onBehaviorSelected);
					_behaviorsList.visible = _data.isExpanded;
					_behaviorsList.dataProvider.removeAll();
					
					HELPER_FRAME_DATA = null;
					HELPER_SELECTED_FRAME_DATA = null;
					for (var i:int = 0; i < _data.behaviors.length; i++)
					{
						HELPER_FRAME_DATA = _data.behaviors[i];
						// select hte behavior if necessary
						HELPER_FRAME_DATA.isSelected = HELPER_FRAME_DATA.id == LudokadoBoneConfiguration(LKConfigManager.currentConfig[_data.armatureSectionType]).tempId;
						
						// if the isOwned filter is checked or if it's check but the user owns the item, we can add it to the list
						if( !ItemSelector.IS_OWNED_FILTER_SELECTED || (ItemSelector.IS_OWNED_FILTER_SELECTED && HELPER_FRAME_DATA.isOwned) )
							_behaviorsList.dataProvider.push(HELPER_FRAME_DATA);
						
						// if the behavior is selected, we save the selected frame data and use it to update the main data
						if( HELPER_FRAME_DATA.isSelected )
							HELPER_SELECTED_FRAME_DATA = HELPER_FRAME_DATA;
					}
					
					_data.isSelected = HELPER_SELECTED_FRAME_DATA ? true : false;
					// change the icon background texture
					_iconBackground.texture = HELPER_SELECTED_FRAME_DATA ? AvatarAssets.iconEquippedBackgroundTexture : AvatarAssets.iconBuyableBackgroundTexture;
					// update the item name color accordingly
					_itemNameLabel.color = HELPER_SELECTED_FRAME_DATA ? EQUIPPED_ITEM_COLOR : BUYABLE_ITEM_COLOR;
					// and the name (with de selected frame name in parethesis)
					_itemNameLabel.text = HELPER_SELECTED_FRAME_DATA ? (_data.name + " (" + HELPER_SELECTED_FRAME_DATA.name + ")") : _data.name;
					// update the main image source
					_itemIcon.source = HELPER_SELECTED_FRAME_DATA ? HELPER_SELECTED_FRAME_DATA.imageUrl : _data.behaviors[0].imageUrl;
				}
				else // else no behaviors
				{
					
					_basket.visible = (!_data.isEmptyable && (!_data.isOwned && !_data.isLocked && _data.price != 0));
					if( _basket.visible )
					{
						// the item is not owned and the renderer does not have behaviors to display, so we
						// can animate the basket here
						if( _data.isSelected ) _basket.animateInBasket( ItemSelector.hasChangedSection || owner.isScrolling );
						else _basket.animateOutBasket( ItemSelector.hasChangedSection || owner.isScrolling );
					}
					
					// change the icon background texture
					_iconBackground.texture = _data.isSelected ? AvatarAssets.iconEquippedBackgroundTexture : (_data.isOwned ? AvatarAssets.iconBoughtNotEquippedBackgroundTexture : AvatarAssets.iconBuyableBackgroundTexture);
					// update the item name color accordingly
					_itemNameLabel.color = _data.isSelected ? EQUIPPED_ITEM_COLOR : (_data.isOwned ? OWNED_ITEM_COLOR : BUYABLE_ITEM_COLOR);
					// and the name
					_itemNameLabel.text = _data.name;
					
					_itemIcon.source = _data.isEmptyable ? AvatarAssets.removeIconTexture : _data.imageUrl;
					
					_behaviorsList.removeEventListener(LKAvatarMakerEventTypes.BEHAVIOR_SELECTED, onBehaviorSelected);
					_behaviorsList.visible = false;
					if( _behaviorsList.dataProvider )
						_behaviorsList.dataProvider.removeAll();
				}
			}
		}

		/**
		 * When a behavior is selected within the sub-list
		 */
		private function onBehaviorSelected(event:Event):void
		{
			// save the frame data
			var selectedFrameData:AvatarFrameData = AvatarFrameData(event.data);
			
			// deselect all except the one we just selected
			var frameData:AvatarFrameData;
			for (var i:int = 0; i < _data.behaviors.length; i++)
			{
				frameData = _data.behaviors[i];
				frameData.isSelected = frameData.id == AvatarFrameData(event.data).id;
				_behaviorsList.dataProvider.updateItemAt(i);
			}
			
			// the configuration will be updated in the handler in the AvatarMakerScreen
			owner.dispatchEventWith(LKAvatarMakerEventTypes.ITEM_SELECTED, false, { itemData:_data, behaviorData:selectedFrameData });
		}
		
		
	    /**
	     * Expands the renderer, showing the behaviors list.
	     *
	     * This function is called only when a renderer has behaviors to display.
	     */
	    private function expand():void
	    {
		    setSize(this.width, (actualHeight + 6 + _behaviorsList.height));
	    }
	
	    /**
	     * Collapses the renderer, hiding the behaviors list.
	     *
	     * This function is called only when a renderer has behaviors to display.
	     */
	    private function collapse():void
	    {
		    setSize(this.width, actualHeight);
	    }
		
		/**
		 * Expands the renderer if there is at least one behavior selected.
		 */
		private function expandIfBehaviorSelected():void
		{
			for (var i:int = 0; i < _data.behaviors.length; i++)
			{
				if( AvatarFrameData(_data.behaviors[i]).isSelected )
				{
					_data.isSelected = true;
					_data.isExpanded = true;
					break;
				}
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Touch
		
		/**
		 * Touch handler.
		 */
		protected function onTouch(event:TouchEvent):void
		{
			var touch:Touch = event.getTouch(_background);
			if (touch == null)
			{
				state = ButtonState.UP;
			}
			else if (touch.phase == TouchPhase.HOVER)
			{
				state = ButtonState.OVER;
			}
			else if (touch.phase == TouchPhase.BEGAN && _currentTouchState != ButtonState.DOWN)
			{
				state = ButtonState.DOWN;
			}
			else if (touch.phase == TouchPhase.MOVED && _currentTouchState == ButtonState.DOWN)
			{
				// reset button when user dragged too far away after pushing
				var buttonRect:Rectangle = getBounds(stage);
				if (touch.globalX < buttonRect.x - MAX_DRAG_DIST || touch.globalY < buttonRect.y - MAX_DRAG_DIST ||
						touch.globalX > buttonRect.x + buttonRect.width + MAX_DRAG_DIST ||
						touch.globalY > buttonRect.y + buttonRect.height + MAX_DRAG_DIST)
				{
					state = ButtonState.UP;
				}
			}
			else if (touch.phase == TouchPhase.ENDED && _currentTouchState == ButtonState.DOWN)
			{
				onTriggered();
			}
		}
		
		/**
		 * Updates the current touch state.
		 */
		public function set state(value:String):void
		{
			_currentTouchState = value;
			
			switch (_currentTouchState)
			{
				case ButtonState.DOWN: { break; }
				case ButtonState.DISABLED: { break; }
				case ButtonState.UP:
				{
					_isOver = false;
					
					break;
				}
				case ButtonState.OVER:
				{
					if( _data.isSelected )
						return;
					
					_isOver = true;
					
					break;
				}
				default: { throw new ArgumentError("Invalid button state: " + _currentTouchState); }
			}
		}
		
		protected function onTriggered():void
		{
			if(_data.hasBehaviors)
			{
				// the item is touched and there are behaviors, in this case we need to expand / collapse the renderer
				_data.isExpanded = !_data.isExpanded;
				if(_data.isExpanded) expand();
				else collapse();
				commitData();
			}
			else
			{
				if(!_data.isSelected)
				{
					if( !_data.isEmptyable )
					{
						state = ButtonState.UP;
						_data.isSelected = !_data.isSelected;
					}
					owner.dispatchEventWith(LKAvatarMakerEventTypes.ITEM_SELECTED, false, { itemData:_data, behaviorData:null });
				}
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Image handlers
		
		/**
		 * The image have been loaded.
		 */
		private function onImageloaded(event:Event):void
		{
			//invalidate(INVALIDATION_FLAG_SIZE);
			if(_data.armatureSectionType == LudokadoBones.EYES_COLOR || _data.armatureSectionType == LudokadoBones.HAIR_COLOR
			|| _data.armatureSectionType == LudokadoBones.LIPS_COLOR || _data.armatureSectionType == LudokadoBones.SKIN_COLOR)
				_itemIcon.scaleX = _itemIcon.scaleY = 0.75;
			else if( _data.armatureSectionType == LudokadoBones.MOUSTACHE || _data.armatureSectionType == LudokadoBones.BEARD ||
					_data.armatureSectionType == LudokadoBones.EYEBROWS || _data.armatureSectionType == LudokadoBones.EYES ||
				_data.armatureSectionType == LudokadoBones.FACE_CUSTOM || _data.armatureSectionType == LudokadoBones.NOSE ||
					_data.armatureSectionType == LudokadoBones.AGE )
				_itemIcon.scaleX = _itemIcon.scaleY = 0.5;
			else
				_itemIcon.scaleX = _itemIcon.scaleY = 0.6;
			
			_itemIcon.validate();
			_itemIcon.alignPivot();
			_itemIcon.x = _iconBackground.x;
			_itemIcon.y = _iconBackground.y;
		}
		
		/**
		 * The image could not be loaded.
		 */
		private function onIOError(event:Event):void
		{
			_itemIcon.source = Theme["defaultIconForSection_" + _data.armatureSectionType];
		}
		
//------------------------------------------------------------------------------------------------------------
//	Get - Set
		
		/**
		 * Avatar item data. */
		protected var _data:AvatarItemData;

		override public function get data():Object
		{
			return this._data;
		}

		override public function set data(value:Object):void
		{
			if(this._data == value)
			{
				return;
			}
			this._data = AvatarItemData(value);
			this.invalidate(INVALIDATION_FLAG_DATA);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
		
		override public function dispose():void
		{
			_background.removeEventListener(TouchEvent.TOUCH, onTouch);
			
			_background.removeFromParent(true);
			_background = null;
			
			_iconBackground.removeFromParent(true);
			_iconBackground = null;
			
			_itemIcon.removeEventListener(FeathersEventType.ERROR, onIOError);
			_itemIcon.removeEventListener(Event.COMPLETE, onImageloaded);
			_itemIcon.removeFromParent(true);
			_itemIcon = null;
			
			_itemNameLabel.removeFromParent(true);
			_itemNameLabel = null;
			
			_itemPriceLabel.removeFromParent(true);
			_itemPriceLabel = null;
			
			_basket.removeFromParent(true);
			_basket = null;
			
			_expandOrCollapseIcon.removeFromParent(true);
			_expandOrCollapseIcon = null;
			
			_behaviorListBackground.removeFromParent(true);
			_behaviorListBackground = null;
			
			_isNewIcon.removeFromParent(true);
			_isNewIcon = null;
			
			// TODO cleaner la liste des behaviors proprement
			if(_behaviorsList)
			{
				_behaviorsList.removeEventListener(LKAvatarMakerEventTypes.BEHAVIOR_SELECTED, onBehaviorSelected);
			}
			
			_data = null;
			
			super.dispose();
		}
		
	}
}