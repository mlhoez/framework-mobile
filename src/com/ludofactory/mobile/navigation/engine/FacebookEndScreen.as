/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 12 nov. 2013
*/
package com.ludofactory.mobile.navigation.engine
{

	import com.greensock.TweenMax;
	import com.ludofactory.common.gettext.LanguageManager;
	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.ButtonFactory;
	import com.ludofactory.mobile.FacebookButton;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.AbstractGameInfo;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.controls.AdvancedScreen;
	import com.ludofactory.mobile.core.model.GameMode;
	import com.ludofactory.mobile.core.model.ScreenIds;
	import com.ludofactory.mobile.core.theme.Theme;
	import com.ludofactory.mobile.navigation.FacebookManagerEventType;

	import feathers.controls.Button;
	import feathers.controls.Label;

	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

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
		 * The publish on Facebook button. */		
		private var _facebookButton:FacebookButton;
		/**
		 * The continue button. */		
		private var _continueButton:Button;
		
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
			_title.text = _("Bravo !\nVous avez dépassé un ami !");
			addChild(_title);
			_title.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(GlobalConfig.isPhone ? 48 : 50), Theme.COLOR_WHITE, false, false, null, null, null, TextFormatAlign.CENTER);
			
			_continueButton = new Button();
			_continueButton.addEventListener(Event.TRIGGERED, onContinue);
			_continueButton.styleName = Theme.BUTTON_EMPTY;
			_continueButton.label = _("Continuer");
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
			
			_all.push(_firstFriend, _middleFriend, _lastFriend);
			var switchId:int = advancedOwner.screenData.gameData.facebookPosition - advancedOwner.screenData.gameData.facebookMoving;
			_friendToSwitch = _all[switchId];
			_me = getMe();
			
			_facebookButton = ButtonFactory.getFacebookButton(_("Partager"), ButtonFactory.FACEBOOK_TYPE_SHARE, formatString(_("{0} a dépassé {1} sur le jeu {2}"), _me.friendName, _friendToSwitch.friendName, AbstractGameInfo.GAME_NAME),
					"",
					formatString(_("Avec un score de {0}, je pense devenir rapidement le meilleur sur ce jeu."), _me.currentScore),
					_("http://www.ludokado.com/"),
					formatString(_("http://img.ludokado.com/img/frontoffice/{0}/mobile/publication/pyramid.jpg"), LanguageManager.getInstance().lang));
			_facebookButton.addEventListener(FacebookManagerEventType.PUBLISHED, onPublished);
			addChild(_facebookButton);
		}
		
		override protected function draw():void
		{
			if( isInvalid(INVALIDATION_FLAG_SIZE) )
			{
				_title.y = scaleAndRoundToDpi(GlobalConfig.isPhone ? 20 : 40);
				_title.width = actualWidth;
				_title.validate();
				
				_continueButton.validate();
				_continueButton.x = (actualWidth - _continueButton.width) * 0.5;
				_continueButton.y = actualHeight - _continueButton.height - scaleAndRoundToDpi(GlobalConfig.isPhone ? 10 : 20);
				
				_facebookButton.width = actualWidth * (AbstractGameInfo.LANDSCAPE ? (GlobalConfig.isPhone ? 0.6 : 0.5) : (GlobalConfig.isPhone ? 0.8 : 0.6) );
				_facebookButton.validate();
				_facebookButton.y = _continueButton.y - _facebookButton.height - scaleAndRoundToDpi(GlobalConfig.isPhone ? 0 : 10);
				_facebookButton.x = (actualWidth - _facebookButton.width) * 0.5;
				
				var maxSize:Number = _facebookButton.y - scaleAndRoundToDpi(AbstractGameInfo.LANDSCAPE ? 40 : 60) /* => padding * 2 */ - _title.y - _title.height;
				var gap:int;
				
				if( _isThreePeople )
				{
					_firstFriend.width = _middleFriend.width = _lastFriend.width = actualWidth * 0.7;
					_firstFriend.x = _middleFriend.x = _lastFriend.x = (actualWidth - _firstFriend.width) * 0.5;
					
					_firstFriend.validate();
					
					gap = (maxSize - (_firstFriend.height * 3)) / 4;
					
					_firstFriend.y = _title.y + _title.height + gap + scaleAndRoundToDpi(AbstractGameInfo.LANDSCAPE ? 20 : 30);
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
					
					_firstFriend.y = _title.y + _title.height + gap + scaleAndRoundToDpi(AbstractGameInfo.LANDSCAPE ? 20 : 30);
					_middleFriend.y = _firstFriend.y + _firstFriend.height + gap;
				}
				
				TweenMax.delayedCall(1.5, animate);
			}
			
			super.draw();
		}
		
//------------------------------------------------------------------------------------------------------------
//	Handlers
//------------------------------------------------------------------------------------------------------------
		
		/**
		 * Continue.
		 */		
		private function onContinue(event:Event = null):void
		{
			advancedOwner.showScreen( this.advancedOwner.screenData.gameData.hasReachNewTop ? ScreenIds.PODIUM_SCREEN : (advancedOwner.screenData.gameType == GameMode.SOLO ? ScreenIds.SOLO_END_SCREEN:ScreenIds.TOURNAMENT_END_SCREEN) );
		}
		
		private function animate():void
		{
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
		
		/**
		 * Publication posted.
		 */		
		private function onPublished(event:Event):void
		{
			_facebookButton.removeEventListener(FacebookManagerEventType.PUBLISHED, onPublished);
			Starling.juggler.delayCall(onContinue, 1);
			touchable = false;
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
		
		override public function dispose():void
		{
			TweenMax.killDelayedCallsTo(animate);
			
			_all = [];
			_all = null;
			
			_me = null;
			_friendToSwitch = null;
			
			TweenMax.killDelayedCallsTo(_firstFriend.setScoreAndRankValue);
			TweenMax.killTweensOf(_firstFriend);
			_firstFriend.removeFromParent(true);
			_firstFriend = null;
			
			TweenMax.killDelayedCallsTo(_middleFriend.setScoreAndRankValue);
			TweenMax.killTweensOf(_middleFriend);
			_middleFriend.removeFromParent(true);
			_middleFriend = null;
			
			if(_lastFriend)
			{
				TweenMax.killDelayedCallsTo(_lastFriend.setScoreAndRankValue);
				TweenMax.killTweensOf(_lastFriend);
				_lastFriend.removeFromParent(true);
				_lastFriend = null;
			}
			
			_title.removeFromParent(true);
			_title = null;

			_facebookButton.removeEventListener(FacebookManagerEventType.PUBLISHED, onPublished);
			_facebookButton.removeFromParent(true);
			_facebookButton = null;
			
			_continueButton.removeEventListener(Event.TRIGGERED, onContinue);
			_continueButton.removeFromParent(true);
			_continueButton = null;
			
			TweenMax.killTweensOf(_downArrow);
			_downArrow.removeFromParent(true);
			_downArrow = null;
			
			TweenMax.killTweensOf(_downValue);
			_downValue.removeFromParent(true);
			_downValue = null;
			
			TweenMax.killTweensOf(_downArrowBis);
			_downArrowBis.removeFromParent(true);
			_downArrowBis = null;
			
			TweenMax.killTweensOf(_downValueBis);
			_downValueBis.removeFromParent(true);
			_downValueBis = null;
			
			TweenMax.killTweensOf(_upArrow);
			_upArrow.removeFromParent(true);
			_upArrow = null;
			
			TweenMax.killTweensOf(_upValue);
			_upValue.removeFromParent(true);
			_upValue = null;
			
			super.dispose();
		}
	}
}