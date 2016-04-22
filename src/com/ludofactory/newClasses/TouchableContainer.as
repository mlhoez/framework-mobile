/**
 * Created by Maxime on 22/04/2016.
 */
package com.ludofactory.newClasses
{
	
	import com.greensock.TweenMax;
	import com.greensock.easing.Back;
	import com.ludofactory.common.utils.logs.log;
	
	import flash.geom.Rectangle;
	
	import starling.animation.Transitions;
	
	import starling.core.Starling;
	
	import starling.display.ButtonState;
	import starling.display.DisplayObjectContainer;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	
	public class TouchableContainer extends DisplayObjectContainer
	{
		/**
		 * Maximum drag distance to count the touch events. */
		private static const MAX_DRAG_DIST:Number = 50;
		
		/**
		 * Whether the container is enabled. */
		private var _enabled:Boolean = true;
		/**
		 * Container state. */
		private var _state:String;
		/**
		 * Scale value whenever the user touches the container. */
		private var _scaleWhenDown:Number = 0.9;
		/**
		 * Alpha value used when the button is disabled. */
		private var _alphaWhenDisabled:Number = 0.5;
		/**
		 * Trigger bounds. */
		private var _triggerBounds:Rectangle = new Rectangle();
		
		public function TouchableContainer()
		{
			super();
			
			addEventListener(TouchEvent.TOUCH, onTouch);
			
			this.touchGroup = true;
		}
		
//------------------------------------------------------------------------------------------------------------
//	Handlers
		
		/**
		 * Main touch event handler.
		 * 
		 * @param event
		 */
		private function onTouch(event:TouchEvent):void
		{
			var touch:Touch = event.getTouch(this);
			var isWithinBounds:Boolean;
			
			if (!_enabled)
			{
				return;
			}
			else if (touch == null)
			{
				state = ButtonState.UP;
			}
			else if (touch.phase == TouchPhase.HOVER)
			{
				// TODO enable this if we need "hover" handling
				// we don't need it on mobile devices so let's ignore it for performances
				//state = ButtonState.OVER;
			}
			else if (touch.phase == TouchPhase.BEGAN && _state != ButtonState.DOWN)
			{
				_triggerBounds = getBounds(stage, _triggerBounds);
				_triggerBounds.inflate(MAX_DRAG_DIST, MAX_DRAG_DIST);
				
				state = ButtonState.DOWN;
			}
			else if (touch.phase == TouchPhase.MOVED)
			{
				isWithinBounds = _triggerBounds.contains(touch.globalX, touch.globalY);
				
				if (_state == ButtonState.DOWN && !isWithinBounds)
				{
					// reset button when finger is moved too far away ...
					state = ButtonState.UP;
				}
				else if (_state == ButtonState.UP && isWithinBounds)
				{
					// ... and reactivate when the finger moves back into the bounds.
					state = ButtonState.DOWN;
				}
			}
			else if (touch.phase == TouchPhase.ENDED && _state == ButtonState.DOWN)
			{
				state = ButtonState.UP;
				if (!touch.cancelled) onTriggered();
			}
		}
		
		/**
		 * Public so that a manual trigger can be made.
		 */
		public function onTriggered():void
		{
			// meant to be overridden in subclass but DON'T forget to call super.onTriggered if listening
			// to the TRIGGERED event on the button somewhere in the app
			dispatchEventWith(Event.TRIGGERED, true);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Get - Set
		
		/**
		 * The current state of the button. The corresponding strings are found
		 * in the ButtonState class. */
		public function get state():String { return _state; }
		public function set state(value:String):void
		{
			
			_state = value;
			// Max : added so that we can animate the button with tweens
			//TweenMax.killTweensOf(this);
			Starling.juggler.removeTweens(this);
			/* Max : commented because I animated it in the up state
				this.x = this.y = 0;
				this.scaleX = this.scaleY = this.alpha = 1.0;
			 */
			
			switch (_state)
			{
				case ButtonState.DOWN:
				{
					this.scaleX = this.scaleY = _scaleWhenDown;
					this.x = (1.0 - _scaleWhenDown) / 2.0 * this.width;
					this.y = (1.0 - _scaleWhenDown) / 2.0 * this.height;
					
					break;
				}
				case ButtonState.UP:
				{
					// Max : added to animate the up state and make it more alive
					//TweenMax.to(this, 0.25, { x:0, y:0, scaleX:1.0, scaleY:1.0, alpha:1.0, ease:Back.easeOut });
					Starling.juggler.tween(this, 0.25, { x:0, y:0, scaleX:1.0, scaleY:1.0, alpha:1.0, transition:Transitions.EASE_OUT_BACK });
					break;
				}
				case ButtonState.OVER:
				{
					// nothing to do
					break;
				}
				case ButtonState.DISABLED:
				{
					this.alpha = _alphaWhenDisabled;
					
					break;
				}
				default:
				{
					throw new ArgumentError("Invalid button state: " + _state);
				}
			}
			
			// save
			/*
				_state = value;
				_contents.x = _contents.y = 0;
				_contents.scaleX = _contents.scaleY = _contents.alpha = 1.0;
				
				switch (_state)
				{
					case ButtonState.DOWN:
					{
						_contents.scaleX = _contents.scaleY = _scaleWhenDown;
						_contents.x = (1.0 - _scaleWhenDown) / 2.0 * _body.width;
						_contents.y = (1.0 - _scaleWhenDown) / 2.0 * _body.height;
						
						break;
					}
					case ButtonState.UP:
					{
						// nothing to do
						break;
					}
					case ButtonState.OVER:
					{
						_contents.x = (1.0 - _scaleWhenOver) / 2.0 * _body.width;
						_contents.y = (1.0 - _scaleWhenOver) / 2.0 * _body.height;
						
						break;
					}
					case ButtonState.DISABLED:
					{
						_contents.alpha = _alphaWhenDisabled;
						
						break;
					}
					default:
					{
						throw new ArgumentError("Invalid button state: " + _state);
					}
				}
			 */
		}
		
		/**
		 * Indicates if the button can be triggered. */
		public function get enabled():Boolean { return _enabled; }
		public function set enabled(value:Boolean):void
		{
			if (_enabled != value)
			{
				_enabled = value;
				state = value ? ButtonState.UP : ButtonState.DISABLED;
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
		
		override public function dispose():void
		{
			removeEventListener(TouchEvent.TOUCH, onTouch);
			
			super.dispose();
		}
		
	}
}