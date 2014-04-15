/*
Copyright © 2006-2014 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 6 oct. 2013
*/
package com.ludofactory.mobile.core.controls
{
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import flash.text.TextFormat;
	
	import feathers.controls.Button;
	import feathers.controls.Label;
	import feathers.controls.ScrollContainer;
	
	public class BadgedButton extends Button
	{
		/**
		 * The badge count. */		
		private var _badgeCount:int = 0;
		
		/**
		 * The badge container. */		
		private var _badgeContainer:ScrollContainer;
		
		/**
		 * The badge label. */		
		private var _badgeLabel:Label;
		
		public function BadgedButton()
		{
			super();
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			_badgeContainer = new ScrollContainer();
			_badgeContainer.styleName = Theme.SCROLL_CONTAINER_ALERT;
			addChild( _badgeContainer );
			
			_badgeLabel = new Label();
			_badgeLabel.text = "999";
			_badgeContainer.addChild( _badgeLabel );
			_badgeLabel.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(20), Theme.COLOR_YELLOW);
		}
		
		override protected function layoutContent():void
		{
			super.layoutContent();
			
			// top right placement
			/*
			_badgeLabel.text = "" + _badgeCount;
			_badgeContainer.validate();
			_badgeContainer.x = this.actualWidth - _badgeContainer.width - scaleAndRoundToDpi(10);
			_badgeContainer.y = scaleAndRoundToDpi(10);
			_badgeContainer.visible = _badgeCount == 0 ? false : true;
			
			setChildIndex( _badgeContainer, int.MAX_VALUE );
			
			currentIcon.x = int(currentIcon.x);
			currentIcon.y = int(currentIcon.y);
			*/
			
			// Placement for the alert button
			_badgeLabel.text = "" + _badgeCount;
			_badgeContainer.validate();
			_badgeContainer.x = int(currentIcon.x + (currentIcon.width * 0.75));
			_badgeContainer.y = int((currentIcon.height - _badgeContainer.height) * 0.5);
			//_badgeContainer.visible = _badgeCount == 0 ? false : true;
			
			setChildIndex( _badgeContainer, int.MAX_VALUE );
			
			currentIcon.x = int(currentIcon.x);
			currentIcon.y = int(currentIcon.y);
			
			setSizeInternal(this.actualWidth + _badgeContainer.width, this.actualHeight, false);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Utils
//------------------------------------------------------------------------------------------------------------
		
		public function set badgeCount(val:int):void
		{
			_badgeCount = val;
			_badgeContainer.invalidate( INVALIDATION_FLAG_SIZE );
			invalidate( INVALIDATION_FLAG_SIZE );
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
//------------------------------------------------------------------------------------------------------------
		
		override public function dispose():void
		{
			_badgeLabel.removeFromParent(true);
			_badgeLabel = null;
			
			_badgeContainer.removeFromParent(true);
			_badgeContainer = null;
			
			super.dispose();
		}
		
	}
}