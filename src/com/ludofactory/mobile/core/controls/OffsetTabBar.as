/*
Copyright © 2006-2014 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 24 août 2013
*/
package com.ludofactory.mobile.core.controls
{
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import feathers.controls.TabBar;
	import feathers.controls.ToggleButton;
	
	import starling.events.Event;
	
	/**
	 * Tab bar with offset
	 */	
	public class OffsetTabBar extends TabBar
	{
		/**
		 * The offset used to create the desired effect */		
		private var _offset:int = 10;
		
		public function OffsetTabBar()
		{
			super();
			
			firstTabName = Theme.BUTTON_OFFSET_TAB_BAR_LEFT;
			tabName = Theme.BUTTON_OFFSET_TAB_BAR_MIDDLE;
			lastTabName = Theme.BUTTON_OFFSET_TAB_BAR_RIGHT;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			_offset *= GlobalConfig.dpiScale;
		}
		
		override protected function layoutTabs():void
		{
			super.layoutTabs();
			
			const tabCount:int = this.activeTabs.length;
			const totalSize:Number = this._direction == DIRECTION_VERTICAL ? this.actualHeight : this.actualWidth;
			const totalTabSize:Number = totalSize - (this._gap * (tabCount - 1));
			const tabSize:Number = totalTabSize / tabCount;
			var position:Number = 0;
			for(var i:int = 0; i < tabCount; i++)
			{
				var tab:ToggleButton = this.activeTabs[i];
				if(this._direction == DIRECTION_VERTICAL)
				{
					tab.width = this.actualWidth;
					tab.height = tabSize;
					tab.x = 0;
					tab.y = position;
					position += tab.height + this._gap;
				}
				else //horizontal
				{
					if( i == 0 )
						setChildIndex(tab, int.MAX_VALUE);
					tab.width = tabSize + scaleAndRoundToDpi(_offset);
					tab.height = this.actualHeight;
					tab.x = position;
					tab.y = 0;
					position += tabSize + this._gap;
				}
				
				//final validation to avoid juggler next frame issues
				tab.validate();
			}
		}
		
		override protected function toggleGroup_changeHandler(event:Event):void
		{
			if(this._ignoreSelectionChanges || this._pendingSelectedIndex != NOT_PENDING_INDEX)
			{
				return;
			}
			setChildIndex( ToggleButton(toggleGroup.selectedItem), int.MAX_VALUE);
			this.dispatchEventWith(Event.CHANGE);
		}
	}
}