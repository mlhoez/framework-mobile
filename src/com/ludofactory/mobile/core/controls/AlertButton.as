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
	
	/**
	 * A button that can display a badge count.
	 */	
	public class AlertButton extends Button
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
		
		public function AlertButton()
		{
			super();
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			_badgeContainer = new ScrollContainer();
			_badgeContainer.touchable = false;
			_badgeContainer.nameList.add( Theme.SCROLL_CONTAINER_BADGE );
			addChild( _badgeContainer );
			
			_badgeLabel = new Label();
			_badgeLabel.touchable = false;
			_badgeContainer.addChild( _badgeLabel );
			_badgeLabel.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(20), 0xffffff);
		}
		
		override protected function layoutContent():void
		{
			super.layoutContent();
			
			_badgeLabel.text = "" + _badgeCount;
			_badgeContainer.validate();
			_badgeContainer.x = actualWidth - _badgeContainer.width - scaleAndRoundToDpi(10);
			_badgeContainer.y = scaleAndRoundToDpi(10);
			_badgeContainer.visible = _badgeCount == 0 ? false : true;
			
			setChildIndex( _badgeContainer, int.MAX_VALUE );
			
			currentIcon.x = int(currentIcon.x);
			currentIcon.y = int(currentIcon.y);
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