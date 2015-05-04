/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 2 déc. 2013
*/
package com.ludofactory.mobile.core.notification
{
	
	import com.greensock.TweenMax;
	import com.greensock.easing.Back;
	import com.greensock.easing.Elastic;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.events.LudoEventType;
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
		
	// Saved positions of the decorations
		
		private var _topLeftLeavesSaveX:Number;
		private var _topLeftLeavesSaveY:Number;
		private var _bottomLeftLeavesSaveX:Number;
		private var _bottomLeftLeavesSaveY:Number;
		private var _bottomMiddleLeavesSaveY:Number;
		private var _bottomRightLeavesSaveX:Number;
		private var _bottomRightLeavesSaveY:Number;
		
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
		 * Offset used to move the leaves. */		
		private var _offset:int;

		/**
		 * The content to display inside the popup. */
		private var _content:AbstractNotificationPopupContent;
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
			
			_offset = scaleAndRoundToDpi(50);
			
			if( _content )
				addChild(_content);
		}
		
		override protected function draw():void
		{
			super.draw();
			
			var sizeInvalid:Boolean = this.isInvalid(INVALIDATION_FLAG_SIZE);
			
			if(sizeInvalid)
			{
				// TODO quand on passe ici ppur la première fois, c'est que la popup vient de s'initialiser
				// alors on peut calculer la hauteur maximal que le contenu de la popup peut avoir, et ainsi
				// adapter la popup en fonction
				
				// tiledBackground = frontSkin.height * 0.8 donc le front skin et 0.2 fois plus grand que le
				// tiledBackground (qui a la même taille que le contenu), donc on peut facilement calculer la
				// taille de la popup si le contenu est trop petit en hauteur
				
				var halfWidth:Number;
				var halfHeight:Number;

				_backgroundSkin.width = actualWidth;
				_backgroundSkin.height = actualHeight;
				_backgroundSkin.alignPivot();
				_backgroundSkin.x = actualWidth * 0.5;
				_backgroundSkin.y = actualHeight * 0.5;

				_frontSkin.width = actualWidth * 0.98;
				_frontSkin.height = actualHeight * 0.98;
				_frontSkin.alignPivot();
				_frontSkin.x = actualWidth * 0.5 + _shadowThickness;
				_frontSkin.y = actualHeight * 0.5 - _shadowThickness;

				_tiledBackground.width = _frontSkin.width * 0.9;
				_tiledBackground.height = _frontSkin.height * 0.9;
				_tiledBackground.alignPivot();
				_tiledBackground.x = actualWidth  * 0.5;
				_tiledBackground.y = actualHeight * 0.5;

				halfWidth = _frontSkin.width * 0.5;
				halfHeight = _frontSkin.height * 0.5;

				_topLeftLeavesSaveX = _topLeftDecoration.x = int(_frontSkin.x + _shadowThickness - halfWidth + _offset);
				_topLeftLeavesSaveY = _topLeftDecoration.y = int(_frontSkin.y + _shadowThickness + _buttonAdjustment - halfHeight + _offset);

				_bottomLeftLeavesSaveX = _bottomLeftDecoration.x = int(_frontSkin.x + _shadowThickness - halfWidth + _offset);
				_bottomLeftLeavesSaveY = _bottomLeftDecoration.y = int(_frontSkin.y - _shadowThickness + halfHeight - _offset);

				_bottomMiddleDecoration.x = int(_frontSkin.x);
				_bottomMiddleLeavesSaveY = _bottomMiddleDecoration.y = int(_frontSkin.y + halfHeight - _offset);

				_bottomRightLeavesSaveX = _bottomRightDecoration.x = int(_frontSkin.x - _shadowThickness - _buttonAdjustment + halfWidth - _offset);
				_bottomRightLeavesSaveY = _bottomRightDecoration.y = int(_frontSkin.y - _shadowThickness + halfHeight - _offset);

				_closeQuad.x = _backgroundSkin.width - _closeQuad.width;

				_backgroundSkin.scaleX = _backgroundSkin.scaleY = 0;
				_frontSkin.scaleX = _frontSkin.scaleY = 0;
				_tiledBackground.scaleX = _tiledBackground.scaleY = 0;
				_topLeftDecoration.alpha = 0;
				_bottomLeftDecoration.alpha = 0;
				_bottomMiddleDecoration.alpha = 0;
				_bottomRightDecoration.alpha = 0;
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Animations

		/**
		 * Displays the popup.
		 */
		public function animateIn():void
		{
			this.touchable = true;
			this.visible = true;
			this.alpha = 1;
			
			// just in case, kill the previous tweens
			TweenMax.killTweensOf([_backgroundSkin, _frontSkin, _tiledBackground, _topLeftDecoration, _bottomLeftDecoration, _bottomMiddleDecoration, _bottomRightDecoration]);
			
			_offset *= -1;
			
			TweenMax.allTo([_backgroundSkin, _frontSkin, _tiledBackground], 0.5, { scaleX:1, scaleY:1, ease:Back.easeOut });
			if( _content )
			{
				_content.scaleX = _content.scaleY = 0;
				_content.x = _tiledBackground.x;
				_content.y = _tiledBackground.y;
				TweenMax.to(_content, 0.5, { scaleX:1, scaleY:1, ease:Back.easeOut });
			}
			
			TweenMax.to(_topLeftDecoration,       1.25, { delay:0.4, alpha:1, x:(_topLeftLeavesSaveX + _offset), y:(_topLeftLeavesSaveY + _offset), ease:Elastic.easeOut });
			TweenMax.to(_bottomLeftDecoration,    1.25, { delay:0.4, alpha:1, x:(_bottomLeftLeavesSaveX + _offset), y:(_bottomLeftLeavesSaveY - _offset), ease:Elastic.easeOut });
			TweenMax.to(_bottomMiddleDecoration,  1.25, { delay:0.4, alpha:1, y:(_bottomMiddleLeavesSaveY - _offset), ease:Elastic.easeOut });
			TweenMax.to(_bottomRightDecoration,   1.25, { delay:0.4, alpha:1, x:(_bottomRightLeavesSaveX - _offset), y:(_bottomRightLeavesSaveY - _offset), ease:Elastic.easeOut });
		}

		/**
		 * Hides the popup, disposing its content.
		 */
		public function animateOut():void
		{
			this.touchable = false;
			
			TweenMax.killTweensOf([_backgroundSkin, _frontSkin, _tiledBackground, _topLeftDecoration, _bottomLeftDecoration, _bottomMiddleDecoration, _bottomRightDecoration]);
			
			_offset *= -1;
			
			TweenMax.allTo([_backgroundSkin, _frontSkin, _tiledBackground], 0.25, { scaleX:0, scaleY:0, ease:Back.easeIn, onComplete:removeAndDisposeContent });
			if( _content )
				TweenMax.to(_content, 0.25, { scaleX:0, scaleY:0, ease:Back.easeIn });
			
			TweenMax.to(_topLeftDecoration,       0.25, { alpha:0, x:(_topLeftLeavesSaveX + _offset), y:(_topLeftLeavesSaveY + _offset), ease:Back.easeIn });
			TweenMax.to(_bottomLeftDecoration,    0.25, { alpha:0, x:(_bottomLeftDecoration.x + _offset), y:(_bottomLeftLeavesSaveY - _offset), ease:Back.easeIn });
			TweenMax.to(_bottomMiddleDecoration,  0.25, { alpha:0, y:(_bottomMiddleLeavesSaveY - _offset), ease:Back.easeIn });
			TweenMax.to(_bottomRightDecoration,   0.25, { alpha:0, x:(_bottomRightLeavesSaveX - _offset), y:(_bottomRightLeavesSaveY - _offset), ease:Back.easeIn });
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
				_callback(_content.data); // TODO rajouter la data
			
			dispatchEventWith(LudoEventType.CLOSE_NOTIFICATION, false);
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
		public function setContentAndCallBack(value:AbstractNotificationPopupContent, callback:Function = null):void
		{
			_content = value;
			_callback = callback;
			
			if( _content )
			{
				addChild(_content);
				
				validate(); // otherwise the reported _frontSkin.width/height is wrong
				
				_content.width = _frontSkin.width * 0.9;
				_content.height = _frontSkin.height * 0.85;
				_content.alignPivot();
				_content.validate();
				
				// TODO trouver une façon d'afficher des flèches dans le conteneur
				//if( _content.height < _content.viewPort.height )
				//	log("[NotificationPopup] ScrollContainer should display arrows !")
			}
		}
		
		public function set backgroundSkin(val:Scale9Image):void { _backgroundSkin = val; }
		
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