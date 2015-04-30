/*
Copyright © 2006-2015 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 2 déc. 2013
*/
package com.ludofactory.mobile.core.controls
{
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import flash.text.TextFormat;
	
	import feathers.controls.Label;
	import feathers.controls.LayoutGroup;
	import feathers.layout.HorizontalLayout;
	
	import starling.display.Image;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	
	public class ArrowGroup extends LayoutGroup
	{
		/**
		 * The login arrow. */		
		private var _arrow:Image;
		
		/**
		 * The register button. */		
		private var _label:Label;
		
		/**
		 * The label name. */		
		private var _labelName:String;
		
		public function ArrowGroup(labelName:String = "")
		{
			super();
			
			_labelName = labelName;
			isQuickHitAreaEnabled = true;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			minHeight = minTouchHeight = scaleAndRoundToDpi(80);
			
			var hlayout:HorizontalLayout = new HorizontalLayout();
			hlayout.horizontalAlign = HorizontalLayout.HORIZONTAL_ALIGN_LEFT;
			hlayout.verticalAlign = HorizontalLayout.VERTICAL_ALIGN_MIDDLE;
			hlayout.gap = scaleAndRoundToDpi(10);
			layout = hlayout;
			
			_arrow = new Image( AbstractEntryPoint.assets.getTexture("arrow-right-dark"));
			_arrow.scaleX = _arrow.scaleY = GlobalConfig.dpiScale;
			addChild(_arrow);
			
			_label = new Label();
			_label.text = _labelName;
			addChild(_label);
			_label.textRendererProperties.textFormat = new TextFormat(Theme.FONT_ARIAL, scaleAndRoundToDpi(GlobalConfig.isPhone ? 30 : 38), Theme.COLOR_DARK_GREY, true, true);
			_label.textRendererProperties.wordWrap = false;
			
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
		
	}
}