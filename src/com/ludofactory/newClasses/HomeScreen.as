/**
 * Created by Maxime on 22/04/2016.
 */
package com.ludofactory.newClasses
{
	
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.controls.AdvancedScreen;
	
	/**
	 * Home screen.
	 */
	public class HomeScreen extends AdvancedScreen
	{
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
			
			_headerContainer = new HeaderContainer();
			addChild(_headerContainer);
		}
		
		override protected function draw():void
		{
			if(isInvalid(INVALIDATION_FLAG_SIZE))
			{
				_headerContainer.x = _headerContainer.y = scaleAndRoundToDpi(5);
				_headerContainer.width = scaleAndRoundToDpi(200);
			}
			
			super.draw()
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
		
		override public function dispose():void
		{
			
			super.dispose();
		}
	}
}