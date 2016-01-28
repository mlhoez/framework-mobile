/**
 * Created by Maxime on 14/01/16.
 */
package com.ludofactory.mobile.core.avatar.test
{
	
	import com.greensock.TweenMax;
	import com.ludofactory.mobile.core.avatar.AvatarMakerAssets;
	import com.ludofactory.mobile.core.avatar.maker.LudokadoStarlingButton;
	import com.ludofactory.mobile.core.avatar.test.events.LKAvatarMakerEventTypes;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	
	import flash.geom.Point;
	
	import starling.display.Image;
	import starling.events.Event;
	
	public class NewSectionButton extends LudokadoStarlingButton
	{
		/**
		 * The associated section name. */
		private var _sectionName:String;
		/**
		 * Final position. */
		private var _finalPosition:Point;
		/**
		 * The animation delay. */
		private var _delay:Number;
		
		/**
		 * The section icon. */
		private var _icon:Image;
		
		public function NewSectionButton(sectionName:String, finalPosition:Point, delay:Number)
		{
			super(AvatarMakerAssets["section_button"], "", AvatarMakerAssets["section_selected_button"]);
			
			_sectionName = sectionName;
			_finalPosition = finalPosition;
			_delay = delay;
			isToggle = true;
			
			_icon = new Image(AvatarMakerAssets["section_" + sectionName + "_button"]);
			_icon.scaleX = _icon.scaleY = GlobalConfig.dpiScale;
			addChild(_icon);
			
			this.alpha = 0;
			this.visible = false;
			
			addEventListener(Event.TRIGGERED, onTriggered);
		}
		
		public function animateIn():void
		{
			TweenMax.killTweensOf(this);
			TweenMax.to(this, 0.20, { delay:_delay, x:_finalPosition.x, y:_finalPosition.y, autoAlpha:1, onComplete:function():void{ touchable = true; } });
		}
		
		public function animateOut():void
		{
			TweenMax.killTweensOf(this);
			touchable = false;
			TweenMax.to(this, 0.15, { /*delay:_delay,*/ x:0, y:0, autoAlpha:0 });
		}
		
		private function onTriggered(event:Event):void
		{
			dispatchEventWith(LKAvatarMakerEventTypes.PART_SELECTED, true, _sectionName);
		}
		
		public function forceTrigger():void
		{
			dispatchEventWith(LKAvatarMakerEventTypes.PART_SELECTED, true, _sectionName);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Get
		
		public function get sectionName():String
		{
			return _sectionName;
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
		
		override public function dispose():void
		{
			removeEventListener(Event.TRIGGERED, onTriggered);
			
			TweenMax.killTweensOf(this);
			
			_icon.removeFromParent(true);
			_icon = null;
			
			_sectionName = null;
			_finalPosition = null;
			_delay = NaN;
			
			super.dispose();
		}
		
	}
}