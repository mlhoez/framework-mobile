/**
 * Created by Maxime on 22/04/2016.
 */
package com.ludofactory.mobileNew
{
	
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.events.MobileEventTypes;
	import com.ludofactory.mobile.core.manager.MemberManager;
	import com.ludofactory.mobile.core.notification.CustomPopupManager;
	import com.ludofactory.mobile.core.notification.content.neww.PlayerProfilePopupContent;
	import com.ludofactory.mobile.core.push.AbstractElementToPush;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import feathers.core.FeathersControl;
	
	import flash.geom.Rectangle;
	
	import starling.display.Image;
	import starling.events.Event;
	import starling.text.TextField;
	import starling.text.TextFieldAutoSize;
	import starling.text.TextFormat;
	import starling.utils.Align;
	
	/**
	 * The main header
	 */
	public class HeaderContainer extends FeathersControl
	{
		private static var MAX_USER_NAME_WIDTH:int = 150;
		
		/**
		 * The photo container. */
		private var _photoContainer:IconButton;
		
		/**
		 * Header container, will hold the high score and number of trophies in duel mode. */
		private var _headerBackground:Image;
		/**
		 * The user name. */
		private var _userName:TextField;
		
		public function HeaderContainer()
		{
			super();
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			// small - normal - large - square
			// FIXME Intégrer ça plutôt : "https://graph.facebook.com/" + _facebookId + "/picture?type=large&width=" + int(actualHeight * 0.8) + "&height=" + int(actualHeight * 0.8);
			_photoContainer = new IconButton(AbstractEntryPoint.assets.getTexture("photo-container"), null, MemberManager.getInstance().facebookId != 0 ? ("https://graph.facebook.com/" + MemberManager.getInstance().facebookId + "/picture?type=square") : AbstractEntryPoint.assets.getTexture("default-photo"));
			_photoContainer.addEventListener(Event.TRIGGERED, onDisplayUserProfilePopup);
			addChild(_photoContainer);
			
			_headerBackground = new Image(AbstractEntryPoint.assets.getTexture("header-container"));
			_headerBackground.touchable = false;
			_headerBackground.scale = GlobalConfig.dpiScale;
			_headerBackground.scale9Grid = new Rectangle(5, 0, 5, _headerBackground.texture.frameHeight);
			addChild(_headerBackground);
			
			// Max width is 150
			_userName = new TextField(scaleAndRoundToDpi(150), _headerBackground.height, "", new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(30), 0xffffff, Align.LEFT));
			_userName.border = true;
			_userName.wordWrap = false;
			addChild(_userName);
			
			MemberManager.getInstance().addEventListener(MobileEventTypes.MEMBER_UPDATED, onMemberUpdated);
		}
		
		override protected function draw():void
		{
			if(isInvalid(INVALIDATION_FLAG_SIZE))
			{
				//_headerBackground.width = actualWidth - _photoContainer.width;
				_headerBackground.x = _photoContainer.width;
				_userName.x = _photoContainer.x + _photoContainer.width + scaleAndRoundToDpi(5);
			}
			
			if(isInvalid(INVALIDATION_FLAG_DATA)) // at first and when the member is updated
			{
				// readjust the user name field
				_userName.autoScale = false;
				_userName.autoSize = TextFieldAutoSize.HORIZONTAL;
				_userName.text = MemberManager.getInstance().pseudo;
				if(_userName.width > scaleAndRoundToDpi(MAX_USER_NAME_WIDTH))
				{
					_userName.autoSize = TextFieldAutoSize.NONE;
					_userName.width = scaleAndRoundToDpi(MAX_USER_NAME_WIDTH);
					_userName.autoScale = true;
				}
				
				// TODO replace the highscore and trophies container here
				
				// then resize the background accordingly
				_headerBackground.width = _userName.width + scaleAndRoundToDpi(10); // 5 for the _userName left padding, of added to the right of it
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
		
		/**
		 * When the member have been updated.
		 * 
		 * @param event
		 */
		private function onMemberUpdated(event:Event):void
		{
			invalidate(INVALIDATION_FLAG_DATA);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
		
		override public function dispose():void
		{
			MemberManager.getInstance().removeEventListener(MobileEventTypes.MEMBER_UPDATED, onMemberUpdated);
			
			_photoContainer.removeEventListener(Event.TRIGGERED, onDisplayUserProfilePopup);
			_photoContainer.removeFromParent(true);
			_photoContainer = null;
			
			_headerBackground.removeFromParent(true);
			_headerBackground = null;
			
			super.dispose();
		}
		
	}
}