/*
Copyright © 2006-2014 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 12 nov. 2013
*/
package com.ludofactory.mobile.core.test.engine
{
	import com.gamua.flox.Flox;
	import com.greensock.TweenMax;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.AbstractGameInfo;
	import com.ludofactory.mobile.core.Localizer;
	import com.ludofactory.mobile.core.authentication.MemberManager;
	import com.ludofactory.mobile.core.controls.AdvancedScreen;
	import com.ludofactory.mobile.core.controls.ScreenIds;
	import com.ludofactory.mobile.core.test.FacebookManager;
	import com.ludofactory.mobile.core.test.config.GlobalConfig;
	import com.ludofactory.mobile.core.test.push.GameSession;
	import com.ludofactory.mobile.core.theme.Theme;
	import com.milkmangames.nativeextensions.GoViral;
	import com.milkmangames.nativeextensions.events.GVFacebookEvent;
	
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import feathers.controls.Button;
	import feathers.controls.ImageLoader;
	import feathers.controls.Label;
	
	import starling.core.Starling;
	import starling.display.Image;
	import starling.events.Event;
	import starling.utils.formatString;
	
	public class FacebookEndScreen extends AdvancedScreen
	{
		/**
		 * The title. */		
		private var _title:Label;
		
		/**
		 * Facebook icon for the button. */		
		private var _facebookIcon:ImageLoader;
		/**
		 * The publish on Facebook button. */		
		private var _facebookButton:Button;
		/**
		 * The continue button. */		
		private var _continueButton:Button;
		private var _facebookManager:FacebookManager;
		
		/**
		 * The first friend container.*/		
		private var _firstFriend:FacebookFriendElement;
		
		/**
		 * The user container.*/		
		private var _middleFriend:FacebookFriendElement;
		
		/**
		 * The last friend container.
		 * Optional if there is nobody behind. */		
		private var _lastFriend:FacebookFriendElement;
		
		/**
		 * Whether we need to display an animation with
		 * three friends or not. */		
		private var _isThreePeople:Boolean;
		
		/**
		 * The maximum available size used to layout the
		 * containers. */		
		private var _maxSize:Number;
		
		/**
		 * The up arrow. */		
		private var _upArrow:Image;
		
		/**
		 * The down arrow. */		
		private var _downArrow:Image;
		/**
		 * The down arrow. */		
		private var _downArrowBis:Image;
		
		/**
		 * The up arrow. */		
		private var _upValue:Label;
		
		/**
		 * The down arrow. */		
		private var _downValue:Label;
		/**
		 * The down arrow. */		
		private var _downValueBis:Label;
		
		private var _all:Array;
		
		private var _me:FacebookFriendElement;
		private var _friendToSwitch:FacebookFriendElement;
		
		public function FacebookEndScreen()
		{
			super();
			
			_fullScreen = true;
			_appDarkBackground = true;
			_canBack = false;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			_isThreePeople = advancedOwner.screenData.gameData.facebookFriends.length > 2;
			_all = [];
			
			_title = new Label();
			_title.text = Localizer.getInstance().translate("FACEBOOK_END.TITLE");
			addChild(_title);
			_title.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(GlobalConfig.isPhone ? 48 : 50), Theme.COLOR_WHITE, false, false, null, null, null, TextFormatAlign.CENTER);
			
			_facebookManager = new FacebookManager();
			_facebookManager.addEventListener(FacebookManager.ACCOUNT_ASSOCIATED, onAccountAssociated);
			_facebookManager.addEventListener(FacebookManager.AUTHENTICATED, onPublish);
			
			_facebookIcon = new ImageLoader();
			_facebookIcon.source = AbstractEntryPoint.assets.getTexture( GlobalConfig.isPhone ? "facebook-icon" : "facebook-icon-hd");
			_facebookIcon.textureScale = GlobalConfig.dpiScale;
			_facebookIcon.snapToPixels = true;
			
			_facebookButton = new Button();
			_facebookButton.defaultIcon = _facebookIcon;
			_facebookButton.label = Localizer.getInstance().translate( MemberManager.getInstance().getFacebookId() != 0 ? "COMMON.PUBLISH" : "COMMON.ASSOCIATE")
			_facebookButton.addEventListener(starling.events.Event.TRIGGERED, onAssociateOrPublish);
			addChild(_facebookButton);
			_facebookButton.iconPosition = Button.ICON_POSITION_LEFT;
			_facebookButton.gap = scaleAndRoundToDpi(GlobalConfig.isPhone ? 10 : 20);
			
			_continueButton = new Button();
			_continueButton.addEventListener(Event.TRIGGERED, onContinue);
			_continueButton.styleName = Theme.BUTTON_EMPTY;
			_continueButton.label = Localizer.getInstance().translate("COMMON.CONTINUE");
			addChild(_continueButton);
			_continueButton.defaultLabelProperties.textFormat = new TextFormat(Theme.FONT_ARIAL, scaleAndRoundToDpi(30), Theme.COLOR_WHITE, true, true);
			_continueButton.height = _continueButton.minHeight = scaleAndRoundToDpi(60);
			
			_upArrow = new Image( AbstractEntryPoint.assets.getTexture("facebook-up-arrow") );
			_upArrow.scaleX = _upArrow.scaleY = GlobalConfig.dpiScale;
			_upArrow.alpha = 0;
			_upArrow.visible = false;
			addChild(_upArrow);
			
			var valueTextFormat:TextFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(26), Theme.COLOR_WHITE);
			
			_upValue = new Label();
			_upValue.alpha = 0;
			_upValue.visible = false;
			addChild(_upValue);
			_upValue.textRendererProperties.textFormat = valueTextFormat;
			_upValue.textRendererProperties.wordWrap = false;
			
			_downArrow = new Image( AbstractEntryPoint.assets.getTexture("facebook-down-arrow") );
			_downArrow.scaleX = _downArrow.scaleY = GlobalConfig.dpiScale;
			_downArrow.alpha = 0;
			_downArrow.visible = false;
			addChild(_downArrow);
			
			_downValue = new Label();
			_downValue.alpha = 0;
			_downValue.visible = false;
			addChild(_downValue);
			_downValue.textRendererProperties.textFormat = valueTextFormat;
			_downValue.textRendererProperties.wordWrap = false;
			
			_downArrowBis = new Image( AbstractEntryPoint.assets.getTexture("facebook-down-arrow") );
			_downArrowBis.scaleX = _downArrowBis.scaleY = GlobalConfig.dpiScale;
			_downArrowBis.alpha = 0;
			_downArrowBis.visible = false;
			addChild(_downArrowBis);
			
			_downValueBis = new Label();
			_downValueBis.alpha = 0;
			_downValueBis.visible = false;
			addChild(_downValueBis);
			_downValueBis.textRendererProperties.textFormat = valueTextFormat;
			_downValueBis.textRendererProperties.wordWrap = false;
			
			_firstFriend = new FacebookFriendElement( advancedOwner.screenData.gameData.facebookFriends[0], 0);
			addChild(_firstFriend);
			
			_middleFriend = new FacebookFriendElement( advancedOwner.screenData.gameData.facebookFriends[1], 1 );
			addChild(_middleFriend);
			
			if( _isThreePeople )
			{
				_lastFriend = new FacebookFriendElement( advancedOwner.screenData.gameData.facebookFriends[2], 2 );
				addChild(_lastFriend);
			}
			
			// FIXME Intégrer ça plus tard
			// GoViral.goViral.showFacebookRequestDialog("Try out this app!","My App Title");
			
			_all.push(_firstFriend, _middleFriend, _lastFriend);
			Flox.logEvent("Publications Facebook", {Total:"Total"});
		}
		
		override protected function draw():void
		{
			if( isInvalid(INVALIDATION_FLAG_SIZE) )
			{
				_title.y = scaleAndRoundToDpi(40);
				_title.width = actualWidth;
				_title.validate();
				
				_continueButton.validate();
				_continueButton.x = (actualWidth - _continueButton.width) * 0.5;
				_continueButton.y = actualHeight - _continueButton.height - scaleAndRoundToDpi(20);
				
				_facebookButton.width = actualWidth * (GlobalConfig.isPhone ? 0.8 : 0.6);
				_facebookButton.validate();
				_facebookButton.y = _continueButton.y - _facebookButton.height - scaleAndRoundToDpi(10);
				_facebookButton.x = (actualWidth - _facebookButton.width) * 0.5;
				
				var maxSize:Number = _facebookButton.y - scaleAndRoundToDpi(60) /* => padding * 2 */ - _title.y - _title.height;
				var gap:int;
				
				if( _isThreePeople )
				{
					_firstFriend.width = _middleFriend.width = _lastFriend.width = actualWidth * 0.7;
					_firstFriend.x = _middleFriend.x = _lastFriend.x = (actualWidth - _firstFriend.width) * 0.5;
					
					_firstFriend.validate();
					
					gap = (maxSize - (_firstFriend.height * 3)) / 4;
					
					_firstFriend.y = _title.y + _title.height + gap + scaleAndRoundToDpi(30);
					_middleFriend.y = _firstFriend.y + _firstFriend.height + gap;
					_middleFriend.validate();
					_lastFriend.y = _middleFriend.y + _middleFriend.height + gap;
				}
				else
				{
					_firstFriend.width = _middleFriend.width = actualWidth * 0.7;
					_firstFriend.x = _middleFriend.x = (actualWidth - _firstFriend.width) * 0.5;
					
					_firstFriend.validate();
					
					gap = (maxSize - (_firstFriend.height * 2)) / 3;
					
					_firstFriend.y = _title.y + _title.height + gap + scaleAndRoundToDpi(30);
					_middleFriend.y = _firstFriend.y + _firstFriend.height + gap;
				}
				
				TweenMax.delayedCall(1.5, animate);
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Handlers
//------------------------------------------------------------------------------------------------------------
		
		/**
		 * Continue.
		 */		
		private function onContinue(event:Event = null):void
		{
			TweenMax.killAll();
			advancedOwner.showScreen( this.advancedOwner.screenData.gameData.hasReachNewTop ? ScreenIds.PODIUM_SCREEN : (advancedOwner.screenData.gameType == GameSession.TYPE_CLASSIC ? ScreenIds.FREE_GAME_END_SCREEN:ScreenIds.TOURNAMENT_GAME_END_SCREEN) );
		}
		
		private function animate():void
		{
			var switchId:int = advancedOwner.screenData.gameData.facebookPosition - advancedOwner.screenData.gameData.facebookMoving;
			_friendToSwitch = _all[switchId];
			_me = getMe();
			
			_upArrow.x = (_friendToSwitch.x - _upArrow.width) * 0.5;
			_upArrow.y = _friendToSwitch.y + _upArrow.height;
			_upValue.text = _me.getUpValue();
			_upValue.validate();
			_upValue.x = _upArrow.x + (Math.max(_upArrow.width, _upValue.width) - Math.min(_upArrow.width, _upValue.width)) * 0.5;
			_upValue.y = _upArrow.y + _upArrow.height;
			
			_downArrow.x = _friendToSwitch.x + _friendToSwitch.width + _upArrow.x;
			_downArrow.y = _me.y;
			_downValue.text = _friendToSwitch.getUpValue();
			_downValue.validate();
			_downValue.x = _downArrow.x + (Math.max(_downArrow.width, _downValue.width) - Math.min(_downArrow.width, _downValue.width)) * 0.5;
			_downValue.y = _downArrow.y + _downArrow.height;
			
			if( advancedOwner.screenData.gameData.facebookMoving > 1 )
			{
				var middleFriend:FacebookFriendElement = _all[1];
				
				_downArrowBis.x = _friendToSwitch.x + _friendToSwitch.width + _upArrow.x;
				_downArrowBis.y = middleFriend.y;
				_downValueBis.text = middleFriend.getUpValue();
				_downValueBis.validate();
				_downValueBis.x = _downArrowBis.x + (Math.max(_downArrowBis.width, _downValueBis.width) - Math.min(_downArrowBis.width, _downValueBis.width)) * 0.5;
				_downValueBis.y = _downArrowBis.y + _downArrowBis.height;
				
				TweenMax.to(_me, 1, { roundProps:["y"], y:_friendToSwitch.y });
				TweenMax.to(_friendToSwitch, 1, { roundProps:["y"], y:middleFriend.y });
				TweenMax.to(middleFriend, 1, { roundProps:["y"], y:_me.y });
				TweenMax.delayedCall(0.5, _me.setScoreAndRankValue); 
				TweenMax.delayedCall(0.5, _friendToSwitch.setScoreAndRankValue); 
				TweenMax.delayedCall(0.5, middleFriend.setScoreAndRankValue);
				TweenMax.to(_downArrowBis, 1, { delay:1.5, roundProps:["y"], y:(_downArrowBis.y + scaleAndRoundToDpi(50)), autoAlpha:1 });
				TweenMax.to(_downValueBis, 1, { delay:1.5, roundProps:["y"], y:(_downValueBis.y + scaleAndRoundToDpi(50)), autoAlpha:1 });
			}
			else
			{
				TweenMax.to(_me, 1, { roundProps:["y"], y:_friendToSwitch.y });
				TweenMax.to(_friendToSwitch, 1, { roundProps:["y"], y:_me.y });
				TweenMax.delayedCall(0.5, _me.setScoreAndRankValue); 
				TweenMax.delayedCall(0.5, _friendToSwitch.setScoreAndRankValue);
			}
			
			TweenMax.to(_upArrow, 1, { delay:1.5, roundProps:["y"], y:(_upArrow.y - scaleAndRoundToDpi(50)), autoAlpha:1 });
			TweenMax.to(_upValue, 1, { delay:1.5, roundProps:["y"], y:(_upValue.y - scaleAndRoundToDpi(50)), autoAlpha:1 });
			
			TweenMax.to(_downArrow, 1, { delay:1.5, roundProps:["y"], y:(_downArrow.y + scaleAndRoundToDpi(50)), autoAlpha:1 });
			TweenMax.to(_downValue, 1, { delay:1.5, roundProps:["y"], y:(_downValue.y + scaleAndRoundToDpi(50)), autoAlpha:1 });
		}
		
		private function getMe():FacebookFriendElement
		{
			for(var i:int = 0; i < _all.length; i++)
			{
				if( FacebookFriendElement(_all[i]).isMe )
					return FacebookFriendElement(_all[i]);
			}
			throw new Error("[FacebookEndScreen] getMe : can't find me.");
		}
		
//------------------------------------------------------------------------------------------------------------
//	Facebook
		
		private function onAssociateOrPublish(event:starling.events.Event):void
		{
			_facebookManager.associateForPublish();
		}
		
		private function onAccountAssociated(event:starling.events.Event):void
		{
			_facebookButton.label = Localizer.getInstance().translate("COMMON.PUBLISH");
		}
		
		/**
		 * Publish on Facebook.
		 */		
		private function onPublish(event:starling.events.Event):void
		{
			GoViral.goViral.addEventListener(GVFacebookEvent.FB_DIALOG_FINISHED, onPublishOver);
			GoViral.goViral.addEventListener(GVFacebookEvent.FB_DIALOG_FAILED, onPublishCancelledOrFailed);
			GoViral.goViral.addEventListener(GVFacebookEvent.FB_DIALOG_CANCELED, onPublishCancelledOrFailed);
			GoViral.goViral.showFacebookFeedDialog( formatString(Localizer.getInstance().translate("FACEBOOK_FRIEND_PUBLICATION.NAME"), _me.friendName, _friendToSwitch.friendName, AbstractGameInfo.GAME_NAME),
				"", "",
				formatString(Localizer.getInstance().translate("FACEBOOK_FRIEND_PUBLICATION.DESCRIPTION"), _me.currentScore),
				Localizer.getInstance().translate("FACEBOOK_FRIEND_PUBLICATION.LINK"),
				formatString(Localizer.getInstance().translate("FACEBOOK_FRIEND_PUBLICATION.IMAGE"), Localizer.getInstance().lang));
		}
		
		/**
		 * Publication cancelled or failed.
		 */		
		private function onPublishCancelledOrFailed(event:GVFacebookEvent):void
		{
			Flox.logEvent("Publications Facebook", {Etat:"Annulee"});
			GoViral.goViral.removeEventListener(GVFacebookEvent.FB_DIALOG_FINISHED, onPublishOver);
			GoViral.goViral.removeEventListener(GVFacebookEvent.FB_DIALOG_FAILED, onPublishCancelledOrFailed);
			GoViral.goViral.removeEventListener(GVFacebookEvent.FB_DIALOG_CANCELED, onPublishCancelledOrFailed);
		}
		
		/**
		 * Publication posted.
		 */		
		private function onPublishOver(event:GVFacebookEvent):void
		{
			Flox.logEvent("Publications Facebook", {Etat:"Validee"});
			GoViral.goViral.removeEventListener(GVFacebookEvent.FB_DIALOG_FINISHED, onPublishOver);
			GoViral.goViral.removeEventListener(GVFacebookEvent.FB_DIALOG_FAILED, onPublishCancelledOrFailed);
			GoViral.goViral.removeEventListener(GVFacebookEvent.FB_DIALOG_CANCELED, onPublishCancelledOrFailed);
			Starling.juggler.delayCall(onContinue, 1);
			touchable = false;
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose  
//------------------------------------------------------------------------------------------------------------
		
		override public function dispose():void
		{
			_all = [];
			_all = null;
			
			_facebookManager.removeEventListener(FacebookManager.ACCOUNT_ASSOCIATED, onAccountAssociated);
			_facebookManager.removeEventListener(FacebookManager.AUTHENTICATED, onPublish);
			_facebookManager.dispose();
			_facebookManager = null;
			
			_facebookIcon.removeFromParent(true);
			_facebookIcon = null;
			
			_facebookButton.removeEventListener(Event.TRIGGERED, onAssociateOrPublish);
			_facebookButton.removeFromParent(true);
			_facebookButton = null;
			
			_continueButton.removeEventListener(Event.TRIGGERED, onContinue);
			_continueButton.removeFromParent(true);
			_continueButton = null;
			
			super.dispose();
		}
	}
}