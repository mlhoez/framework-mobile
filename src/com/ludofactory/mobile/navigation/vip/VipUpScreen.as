/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 8 janv. 2014
*/
package com.ludofactory.mobile.navigation.vip
{
	
	import com.gamua.flox.Flox;
	import com.greensock.TweenMax;
	import com.greensock.easing.Back;
	import com.greensock.easing.Bounce;
	import com.greensock.easing.Linear;
	import com.ludofactory.common.gettext.LanguageManager;
	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.common.utils.roundUp;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.AbstractGameInfo;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.controls.AdvancedScreen;
	import com.ludofactory.mobile.core.controls.ArrowGroup;
	import com.ludofactory.mobile.core.manager.MemberManager;
	import com.ludofactory.mobile.core.manager.NavigationManager;
	import com.ludofactory.mobile.core.model.ScreenIds;
	import com.ludofactory.mobile.core.storage.Storage;
	import com.ludofactory.mobile.core.storage.StorageConfig;
	import com.ludofactory.mobile.core.theme.Theme;
	import com.ludofactory.mobile.navigation.FacebookManager;
	import com.milkmangames.nativeextensions.GoViral;
	import com.milkmangames.nativeextensions.events.GVFacebookEvent;
	
	import feathers.controls.Button;
	import feathers.controls.ImageLoader;
	import feathers.controls.Label;
	
	import flash.filters.DropShadowFilter;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import starling.core.Starling;
	import starling.display.Image;
	import starling.events.Event;
	import starling.extensions.PDParticleSystem;
	import starling.utils.deg2rad;
	import starling.utils.formatString;
	
	public class VipUpScreen extends AdvancedScreen
	{
		/**
		 * Podium glow */		
		private var _podiumGlow:Image;
		/**
		 * The rank icon. */		
		private var _rankImage:ImageLoader;
		
		/**
		 * The congratulation message. */		
		private var _message:Label;
		
		/**
		 * The button that redirects to the home screen. */		
		private var _moreButton:Button;
		
		/**
		 * A button that edirects to the VIP screen. */		
		private var _continueButtonTrue:ArrowGroup;
		
		/**
		 * The player rank data. */		
		private var _playerRankData:VipData;
		
		/**
		 * The label used to layout the whole thing before the
		 * ran name is animated. */		
		private var _layoutLabel:Label;
		
		/**
		 *  */		
		private var _animArray:Array;
		
		/**
		 * Facebook icon for the button. */		
		private var _facebookIcon:ImageLoader;
		/**
		 * Facebook button that will associate the
		 * account or directly publish, depending on
		 * the actual state. */		
		private var _facebookButton:Button;
		
		public function VipUpScreen()
		{
			super();
			
			_canBack = false;
			_blueBackground = true;
			_fullScreen = true;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			var temp:Array = JSON.parse( Storage.getInstance().getProperty( (MemberManager.getInstance().getGiftsEnabled() ? StorageConfig.PROPERTY_VIP : StorageConfig.PROPERTY_VIP_WITHOUT_GIFTS) )[LanguageManager.getInstance().lang] ) as Array;
			for(var i:int = 0; i < temp.length; i++)
			{
				if( i == MemberManager.getInstance().rank - 1 )
				{
					_playerRankData = new VipData(temp[i]);
					break;
				}
			}
			
			_podiumGlow = new Image( AbstractEntryPoint.assets.getTexture("HighScoreGlow") );
			_podiumGlow.alpha = 0;
			_podiumGlow.scaleX = _podiumGlow.scaleY = (GlobalConfig.stageWidth * (AbstractGameInfo.LANDSCAPE ? 0.5 : 1)) / _podiumGlow.width;
			_podiumGlow.alignPivot();
			addChild( _podiumGlow );
			
			_rankImage = new ImageLoader();
			_rankImage.source = AbstractEntryPoint.assets.getTexture("Rank-" + MemberManager.getInstance().rank);
			//_rankImage.textureScale = GlobalConfig.dpiScalez; // Pose un problème !
			addChild( _rankImage );
			
			_message = new Label();
			_message.alpha = 0;
			_message.visible = false;
			_message.text = _("Bravo !\nVous êtes maintenant");
			addChild(_message);
			_message.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(GlobalConfig.isPhone ? 54 : 80), Theme.COLOR_WHITE, false, false, null, null, null, TextFormatAlign.CENTER);
			_message.textRendererProperties.nativeFilters = [ new DropShadowFilter(0, 75, 0x000000, 1, 7, 7) ];
			
			_moreButton = new Button();
			_moreButton.alpha = 0;
			_moreButton.visible = false;
			_moreButton.label = _("Voir mes privilèges");
			_moreButton.addEventListener(Event.TRIGGERED, onKnowMore);
			addChild(_moreButton);
			
			_continueButtonTrue = new ArrowGroup( _("Continuer") );
			_continueButtonTrue.alpha = 0;
			_continueButtonTrue.visible = false;
			_continueButtonTrue.addEventListener(Event.TRIGGERED, onContinue);
			addChild(_continueButtonTrue);
			
			_layoutLabel = new Label();
			_layoutLabel.touchable = false;
			_layoutLabel.alpha = 0;
			_layoutLabel.visible = false;
			_layoutLabel.text = _playerRankData.rankName.charAt(i);
			addChild(_layoutLabel);
			_layoutLabel.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(GlobalConfig.isPhone ? 80 : 120), Theme.COLOR_WHITE);
			_layoutLabel.textRendererProperties.wordWrap = false;
			_layoutLabel.textRendererProperties.nativeFilters = [ new DropShadowFilter(0, 75, 0x000000, 1, 7, 7) ];
			
			if( MemberManager.getInstance().isLoggedIn() && GoViral.isSupported() && GoViral.goViral.isFacebookSupported() )
			{
				FacebookManager.getInstance().addEventListener(FacebookManager.ACCOUNT_ASSOCIATED, onAccountAssociated);
				FacebookManager.getInstance().addEventListener(FacebookManager.AUTHENTICATED, onPublish);
				
				_facebookIcon = new ImageLoader();
				_facebookIcon.source = AbstractEntryPoint.assets.getTexture( GlobalConfig.isPhone ? "facebook-icon" : "facebook-icon-hd");
				_facebookIcon.textureScale = GlobalConfig.dpiScale;
				_facebookIcon.snapToPixels = true;
				
				_facebookButton = new Button();
				_facebookButton.alpha = 0;
				_facebookButton.defaultIcon = _facebookIcon;
				_facebookButton.label = MemberManager.getInstance().facebookId != 0 ? _("Publier") : _("Associer");
				_facebookButton.addEventListener(Event.TRIGGERED, onAssociateOrPublish);
				addChild(_facebookButton);
				_facebookButton.iconPosition = Button.ICON_POSITION_LEFT;
				_facebookButton.gap = scaleAndRoundToDpi(GlobalConfig.isPhone ? 10 : 20);
			}
			
			TweenMax.delayedCall(1, animateBase);
		}
		
		private var _savecRankImageScaleX:Number = 1;
		private var _savecRankImageScaleY:Number = 1;
		
		override protected function draw():void
		{
			if( isInvalid(INVALIDATION_FLAG_SIZE) )
			{
				if( AbstractGameInfo.LANDSCAPE )
				{
					_rankImage.scaleX = _rankImage.scaleY = 1;
					_rankImage.width = actualWidth * (GlobalConfig.isPhone ? 0.35 : 0.35);
					_rankImage.validate();
					_savecRankImageScaleX = _rankImage.scaleX;
					_savecRankImageScaleY = _rankImage.scaleY;
					_rankImage.alignPivot();
					_rankImage.x = _podiumGlow.x = roundUp((actualWidth * (GlobalConfig.isPhone ? 0.4 : 0.5)) * 0.5);
					
					_moreButton.width = actualWidth * (GlobalConfig.isPhone ? 0.48 : 0.35);
					_moreButton.x = (actualWidth - _moreButton.width - (_facebookButton ? _facebookButton.width : 0) - scaleAndRoundToDpi(_facebookButton ? 10 : 0)) * 0.5;
					_moreButton.validate();
					
					_continueButtonTrue.validate();
					_continueButtonTrue.x = (actualWidth - _continueButtonTrue.width) * 0.5;
					_continueButtonTrue.y = actualHeight - _continueButtonTrue.height - scaleAndRoundToDpi( GlobalConfig.isPhone ? 10 : 20 );
					_moreButton.y = _continueButtonTrue.y - _moreButton.height - scaleAndRoundToDpi( GlobalConfig.isPhone ? 10 : 20 );
					
					if( _facebookButton )
					{
						_facebookButton.width = _moreButton.width;
						_facebookButton.x = _moreButton.x + _moreButton.width + scaleAndRoundToDpi(10);
						_facebookButton.validate();
						_facebookButton.y = _moreButton.y
					}
					
					_message.width = actualWidth * 0.6;
					_message.validate();
					_layoutLabel.validate();
					_message.x = _rankImage.x + (_rankImage.width * 0.5) + (((actualWidth - _rankImage.x - (_rankImage.width * 0.5)) - _message.width) * 0.5);
					
					_message.y = (actualHeight - _message.height - _layoutLabel.height - scaleAndRoundToDpi(GlobalConfig.isPhone ? 20 : 40) - _moreButton.height - _continueButtonTrue.height) * 0.5;
					_layoutLabel.y = _message.y + _message.height + scaleAndRoundToDpi(GlobalConfig.isPhone ? 20 : 40) + (_layoutLabel.height * 0.5);
					
					_rankImage.y = _podiumGlow.y = _message.y + ((_message.height + _layoutLabel.height + scaleAndRoundToDpi(GlobalConfig.isPhone ? 20 : 40)) * 0.5);
					
					_rankImage.scaleX = _rankImage.scaleY = 0;
				}
				else
				{
					_rankImage.scaleX = _rankImage.scaleY = 1;
					_rankImage.width = actualWidth * (GlobalConfig.isPhone ? 0.4 : 0.30);
					_rankImage.validate();
					_rankImage.alignPivot();
					_rankImage.y = _podiumGlow.y = scaleAndRoundToDpi( (_rankImage.height * 0.5) + (GlobalConfig.isPhone ? 100 : 100) );
					_rankImage.x = _podiumGlow.x = (actualWidth * 0.5) << 0;
					
					//_moreButton.height = scaleAndRoundToDpi(118);
					_moreButton.width = actualWidth * (GlobalConfig.isPhone ? 0.9 : 0.7);
					_moreButton.x = (actualWidth - (actualWidth * (GlobalConfig.isPhone ? 0.9 : 0.7))) * 0.5;
					_moreButton.validate();
					_continueButtonTrue.validate();
					_continueButtonTrue.x = (actualWidth - _continueButtonTrue.width) * 0.5;
					
					_continueButtonTrue.y = actualHeight - _continueButtonTrue.height - scaleAndRoundToDpi( GlobalConfig.isPhone ? 10 : 20 );
					_moreButton.y = _continueButtonTrue.y - _moreButton.height - scaleAndRoundToDpi( GlobalConfig.isPhone ? 0 : 20 );
					
					if( _facebookButton )
					{
						_facebookButton.width = actualWidth * (GlobalConfig.isPhone ? 0.9 : 0.7);
						_facebookButton.x = (actualWidth - (actualWidth * (GlobalConfig.isPhone ? 0.9 : 0.7))) * 0.5;
						_facebookButton.validate();
						_facebookButton.y = _moreButton.y - _facebookButton.height - scaleAndRoundToDpi( GlobalConfig.isPhone ? 10 : 20 );
					}
					
					_message.width = actualWidth * 0.9;
					_message.validate();
					_layoutLabel.validate();
					_message.x = (actualWidth - (actualWidth * 0.9)) * 0.5;
					_message.y = (_rankImage.y + (_rankImage.height * 0.5)) + scaleAndRoundToDpi(GlobalConfig.isPhone ? 10 : 20) + ( ((_moreButton.y - (_facebookButton ? _facebookButton.height : 0) - _rankImage.y - (_rankImage.height * 0.5)) - (_message.height + _layoutLabel.height - scaleAndRoundToDpi(GlobalConfig.isPhone ? 30 : 60))) * 0.5) << 0;
					_layoutLabel.y = _message.y + _message.height + scaleAndRoundToDpi(GlobalConfig.isPhone ? 20 : 40) + (_layoutLabel.height * 0.5);
					
					_rankImage.scaleX = _rankImage.scaleY = 0;
				}
			}
			
			super.draw();
		}
		
		private function animateBase():void
		{
			TweenMax.to(_podiumGlow, 0.75, { delay:0.75, alpha:1 } );
			TweenMax.to(_podiumGlow, 10, { delay:0.75, rotation:deg2rad(360), ease:Linear.easeNone, repeat:-1 } );
			TweenMax.to(_message, 0.75, { delay:1, autoAlpha:1, onComplete:animate } );
			TweenMax.to(_rankImage, 0.75, { scaleX:_savecRankImageScaleX, scaleY:_savecRankImageScaleY, ease:Back.easeOut } );
		}
		
		private function animate():void
		{
			var scoreStringLength:int = _playerRankData.rankName.length;
			var scoreLabel:Label;
			
			var startX:int;
			var delay:Number = 0;
			
			var step:int = 0;
			
			var charWidths:Array = [];
			var totalLabelWdth:int = 0;
			var particleSystem:PDParticleSystem;
			
			// first we need to calculate the width of each single char
			// so that we can position evrything correctly without gap
			_animArray = [];
			for( var i:int = 0; i < scoreStringLength; i++)
			{
				scoreLabel = new Label();
				scoreLabel.touchable = false;
				scoreLabel.alpha = 1;
				scoreLabel.scaleX = scoreLabel.scaleY = 1;
				scoreLabel.text = _playerRankData.rankName.charAt(i);
				addChild(scoreLabel);
				scoreLabel.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(GlobalConfig.isPhone ? 80 : 120), Theme.COLOR_WHITE); // 0xff8500 = orange du podium
				scoreLabel.textRendererProperties.wordWrap = false;
				scoreLabel.textRendererProperties.nativeFilters = [ new DropShadowFilter(0, 75, 0x000000, 1, 7, 7) ];
				scoreLabel.validate();
				scoreLabel.alignPivot();
				
				particleSystem = new PDParticleSystem(Theme.particleSparklesXml, Theme.particleSparklesTexture);
				particleSystem.touchable = false;
				particleSystem.maxNumParticles = 500;
				particleSystem.emitterXVariance = scoreLabel.width * 0.25;
				particleSystem.emitterYVariance = scoreLabel.height * 0.25;
				//particleSystem.scaleX = particleSystem.scaleY = GlobalConfig.dpiScalez;
				addChild(particleSystem);
				Starling.juggler.add(particleSystem);
				
				_animArray.push( { label:scoreLabel, particles:particleSystem } );
				charWidths.push(scoreLabel.width - 2); // 2 is the gutter Flash Player adds
				totalLabelWdth += scoreLabel.width;
			}
			if( AbstractGameInfo.LANDSCAPE)
				startX = _rankImage.x + (_rankImage.width * 0.5) + (actualWidth - _rankImage.x - (_rankImage.width * 0.5) - totalLabelWdth) * 0.5;
			else
				startX = (actualWidth - totalLabelWdth) * 0.5;
			
			for( i = 0; i < scoreStringLength; i++)
			{
				particleSystem = _animArray[i].particles;
				
				scoreLabel = _animArray[i].label;
				scoreLabel.x = particleSystem.emitterX = startX + step + (charWidths[i] * 0.5);
				scoreLabel.y = particleSystem.emitterY = _layoutLabel.y;
				step += charWidths[i];
				TweenMax.delayedCall(delay + 0.15, particleSystem.start, [0.05]);
				TweenMax.from(scoreLabel, 0.5, { delay:delay, scaleX:2, scaleY:2, alpha:0, ease:Bounce.easeOut /*, onComplete:removeLabel, onCompleteParams:[scoreLabel]*/ });
				delay += 0.15;
			}
			
			TweenMax.delayedCall((delay + 0.5), displayButtons);
			
			scoreLabel = null;
		}
		
		private function displayButtons():void
		{
			if( _facebookButton )
				TweenMax.allTo([_facebookButton, _continueButtonTrue, _moreButton], 0.75, { autoAlpha:1 });
			else
				TweenMax.allTo([_continueButtonTrue, _moreButton], 0.75, { autoAlpha:1 });
		}
		
//------------------------------------------------------------------------------------------------------------
//	Handlers
//------------------------------------------------------------------------------------------------------------
		
		private function onContinue(event:Event):void
		{
			advancedOwner.showScreen(ScreenIds.HOME_SCREEN);
		}
		
		private function onKnowMore(event:Event):void
		{
			NavigationManager.resetNavigation(true);
			advancedOwner.showScreen(ScreenIds.VIP_SCREEN);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Facebook
		
		private function onAssociateOrPublish(event:Event):void
		{
			FacebookManager.getInstance().associateForPublish();
		}
		
		private function onAccountAssociated(event:Event):void
		{
			_facebookButton.label = _("Publier");
		}
		
		/**
		 * Publish on Facebook.
		 */		
		private function onPublish(event:Event):void
		{
			GoViral.goViral.addEventListener(GVFacebookEvent.FB_DIALOG_FINISHED, onPublishOver);
			GoViral.goViral.addEventListener(GVFacebookEvent.FB_DIALOG_FAILED, onPublishCancelledOrFailed);
			GoViral.goViral.addEventListener(GVFacebookEvent.FB_DIALOG_CANCELED, onPublishCancelledOrFailed);
			
			GoViral.goViral.showFacebookShareDialog( formatString(_("{0} est maintenant {1}"), (event.data.nom + " " + event.data.prenom), _playerRankData.rankName),
				"",
				_("Avec ce nouveau rang, je peux bénéficier de nouveaux avantages pour gagner encore plus vite."),
				_("http://www.ludokado.com/"),
				formatString(_("http://img.ludokado.com/img/frontoffice/{0}/mobile/publication/publication_vip_{1}.jpg"), LanguageManager.getInstance().lang, _playerRankData.id));
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
			_facebookButton.visible = false;
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
//------------------------------------------------------------------------------------------------------------
		
		override public function dispose():void
		{
			TweenMax.killDelayedCallsTo(animateBase);
			TweenMax.killDelayedCallsTo(displayButtons);
					
			TweenMax.killTweensOf(_podiumGlow);
			_podiumGlow.removeFromParent(true);
			_podiumGlow = null;
			
			TweenMax.killTweensOf(_rankImage);
			_rankImage.removeFromParent(true);
			_rankImage = null;
			
			TweenMax.killTweensOf(_message);
			_message.removeFromParent(true);
			_message = null;
			
			TweenMax.killTweensOf(_moreButton);
			_moreButton.removeEventListener(Event.TRIGGERED, onKnowMore);
			_moreButton.removeFromParent(true);
			_moreButton = null;
			
			TweenMax.killTweensOf(_continueButtonTrue);
			_continueButtonTrue.removeEventListener(Event.TRIGGERED, onContinue);
			_continueButtonTrue.removeFromParent(true);
			_continueButtonTrue = null;
			
			_layoutLabel.removeFromParent(true);
			_layoutLabel = null;
			
			_playerRankData = null;
			
			var label:Label;
			var particles:PDParticleSystem;
			for each(var element:Object in _animArray)
			{
				label = element.label;
				delete element["label"];
				TweenMax.killTweensOf(label);
				label.removeFromParent(true);
				label = null;
				
				particles = element.particles;
				delete element["particles"];
				TweenMax.killDelayedCallsTo(particles.start);
				Starling.juggler.remove(particles);
				particles.stop(true);
				particles.removeFromParent(true);
				particles = null;
			}
			_animArray.length = 0;
			_animArray = null;
			
			if( _facebookButton )
			{
				FacebookManager.getInstance().removeEventListener(FacebookManager.ACCOUNT_ASSOCIATED, onAccountAssociated);
				FacebookManager.getInstance().removeEventListener(FacebookManager.AUTHENTICATED, onPublish);
				
				_facebookIcon.removeFromParent(true);
				_facebookIcon = null;
				
				TweenMax.killTweensOf(_facebookButton);
				_facebookButton.removeEventListener(Event.TRIGGERED, onAssociateOrPublish);
				_facebookButton.removeFromParent(true);
				_facebookButton = null;
				
				// just in case
				GoViral.goViral.removeEventListener(GVFacebookEvent.FB_DIALOG_FINISHED, onPublishOver);
				GoViral.goViral.removeEventListener(GVFacebookEvent.FB_DIALOG_FAILED, onPublishCancelledOrFailed);
				GoViral.goViral.removeEventListener(GVFacebookEvent.FB_DIALOG_CANCELED, onPublishCancelledOrFailed);
			}
			
			super.dispose();
		}
	}
}