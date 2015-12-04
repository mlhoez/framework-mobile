/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 2 déc. 2013
*/
package com.ludofactory.mobile.core.controls
{
	
	import com.ludofactory.common.utils.roundUp;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.text.TextField;
	import starling.text.TextFieldAutoSize;
	
	public class ArrowGroup extends Sprite
	{
		/**
		 * The login arrow. */		
		private var _arrow:Image;
		
		/**
		 * The register button. */		
		private var _label:TextField;
		
		/**
		 * The label name. */		
		private var _labelName:String;
		
		public function ArrowGroup(labelName:String = "")
		{
			super();
			
			_labelName = labelName;
			touchGroup = true;
			
			_arrow = new Image( AbstractEntryPoint.assets.getTexture("arrow-right"));
			_arrow.color = 0x6d6d6d;
			_arrow.scaleX = _arrow.scaleY = GlobalConfig.dpiScale;
			addChild(_arrow);
			
			_label = new TextField(5, scaleAndRoundToDpi(50), _labelName, Theme.FONT_ARIAL, scaleAndRoundToDpi(GlobalConfig.isPhone ? 25 : 33), 0x6d6d6d, true);
			_label.text = _labelName;
			_label.autoSize = TextFieldAutoSize.HORIZONTAL;
			_label.x = _arrow.x + _arrow.width + scaleAndRoundToDpi(3);
			addChild(_label);
			
			_arrow.y = roundUp((_label.height - _arrow.height) * 0.5);
			
			addEventListener(TouchEvent.TOUCH, onTouch);
		}
		
		private function onTouch(event:TouchEvent):void
		{
			var touch:Touch = event.getTouch(this);
			if( touch && touch.phase == TouchPhase.ENDED )
				dispatchEventWith(Event.TRIGGERED);
			touch = null;
		}
		
		public function set label(val:String):void
		{
			_label.text = val;
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
		
		override public function dispose():void
		{
			removeEventListener(TouchEvent.TOUCH, onTouch);
			
			_arrow.removeFromParent(true);
			_arrow = null;
			
			_label.removeFromParent(true);
			_label = null;
			
			super.dispose();
		}
		
	}
}