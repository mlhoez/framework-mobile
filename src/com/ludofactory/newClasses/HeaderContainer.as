/**
 * Created by Maxime on 22/04/2016.
 */
package com.ludofactory.newClasses
{
	
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.manager.MemberManager;
	import com.ludofactory.mobile.core.notification.CustomPopupManager;
	import com.ludofactory.mobile.core.notification.content.neww.PlayerProfilePopupContent;
	
	import feathers.controls.ImageLoader;
	import feathers.core.FeathersControl;
	
	import flash.geom.Rectangle;
	
	import starling.display.Image;
	import starling.events.Event;
	
	/**
	 * The main header
	 */
	public class HeaderContainer extends FeathersControl
	{
		/**
		 * The photo container. */
		private var _photoContainer:TouchableContainer;
		/**
		 * The photo background. */
		private var _photoBackground:Image;
		/**
		 * Theuser photo. */
		private var _userPhoto:ImageLoader;
		
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
			
			_userPhoto = new ImageLoader();
			_userPhoto.maintainAspectRatio = true;
			// small - normal - large - square
			// FIXME Intégrer ça plutôt : "https://graph.facebook.com/" + _facebookId + "/picture?type=large&width=" + int(actualHeight * 0.8) + "&height=" + int(actualHeight * 0.8);
			_userPhoto.source = MemberManager.getInstance().facebookId != 0 ? ("https://graph.facebook.com/" + MemberManager.getInstance().facebookId + "/picture?type=square") : AbstractEntryPoint.assets.getTexture("default-photo");
			
			_photoContainer = new TouchableContainer();
			_photoContainer.addChild(_photoBackground);
			_photoContainer.addChild(_userPhoto);
			_photoContainer.addEventListener(Event.TRIGGERED, onDisplayUserProfilePopup);
			addChild(_photoContainer);
			
			_headerBackground = new Image(AbstractEntryPoint.assets.getTexture("header-container"));
			_headerBackground.scale = GlobalConfig.dpiScale;
			_headerBackground.scale9Grid = new Rectangle(5, 0, 5, _headerBackground.texture.frameHeight);
			addChild(_headerBackground);
		}
		
		override protected function draw():void
		{
			if(isInvalid(INVALIDATION_FLAG_SIZE))
			{
				_headerBackground.width = actualWidth - _photoContainer.width;
				_headerBackground.x = _photoContainer.width;
			}
			
			super.draw();
		}
		
//------------------------------------------------------------------------------------------------------------
//	Handlers
		
		/**
		 * Displays the user profile.
		 * 
		 * @param event
		 */
		private function onDisplayUserProfilePopup(event:Event):void
		{
			CustomPopupManager.addPopup(new PlayerProfilePopupContent());
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
		
		override public function dispose():void
		{
			_photoBackground.removeFromParent(true);
			_photoBackground = null;
			
			_userPhoto.removeFromParent(true);
			_userPhoto = null;
			
			_photoContainer.removeEventListener(Event.TRIGGERED, onDisplayUserProfilePopup);
			_photoContainer.removeFromParent(true);
			_photoContainer = null;
			
			_headerBackground.removeFromParent(true);
			_headerBackground = null;
			
			super.dispose();
		}
		
	}
}