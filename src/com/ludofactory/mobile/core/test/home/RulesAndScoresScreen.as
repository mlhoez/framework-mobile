package com.ludofactory.mobile.core.test.home
{
	import com.gamua.flox.Flox;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.test.config.GlobalConfig;
	import com.ludofactory.mobile.core.Localizer;
	import com.ludofactory.mobile.core.controls.AdvancedScreen;
	import com.ludofactory.mobile.core.controls.OffsetTabBar;
	import com.ludofactory.mobile.core.scoring.ScoreToPointsContainer;
	import com.ludofactory.mobile.core.scoring.ScoreToStarsContainer;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import feathers.controls.ImageLoader;
	import feathers.controls.List;
	import feathers.controls.Scroller;
	import feathers.data.ListCollection;
	import feathers.layout.VerticalLayout;
	
	import starling.display.Quad;
	import starling.events.Event;
	
	public class RulesAndScoresScreen extends AdvancedScreen
	{
		/**
		 * The logo */		
		private var _logo:ImageLoader;
		
		private var _gradient:Quad;
		
		private var _rulesList:List;
		private var _scoreToPointsContainer:ScoreToPointsContainer;
		private var _scoreToStarsContainer:ScoreToStarsContainer;
		
		private var _tabMenu:OffsetTabBar;
		
		public function RulesAndScoresScreen()
		{
			super();
			
			_whiteBackground = false;
			_appClearBackground = true;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			_logo = new ImageLoader();
			_logo.source = Theme.gameLogoTexture;
			_logo.textureScale = GlobalConfig.dpiScale;
			_logo.snapToPixels = true;
			addChild(_logo);
			
			_gradient = new Quad(5, 5, 0xffffff);
			addChild(_gradient);
			
			const vlayout:VerticalLayout = new VerticalLayout();
			vlayout.hasVariableItemDimensions = true;
			vlayout.horizontalAlign = VerticalLayout.HORIZONTAL_ALIGN_CENTER;
			vlayout.verticalAlign = VerticalLayout.VERTICAL_ALIGN_TOP;
			vlayout.paddingTop = vlayout.paddingBottom = scaleAndRoundToDpi(40);
			vlayout.gap = scaleAndRoundToDpi(20);
			
			_rulesList = new List();
			_rulesList.verticalScrollPolicy = Scroller.SCROLL_POLICY_AUTO;
			_rulesList.horizontalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			_rulesList.itemRendererType = RuleItemRenderer;
			_rulesList.layout = vlayout;
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
			
			_tabMenu = new OffsetTabBar();
			_tabMenu.addEventListener(Event.CHANGE, onButtonTouched);
			_tabMenu.dataProvider = new ListCollection( [Localizer.getInstance().translate("RULES_AND_POINTS.RULES_BUTTON_LABEL"),
														 Localizer.getInstance().translate("RULES_AND_POINTS.CLASSIC_BUTTON_LABEL"),
														 Localizer.getInstance().translate("RULES_AND_POINTS.TOURNAMENT_BUTTON_LABEL") ] );
			addChild(_tabMenu);
		}
		
		override protected function draw():void
		{
			if( isInvalid(INVALIDATION_FLAG_SIZE) )
			{
				_logo.width = actualWidth * (GlobalConfig.isPhone ? 0.85 : 0.75);
				_logo.x = ((actualWidth - _logo.width) * 0.5) << 0;
				_logo.validate();
				
				_tabMenu.y = _logo.height + scaleAndRoundToDpi(GlobalConfig.isPhone ? 20 : 40);
				_tabMenu.width = this.actualWidth;
				_tabMenu.validate();
				
				_rulesList.width = this.actualWidth;
				_rulesList.y = _tabMenu.y + _tabMenu.height;
				_rulesList.height = actualHeight - _rulesList.y;
				
				_gradient.width = this.actualWidth;
				_gradient.height = this.actualHeight - _rulesList.y;
				_gradient.y = _rulesList.y;
			}
		}
		
		private function layoutScoreToPoints():void
		{
			_scoreToPointsContainer.width = this.actualWidth;
			_scoreToPointsContainer.y = _tabMenu.y + _tabMenu.height;
			_scoreToPointsContainer.height = actualHeight -_rulesList.y;
		}
		
		private function layoutScoreToStars():void
		{
			_scoreToStarsContainer.width = this.actualWidth;
			_scoreToStarsContainer.y = _tabMenu.y + _tabMenu.height;
			_scoreToStarsContainer.height = actualHeight - _rulesList.y;
		}
		
//------------------------------------------------------------------------------------------------------------
//	Handlers
//------------------------------------------------------------------------------------------------------------
		
		private function onButtonTouched(event:Event):void
		{
			switch(_tabMenu.selectedIndex)
			{
				case 0:
				{
					Flox.logInfo("\t\tAffichage de l'onglet [Règles]");
					
					_rulesList.visible = true;
					if( _scoreToPointsContainer )
						_scoreToPointsContainer.visible = false;
					if( _scoreToStarsContainer )
						_scoreToStarsContainer.visible = false;
					break;
				}
					
				case 1:
				{
					Flox.logInfo("\t\tAffichage de l'onglet [Règles du mode Classique]");
					
					if( !_scoreToPointsContainer )
					{
						_scoreToPointsContainer = new ScoreToPointsContainer();
						addChild(_scoreToPointsContainer);
						layoutScoreToPoints();
					}
					
					_rulesList.visible = false;
					if( _scoreToPointsContainer )
						_scoreToPointsContainer.visible = true;
					if( _scoreToStarsContainer )
						_scoreToStarsContainer.visible = false;
					break;
				}
					
				case 2:
				{
					Flox.logInfo("\t\tAffichage de l'onglet [Règles du mode Tournoi]");
					
					if( !_scoreToStarsContainer )
					{
						_scoreToStarsContainer = new ScoreToStarsContainer();
						addChild(_scoreToStarsContainer);
						layoutScoreToStars();
					}
					
					_rulesList.visible = false;
					if( _scoreToPointsContainer )
						_scoreToPointsContainer.visible = false;
					if( _scoreToStarsContainer )
						_scoreToStarsContainer.visible = true;
					break;
				}
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
//------------------------------------------------------------------------------------------------------------
		
		override public function dispose():void
		{
			_logo.removeFromParent(true);
			_logo = null;
			
			_tabMenu.removeEventListener(Event.CHANGE, onButtonTouched);
			_tabMenu.removeFromParent(true);
			_tabMenu = null;
			
			_gradient.removeFromParent(true);
			_gradient = null;
			
			_rulesList.removeFromParent(true);
			_rulesList = null;
			
			if( _scoreToPointsContainer )
			{
				_scoreToPointsContainer.removeFromParent(true);
				_scoreToPointsContainer = null;
			}
			
			if( _scoreToStarsContainer )
			{
				_scoreToStarsContainer.removeFromParent(true);
				_scoreToStarsContainer = null;
			}
			
			super.dispose();
		}
		
	}
}