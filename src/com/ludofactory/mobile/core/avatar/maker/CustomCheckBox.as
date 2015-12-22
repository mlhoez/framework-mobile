/**
 * Created by Maxime on 30/12/14.
 */
package com.ludofactory.mobile.core.avatar.maker
{

	import com.greensock.TweenMax;
	import com.greensock.easing.Elastic;
	import com.ludofactory.desktop.core.StarlingRoot;
	import com.ludofactory.desktop.gettext.aliases._;
	import com.ludofactory.desktop.tools.roundUp;
	import com.ludofactory.globbies.events.AvatarMakerEventTypes;
	import com.ludofactory.server.data.ServerData;
	import com.ludofactory.server.starling.theme.Theme;

	import flash.geom.Rectangle;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;

	import starling.display.ButtonState;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.text.TextField;
	import starling.text.TextFieldAutoSize;
	import starling.utils.HAlign;

	public class CustomCheckBox extends Sprite
	{
		private static const MAX_DRAG_DIST:Number = 50;
		private var mUseHandCursor:Boolean = true;
		private var mState:String;
		
		/**
		 * Whether the booster shouldremain in the down state if a touch moves outside of the button's bounds. */
		public var keepDownStateOnRollOut:Boolean = false;

		/**
		 *  */
		private var _onlyMyItemsLabel:TextField;
		/**
		 * Check box background. */
		private var _background:Quad;
		/**
		 * Check icon. */
		private var _checkIcon:Image;
		/**
		 * Whether the checkbox is selected. */
		private var _isSelected:Boolean = false;
		
		public function CustomCheckBox()
		{
			super();
			
			_onlyMyItemsLabel = new TextField(230, 24, _("Afficher seulement les objets acquis"), Theme.FONT_OSWALD, 12, 0xffffff);
			_onlyMyItemsLabel.autoScale = true;
			_onlyMyItemsLabel.hAlign = HAlign.RIGHT;
			_onlyMyItemsLabel.x = roundUp(_onlyMyItemsLabel.x);
			_onlyMyItemsLabel.y = roundUp(_onlyMyItemsLabel.y - 1);
			addChild(_onlyMyItemsLabel);
			
			_background = new Quad(12, 12, 0x000000);
			_background.alpha = 0.6;
			_background.x = _onlyMyItemsLabel.width + 4;
			_background.y = roundUp((_onlyMyItemsLabel.height - _background.height) * 0.5);
			addChild(_background);
			
			_checkIcon = new Image(StarlingRoot.assets.getTexture("checkbox-arrow"));
			_checkIcon.visible = false;
			_checkIcon.alpha = 0;
			_checkIcon.alignPivot();
			_checkIcon.x = roundUp(_background.x + (_background.width * 0.5));
			_checkIcon.y = roundUp(_background.y + (_background.height * 0.5) - 2);
			addChild(_checkIcon);

			this.addEventListener(TouchEvent.TOUCH, onTouch);
		}

//------------------------------------------------------------------------------------------------------------
//	Touch handler

		private function onTouch(event:TouchEvent):void
		{
			Mouse.cursor = (mUseHandCursor && event.interactsWith(this)) ?
					MouseCursor.BUTTON : MouseCursor.AUTO;

			var touch:Touch = event.getTouch(this);
			if (touch == null)
			{
				state = ButtonState.UP;
			}
			else if (touch.phase == TouchPhase.HOVER)
			{
				state = ButtonState.OVER;
			}
			else if (touch.phase == TouchPhase.BEGAN && mState != ButtonState.DOWN)
			{
				state = ButtonState.DOWN;
			}
			else if (touch.phase == TouchPhase.MOVED && mState == ButtonState.DOWN)
			{
				// reset button when user dragged too far away after pushing
				var buttonRect:Rectangle = getBounds(stage);
				if (touch.globalX < buttonRect.x - MAX_DRAG_DIST ||
						touch.globalY < buttonRect.y - MAX_DRAG_DIST ||
						touch.globalX > buttonRect.x + buttonRect.width + MAX_DRAG_DIST ||
						touch.globalY > buttonRect.y + buttonRect.height + MAX_DRAG_DIST)
				{
					state = ButtonState.UP;
				}
			}
			else if (touch.phase == TouchPhase.ENDED && mState == ButtonState.DOWN)
			{
				state = ButtonState.UP;
				isSelected = !_isSelected;
				dispatchEventWith(Event.TRIGGERED, false);
			}
		}
		/** The current state of the button. The corresponding strings are found
		 *  in the ButtonState class. */
		public function get state():String { return mState; }
		public function set state(value:String):void
		{
			mState = value;

			switch (mState)
			{
				case ButtonState.DOWN:
						
					break;
				case ButtonState.UP:
						
					break;
				case ButtonState.OVER:
						
					break;
				case ButtonState.DISABLED:
						
					break;
				default:
					throw new ArgumentError("Invalid button state: " + mState);
			}
		}


		public function get isSelected():Boolean
		{
			return _isSelected;
		}

		public function set isSelected(value:Boolean):void
		{
			if( value == _isSelected )
				return;
			
			_isSelected = value;
			if( _isSelected )
				TweenMax.to(_checkIcon, 0.25, { autoAlpha:1, scaleX:1, scaleY:1 });
			else
				TweenMax.to(_checkIcon, 0.25, { autoAlpha:0, scaleX:0, scaleY:0 });
		}

		//------------------------------------------------------------------------------------------------------------
//	Dispose
		
		override public function dispose():void
		{
			this.removeEventListener(TouchEvent.TOUCH, onTouch);
			
			_background.removeFromParent(true);
			_background = null;
			
			_checkIcon.removeFromParent(true);
			_checkIcon = null;
			
			_isSelected = false;
		}
		
	}
}