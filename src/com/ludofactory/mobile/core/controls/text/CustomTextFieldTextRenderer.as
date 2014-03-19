/*
LudoFactory
Framework mobile
Author  : Maxime Lhoez
Created : 21 sept. 2013
*/
package com.ludofactory.mobile.core.controls.text
{
	import feathers.controls.text.TextFieldTextRenderer;
	
	/**
	 * This is a custom TextFieldTextRenderer based on the Feathers TextFieldTextRenderer.
	 * 
	 * <p>This custom text renderer allows the text to use native filters.</p>
	 */	
	public class CustomTextFieldTextRenderer extends TextFieldTextRenderer
	{
		/**
		 * Flag to indicate that the textformat is invalid and should be redrawn.
		 */
		public static const INVALIDATION_FLAG_TEXTFORMAT:String = "textformat";
		
		public function CustomTextFieldTextRenderer()
		{
			super();
		}
		
		/**
		 * @private
		 */
		//private var _filters:Array = [];
		
		/**
		 * Same as the TextField property with the same name.
		 *
		 * <p>In the following example, the text is displayed as a password:</p>
		 *
		 * <listing version="3.0">
		 * textRenderer.displayAsPassword = true;</listing>
		 *
		 * @default false
		 *
		 * @see flash.text.TextField#displayAsPassword
		 */
		/*public function get filters():Array
		{
			return this._filters;
		}*/
		
		/**
		 * @private
		 */
		/*public function set filters(value:Array):void
		{
			if(this._filters == value)
			{
				return;
			}
			this._filters = value.concat();
			this.invalidate(INVALIDATION_FLAG_STYLES);
		}*/
		
		/**
		 * @private
		 */
		override protected function commit():void
		{
			//const stylesInvalid:Boolean = this.isInvalid(INVALIDATION_FLAG_STYLES);
			const textFormatInvalid:Boolean = this.isInvalid(INVALIDATION_FLAG_TEXTFORMAT);
			
			/*if(stylesInvalid)
			{
				this.textField.filters = this._filters.concat();
			}*/
			
			super.commit();
			
			if(textFormatInvalid && _insideTextFormat)
			{
				this.textField.setTextFormat(_insideTextFormat.textFormat, _insideTextFormat.beginIndex, _insideTextFormat.endIndex);
			}
		}
		
		/**
		 * textFormat, beginIndex et endIndex
		 */		
		protected var _insideTextFormat:InsideTextFormatProperties;
		
		public function get insideTextFormat():InsideTextFormatProperties
		{
			return this._insideTextFormat;
		}
		
		public function set insideTextFormat(value:InsideTextFormatProperties):void
		{
			if( this._insideTextFormat == value)
			{
				return;
			}
			_insideTextFormat = value;
			invalidate(INVALIDATION_FLAG_TEXTFORMAT);
		}
	}
}