/*
Copyright © 2006-2014 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 15 août 2013
*/
package com.ludofactory.mobile.core.controls
{
	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.events.LudoEventType;
	import com.ludofactory.mobile.core.test.config.GlobalConfig;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import flash.text.TextFormat;
	
	import feathers.controls.Label;
	import feathers.controls.List;
	
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.MovieClip;
	import starling.display.Sprite;
	import starling.utils.deg2rad;
	
	/**
	 * List with "pull to refresh" feature enabled like in iOS lists / containers.
	 * 
	 * See the history of this class to know ho to enable a "pull to refresh" at
	 * the bottom of the list (when it was removed : 10 Mars 2014).
	 */	
	public class PullToRefreshList extends List
	{
		/**
		 * Hack for Poedit:
		 * _("Tirer pour mettre à jour");
		 * _("Lâcher pour mettre à jour");
		 * _("Mise à jour...");
		 * _("Dernière mise à jour à");
		 * 
		 */		
		
		/**
		 * Flag to indicate that the refreshable state have changed. */
		public static const INVALIDATION_FLAG_REFRESHABLE_STATE:String = "refreshable-state";
		
		/**
		 * "Pull to refresh" default Localizer translation key. */		
		private static const DEFAULT_PULL_TO_REFRESH_KEY:String = "Tirer pour mettre à jour";
		/**
		 * "Release to refresh" default Localizer translation key. */		
		private static const DEFAULT_RELEASE_TO_REFRESH_KEY:String = "Lâcher pour mettre à jour";
		/**
		 * "Refreshing..." default Localizer translation key. */		
		private static const DEFAULT_REFRESHING_KEY:String = "Mise à jour...";
		/**
		 * "Last refresh : --/--/--" default Localizer translation key. */		
		private static const DEFAULT_LAST_REFRESH_KEY:String = "Dernière mise à jour à";
		
		/**
		 * "Pull to refresh" translated value. */		
		private static var PULL_TO_REFRESH_TEXT:String;
		/**
		 * "Release to refresh" translated value. */		
		private static var RELEASE_TO_REFRESH_TEXT:String;
		/**
		 * "Refreshing..." translated value. */		
		private static var REFRESHING_TEXT:String;
		/**
		 * "Last refresh : --/--/--" translated value. */		
		private static var LAST_REFRESH_TEXT:String;
		
		/**
		 * The top main container. */		
		private var _container:Sprite;
		/**
		 * The top message. */		
		private var _message:Label;
		/**
		 * The top last update message. */		
		private var _lastRefresh:Label;
		/**
		 * The top loader. */		
		private var _loader:MovieClip;
		/**
		 * The top arrow. */		
		private var _arrow:Image;
		/**
		 * The date used to indicate the last refresh time. */		
		private var _date:Date;
		
		/**
		 * Determines if the list can be pulled on top to refresh. */		
		private var _isRefreshable:Boolean = true;
		/**
		 * Indicates if the list is currently refreshing on top. */		
		private var _isRefreshing:Boolean;
		/**
		 * Whether the list was refreshing top. */		
		private var _wasRefreshing:Boolean = false;
		
		/**
		 * The top offset used to determine when the refresh
		 * should be triggered. */		
		private var _refreshOffset:int = 0;
		
		public function PullToRefreshList()
		{
			super();
			
			PULL_TO_REFRESH_TEXT = _(DEFAULT_PULL_TO_REFRESH_KEY);
			RELEASE_TO_REFRESH_TEXT = _(DEFAULT_RELEASE_TO_REFRESH_KEY);
			REFRESHING_TEXT = _(DEFAULT_REFRESHING_KEY);
			LAST_REFRESH_TEXT = _(DEFAULT_LAST_REFRESH_KEY);
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			if( _isRefreshable )
				createTopLoader();
		}
		
		override protected function draw():void
		{
			super.draw();
			
			if( _isRefreshable && isInvalid(INVALIDATION_FLAG_REFRESHABLE_STATE) )
			{
				const paddingRefresh:int = scaleAndRoundToDpi(40);
				
				_message.validate();
				
				_loader.x = _arrow.x = scaleAndRoundToDpi(20) + Math.max((_loader.width * 0.5), (_arrow.width * 0.5));
				
				_lastRefresh.validate();
				_lastRefresh.y = _loader.y = _arrow.y = _message.height;
				_lastRefresh.x = _message.x = _arrow.x + (_arrow.width * 0.5) + scaleAndRoundToDpi(20);
				_lastRefresh.width = _message.width = this.actualWidth * 0.75;
				
				_container.y = -_container.height - paddingRefresh;
				
				_refreshOffset = Math.abs(_container.y) + paddingRefresh;
			}
			
			if( _isRefreshable && !_isRefreshing )
			{
				if(_verticalScrollPosition <= -_refreshOffset)
				{
					// if we scrolled enough to trigger a refresh, we need to
					// update the current message
					_message.text = RELEASE_TO_REFRESH_TEXT;
					Starling.juggler.tween(_arrow, 0.25, { rotation:deg2rad(-180) });
				}
				else
				{
					// if we aren't scrolling enough to trigger a refresh, we
					// set the appropriate message
					_message.text = PULL_TO_REFRESH_TEXT;
					Starling.juggler.tween(_arrow, 0.25, { rotation:deg2rad(0) });
				}
			}
		}
		
		override protected function finishScrollingVertically():void
		{
			if( _isRefreshable && !_isRefreshing && this._verticalScrollPosition <= -_refreshOffset )
			{
				// finishScrollingVertically is triggered when we are scrolling
				// and then we release the finger, in this case, there is still
				// some scroll to finish.
				
				// here we are checking if there is enough scroll to trigger a
				// refresh
				
				_message.text = REFRESHING_TEXT;
				_arrow.visible = false;
				_loader.visible = _isRefreshing = true;
				
				dispatchEventWith(LudoEventType.REFRESH_TOP);
			}
			
			super.finishScrollingVertically();
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
				this._minVerticalScrollPosition = this._viewPort.contentY - (_isRefreshing ? _refreshOffset:0); // Ajout Max
				this._maxVerticalScrollPosition = this._viewPort.height - visibleViewPortHeight;
				if(this._maxVerticalScrollPosition < this._minVerticalScrollPosition)
				{
					this._maxVerticalScrollPosition =  this._minVerticalScrollPosition;
				}
				if(this._snapScrollPositionsToPixels)
				{
					this._minHorizontalScrollPosition = Math.round(this._minHorizontalScrollPosition);
					this._minVerticalScrollPosition = Math.round(this._minVerticalScrollPosition);
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
			if( _wasRefreshing )
			{
				// because when we update the dataProvider and we add elements at
				// the top of the list the list will automatically be positioned
				// at the very top, we need to scroll down where it was before the
				// update.
				this.throwTo(NaN, _minVerticalScrollPosition, 0.5);
				_wasRefreshing = _isRefreshing = false;
			}
			// Fin ajout
		}
		
		//------------------------------------------------------------------------------------------------------------
		//	-
		
		/**
		 * Whether the container is refreshable.
		 */		
		public function set isRefreshable(val:Boolean):void
		{
			if( _isRefreshable == val )
				return;
			
			_isRefreshable = val;
			if( _isRefreshable && _isInitialized )
				createTopLoader();
			else
				clearTopLoader();
			_isRefreshing = _wasRefreshing = false;
			invalidate(INVALIDATION_FLAG_REFRESHABLE_STATE);
		}
		
		/**
		 * When the update in complete, we replace the "last update"
		 * label.
		 */		
		public function onRefreshComplete():void
		{
			_wasRefreshing = _isRefreshable;
			_isRefreshing = _loader.visible = false;
			
			_arrow.visible = true;
			
			_date = new Date();
			_lastRefresh.text = LAST_REFRESH_TEXT + " " + _date.hours + ":" + _date.minutes;
			_date = null;
		}
		
		/**
		 * Creates the refresh elements.
		 */		
		protected function createTopLoader():void
		{
			if( !_container )
			{
				_date = new Date();
				
				_container = new Sprite();
				dataViewPort.addChild(_container);
				
				_message = new Label();
				_message.text = PULL_TO_REFRESH_TEXT;
				_container.addChild(_message);
				_message.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(20), Theme.COLOR_DARK_GREY);
				
				_lastRefresh = new Label();
				_lastRefresh.text = LAST_REFRESH_TEXT + " " + _date.hours + ":" + _date.minutes;
				_container.addChild(_lastRefresh);
				_lastRefresh.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(20), Theme.COLOR_LIGHT_GREY);
				
				_loader = new MovieClip(Theme.blackLoaderTextures);
				_loader.scaleX = _loader.scaleY = GlobalConfig.dpiScale;
				_loader.alignPivot();
				_loader.visible = false;
				_container.addChild(_loader);
				
				_arrow = new Image( AbstractEntryPoint.assets.getTexture("level-arrow-icon") );
				_arrow.scaleX = _arrow.scaleY = GlobalConfig.dpiScale;
				_arrow.alignPivot();
				_container.addChild(_arrow);
			}
		}
		
		/**
		 * Clears the refresh elements.
		 */		
		protected function clearTopLoader():void
		{
			if( _container )
			{
				Starling.juggler.remove(_loader);
				_loader.removeFromParent(true);
				_loader = null;
				
				_arrow.removeFromParent(true);
				_arrow = null;
				
				_message.removeFromParent(true);
				_message = null;
				
				_lastRefresh.removeFromParent(true);
				_lastRefresh = null;
				
				
				_container.removeFromParent(true);
				_container = null;
				
				_date = null;
			}
		}
		
		public function set pullToRefreshTextTop(val:String):void { PULL_TO_REFRESH_TEXT = val; }
		public function set releaseToRefreshTextTop(val:String):void { RELEASE_TO_REFRESH_TEXT = val; }
		public function set refreshingTextTop(val:String):void { REFRESHING_TEXT = val; }
		public function set lastRefreshTextTop(val:String):void { LAST_REFRESH_TEXT = val; }
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
		
		override public function dispose():void
		{
			clearTopLoader();
			
			super.dispose();
		}
		
	}
}