// =================================================================================================
//
//	Starling Framework
//	Copyright 2011-2014 Gamua. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package com.ludofactory.mobile
{
	
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import feathers.core.FeathersControl;
	import feathers.display.Scale9Image;
	import feathers.textures.Scale9Textures;
	
	import flash.geom.Rectangle;
	
	import starling.display.ButtonState;
	import starling.display.DisplayObjectContainer;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.text.TextField;
	import starling.text.TextFieldAutoSize;
	import starling.utils.HAlign;
	import starling.utils.VAlign;
	
	/** Dispatched when the user triggers the button. Bubbles. */
	[Event(name="triggered", type="starling.events.Event")]
	
	/** A simple button composed of an image and, optionally, text.
	 *
	 *  <p>You can use different textures for various states of the button. If you're providing
	 *  only an up state, the button is simply scaled a little when it is touched.</p>
	 *
	 *  <p>In addition, you can overlay text on the button. To customize the text, you can use
	 *  properties equivalent to those of the TextField class. Move the text to a certain position
	 *  by updating the <code>textBounds</code> property.</p>
	 *
	 *  <p>To react on touches on a button, there is special <code>Event.TRIGGERED</code> event.
	 *  Use this event instead of normal touch events. That way, users can cancel button
	 *  activation by moving the mouse/finger away from the button before releasing.</p>
	 */
	public class MobileButton extends DisplayObjectContainer
	{
		private static const MAX_DRAG_DIST:Number = 50;
		
	// ----------- Textures
		
		private var _upTextures:Scale9Textures;
		private var _downTextures:Scale9Textures;
		private var _overTextures:Scale9Textures;
		private var _disabledTextures:Scale9Textures;
		
	// ----------- Textures
		
		protected var mContents:Sprite;
		private var mBody:Scale9Image;
		private var mTextField:TextField;
		private var mOverlay:Sprite;
		
	// ----------- Textures
		
		private var mScaleWhenDown:Number;
		private var mAlphaWhenDown:Number = 1.0;
		private var mAlphaWhenDisabled:Number;
		private var mEnabled:Boolean = true;
		private var mState:String;
		private var mTriggerBounds:Rectangle;
		
		/**
		 * Creates a button with a set of state-textures and (optionally) some text.
		 * Any state that is left 'null' will display the up-state texture. Beware that all
		 * state textures should have the same dimensions.
		 **/
		public function MobileButton(upState:Scale9Textures, text:String = "", downState:Scale9Textures = null, overState:Scale9Textures = null, disabledState:Scale9Textures = null)
		{
			if (upState == null) throw new ArgumentError("Texture 'upState' cannot be null");
			
			_upTextures = upState;
			_downTextures = downState;
			_overTextures = overState;
			_disabledTextures = disabledState;
			
			mState = ButtonState.UP;
			
			mBody = new Scale9Image(upState);
			mBody.useSeparateBatch = false;
			mScaleWhenDown = downState ? 1.0 : 0.9;
			mAlphaWhenDisabled = disabledState ? 1.0: 0.5;
			
			//scaleAndRoundToDpi(AbstractGameInfo.LANDSCAPE ? (GlobalConfig.isPhone ? 118 : 148) : 128)
			mTextField = new TextField(5, 5, text, Theme.FONT_SANSITA, scaleAndRoundToDpi(50));
			mTextField.vAlign = VAlign.CENTER;
			mTextField.hAlign = HAlign.CENTER;
			mTextField.touchable = false;
			mTextField.batchable = true;
			mTextField.wordWrap = false;
			
			mContents = new Sprite();
			mContents.addChild(mBody);
			mContents.addChild(mTextField);
			addChild(mContents);
			addEventListener(TouchEvent.TOUCH, onTouch);
			
			this.touchGroup = true;
		}
		
		public function initialize():void
		{
			// we need at least the height for the horizontal autosize to work
			mTextField.height = scaleAndRoundToDpi(GlobalConfig.isPhone ? (98 - _padding*2) : (108 - _padding*2));
			mTextField.autoSize = TextFieldAutoSize.HORIZONTAL;
			mTextField.autoScale = false;
			mTextField.text = text;
			
			mBody.validate();
			mBody.width = mTextField.width + (_padding * 2);
			mBody.height = mTextField.height + (_padding * 2);
			
			mTextField.autoSize =  TextFieldAutoSize.NONE;
			mTextField.width  = mBody.width - (_padding * 2);
			mTextField.height = mBody.height - (_padding * 2);
			mTextField.x = mBody.x + _padding;
			mTextField.y = mBody.y + _padding;
			mTextField.autoScale = true;
		}
		
		private function onTouch(event:TouchEvent):void
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
				if (!touch.cancelled) dispatchEventWith(Event.TRIGGERED, true);
			}
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
					setStateTexture(_downTextures);
					mContents.alpha = mAlphaWhenDown;
					mContents.scaleX = mContents.scaleY = mScaleWhenDown;
					mContents.x = (1.0 - mScaleWhenDown) / 2.0 * mBody.width;
					mContents.y = (1.0 - mScaleWhenDown) / 2.0 * mBody.height;
					break;
				case ButtonState.UP:
					setStateTexture(_upTextures);
					break;
				case ButtonState.OVER:
					setStateTexture(_overTextures);
					break;
				case ButtonState.DISABLED:
					setStateTexture(_disabledTextures);
					mContents.alpha = mAlphaWhenDisabled;
					break;
				default:
					throw new ArgumentError("Invalid button state: " + mState);
			}
		}
		
		private function setStateTexture(texture:Scale9Textures):void
		{
			mBody.textures = texture ? texture : _upTextures;
		}
		
		
		
		/** Indicates if the button can be triggered. */
		public function get enabled():Boolean { return mEnabled; }
		public function set enabled(value:Boolean):void
		{
			if (mEnabled != value)
			{
				mEnabled = value;
				state = value ? ButtonState.UP : ButtonState.DISABLED;
			}
		}
		
		/** The text that is displayed on the button. */
		public function get text():String { return mTextField ? mTextField.text : ""; }
		public function set text(value:String):void
		{
			if (value.length == 0)
			{
				if (mTextField)
				{
					mTextField.text = value;
					mTextField.removeFromParent();
				}
			}
			else
			{
				mTextField.text = value;
				
				if (mTextField.parent == null)
					mContents.addChild(mTextField);
			}
		}
		
		/** The overlay sprite is displayed on top of the button contents. It scales with the
		 *  button when pressed. Use it to add additional objects to the button (e.g. an icon). */
		public function get overlay():Sprite
		{
			if (mOverlay == null)
				mOverlay = new Sprite();
			
			mContents.addChild(mOverlay); // make sure it's always on top
			return mOverlay;
		}
		
		override public function set width(value:Number):void
		{
			mBody.width = value;
			if(mTextField)
			{
				mTextField.width = value - (_padding * 2);
			}
			super.width = value;
		}
		
		override public function set height(value:Number):void
		{
			mBody.height = value;
			if(mTextField)
			{
				mTextField.height = value - (_padding * 2);
			}
			super.height = value;
		}
		
//------------------------------------------------------------------------------------------------------------
//	Textfield
		
		/**
		 * Sets native filters.
		 * 
		 * @param value
		 */
		public function set nativeFilters(value:Array):void
		{
			mTextField.nativeFilters = value;
		}
		
		private var _padding:Number = 20;
		public function set textPadding(value:Number):void
		{
			_padding = value;
			
			if(mBody is FeathersControl) mBody.validate();
			mTextField.width  = mBody.width - (_padding * 4);
			mTextField.height = mBody.height - (_padding * 2);
			mTextField.x = mBody.x + _padding;
			mTextField.y = mBody.y + _padding;
		}
		
//------------------------------------------------------------------------------------------------------------
//	Get - Set
		
		/** The texture that is displayed when the button is not being touched. */
		public function get upState():Scale9Textures { return _upTextures; }
		public function set upState(value:Scale9Textures):void
		{
			if (value == null)
				throw new ArgumentError("Texture 'upState' cannot be null");
			
			if (_upTextures != value)
			{
				_upTextures = value;
				if ( mState == ButtonState.UP ||
						(mState == ButtonState.DISABLED && _disabledTextures == null) ||
						(mState == ButtonState.DOWN && _downTextures == null) ||
						(mState == ButtonState.OVER && _overTextures == null))
				{
					setStateTexture(value);
				}
			}
		}
		
		/** The texture that is displayed while the button is touched. */
		public function get downState():Scale9Textures { return _downTextures; }
		public function set downState(value:Scale9Textures):void
		{
			if (_downTextures != value)
			{
				_downTextures = value;
				if (mState == ButtonState.DOWN) setStateTexture(value);
			}
		}
		
		/** The texture that is displayed while mouse hovers over the button. */
		public function get overState():Scale9Textures { return _overTextures; }
		public function set overState(value:Scale9Textures):void
		{
			if (_overTextures != value)
			{
				_overTextures = value;
				if (mState == ButtonState.OVER) setStateTexture(value);
			}
		}
		
		/** The texture that is displayed when the button is disabled. */
		public function get disabledState():Scale9Textures { return _disabledTextures; }
		public function set disabledState(value:Scale9Textures):void
		{
			if (_disabledTextures != value)
			{
				_disabledTextures = value;
				if (mState == ButtonState.DISABLED) setStateTexture(value);
			}
		}
		
		/** The name of the font displayed on the button. May be a system font or a registered
		 *  bitmap font. */
		public function get fontName():String { return mTextField ? mTextField.fontName : "Verdana"; }
		public function set fontName(value:String):void { mTextField.fontName = value; }
		
		/** The size of the font. */
		public function get fontSize():Number { return mTextField ? mTextField.fontSize : 12; }
		public function set fontSize(value:Number):void { mTextField.fontSize = value; }
		
		/** The color of the font. */
		public function get fontColor():uint { return mTextField ? mTextField.color : 0x0; }
		public function set fontColor(value:uint):void { mTextField.color = value; }
		
		/** Indicates if the font should be bold. */
		public function get fontBold():Boolean { return mTextField ? mTextField.bold : false; }
		public function set fontBold(value:Boolean):void { mTextField.bold = value; }
		
		/** The vertical alignment of the text on the button. */
		public function get textVAlign():String { return mTextField ? mTextField.vAlign : VAlign.CENTER; }
		public function set textVAlign(value:String):void { mTextField.vAlign = value; }
		
		/** The horizontal alignment of the text on the button. */
		public function get textHAlign():String { return mTextField ? mTextField.hAlign : HAlign.CENTER; }
		public function set textHAlign(value:String):void { mTextField.hAlign = value; }
		
		
		/** The scale factor of the button on touch. Per default, a button without a down state
		 *  texture will be made slightly smaller, while a button with a down state texture
		 *  remains unscaled. */
		public function get scaleWhenDown():Number { return mScaleWhenDown; }
		public function set scaleWhenDown(value:Number):void { mScaleWhenDown = value; }
		
		/** The alpha value of the button on touch. @default 1.0 */
		public function get alphaWhenDown():Number { return mAlphaWhenDown; }
		public function set alphaWhenDown(value:Number):void { mAlphaWhenDown = value; }
		
		/** The alpha value of the button when it is disabled. @default 0.5 */
		public function get alphaWhenDisabled():Number { return mAlphaWhenDisabled; }
		public function set alphaWhenDisabled(value:Number):void { mAlphaWhenDisabled = value; }
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
		
		
		public override function dispose():void
		{
			// text field might be disconnected from parent, so we have to dispose it manually
			if (mTextField)
			{
				mTextField.nativeFilters = [];
				mTextField.dispose();
			}
			
			super.dispose();
		}
		
	}
}