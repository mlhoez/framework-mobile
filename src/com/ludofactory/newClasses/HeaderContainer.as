/**
 * Created by Maxime on 22/04/2016.
 */
package com.ludofactory.newClasses
{
	
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.manager.MemberManager;
	
	import feathers.core.FeathersControl;
	
	import flash.geom.Rectangle;
	
	import starling.display.Image;
	import starling.display.Sprite;
	
	/**
	 * The main header
	 */
	public class HeaderContainer extends FeathersControl
	{
		/**
		 * The photo container. */
		private var _photoContainer:Sprite;
		/**
		 * The photo background. */
		private var _photoBackground;
		/**
		 * Theuser photo. */
		private var _userPhoto:Image;
		
		/**
		 * Header container, will hold the high score and number of trophies in duel mode. */
		private var _headerBackground:Image;
		
		public function HeaderContainer()
		{
			super();
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			_photoBackground = new Image(AbstractEntryPoint.assets.getTexture("photo-container"));
			_photoBackground.scale = GlobalConfig.dpiScale;
			
			if(MemberManager.getInstance().facebookId != 0)
			{
				
			}
			else
			{
				// TODO fetch user Facebook photo
			}
			
			_photoContainer = new Sprite();
			
			
			_headerBackground = new Image(AbstractEntryPoint.assets.getTexture("header-container"));
			_headerBackground.scale = GlobalConfig.dpiScale;
			_headerBackground.scale9Grid = new Rectangle(5, 0, 5, _headerBackground.texture.frameHeight);
			addChild(_headerBackground);
		}
		
		override protected function draw():void
		{
			if(isInvalid(INVALIDATION_FLAG_SIZE))
			{
				_headerBackground.width = actualWidth;
			}
			
			super.draw();
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
		
		override public function dispose():void
		{
			
			
			super.dispose();
		}
		
	}
}