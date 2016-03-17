/**
 * Created by Maxime on 19/01/16.
 */
package com.ludofactory.mobile.core.avatar.maker
{
	
	import com.ludofactory.common.utils.logs.log;
	import com.ludofactory.common.utils.roundUp;
	import com.ludofactory.mobile.core.avatar.maker.sections.ColorButton;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	
	import feathers.controls.LayoutGroup;
	
	import feathers.core.FeathersControl;
	
	import flash.geom.Rectangle;
	
	import starling.display.ButtonState;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	
	import starling.events.Touch;
	
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	
	import starling.textures.Texture;
	
	public class ColorListButton extends FeathersControl
	{
		private static const MAX_DRAG_DIST:Number = 50;
		
		//private var _button:button
		private var _colorButton:ColorButton;
		
		private var _section:String;
		
		private var mEnabled:Boolean;
		private var mState:String;
		private var mBody:Image;
		private var mTriggerBounds:Rectangle;
		protected var mContents:LayoutGroup;
		private var _isSelected:Boolean = false;
		private var mUpState:Texture;
		private var mDownState:Texture;
		
		public function ColorListButton(upState:Texture, text:String = "", downState:Texture = null)
		{
			super();
			
			mUpState = upState;
			mDownState = downState;
			
			_isToggle = true;
			
			mState = ButtonState.UP;
			mBody = new Image(upState);
			mBody.scaleX = mBody.scaleY = GlobalConfig.dpiScale;
			mEnabled = true;
			//mTextBounds = new Rectangle(0, 0, mBody.width, mBody.height);
			
			mContents = new LayoutGroup();
			mContents.addChild(mBody);
			addChild(mContents);
			addEventListener(TouchEvent.TOUCH, onTouch);
			
			_colorButton = new ColorButton();
			_colorButton.touchable = false;
			addChild(_colorButton);
			
			_colorButton.x = roundUp((this.width - _colorButton.width) * 0.5);
			_colorButton.y = roundUp((this.height - _colorButton.height) * 0.5);
		}
		
		public function enableWithSection(section:String):void
		{
			_section = section;
			_colorButton.alpha = 1;
			this.touchable = true;
		}
		
		public function disable():void
		{
			_section = null;
			_colorButton.alpha = 0;
			this.touchable = false;
		}
		
		override protected function draw():void
		{
			super.draw();
			
			if(isInvalid(INVALIDATION_FLAG_SIZE))
			{
				mContents.width = mBody.width = actualWidth;
				mContents.height = mBody.height = actualHeight;
				
				_colorButton.x = roundUp((actualWidth - _colorButton.width) * 0.5);
				_colorButton.y = roundUp((actualHeight - _colorButton.height) * 0.5);
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Handlers
		
		private function setStateTexture(texture:Texture):void
		{
			mBody.texture = texture ? texture : mUpState;
		}
		
		/** The current state of the button. The corresponding strings are found
		 *  in the ButtonState class. */
		public function get state():String { return mState; }
		public function set state(value:String):void
		{
			mState = value;
			mContents.x = mContents.y = 0;
			mContents.scaleX = mContents.scaleY = mContents.alpha = 1.0;
			
			switch (mState)
			{
				case ButtonState.DOWN:
					setStateTexture(mDownState);
					break;
				case ButtonState.UP:
					
					setStateTexture(_isSelected ? mDownState : mUpState);
					break;
				case ButtonState.OVER:
						
					break;
				case ButtonState.DISABLED:
						
					break;
				//default:
				//    throw new ArgumentError("Invalid button state: " + mState);
			}
		}
		
		protected function onTouch(event:TouchEvent):void
		{
			var touch:Touch = event.getTouch(this);
			var isWithinBounds:Boolean;
			
			if (!mEnabled)
			{
				return;
			}
			else if (touch == null)
			{
				state = ButtonState.UP;
			}
			else if (touch.phase == TouchPhase.HOVER)
			{
				state = ButtonState.OVER;
			}
			else if (touch.phase == TouchPhase.BEGAN && mState != ButtonState.DOWN)
			{
				mTriggerBounds = getBounds(stage, mTriggerBounds);
				mTriggerBounds.inflate(MAX_DRAG_DIST, MAX_DRAG_DIST);
				
				state = ButtonState.DOWN;
			}
			else if (touch.phase == TouchPhase.MOVED)
			{
				isWithinBounds = mTriggerBounds.contains(touch.globalX, touch.globalY);
				
				if (mState == ButtonState.DOWN && !isWithinBounds)
				{
					// reset button when finger is moved too far away ...
					state = ButtonState.UP;
				}
				else if (mState == ButtonState.UP && isWithinBounds)
				{
					// ... and reactivate when the finger moves back into the bounds.
					state = ButtonState.DOWN;
				}
			}
			else if (touch.phase == TouchPhase.ENDED && mState == ButtonState.DOWN)
			{
				state = ButtonState.UP;
				if (!touch.cancelled)
				{
					if(_isToggle)
					{
						if(!_isSelected)
						{
							_isSelected = true;
							state = ButtonState.DOWN;
							onTriggered();
						}
					}
					else
					{
						onTriggered();
					}
				}
			}
		}
		
		private var _isToggle:Boolean = false;
		public function get isToggle():Boolean { return _isToggle; }
		public function set isToggle(value:Boolean):void { _isToggle = value; }
		
//------------------------------------------------------------------------------------------------------------
//	Override
		
		protected function onTriggered():void
		{
			_colorButton.animate();
			dispatchEventWith(Event.TRIGGERED, true);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Get
		
		public function get section():String
		{
			return _section;
		}
		
		public function get isSelected():Boolean { return _isSelected; }
		public function set isSelected(value:Boolean):void
		{
			_isSelected = value;
			if(!_isSelected)
				state = ButtonState.UP;
			else
				state = ButtonState.DOWN
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
		
		override public function dispose():void
		{
			_colorButton.removeFromParent(true);
			_colorButton = null;
			
			super.dispose();
		}
		
	}
}