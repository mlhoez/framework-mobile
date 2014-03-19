/*
LudoFactory
Framework mobile
Author  : Maxime Lhoez
Created : 9 janv. 2014
*/
package com.ludofactory.mobile.core.controls
{
	import feathers.controls.ToggleSwitch;
	
	public class CustomToggleSwitch extends ToggleSwitch
	{
		/**
		 * The on thumb text. */		
		protected var _onThumbText:String;
		
		/**
		 * The off thumb text. */		
		protected var _offThumbText:String;
		
		public function CustomToggleSwitch()
		{
			super();
		}
		
		override protected function layoutTracks():void
		{
			super.layoutTracks();
			
			const trackScrollableWidth:Number = this.actualWidth - this._paddingLeft - this._paddingRight - this.thumb.width;
			if( this.thumb.x > (this._paddingLeft + trackScrollableWidth / 2) )
			{
				this.thumb.label = _onThumbText;
				this.thumb.isSelected = true;
			}
			else
			{
				this.thumb.label = _offThumbText;
				this.thumb.isSelected = false;
			}
		}
		
		/**
		 * The text to display in the ON label.
		 *
		 * <p>In the following example, the toggle switch's on label text is
		 * updated:</p>
		 *
		 * <listing version="3.0">
		 * toggle.onText = "on";</listing>
		 *
		 * @default "ON"
		 */
		public function get onThumbText():String
		{
			return this._onThumbText;
		}
		
		/**
		 * @private
		 */
		public function set onThumbText(value:String):void
		{
			if(value === null)
			{
				value = "";
			}
			if(this._onThumbText == value)
			{
				return;
			}
			this._onThumbText = value;
			this.invalidate(INVALIDATION_FLAG_STYLES);
		}
		
		/**
		 * The text to display in the ON label.
		 *
		 * <p>In the following example, the toggle switch's on label text is
		 * updated:</p>
		 *
		 * <listing version="3.0">
		 * toggle.onText = "on";</listing>
		 *
		 * @default "ON"
		 */
		public function get offThumbText():String
		{
			return this._offThumbText;
		}
		
		/**
		 * @private
		 */
		public function set offThumbText(value:String):void
		{
			if(value === null)
			{
				value = "";
			}
			if(this._offThumbText == value)
			{
				return;
			}
			this._offThumbText = value;
			this.invalidate(INVALIDATION_FLAG_STYLES);
		}
		
	}
}