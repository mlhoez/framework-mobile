// =================================================================================================
//
//	Starling Framework
//	Copyright 2011-2014 Gamua. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package com.ludofactory.mobile
{
	
	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.common.utils.Utilities;
	import com.ludofactory.common.utils.log;
	import com.ludofactory.common.utils.roundUp;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.ButtonFactory;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.manager.InfoContent;
	import com.ludofactory.mobile.core.manager.InfoManager;
	import com.ludofactory.mobile.core.manager.MemberManager;
	import com.ludofactory.mobile.core.model.StakeType;
	import com.ludofactory.mobile.core.notification.NotificationPopupManager;
	import com.ludofactory.mobile.core.notification.content.FacebookNotificationContent;
	import com.ludofactory.mobile.core.remoting.Remote;
	import com.ludofactory.mobile.core.storage.Storage;
	import com.ludofactory.mobile.core.storage.StorageConfig;
	import com.ludofactory.mobile.core.theme.Theme;
	import com.ludofactory.mobile.navigation.FacebookManager;
	import com.ludofactory.mobile.navigation.FacebookManagerEventType;
	import com.ludofactory.mobile.navigation.FacebookPublicationData;

	import feathers.controls.LayoutGroup;
	import feathers.core.FeathersControl;
	import feathers.display.Scale9Image;
	import feathers.textures.Scale9Textures;
	
	import flash.filters.BitmapFilterQuality;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	
	import flash.geom.Rectangle;
	
	import starling.display.ButtonState;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.text.TextField;
	import starling.text.TextFieldAutoSize;
	import starling.textures.Texture;
	import starling.utils.HAlign;
	import starling.utils.VAlign;
	
	/** Dispatched when the user triggers the button. Bubbles. */
	[Event(name="triggered", type="starling.events.Event")]
	
	/** A simple button composed of an image and, optionally, text.
	 *
	 *  <p>You can use different textures for various states of the button. If you're providing
	 *  only an up state, the button is simply scaled a little when it is touched.</p>
	 *
	 *  <p>In addition, you can overlay text on the button. To customize the text, you can use
	 *  properties equivalent to those of the TextField class. Move the text to a certain position
	 *  by updating the <code>textBounds</code> property.</p>
	 *
	 *  <p>To react on touches on a button, there is special <code>Event.TRIGGERED</code> event.
	 *  Use this event instead of normal touch events. That way, users can cancel button
	 *  activation by moving the mouse/finger away from the button before releasing.</p>
	 */
	public class FacebookButton extends LayoutGroup
	{
		private static const MAX_DRAG_DIST:Number = 50;
		
	// ----------- Textures
		
		private var _upTextures:Scale9Textures;
		private var _downTextures:Scale9Textures;
		private var _overTextures:Scale9Textures;
		private var _disabledTextures:Scale9Textures;
		
	// ----------- Textures
		
		protected var mContents:Sprite;
		private var mBody:Scale9Image;
		private var mTextField:TextField;
		private var mOverlay:Sprite;
		
	// ----------- Textures
		
		private var mScaleWhenDown:Number;
		private var mAlphaWhenDown:Number = 1.0;
		private var mAlphaWhenDisabled:Number;
		private var mEnabled:Boolean = true;
		private var mState:String;
		private var mTriggerBounds:Rectangle;
		
		private var _icon:Image;
		private var _incentive:Image;
		private var _incentiveLabel:TextField;
		
		private var _buttonType:String;
		private var _publicationData:FacebookPublicationData;
		
		/**
		 * Creates a button with a set of state-textures and (optionally) some text.
		 * Any state that is left 'null' will display the up-state texture. Beware that all
		 * state textures should have the same dimensions.
		 **/
		public function FacebookButton(upState:Scale9Textures, text:String = "", downState:Scale9Textures = null, overState:Scale9Textures = null, disabledState:Scale9Textures = null, buttonType:String = ButtonFactory.FACEBOOK_TYPE_CONNECT, publicationData:FacebookPublicationData = null)
		{
			if (upState == null) throw new ArgumentError("Texture 'upState' cannot be null");
			
			_upTextures = upState;
			_downTextures = downState;
			_overTextures = overState;
			_disabledTextures = disabledState;
			
			_buttonType = buttonType;
			_publicationData = publicationData;
			
			mState = ButtonState.UP;
			
			mBody = new Scale9Image(upState);
			mBody.useSeparateBatch = false;
			mScaleWhenDown = downState ? 1.0 : 0.9;
			mAlphaWhenDisabled = disabledState ? 1.0: 0.5;
			
			//scaleAndRoundToDpi(AbstractGameInfo.LANDSCAPE ? (GlobalConfig.isPhone ? 118 : 148) : 128)
			mTextField = new TextField(5, 5, text, Theme.FONT_SANSITA, scaleAndRoundToDpi(40));
			mTextField.vAlign = VAlign.CENTER;
			mTextField.hAlign = HAlign.CENTER;
			mTextField.touchable = false;
			mTextField.batchable = true;
			mTextField.wordWrap = false;
			mTextField.border = false;
			
			_icon = new Image(AbstractEntryPoint.assets.getTexture("facebook-icon"));
			_icon.scaleX = _icon.scaleY = GlobalConfig.dpiScale;
			
			switch (buttonType)
			{
				case ButtonFactory.FACEBOOK_TYPE_NORMAL:
				{
					// nothing
					
					break;
				}
				case ButtonFactory.FACEBOOK_TYPE_CONNECT:
				{
					// show the incentive no matter what
					createIncentiveImage(Storage.getInstance().getProperty(StorageConfig.PROPERTY_FACEBOOK_CONNECT_REWARD).rewardType,
							Storage.getInstance().getProperty(StorageConfig.PROPERTY_FACEBOOK_CONNECT_REWARD).rewardValue);
					break;
				}
				
				case ButtonFactory.FACEBOOK_TYPE_SHARE:
				{
					if(MemberManager.getInstance().canHaveRewardAfterPublish)
					{
						// only show the incentive if the player did not already get it
						createIncentiveImage(Storage.getInstance().getProperty(StorageConfig.PROPERTY_FACEBOOK_SHARE_REWARD).rewardType,
								Storage.getInstance().getProperty(StorageConfig.PROPERTY_FACEBOOK_SHARE_REWARD).rewardValue);
					}
					
					break;
				}
			}
			
			mContents = new Sprite();
			mContents.addChild(mBody);
			mContents.addChild(_icon);
			if(_incentive)
			{
				mContents.addChild(_incentive);
				mContents.addChild(_incentiveLabel);
			}
			mContents.addChild(mTextField);
			addChild(mContents);
			addEventListener(TouchEvent.TOUCH, onTouch);
			
			this.touchGroup = true;
		}
		
		private function createIncentiveImage(stakeType:int, stakeValue:int):void
		{
			switch(stakeType)
			{
				case StakeType.CREDIT:
				{
					_incentive = new Image(AbstractEntryPoint.assets.getTexture("facebook-credit-incentive"));
					break;
				}
				case StakeType.TOKEN:
				{
					_incentive = new Image(AbstractEntryPoint.assets.getTexture("facebook-token-incentive"));
					break;
				}
				case StakeType.POINT:
				{
					_incentive = new Image(AbstractEntryPoint.assets.getTexture("facebook-point-incentive"));
					break;
				}
			}
			
			if(_incentive)
			{
				_incentive.scaleX = _incentive.scaleY = GlobalConfig.dpiScale;
				
				_incentiveLabel = new TextField(scaleAndRoundToDpi(48), scaleAndRoundToDpi(34), ("+" + stakeValue), Theme.FONT_SANSITA, scaleAndRoundToDpi(22), 0xffffff);
				_incentiveLabel.autoScale = true;
				_incentiveLabel.nativeFilters = [ new GlowFilter(0xa00000, 1, scaleAndRoundToDpi(1.0), scaleAndRoundToDpi(1.0), scaleAndRoundToDpi(5), BitmapFilterQuality.LOW),
					new DropShadowFilter(2, 75, 0xa00000, 0.6, scaleAndRoundToDpi(1), scaleAndRoundToDpi(1), scaleAndRoundToDpi(1), BitmapFilterQuality.LOW) ];
			}
		}
		
		override protected function initialize():void
		{
			// we need at least the height for the horizontal autosize to work
			mTextField.height = scaleAndRoundToDpi(GlobalConfig.isPhone ? (98 - _padding*2) : (108 - _padding*2));
			mTextField.autoSize = TextFieldAutoSize.HORIZONTAL;
			mTextField.autoScale = false;
			mTextField.text = text;
			
			_icon.x = _padding;
			_icon.y = roundUp(((mTextField.height + (_padding * 2)) - _icon.height) * 0.5);
			
			//log("zob = " + mTextField.width + " - " + _padding)
			mBody.validate();
			mBody.width = _icon.width + mTextField.width + (_incentive ? (_incentive.width * 0.5) : 0) + (_padding * 3);
			mBody.height = mTextField.height + (_padding * 2);
			
			mBody.validate();
			if(_incentive)
			{
				_incentive.x = mBody.width - _incentive.width;
				_incentiveLabel.x = _incentive.x + scaleAndRoundToDpi(40);
				_incentiveLabel.y = _incentive.y + scaleAndRoundToDpi(55);
			}
			
			mTextField.autoSize =  TextFieldAutoSize.NONE;
			//mTextField.width = mBody.width - (_padding * 2) - _icon.x - _icon.width;
			mTextField.width = (_incentive ? _incentive.x : mBody.width) - (_padding * 2) - _icon.x - _icon.width;
			mTextField.height = mBody.height - (_padding * 2);
			mTextField.x = _icon.x + _icon.width + _padding;
			mTextField.y = mBody.y + _padding;
			mTextField.autoScale = true;
			mTextField.redraw();

			mBody.width = mBody.width - (_incentive ? (_incentive.width * 0.2) : 0);
		}
		
		private function onTouch(event:TouchEvent):void
		{
			var touch:Touch = event.getTouch(this);
			var isWithinBounds:Boolean;
			
			if (!mEnabled)
			{
				return;
			}
			else if (touch == null)
			{
				state = ButtonState.UP;
			}
			else if (touch.phase == TouchPhase.HOVER)
			{
				state = ButtonState.OVER;
			}
			else if (touch.phase == TouchPhase.BEGAN && mState != ButtonState.DOWN)
			{
				mTriggerBounds = getBounds(stage, mTriggerBounds);
				mTriggerBounds.inflate(MAX_DRAG_DIST, MAX_DRAG_DIST);
				
				state = ButtonState.DOWN;
			}
			else if (touch.phase == TouchPhase.MOVED)
			{
				isWithinBounds = mTriggerBounds.contains(touch.globalX, touch.globalY);
				
				if (mState == ButtonState.DOWN && !isWithinBounds)
				{
					// reset button when finger is moved too far away ...
					state = ButtonState.UP;
				}
				else if (mState == ButtonState.UP && isWithinBounds)
				{
					// ... and reactivate when the finger moves back into the bounds.
					state = ButtonState.DOWN;
				}
			}
			else if (touch.phase == TouchPhase.ENDED && mState == ButtonState.DOWN)
			{
				state = ButtonState.UP;
				if (!touch.cancelled) onTriggered();
			}
		}

		/**
		 * The Facebook button have been touched.
		 */
		private function onTriggered():void
		{
			switch (_buttonType)
			{
				case ButtonFactory.FACEBOOK_TYPE_CONNECT:
				{
					// display the Facebook popup to inform the player of what we will do / grant him
					NotificationPopupManager.addNotification(new FacebookNotificationContent(), onFacebookPopupClosed);
					break;
				}
					
				case ButtonFactory.FACEBOOK_TYPE_SHARE:
				{
					var now:Date = new Date();
					var tokenExpiryDate:Date = new Date( MemberManager.getInstance().getFacebookTokenExpiryTimestamp() );
					if( (MemberManager.getInstance().isLoggedIn() && MemberManager.getInstance().facebookId != 0 && now > tokenExpiryDate) ||
							(MemberManager.getInstance().isLoggedIn() && MemberManager.getInstance().facebookId == 0) || !MemberManager.getInstance().isLoggedIn())
					{
						// if the player is not logged in or does not have its Facebook account associated, we display
						// the popup. When the user closes the popup or is authenticated with Facebook, the callback
						// onFacebookPopupClosed will be called. If the data of the callback is true, it means that the
						// user is authenticated and that we can automatically launch the publication.
						NotificationPopupManager.addNotification(new FacebookNotificationContent(), onFacebookPopupClosed);
					}
					else
					{
						// in all other cases, we can directly publish
						FacebookManager.getInstance().addEventListener(FacebookManagerEventType.PUBLISHED, onPublished);
						FacebookManager.getInstance().publishOnWall(_publicationData);
					}
					break;
				}
					
				case ButtonFactory.FACEBOOK_TYPE_NORMAL:
				{
					// else dispatch an event normally
					dispatchEventWith(Event.TRIGGERED);
					break;
				}
			}
		}

		/**
		 * When the popup is closed.
		 *
		 * If data == true, it means that the user successfully logged in, otherwise he just closed it
		 * with the cross.
		 */
		private function onFacebookPopupClosed(data:Object):void
		{
			if(data)
			{
				// the user authenticated successfully
				if(_buttonType == ButtonFactory.FACEBOOK_TYPE_SHARE)
				{
					// if we are in share mode, it means that in this callback we have to launch the publication
					FacebookManager.getInstance().addEventListener(FacebookManagerEventType.PUBLISHED, onPublished);
					FacebookManager.getInstance().publishOnWall(_publicationData, false);
				}
				else
				{
					// tell the parent that the user authenticated, so that it can refresh / layout again
					dispatchEventWith(FacebookManagerEventType.AUTHENTICATED);
				}
			}
		}

		/**
		 * The player successfully published on his wall.
		 * 
		 * Here we need to tell the parent container that everything was ok.
		 */
		private function onPublished(event:Event):void
		{
			FacebookManager.getInstance().removeEventListener(FacebookManagerEventType.PUBLISHED, onPublished);
			Remote.getInstance().addRewardAfterSharing(onRewarded, onNotRewarded, onNotRewarded, 1, AbstractEntryPoint.screenNavigator.activeScreenID);
			
			
			// inform the parent
			dispatchEventWith(FacebookManagerEventType.PUBLISHED);
		}
		
		private function onRewarded(result:Object):void
		{
			switch(result.code)
			{
				case 0: // problem
				{
					InfoManager.hide(result.txt, InfoContent.ICON_CROSS, InfoManager.DEFAULT_DISPLAY_TIME);
					break;
				}
				case 1: // the user have been rewarded
				{
					InfoManager.hide(result.txt, InfoContent.ICON_CROSS, InfoManager.DEFAULT_DISPLAY_TIME);
					removeIncentive();
					break;
				}
				case 2: // the user have already been rewarded
				{
					InfoManager.hide(result.txt, InfoContent.ICON_CROSS, InfoManager.DEFAULT_DISPLAY_TIME);
					removeIncentive();
					break;
				}
			}
			
			removeIncentive();
		}
		
		private function onNotRewarded(error:Object):void
		{
			InfoManager.hide(_("Une erreur est survenue lors de l'ajout de votre récompense, veuillez réessayer."), InfoContent.ICON_CROSS);
		}
		
		public function removeIncentive():void
		{
			// TODO if the bonus was granted
			_incentiveLabel.removeFromParent(true);
			_incentiveLabel = null;
			
			_incentive.removeFromParent(true);
			_incentive = null;
		}
		
		/** The current state of the button. The corresponding strings are found
		 *  in the ButtonState class. */
		public function get state():String { return mState; }
		public function set state(value:String):void
		{
			mState = value;
			mContents.x = mContents.y = 0;
			mContents.scaleX = mContents.scaleY = mContents.alpha = 1.0;
			
			switch (mState)
			{
				case ButtonState.DOWN:
					setStateTexture(_downTextures);
					mContents.alpha = mAlphaWhenDown;
					mContents.scaleX = mContents.scaleY = mScaleWhenDown;
					mContents.x = (1.0 - mScaleWhenDown) / 2.0 * mBody.width;
					mContents.y = (1.0 - mScaleWhenDown) / 2.0 * mBody.height;
					break;
				case ButtonState.UP:
					setStateTexture(_upTextures);
					break;
				case ButtonState.OVER:
					setStateTexture(_overTextures);
					break;
				case ButtonState.DISABLED:
					setStateTexture(_disabledTextures);
					mContents.alpha = mAlphaWhenDisabled;
					break;
				default:
					throw new ArgumentError("Invalid button state: " + mState);
			}
		}
		
		private function setStateTexture(texture:Scale9Textures):void
		{
			mBody.textures = texture ? texture : _upTextures;
		}
		
		
		
		/** Indicates if the button can be triggered. */
		public function get enabled():Boolean { return mEnabled; }
		public function set enabled(value:Boolean):void
		{
			if (mEnabled != value)
			{
				mEnabled = value;
				state = value ? ButtonState.UP : ButtonState.DISABLED;
			}
		}
		
		/** The text that is displayed on the button. */
		public function get text():String { return mTextField ? mTextField.text : ""; }
		public function set text(value:String):void
		{
			if (value.length == 0)
			{
				if (mTextField)
				{
					mTextField.text = value;
					mTextField.removeFromParent();
				}
			}
			else
			{
				mTextField.text = value;
				
				if (mTextField.parent == null)
					mContents.addChild(mTextField);
			}
		}
		
		/** The overlay sprite is displayed on top of the button contents. It scales with the
		 *  button when pressed. Use it to add additional objects to the button (e.g. an icon). */
		public function get overlay():Sprite
		{
			if (mOverlay == null)
				mOverlay = new Sprite();
			
			mContents.addChild(mOverlay); // make sure it's always on top
			return mOverlay;
		}
		
		override public function set width(value:Number):void
		{
			mBody.width = value - (_incentive ? (_incentive.width * 0.2) : 0);
			
			if(_incentive)
			{
				_incentive.x = value - _incentive.width;
				_incentiveLabel.x = _incentive.x + scaleAndRoundToDpi(40);
				_incentiveLabel.y = _incentive.y + scaleAndRoundToDpi(55);
			}
			
			if(mTextField)
			{
				mTextField.width = (_incentive ? _incentive.x : mBody.width) - (_padding * 2) - _icon.x - _icon.width;
			}
			
			super.width = value;
		}
		
		override public function set height(value:Number):void
		{
			mBody.height = value;
			if(mTextField)
			{
				mTextField.height = value - (_padding * 2);
			}
			
			_icon.scaleX = _icon.scaleY = GlobalConfig.dpiScale;
			_icon.readjustSize();
			_icon.scaleX = _icon.scaleY = Utilities.getScaleToFillHeight(_icon.height, ((value * 0.75) - _padding * 2));
			_icon.readjustSize();
			_icon.y = roundUp((value - _icon.height) * 0.5);
			
			// TODO recaler le textfield en x ensuite
			
			super.height = value;
		}
		
//------------------------------------------------------------------------------------------------0------------
//	Textfield
		
		/**
		 * Sets native filters.
		 * 
		 * @param value
		 */
		public function set nativeFilters(value:Array):void
		{
			mTextField.nativeFilters = value;
		}
		
		private var _padding:Number = 20;
		public function set textPadding(value:Number):void
		{
			_padding = value;
			
			if(mBody is FeathersControl) mBody.validate();
			mTextField.width  = mBody.width - (_padding * 4);
			mTextField.height = mBody.height - (_padding * 2);
			mTextField.x = mBody.x + _padding;
			mTextField.y = mBody.y + _padding;
		}
		
//------------------------------------------------------------------------------------------------------------
//	Get - Set
		
		/** The texture that is displayed when the button is not being touched. */
		public function get upState():Scale9Textures { return _upTextures; }
		public function set upState(value:Scale9Textures):void
		{
			if (value == null)
				throw new ArgumentError("Texture 'upState' cannot be null");
			
			if (_upTextures != value)
			{
				_upTextures = value;
				if ( mState == ButtonState.UP ||
						(mState == ButtonState.DISABLED && _disabledTextures == null) ||
						(mState == ButtonState.DOWN && _downTextures == null) ||
						(mState == ButtonState.OVER && _overTextures == null))
				{
					setStateTexture(value);
				}
			}
		}
		
		/** The texture that is displayed while the button is touched. */
		public function get downState():Scale9Textures { return _downTextures; }
		public function set downState(value:Scale9Textures):void
		{
			if (_downTextures != value)
			{
				_downTextures = value;
				if (mState == ButtonState.DOWN) setStateTexture(value);
			}
		}
		
		/** The texture that is displayed while mouse hovers over the button. */
		public function get overState():Scale9Textures { return _overTextures; }
		public function set overState(value:Scale9Textures):void
		{
			if (_overTextures != value)
			{
				_overTextures = value;
				if (mState == ButtonState.OVER) setStateTexture(value);
			}
		}
		
		/** The texture that is displayed when the button is disabled. */
		public function get disabledState():Scale9Textures { return _disabledTextures; }
		public function set disabledState(value:Scale9Textures):void
		{
			if (_disabledTextures != value)
			{
				_disabledTextures = value;
				if (mState == ButtonState.DISABLED) setStateTexture(value);
			}
		}
		
		/** The name of the font displayed on the button. May be a system font or a registered
		 *  bitmap font. */
		public function get fontName():String { return mTextField ? mTextField.fontName : "Verdana"; }
		public function set fontName(value:String):void { mTextField.fontName = value; }
		
		/** The size of the font. */
		public function get fontSize():Number { return mTextField ? mTextField.fontSize : 12; }
		public function set fontSize(value:Number):void { mTextField.fontSize = value; }
		
		/** The color of the font. */
		public function get fontColor():uint { return mTextField ? mTextField.color : 0x0; }
		public function set fontColor(value:uint):void { mTextField.color = value; }
		
		/** Indicates if the font should be bold. */
		public function get fontBold():Boolean { return mTextField ? mTextField.bold : false; }
		public function set fontBold(value:Boolean):void { mTextField.bold = value; }
		
		/** The vertical alignment of the text on the button. */
		public function get textVAlign():String { return mTextField ? mTextField.vAlign : VAlign.CENTER; }
		public function set textVAlign(value:String):void { mTextField.vAlign = value; }
		
		/** The horizontal alignment of the text on the button. */
		public function get textHAlign():String { return mTextField ? mTextField.hAlign : HAlign.CENTER; }
		public function set textHAlign(value:String):void { mTextField.hAlign = value; }
		
		
		/** The scale factor of the button on touch. Per default, a button without a down state
		 *  texture will be made slightly smaller, while a button with a down state texture
		 *  remains unscaled. */
		public function get scaleWhenDown():Number { return mScaleWhenDown; }
		public function set scaleWhenDown(value:Number):void { mScaleWhenDown = value; }
		
		/** The alpha value of the button on touch. @default 1.0 */
		public function get alphaWhenDown():Number { return mAlphaWhenDown; }
		public function set alphaWhenDown(value:Number):void { mAlphaWhenDown = value; }
		
		/** The alpha value of the button when it is disabled. @default 0.5 */
		public function get alphaWhenDisabled():Number { return mAlphaWhenDisabled; }
		public function set alphaWhenDisabled(value:Number):void { mAlphaWhenDisabled = value; }
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
		
		
		public override function dispose():void
		{
			FacebookManager.getInstance().removeEventListener(FacebookManagerEventType.PUBLISHED, onPublished);
			
			_icon.removeFromParent(true);
			_icon = null;
			
			if(_incentive)
			{
				_incentive.removeFromParent(true);
				_incentive = null;
			}
			
			if(_incentiveLabel)
			{
				_incentiveLabel.removeFromParent(true);
				_incentiveLabel = null;
			}
			
			mTextField.removeFromParent(true);
			mTextField = null;
			
			_publicationData = null;
			
			super.dispose();
		}
		
	}
}