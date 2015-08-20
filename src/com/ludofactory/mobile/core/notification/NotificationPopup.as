/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 2 déc. 2013
*/
package com.ludofactory.mobile.core.notification
{
	
	import com.greensock.TweenMax;
	import com.greensock.easing.ElasticOut;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.events.MobileEventTypes;
	import com.ludofactory.mobile.core.notification.content.AbstractPopupContent;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import feathers.core.FeathersControl;
	import feathers.display.Scale9Image;
	import feathers.display.TiledImage;
	
	import starling.display.Image;
	import starling.display.Quad;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	
	/**
	 * The pop up used to display a popup content.
	 */	
	public class NotificationPopup extends FeathersControl
	{
		
		/**
		 * Flag to indicate that we need to calculate the maximum content size. */
		public static const INVALIDATION_FLAG_MAXIMUM_CONTENT_SIZE:String = "maximum-content-size";
		
	// Elements
		
		/**
		 * The shadow thickness used to adjust the layout. */		
		private var _shadowThickness:Number;
		/**
		 * The close button height used to adjust the layout. */		
		private var _buttonAdjustment:Number;
		
		/**
		 * The background skin of the popup. */		
		private var _backgroundSkin:Scale9Image;
		/**
		 * The top left decoration displayed between the two backgrounds. */
		private var _topLeftDecoration:Image;
		/**
		 * The bottom left decoration displayed between the two backgrounds. */
		private var _bottomLeftDecoration:Image;
		/**
		 * The bottom middle decoration displayed between the two backgrounds. */
		private var _bottomMiddleDecoration:Image;
		/**
		 * The bottom right decoration displayed between the two backgrounds. */
		private var _bottomRightDecoration:Image;
		/**
		 * The front skin of the popup. */		
		private var _frontSkin:Scale9Image;
		/**
		 * The tiled background displayed behind the content. */
		private var _tiledBackground:TiledImage;

		/**
		 * A quad used as a button to close the popup. */
		private var _closeQuad:Quad;

		/**
		 * The content to display inside the popup. */
		private var _content:AbstractPopupContent;
		/**
		 * The callback to call when the popup is closed. */
		private var _callback:Function;
		
		public function NotificationPopup()
		{
			super();
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			_shadowThickness = scaleAndRoundToDpi(10);
			_buttonAdjustment = scaleAndRoundToDpi(23);
			
			_backgroundSkin = new Scale9Image(Theme.gameModeSelectionBackgroundTextures, GlobalConfig.dpiScale);
			_backgroundSkin.useSeparateBatch = false;
			addChild(_backgroundSkin);
			
			_topLeftDecoration = new Image(Theme.topLeftLeavesTexture);
			_topLeftDecoration.pivotX = _topLeftDecoration.width * 0.35;
			_topLeftDecoration.pivotY = _topLeftDecoration.height * 0.35;
			_topLeftDecoration.scaleX = _topLeftDecoration.scaleY = GlobalConfig.dpiScale;
			addChild(_topLeftDecoration);
			
			_bottomLeftDecoration = new Image(Theme.bottomLeftLeavesTexture);
			_bottomLeftDecoration.pivotX = _bottomLeftDecoration.width * 0.35;
			_bottomLeftDecoration.pivotY = _bottomLeftDecoration.height * 0.6;
			_bottomLeftDecoration.scaleX = _bottomLeftDecoration.scaleY = GlobalConfig.dpiScale;
			addChild(_bottomLeftDecoration);
			
			_bottomMiddleDecoration = new Image(Theme.bottomMiddleLeavesTexture);
			_bottomMiddleDecoration.pivotX = _bottomMiddleDecoration.width * 0.5;
			_bottomMiddleDecoration.pivotY = _bottomMiddleDecoration.height * 0.6;
			_bottomMiddleDecoration.scaleX = _bottomMiddleDecoration.scaleY = GlobalConfig.dpiScale;
			addChild(_bottomMiddleDecoration);
			
			_bottomRightDecoration = new Image(Theme.bottomRightLeavesTexture);
			_bottomRightDecoration.pivotX = _bottomRightDecoration.width * 0.6;
			_bottomRightDecoration.pivotY = _bottomRightDecoration.height * 0.6;
			_bottomRightDecoration.scaleX = _bottomRightDecoration.scaleY = GlobalConfig.dpiScale;
			addChild(_bottomRightDecoration);
			
			_frontSkin = new Scale9Image(Theme.gameModeSelectionFrontTextures, GlobalConfig.dpiScale);
			_frontSkin.useSeparateBatch = false;
			addChild(_frontSkin);
			
			_tiledBackground = new TiledImage(Theme.gameModeSelectionTileTexture, GlobalConfig.dpiScale);
			_tiledBackground.useSeparateBatch = false;
			addChild(_tiledBackground);
			
			_closeQuad = new Quad(scaleAndRoundToDpi(100), scaleAndRoundToDpi(100));
			_closeQuad.alpha = 0;
			_closeQuad.addEventListener(TouchEvent.TOUCH, onTouchCloseButton);
			addChild(_closeQuad);
			
			if( _content )
				addChild(_content);
		}
		
		override protected function draw():void
		{
			if(isInvalid(INVALIDATION_FLAG_SIZE))
			{
				_backgroundSkin.width = actualWidth;
				_backgroundSkin.height = actualHeight;

				_frontSkin.width = actualWidth * 0.98;
				_frontSkin.height = actualHeight * 0.98;
				_frontSkin.x = (actualWidth - _frontSkin.width) * 0.5 + _shadowThickness;
				_frontSkin.y = (actualHeight - _frontSkin.height) * 0.5 - _shadowThickness;

				_tiledBackground.width = _frontSkin.width * 0.85;
				_tiledBackground.height = _frontSkin.height * 0.85;
				_tiledBackground.x = (actualWidth - _tiledBackground.width) * 0.5;
				_tiledBackground.y = (actualHeight - _tiledBackground.height) * 0.5;

				_closeQuad.x = _backgroundSkin.width - _closeQuad.width;
				
				if(isInvalid(INVALIDATION_FLAG_MAXIMUM_CONTENT_SIZE))
				{
					// this is done once
					_maxContentHeight = _tiledBackground.height;
				}
				
				if(_content)
				{
					_content.width = _tiledBackground.width;
					_content.validate();
					if(_content.height > _maxContentHeight)
					{
						_content.height = _maxContentHeight;
					}
					else
					{
						// we reduce the size because the content is smaller
						_tiledBackground.height -= _maxContentHeight - _content.height;
						_frontSkin.height -= _maxContentHeight - _content.height;
						_backgroundSkin.height -= _maxContentHeight - _content.height;
					}
					_content.x = _tiledBackground.x;
					_content.y = _tiledBackground.y;
				}
				
				_topLeftDecoration.x = int(_frontSkin.x + _shadowThickness);
				_topLeftDecoration.y = int(_frontSkin.y + _shadowThickness + _buttonAdjustment);
				
				_bottomLeftDecoration.x = int(_frontSkin.x + _shadowThickness);
				_bottomLeftDecoration.y = int(_frontSkin.y + _frontSkin.height - _shadowThickness);
				
				_bottomMiddleDecoration.x = int(_frontSkin.x + _frontSkin.width * 0.5);
				_bottomMiddleDecoration.y = int(_frontSkin.y + _frontSkin.height - _shadowThickness);
				
				_bottomRightDecoration.x = int(_frontSkin.x + _frontSkin.width - _shadowThickness - _buttonAdjustment);
				_bottomRightDecoration.y = int(_frontSkin.y + _frontSkin.height - _shadowThickness);
			}
			
			super.draw();
		}
		
//------------------------------------------------------------------------------------------------------------
//	Animations

		/**
		 * Displays the popup.
		 */
		public function animateIn():void
		{
			this.touchable = true;
			
			if( _content )
			{
				_content.x = _tiledBackground.x;
				_content.y = _tiledBackground.y;
			}
			
			this.scaleX = this.scaleY = 1.2;
			TweenMax.to(this, 0.25, { autoAlpha:1 });
			TweenMax.to(this, 1, { scaleX:1, scaleY:1, ease:new ElasticOut(1, 0.6) });
		}

		/**
		 * Hides the popup, disposing its content.
		 */
		public function animateOut():void
		{
			this.touchable = false;
			TweenMax.to(this, 0.25, { autoAlpha:0, onComplete:removeAndDisposeContent });
		}

//------------------------------------------------------------------------------------------------------------
//	Handlers

		/**
		 * When the quad displayed above the cross is touched, we close the popup.
		 */
		private function onTouchCloseButton(event:TouchEvent):void
		{
			if( event.getTouch(_closeQuad, TouchPhase.ENDED) )
				close();
		}
		
		/**
		 * Called externally.
		 */
		public function close():void
		{
			if( _callback )
				_callback(_content.data);
			
			dispatchEventWith(MobileEventTypes.CLOSE_NOTIFICATION, false);
		}

		/**
		 * Removes and disposes the content of the popup. Called whenever the popup have been closed.
		 */
		private function removeAndDisposeContent():void
		{
			this.visible = false;
			this.alpha = 0;
			
			if( _content )
			{
				_content.removeFromParent(true);
				_content = null;

				_callback = null;
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Get / Set

		/**
		 * Sets the content to display and a callback on close.
		 * 
		 * @param value
		 * @param callback
		 */
		public function setContentAndCallBack(value:AbstractPopupContent, callback:Function = null):void
		{
			_content = value;
			_callback = callback;
			
			if( _content )
				addChild(_content);
			
			invalidate(INVALIDATION_FLAG_SIZE);
		}
		
		public function set backgroundSkin(val:Scale9Image):void { _backgroundSkin = val; }
		
		private var _maxContentHeight:Number;
		
		public function get offset():Number
		{
			// offset used to help centering the popup once validated in the NotificationPopupManager
			return _content.height > _maxContentHeight ? 0 : ((_maxContentHeight - _content.height) * 0.5);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
		
		override public function dispose():void
		{
			_backgroundSkin.removeFromParent(true);
			_backgroundSkin = null;
			
			_frontSkin.removeFromParent(true);
			_frontSkin = null;
			
			_tiledBackground.removeFromParent(true);
			_tiledBackground = null;
			
			_topLeftDecoration.removeFromParent(true);
			_topLeftDecoration = null;
			
			_bottomLeftDecoration.removeFromParent(true);
			_bottomLeftDecoration = null;
			
			_bottomMiddleDecoration.removeFromParent(true);
			_bottomMiddleDecoration = null;
			
			_bottomRightDecoration.removeFromParent(true);
			_bottomRightDecoration = null;
			
			super.dispose();
		}
		
	}
}