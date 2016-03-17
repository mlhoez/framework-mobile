/**
 * Created by Maxime on 05/10/15.
 */
package com.ludofactory.mobile.core.avatar.maker
{
	
	import feathers.controls.List;
	import feathers.controls.renderers.IListItemRenderer;
	import feathers.core.FeathersControl;
	
	import starling.events.Event;
	
	public class CustomDefaultListItemRenderer extends FeathersControl implements IListItemRenderer
	{
		public function CustomDefaultListItemRenderer()
		{
			super();
		}
		
		protected var _owner:List;
		
		public function get owner():List
		{
			return List(this._owner);
		}
		
		public function set owner(value:List):void
		{
			if(this._owner) // first remove the listener
				owner.removeEventListener(Event.SCROLL, onScroll);
			
			if(this._owner == value)
				return;
			
			this._owner = value;
			this.invalidate(INVALIDATION_FLAG_DATA);
			
			if(this.owner)
				owner.addEventListener(Event.SCROLL, onScroll)
		}
		
		protected var _index:int = -1;
		
		public function get index():int
		{
			return this._index;
		}
		
		public function set index(value:int):void
		{
			if(this._index == value)
			{
				return;
			}
			this._index = value;
			this.invalidate(INVALIDATION_FLAG_DATA);
		}
		
		/**
		 * @private
		 */
		protected var _factoryID:String;
		
		/**
		 * @inheritDoc
		 */
		public function get factoryID():String
		{
			return this._factoryID;
		}
		
		/**
		 * @private*/
		 
		public function set factoryID(value:String):void
		{
			this._factoryID = value;
		}
		
		public function get data():Object
		{
			throw new Error("A implémenter !");
		}
		
		public function set data(value:Object):void
		{
			throw new Error("A implémenter !");
		}
		
		protected var _isSelected:Boolean;
		
		public function get isSelected():Boolean
		{
			return this._isSelected;
		}
		
		public function set isSelected(value:Boolean):void
		{
			if(this._isSelected == value)
			{
				return;
			}
			this._isSelected = value;
			this.invalidate(INVALIDATION_FLAG_SELECTED);
			this.dispatchEventWith(Event.CHANGE);
		}
		
		public function onScroll(event:Event = null):void
		{
			
		}
		
	}
}