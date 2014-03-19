/*
LudoFactory
Framework mobile
Author  : Maxime Lhoez
Created : 19 juin 2013
*/
package com.ludofactory.mobile.core.test.engine
{
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.Localizer;
	import com.ludofactory.mobile.core.controls.AdvancedScreen;
	import com.ludofactory.mobile.core.controls.ScreenIds;
	import com.ludofactory.mobile.core.events.LudoEventType;
	import com.ludofactory.mobile.core.authentication.MemberManager;
	import com.ludofactory.mobile.core.test.config.GlobalConfig;
	import com.ludofactory.mobile.core.test.home.RuleData;
	import com.ludofactory.mobile.core.test.home.RuleItemRenderer;
	import com.ludofactory.mobile.core.test.home.RuleProperties;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import feathers.controls.Button;
	import feathers.controls.ImageLoader;
	import feathers.controls.List;
	import feathers.controls.Scroller;
	import feathers.data.ListCollection;
	import feathers.layout.VerticalLayout;
	
	import starling.events.Event;
	
	public class SmallRulesScreen extends AdvancedScreen
	{
		/**
		 * Logo */		
		private var _logo:ImageLoader;
		
		private var _rulesList:List;
		
		/**
		 * Back button */		
		private var _backButton:Button;
		
		/**
		 * Play button */		
		private var _playButton:Button;
		
		public function SmallRulesScreen()
		{
			super();
			
			_whiteBackground = true;
			_appClearBackground = false;
			_fullScreen = true;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			_logo = new ImageLoader();
			_logo.source = Theme.gameLogoTexture;
			_logo.textureScale = GlobalConfig.dpiScale;
			_logo.snapToPixels = true;
			addChild(_logo);
			
			const vlayout:VerticalLayout = new VerticalLayout();
			vlayout.horizontalAlign = VerticalLayout.HORIZONTAL_ALIGN_CENTER;
			vlayout.verticalAlign = VerticalLayout.VERTICAL_ALIGN_MIDDLE;
			vlayout.gap = scaleAndRoundToDpi(40);
			
			const vlayoutt:VerticalLayout = new VerticalLayout();
			vlayoutt.hasVariableItemDimensions = true;
			vlayoutt.horizontalAlign = VerticalLayout.HORIZONTAL_ALIGN_CENTER;
			vlayoutt.verticalAlign = VerticalLayout.VERTICAL_ALIGN_TOP;
			vlayoutt.paddingTop = vlayoutt.paddingBottom = scaleAndRoundToDpi(GlobalConfig.isPhone ? 10 : 20);
			vlayoutt.gap = scaleAndRoundToDpi(40);
			
			_rulesList = new List();
			_rulesList.verticalScrollPolicy = Scroller.SCROLL_POLICY_AUTO;
			_rulesList.horizontalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			_rulesList.itemRendererType = RuleItemRenderer;
			_rulesList.layout = vlayoutt;
			_rulesList.isSelectable = false;
			_rulesList.dataProvider = new ListCollection( [
				new RuleData( { type:RuleProperties.TYPE_RULE_WITHOUT_IMAGE, rule:Localizer.getInstance().translate("RULE_1") } ),
				new RuleData( { type:RuleProperties.TYPE_TITLE,              rule:Localizer.getInstance().translate("RULE_HOW_TO_PLAY") } ),
				new RuleData( { type:RuleProperties.TYPE_RULE_WITH_IMAGE,    rule:Localizer.getInstance().translate("RULE_2"), imageSource:"rule-1-" + (GlobalConfig.isPhone ? "sd" : "hd"), imagePosition:RuleProperties.POSITION_BOTTOM } ),
				new RuleData( { type:RuleProperties.TYPE_RULE_WITH_IMAGE,    rule:Localizer.getInstance().translate("RULE_3"), imageSource:"rule-2-" + (GlobalConfig.isPhone ? "sd" : "hd"), imagePosition:RuleProperties.POSITION_RIGHT } ),
				new RuleData( { type:RuleProperties.TYPE_RULE_WITH_IMAGE,    rule:Localizer.getInstance().translate("RULE_4"), imageSource:"rule-3-" + (GlobalConfig.isPhone ? "sd" : "hd"), imagePosition:RuleProperties.POSITION_RIGHT } ),
				new RuleData( { type:RuleProperties.TYPE_TITLE,              rule:Localizer.getInstance().translate("RULE_5") } ),
				new RuleData( { type:RuleProperties.TYPE_RULE_WITH_IMAGE,    rule:Localizer.getInstance().translate("RULE_6"), imageSource:"rule-4-" + (GlobalConfig.isPhone ? "sd" : "hd"), imagePosition:RuleProperties.POSITION_RIGHT } ),
				new RuleData( { type:RuleProperties.TYPE_RULE_WITH_IMAGE,    rule:Localizer.getInstance().translate("RULE_7"), imageSource:"rule-5-" + (GlobalConfig.isPhone ? "sd" : "hd"), imagePosition:RuleProperties.POSITION_RIGHT } )
			] );
			addChild(_rulesList);
			
			_backButton = new Button();
			_backButton.label = Localizer.getInstance().translate("SMALL_RULES.BACK_BUTTON_LABEL");
			_backButton.nameList.add( Theme.BUTTON_BLUE_SQUARED_RIGHT );
			_backButton.addEventListener(Event.TRIGGERED, onBackTouched);
			addChild(_backButton);
			
			_playButton = new Button();
			_playButton.label = Localizer.getInstance().translate("SMALL_RULES.PLAY_BUTTON_LABEL");
			_playButton.nameList.add( Theme.BUTTON_YELLOW_SQUARED_LEFT );
			_playButton.addEventListener(Event.TRIGGERED, onPlay);
			addChild(_playButton);
		}
		
		override protected function draw():void
		{
			if( isInvalid(INVALIDATION_FLAG_SIZE) )
			{
				_logo.width = actualWidth * (GlobalConfig.isPhone ? 0.75 : 0.65);
				_logo.x = ((actualWidth - _logo.width) * 0.5) << 0;
				_logo.y = scaleAndRoundToDpi(GlobalConfig.isPhone ? 20 : 40);
				_logo.validate();
				
				_backButton.width = scaleAndRoundToDpi(GlobalConfig.isPhone ? 560 : 760) * 0.5;
				_backButton.validate();
				_backButton.y = actualHeight - _backButton.height - scaleAndRoundToDpi(10);
				_backButton.x = (actualWidth * 0.5) - _backButton.width;
				
				_playButton.y = _backButton.y;
				_playButton.width = _backButton.width;
				_playButton.x = (actualWidth * 0.5);
				
				_rulesList.width = this.actualWidth;
				_rulesList.validate();
				_rulesList.y = _logo.y + _logo.height + scaleAndRoundToDpi(GlobalConfig.isPhone ? 10 : 20);
				_rulesList.height = _backButton.y - _rulesList.y - scaleAndRoundToDpi(GlobalConfig.isPhone ? 10 : 20);
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Handlers
//------------------------------------------------------------------------------------------------------------
		
		/**
		 * Launch the game.
		 */		
		private function onPlay(event:Event):void
		{
			MemberManager.getInstance().setDisplayRules( false );
			this.advancedOwner.showScreen( ScreenIds.GAME_SCREEN );
		}
		
		/**
		 * On back
		 */		
		private function onBackTouched(event:Event):void
		{
			onBack();
		}
		
		override public function onBack():void
		{
			// give the credits / free games / points back in case on back
			advancedOwner.dispatchEventWith(LudoEventType.UPDATE_SUMMARY);
			super.onBack();
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
//------------------------------------------------------------------------------------------------------------
		
		override public function dispose():void
		{
			_logo.removeFromParent(true);
			_logo = null;
			
			_backButton.removeEventListener(Event.TRIGGERED, onBackTouched);
			_backButton.removeFromParent(true);
			_backButton = null,
				
			_playButton.removeEventListener(Event.TRIGGERED, onPlay);
			_playButton.removeFromParent(true);
			_playButton = null;
			
			_rulesList.removeFromParent(true);
			_rulesList = null;
			
			super.dispose();
		}
	}
}