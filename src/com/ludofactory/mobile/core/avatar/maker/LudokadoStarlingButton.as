/**
 * Created by Maxime on 29/09/15.
 */
package com.ludofactory.mobile.core.avatar.maker
{
	
	import com.ludofactory.mobile.core.theme.Theme;
	
	import feathers.controls.Callout;
	
	import starling.display.ButtonState;
	import starling.text.TextField;
	import starling.text.TextFieldAutoSize;
	import starling.textures.Texture;
	import starling.utils.HAlign;
	
	/**
	 * Extended Starling button in order to include a toggle feature and a tooltip
	 */
	public class LudokadoStarlingButton extends CustomButton
	{
		
	// ---------- ToolTip properties
		
		/**
		 * Whether the callout is displaying. */
		private var _isCalloutDisplaying:Boolean = false;
		/**
		 * Callout label. */
		private var _calloutLabel:TextField;
		private var _calloutDirection:String = Callout.DIRECTION_ANY;
		private var _calloutText:String;
		
	// ---------- Other properties
		
		public function LudokadoStarlingButton(upState:Texture, text:String = "", downState:Texture = null,
		                                       overState:Texture = null, disabledState:Texture = null)
		{
			super(upState, text, downState, overState, disabledState);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Override
		
		private var _callout:Callout;
		
		override public function set state(value:String):void
		{
			super.state = value;
			
			switch(state)
			{
				case ButtonState.OVER:
				{
					if(_isToolTipEnabled && !_isCalloutDisplaying)
					{
						_isCalloutDisplaying = true;
						_calloutLabel.text = _calloutText;
						_callout = Callout.show(_calloutLabel, this, _calloutDirection, false);
						_callout.disposeContent = false;
						_callout.touchable = false;
					}
					
					break;
				}
				
				case ButtonState.UP:
				{
					if(_callout)
					{
						_isCalloutDisplaying = false;
						_callout.close(true);
						_callout = null;
					}
					
					break;
				}
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	ToolTip management
		
		/**
		 * Whether the tooltip is enabled. */
		private var _isToolTipEnabled:Boolean = false;
		
		public function get isToolTipEnabled():Boolean { return _isToolTipEnabled; }
		public function set isToolTipEnabled(value:Boolean):void
		{
			_isToolTipEnabled = value;
			if(_isToolTipEnabled)
			{
				if(!_calloutLabel)
				{
					_calloutLabel = new TextField(5, 5, "", Theme.FONT_OSWALD, 12, 0xffffff);
					_calloutLabel.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
					_calloutLabel.hAlign = HAlign.CENTER;
					_calloutLabel.touchable = false;
				}
			}
			else
			{
				if(_calloutLabel)
				{
					_calloutLabel.removeFromParent(true);
					_calloutLabel = null;
				}
			}
		}
		
		public function get calloutDirection():String { return _calloutDirection; }
		public function set calloutDirection(value:String):void { _calloutDirection = value; }
		
		public function get calloutText():String { return _calloutText; }
		public function set calloutText(value:String):void { _calloutText = value; }
		
//------------------------------------------------------------------------------------------------------------
//	Toggle management
		
		
		
		
	}
}