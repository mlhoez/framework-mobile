/**
 * Created by Maxime on 08/09/15.
 */
package com.ludofactory.mobile.core.avatar.maker.sections
{
	
	public class SectionData
	{
		/**
		 * Section name. */
		private var _title:String;
		/**
		 * Icon url. */
		private var _iconUrl:String;
		/**
		 * Associated bone name.
		 * @see com.ludofactory.ludokado.config.LudokadoBones */
		private var _asociatedBone:String;
		
		private var _isChoosed:Boolean = false;
		
		private var _forceTrigger:Boolean = false;
		
		public function SectionData(data:Object)
		{
			_title = String(data.sectionName);
			_iconUrl = String(data.url);
			_asociatedBone = String(data.sectionId);
		}
		
		public function get title():String { return _title; }
		
		public function set title(value:String):void
		{
			_title = value;
		}
		
		
		public function get asociatedBone():String
		{
			return _asociatedBone;
		}
		
		
		public function get isChoosed():Boolean
		{
			return _isChoosed;
		}
		
		
		public function set isChoosed(value:Boolean):void
		{
			_isChoosed = value;
		}
		
		
		public function get forceTrigger():Boolean
		{
			return _forceTrigger;
		}
		
		public function set forceTrigger(value:Boolean):void
		{
			_forceTrigger = value;
		}
	}
}