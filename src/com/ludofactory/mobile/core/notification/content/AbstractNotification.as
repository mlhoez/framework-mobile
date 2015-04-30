/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 20 août 2013
*/
package com.ludofactory.mobile.core.notification.content
{
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.controls.PullToRefreshScrollContainer;
	import com.ludofactory.mobile.core.events.LudoEventType;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	
	import feathers.controls.ScrollContainer;
	import feathers.controls.Scroller;
	import feathers.display.Scale3Image;
	import feathers.display.Scale9Image;
	
	import starling.display.Button;
	import starling.display.Quad;
	import starling.events.Event;
	import starling.utils.HAlign;
	import starling.utils.VAlign;
	
	/**
	 * Parent class for notifications.
	 * 
	 * <p>This class contains a refreshable scroll container (turned off by default)
	 * which will host all the content. When the notification's content is initialized,
	 * the container is validated and the notification will be drawn depending on the
	 * container size. The maximum height of the notification is 95% of the screen,
	 * allowing a more easy way to close it by touching the black overlay.</p>
	 */	
	public class AbstractNotification extends ScrollContainer
	{
		// TODO A mettre dans l'initialiseur du thème ?
		protected var padSide:Number;
		protected var padSideDeco:Number;
		protected var padTopDeco:Number;
		protected var padTopBackgroundSkinou:Number;
		
		/**
		 * The main container */		
		protected var _container:PullToRefreshScrollContainer;
		
		/**
		 * The notification's background skin */		
		protected var _backgroundSkinou:Scale9Image;
		
		/**
		 * The background gradient */		
		protected var _backgroundGradient:Quad;
		
		/**
		 * The close button */		
		protected var _closeButton:Button;
		
		/**
		 * The top left decoration */		
		protected var _topLeftDecoration:Scale3Image;
		
		/**
		 * The top right decoration */		
		protected var _topRightDecoration:Scale3Image;
		
		/**
		 * The bottom left decoration */		
		protected var _bottomLeftDecoration:Scale3Image;
		
		/**
		 * The bottom right decoration */		
		protected var _bottomRightDecoration:Scale3Image;
		
		/**
		 * The maximum height of the main container. */		
		protected var maximumContainerHeight:int;
		
		/**
		 * The data used when the close event is dispatched. */		
		protected var _data:Object;
		
		public function AbstractNotification()
		{
			super();
			
			padSide = scaleAndRoundToDpi(12);
			padSideDeco = scaleAndRoundToDpi(16);
			padTopBackgroundSkinou = scaleAndRoundToDpi(47.5);
			padTopDeco = scaleAndRoundToDpi(75);
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			//this.layout = new AnchorLayout();
			//this.layoutData = new AnchorLayoutData(0,0,0,0,0,0);
			
			addChild(_backgroundSkinou);
			
			_backgroundGradient = new Quad(50, 50, 0xffffff);
			_backgroundGradient.setVertexColor(0, 0xffffff);
			_backgroundGradient.setVertexColor(1, 0xffffff);
			_backgroundGradient.setVertexColor(2, 0xdfdfdf);
			_backgroundGradient.setVertexColor(3, 0xdfdfdf);
			addChild(_backgroundGradient);
			
			_container = new PullToRefreshScrollContainer();
			_container.horizontalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			_container.verticalScrollPolicy = Scroller.SCROLL_POLICY_AUTO;
			_container.scrollBarDisplayMode = Scroller.SCROLL_BAR_DISPLAY_MODE_FLOAT;
			_container.isRefreshable = false;
			addChild(_container);
			
			_topLeftDecoration.touchable = false;
			addChild(_topLeftDecoration);
			
			_topRightDecoration.touchable = false;
			addChild(_topRightDecoration);
			
			_bottomLeftDecoration.touchable = false;
			addChild(_bottomLeftDecoration);
			
			_bottomRightDecoration.touchable = false;
			addChild(_bottomRightDecoration);
			
			_topLeftDecoration.color = _topRightDecoration.color = _bottomLeftDecoration.color = _bottomRightDecoration.color = 0xe9e9e9;
			
			_closeButton = new Button( AbstractEntryPoint.assets.getTexture("notification-close-button-up-skin"), "", AbstractEntryPoint.assets.getTexture("notification-close-button-down-skin") );
			_closeButton.scaleX = _closeButton.scaleY = GlobalConfig.dpiScale;
			_closeButton.addEventListener(Event.TRIGGERED, onCloseButtonTouched);
			_closeButton.alignPivot(HAlign.CENTER, VAlign.TOP);
			addChild(_closeButton);
			
			maximumContainerHeight = (GlobalConfig.stageHeight * 0.95) - (padTopDeco + _topLeftDecoration.height + scaleAndRoundToDpi(10) + _bottomLeftDecoration.height + scaleAndRoundToDpi(10));
		}
		
		override protected function draw():void
		{
			super.draw();
			
			_closeButton.x = this.actualWidth * 0.5;
			
			_topLeftDecoration.width = _topRightDecoration.width = _closeButton.x - padSideDeco - (_closeButton.width * 0.35);
			_topRightDecoration.alignPivot(HAlign.RIGHT, VAlign.TOP);
			_topRightDecoration.scaleX = -1;
			_topLeftDecoration.y = _topRightDecoration.y = padTopDeco;
			_topLeftDecoration.x = padSideDeco;
			_topRightDecoration.x = (this.actualWidth - padSideDeco - _topRightDecoration.width) << 0;
			
			_container.validate();
			if( _container.height > maximumContainerHeight )
				_container.height = maximumContainerHeight;
			_container.y = _topLeftDecoration.y + _topLeftDecoration.height + scaleAndRoundToDpi(10);
			
			_bottomLeftDecoration.width = _bottomRightDecoration.width = (this.actualWidth * 0.5) - padSideDeco * 2;
			_bottomRightDecoration.alignPivot(HAlign.RIGHT, VAlign.TOP);
			_bottomRightDecoration.scaleX = -1;
			_bottomLeftDecoration.y = _bottomRightDecoration.y = _container.y + _container.height + scaleAndRoundToDpi(10);
			_bottomLeftDecoration.x = padSideDeco;
			_bottomRightDecoration.x = this.actualWidth - padSideDeco - _bottomRightDecoration.width;
			
			_backgroundSkinou.width = this.actualWidth;
			_backgroundSkinou.y = padTopBackgroundSkinou;
			_backgroundSkinou.height = _container.height + _container.y - padTopBackgroundSkinou + scaleAndRoundToDpi(20) + _bottomLeftDecoration.height;
			
			_backgroundGradient.width = this.actualWidth - padSide * 2;
			_backgroundGradient.x = padSide;
			_backgroundGradient.y = _container.y;
			_backgroundGradient.height = _backgroundSkinou.height + _backgroundSkinou.y - _backgroundGradient.y;
			
			setSize(this.actualWidth, _backgroundSkinou.height + _backgroundSkinou.y);
		}
		
		/**
		 * The close button was touched, lets close the notification.
		 */		
		private function onCloseButtonTouched(event:Event):void
		{
			onClose();
		}
		
		/**
		 * Close the notification.
		 */		
		public function onClose():void
		{
			dispatchEventWith(LudoEventType.CLOSE_NOTIFICATION, false, _data);
		}
		
		override public function dispose():void
		{
			_closeButton.removeEventListener(Event.TRIGGERED, onCloseButtonTouched);
			_closeButton.removeFromParent(true);
			_closeButton = null;
			
			_bottomLeftDecoration.removeFromParent(true);
			_bottomLeftDecoration = null;
			
			_bottomRightDecoration.removeFromParent(true);
			_bottomRightDecoration = null;
			
			_topLeftDecoration.removeFromParent(true);
			_topLeftDecoration = null;
			
			_topRightDecoration.removeFromParent(true);
			_topRightDecoration = null;
			
			_backgroundGradient.removeFromParent(true);
			_backgroundGradient = null;
			
			_backgroundSkinou.removeFromParent(true);
			_backgroundSkinou = null;
			
			_container.removeFromParent(true);
			_container = null;
			
			_data = null;
			
			super.dispose();
		}
		
		public function get backgroundSkinou():Scale9Image { return _backgroundSkinou; }
		public function set backgroundSkinou(val:Scale9Image):void { _backgroundSkinou = val; }
		
		public function set topLeftDecoration(val:Scale3Image):void { _topLeftDecoration = val; }
		public function get topLeftDecoration():Scale3Image { return _topLeftDecoration; }
		
		public function set topRightDecoration(val:Scale3Image):void { _topRightDecoration = val; }
		public function get topRightDecoration():Scale3Image { return _topRightDecoration; }
		
		public function set bottomLeftDecoration(val:Scale3Image):void { _bottomLeftDecoration = val; }
		public function get bottomLeftDecoration():Scale3Image { return _bottomLeftDecoration; }
		
		public function set bottomRightDecoration(val:Scale3Image):void { _bottomRightDecoration = val; }
		public function get bottomRightDecoration():Scale3Image { return _bottomRightDecoration; }
	}
}