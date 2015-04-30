/*
Copyright © 2006-2015 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 16 sept. 2013
*/
package com.ludofactory.mobile.core.controls
{
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.events.LudoEventType;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import feathers.controls.GroupedList;
	import feathers.controls.renderers.IGroupedListHeaderOrFooterRenderer;
	import feathers.controls.supportClasses.GroupedListDataViewPort;
	import feathers.core.IFeathersControl;
	
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.display.MovieClip;
	import starling.display.Sprite;
	
	/**
	 * Auto refreshable Grouped List with "caching of headers" like the iOS
	 * cobtacts list.
	 * 
	 * <p>Simply allows a refresh of data while scrolling and a caching of the
	 * actual header so that it improves readability.</p>
	 */	
	public class CustomGroupedList extends GroupedList
	{
		/**
		 * Flag to indicate that the refreshable state have changed. */
		public static const INVALIDATION_FLAG_REFRESHABLE_STATE:String = "refreshable-state";
		
		/**
		 * Flag to indicate that the fake header should be redrawn. */
		public static const INVALIDATION_FLAG_FAKE_HEADER:String = "fake-header";
		
		/**
		 * Container used to clip the fake header. */		
		private var _fakeClipRectContainer:Sprite;
		
		/**
		 * The fake header displayed on top of the list. */		
		private var _fakeHeaderItemRenderer:IGroupedListHeaderOrFooterRenderer;
		
		/**
		 * The cached header height used to calculate when we should
		 * move the faker header. */		
		private var _headerHeight:Number = 0;
		
		/**
		 * The cached topmost header item renderer. */		
		private var _cachedHeaderItemRenderer:IGroupedListHeaderOrFooterRenderer;
		
		/**
		 * Whether the list is refreshable on top. */		
		private var _isRefreshableUp:Boolean = false;
		/**
		 * Whether the list is refreshing on top. */		
		private var _isRefreshingUp:Boolean = false;
		/**
		 * The top loader. */		
		private var _loaderUp:MovieClip;
		/**
		 * The calculated top offset. */		
		private var _offsetUp:int = 0;
		
		/**
		 * Whether the list is refreshable on bottom. */		
		private var _isRefreshableDown:Boolean = false;
		/**
		 * Whether the list is refreshing on bottom. */		
		private var _isRefreshingDown:Boolean = false;
		/**
		 * The down loader. */		
		private var _loaderDown:MovieClip;
		/**
		 * The calculated down offset. */		
		private var _offsetDown:int = 0;
		
		/**
		 * The global loader padding. */		
		private var _loaderPadding:int = 0;
		
		/**
		 * Save value of the old maximum vertical scroll position. */		
		private var _oldMaxVerticalScrollPosition:Number;
		/**
		 * Whether the list was refreshing top. */		
		private var _wasRefreshingTop:Boolean = false;
		
		public function CustomGroupedList()
		{
			super();
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			// because the fake item renderer needs to be moved to create the desired
			// effect, we need to clip its content
			_fakeClipRectContainer = new Sprite();
			addChild(_fakeClipRectContainer);
			
			// we need to create a fake header in the style of
			// the one defined for the list.
			if(this._headerRendererFactory != null)
			{
				_fakeHeaderItemRenderer = IGroupedListHeaderOrFooterRenderer(this._headerRendererFactory());
			}
			else
			{
				_fakeHeaderItemRenderer = new this._headerRendererType();
			}
			var uiRenderer:IFeathersControl = IFeathersControl(_fakeHeaderItemRenderer);
			if(this._customHeaderRendererStyleName && this._customHeaderRendererStyleName.length > 0)
			{
				uiRenderer.styleName = this._customHeaderRendererStyleName;
			}
			_fakeClipRectContainer.addChild(DisplayObject(_fakeHeaderItemRenderer));
			_fakeHeaderItemRenderer.visible = false;
			_fakeHeaderItemRenderer.owner = this;
		}
		
		/**
		 * Creates the loader used at the top of the list.
		 */		
		protected function createTopLoader():void
		{
			if( !_loaderUp )
			{
				_loaderUp = new MovieClip(Theme.blackLoaderTextures);
				Starling.juggler.add(_loaderUp);
				dataViewPort.addChild(_loaderUp);
				
				_loaderPadding = scaleAndRoundToDpi(40);
				_offsetUp = _loaderUp.height + _loaderPadding * 2;
			}
		}
		
		/**
		 * Clears the top loader.
		 */		
		protected function clearTopLoader():void
		{
			if( _loaderUp )
			{
				Starling.juggler.remove(_loaderUp);
				_loaderUp.removeFromParent(true);
				_loaderUp = null;
				
				_offsetUp = 0;
			}
		}
		
		/**
		 * Creates the loader used at the bottom of the list.
		 */		
		protected function createBottomLoader():void
		{
			if( !_loaderDown )
			{
				_loaderDown = new MovieClip(Theme.blackLoaderTextures);
				Starling.juggler.add(_loaderDown);
				dataViewPort.addChild(_loaderDown);
				
				_loaderPadding = scaleAndRoundToDpi(40);
				_offsetDown = _loaderDown.height + _loaderPadding * 2;
			}
		}
		
		/**
		 * Clears the bottom loader.
		 */		
		protected function clearBottomLoader():void
		{
			if( _loaderDown )
			{
				Starling.juggler.remove(_loaderDown);
				_loaderDown.removeFromParent(true);
				_loaderDown = null;
				
				_offsetDown = 0;
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Overrides
		
		override protected function draw():void
		{
			super.draw();
			
			if( isInvalid(INVALIDATION_FLAG_FAKE_HEADER) )
			{
				// position and clip the fake header
				_fakeHeaderItemRenderer.width = parent.width;;
				_fakeHeaderItemRenderer.validate();
				_fakeClipRectContainer.clipRect = _fakeHeaderItemRenderer.bounds;
				_headerHeight = _fakeHeaderItemRenderer.height;
			}
			
			if( isInvalid(INVALIDATION_FLAG_REFRESHABLE_STATE) )
			{
				if( _isRefreshableDown && _loaderDown )
				{
					_loaderDown.x = (this.actualWidth - _loaderDown.width) * 0.5;
					_loaderDown.y = dataViewPort.height + _loaderPadding;
				}
				
				if( _isRefreshableUp && _loaderUp )
				{
					_loaderUp.x = (this.actualWidth - _loaderUp.width) * 0.5;
					_loaderUp.y = -_loaderPadding - _loaderUp.height;
				}
			}
			
			if( _dataProvider )
			{
				if( (viewPort as GroupedListDataViewPort).activeHeaderRenderers.length == 0)
					return;
				
				// the cached header is the first visible header item renderer currently
				// displaying in the list. Note that its data will be null if the header
				// is currently visible (it will happen if there are lots of data between
				// two header, so in consequence, no header will be displaying so no data
				// available.
				_cachedHeaderItemRenderer = IGroupedListHeaderOrFooterRenderer((viewPort as GroupedListDataViewPort).activeHeaderRenderers[0]);
				
				// the fake header will be invisible only in one case : when the list
				// is scrolled down too much (so when the vertical scroll position is
				// less than 0
				_fakeHeaderItemRenderer.visible = _verticalScrollPosition >= 0;
				
				
				// If the data of the cached header is null, it means that we are displaying
				// large amout of data between two sections (headers), so the fake header's
				// data and position are already correct, so no need to enter this condition
				if( _cachedHeaderItemRenderer.data && _cachedHeaderItemRenderer.y <= (_verticalScrollPosition + _headerHeight) )
				{
					// if we get here, it means that the cached header's y position is above
					// the limit (whether because the list is scrolling up or down), so we
					// need to position the fake header accordingly : it will be right below
					// the cached header
					_fakeHeaderItemRenderer.y = _cachedHeaderItemRenderer.y - (_verticalScrollPosition + _headerHeight);
					
					// update the fake header's data
					_fakeHeaderItemRenderer.data = _dataProvider.data[ (_cachedHeaderItemRenderer.groupIndex - 1) < 0 ? 0 : (_cachedHeaderItemRenderer.groupIndex - 1) ]["header"];
					
					if( _fakeHeaderItemRenderer.y <= -_headerHeight )
					{
						// the fake header have reached the top of the list and isn't visible
						// anymore, it means that a new header have replaced its position so
						// we need to update its data and bring it back to the top
						_fakeHeaderItemRenderer.y = 0;
						_fakeHeaderItemRenderer.data = _cachedHeaderItemRenderer.data;
					}
				}
				else
				{
					// if we scroll too quickly, the fake header can be stuck at the wrong
					// position, so we always need to force the y position to 0 here
					_fakeHeaderItemRenderer.y = 0;
				}
				
				if( !_isRefreshingDown && _isRefreshableDown && _verticalScrollPosition >= (_maxVerticalScrollPosition - _offsetDown))
				{
					_isRefreshingDown = true;
					dispatchEventWith(LudoEventType.LIST_BOTTOM_UPDATE);
				}
				else if( !_isRefreshingUp && _isRefreshableUp && _verticalScrollPosition < 0 )
				{
					_isRefreshingUp = true;
					dispatchEventWith(LudoEventType.LIST_TOP_UPDATE);
				}
			}
		}
		
		override protected function refreshMinAndMaxScrollPositions():void
		{
			var visibleViewPortWidth:Number = this.actualWidth - (this._leftViewPortOffset + this._rightViewPortOffset);
			var visibleViewPortHeight:Number = this.actualHeight - (this._topViewPortOffset + this._bottomViewPortOffset);
			if(isNaN(this.explicitPageWidth))
			{
				this.actualPageWidth = visibleViewPortWidth;
			}
			if(isNaN(this.explicitPageHeight))
			{
				this.actualPageHeight = visibleViewPortHeight;
			}
			if(this._viewPort)
			{
				this._minHorizontalScrollPosition = this._viewPort.contentX;
				this._maxHorizontalScrollPosition = this._viewPort.width - visibleViewPortWidth;
				if(this._maxHorizontalScrollPosition < this._minHorizontalScrollPosition)
				{
					this._maxHorizontalScrollPosition = this._minHorizontalScrollPosition;
				}
				// if we don't update these values when we are refreshing either the top or the
				// bottom, in the updateVerticalScrollFromTouchPosition the offset will take in
				// account the elasticity, so the list will "jump" whereas we are just scrolling
				// a little bit
				this._minVerticalScrollPosition = this._viewPort.contentY - _offsetUp; // Ajout Max
				this._maxVerticalScrollPosition = this._viewPort.height - visibleViewPortHeight + _offsetDown; // Ajout Max
				if(this._maxVerticalScrollPosition < this._minVerticalScrollPosition)
				{
					this._maxVerticalScrollPosition =  this._minVerticalScrollPosition;
				}
				if(this._snapScrollPositionsToPixels)
				{
					this._minHorizontalScrollPosition = Math.round(this._minHorizontalScrollPosition);
					this._minVerticalScrollPosition = Math.round(this._minVerticalScrollPosition + _offsetUp); // Ajout Max
					this._maxHorizontalScrollPosition = Math.round(this._maxHorizontalScrollPosition);
					this._maxVerticalScrollPosition = Math.round(this._maxVerticalScrollPosition);
				}
			}
			else
			{
				this._minHorizontalScrollPosition = 0;
				this._minVerticalScrollPosition = 0;
				this._maxHorizontalScrollPosition = 0;
				this._maxVerticalScrollPosition = 0;
			}
		}
		
		override protected function refreshScrollValues():void
		{
			super.refreshScrollValues();
			
			// Ajout Max
			if( _wasRefreshingTop )
			{
				// because when we update the dataProvider and we add elements at
				// the top of the list the list will automatically be positioned
				// at the very top, we need to scroll down where it was before the
				// update.
				this.throwTo(NaN, _maxVerticalScrollPosition - _oldMaxVerticalScrollPosition, 0);
				_wasRefreshingTop = _isRefreshingUp = false;
			}
			// Fin ajout
		}
		
//------------------------------------------------------------------------------------------------------------
//	-
		
		/**
		 * Whether the list is refreshable on bottom.
		 */		
		public function set isRefreshableDown(val:Boolean):void
		{
			if( _isRefreshableDown == val )
				return;
			
			_isRefreshableDown = val;
			if( _isRefreshableDown )
				createBottomLoader();
			else
				clearBottomLoader();
			_isRefreshingDown = false;
			invalidate(INVALIDATION_FLAG_REFRESHABLE_STATE);
		}
		
		/**
		 * The bottom updated is complete.
		 */		
		public function onBottomAutoUpdateFinished():void
		{
			_isRefreshingDown = false;
		}
		
		/**
		 * Whether the list is refreshable on top.
		 */		
		public function set isRefreshableTop(val:Boolean):void
		{
			if( _isRefreshableUp == val )
				return;
			
			_isRefreshableUp = val;
			if( _isRefreshableUp )
				createTopLoader();
			else
				clearTopLoader();
			_isRefreshingUp = false;
			_wasRefreshingTop = false;
			invalidate(INVALIDATION_FLAG_REFRESHABLE_STATE);
		}
		
		/**
		 * When the top update in finshed, we need to save to old
		 * maximum vertical scroll position so that we can position
		 * the scroller back where it was before the update, otherwise
		 * it will automatically jump at the top and keep trigger an
		 * update top event.
		 */		
		public function onTopAutoUpdateFinished():void
		{
			_oldMaxVerticalScrollPosition = _maxVerticalScrollPosition;
			_wasRefreshingTop = _isRefreshableUp;
			invalidate(INVALIDATION_FLAG_SIZE);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
		
		override public function dispose():void
		{
			_cachedHeaderItemRenderer = null;
			
			_fakeHeaderItemRenderer.removeFromParent(true);
			_fakeHeaderItemRenderer = null;
			
			_fakeClipRectContainer.removeFromParent(true);
			_fakeClipRectContainer = null;
			
			clearBottomLoader();
			clearTopLoader();
			
			super.dispose();
		}
	}
}