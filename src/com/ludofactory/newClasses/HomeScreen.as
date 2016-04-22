/**
 * Created by Maxime on 22/04/2016.
 */
package com.ludofactory.newClasses
{
	
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.controls.AdvancedScreen;
	
	import starling.display.Image;
	
	/**
	 * Home screen.
	 */
	public class HomeScreen extends AdvancedScreen
	{
		/**
		 * Background. */
		private var _background:Image;
		
		/**
		 * Header container, will hold the high score and number of trophies in duel mode. */
		private var _headerContainer:HeaderContainer;
		
		public function HomeScreen()
		{
			super();
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			_background = new Image(AbstractEntryPoint.assets.getTexture("dark-background"));
			addChild(_background);
			
			_headerContainer = new HeaderContainer();
			addChild(_headerContainer);
		}
		
		override protected function draw():void
		{
			if(isInvalid(INVALIDATION_FLAG_SIZE))
			{
				_background.width = actualWidth;
				_background.height = actualHeight;
				
				_headerContainer.x = _headerContainer.y = scaleAndRoundToDpi(5);
				_headerContainer.width = scaleAndRoundToDpi(400);
			}
			
			super.draw()
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
		
		override public function dispose():void
		{
			_background.removeFromParent(true);
			_background = null;
			
			_headerContainer.removeFromParent(true);
			_headerContainer = null;
			
			super.dispose();
		}
	}
}