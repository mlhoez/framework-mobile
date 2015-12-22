/**
 * Created by Max on 14/12/14.
 */
package com.ludofactory.mobile.core.avatar.maker.sections
{

	import com.ludofactory.desktop.core.StarlingRoot;
	import com.ludofactory.globbies.events.AvatarMakerEventTypes;
	import com.ludofactory.server.starling.theme.Theme;

	import flash.geom.Rectangle;

	import starling.display.ButtonState;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.textures.Texture;
	import starling.textures.TextureSmoothing;

	/**
	 * A SectionButton displays an avatar section within the SectionSelector class.
	 * 
	 * It is used to select a body section and load all the available items for purchase.
	 */
	public class SectionButton extends Sprite
	{
		
	// ---------- Touch

		private var _enable:Boolean = true;
		
		/**
		 * MAx drag distance after the touch is released. */
		private static const MAX_DRAG_DIST:Number = 50;
		/**
		 * Current touch state. */
		private var _currentTouchState:String;
		/**
		 * Whether the user is over this item renderer. */
		private var _isOver:Boolean = false;

	// ---------- Properties
		
		/**
		 * State textures. */
		private var _deselectedTexture:Texture;
		private var _selectedTexture:Texture;
		private var _addedTexture:Texture;
		
		/**
		 * Part image. */
		private var _image:Image;

		/**
		 * Whether this section is currently sleected. */
		private var _isSelected:Boolean = false;
		
		/**
		 * The armature section name associated to this part.
		 * @see com.ludofactory.globbies.GlobbiesBones */
		private var _armatureSectionName:String;
		
		public function SectionButton(textureName:String, armatureSectionName:String)
		{
			super();
			
			_armatureSectionName = armatureSectionName;

			_selectedTexture = StarlingRoot.assets.getTexture(textureName + "-over");
			_deselectedTexture = StarlingRoot.assets.getTexture(textureName + "-idle");
			_addedTexture = StarlingRoot.assets.getTexture(textureName + "-added");

			this.useHandCursor = true;
			
			_image = new Image(_deselectedTexture);
			_image.smoothing = TextureSmoothing.TRILINEAR;
			addChild(_image);
			
			this.alignPivot();
			
			addEventListener(TouchEvent.TOUCH, onTouch);
		}

//------------------------------------------------------------------------------------------------------------
//	Handlers
		
		/**
		 * Touch handler.
		 */
		private function onTouch(event:TouchEvent):void
		{
			var touch:Touch = event.getTouch(this);

			if (touch == null)
			{
				state = ButtonState.UP;
			}
			else if (touch.phase == TouchPhase.HOVER)
			{
				state = ButtonState.OVER;
			}
			else if (touch.phase == TouchPhase.BEGAN && _currentTouchState != ButtonState.DOWN)
			{
				state = ButtonState.DOWN;
			}
			else if (touch.phase == TouchPhase.MOVED && _currentTouchState == ButtonState.DOWN)
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
			else if (touch.phase == TouchPhase.ENDED && _currentTouchState == ButtonState.DOWN && !_isSelected) // cannot be deselected by reclicking on it
			{
				isSelected = true;
				state = ButtonState.UP;
//				dispatchEventWith(AvatarMakerEventTypes.PART_SELECTED, true, _armatureSectionName);
			}
		}
		
		public function set state(value:String):void
		{
			_currentTouchState = value;

			switch (_currentTouchState)
			{
				case ButtonState.DOWN:{ break; }
				case ButtonState.DISABLED: { break; }
				case ButtonState.UP:
				{
					_isOver = false;

					if( !_isSelected )
						dispatchEventWith(AvatarMakerEventTypes.PART_UP, true);

					break;
				}

				case ButtonState.OVER:
				{
					if( _isSelected || _isOver)
						return;

					_isOver = true;
					dispatchEventWith(AvatarMakerEventTypes.PART_HOVERED, true);
					
					break;
				}
					
				default:
					throw new ArgumentError("Invalid button state: " + _currentTouchState);
			}
		}
		
		public function get isSelected():Boolean
		{
			return _isSelected;
		}

		public function set isSelected(value:Boolean):void
		{
 			if( !_isSelected && value )
			{
				dispatchEventWith(AvatarMakerEventTypes.PART_SELECTED, true, _armatureSectionName);
				_image.x = _image.y = 0;
				_image.scaleX = _image.scaleY = 1.0;
				_image.texture = _selectedTexture;
			}
			
			_isSelected = value;
			
			if(_hasItemInCart && !_isSelected)
				_image.texture = _addedTexture;
			else
				_image.texture = _isSelected ?  _selectedTexture : _deselectedTexture;
		}
		
		private var _hasItemInCart:Boolean = false;
		public function set isBasketVisible(value:Boolean):void
		{
			if(_hasItemInCart == value)
				return;
			
			_hasItemInCart = value;
			if(_hasItemInCart && !_isSelected)
				_image.texture = _addedTexture;
			else
				_image.texture = _isSelected ?  _selectedTexture : _deselectedTexture;
		}
		
		public function onRollOver():void
		{
			if(_isSelected)
				return;
			_image.texture = _selectedTexture;
		}
		
		public function onRollOut():void
		{
			if(_hasItemInCart)
				_image.texture = _addedTexture;
			else
				_image.texture = _deselectedTexture;
		}
		
//------------------------------------------------------------------------------------------------------------
//	Get - Set
		
		public function get enable():Boolean { return _enable; }
		
		public function set enable(value:Boolean):void
		{
			if(value)
				addEventListener(TouchEvent.TOUCH, onTouch);
			else
				removeEventListener(TouchEvent.TOUCH, onTouch);
			_enable = value;
			this.useHandCursor = value;
		}

//------------------------------------------------------------------------------------------------------------
//	Dispose
		
		override public function dispose():void
		{
			removeEventListener(TouchEvent.TOUCH, onTouch);
			
			_image.removeFromParent(true);
			_image = null;
			
			super.dispose();
		}
		
	}
}