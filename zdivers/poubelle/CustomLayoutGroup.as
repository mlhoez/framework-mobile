/*
LudoFactory
Framework mobile
Author  : Maxime Lhoez
Created : 12 déc. 2013
*/
package com.ludofactory.mobile.core.controls
{
	import com.ludofactory.common.utils.log;
	
	import feathers.controls.LayoutGroup;
	import feathers.core.IFeathersControl;
	import feathers.events.FeathersEventType;
	import feathers.layout.ILayoutDisplayObject;
	
	import starling.display.DisplayObject;
	import starling.display.DisplayObjectContainer;
	import starling.display.Quad;
	
	public class CustomLayoutGroup extends LayoutGroup
	{
		private var _quad:Quad;
		
		private var _bypassLayout:Boolean = false;
		
		public function CustomLayoutGroup()
		{
			super();
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			_quad = new Quad(5, 5, 0xff0000);
			_quad.touchable = false; // FIXME A vérifier
			_bypassLayout = true;
			addChildAt(_quad, 0);
			_bypassLayout = false;
		}
		
		override protected function draw():void
		{
			super.draw();
			
			if( isInvalid(INVALIDATION_FLAG_SIZE) )
			{
				_quad.width = actualWidth;
				_quad.height = actualHeight;
			}
		}
		
		override public function addChildAt(child:DisplayObject, index:int):DisplayObject
		{
			if(child is IFeathersControl)
			{
				child.addEventListener(FeathersEventType.RESIZE, child_resizeHandler);
			}
			if(child is ILayoutDisplayObject)
			{
				child.addEventListener(FeathersEventType.LAYOUT_DATA_CHANGE, child_layoutDataChangeHandler);
			}
			if( !_bypassLayout )
			{
				var oldIndex:int = this.items.indexOf(child);
				if(oldIndex == index)
				{
					return child;
				}
				if(oldIndex >= 0)
				{
					this.items.splice(oldIndex, 1);
				}
				var itemCount:int = this.items.length;
				if(index == itemCount)
				{
					//faster than splice because it avoids gc
					this.items[index] = child;
				}
				else
				{
					this.items.splice(index, 0, child);
				}
			}
			this.invalidate(INVALIDATION_FLAG_LAYOUT);
			return (this as DisplayObjectContainer).addChildAt(child, index);
		}
	}
}