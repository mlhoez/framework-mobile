/*
 Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
 Framework mobile
 Author  : Maxime Lhoez
 Created : 2 déc. 2013
 */
package com.ludofactory.mobile.navigation.engine
{
	
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.notification.content.AbstractPopupContent;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import feathers.core.FeathersControl;
	
	import flash.geom.Rectangle;
	
	import starling.display.Image;
	
	/**
	 * The pop up used to display a popup content.
	 */
	public class EndScreenContainer extends FeathersControl
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
		private var _backgroundPopupSkin:Image;
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
		private var _frontSkin:Image;
		/**
		 * The tiled background displayed behind the content. */
		private var _tiledBackground:Image;

		/**
		 * The content to display inside the popup. */
		private var _content:AbstractPopupContent;
		/**
		 * The callback to call when the popup is closed. */
		private var _callback:Function;

		public function EndScreenContainer()
		{
			super();
		}

		override protected function initialize():void
		{
			super.initialize();

			_shadowThickness = scaleAndRoundToDpi(10);
			_buttonAdjustment = scaleAndRoundToDpi(23);

			_backgroundPopupSkin = new Image(AbstractEntryPoint.assets.getTexture("game-type-selection-background-skin"));
			_backgroundPopupSkin.scale = GlobalConfig.dpiScale;
			_backgroundPopupSkin.scale9Grid = new Rectangle(30, 30, 20, 20);
			addChild(_backgroundPopupSkin);

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

			_frontSkin = new Image(AbstractEntryPoint.assets.getTexture("game-type-selection-front-skin"));
			_frontSkin.scale = GlobalConfig.dpiScale;
			_frontSkin.scale9Grid = new Rectangle(38, 72, 19, 13);
			addChild(_frontSkin);

			_tiledBackground = new Image(AbstractEntryPoint.assets.getTexture("game-type-selection-tile"));
			_tiledBackground.scale = GlobalConfig.dpiScale;
			_tiledBackground.tileGrid = new Rectangle();;
			addChild(_tiledBackground);

			if( _content )
				addChild(_content);
		}


		public var _ww:Number = 0;
		public var _hh:Number = 0;

		override protected function draw():void
		{
			//if(isInvalid(INVALIDATION_FLAG_SIZE))
			//{
			
			if(_ww == 0 || _hh == 0)
			{
				_ww = actualWidth;
				_hh = actualHeight;
				/*TweenMax.to(this, 5, { _ww:(actualWidth * 0.8), _hh:(actualHeight * 0.8), onUpdate:draw});
				_backgroundPopupSkin.x = (actualWidth - (actualWidth * 0.8)) * 0.5;
				_backgroundPopupSkin.y = (actualHeight - (actualHeight * 0.8)) * 0.5;*/
			}

			_backgroundPopupSkin.width = actualWidth;
			_backgroundPopupSkin.height = actualHeight;

			_frontSkin.width = actualWidth * 0.99;
			_frontSkin.height = actualHeight * 0.99;
			_frontSkin.x = _backgroundPopupSkin.x + (actualWidth - _frontSkin.width) * 0.5 + _shadowThickness;
			_frontSkin.y = _backgroundPopupSkin.y + (actualHeight - _frontSkin.height) * 0.5 - _shadowThickness;

			_tiledBackground.width = _frontSkin.width - scaleAndRoundToDpi(100); // -50 on each side
			_tiledBackground.height = _frontSkin.height - scaleAndRoundToDpi(100); // -50 on each side
			_tiledBackground.x = _backgroundPopupSkin.x + (actualWidth - _tiledBackground.width) * 0.5;
			_tiledBackground.y = _backgroundPopupSkin.y + (actualHeight - _tiledBackground.height) * 0.5;

			/*if(isInvalid(INVALIDATION_FLAG_MAXIMUM_CONTENT_SIZE))
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
					_backgroundPopupSkin.height -= _maxContentHeight - _content.height;
				}
				_content.x = _tiledBackground.x;
				_content.y = _tiledBackground.y;
			}*/

			_topLeftDecoration.x = int(_frontSkin.x + _shadowThickness);
			_topLeftDecoration.y = int(_frontSkin.y + _shadowThickness + _buttonAdjustment);

			_bottomLeftDecoration.x = int(_frontSkin.x + _shadowThickness);
			_bottomLeftDecoration.y = int(_frontSkin.y + _frontSkin.height - _shadowThickness);

			_bottomMiddleDecoration.x = int(_frontSkin.x + _frontSkin.width * 0.5);
			_bottomMiddleDecoration.y = int(_frontSkin.y + _frontSkin.height - _shadowThickness);

			_bottomRightDecoration.x = int(_frontSkin.x + _frontSkin.width - _shadowThickness - _buttonAdjustment);
			_bottomRightDecoration.y = int(_frontSkin.y + _frontSkin.height - _shadowThickness);
			//}

			super.draw();
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose

		override public function dispose():void
		{
			_backgroundPopupSkin.removeFromParent(true);
			_backgroundPopupSkin = null;

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