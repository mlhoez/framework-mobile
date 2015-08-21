/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 6 sept. 2013
*/
package com.ludofactory.mobile.core.controls
{
	import com.greensock.TweenMax;
	import com.ludofactory.mobile.core.events.MobileEventTypes;
	
	import flash.geom.Point;
	
	import feathers.controls.ImageLoader;
	import feathers.controls.ScrollContainer;
	
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.utils.deg2rad;
	
	/**
	 * An abstract Accordion element to use in an accordion list.
	 * 
	 * <p>This class is meant to be extended to implement a custom
	 * design and / or behavior.</p>
	 */	
	public class AbstractAccordionItem extends ScrollContainer
	{
		private static const HELPER_POINT:Point = new Point();
		private static const HELPER_TOUCHES_VECTOR:Vector.<Touch> = new <Touch>[];
		//private var _touchPointID:int = -1;

		/**
		 * Header height used to calculate the scroll position. */
		private var _headerHeight:int;
		
		/**
		 * The expand / collapse animation duration. */		
		protected var _expandOrCollapseDuration:Number = 0.25;
		
		/**
		 * Whether the panel is expanded. */		
		protected var _isExpanded:Boolean = false;
		
		/**
		 * Whether the panel is expanding. */		
		protected var _isExpanding:Boolean;
		
		/**
		 * Whether the content needs to resize. */		
		protected var needResize:Boolean = false;
		
		/**
		 * The clipped content container used to hide / show the content. */		
		protected var _contentContainer:ScrollContainer;
		
		/**
		 * The maximum container height. */		
		protected var _maxContainerHeight:Number;
		
		/**
		 * If the content have been draw at least once. */		
		protected var _initialized:Boolean = false;
		
		/**
		 * Whether it is the last element. */		
		protected var _isLast:Boolean = false;
		
		/**
		 * The arrow. */		
		protected var _arrow:ImageLoader;
		
		/**
		 * The item index in the accordion. */		
		protected var _index:int;
		
		private var _tempIndexHackForVips:int = 0;
		
		public function AbstractAccordionItem()
		{
			super();
		}
		
		/**
		 * When the user touches the header, we expand / collapse the content
		 * depending on the actual state of the component.
		 */		
		protected function expandOrCollapseContent(event:TouchEvent):void
		{
			const touches:Vector.<Touch> = event.getTouches(this, null, HELPER_TOUCHES_VECTOR);
			if(touches.length == 0)
			{
				return;
			}
			if(this._touchPointID >= 0)
			{
				var touch:Touch;
				for each(var currentTouch:Touch in touches)
				{
					if(currentTouch.id == this._touchPointID)
					{
						touch = currentTouch;
						break;
					}
				}
				if(!touch)
				{
					HELPER_TOUCHES_VECTOR.length = 0;
					return;
				}
				if(touch.phase == TouchPhase.ENDED)
				{
					this._touchPointID = -1;
					
					touch.getLocation(this, HELPER_POINT);
					if(this.hitTest(HELPER_POINT, true) != null )
					{
						//this.isSelected = true;
						if(!isExpanded) expand();
						else collapse();
					}
				}
			}
			else
			{
				
				for each(touch in touches)
				{
					if(touch.phase == TouchPhase.BEGAN)
					{
						this._touchPointID = touch.id;
						break;
					}
				}
			}
			HELPER_TOUCHES_VECTOR.length = 0;
		}
		
		public function resizeToContent():void
		{
			if(!_isExpanded || (_isExpanded && _isExpanding))
				return;
			needResize = true;
			invalidate(INVALIDATION_FLAG_SIZE);
		}
		
		public function onScroll(event:Event):void
		{
			_touchPointID = -1;
		}
		
		/**
		 * Expands the content in the given time.
		 */
		public function expand(duration:Number = NaN):void
		{
			if( isNaN(duration) )
				duration = _expandOrCollapseDuration;
			
			dispatchEventWith(MobileEventTypes.EXPAND_BEGIN);
			_contentContainer.visible = true;
			_isExpanding = true;
			
			TweenMax.to(_contentContainer, duration, { height:_maxContainerHeight, onComplete:function():void
			{
				_isExpanding = false;
				resizeToContent();
				dispatchEventWith(MobileEventTypes.EXPAND_COMPLETE);
			} });
			
			if( _arrow )
				_arrow.rotation = deg2rad(-180);
			
			_isExpanded = true;
		}
		
		/**
		 * Collapses the content in the given time.
		 */
		public function collapse(duration:Number = NaN):void
		{
			if(isNaN(duration))
				duration = _expandOrCollapseDuration;
			
			dispatchEventWith(MobileEventTypes.COLLAPSE_BEGIN);
			TweenMax.to(_contentContainer, duration, { height:0, onComplete:function():void
			{
				dispatchEventWith(MobileEventTypes.COLLAPSE_COMPLETE);
				_contentContainer.visible = false;
			} });
			
			if( _arrow )
				_arrow.rotation = deg2rad(0);
			
			TweenMax.delayedCall(0.45, function():void{ _contentContainer.visible = false; } ); // bug visuel sinon
			
			_isExpanded = false;
		}
		
		/**
		 * Indicates if the panel is expanded (true while expanding).
		 */		
		public function get isExpanded():Boolean
		{
			return _isExpanded;
		}
		
		/**
		 * Indicates if the panel is currently expanding.
		 */		
		public function get isExpanding():Boolean
		{
			return _isExpanding;
		}
		
		public function get isLast():Boolean
		{
			return _isLast;
		}
		
		public function set isLast(val:Boolean):void
		{
			_isLast = val;
		}
		
		public function set index(val:int):void
		{
			_index = val;
		}
		
		public function get index():int
		{
			return _index;
		}
		
		
		public function get tempIndexHackForVips():int
		{
			return _tempIndexHackForVips;
		}
		
		public function set tempIndexHackForVips(value:int):void
		{
			_tempIndexHackForVips = value;
		}
		
		//------------------------------------------------------------------------------------------------------------
//	Dispose
		
		override public function dispose():void
		{
			_arrow.removeFromParent(true);
			_arrow = null;
			
			_contentContainer.removeFromParent(true);
			_contentContainer = null;
			
			TweenMax.killTweensOf(_contentContainer);
			
			super.dispose();
		}

		public function get headerHeight():int
		{
			return _headerHeight;
		}

		public function set headerHeight(value:int):void
		{
			_headerHeight = value;
		}
	}
}