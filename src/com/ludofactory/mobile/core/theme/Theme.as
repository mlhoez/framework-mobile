package com.ludofactory.mobile.core.theme
{
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.notification.content.AbstractNotification;
	import com.ludofactory.mobile.core.test.achievements.TrophyItemRenderer;
	import com.ludofactory.mobile.core.test.achievements.TrophyMessage;
	import com.ludofactory.mobile.core.test.ads.tournament.AdTournamentItemRenderer;
	import com.ludofactory.mobile.core.test.alert.AlertItemRenderer;
	import com.ludofactory.mobile.core.test.config.GlobalConfig;
	import com.ludofactory.mobile.core.test.cs.thread.CSThreadItemRenderer;
	import com.ludofactory.mobile.core.test.engine.FacebookFriendElement;
	import com.ludofactory.mobile.core.test.game.GamePriceSelectionButton;
	import com.ludofactory.mobile.core.test.game.GamePriceSelectionButtonCredits;
	import com.ludofactory.mobile.core.test.game.GamePriceSelectionButtonFree;
	import com.ludofactory.mobile.core.test.game.GamePriceSelectionButtonPoints;
	import com.ludofactory.mobile.core.test.game.GameTypeSelectionPopup;
	import com.ludofactory.mobile.core.test.home.RuleItemRenderer;
	import com.ludofactory.mobile.core.test.sponsor.info.SponsorBonusItemRenderer;
	import com.ludofactory.mobile.core.test.store.StoreItemRenderer;
	import com.ludofactory.mobile.navigation.menu.MenuItemRenderer;
	
	import flash.geom.Rectangle;
	import flash.text.AutoCapitalize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import feathers.controls.Button;
	import feathers.controls.Callout;
	import feathers.controls.GroupedList;
	import feathers.controls.ImageLoader;
	import feathers.controls.Label;
	import feathers.controls.List;
	import feathers.controls.PageIndicator;
	import feathers.controls.PickerList;
	import feathers.controls.Radio;
	import feathers.controls.Screen;
	import feathers.controls.ScrollContainer;
	import feathers.controls.ScrollText;
	import feathers.controls.Scroller;
	import feathers.controls.SimpleScrollBar;
	import feathers.controls.TextInput;
	import feathers.controls.ToggleSwitch;
	import feathers.controls.popups.CalloutPopUpContentManager;
	import feathers.controls.popups.VerticalCenteredPopUpContentManager;
	import feathers.controls.renderers.BaseDefaultItemRenderer;
	import feathers.controls.renderers.DefaultGroupedListHeaderOrFooterRenderer;
	import feathers.controls.renderers.DefaultGroupedListItemRenderer;
	import feathers.controls.renderers.DefaultListItemRenderer;
	import feathers.controls.text.StageTextTextEditor;
	import feathers.controls.text.TextFieldTextRenderer;
	import feathers.core.DisplayListWatcher;
	import feathers.core.FeathersControl;
	import feathers.core.PopUpManager;
	import feathers.display.Scale3Image;
	import feathers.display.Scale9Image;
	import feathers.display.TiledImage;
	import feathers.layout.HorizontalLayout;
	import feathers.layout.VerticalLayout;
	import feathers.skins.SmartDisplayObjectStateValueSelector;
	import feathers.skins.StandardIcons;
	import feathers.system.DeviceCapabilities;
	import feathers.textures.Scale3Textures;
	import feathers.textures.Scale9Textures;
	
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.display.DisplayObjectContainer;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.textures.Texture;

	public class Theme extends DisplayListWatcher
	{
		
//------------------------------------------------------------------------------------------------------------
//	Fonts
		
		[Embed(source="/fonts/Arial.ttf", fontFamily="Arial", fontWeight="normal", fontStyle="normal", mimeType="application/x-font-truetype", embedAsCFF="false")]
		protected static const ARIAL:Class;
		
		[Embed(source="/fonts/Arial Italic.ttf", fontFamily="Arial", fontWeight="normal", fontStyle="italic", mimeType="application/x-font-truetype", embedAsCFF="false")]
		protected static const ARIAL_ITALIC:Class;
		
		[Embed(source="/fonts/Arial Bold.ttf", fontFamily="Arial", fontWeight="bold", fontStyle="normal", mimeType="application/x-font-truetype", embedAsCFF="false")]
		protected static const ARIAL_BOLD:Class;
		
		[Embed(source="/fonts/Arial Bold Italic.ttf", fontFamily="Arial", fontWeight="bold", fontStyle="italic", mimeType="application/x-font-truetype", embedAsCFF="false")]
		protected static const ARIAL_BOLD_ITALIC:Class;
		
		[Embed(source="/fonts/SansitaOne.ttf", fontFamily="Sansita", fontWeight="normal", fontStyle="normal", mimeType="application/x-font-truetype", embedAsCFF="false")]
		protected static const SANSITAONE:Class;
		
		public static const FONT_ARIAL:String = "Arial";
		public static const FONT_SANSITA:String = "Sansita";
		
//------------------------------------------------------------------------------------------------------------
//	Reference DPI
		
		/**
		 * Dpi de référence pour iPhone retina. */		
		public static const ORIGINAL_DPI_IPHONE_RETINA:int = 326; // original = 326 - modifié = 260
		/**
		 * Dpi de référence pour iPad retina. */		
		public static const ORIGINAL_DPI_IPAD_RETINA:int = 170; // original = 264 - modifié = 180
		/**
		 * The scale factor. */		
		protected var scaleFactor:Number = 1;
		
//------------------------------------------------------------------------------------------------------------
//	Colors
		
		public static const COLOR_YELLOW:uint = 0xffea00;
		public static const COLOR_BROWN:uint = 0x401800;
		public static const COLOR_WHITE:uint = 0xffffff;
		public static const COLOR_GREEN:uint = 0x43a01f;
		public static const COLOR_LIGHT_GREY:uint = 0x939393;
		public static const COLOR_VERY_LIGHT_GREY:uint = 0xd6d6d6;
		public static const COLOR_DARK_GREY:uint = 0x333333;
		public static const COLOR_ORANGE:uint = 0xff4e00;
		public static const COLOR_BLACK:uint = 0x353535;
		
		// Game Top Podium
		public static var labelMessageHighscorePodiumTextFormat:TextFormat;
		public static var labelPodiumTopTextFormat:TextFormat;
		
		// In Game
		public static var inGameScoreTextFormat:TextFormat;
		public static var inGameSuccessTextFormat:TextFormat;
		public static var inGameFailTextFormat:TextFormat;
		
		public static const LABEL_ALIGN_RIGHT:String = "label-align-right";
		public static const LABEL_ALIGN_CENTER:String = "label-align-center";
		
		/**
		 * The game logo. */		
		public static var gameLogoTexture:Texture;
		/**
		 * Ludokado's logo. */		
		public static var ludokadoLogoTexture:Texture;
		/**
		 * Game Center texture (at the home screen when available). */		
		public static var gameCenterTexture:Texture;
		/**
		 * Black loader textures. */		
		public static var blackLoaderTextures:Vector.<Texture>;
		
//------------------------------------------------------------------------------------------------------------
//	Init
		
		public function Theme(container:DisplayObjectContainer = null, scaleToDPI:Boolean = true)
		{
			if(!container)
			{
				container = Starling.current.stage;
			}
			super(container)
			this._scaleToDPI = scaleToDPI;
			this.initialize();
		}
		
		protected function initialize():void
		{
			initializeScale();
			initializeFonts();
			initializeTextures();
			initializeGlobals();
			setInitializers();
			
			// TODO A checker
			setInitializerForClass(Button, nothingInitializer, SimpleScrollBar.DEFAULT_CHILD_NAME_THUMB);
			this.setInitializerForClass(List, nothingInitializer, PickerList.DEFAULT_CHILD_NAME_LIST);
			this.setInitializerForClassAndSubclasses(ScrollText, scrollTextListInitializer);
			this.setInitializerForClassAndSubclasses(GroupedList, groupedListInitializer);
		}
		
		protected function initializeScale():void
		{
			var scaledDPI:int = DeviceCapabilities.dpi / Starling.contentScaleFactor;
			this._originalDPI = scaledDPI;
			if(this._scaleToDPI)
			{
				if(DeviceCapabilities.isTablet(Starling.current.nativeStage))
				{
					this._originalDPI = ORIGINAL_DPI_IPAD_RETINA;
				}
				else
				{
					this._originalDPI = ORIGINAL_DPI_IPHONE_RETINA;
				}
			}
			scaleFactor = GlobalConfig.dpiScale = scaledDPI / _originalDPI;
		}
		
		public static var baseLabelTextFormat:TextFormat;
		
		protected function initializeFonts():void
		{
			// OffsetTabBar
			offsetTabBarTextFormat = new TextFormat(FONT_SANSITA, scaleAndRoundToDpi(GlobalConfig.isPhone ? 24 : 28), COLOR_BLACK, false, false, null, null, null, TextFormatAlign.CENTER);
			
			// TextInput
			textInputTextFormat = new TextFormat(FONT_ARIAL, scaleAndRoundToDpi(30), COLOR_LIGHT_GREY, true);
			
			// Button
			buttonTextFormat                      = new TextFormat(FONT_SANSITA, scaleAndRoundToDpi(42), COLOR_BROWN);
			buttonBlueTextFormat                  = new TextFormat(FONT_SANSITA, scaleAndRoundToDpi(42), COLOR_WHITE);
			buttonSpecialTextFormat               = new TextFormat(FONT_SANSITA, scaleAndRoundToDpi(42), COLOR_BROWN); // TODO A voir une couleur spéciale plutôt
			buttonSpecialBiggerTextFormat         = new TextFormat(FONT_SANSITA, scaleAndRoundToDpi(60), COLOR_BROWN); // TODO A voir une couleur spéciale plutôt
			buttonNewsTextFormat                  = new TextFormat(FONT_SANSITA, scaleAndRoundToDpi(28), COLOR_BROWN);
			buttonFlatGreenTextFormat             = new TextFormat(FONT_ARIAL, scaleAndRoundToDpi(26), COLOR_WHITE, true);
			buttonFlatGreenDisabledTextFormat     = new TextFormat(FONT_ARIAL, scaleAndRoundToDpi(26), COLOR_GREEN, true);
			buttonAdTextFormat                    = new TextFormat(FONT_SANSITA, scaleAndRoundToDpi(28), COLOR_ORANGE);
			buttonTransparentWhiteTextFormat      = new TextFormat(FONT_SANSITA, scaleAndRoundToDpi(32), COLOR_WHITE);
			buttonTransparentBlueTextFormat       = new TextFormat(FONT_ARIAL, scaleAndRoundToDpi(GlobalConfig.isPhone ? 20 : 26), COLOR_DARK_GREY, true, false, null, null, null, TextFormatAlign.CENTER);
			buttonTransparentBlueDarkerTextFormat = new TextFormat(FONT_SANSITA, scaleAndRoundToDpi(GlobalConfig.isPhone ? 26 : 32), COLOR_DARK_GREY);
			
			// ToggleSwitch
			onThumbTextFormat  = new TextFormat(FONT_ARIAL, scaleAndRoundToDpi(24), COLOR_WHITE, true, true);
			offThumbTextFormat = new TextFormat(FONT_ARIAL, scaleAndRoundToDpi(24), COLOR_VERY_LIGHT_GREY, true, true);
			
			// Radio
			radioTextFormat = new TextFormat(FONT_SANSITA, scaleAndRoundToDpi(24), COLOR_LIGHT_GREY);
			
			// PickerList
			pickerListButtonTextFormat               = new TextFormat(FONT_ARIAL, scaleAndRoundToDpi(26), COLOR_LIGHT_GREY, false, true);
			pickerListItemRendererTextFormat         = new TextFormat(FONT_ARIAL, scaleAndRoundToDpi(36), COLOR_LIGHT_GREY, true, true);
			pickerListItemRendererSelectedTextFormat = new TextFormat(FONT_ARIAL, scaleAndRoundToDpi(36), COLOR_ORANGE), true, true;
			
			// Trophies (display and list)
			trophyMessageTextFormat = new TextFormat(FONT_SANSITA, scaleAndRoundToDpi(24), COLOR_WHITE);
			trophyGainTextFormat = new TextFormat(FONT_SANSITA, scaleAndRoundToDpi(38), COLOR_WHITE);
			
			// AdTournamentItemRenderer
			adTournamentFirstRankTextFormat = new TextFormat(FONT_SANSITA, scaleAndRoundToDpi(36), COLOR_DARK_GREY); // 0x470000
			adTournamentSecondRankTextFormat = new TextFormat(FONT_SANSITA, scaleAndRoundToDpi(36), COLOR_DARK_GREY); // 0x470000
			adTournamentThirdRankTextFormat = new TextFormat(FONT_SANSITA, scaleAndRoundToDpi(36), COLOR_DARK_GREY); // 0x3b1e01
			
			// Rules
			ruleTitleTextFormat = new TextFormat(FONT_SANSITA, scaleAndRoundToDpi(36), COLOR_DARK_GREY);
			ruleNormalTextFormat = new TextFormat(FONT_ARIAL, scaleAndRoundToDpi(26), COLOR_LIGHT_GREY, true, true);
			
			// AccountHistoryItemRenderer
			accoutHistoryIRTitleTextFormat = new TextFormat(FONT_ARIAL, scaleAndRoundToDpi(26), COLOR_DARK_GREY, true);
			
			// TrophyItemRenderer
			trophyIRTitleTF = new TextFormat(FONT_ARIAL, scaleAndRoundToDpi(28), COLOR_WHITE, true);
			trophyIRMessageTF = new TextFormat(FONT_ARIAL, scaleAndRoundToDpi(26), COLOR_LIGHT_GREY, false, true);
			trophyIRRewardTF = new TextFormat(FONT_ARIAL, scaleAndRoundToDpi(26), COLOR_LIGHT_GREY, true, true);
			trophyIRRewardOwnedTF = new TextFormat(FONT_ARIAL, scaleAndRoundToDpi(26), COLOR_ORANGE, true, true);
			trophyIROwnedTF = new TextFormat(FONT_ARIAL, scaleAndRoundToDpi(28), COLOR_WHITE, true, false, null, null, null, TextFormatAlign.RIGHT);
			
			// AccountItemRenderer
			accountIRTextFormat = new TextFormat(FONT_ARIAL, scaleAndRoundToDpi(24), COLOR_DARK_GREY, true);
			accountIRLabelTextFormat = new TextFormat(FONT_ARIAL, scaleAndRoundToDpi(32), COLOR_LIGHT_GREY);
			
			// FaqItemRenderer
			faqIRTextFormat = new TextFormat(FONT_ARIAL, scaleAndRoundToDpi(26), COLOR_DARK_GREY, true);
			
			// MenuItemRenderer
			menuIRTextFormat = new TextFormat(FONT_SANSITA, scaleAndRoundToDpi(26), COLOR_DARK_GREY, false, false, null, null, null, TextFormatAlign.CENTER);
			menuIRBadgeTextFormat = new TextFormat(FONT_SANSITA, scaleAndRoundToDpi(20), COLOR_WHITE);
			
			// ContactItemRenderer
			contactIRNameTextFormat = new TextFormat(FONT_ARIAL, scaleAndRoundToDpi(26), COLOR_DARK_GREY, true);
			contactIRValueTextFormat = new TextFormat(FONT_ARIAL, scaleAndRoundToDpi(26), COLOR_LIGHT_GREY, true, true);
			
			// CSMessageItemRenderer
			csMessageIRTitleReadTextFormat = new TextFormat(FONT_ARIAL, scaleAndRoundToDpi(GlobalConfig.isPhone ? 28 : 32), COLOR_ORANGE);
			csMessageIRMessageReadTextFormat = new TextFormat(FONT_ARIAL, scaleAndRoundToDpi(GlobalConfig.isPhone ? 28 : 32), COLOR_LIGHT_GREY, false, true);
			csMessageIRDateReadTextFormat = new TextFormat(FONT_ARIAL, scaleAndRoundToDpi(GlobalConfig.isPhone ? 28 : 32), COLOR_LIGHT_GREY);
			
			csMessageIRTitleTextFormat = new TextFormat(FONT_ARIAL, scaleAndRoundToDpi(GlobalConfig.isPhone ? 28 : 32), COLOR_ORANGE, true);
			csMessageIRMessageTextFormat = new TextFormat(FONT_ARIAL, scaleAndRoundToDpi(GlobalConfig.isPhone ? 28 : 32), COLOR_LIGHT_GREY, true, true);
			csMessageIRDateTextFormat = new TextFormat(FONT_ARIAL, scaleAndRoundToDpi(GlobalConfig.isPhone ? 28 : 32), COLOR_LIGHT_GREY, true, false, null, null, null, TextFormatAlign.RIGHT);
			
			// CSThreadItemRenderer
			csThreadIRMessageTextFormat = new TextFormat(FONT_ARIAL, scaleAndRoundToDpi(25), COLOR_LIGHT_GREY, false, true);
			csThreadIRDateTextFormat = new TextFormat(FONT_ARIAL, scaleAndRoundToDpi(25), COLOR_DARK_GREY, false, true);
			
			// BoutiqueCategoryItemRenderer
			boutiqueCategoryIRTitleTextFormat = new TextFormat(FONT_ARIAL, scaleAndRoundToDpi(26), COLOR_LIGHT_GREY, true, false, null, null, null, TextFormatAlign.CENTER);
			
			// FilleulItemRenderer
			filleulIRNameTextFormat = new TextFormat(FONT_ARIAL, scaleAndRoundToDpi(26), COLOR_DARK_GREY, true);
			
			// GiftHistoryItemRenderer
			giftIRTitleTextFormat = new TextFormat(FONT_ARIAL, scaleAndRoundToDpi(26), COLOR_DARK_GREY, true);
			
			// HistoryHeaderItemRenderer
			historyIRTitleTextFormat = new TextFormat(FONT_ARIAL, scaleAndRoundToDpi(26), COLOR_WHITE, true);
			
			// PaymentHistoryItemRenderer
			paymentIRTitleTextFormat = new TextFormat(FONT_ARIAL, scaleAndRoundToDpi(26), COLOR_DARK_GREY, true);
			
			// NewsItemRenderer
			newsIRTitleTextFormat = new TextFormat(FONT_ARIAL, scaleAndRoundToDpi(26), COLOR_DARK_GREY, true);
			newsIRMessageTextFormat = new TextFormat(FONT_ARIAL, scaleAndRoundToDpi(26), COLOR_LIGHT_GREY, true, true);
			
			// PreviousTournamentItemRenderer
			previousTournamentIRTextFormat = new TextFormat(FONT_ARIAL, scaleAndRoundToDpi(34), COLOR_DARK_GREY, true);
			
			// SettingsItemRenderer
			settingsIRTextFormat = new TextFormat(FONT_ARIAL, scaleAndRoundToDpi(26), COLOR_DARK_GREY, true);
			
			// NotLoggedInContainer
			notLoggedInMessageTextFormat = new TextFormat(FONT_ARIAL, scaleAndRoundToDpi(30), COLOR_LIGHT_GREY, true, true, null, null, null, TextFormatAlign.CENTER);
			notLoggedInButtonTextFormat = new TextFormat(FONT_ARIAL, scaleAndRoundToDpi(30), COLOR_DARK_GREY, true, true);
			
			// FilleulRewardItemRenderer
			filleulRewardIRTextFormat = new TextFormat(FONT_ARIAL, scaleAndRoundToDpi(28), COLOR_LIGHT_GREY, true, true, null, null, null, TextFormatAlign.CENTER);
			
			// RankHeaderItemRenderer
			rankHeaderIRTextFormat = new TextFormat(FONT_ARIAL, scaleAndRoundToDpi(26), COLOR_BROWN, true, true);
			
			// RetryContainer
			retryContainerLightTextFormat = new TextFormat(FONT_ARIAL, scaleAndRoundToDpi(GlobalConfig.isPhone ? 30 : 38), COLOR_LIGHT_GREY, true, true, null, null, null, TextFormatAlign.CENTER);
			retryContainerDarkTextFormat = new TextFormat(FONT_ARIAL, scaleAndRoundToDpi(GlobalConfig.isPhone ? 30 : 38), COLOR_DARK_GREY, true, true, null, null, null, TextFormatAlign.CENTER);
			
			// BoutiqueItemRenderer
			boutiqueItemIRTextFormat = new TextFormat(FONT_SANSITA, scaleAndRoundToDpi(26), COLOR_ORANGE, false, false, null, null, null, TextFormatAlign.CENTER);
			
			// CommonBidItemRenderer
			commonBidIRTextFormat = new TextFormat(FONT_SANSITA, scaleAndRoundToDpi(26), COLOR_ORANGE, false, false, null, null, null, TextFormatAlign.CENTER);
			
			// Base Label
			baseLabelTextFormat = new TextFormat(FONT_SANSITA, scaleAndRoundToDpi(24), COLOR_BLACK);
			
			// Game
			inGameScoreTextFormat = new TextFormat(FONT_SANSITA, scaleAndRoundToDpi(38), 0xffff05, false, false, null, null, null, TextFormatAlign.CENTER);
			inGameSuccessTextFormat = new TextFormat(FONT_SANSITA, scaleAndRoundToDpi(46), 0xc6d29d);
			inGameFailTextFormat = new TextFormat(FONT_SANSITA, scaleAndRoundToDpi(46), 0xc52828);
			
			// Top
			labelMessageHighscorePodiumTextFormat = new TextFormat(FONT_SANSITA, scaleAndRoundToDpi(50), COLOR_WHITE, false, false, null, null, null, TextFormatAlign.CENTER);
			labelPodiumTopTextFormat = new TextFormat(FONT_SANSITA, scaleAndRoundToDpi(120), COLOR_ORANGE, false, false, null, null, null, TextFormatAlign.CENTER);
			
			// FreeGameEndScreen
			freeGameEndScreenContainerTitleTextFormat = new TextFormat(FONT_SANSITA, scaleAndRoundToDpi(GlobalConfig.isPhone ? 50 : 72), COLOR_ORANGE, false, false, null, null, null, TextFormatAlign.CENTER);
			
			// ScoreToPointsItemRenderer
			scoreToPointsIRTextFormat = new TextFormat(FONT_ARIAL, scaleAndRoundToDpi(25), COLOR_LIGHT_GREY, true, true, null, null, null, TextFormatAlign.CENTER);
			
			// ScoreToPointsItemRenderer
			highScoreListHeaderTextFormat = new TextFormat(FONT_SANSITA, scaleAndRoundToDpi(30), COLOR_LIGHT_GREY, false, false, null, null, null, TextFormatAlign.CENTER);
			
			// MarketingRegisterNotification
			marketingRegisterNotificationBonusTextFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(GlobalConfig.isPhone ? 20 : 34), Theme.COLOR_WHITE);
			
			// SummaryElement
			summaryElementTextFormat = new TextFormat(FONT_SANSITA, scaleAndRoundToDpi(GlobalConfig.isPhone ? 32 : 46), COLOR_WHITE);
			
			// PauseView
			pauseViewLabelTextFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(34), Theme.COLOR_WHITE, false, false, null, null, null, TextFormatAlign.CENTER)
		}
		
		protected function initializeTextures():void
		{
			StandardIcons.listDrillDownAccessoryTexture = AbstractEntryPoint.assets.getTexture("list-accessory-drill-down-icon");
			horizontalScrollBarThumbSkinTextures = new Scale3Textures(AbstractEntryPoint.assets.getTexture("horizontal-scroll-bar-thumb-skin"), SCROLL_BAR_THUMB_REGION1, SCROLL_BAR_THUMB_REGION2, Scale3Textures.DIRECTION_HORIZONTAL);
			verticalScrollBarThumbSkinTextures = new Scale3Textures(AbstractEntryPoint.assets.getTexture("vertical-scroll-bar-thumb-skin"), SCROLL_BAR_THUMB_REGION1, SCROLL_BAR_THUMB_REGION2, Scale3Textures.DIRECTION_VERTICAL);
			infoManagerOverlay = AbstractEntryPoint.assets.getTexture("overlay-skin");
			
			// logos
			gameLogoTexture     = AbstractEntryPoint.assets.getTexture("logo-game");
			ludokadoLogoTexture = AbstractEntryPoint.assets.getTexture("logo-ludokado");
			gameCenterTexture   = AbstractEntryPoint.assets.getTexture("game-center");
			blackLoaderTextures = AbstractEntryPoint.assets.getTextures("MiniLoader");
			
			// OffsetTabBar
			buttonOffsetTabBarLeftSelectedTextures   = new Scale9Textures(AbstractEntryPoint.assets.getTexture("button-rules-and-scores-left-selected-background-skin"), BUTTON_OFFSET_TAB_BAR_LEFT_GRID);
			buttonOffsetTabBarLeftTextures           = new Scale9Textures(AbstractEntryPoint.assets.getTexture("button-rules-and-scores-left-background-skin"), BUTTON_OFFSET_TAB_BAR_LEFT_GRID);
			buttonOffsetTabBarRightSelectedTextures  = new Scale9Textures(AbstractEntryPoint.assets.getTexture("button-rules-and-scores-right-selected-background-skin"), BUTTON_OFFSET_TAB_BAR_RIGHT_GRID);
			buttonOffsetTabBarRightTextures          = new Scale9Textures(AbstractEntryPoint.assets.getTexture("button-rules-and-scores-right-background-skin"), BUTTON_OFFSET_TAB_BAR_RIGHT_GRID);
			buttonOffsetTabBarMiddleSelectedTextures = new Scale9Textures(AbstractEntryPoint.assets.getTexture("button-rules-and-scores-middle-selected-background-skin"), BUTTON_OFFSET_TAB_BAR_MIDDLE_GRID);
			buttonOffsetTabBarMiddleTextures         = new Scale9Textures(AbstractEntryPoint.assets.getTexture("button-rules-and-scores-middle-background-skin"), BUTTON_OFFSET_TAB_BAR_MIDDLE_GRID);
			
			// TextInput
			textinputBackgroundSkinTextures       = new Scale9Textures(AbstractEntryPoint.assets.getTexture("textinput-background-skin"), TEXTINPUT_GRID);
			textinputFirstBackgroundSkinTextures  = new Scale9Textures(AbstractEntryPoint.assets.getTexture("textinput-first-background-skin"), TEXTINPUT_FIRST_GRID);
			textinputLastBackgroundSkinTextures   = new Scale9Textures(AbstractEntryPoint.assets.getTexture("textinput-last-background-skin"), TEXTINPUT_LAST_GRID);
			textinputMiddleBackgroundSkinTextures = new Scale9Textures(AbstractEntryPoint.assets.getTexture("textinput-middle-background-skin"), TEXTINPUT_MIDDLE_GRID);
			
			// Button
			buttonYellowSkinTextures                  = new Scale9Textures(AbstractEntryPoint.assets.getTexture("button-yellow"), BUTTON_GRID);
			buttonYellowSquaredLeftUpSkinTextures     = new Scale9Textures(AbstractEntryPoint.assets.getTexture("button-yellow-squared-left"), BUTTON_GRID);
			buttonYellowSquaredRightUpSkinTextures    = new Scale9Textures(AbstractEntryPoint.assets.getTexture("button-yellow-squared-right"), BUTTON_GRID);
			buttonSpecialSkinTextures                 = new Scale9Textures(AbstractEntryPoint.assets.getTexture("button-special"), BUTTON_GRID);
			buttonSpecialSquaredLeftUpSkinTextures    = new Scale9Textures(AbstractEntryPoint.assets.getTexture("button-special-squared-left"), BUTTON_GRID);
			buttonSpecialSquaredRightUpSkinTextures   = new Scale9Textures(AbstractEntryPoint.assets.getTexture("button-special-squared-right"), BUTTON_GRID);
			buttonBlueSkinTextures                    = new Scale9Textures(AbstractEntryPoint.assets.getTexture("button-blue"), BUTTON_GRID);
			buttonBlueSquaredRightUpSkinTextures      = new Scale9Textures(AbstractEntryPoint.assets.getTexture("button-blue-squared-right"), BUTTON_GRID);
			buttonRedSkinTextures                     = new Scale9Textures(AbstractEntryPoint.assets.getTexture("button-red"), BUTTON_GRID);
			buttonGreenSkinTextures                   = new Scale9Textures(AbstractEntryPoint.assets.getTexture("button-green"), BUTTON_GRID);
			buttonDisabledSkinTextures                = new Scale9Textures(AbstractEntryPoint.assets.getTexture("button-grey"), BUTTON_GRID);
			buttonNewsUpSkinTextures                  = new Scale9Textures(AbstractEntryPoint.assets.getTexture("button-news-up-skin"), BUTTON_AD_GRID);
			buttonFlatGreenSkinTextures               = new Scale9Textures(AbstractEntryPoint.assets.getTexture("button-sponsor"), BUTTON_FLAT_GREEN_GRID);
			buttonAdUpSkinTextures                    = new Scale9Textures(AbstractEntryPoint.assets.getTexture("button-ad-up-skin"), BUTTON_AD_GRID);
			buttonTransparentWhiteUpSkinTextures      = new Scale9Textures(AbstractEntryPoint.assets.getTexture("button-transparent"), BUTTON_GRID);
			buttonTransparentBlueUpSkinTextures       = new Scale9Textures(AbstractEntryPoint.assets.getTexture("button-transparent-blue"), BUTTON_GRID);
			buttonTransparentBlueDarkerUpSkinTextures = new Scale9Textures(AbstractEntryPoint.assets.getTexture("button-transparent-blue-darker"), BUTTON_GRID);
			
			// ToggleSwitch
			toggleSwitchBackgroundSkinTextures              = new Scale9Textures(AbstractEntryPoint.assets.getTexture("toggle-switch-background"), TOGGLE_SWITCH_BACKGROUND_GRID);
			toggleSwitchThumbBackgroundSkinTextures         = new Scale9Textures(AbstractEntryPoint.assets.getTexture("toggle-switch-thumb-background"), TOGGLE_SWITCH_BACKGROUND_GRID);
			toggleSwitchThumbDisabledBackgroundSkinTextures = new Scale9Textures(AbstractEntryPoint.assets.getTexture("toggle-switch-thumb-disabled-background"), TOGGLE_SWITCH_BACKGROUND_GRID);
			
			// PageIndicator
			pageIndicatorSelectedSkinTexture = AbstractEntryPoint.assets.getTexture("page-indicator-selected-skin");
			pageIndicatorNormalSkinTexture   = AbstractEntryPoint.assets.getTexture("page-indicator-normal-skin");
			
			// Callout
			calloutSkinTextures           = new Scale9Textures(AbstractEntryPoint.assets.getTexture("callout-background-skin"), DEFAULT_CALLOUT_GRID);
			calloutTopArrowSkinTexture    = AbstractEntryPoint.assets.getTexture("callout-arrow-top-skin");
			calloutRightArrowSkinTexture  = AbstractEntryPoint.assets.getTexture("callout-arrow-right-skin");
			calloutBottomArrowSkinTexture = AbstractEntryPoint.assets.getTexture("callout-arrow-bottom-skin");
			calloutLeftArrowSkinTexture   = AbstractEntryPoint.assets.getTexture("callout-arrow-left-skin");
			
			// Radio
			radioUpIconTexture               = AbstractEntryPoint.assets.getTexture("radio-background-skin");
			radioDownIconTexture             = AbstractEntryPoint.assets.getTexture("radio-background-down-skin");
			radioSelectedUpIconTexture       = radioDownIconTexture;
			radioSelectedDownIconTexture     = radioDownIconTexture;
			radioSelectedDisabledIconTexture = AbstractEntryPoint.assets.getTexture("radio-selected-disabled-icon"); // à retirer ?
			
			// PickerList
			pickerListButtonIconTexture = AbstractEntryPoint.assets.getTexture("arrow_down");
			backgroundSkinTextures = new Scale9Textures(AbstractEntryPoint.assets.getTexture("background-skin"), DEFAULT_SCALE9_GRID);
			
			// GroupedList
			groupedListBackgroundSkinTextures = new Scale9Textures(AbstractEntryPoint.assets.getTexture("grouped-list-background-skin"), TEXTINPUT_GRID);
			groupedListBackgroundSelectedSkinTextures = new Scale9Textures(AbstractEntryPoint.assets.getTexture("grouped-list-background-selected-skin"), TEXTINPUT_GRID);
			groupedListFirstBackgroundSkinTextures = new Scale9Textures(AbstractEntryPoint.assets.getTexture("grouped-list-first-background-skin"), TEXTINPUT_FIRST_GRID);
			groupedListFirstBackgroundSelectedSkinTextures = new Scale9Textures(AbstractEntryPoint.assets.getTexture("grouped-list-first-background-selected-skin"), TEXTINPUT_FIRST_GRID);
			groupedListLastBackgroundSkinTextures = new Scale9Textures(AbstractEntryPoint.assets.getTexture("grouped-list-last-background-skin"), TEXTINPUT_LAST_GRID);
			groupedListLastBackgroundSelectedSkinTextures = new Scale9Textures(AbstractEntryPoint.assets.getTexture("grouped-list-last-background-selected-skin"), TEXTINPUT_LAST_GRID);
			groupedListMiddleBackgroundSkinTextures = new Scale9Textures(AbstractEntryPoint.assets.getTexture("grouped-list-middle-background-skin"), TEXTINPUT_MIDDLE_GRID);
			groupedListMiddleBackgroundSelectedSkinTextures = new Scale9Textures(AbstractEntryPoint.assets.getTexture("grouped-list-middle-background-selected-skin"), TEXTINPUT_MIDDLE_GRID);
			
			// Parrainage
			sponsorBonusBackground = new Scale3Textures(AbstractEntryPoint.assets.getTexture("sponsor-bonus-background"), SPONSOR_BONUS_REGION1, SPONSOR_BONUS_REGION2, Scale3Textures.DIRECTION_HORIZONTAL);
			
			// GameTypeSelection
			gameTypeSelectionFrontTextures = new Scale9Textures(AbstractEntryPoint.assets.getTexture("game-type-selection-front-skin"), GAME_TYPE_SELECTION_POPUP_FRONT_GRID);
			gameTypeSelectionBackgroundTextures = new Scale9Textures(AbstractEntryPoint.assets.getTexture("game-type-selection-background-skin"), GAME_TYPE_SELECTION_POPUP_BACKGROUND_GRID);
			topLeftLeavesTexture = AbstractEntryPoint.assets.getTexture("game-type-selection-deco-top-left");
			bottomLeftLeavesTexture = AbstractEntryPoint.assets.getTexture("game-type-selection-deco-bottom-left");
			bottomMiddleLeavesTexture = AbstractEntryPoint.assets.getTexture("game-type-selection-deco-bottom-middle");
			bottomRightLeavesTexture = AbstractEntryPoint.assets.getTexture("game-type-selection-deco-bottom-right");
			leftChainTexture = AbstractEntryPoint.assets.getTexture("lock-left");
			rightChainTexture = AbstractEntryPoint.assets.getTexture("lock-right");
			lockClosed = AbstractEntryPoint.assets.getTexture("lock");
			lockGlow = AbstractEntryPoint.assets.getTexture("MiniLueur");
			lockOpened = AbstractEntryPoint.assets.getTexture("unlock");
			gameTypeSelectionTileTexture = AbstractEntryPoint.assets.getTexture("game-type-selection-tile");
			
			// AbstractNotification
			notificationContainerBackgroundSkinTextures = new Scale9Textures(AbstractEntryPoint.assets.getTexture("notification-background-skin"), NOTIFICATION_CONTAINER_GRID);
			notificationContainerTopDecorationSkinTextures = new Scale3Textures(AbstractEntryPoint.assets.getTexture("notification-top-decoration"), NOTIFICATION_CONTAINER_TOP_DECORATION_REGION1, NOTIFICATION_CONTAINER_TOP_DECORATION_REGION2, Scale3Textures.DIRECTION_HORIZONTAL);
			notificationContainerBottomDecorationSkinTextures = new Scale3Textures(AbstractEntryPoint.assets.getTexture("notification-bottom-decoration"), NOTIFICATION_CONTAINER_BOTTOM_DECORATION_REGION1, NOTIFICATION_CONTAINER_BOTTOM_DECORATION_REGION2, Scale3Textures.DIRECTION_HORIZONTAL);
			
			// Trophies (display and list)
			trophyBackgroundSkinTextures = new Scale9Textures(AbstractEntryPoint.assets.getTexture("trophy-background-skin"), TROPHY_BACKGROUND_GRID);
			
			// StoreItemRenderer
			storeBackgroundSkinTextures = new Scale9Textures(AbstractEntryPoint.assets.getTexture("store-background"), STORE_BACKGROUND_CONTAINER_GRID);
			storeTopOfferTexture = new Scale3Textures(AbstractEntryPoint.assets.getTexture("top-offer"), 30, 50);
			storePlayersChoiceTexture = new Scale3Textures(AbstractEntryPoint.assets.getTexture("players-choice"), 30, 50);
			
			// CSThreadItemRenderer
			customerServiceThreadBackgroundSkinTextures = new Scale9Textures(AbstractEntryPoint.assets.getTexture("cs-message-container"), CUSTOMER_SERVICE_BACKGROUND_CONTAINER_GRID);
			customerServiceDefaultAvatarTexture = AbstractEntryPoint.assets.getTexture("cs-default-icon");
			customerServiceDefaultUserAvatarTexture = AbstractEntryPoint.assets.getTexture("cs-user-default-icon");
			
			// FacebookFriendElement
			facebookFriendBackgroundSkinTextures = new Scale9Textures(AbstractEntryPoint.assets.getTexture("facebook-friend-background-skin"), FACEBOOK_FRIEND_BACKGROUND_GRID);
			
			// ScrollContainer
			tournamentEndArrowSkinTextures = new Scale3Textures(AbstractEntryPoint.assets.getTexture("tournament-end-arrow"), TOURNAMENT_END_ARROW_REGION1, TOURNAMENT_END_ARROW_REGION2, Scale3Textures.DIRECTION_HORIZONTAL);
			scrollContainerResultGreyBackgroundSkinTextures = new Scale9Textures(AbstractEntryPoint.assets.getTexture("scroll-container-result-grey-background-skin"), SCROLL_CONTAINER_RESULT_GREY_GRID);
			scrollContainerBadgeBackgroundSkinTextures = new Scale9Textures(AbstractEntryPoint.assets.getTexture("badge-background-skin"), SCROLL_CONTAINER_BADGE_GRID);
			scrollContainerAlertBackgroundSkinTextures = new Scale9Textures(AbstractEntryPoint.assets.getTexture("alert-background-skin"), SCROLL_CONTAINER_BADGE_GRID);
			scrollContainerLabelBackgroundSkinTextures = new Scale9Textures(AbstractEntryPoint.assets.getTexture("scroll-container-label-background-skin"), SCROLL_CONTAINER_LABEL_GRID);
			scrollContainerResultLightCornerBottomRightBackgroundSkinTextures = new Scale9Textures(AbstractEntryPoint.assets.getTexture("scroll-container-result-light-corner-bottom-right"), SCROLL_CONTAINER_RESULT_GRID);
			scrollContainerResultLightCornerBottomLeftBackgroundSkinTextures = new Scale9Textures(AbstractEntryPoint.assets.getTexture("scroll-container-result-light-corner-bottom-left"), SCROLL_CONTAINER_RESULT_GRID);
			scrollContainerResultDarkCornerTopLeftBackgroundSkinTextures = new Scale9Textures(AbstractEntryPoint.assets.getTexture("scroll-container-result-dark-corner-top-left"), SCROLL_CONTAINER_RESULT_GRID);
			
			// TrophyItemRenderer
			trophyHighlightTexture = AbstractEntryPoint.assets.getTexture("trophy-highlight");
			trophyOwnedTexture = AbstractEntryPoint.assets.getTexture("trophy-owned-corner-label");
		}
		
		protected function initializeGlobals():void
		{
			FeathersControl.defaultTextRendererFactory = textRendererFactory;
			FeathersControl.defaultTextEditorFactory = textEditorFactory;
			
			PopUpManager.overlayFactory = popUpOverlayFactory;
			Callout.stagePaddingTop = Callout.stagePaddingRight = Callout.stagePaddingBottom = Callout.stagePaddingLeft = 16 * this.scaleFactor;
		}
		
		protected function setInitializers():void
		{
			// Screen
			setInitializerForClassAndSubclasses(Screen, screenInitializer);
			
			// OffsetTabBar
			setInitializerForClass(Button, buttonRulesAndScoresLeftInitializer, BUTTON_OFFSET_TAB_BAR_LEFT);
			setInitializerForClass(Button, buttonRulesAndScoresRightInitializer, BUTTON_OFFSET_TAB_BAR_RIGHT);
			setInitializerForClass(Button, buttonRulesAndScoresMiddleInitializer, BUTTON_OFFSET_TAB_BAR_MIDDLE);
			
			// TextInput
			setInitializerForClass(TextInput, textInputInitializer);
			setInitializerForClass(TextInput, textInputFirstInitializer, TEXTINPUT_FIRST);
			setInitializerForClass(TextInput, textInputLastInitializer, TEXTINPUT_LAST);
			setInitializerForClass(TextInput, textInputMiddleInitializer, TEXTINPUT_MIDDLE);
			
			// Button
			setInitializerForClass(Button, buttonInitializer);
			setInitializerForClass(Button, buttonYellowSquaredLeftInitializer, BUTTON_YELLOW_SQUARED_LEFT);
			setInitializerForClass(Button, buttonYellowSquaredRightInitializer, BUTTON_YELLOW_SQUARED_RIGHT);
			setInitializerForClass(Button, buttonSpecialBiggerInitializer, BUTTON_SPECIAL_BIGGER);
			setInitializerForClass(Button, buttonSpecialInitializer, BUTTON_SPECIAL);
			setInitializerForClass(Button, buttonSpecialSquaredLeftInitializer, BUTTON_SPECIAL_SQUARED_LEFT);
			setInitializerForClass(Button, buttonSpecialSquaredRightInitializer, BUTTON_SPECIAL_SQUARED_RIGHT);
			setInitializerForClass(Button, buttonSpecialSquaredRightBiggerInitializer, BUTTON_SPECIAL_SQUARED_RIGHT_BIGGER);
			setInitializerForClass(Button, buttonBlueInitializer, BUTTON_BLUE);
			setInitializerForClass(Button, buttonBlueSquaredRightInitializer, BUTTON_BLUE_SQUARED_RIGHT);
			setInitializerForClass(Button, buttonRedInitializer, BUTTON_RED);
			setInitializerForClass(Button, buttonGreenInitializer, BUTTON_GREEN);
			setInitializerForClass(Button, buttonNewsInitializer, BUTTON_NEWS);
			setInitializerForClass(Button, buttonFlatGreenInitializer, BUTTON_FLAT_GREEN);
			setInitializerForClass(Button, buttonAdInitializer, BUTTON_AD);
			setInitializerForClass(Button, buttonTransparentWhiteInitializer, BUTTON_TRANSPARENT_WHITE);
			setInitializerForClass(Button, buttonTransparentBlueInitializer, BUTTON_TRANSPARENT_BLUE);
			setInitializerForClass(Button, buttonTransparentBlueDarkerInitializer, BUTTON_TRANSPARENT_BLUE_DARKER);
			setInitializerForClass(Button, buttonEmptyInitializer, BUTTON_EMPTY);
			
			// ToggleSwitch
			setInitializerForClassAndSubclasses(ToggleSwitch, toggleSwitchInitializer);
			setInitializerForClass(Button, buttonToggleSwitchInitializer, BUTTON_TOGGLE_SWITCH_THUMB);
			setInitializerForClass(Button, toggleSwitchTrackInitializer, ToggleSwitch.DEFAULT_CHILD_NAME_ON_TRACK);
			
			// PageIndicator
			setInitializerForClass(PageIndicator, pageIndicatorInitializer);
			
			// Callout
			setInitializerForClass(Callout, calloutInitializer);
			
			// Radio
			setInitializerForClass(Radio, radioInitializer);
			
			// PickerList
			setInitializerForClass(PickerList, pickerListInitializer);
			setInitializerForClass(Button, pickerListButtonInitializer, PickerList.DEFAULT_CHILD_NAME_BUTTON);
			setInitializerForClass(DefaultListItemRenderer, pickerListItemRendererInitializer, COMPONENT_NAME_PICKER_LIST_ITEM_RENDERER);
			
			// GroupedList (custom in the shop)
			setInitializerForClass(GroupedList, subCategoryGroupedListInitializer, SUB_CATEGORY_GROUPED_LIST);
			setInitializerForClass(DefaultGroupedListHeaderOrFooterRenderer, nothingInitializer, SUB_CATEGORY_INSET_HEADER_RENDERER);
			setInitializerForClass(DefaultGroupedListItemRenderer, insetSubCatgoryMiddleItemRendererInitializer, SUB_CATEGORY_INSET_MIDDE_ITEM_RENDERER);
			setInitializerForClass(DefaultGroupedListItemRenderer, insetSubCatgoryFirstItemRendererInitializer, SUB_CATEGORY_INSET_FIRST_ITEM_RENDERER);
			setInitializerForClass(DefaultGroupedListItemRenderer, insetSubCatgoryLastItemRendererInitializer, SUB_CATEGORY_INSET_LAST_ITEM_RENDERER);
			setInitializerForClass(DefaultGroupedListItemRenderer, insetSubCatgorySingleItemRendererInitializer, SUB_CATEGORY_INSET_SINGLE_ITEM_RENDERER);
			
			// List
			setInitializerForClassAndSubclasses(List, listInitializer);
			
			// Parrainage
			setInitializerForClass(SponsorBonusItemRenderer, sponsorBonusItemRendererInitializer);
			
			// GameTypeSelection
			setInitializerForClass(GameTypeSelectionPopup, gameTypeSelectionPopupInitializer);
			
			// GamePriceSelection buttons
			setInitializerForClassAndSubclasses(GamePriceSelectionButtonPoints,  gamePriceSelectionButtonPointsInitializer);
			setInitializerForClassAndSubclasses(GamePriceSelectionButtonFree,    gamePriceSelectionButtonFreeInitializer);
			setInitializerForClassAndSubclasses(GamePriceSelectionButtonCredits, gamePriceSelectionButtonCreditsInitializer);
			
			// AbstractNotification
			setInitializerForClassAndSubclasses(AbstractNotification, abstractNotificationInitializer);
			
			// Trophies (display and list)
			setInitializerForClass(TrophyMessage, trophyMessageInitializer);
			
			// MenuItemRenderer
			setInitializerForClass(MenuItemRenderer, menuItemRendererInitializer);
			
			// StoreItemRenderer
			setInitializerForClass(StoreItemRenderer, sotreItemRendererInitializer);
			
			// CSThreadItemRenderer
			setInitializerForClass(CSThreadItemRenderer, customerServiceThreadItemRendererInitializer);
			
			// AdTournamentItemRenderer
			setInitializerForClass(AdTournamentItemRenderer, adTournamentItemRendererInitializer);
			
			// Rules
			setInitializerForClass(RuleItemRenderer, ruleItemRendererInitializer);
			
			// AlertItemRenderer
			setInitializerForClass(AlertItemRenderer, alertItemRendererInitializer);
			
			// FacebookFriendElement
			setInitializerForClass(FacebookFriendElement, facebookFriendElementInitializer);
			
			// ScrollContainer
			setInitializerForClassAndSubclasses(ScrollContainer, scrollContainerInitializer);
			setInitializerForClass(ScrollContainer, scrollContainerWhiteInitializer, SCROLL_CONTAINER_WHITE);
			setInitializerForClass(ScrollContainer, scrollContainerTournamentEndArrowInitializer, TOURNAMENT_END_ARROW_CONTAINER);
			setInitializerForClass(ScrollContainer, scrollContainerResultGreyInitializer, SCROLL_CONTAINER_RESULT_GREY);
			setInitializerForClass(ScrollContainer, scrollContainerBadgeInitializer, SCROLL_CONTAINER_BADGE);
			setInitializerForClass(ScrollContainer, scrollContainerAlertInitializer, SCROLL_CONTAINER_ALERT);
			setInitializerForClass(ScrollContainer, scrollContainerLabelInitializer, SCROLL_CONTAINER_LABEL);
			setInitializerForClass(ScrollContainer, scrollContainerResultCornerBottomRightInitializer, SCROLL_CONTAINER_RESULT_LIGHT_CORNER_BOTTOM_RIGHT);
			setInitializerForClass(ScrollContainer, scrollContainerResultCornerBottomLeftInitializer, SCROLL_CONTAINER_RESULT_LIGHT_CORNER_BOTTOM_LEFT);
			setInitializerForClass(ScrollContainer, scrollContainerResultCornerTopLeftInitializer, SCROLL_CONTAINER_RESULT_DARK_CORNER_TOP_LEFT);
			
			// Label
			setInitializerForClass(Label, baseLabelInitializer);
			setInitializerForClass(Label, labelAlignRightInitializer, LABEL_ALIGN_RIGHT);
			setInitializerForClass(Label, labelAlignCenterInitializer, LABEL_ALIGN_CENTER);
			
			// TrophyItemRenderer
			setInitializerForClass(TrophyItemRenderer, trophyItemRendererInitializer);
		}
		
		protected var _originalDPI:int;
		public function get originalDPI():int { return this._originalDPI; }
		
		protected var _scaleToDPI:Boolean;
		public function get scaleToDPI():Boolean { return this._scaleToDPI; }
		
//------------------------------------------------------------------------------------------------------------
//
//
//
//							T E X T  &  P O P U P  &  N O T H I N G
//
//
//
//------------------------------------------------------------------------------------------------------------
		
		/**
		 * Global text renderer.
		 */		
		protected static function textRendererFactory():TextFieldTextRenderer
		{
			var tr:TextFieldTextRenderer = new TextFieldTextRenderer();
			tr.embedFonts = true;
			return tr;
		}
		
		/**
		 * Text editor (for text inputs)
		 */		
		protected static function textEditorFactory():StageTextTextEditor
		{
			const textEditor:StageTextTextEditor = new StageTextTextEditor();
			textEditor.autoCorrect = false;
			textEditor.autoCapitalize = AutoCapitalize.NONE;
			return textEditor;
		}
		
		protected static function popUpOverlayFactory():DisplayObject
		{
			// FIXME A remplacer par une texture noire en alpha 0.75% ?
			const quad:Quad = new Quad(100, 100, COLOR_BLACK);
			quad.alpha = 0.75;
			return quad;
		}
		
		protected function nothingInitializer(target:DisplayObject):void {}
		
//------------------------------------------------------------------------------------------------------------
//	FIXME A vérifier
		
		protected function groupedListInitializer(list:GroupedList):void
		{
			list.verticalScrollBarFactory = this.verticalScrollBarFactory;
			list.horizontalScrollBarFactory = this.horizontalScrollBarFactory;
		}
		
		protected function scrollTextListInitializer(scrollText:ScrollText):void
		{
			scrollText.verticalScrollBarFactory = this.verticalScrollBarFactory;
			scrollText.horizontalScrollBarFactory = this.horizontalScrollBarFactory;
		}
		
		protected function imageLoaderFactory():ImageLoader
		{
			const image:ImageLoader = new ImageLoader();
			image.textureScale = this.scaleFactor;
			return image;
		}
		
//------------------------------------------------------------------------------------------------------------
//
//
//
//										S C R E E N
//
//
//
//------------------------------------------------------------------------------------------------------------
		
		protected function screenInitializer(screen:Screen):void
		{
			screen.originalDPI = this._originalDPI;
		}
		
//------------------------------------------------------------------------------------------------------------
//
//
//
//										O F F S E T  T A B  B A R
//
//
//
//------------------------------------------------------------------------------------------------------------
		
		/**
		 * TextFormat used for the offset tab bar buttons. */		
		protected var offsetTabBarTextFormat:TextFormat;
		
		/**
		 * OffsetTabBar left button. */		
		public static const BUTTON_OFFSET_TAB_BAR_LEFT:String = "button-offset-tab-bar-left";
		protected static const BUTTON_OFFSET_TAB_BAR_LEFT_GRID:Rectangle = new Rectangle(5, 24, 17, 2);
		protected var buttonOffsetTabBarLeftTextures:Scale9Textures;
		protected var buttonOffsetTabBarLeftSelectedTextures:Scale9Textures;
		
		/**
		 * OffsetTabBar normal (middle) button. */		
		public static const BUTTON_OFFSET_TAB_BAR_MIDDLE:String = "button-offset-tab-bar-middle";
		protected static const BUTTON_OFFSET_TAB_BAR_MIDDLE_GRID:Rectangle = new Rectangle(24, 24, 2, 2);
		protected var buttonOffsetTabBarMiddleTextures:Scale9Textures;
		protected var buttonOffsetTabBarMiddleSelectedTextures:Scale9Textures;
		
		/**
		 * OffsetTabBar right button. */		
		public static const BUTTON_OFFSET_TAB_BAR_RIGHT:String = "button-offset-tab-bar-right";
		protected static const BUTTON_OFFSET_TAB_BAR_RIGHT_GRID:Rectangle = new Rectangle(22, 24, 17, 2);
		protected var buttonOffsetTabBarRightTextures:Scale9Textures;
		protected var buttonOffsetTabBarRightSelectedTextures:Scale9Textures;
		
		/**
		 * OffsetTabBar left button.
		 */		
		protected function buttonRulesAndScoresLeftInitializer(button:Button):void
		{
			const skinSelector:SmartDisplayObjectStateValueSelector = new SmartDisplayObjectStateValueSelector();
			skinSelector.defaultValue = buttonOffsetTabBarLeftTextures;
			skinSelector.defaultSelectedValue = buttonOffsetTabBarLeftSelectedTextures;
			skinSelector.setValueForState(buttonOffsetTabBarLeftSelectedTextures, Button.STATE_DOWN, false);
			skinSelector.displayObjectProperties = { width: 44 * scaleFactor, height: 60 * scaleFactor, textureScale: scaleFactor };
			button.stateToSkinFunction = skinSelector.updateValue;
			
			offsetTabBarCommonInitializer(button);
		}
		/**
		 * OffsetTabBar normal (middle) button.
		 */		
		protected function buttonRulesAndScoresRightInitializer(button:Button):void
		{
			const skinSelector:SmartDisplayObjectStateValueSelector = new SmartDisplayObjectStateValueSelector();
			skinSelector.defaultValue = buttonOffsetTabBarRightTextures;
			skinSelector.defaultSelectedValue = buttonOffsetTabBarRightSelectedTextures;
			skinSelector.setValueForState(buttonOffsetTabBarRightSelectedTextures, Button.STATE_DOWN, false);
			skinSelector.displayObjectProperties = { width: 44 * scaleFactor, height: 60 * scaleFactor, textureScale: scaleFactor };
			button.stateToSkinFunction = skinSelector.updateValue;
			
			offsetTabBarCommonInitializer(button);
		}
		/**
		 * OffsetTabBar right button.
		 */		
		protected function buttonRulesAndScoresMiddleInitializer(button:Button):void
		{
			const skinSelector:SmartDisplayObjectStateValueSelector = new SmartDisplayObjectStateValueSelector();
			skinSelector.defaultValue = buttonOffsetTabBarMiddleTextures;
			skinSelector.defaultSelectedValue = buttonOffsetTabBarMiddleSelectedTextures;
			skinSelector.setValueForState(buttonOffsetTabBarMiddleSelectedTextures, Button.STATE_DOWN, false);
			skinSelector.displayObjectProperties = { width: 50 * scaleFactor, height: 60 * scaleFactor, textureScale: scaleFactor };
			button.stateToSkinFunction = skinSelector.updateValue;
			
			offsetTabBarCommonInitializer(button);
		}
		
		/**
		 * Common OffsetTabBarInitializer
		 */		
		protected function offsetTabBarCommonInitializer(button:Button):void
		{
			button.defaultLabelProperties.textFormat = offsetTabBarTextFormat;
			
			button.paddingTop = button.paddingBottom = 10 * scaleFactor;
			button.paddingLeft = button.paddingRight = 16 * scaleFactor;
			//button.gap = 12 * scaleFactor;
			
			button.minTouchWidth = 44 * scaleFactor;
			button.minWidth = 44 * scaleFactor;
			button.minTouchHeight = 60 * scaleFactor;
			button.minHeight = 60 * scaleFactor;
			button.maxHeight = 60 * scaleFactor;
		}
		
//------------------------------------------------------------------------------------------------------------
//
//
//
//												T E X T I N P U T
//
//
//
//------------------------------------------------------------------------------------------------------------
		
		protected var textInputTextFormat:TextFormat;
		protected static const TEXTINPUT_GRID:Rectangle = new Rectangle(15, 15, 2, 2);
		protected var textinputBackgroundSkinTextures:Scale9Textures;
				
		/**
		 * TextInput with rounded corners on the top */		
		public static const TEXTINPUT_FIRST:String = "textinput-first";
		protected static const TEXTINPUT_FIRST_GRID:Rectangle = new Rectangle(15, 16, 2, 11);
		protected var textinputFirstBackgroundSkinTextures:Scale9Textures;
		
		/**
		 * TextInput with rounded corners on the bottom */		
		public static const TEXTINPUT_LAST:String = "textinput-last";
		protected static const TEXTINPUT_LAST_GRID:Rectangle = new Rectangle(15, 5, 2, 11);
		protected var textinputLastBackgroundSkinTextures:Scale9Textures;
		
		/**
		 * TextInput with no corners */		
		public static const TEXTINPUT_MIDDLE:String = "textinput-middle";
		protected static const TEXTINPUT_MIDDLE_GRID:Rectangle = new Rectangle(4, 4, 24, 24);
		protected var textinputMiddleBackgroundSkinTextures:Scale9Textures;
		
		/**
		 * Common TextInput settings.
		 */		
		private function baseTextInputInitializer(input:TextInput, backgroundSkinTextures:Scale9Textures):void
		{
			const backgroundSkin:Scale9Image = new Scale9Image(backgroundSkinTextures, scaleFactor);
			backgroundSkin.width = 264 * scaleFactor;
			backgroundSkin.height = 80 * scaleFactor;
			input.backgroundSkin = backgroundSkin;
			
			input.minWidth = input.minHeight = 80 * scaleFactor;
			input.minTouchWidth = input.minTouchHeight = 108 * scaleFactor;
			input.paddingTop = 16 * scaleFactor;
			input.paddingBottom = 10 * scaleFactor;
			input.paddingLeft = input.paddingRight = 14 * scaleFactor;
			input.textEditorProperties.fontFamily = "Helvetica";
			input.textEditorProperties.fontSize = 32 * this.scaleFactor;
			input.textEditorProperties.color = COLOR_LIGHT_GREY;
			
			input.promptProperties.textFormat = textInputTextFormat;
		}
		/**
		 * Common TextInput used a s a single line.
		 */		
		protected function textInputInitializer(input:TextInput):void
		{
			baseTextInputInitializer(input, textinputBackgroundSkinTextures);
		}
		
		/**
		 * When used as a form, this TextInput is designed as the first element.
		 */		
		protected function textInputFirstInitializer(input:TextInput):void
		{
			baseTextInputInitializer(input, textinputFirstBackgroundSkinTextures);
		}
		
		/**
		 * When used as a form, this TextInput is designed as the middle element.
		 */		
		protected function textInputMiddleInitializer(input:TextInput):void
		{
			baseTextInputInitializer(input, textinputMiddleBackgroundSkinTextures);
		}
		
		/**
		 * When used as a form, this TextInput is designed as the last element.
		 */		
		protected function textInputLastInitializer(input:TextInput):void
		{
			baseTextInputInitializer(input, textinputLastBackgroundSkinTextures);
		}
		
//------------------------------------------------------------------------------------------------------------
//
//
//
//												B U T T O N
//
//
//
//------------------------------------------------------------------------------------------------------------
		
//------------------------------------------------------------------------------------------------------------
//	Yellow (common style)
		
		/**
		 * Common element format. */		
		protected var buttonTextFormat:TextFormat;
		
		protected static const BUTTON_GRID:Rectangle = new Rectangle(32, 32, 24, 24);
		
		/**
		 * Initializer for common buttons.
		 */		
		protected function baseButtonInitializer(button:Button):void
		{
			button.defaultLabelProperties.textFormat = this.buttonTextFormat;
			
			button.scaleWhenDown = true;
			button.paddingTop = button.paddingBottom = 10 * scaleFactor;
			button.paddingLeft = button.paddingRight = 32 * scaleFactor;
			button.gap = 12 * scaleFactor;
			button.minWidth = 114 * scaleFactor;
			button.minHeight = (GlobalConfig.isPhone ? 98 : 108) * scaleFactor;
			button.minTouchWidth = button.minTouchHeight = 114 * scaleFactor;
		}
		
		/**
		 * Disabled / Grey button */		
		protected var buttonDisabledSkinTextures:Scale9Textures;
		
		/**
		 * Yellow button */	
		protected var buttonYellowSkinTextures:Scale9Textures;
		
		/**
		 * Yellow button squared on the left */		
		public static const BUTTON_YELLOW_SQUARED_LEFT:String = "button-yellow-squared-left";
		protected var buttonYellowSquaredLeftUpSkinTextures:Scale9Textures;
		
		/**
		 * Yellow button squared on the right */		
		public static const BUTTON_YELLOW_SQUARED_RIGHT:String = "button-yellow-squared-right";
		protected var buttonYellowSquaredRightUpSkinTextures:Scale9Textures;
		
		/**
		 * Common yellow button.
		 */		
		protected function buttonInitializer(button:Button):void
		{
			const skinSelector:SmartDisplayObjectStateValueSelector = new SmartDisplayObjectStateValueSelector();
			skinSelector.defaultValue = this.buttonYellowSkinTextures;
			skinSelector.displayObjectProperties =
				{
					width: 114 * this.scaleFactor,
						height: (GlobalConfig.isPhone ? 98 : 108) * this.scaleFactor,
						textureScale: this.scaleFactor
				};
			button.stateToSkinFunction = skinSelector.updateValue;
			this.baseButtonInitializer(button);
		}
		
		/**
		 * Yellow button with left side squared
		 */		
		protected function buttonYellowSquaredLeftInitializer(button:Button):void
		{
			const skinSelector:SmartDisplayObjectStateValueSelector = new SmartDisplayObjectStateValueSelector();
			skinSelector.defaultValue = this.buttonYellowSquaredLeftUpSkinTextures;
			skinSelector.displayObjectProperties =
				{
					width: 114 * this.scaleFactor,
						height: (GlobalConfig.isPhone ? 98 : 108) * this.scaleFactor,
						textureScale: this.scaleFactor
				};
			button.stateToSkinFunction = skinSelector.updateValue;
			this.baseButtonInitializer(button);
		}
		
		/**
		 * Yellow button with right side squared
		 */		
		protected function buttonYellowSquaredRightInitializer(button:Button):void
		{
			const skinSelector:SmartDisplayObjectStateValueSelector = new SmartDisplayObjectStateValueSelector();
			skinSelector.defaultValue = this.buttonYellowSquaredRightUpSkinTextures;
			skinSelector.displayObjectProperties =
				{
					width: 114 * this.scaleFactor,
						height: (GlobalConfig.isPhone ? 98 : 108) * this.scaleFactor,
						textureScale: this.scaleFactor
				};
			button.stateToSkinFunction = skinSelector.updateValue;
			this.baseButtonInitializer(button);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Special (different for each game)
		
		protected var buttonSpecialBiggerTextFormat:TextFormat;
		protected var buttonSpecialTextFormat:TextFormat;
		
		/**
		 * Special button */	
		public static const BUTTON_SPECIAL_BIGGER:String = "button-special-bigger";
		public static const BUTTON_SPECIAL:String = "button-special";
		protected var buttonSpecialSkinTextures:Scale9Textures;
		
		/**
		 * Special button squared on the left */		
		public static const BUTTON_SPECIAL_SQUARED_LEFT:String = "button-special-squared-left";
		protected var buttonSpecialSquaredLeftUpSkinTextures:Scale9Textures;
		
		/**
		 * Special button squared on the right */		
		public static const BUTTON_SPECIAL_SQUARED_RIGHT_BIGGER:String = "button-special-squared-right-bigger";
		public static const BUTTON_SPECIAL_SQUARED_RIGHT:String = "button-special-squared-right";
		protected var buttonSpecialSquaredRightUpSkinTextures:Scale9Textures;
		
		/**
		 * Base button special initializer.
		 */		
		protected function baseButtonSpecialInitializer(button:Button, bigger:Boolean = false):void
		{
			button.defaultLabelProperties.textFormat = bigger ? this.buttonSpecialBiggerTextFormat : this.buttonSpecialTextFormat;
			
			button.scaleWhenDown = true;
			button.paddingTop = button.paddingBottom = 10 * this.scaleFactor;
			button.paddingLeft = button.paddingRight = 32 * this.scaleFactor;
			button.gap = 12 * this.scaleFactor;
			button.minWidth = 114 * this.scaleFactor;
			button.minHeight = (GlobalConfig.isPhone ? 98 : 108) * this.scaleFactor;
			button.minTouchWidth = button.minTouchHeight = 114 * this.scaleFactor;
		}
		
		/**
		 * Special button.
		 */		
		protected function buttonSpecialInitializer(button:Button):void
		{
			const skinSelector:SmartDisplayObjectStateValueSelector = new SmartDisplayObjectStateValueSelector();
			skinSelector.defaultValue = this.buttonSpecialSkinTextures;
			skinSelector.displayObjectProperties =
				{
					width: 114 * this.scaleFactor,
						height: (GlobalConfig.isPhone ? 98 : 108) * this.scaleFactor,
						textureScale: this.scaleFactor
				};
			button.stateToSkinFunction = skinSelector.updateValue;
			//button.defaultLabelProperties.filters = [ new GlowFilter(0x2a5c02, 1, 12, 12, 10) ];
			this.baseButtonSpecialInitializer(button);
		}
		
		/**
		 * Special button.
		 */		
		protected function buttonSpecialBiggerInitializer(button:Button):void
		{
			const skinSelector:SmartDisplayObjectStateValueSelector = new SmartDisplayObjectStateValueSelector();
			skinSelector.defaultValue = this.buttonSpecialSkinTextures;
			skinSelector.displayObjectProperties =
				{
					width: 114 * this.scaleFactor,
						height: (GlobalConfig.isPhone ? 98 : 108) * this.scaleFactor,
						textureScale: this.scaleFactor
				};
			button.stateToSkinFunction = skinSelector.updateValue;
			//button.defaultLabelProperties.filters = [ new GlowFilter(0x2a5c02, 1, 12, 12, 10) ];
			this.baseButtonSpecialInitializer(button, true);
		}
		
		/**
		 * Special button with left side squared
		 */		
		protected function buttonSpecialSquaredLeftInitializer(button:Button):void
		{
			const skinSelector:SmartDisplayObjectStateValueSelector = new SmartDisplayObjectStateValueSelector();
			skinSelector.defaultValue = this.buttonSpecialSquaredLeftUpSkinTextures;
			skinSelector.displayObjectProperties =
				{
					width: 114 * this.scaleFactor,
						height: (GlobalConfig.isPhone ? 98 : 108) * this.scaleFactor,
						textureScale: this.scaleFactor
				};
			button.stateToSkinFunction = skinSelector.updateValue;
			this.baseButtonSpecialInitializer(button);
		}
		
		/**
		 * Special button with right side squared
		 */		
		protected function buttonSpecialSquaredRightInitializer(button:Button):void
		{
			const skinSelector:SmartDisplayObjectStateValueSelector = new SmartDisplayObjectStateValueSelector();
			skinSelector.defaultValue = this.buttonSpecialSquaredRightUpSkinTextures;
			skinSelector.displayObjectProperties =
				{
					width: 114 * this.scaleFactor,
						height: (GlobalConfig.isPhone ? 98 : 108) * this.scaleFactor,
						textureScale: this.scaleFactor
				};
			button.stateToSkinFunction = skinSelector.updateValue;
			this.baseButtonSpecialInitializer(button);
		}
		/**
		 * Special button with right side squared
		 */		
		protected function buttonSpecialSquaredRightBiggerInitializer(button:Button):void
		{
			const skinSelector:SmartDisplayObjectStateValueSelector = new SmartDisplayObjectStateValueSelector();
			skinSelector.defaultValue = this.buttonSpecialSquaredRightUpSkinTextures;
			skinSelector.displayObjectProperties =
				{
					width: 114 * this.scaleFactor,
						height: (GlobalConfig.isPhone ? 98 : 108) * this.scaleFactor,
						textureScale: this.scaleFactor
				};
			button.stateToSkinFunction = skinSelector.updateValue;
			this.baseButtonSpecialInitializer(button, true);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Blue
		
		protected var buttonBlueTextFormat:TextFormat;
		
		/**
		 * Blue button */		
		public static const BUTTON_BLUE:String = "button-blue";
		protected var buttonBlueSkinTextures:Scale9Textures;
		
		/**
		 * Blue button squared on the right */		
		public static const BUTTON_BLUE_SQUARED_RIGHT:String = "button-blue-squared-right";
		protected var buttonBlueSquaredRightUpSkinTextures:Scale9Textures;
		
		/**
		 * Base button blue initializer.
		 */		
		protected function baseButtonBlueInitializer(button:Button):void
		{
			button.defaultLabelProperties.textFormat = this.buttonBlueTextFormat;
			
			button.scaleWhenDown = true;
			button.paddingTop = button.paddingBottom = 10 * this.scaleFactor;
			button.paddingLeft = button.paddingRight = 32 * this.scaleFactor;
			button.gap = 12 * this.scaleFactor;
			button.minWidth = 114 * this.scaleFactor;
			button.minHeight = (GlobalConfig.isPhone ? 98 : 108) * this.scaleFactor;
			button.minTouchWidth = button.minTouchHeight = 114 * this.scaleFactor;
		}
		
		/**
		 * Blue button.
		 */		
		protected function buttonBlueInitializer(button:Button):void
		{
			const skinSelector:SmartDisplayObjectStateValueSelector = new SmartDisplayObjectStateValueSelector();
			skinSelector.defaultValue = this.buttonBlueSkinTextures;
			skinSelector.displayObjectProperties =
				{
					width: 114 * this.scaleFactor,
						height: (GlobalConfig.isPhone ? 98 : 108) * this.scaleFactor,
						textureScale: this.scaleFactor
				};
			button.stateToSkinFunction = skinSelector.updateValue;
			this.baseButtonBlueInitializer(button);
		}
		
		/**
		 * Blue button with right side squared
		 */		
		protected function buttonBlueSquaredRightInitializer(button:Button):void
		{
			const skinSelector:SmartDisplayObjectStateValueSelector = new SmartDisplayObjectStateValueSelector();
			skinSelector.defaultValue = this.buttonBlueSquaredRightUpSkinTextures;
			skinSelector.displayObjectProperties =
				{
					width: 114 * this.scaleFactor,
						height: (GlobalConfig.isPhone ? 98 : 108) * this.scaleFactor,
						textureScale: this.scaleFactor
				};
			button.stateToSkinFunction = skinSelector.updateValue;
			this.baseButtonBlueInitializer(button);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Red
		
		/**
		 * Red button */		
		public static const BUTTON_RED:String = "button-red";
		protected var buttonRedSkinTextures:Scale9Textures;
		
		/**
		 * Red button.
		 */		
		protected function buttonRedInitializer(button:Button):void
		{
			const skinSelector:SmartDisplayObjectStateValueSelector = new SmartDisplayObjectStateValueSelector();
			skinSelector.defaultValue = this.buttonRedSkinTextures;
			skinSelector.displayObjectProperties =
				{
					width: 114 * this.scaleFactor,
						height: (GlobalConfig.isPhone ? 98 : 108) * this.scaleFactor,
						textureScale: this.scaleFactor
				};
			button.stateToSkinFunction = skinSelector.updateValue;
			this.baseButtonBlueInitializer(button);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Green
		
		/**
		 * Green button */		
		public static const BUTTON_GREEN:String = "button-green";
		protected var buttonGreenSkinTextures:Scale9Textures;
		
		/**
		 * Green button.
		 */		
		protected function buttonGreenInitializer(button:Button):void
		{
			const skinSelector:SmartDisplayObjectStateValueSelector = new SmartDisplayObjectStateValueSelector();
			skinSelector.defaultValue = this.buttonGreenSkinTextures;
			skinSelector.displayObjectProperties =
				{
					width: 114 * this.scaleFactor,
						height: (GlobalConfig.isPhone ? 98 : 108) * this.scaleFactor,
						textureScale: this.scaleFactor
				};
			button.stateToSkinFunction = skinSelector.updateValue;
			this.baseButtonInitializer(button);
		}
		
//------------------------------------------------------------------------------------------------------------
//	News
		
		/**
		 * Button displayed in the news screen. */		
		public static const BUTTON_NEWS:String = "button-news";
		protected var buttonNewsUpSkinTextures:Scale9Textures;
		protected var buttonNewsTextFormat:TextFormat;
		
		/**
		 * Button used in the NewsItemRenderer when a renderer is touchable
		 * and redirects somewhere.
		 */		
		protected function buttonNewsInitializer(button:Button):void
		{
			const skinSelector:SmartDisplayObjectStateValueSelector = new SmartDisplayObjectStateValueSelector();
			skinSelector.defaultValue = this.buttonNewsUpSkinTextures;
			skinSelector.displayObjectProperties =
				{
					width: 49 * this.scaleFactor,
						height: 56 * this.scaleFactor,
						textureScale: this.scaleFactor
				};
			button.stateToSkinFunction = skinSelector.updateValue;
			
			button.defaultLabelProperties.textFormat = this.buttonNewsTextFormat;
			
			button.paddingTop = button.paddingBottom = 10 * this.scaleFactor;
			button.paddingLeft  = 39 * this.scaleFactor;
			button.paddingRight = 10 * this.scaleFactor;
			button.gap = 12 * this.scaleFactor;
			button.minWidth = 49 * this.scaleFactor;
			button.minHeight = 56 * this.scaleFactor;
			button.minTouchWidth = 49 * this.scaleFactor;
			button.minTouchHeight = 56 * this.scaleFactor;
		}
		
//------------------------------------------------------------------------------------------------------------
//	Sponsor and account
		
		/**
		 * Sponsor button. */		
		public static const BUTTON_FLAT_GREEN:String = "button-sponsor";
		protected static const BUTTON_FLAT_GREEN_GRID:Rectangle = new Rectangle(4, 4, 8, 8);
		protected var buttonFlatGreenSkinTextures:Scale9Textures;
		protected var buttonFlatGreenTextFormat:TextFormat;
		protected var buttonFlatGreenDisabledTextFormat:TextFormat;
		
		/**
		 * Green sponsor button
		 */		
		protected function buttonFlatGreenInitializer(button:Button):void
		{
			button.defaultSkin = new Scale9Image(this.buttonFlatGreenSkinTextures, this.scaleFactor);
			button.defaultLabelProperties.textFormat = buttonFlatGreenTextFormat;
			
			const qd:Quad = new Quad(5, 5, 0xff0000);
			qd.alpha = 0;
			button.disabledSkin = qd;
			button.disabledLabelProperties.textFormat = buttonFlatGreenDisabledTextFormat;
			
			button.paddingTop = button.paddingBottom = 6 * this.scaleFactor;
			button.paddingLeft = button.paddingRight = 16 * this.scaleFactor;
			button.gap = 12 * this.scaleFactor;
			button.minWidth = 114 * this.scaleFactor;
			button.minHeight = 44 * this.scaleFactor;
			button.minTouchWidth = 114 * this.scaleFactor;
			button.minTouchHeight = 88 * this.scaleFactor;
		}
		
//------------------------------------------------------------------------------------------------------------
//	Ads (in tournament)
		
		/**
		 * White button with arrow on the left (for ads) */		
		public static const BUTTON_AD:String = "button-ad";
		protected static const BUTTON_AD_GRID:Rectangle = new Rectangle(34, 27, 10, 2);
		protected var buttonAdUpSkinTextures:Scale9Textures;
		protected var buttonAdTextFormat:TextFormat;
		
		/**
		 * Common button.
		 *  - Finalized
		 */		
		protected function buttonAdInitializer(button:Button):void
		{
			const skinSelector:SmartDisplayObjectStateValueSelector = new SmartDisplayObjectStateValueSelector();
			skinSelector.defaultValue = this.buttonAdUpSkinTextures;
			skinSelector.displayObjectProperties =
				{
					width: 49 * this.scaleFactor,
						height: 56 * this.scaleFactor,
						textureScale: this.scaleFactor
				};
			button.stateToSkinFunction = skinSelector.updateValue;
			
			button.defaultLabelProperties.textFormat = this.buttonAdTextFormat;
			
			button.paddingTop = button.paddingBottom = 10 * this.scaleFactor;
			button.paddingLeft  = 39 * this.scaleFactor;
			button.paddingRight = 10 * this.scaleFactor;
			button.gap = 12 * this.scaleFactor;
			button.minWidth = 49 * this.scaleFactor;
			button.minHeight = 56 * this.scaleFactor;
			button.minTouchWidth = 49 * this.scaleFactor;
			button.minTouchHeight = 56 * this.scaleFactor;
		}
		
//------------------------------------------------------------------------------------------------------------
//	Transparent normal, white and blue (lighter and darker)
		
		public static const BUTTON_EMPTY:String = "button-empty";
		
		/**
		 * Transparent button used for the rules in the home screen */		
		public static const BUTTON_TRANSPARENT_WHITE:String = "button-transparent";
		protected var buttonTransparentWhiteUpSkinTextures:Scale9Textures;
		protected var buttonTransparentWhiteTextFormat:TextFormat;
		
		/**
		 * Transparent button used for the rules in the home screen */		
		public static const BUTTON_TRANSPARENT_BLUE:String = "button-transparent-blue";
		protected var buttonTransparentBlueUpSkinTextures:Scale9Textures;
		protected var buttonTransparentBlueTextFormat:TextFormat;
		
		/**
		 * Transparent button used for the rules in the home screen */		
		public static const BUTTON_TRANSPARENT_BLUE_DARKER:String = "button-transparent-blue-darker";
		protected var buttonTransparentBlueDarkerUpSkinTextures:Scale9Textures;
		protected var buttonTransparentBlueDarkerTextFormat:TextFormat
		
		/**
		 * Use this button when we want to display a single icon and when we want
		 * to enhance the access.
		 */		
		protected function buttonEmptyInitializer(button:Button):void
		{
			button.scaleWhenDown = true;
			button.scaleWhenDownValue = 0.9;
			//button.minWidth = 112 * this.scale;
			button.minHeight = 120 * this.scaleFactor;
			button.minTouchWidth = 130 * this.scaleFactor;
			button.minTouchHeight = 120 * this.scaleFactor;
		}
		
		/**
		 * Button transparent white.
		 */		
		protected function buttonTransparentWhiteInitializer(button:Button):void
		{
			button.defaultSkin = new Scale9Image(buttonTransparentWhiteUpSkinTextures, this.scaleFactor);
			button.height = 88 * this.scaleFactor;
			
			button.defaultLabelProperties.textFormat = this.buttonTransparentWhiteTextFormat;
			
			button.scaleWhenDown = true;
			button.paddingTop = button.paddingBottom = 10 * this.scaleFactor;
			button.paddingLeft = button.paddingRight = 32 * this.scaleFactor;
			button.gap = 12 * this.scaleFactor;
			button.minWidth = button.minHeight = 68 * this.scaleFactor;
			button.minTouchWidth = button.minTouchHeight = 88 * this.scaleFactor;
		}
		
		/**
		 * Button transparent tinted blue.
		 */		
		protected function buttonTransparentBlueInitializer(button:Button):void
		{
			button.defaultSkin = new Scale9Image(buttonTransparentBlueUpSkinTextures, this.scaleFactor);
			
			button.defaultLabelProperties.textFormat = buttonTransparentBlueTextFormat;
			button.defaultLabelProperties.wordWrap = true;
			
			button.scaleWhenDown = true;
			button.paddingTop = button.paddingBottom = (GlobalConfig.isPhone ? 20 : 40) * this.scaleFactor;
			button.paddingLeft = button.paddingRight = 32 * this.scaleFactor;
			button.gap = (GlobalConfig.isPhone ? 12 : 22) * this.scaleFactor;
			button.minWidth = button.minHeight = 88 * this.scaleFactor;
			button.minTouchWidth = button.minTouchHeight = 88 * this.scaleFactor;
		}
		
		/**
		 * Transparent blue button used in the GameTypeSelectionPopup.
		 */		
		protected function buttonTransparentBlueDarkerInitializer(button:Button):void
		{
			button.defaultSkin = new Scale9Image(buttonTransparentBlueDarkerUpSkinTextures, this.scaleFactor);
			
			button.defaultLabelProperties.textFormat = buttonTransparentBlueDarkerTextFormat;
			
			button.scaleWhenDown = true;
			button.paddingTop = button.paddingBottom = 20 * this.scaleFactor;
			button.paddingLeft = button.paddingRight = 32 * this.scaleFactor;
			button.gap = 12 * this.scaleFactor;
			button.minWidth = button.minHeight = 78 * this.scaleFactor;
			button.minTouchWidth = button.minTouchHeight = 87 * this.scaleFactor;
		}
		
//------------------------------------------------------------------------------------------------------------
//
//
//
//												T O G G L E  S W I T C H
//
//
//
//------------------------------------------------------------------------------------------------------------
		
		public static const BUTTON_TOGGLE_SWITCH_THUMB:String = "button-toggle_switch_thumb";
		
		protected static const TOGGLE_SWITCH_BACKGROUND_GRID:Rectangle = new Rectangle(21, 25, 2, 4);
		protected var toggleSwitchBackgroundSkinTextures:Scale9Textures;
		
		protected var toggleSwitchThumbBackgroundSkinTextures:Scale9Textures;
		protected var toggleSwitchThumbDisabledBackgroundSkinTextures:Scale9Textures;
		protected var onThumbTextFormat:TextFormat;
		protected var offThumbTextFormat:TextFormat;
		
		protected function toggleSwitchInitializer(toggle:ToggleSwitch):void
		{
			toggle.trackLayoutMode = ToggleSwitch.TRACK_LAYOUT_MODE_SINGLE;
			toggle.customThumbName = BUTTON_TOGGLE_SWITCH_THUMB;
		}
		
		/**
		 * Button used as a background for a ToggleSwitch component?
		 */		
		protected function toggleSwitchTrackInitializer(track:Button):void
		{
			track.defaultSkin = new Scale9Image(toggleSwitchBackgroundSkinTextures, scaleFactor);
			track.minHeight = track.height = track.minTouchHeight = 44 * scaleFactor;
			track.minWidth = track.width = track.minTouchWidth = 60 * scaleFactor;
		}
		
		/**
		 * Button used as a thumb in a ToggleSwitch component.
		 */		
		protected function buttonToggleSwitchInitializer(button:Button):void
		{
			button.defaultSelectedSkin = new Scale9Image(toggleSwitchThumbBackgroundSkinTextures, scaleFactor);
			button.defaultSelectedLabelProperties.textFormat = onThumbTextFormat;
			
			button.defaultSkin = new Scale9Image(toggleSwitchThumbDisabledBackgroundSkinTextures, scaleFactor);
			button.defaultLabelProperties.textFormat = offThumbTextFormat;
			
			button.minHeight = button.height = button.minTouchHeight = 44 * scaleFactor;
			button.minWidth = button.width = button.minTouchWidth = 120 * scaleFactor;
		}
		
//------------------------------------------------------------------------------------------------------------
//
//
//
//												P A G E  I N D I C A T O R
//
//
//
//------------------------------------------------------------------------------------------------------------
		
		protected var pageIndicatorNormalSkinTexture:Texture;
		protected var pageIndicatorSelectedSkinTexture:Texture;
			
		protected function pageIndicatorInitializer(pageIndicator:PageIndicator):void
		{
			pageIndicator.normalSymbolFactory = this.pageIndicatorNormalSymbolFactory;
			pageIndicator.selectedSymbolFactory = this.pageIndicatorSelectedSymbolFactory;
			pageIndicator.gap = 10 * this.scaleFactor;
			pageIndicator.paddingTop = pageIndicator.paddingRight = pageIndicator.paddingBottom =
				pageIndicator.paddingLeft = 6 * this.scaleFactor;
			pageIndicator.minTouchWidth = pageIndicator.minTouchHeight = 44 * this.scaleFactor;
		}
		
		protected function pageIndicatorNormalSymbolFactory():DisplayObject
		{
			const symbol:ImageLoader = new ImageLoader();
			symbol.source = this.pageIndicatorNormalSkinTexture;
			symbol.textureScale = this.scaleFactor;
			return symbol;
		}
		
		protected function pageIndicatorSelectedSymbolFactory():DisplayObject
		{
			const symbol:ImageLoader = new ImageLoader();
			symbol.source = this.pageIndicatorSelectedSkinTexture;
			symbol.textureScale = this.scaleFactor;
			return symbol;
		}
		
//------------------------------------------------------------------------------------------------------------
//
//
//
//												C A L L O U T
//
//
//
//------------------------------------------------------------------------------------------------------------
		
		protected static const DEFAULT_CALLOUT_GRID:Rectangle = new Rectangle(40, 40, 20, 20);
		protected var calloutSkinTextures:Scale9Textures;
		protected var calloutTopArrowSkinTexture:Texture;
		protected var calloutRightArrowSkinTexture:Texture;
		protected var calloutBottomArrowSkinTexture:Texture;
		protected var calloutLeftArrowSkinTexture:Texture;
		
		protected function calloutInitializer(callout:Callout):void
		{
			const backgroundSkin:Scale9Image = new Scale9Image(this.calloutSkinTextures, this.scaleFactor);
			callout.backgroundSkin = backgroundSkin;
			
			const topArrowSkin:Image = new Image(this.calloutTopArrowSkinTexture);
			topArrowSkin.scaleX = topArrowSkin.scaleY = this.scaleFactor;
			callout.topArrowSkin = topArrowSkin;
			
			const rightArrowSkin:Image = new Image(this.calloutRightArrowSkinTexture);
			rightArrowSkin.scaleX = rightArrowSkin.scaleY = this.scaleFactor;
			callout.rightArrowSkin = rightArrowSkin;
			
			const bottomArrowSkin:Image = new Image(this.calloutBottomArrowSkinTexture);
			bottomArrowSkin.scaleX = bottomArrowSkin.scaleY = this.scaleFactor;
			callout.bottomArrowSkin = bottomArrowSkin;
			
			const leftArrowSkin:Image = new Image(this.calloutLeftArrowSkinTexture);
			leftArrowSkin.scaleX = leftArrowSkin.scaleY = this.scaleFactor;
			callout.leftArrowSkin = leftArrowSkin;
			
			callout.padding = 40 * this.scaleFactor;
			callout.bottomArrowGap = -20 * this.scaleFactor;
			callout.topArrowGap = -20 * this.scaleFactor;
		}
		
//------------------------------------------------------------------------------------------------------------
//
//
//
//												R A D I O
//
//
//
//------------------------------------------------------------------------------------------------------------
		
		protected var radioUpIconTexture:Texture;
		protected var radioDownIconTexture:Texture;
		//protected var radioDisabledIconTexture:Texture;
		protected var radioSelectedUpIconTexture:Texture;
		protected var radioSelectedDownIconTexture:Texture;
		protected var radioSelectedDisabledIconTexture:Texture;
		protected var radioTextFormat:TextFormat;
		
		protected function radioInitializer(radio:Radio):void
		{
			const iconSelector:SmartDisplayObjectStateValueSelector = new SmartDisplayObjectStateValueSelector();
			iconSelector.defaultValue = this.radioUpIconTexture;
			iconSelector.defaultSelectedValue = this.radioSelectedUpIconTexture;
			iconSelector.setValueForState(this.radioDownIconTexture, Button.STATE_DOWN, false);
			iconSelector.setValueForState(this.radioDownIconTexture, Button.STATE_DISABLED, false);
			iconSelector.setValueForState(this.radioSelectedDownIconTexture, Button.STATE_DOWN, true);
			iconSelector.setValueForState(this.radioSelectedDisabledIconTexture, Button.STATE_DISABLED, true);
			iconSelector.displayObjectProperties =
				{
					scaleX: this.scaleFactor,
						scaleY: this.scaleFactor
				};
			radio.stateToIconFunction = iconSelector.updateValue;
			
			radio.defaultLabelProperties.textFormat = radioTextFormat;
			
			radio.gap = 8 * this.scaleFactor;
			radio.minTouchWidth = radio.minTouchHeight = 88 * this.scaleFactor;
		}
		
//------------------------------------------------------------------------------------------------------------
//
//
//
//												P I C K E R  L I S T
//
//
//
//------------------------------------------------------------------------------------------------------------
		
		public static const COMPONENT_NAME_PICKER_LIST_ITEM_RENDERER:String = "feathers-mobile-picker-list-item-renderer";
		protected static const DEFAULT_SCALE9_GRID:Rectangle = new Rectangle(5, 5, 22, 22);
		
		protected var pickerListButtonIconTexture:Texture;
		protected var backgroundSkinTextures:Scale9Textures;
		
		protected var pickerListButtonTextFormat:TextFormat;
		protected var pickerListItemRendererTextFormat:TextFormat;
		protected var pickerListItemRendererSelectedTextFormat:TextFormat;
		
		protected function pickerListInitializer(list:PickerList):void
		{
			if(DeviceCapabilities.isTablet(Starling.current.nativeStage))
			{
				list.popUpContentManager = new CalloutPopUpContentManager();
			}
			else
			{
				const centerStage:VerticalCenteredPopUpContentManager = new VerticalCenteredPopUpContentManager();
				centerStage.marginTop = centerStage.marginRight = centerStage.marginBottom =
					centerStage.marginLeft = 24 * this.scaleFactor;
				list.popUpContentManager = centerStage;
			}
			
			const layout:VerticalLayout = new VerticalLayout();
			layout.verticalAlign = VerticalLayout.VERTICAL_ALIGN_BOTTOM;
			layout.horizontalAlign = VerticalLayout.HORIZONTAL_ALIGN_JUSTIFY;
			layout.useVirtualLayout = true;
			layout.gap = 0;
			layout.paddingTop = layout.paddingRight = layout.paddingBottom =
				layout.paddingLeft = 0;
			list.listProperties.layout = layout;
			list.listProperties.verticalScrollPolicy = List.SCROLL_POLICY_ON;
			list.listProperties.verticalScrollBarFactory = this.verticalScrollBarFactory;
			list.listProperties.horizontalScrollBarFactory = this.horizontalScrollBarFactory;
			
			if(DeviceCapabilities.isTablet(Starling.current.nativeStage))
			{
				list.listProperties.minWidth = 560 * this.scaleFactor;
				list.listProperties.maxHeight = 528 * this.scaleFactor;
			}
			else
			{
				const backgroundSkin:Scale9Image = new Scale9Image(this.backgroundSkinTextures, this.scaleFactor);
				backgroundSkin.width = 20 * this.scaleFactor;
				backgroundSkin.height = 20 * this.scaleFactor;
				list.listProperties.backgroundSkin = backgroundSkin;
				list.listProperties.paddingTop = list.listProperties.paddingRight =
					list.listProperties.paddingBottom = list.listProperties.paddingLeft = 8 * this.scaleFactor;
			}
			
			list.listProperties.itemRendererName = COMPONENT_NAME_PICKER_LIST_ITEM_RENDERER;
		}
		
		/**
		 * Button used for the picker list
		 */		
		protected function pickerListButtonInitializer(button:Button):void
		{
			const skinSelector:SmartDisplayObjectStateValueSelector = new SmartDisplayObjectStateValueSelector();
			skinSelector.defaultValue = this.textinputBackgroundSkinTextures;
			skinSelector.displayObjectProperties =
				{
					width: 60 * this.scaleFactor,
						height: 64 * this.scaleFactor,
						textureScale: this.scaleFactor
				};
			button.stateToSkinFunction = skinSelector.updateValue;
			
			button.defaultLabelProperties.textFormat = pickerListButtonTextFormat;
			
			button.paddingTop = button.paddingBottom = 6 * this.scaleFactor;
			button.paddingLeft = button.paddingRight = 8 * this.scaleFactor;
			button.gap = 6 * this.scaleFactor;
			button.minWidth = 60 * this.scaleFactor;
			button.minHeight = 64 * this.scaleFactor;
			button.minTouchWidth = 60 * this.scaleFactor;
			button.minTouchHeight = 64 * this.scaleFactor;
			
			const defaultIcon:Image = new Image(this.pickerListButtonIconTexture);
			defaultIcon.scaleX = defaultIcon.scaleY = this.scaleFactor;
			button.defaultIcon = defaultIcon;
			
			button.gap = Number.POSITIVE_INFINITY;
			button.iconPosition = Button.ICON_POSITION_RIGHT;
		}
		
		protected function pickerListItemRendererInitializer(renderer:BaseDefaultItemRenderer):void
		{
			const skinSelector:SmartDisplayObjectStateValueSelector = new SmartDisplayObjectStateValueSelector();
			skinSelector.defaultValue = groupedListMiddleBackgroundSkinTextures;
			skinSelector.defaultSelectedValue = groupedListMiddleBackgroundSelectedSkinTextures;
			skinSelector.setValueForState(groupedListMiddleBackgroundSelectedSkinTextures, Button.STATE_DOWN, false);
			skinSelector.displayObjectProperties =
				{
					width: 88 * this.scaleFactor,
						height: 88 * this.scaleFactor,
						textureScale: this.scaleFactor
				};
			renderer.stateToSkinFunction = skinSelector.updateValue;
			
			renderer.defaultLabelProperties.textFormat = pickerListItemRendererTextFormat;
			renderer.downLabelProperties.textFormat = pickerListItemRendererSelectedTextFormat;
			renderer.defaultSelectedLabelProperties.textFormat = pickerListItemRendererSelectedTextFormat;
			
			// taille 26 pour le debug
			
			renderer.horizontalAlign = Button.HORIZONTAL_ALIGN_LEFT;
			renderer.paddingTop = renderer.paddingBottom = 8 * this.scaleFactor;
			renderer.paddingLeft = 32 * this.scaleFactor;
			renderer.paddingRight = 24 * this.scaleFactor;
			renderer.gap = 20 * this.scaleFactor;
			renderer.iconPosition = Button.ICON_POSITION_LEFT;
			renderer.accessoryGap = Number.POSITIVE_INFINITY;
			renderer.accessoryPosition = BaseDefaultItemRenderer.ACCESSORY_POSITION_RIGHT;
			renderer.minWidth = renderer.minHeight = 88 * this.scaleFactor;
			renderer.minTouchWidth = renderer.minTouchHeight = 88 * this.scaleFactor;
			
			renderer.accessoryLoaderFactory = this.imageLoaderFactory;
			renderer.iconLoaderFactory = this.imageLoaderFactory;
		}
		
//------------------------------------------------------------------------------------------------------------
//
//
//
//												G R O U P E D  L I S T
//
//
//
//------------------------------------------------------------------------------------------------------------
		
		public static const SUB_CATEGORY_GROUPED_LIST:String = "sub-cat-grouped-list";
		public static const SUB_CATEGORY_INSET_HEADER_RENDERER:String = "sub-cat-inset-header-renderer";
		public static const SUB_CATEGORY_INSET_MIDDE_ITEM_RENDERER:String = "sub-cat-inset-middle-item-renderer";
		public static const SUB_CATEGORY_INSET_FIRST_ITEM_RENDERER:String = "sub-cat-inset-first-item-renderer";
		public static const SUB_CATEGORY_INSET_SINGLE_ITEM_RENDERER:String = "sub-cat-inset-single-item-renderer";
		public static const SUB_CATEGORY_INSET_LAST_ITEM_RENDERER:String = "sub-cat-inset-last-item-renderer";
		
		protected var groupedListBackgroundSkinTextures:Scale9Textures;
		protected var groupedListBackgroundSelectedSkinTextures:Scale9Textures;
		
		/**
		 * TextInput with rounded corners on the top */		
		protected var groupedListFirstBackgroundSkinTextures:Scale9Textures;
		protected var groupedListFirstBackgroundSelectedSkinTextures:Scale9Textures;
		
		/**
		 * TextInput with rounded corners on the bottom */		
		protected var groupedListLastBackgroundSkinTextures:Scale9Textures;
		protected var groupedListLastBackgroundSelectedSkinTextures:Scale9Textures;
		
		/**
		 * TextInput with no corners */		
		protected var groupedListMiddleBackgroundSkinTextures:Scale9Textures;
		protected var groupedListMiddleBackgroundSelectedSkinTextures:Scale9Textures;
		
		/**
		 * Custom grouped list used in the shop.
		 */		
		protected function subCategoryGroupedListInitializer(list:GroupedList):void
		{
			list.headerRendererName = SUB_CATEGORY_INSET_HEADER_RENDERER;
			list.singleItemRendererName = SUB_CATEGORY_INSET_SINGLE_ITEM_RENDERER;
			list.firstItemRendererName = SUB_CATEGORY_INSET_FIRST_ITEM_RENDERER;
			list.itemRendererName = SUB_CATEGORY_INSET_MIDDE_ITEM_RENDERER;
			list.lastItemRendererName = SUB_CATEGORY_INSET_LAST_ITEM_RENDERER;
			
			list.verticalScrollBarFactory = this.verticalScrollBarFactory;
			list.horizontalScrollBarFactory = this.horizontalScrollBarFactory;
		}
		
		protected function insetSubCatgoryItemRendererInitializer(renderer:DefaultGroupedListItemRenderer, defaultSkinTextures:Scale9Textures, selectedAndDownSkinTextures:Scale9Textures):void
		{
			const skinSelector:SmartDisplayObjectStateValueSelector = new SmartDisplayObjectStateValueSelector();
			skinSelector.defaultValue = defaultSkinTextures;
			skinSelector.defaultSelectedValue = selectedAndDownSkinTextures;
			skinSelector.setValueForState(selectedAndDownSkinTextures, Button.STATE_DOWN, false);
			skinSelector.displayObjectProperties =
				{
					width: 88 * this.scaleFactor,
						height: 88 * this.scaleFactor,
						textureScale: this.scaleFactor
				};
			renderer.stateToSkinFunction = skinSelector.updateValue;
			
			renderer.defaultLabelProperties.textFormat = pickerListItemRendererTextFormat;
			renderer.downLabelProperties.textFormat = pickerListItemRendererSelectedTextFormat;
			renderer.defaultSelectedLabelProperties.textFormat = pickerListItemRendererSelectedTextFormat;
			
			renderer.horizontalAlign = Button.HORIZONTAL_ALIGN_LEFT;
			renderer.paddingTop = renderer.paddingBottom = 8 * this.scaleFactor;
			renderer.paddingLeft = 32 * this.scaleFactor;
			renderer.paddingRight = 24 * this.scaleFactor;
			renderer.gap = 20 * this.scaleFactor;
			renderer.iconPosition = Button.ICON_POSITION_LEFT;
			renderer.accessoryGap = Number.POSITIVE_INFINITY;
			renderer.accessoryPosition = BaseDefaultItemRenderer.ACCESSORY_POSITION_RIGHT;
			renderer.minWidth = renderer.minHeight = 88 * this.scaleFactor;
			renderer.minTouchWidth = renderer.minTouchHeight = 88 * this.scaleFactor;
			
			renderer.accessoryLoaderFactory = this.imageLoaderFactory;
			renderer.iconLoaderFactory = this.imageLoaderFactory;
		}
		
		protected function insetSubCatgoryMiddleItemRendererInitializer(renderer:DefaultGroupedListItemRenderer):void
		{
			this.insetSubCatgoryItemRendererInitializer(renderer, this.groupedListMiddleBackgroundSkinTextures, this.groupedListMiddleBackgroundSelectedSkinTextures);
		}
		
		protected function insetSubCatgoryFirstItemRendererInitializer(renderer:DefaultGroupedListItemRenderer):void
		{
			this.insetSubCatgoryItemRendererInitializer(renderer, this.groupedListFirstBackgroundSkinTextures, this.groupedListFirstBackgroundSelectedSkinTextures);
		}
		
		protected function insetSubCatgoryLastItemRendererInitializer(renderer:DefaultGroupedListItemRenderer):void
		{
			this.insetSubCatgoryItemRendererInitializer(renderer, this.groupedListLastBackgroundSkinTextures, this.groupedListLastBackgroundSelectedSkinTextures);
		}
		
		protected function insetSubCatgorySingleItemRendererInitializer(renderer:DefaultGroupedListItemRenderer):void
		{
			this.insetSubCatgoryItemRendererInitializer(renderer, this.groupedListBackgroundSkinTextures, this.groupedListBackgroundSelectedSkinTextures);
		}
		
//------------------------------------------------------------------------------------------------------------
//
//
//
//												L I S T
//
//
//
//------------------------------------------------------------------------------------------------------------
		
		protected function listInitializer(list:List):void
		{
			list.verticalScrollBarFactory = this.verticalScrollBarFactory;
			list.horizontalScrollBarFactory = this.horizontalScrollBarFactory;
		}
		
//------------------------------------------------------------------------------------------------------------
//
//
//
//												P A R R A I N A G E
//
//
//
//------------------------------------------------------------------------------------------------------------
		
		protected var sponsorBonusBackground:Scale3Textures;
		protected static const SPONSOR_BONUS_REGION1:int = 5; // the x position westart to slice
		protected static const SPONSOR_BONUS_REGION2:int = 20; // the width after the x position
		
		protected function sponsorBonusItemRendererInitializer(renderer:SponsorBonusItemRenderer):void
		{
			renderer.backgroundSkin = new Scale3Image(this.sponsorBonusBackground, this.scaleFactor);
		}
		
//------------------------------------------------------------------------------------------------------------
//
//
//
//										G A M E  T Y P E  S E L E C T I O N
//
//
//
//------------------------------------------------------------------------------------------------------------
		
		/**
		 * Top left leaves. */		
		protected var topLeftLeavesTexture:Texture;
		/**
		 * Bottom left leaves. */		
		protected var bottomLeftLeavesTexture:Texture;
		/**
		 * Bottom middle leaves. */		
		protected var bottomMiddleLeavesTexture:Texture;
		/**
		 * Bottom right leaves. */		
		protected var bottomRightLeavesTexture:Texture;
		
		/**
		 * Left chain. */		
		protected var leftChainTexture:Texture;
		/**
		 * Right chain. */		
		protected var rightChainTexture:Texture;
		/**
		 * Lock closed. */		
		protected var lockClosed:Texture;
		/**
		 * Lock opened. */		
		protected var lockOpened:Texture;
		/**
		 * Lock glow. */		
		protected var lockGlow:Texture;
		/**
		 * Tile. */		
		protected var gameTypeSelectionTileTexture:Texture;
		
		protected static const GAME_TYPE_SELECTION_POPUP_FRONT_GRID:Rectangle = new Rectangle(38, 72, 19, 13);
		protected var gameTypeSelectionFrontTextures:Scale9Textures;
		
		protected static const GAME_TYPE_SELECTION_POPUP_BACKGROUND_GRID:Rectangle = new Rectangle(30, 30, 20, 20);
		protected var gameTypeSelectionBackgroundTextures:Scale9Textures;
		
		/**
		 * GameTypeSelectionPopup displayed in the home screen.
		 */		
		protected function gameTypeSelectionPopupInitializer(popup:GameTypeSelectionPopup):void
		{
			popup.frontSkin = new Scale9Image(gameTypeSelectionFrontTextures, scaleFactor);
			popup.backgroundSkin = new Scale9Image(gameTypeSelectionBackgroundTextures, scaleFactor);
			popup.topLeftLeaves = new Image(topLeftLeavesTexture);
			popup.topLeftLeaves.pivotX = popup.topLeftLeaves.width * 0.35;
			popup.topLeftLeaves.pivotY = popup.topLeftLeaves.height * 0.35;
			popup.topLeftLeaves.scaleX = popup.topLeftLeaves.scaleY = scaleFactor;
			popup.bottomLeftLeaves = new Image(bottomLeftLeavesTexture);
			popup.bottomLeftLeaves.pivotX = popup.bottomLeftLeaves.width * 0.35;
			popup.bottomLeftLeaves.pivotY = popup.bottomLeftLeaves.height * 0.6;
			popup.bottomLeftLeaves.scaleX = popup.bottomLeftLeaves.scaleY = scaleFactor;
			popup.bottomMiddleLeaves = new Image(bottomMiddleLeavesTexture);
			popup.bottomMiddleLeaves.pivotX = popup.bottomMiddleLeaves.width * 0.5;
			popup.bottomMiddleLeaves.pivotY = popup.bottomMiddleLeaves.height * 0.6;
			popup.bottomMiddleLeaves.scaleX = popup.bottomMiddleLeaves.scaleY = scaleFactor;
			popup.bottomRightLeaves = new Image(bottomRightLeavesTexture);
			popup.bottomRightLeaves.pivotX = popup.bottomRightLeaves.width * 0.6;
			popup.bottomRightLeaves.pivotY = popup.bottomRightLeaves.height * 0.6;
			popup.bottomRightLeaves.scaleX = popup.bottomRightLeaves.scaleY = scaleFactor;
			popup.shadowThickness = 10 * scaleFactor;
			popup.buttonAdjustment = 23 * scaleFactor;
			popup.leftLock = new Image(leftChainTexture);
			popup.leftLock.scaleX = popup.leftLock.scaleY = scaleFactor;
			popup.rightLock = new Image(rightChainTexture);
			popup.rightLock.scaleX = popup.rightLock.scaleY = scaleFactor;
			popup.lock = new Image(lockClosed);
			popup.lock.scaleX = popup.lock.scaleY = scaleFactor;
			popup.glow = new Image(lockGlow);
			popup.glow.alignPivot();
			popup.glow.scaleX = popup.glow.scaleY = 0;
			popup.unlockTexture = lockOpened;
			popup.tiledBackground = new TiledImage(gameTypeSelectionTileTexture, scaleFactor);
		}
		
//------------------------------------------------------------------------------------------------------------
//
//
//
//								G A M E  P R I C E  S E L E C T I O N  B U T T O N S
//
//
//
//------------------------------------------------------------------------------------------------------------
		
		protected function baseGamePriceSelectionButtonInitializer(container:GamePriceSelectionButton):void
		{
			container.shadowThickness = 17 * this.scaleFactor;
			container.minWidth = 60 * this.scaleFactor;
			container.minHeight = 140 * this.scaleFactor;
		}
		
		/**
		 * 
		 */		
		protected function gamePriceSelectionButtonPointsInitializer(container:GamePriceSelectionButtonPoints):void
		{
			container.backgroundSkin = new Scale9Image(this.buttonBlueSkinTextures, this.scaleFactor);
			container.backgroundDisabledSkin = new Scale9Image(this.buttonDisabledSkinTextures, this.scaleFactor);
			baseGamePriceSelectionButtonInitializer(container);
		}
		
		/**
		 * 
		 */		
		protected function gamePriceSelectionButtonFreeInitializer(container:GamePriceSelectionButtonFree):void
		{
			container.backgroundSkin = new Scale9Image(this.buttonGreenSkinTextures, this.scaleFactor);
			container.backgroundDisabledSkin = new Scale9Image(this.buttonDisabledSkinTextures, this.scaleFactor);
			baseGamePriceSelectionButtonInitializer(container);
		}
		
		/**
		 * 
		 */		
		protected function gamePriceSelectionButtonCreditsInitializer(container:GamePriceSelectionButtonCredits):void
		{
			container.backgroundSkin = new Scale9Image(this.buttonYellowSkinTextures, this.scaleFactor);
			container.backgroundDisabledSkin = new Scale9Image(this.buttonDisabledSkinTextures, this.scaleFactor);
			baseGamePriceSelectionButtonInitializer(container);
		}
		
//------------------------------------------------------------------------------------------------------------
//
//
//
//										N O T I F I C A T I O N S
//
//
//
//------------------------------------------------------------------------------------------------------------
		
		protected var notificationContainerBackgroundSkinTextures:Scale9Textures;
		protected var notificationContainerBottomDecorationSkinTextures:Scale3Textures;
		protected var notificationContainerTopDecorationSkinTextures:Scale3Textures;
		protected static const NOTIFICATION_CONTAINER_GRID:Rectangle = new Rectangle(30, 50, 4, 2);
		protected static var NOTIFICATION_CONTAINER_TOP_DECORATION_REGION1:int = 135; // the x position westart to slice
		protected static var NOTIFICATION_CONTAINER_TOP_DECORATION_REGION2:int = 2; // the width after the x position
		protected static var NOTIFICATION_CONTAINER_BOTTOM_DECORATION_REGION1:int = 66; // the x position westart to slice
		protected static var NOTIFICATION_CONTAINER_BOTTOM_DECORATION_REGION2:int = 2; // the width after the x position
		
		/**
		 * AbstractNotification
		 */		
		protected function abstractNotificationInitializer(container:AbstractNotification):void
		{
			scrollContainerInitializer(container);
			container.backgroundSkinou = new Scale9Image(notificationContainerBackgroundSkinTextures, scaleFactor);
			container.topLeftDecoration = new Scale3Image(notificationContainerTopDecorationSkinTextures, scaleFactor);
			container.topRightDecoration = new Scale3Image(notificationContainerTopDecorationSkinTextures, scaleFactor);
			container.bottomLeftDecoration = new Scale3Image(notificationContainerBottomDecorationSkinTextures, scaleFactor);
			container.bottomRightDecoration = new Scale3Image(notificationContainerBottomDecorationSkinTextures, scaleFactor);
		}
		
//------------------------------------------------------------------------------------------------------------
//
//
//
//										T R O P H Y  M E S S A G E
//
//
//
//------------------------------------------------------------------------------------------------------------
		
		protected var trophyGainTextFormat:TextFormat;
		protected var trophyMessageTextFormat:TextFormat;
		protected var trophyBackgroundSkinTextures:Scale9Textures;
		protected var TROPHY_BACKGROUND_GRID:Rectangle = new Rectangle(11, 11, 18, 18);
		
		protected function trophyMessageInitializer(trophyMessage:TrophyMessage):void
		{
			trophyMessage.background = new Scale9Image(trophyBackgroundSkinTextures, this.scaleFactor);
			trophyMessage.textFormatMessage = trophyMessageTextFormat;
			trophyMessage.textFormatGain = trophyGainTextFormat;
			trophyMessage.width = 500 * scaleFactor;
			trophyMessage.height = 130 * scaleFactor
		}
		
//------------------------------------------------------------------------------------------------------------
//
//
//
//										S T O R E  I T E M  R E N D E R E R
//
//
//
//------------------------------------------------------------------------------------------------------------
		
		protected var storeBackgroundSkinTextures:Scale9Textures;
		protected var storeTopOfferTexture:Scale3Textures;
		protected var storePlayersChoiceTexture:Scale3Textures;
		protected static const STORE_BACKGROUND_CONTAINER_GRID:Rectangle = new Rectangle(20, 55, 20, 30);
		
		protected function sotreItemRendererInitializer(renderer:StoreItemRenderer):void
		{
			renderer.topOfferTexture =  new Scale3Image(storeTopOfferTexture, this.scaleFactor);
			renderer.playersChoiceTexture = new Scale3Image(storePlayersChoiceTexture, this.scaleFactor);
			renderer.backgroundSkin = new Scale9Image(storeBackgroundSkinTextures, this.scaleFactor);
			renderer.paddingLeft = scaleAndRoundToDpi(18);
			renderer.paddingRight = scaleAndRoundToDpi(18);
			renderer.paddingBottom = scaleAndRoundToDpi(20);
			renderer.headerHeight = scaleAndRoundToDpi(54);
		}
		
//------------------------------------------------------------------------------------------------------------
//
//
//
//						C U S T O M E R  S E R V I C E  T H R E A D  I T E M  R E N D E R E R 
//
//
//
//------------------------------------------------------------------------------------------------------------
		
		protected var customerServiceThreadBackgroundSkinTextures:Scale9Textures;
		protected static const CUSTOMER_SERVICE_BACKGROUND_CONTAINER_GRID:Rectangle = new Rectangle(25, 50, 10, 20);
		
		protected var customerServiceDefaultAvatarTexture:Texture;
		protected var customerServiceDefaultUserAvatarTexture:Texture;
		
		protected function customerServiceThreadItemRendererInitializer(renderer:CSThreadItemRenderer):void
		{
			renderer.messageBackground = new Scale9Image(customerServiceThreadBackgroundSkinTextures, scaleFactor);
			renderer.csDefaultTexture = customerServiceDefaultAvatarTexture;
			renderer.csDefaultUserTexture = customerServiceDefaultUserAvatarTexture;
			renderer.minItemHeight = 150 * scaleFactor;
			renderer.stripeHeight = 90 * scaleFactor;
			renderer.paddingMessageTop = renderer.paddingMessageBottom = 20 * scaleFactor;
			renderer.paddingMessageLeft = renderer.paddingMessageRight = 40 * scaleFactor;
		}
		
//------------------------------------------------------------------------------------------------------------
//
//
//
//							A D  T O U R N A M E N T  I T E M  R E N D E R E R
//
//
//
//------------------------------------------------------------------------------------------------------------
		
		protected var adTournamentFirstRankTextFormat:TextFormat;
		protected var adTournamentSecondRankTextFormat:TextFormat;
		protected var adTournamentThirdRankTextFormat:TextFormat;
		
		protected function adTournamentItemRendererInitializer(renderer:AdTournamentItemRenderer):void
		{
			renderer.firstTextFormat = adTournamentFirstRankTextFormat;
			renderer.secondTextFormat = adTournamentSecondRankTextFormat;
			renderer.thirdTextFormat = adTournamentThirdRankTextFormat;
		}
		
//------------------------------------------------------------------------------------------------------------
//
//
//
//											R U L E S
//
//
//
//------------------------------------------------------------------------------------------------------------
		
		protected var ruleTitleTextFormat:TextFormat;
		protected var ruleNormalTextFormat:TextFormat;
		
		protected function ruleItemRendererInitializer(renderer:RuleItemRenderer):void
		{
			renderer.titleTextFormat = ruleTitleTextFormat;
			renderer.ruleTextFormat = ruleNormalTextFormat;
		}
		
//------------------------------------------------------------------------------------------------------------
//
//
//
//								A L E R T  I T E M  R E N D E R E R
//
//
//
//------------------------------------------------------------------------------------------------------------
		
		protected function alertItemRendererInitializer(renderer:AlertItemRenderer):void
		{
			renderer.minItemHeight = 100 * this.scaleFactor;
			renderer.gap = 10 * this.scaleFactor;
			renderer.paddingMessageTop = renderer.paddingMessageBottom = 20 * this.scaleFactor;
			renderer.paddingMessageLeft = renderer.paddingMessageRight = 20 * this.scaleFactor;
		}
		
//------------------------------------------------------------------------------------------------------------
//
//
//
//								F A C E B O O K  F R I E N D  E L E M E N T
//
//
//
//------------------------------------------------------------------------------------------------------------
		
		protected static const FACEBOOK_FRIEND_BACKGROUND_GRID:Rectangle = new Rectangle(22, 24, 17, 2);
		protected var facebookFriendBackgroundSkinTextures:Scale9Textures;
		
		protected function facebookFriendElementInitializer(facebookFriendElement:FacebookFriendElement):void
		{
			facebookFriendElement.background = new Scale9Image(facebookFriendBackgroundSkinTextures, this.scaleFactor);
			facebookFriendElement.height = 160 * this.scaleFactor
		}

//------------------------------------------------------------------------------------------------------------
//
//
//
//								S C R O L L  C O N T A I N E R
//
//
//
//------------------------------------------------------------------------------------------------------------
		
//------------------------------------------------------------------------------------------------------------
//	White for the tutorial
		
		public static const SCROLL_CONTAINER_WHITE:String = "scroll-container-white";
		
		/**
		 * Common ScrollContainer initializer.
		 */		
		protected function scrollContainerInitializer(container:ScrollContainer):void
		{
			container.verticalScrollBarFactory = verticalScrollBarFactory;
			container.horizontalScrollBarFactory = horizontalScrollBarFactory;
		}
		
		/**
		 * ScrollContainer with a white background (used for the tutorial).
		 */		
		protected function scrollContainerWhiteInitializer(container:ScrollContainer):void
		{
			scrollContainerInitializer(container);
			container.backgroundSkin = new Scale9Image(textinputBackgroundSkinTextures, this.scaleFactor);
			container.minHeight = 60 * this.scaleFactor;
			container.padding = 5 * this.scaleFactor;
		}
		
//------------------------------------------------------------------------------------------------------------
//	With and arrow (TournamentEndScreen)
		
		/**
		 * The container used at the end of a tournament game (it is an arrow) */		
		public static const TOURNAMENT_END_ARROW_CONTAINER:String = "tournament-end-arrow-container";
		protected var tournamentEndArrowSkinTextures:Scale3Textures;
		protected static const TOURNAMENT_END_ARROW_REGION1:int = 26; // the x position westart to slice
		protected static const TOURNAMENT_END_ARROW_REGION2:int = 30; // the width after the x position
		
		/**
		 * ScrollContainer with an arrow as background (used in the TournamentEndScreen
		 * to display the number of stars need ed to reach the next podium).
		 */		
		protected function scrollContainerTournamentEndArrowInitializer(container:ScrollContainer):void
		{
			scrollContainerInitializer(container);
			container.backgroundSkin = new Scale3Image(this.tournamentEndArrowSkinTextures, this.scaleFactor);
			container.minHeight = container.maxHeight = 83 * this.scaleFactor;
			container.paddingRight = 20 * this.scaleFactor;
			container.paddingLeft = 20 * this.scaleFactor;
		}
		
//------------------------------------------------------------------------------------------------------------
//	Grey for the convert container and the timer in both TournamentEndScreen and FreeGameEndScreen
		
		/**
		 * Scroll container used at the end of a game session */		
		public static const SCROLL_CONTAINER_RESULT_GREY:String = "scroll-container-result-grey";
		protected static const SCROLL_CONTAINER_RESULT_GREY_GRID:Rectangle = new Rectangle(15, 15, 2, 2);
		protected var scrollContainerResultGreyBackgroundSkinTextures:Scale9Textures;
		
		/**
		 * ScrollContainer used for the convert container and the timer
		 * in both TournamentEndScreen and FreeGameEndScreen.
		 */		
		protected function scrollContainerResultGreyInitializer(container:ScrollContainer):void
		{
			scrollContainerInitializer(container);
			container.backgroundSkin = new Scale9Image(this.scrollContainerResultGreyBackgroundSkinTextures, this.scaleFactor);
			container.minHeight = 60 * this.scaleFactor; // same as text input
			
			const vlayout:VerticalLayout = new VerticalLayout();
			vlayout.horizontalAlign = VerticalLayout.HORIZONTAL_ALIGN_CENTER;
			vlayout.verticalAlign = VerticalLayout.VERTICAL_ALIGN_MIDDLE;
			vlayout.padding = 20 * scaleFactor;
			vlayout.gap = (GlobalConfig.isPhone ? 10 : 20) * scaleFactor;
			container.layout = vlayout;
		}
		
//------------------------------------------------------------------------------------------------------------
//	ScrollContainer for badges count
		
		public static const SCROLL_CONTAINER_BADGE:String = "scroll-container-badge";
		protected var scrollContainerBadgeBackgroundSkinTextures:Scale9Textures;
		protected static const SCROLL_CONTAINER_BADGE_GRID:Rectangle = new Rectangle(10, 10, 10, 10);
		
		/**
		 * Scroll container de fin de partie (affichant les résultats)
		 */		
		protected function scrollContainerBadgeInitializer(container:ScrollContainer):void
		{
			// FIXME besoin du layout ?
			const layout:HorizontalLayout = new HorizontalLayout();
			layout.horizontalAlign = HorizontalLayout.HORIZONTAL_ALIGN_CENTER;
			layout.verticalAlign = HorizontalLayout.VERTICAL_ALIGN_MIDDLE;
			
			container.layout = layout;
			container.backgroundSkin = new Scale9Image(this.scrollContainerBadgeBackgroundSkinTextures, this.scaleFactor);
			container.minHeight = container.minWidth = 30 * this.scaleFactor; // same as text input
			container.horizontalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			container.verticalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			container.paddingTop = container.paddingBottom = 2 * this.scaleFactor;
			container.paddingLeft = container.paddingRight = 6 * this.scaleFactor;
		}
		
//------------------------------------------------------------------------------------------------------------
//	ScrollContainer used for the AlertButton in the header
		
		public static const SCROLL_CONTAINER_ALERT:String = "scroll-container-alert";
		protected var scrollContainerAlertBackgroundSkinTextures:Scale9Textures;
		
		protected function scrollContainerAlertInitializer(container:ScrollContainer):void
		{
			// FIXME besoin du layout ?
			const layout:HorizontalLayout = new HorizontalLayout();
			layout.horizontalAlign = HorizontalLayout.HORIZONTAL_ALIGN_CENTER;
			layout.verticalAlign = HorizontalLayout.VERTICAL_ALIGN_MIDDLE;
			
			container.layout = layout;
			container.backgroundSkin = new Scale9Image(this.scrollContainerAlertBackgroundSkinTextures, this.scaleFactor);
			container.minHeight = container.minWidth = 30 * this.scaleFactor; // same as text input
			container.horizontalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			container.verticalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			container.paddingTop = container.paddingBottom = 0 * this.scaleFactor;
			container.paddingLeft = container.paddingRight = 2 * this.scaleFactor;
		}
		
//------------------------------------------------------------------------------------------------------------
//	ScrollContziner used in the pseudo choice screen to display the choices
		
		public static const SCROLL_CONTAINER_LABEL:String = "scroll-container-label";
		protected static const SCROLL_CONTAINER_LABEL_GRID:Rectangle = new Rectangle(15, 15, 2, 2);
		protected var scrollContainerLabelBackgroundSkinTextures:Scale9Textures;
		
		/**
		 * ScrollContainer with background skin (for Label).
		 */		
		protected function scrollContainerLabelInitializer(container:ScrollContainer):void
		{
			scrollContainerInitializer(container);
			container.backgroundSkin = new Scale9Image(this.scrollContainerLabelBackgroundSkinTextures, this.scaleFactor);
			container.minHeight = 80 * scaleFactor; // same as text input
		}
		
//------------------------------------------------------------------------------------------------------------
//	White container with the bottom right corner squared
		
		protected static const SCROLL_CONTAINER_RESULT_GRID:Rectangle = new Rectangle(21, 20, 2, 2);
		
		/**
		 * Scroll container used at the end of a game session */		
		public static const SCROLL_CONTAINER_RESULT_LIGHT_CORNER_BOTTOM_RIGHT:String = "scroll-container-result-light-corner-bottom-right";
		protected var scrollContainerResultLightCornerBottomRightBackgroundSkinTextures:Scale9Textures;
		
		/**
		 * Scroll container de fin de partie (affichant les résultats)
		 */		
		protected function scrollContainerResultCornerBottomRightInitializer(container:ScrollContainer):void
		{
			scrollContainerInitializer(container);
			container.backgroundSkin = new Scale9Image(this.scrollContainerResultLightCornerBottomRightBackgroundSkinTextures, this.scaleFactor);
			container.minHeight = 60 * this.scaleFactor; // same as text input
			//container.padding = 10 * this.scaleFactor;
			
			const vlayout:VerticalLayout = new VerticalLayout();
			vlayout.horizontalAlign = VerticalLayout.HORIZONTAL_ALIGN_CENTER;
			vlayout.verticalAlign = VerticalLayout.VERTICAL_ALIGN_MIDDLE;
			vlayout.padding = (GlobalConfig.isPhone ? 30 : 30) * scaleFactor;
			vlayout.gap = (GlobalConfig.isPhone ? 10 : 20) * scaleFactor;
			container.layout = vlayout;
		}
		
//------------------------------------------------------------------------------------------------------------
//	White container with the bottom left corner squared
		
		/**
		 * Scroll container used at the end of a game session */		
		public static const SCROLL_CONTAINER_RESULT_LIGHT_CORNER_BOTTOM_LEFT:String = "scroll-container-result-light-corner-bottom-left";
		protected var scrollContainerResultLightCornerBottomLeftBackgroundSkinTextures:Scale9Textures;
		
		/**
		 * Scroll container de fin de partie (affichant les résultats)
		 */		
		protected function scrollContainerResultCornerBottomLeftInitializer(container:ScrollContainer):void
		{
			scrollContainerInitializer(container);
			container.backgroundSkin = new Scale9Image(this.scrollContainerResultLightCornerBottomLeftBackgroundSkinTextures, this.scaleFactor);
			container.minHeight = 60 * this.scaleFactor; // same as text input
			//container.padding = 10 * this.scaleFactor;
			
			const vlayout:VerticalLayout = new VerticalLayout();
			vlayout.horizontalAlign = VerticalLayout.HORIZONTAL_ALIGN_CENTER;
			vlayout.verticalAlign = VerticalLayout.VERTICAL_ALIGN_MIDDLE;
			vlayout.padding = 30 * scaleFactor;
			vlayout.gap = (GlobalConfig.isPhone ? 10 : 20) * scaleFactor;
			container.layout = vlayout;
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dark container with the top left corner squared
		
		/**
		 * Scroll container used at the end of a game session */		
		public static const SCROLL_CONTAINER_RESULT_DARK_CORNER_TOP_LEFT:String = "scroll-container-result-dark-corner-top-left";
		protected var scrollContainerResultDarkCornerTopLeftBackgroundSkinTextures:Scale9Textures;
		
		/**
		 * Scroll container de fin de partie (affichant les résultats)
		 */		
		protected function scrollContainerResultCornerTopLeftInitializer(container:ScrollContainer):void
		{
			scrollContainerInitializer(container);
			container.backgroundSkin = new Scale9Image(this.scrollContainerResultDarkCornerTopLeftBackgroundSkinTextures, this.scaleFactor);
			container.minHeight = 60 * this.scaleFactor; // same as text input
			container.padding = 20 * this.scaleFactor;
			
			const vlayout:VerticalLayout = new VerticalLayout();
			vlayout.horizontalAlign = VerticalLayout.HORIZONTAL_ALIGN_CENTER;
			vlayout.verticalAlign = VerticalLayout.VERTICAL_ALIGN_MIDDLE;
			vlayout.gap = 10 * this.scaleFactor;
			container.layout = vlayout;
		}
		
//------------------------------------------------------------------------------------------------------------
//
//
//
//											S C R O L L  B A R
//
//
//
//------------------------------------------------------------------------------------------------------------
		
		protected static const SCROLL_BAR_THUMB_REGION1:int = 5;
		protected static const SCROLL_BAR_THUMB_REGION2:int = 14;
		
		protected var verticalScrollBarThumbSkinTextures:Scale3Textures;
		protected var horizontalScrollBarThumbSkinTextures:Scale3Textures;
		
		protected function horizontalScrollBarFactory():SimpleScrollBar
		{
			const scrollBar:SimpleScrollBar = new SimpleScrollBar();
			scrollBar.direction = SimpleScrollBar.DIRECTION_HORIZONTAL;
			const defaultSkin:Scale3Image = new Scale3Image(this.horizontalScrollBarThumbSkinTextures, this.scaleFactor);
			defaultSkin.width = 10 * this.scaleFactor;
			scrollBar.thumbProperties.defaultSkin = defaultSkin;
			scrollBar.paddingRight = scrollBar.paddingBottom = scrollBar.paddingLeft = 4 * this.scaleFactor;
			return scrollBar;
		}
		
		protected function verticalScrollBarFactory():SimpleScrollBar
		{
			const scrollBar:SimpleScrollBar = new SimpleScrollBar();
			scrollBar.direction = SimpleScrollBar.DIRECTION_VERTICAL;
			const defaultSkin:Scale3Image = new Scale3Image(this.verticalScrollBarThumbSkinTextures, this.scaleFactor);
			defaultSkin.height = 10 * this.scaleFactor;
			scrollBar.thumbProperties.defaultSkin = defaultSkin;
			scrollBar.paddingTop = scrollBar.paddingRight = scrollBar.paddingBottom = 4 * this.scaleFactor;
			return scrollBar;
		}
		
//------------------------------------------------------------------------------------------------------------
//
//
//
//									T R O P H Y  I T E M  R E N D E R E R
//
//
//
//------------------------------------------------------------------------------------------------------------
		
		public static var trophyIRTitleTF:TextFormat;
		public static var trophyIRMessageTF:TextFormat;
		public static var trophyIRRewardTF:TextFormat;
		public static var trophyIRRewardOwnedTF:TextFormat;
		public static var trophyIROwnedTF:TextFormat;
		
		protected var trophyHighlightTexture:Texture;
		protected var trophyOwnedTexture:Texture;
		
		protected function trophyItemRendererInitializer(renderer:TrophyItemRenderer):void
		{
			const highlight:Image = new Image( trophyHighlightTexture );
			highlight.scaleX = highlight.scaleY = scaleFactor;
			renderer.highlights = highlight;
			
			const owned:Image = new Image( trophyOwnedTexture );
			owned.scaleX = owned.scaleY = scaleFactor;
			renderer.ownedLabelImage = owned;
		}
		
//------------------------------------------------------------------------------------------------------------
//
//
//
//											L A B E L
//
//
//
//------------------------------------------------------------------------------------------------------------
		
		protected function labelAlignRightInitializer(label:Label):void
		{
			label.textRendererProperties.textFormat.align = TextFormatAlign.RIGHT;
			label.textRendererProperties.wordWrap = true;
		}
		
		protected function labelAlignCenterInitializer(label:Label):void
		{
			label.textRendererProperties.textFormat.align = TextFormatAlign.CENTER;
			label.textRendererProperties.wordWrap = true;
		}
		
		protected function baseLabelInitializer(label:Label):void
		{
			label.textRendererProperties.textFormat = baseLabelTextFormat;
			label.textRendererProperties.textFormat.align = TextFormatAlign.LEFT;
			label.textRendererProperties.wordWrap = true;
		}
		
//------------------------------------------------------------------------------------------------------------
//
//
//
//								A C C O U N T  I T E M  R E N D E R E R
//
//
//
//------------------------------------------------------------------------------------------------------------
		
		public static var accountIRTextFormat:TextFormat;
		public static var accountIRLabelTextFormat:TextFormat;
		
//------------------------------------------------------------------------------------------------------------
//
//
//
//								F A Q  I T E M  R E N D E R E R
//
//
//
//------------------------------------------------------------------------------------------------------------
		
		public static var faqIRTextFormat:TextFormat;
		
//------------------------------------------------------------------------------------------------------------
//
//
//
//								M E N U  I T E M  R E N D E R E R
//
//
//
//------------------------------------------------------------------------------------------------------------
		
		public static var menuIRTextFormat:TextFormat;
		public static var menuIRBadgeTextFormat:TextFormat;
		
		protected function menuItemRendererInitializer(renderer:MenuItemRenderer):void
		{
			renderer.borderThickness = scaleAndRoundToDpi(2);
			renderer.stripeThickness = scaleAndRoundToDpi(48);
		}
		
//------------------------------------------------------------------------------------------------------------
//
//
//
//							C O N T A C T  I T E M  R E N D E R E R
//
//
//
//------------------------------------------------------------------------------------------------------------
		
		public static var contactIRNameTextFormat:TextFormat;
		public static var contactIRValueTextFormat:TextFormat;
		
//------------------------------------------------------------------------------------------------------------
//
//
//
//				C U S T O M E R  S E R V I C E  M E S S A G E  I T E M  R E N D E R E R
//
//
//
//------------------------------------------------------------------------------------------------------------
		
		public static var csMessageIRTitleReadTextFormat:TextFormat;
		public static var csMessageIRMessageReadTextFormat:TextFormat;
		public static var csMessageIRDateReadTextFormat:TextFormat;
		
		public static var csMessageIRTitleTextFormat:TextFormat;
		public static var csMessageIRMessageTextFormat:TextFormat;
		public static var csMessageIRDateTextFormat:TextFormat;
		
//------------------------------------------------------------------------------------------------------------
//
//
//
//					C U S T O M E R  T H R E A D  I T E M  R E N D E R E R
//
//
//
//------------------------------------------------------------------------------------------------------------
		
		public static var csThreadIRMessageTextFormat:TextFormat;
		public static var csThreadIRDateTextFormat:TextFormat;
		
//------------------------------------------------------------------------------------------------------------
//
//
//
//				B O U T I Q U E  C A T E G O R Y  M E S S A G E  I T E M  R E N D E R E R
//
//
//
//------------------------------------------------------------------------------------------------------------
		
		public static var boutiqueCategoryIRTitleTextFormat:TextFormat;
		
//------------------------------------------------------------------------------------------------------------
//
//
//
//								F I L L E U L  I T E M  R E N D E R E R
//
//
//
//------------------------------------------------------------------------------------------------------------
		
		public static var filleulIRNameTextFormat:TextFormat;
		
//------------------------------------------------------------------------------------------------------------
//
//
//
//							G I F T  H I S T O R Y  I T E M  R E N D E R E R
//
//
//
//------------------------------------------------------------------------------------------------------------
		
		public static var giftIRTitleTextFormat:TextFormat;
		
//------------------------------------------------------------------------------------------------------------
//
//
//
//							H I S T O R Y  H E A D E R  I T E M  R E N D E R E R
//
//
//
//------------------------------------------------------------------------------------------------------------
		
		public static var historyIRTitleTextFormat:TextFormat;
		
//------------------------------------------------------------------------------------------------------------
//
//
//
//							P A Y M E N T  H I S T O R Y  I T E M  R E N D E R E R
//
//
//
//------------------------------------------------------------------------------------------------------------
		
		public static var paymentIRTitleTextFormat:TextFormat;
		
//------------------------------------------------------------------------------------------------------------
//
//
//
//									N E W S  I T E M  R E N D E R E R
//
//
//
//------------------------------------------------------------------------------------------------------------
		
		public static var newsIRTitleTextFormat:TextFormat;
		public static var newsIRMessageTextFormat:TextFormat;
		
//------------------------------------------------------------------------------------------------------------
//
//
//
//						P R E V I O U S  T O U R N A M E N T  I T E M  R E N D E R E R
//
//
//
//------------------------------------------------------------------------------------------------------------
		
		public static var previousTournamentIRTextFormat:TextFormat;
		
//------------------------------------------------------------------------------------------------------------
//
//
//
//								S E T T I N G S  I T E M  R E N D E R E R
//
//
//
//------------------------------------------------------------------------------------------------------------
		
		public static var settingsIRTextFormat:TextFormat;
		
//------------------------------------------------------------------------------------------------------------
//
//
//
//								N O T  L O G G E D  I N  C O N T A I N E R
//
//
//
//------------------------------------------------------------------------------------------------------------
		
		public static var notLoggedInMessageTextFormat:TextFormat;
		public static var notLoggedInButtonTextFormat:TextFormat;
		
//------------------------------------------------------------------------------------------------------------
//
//
//
//							F I L L E U L  R E W A R D  I T E M  R E N D E R E R
//
//
//
//------------------------------------------------------------------------------------------------------------
		
		public static var filleulRewardIRTextFormat:TextFormat;
		
//------------------------------------------------------------------------------------------------------------
//
//
//
//							R A N K  H E A D E R  I T E M  R E N D E R E R
//
//
//
//------------------------------------------------------------------------------------------------------------
		
		public static var rankHeaderIRTextFormat:TextFormat;
		
//------------------------------------------------------------------------------------------------------------
//
//
//
//								R E T R Y  C O N T A I N E R 
//
//
//
//------------------------------------------------------------------------------------------------------------
		
		public static var retryContainerLightTextFormat:TextFormat;
		public static var retryContainerDarkTextFormat:TextFormat;
		
//------------------------------------------------------------------------------------------------------------
//
//
//
//							R A N K  H E A D E R  I T E M  R E N D E R E R
//
//
//
//------------------------------------------------------------------------------------------------------------
		
		public static var boutiqueItemIRTextFormat:TextFormat;
		
//------------------------------------------------------------------------------------------------------------
//
//
//
//							C O M M O N  B I D  I T E M  R E N D E R E R
//
//
//
//------------------------------------------------------------------------------------------------------------
		
		public static var commonBidIRTextFormat:TextFormat;
		
//------------------------------------------------------------------------------------------------------------
//
//
//
//							A C C O U N T  H I S T O R Y  I T E M  R E N D E R E R
//
//
//
//------------------------------------------------------------------------------------------------------------
		
		public static var accoutHistoryIRTitleTextFormat:TextFormat;
		
//------------------------------------------------------------------------------------------------------------
//
//
//
//										I N F O  M A N A G E R
//
//
//
//------------------------------------------------------------------------------------------------------------
		
		public static var infoManagerOverlay:Texture;
		
//------------------------------------------------------------------------------------------------------------
//
//
//
//										F R E E  G A M E  E N D  S C R E E N
//
//
//
//------------------------------------------------------------------------------------------------------------
		
		public static var freeGameEndScreenContainerTitleTextFormat:TextFormat;
		
//------------------------------------------------------------------------------------------------------------
//
//
//
//							S C O R E  T O  P O I N T S  I T E M  R E N D E R E R
//
//
//
//------------------------------------------------------------------------------------------------------------
		
		public static var scoreToPointsIRTextFormat:TextFormat;
		
//------------------------------------------------------------------------------------------------------------
//
//
//
//							H I G H  S C O R E  L I S T  H E A D E R
//
//
//
//------------------------------------------------------------------------------------------------------------
		
		public static var highScoreListHeaderTextFormat:TextFormat;
		
//------------------------------------------------------------------------------------------------------------
//
//
//
//					M A R K E T I N G  R E G I S T E R  N O T I F I C A T I O N  B O N U S
//
//
//
//------------------------------------------------------------------------------------------------------------
		
		public static var marketingRegisterNotificationBonusTextFormat:TextFormat;
		
//------------------------------------------------------------------------------------------------------------
//
//
//
//								S U M M A R Y  E L E M E N T
//
//
//
//------------------------------------------------------------------------------------------------------------
		
		public static var summaryElementTextFormat:TextFormat;
		
//------------------------------------------------------------------------------------------------------------
//
//
//
//								P A U S E  V I E W
//
//
//
//------------------------------------------------------------------------------------------------------------
		
		public static var pauseViewLabelTextFormat:TextFormat;
		
	}
}