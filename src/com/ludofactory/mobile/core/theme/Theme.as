package com.ludofactory.mobile.core.theme
{
	
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.AbstractGameInfo;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.config.Platform;
	
	import feathers.controls.Button;
	import feathers.controls.ButtonState;
	import feathers.controls.Callout;
	import feathers.controls.GroupedList;
	import feathers.controls.ImageLoader;
	import feathers.controls.List;
	import feathers.controls.PageIndicator;
	import feathers.controls.Radio;
	import feathers.controls.Screen;
	import feathers.controls.ScrollContainer;
	import feathers.controls.ScrollText;
	import feathers.controls.Scroller;
	import feathers.controls.SimpleScrollBar;
	import feathers.controls.TextInput;
	import feathers.controls.ToggleButton;
	import feathers.controls.ToggleSwitch;
	import feathers.controls.TrackLayoutMode;
	import feathers.controls.text.StageTextTextEditor;
	import feathers.controls.text.TextBlockTextRenderer;
	import feathers.controls.text.TextFieldTextRenderer;
	import feathers.core.FeathersControl;
	import feathers.core.PopUpManager;
	import feathers.layout.Direction;
	import feathers.layout.HorizontalLayout;
	import feathers.layout.VerticalLayout;
	import feathers.skins.ImageSkin;
	import feathers.system.DeviceCapabilities;
	import feathers.themes.StyleNameFunctionTheme;
	
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Rectangle;
	import flash.system.Capabilities;
	import flash.text.AutoCapitalize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.text.engine.ElementFormat;
	import flash.text.engine.FontDescription;
	
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.events.Event;
	import starling.textures.Texture;
	
	public class Theme extends StyleNameFunctionTheme
	{
		
//------------------------------------------------------------------------------------------------------------
//	Fonts
		
		[Embed(source="./fonts/Arial.ttf", fontFamily="Arial", fontWeight="normal", fontStyle="normal", mimeType="application/x-font-truetype", embedAsCFF="false")]
		protected static const ARIAL:Class;
		
		[Embed(source="./fonts/Arial Italic.ttf", fontFamily="Arial", fontWeight="normal", fontStyle="italic", mimeType="application/x-font-truetype", embedAsCFF="false")]
		protected static const ARIAL_ITALIC:Class;
		
		[Embed(source="./fonts/Arial Bold.ttf", fontFamily="Arial", fontWeight="bold", fontStyle="normal", mimeType="application/x-font-truetype", embedAsCFF="false")]
		protected static const ARIAL_BOLD:Class;
		
		[Embed(source="./fonts/Arial Bold Italic.ttf", fontFamily="Arial", fontWeight="bold", fontStyle="italic", mimeType="application/x-font-truetype", embedAsCFF="false")]
		protected static const ARIAL_BOLD_ITALIC:Class;
		
		[Embed(source="./fonts/SansitaOne.ttf", fontFamily="Sansita", fontWeight="normal", fontStyle="normal", mimeType="application/x-font-truetype", embedAsCFF="false")]
		protected static const SANSITAONE:Class;
		
		public static const FONT_ARIAL:String = "Arial";
		public static const FONT_SANSITA:String = "Sansita";
		
//------------------------------------------------------------------------------------------------------------
//	Scale factor
		
		protected var _originalDPI:int;
		protected var _scaleToDPI:Boolean;
		
		/**
		 * DPI reference for the iPhone Retina. Since all the SD assets have been designed for this reolution,
		 * this value will help us to calculate the appropriate dpi scale value.
		 * 
		 * Default is 326. */		
		public static const ORIGINAL_DPI_IPHONE_RETINA:int = 326;
		/**
		 * Resolution in which the SD assets (i.e the smartphone assets) have been designed.
		 * It matches the iPhone Retina resolution. */
		public static const ORIGINAL_X:int = 960;
		public static const ORIGINAL_Y:int = 640;
		
		
		/**
		 * DPI reference for the iPad Retina. Since all the SD assets have been designed for this reolution,
		 * this value will help us to calculate the appropriate dpi scale value.
		 * 
		 * Defauly is 264. */
		public static const ORIGINAL_DPI_IPAD_RETINA:int = 264;
		/**
		 * Resolution in which the HD assets (i.e the smartphone assets) have been designed.
		 * It matches the iPad Retina resolution. */
		public static const ORIGINAL_X_TABLETTE:int= 1024;
		public static const ORIGINAL_Y_TABLETTE:int = 768;
		
		
		/**
		 * The scale factor. */		
		protected var scaleFactor:Number = 1;
		
		/**
		 * Calculates the appropriate scale factor depending on the screen resolution.
		 *
		 * Base on : http://salsadepixeles.blogspot.com.es/2013/05/fitting-game-to-in-any-screen-resolution.html
		 */
		private static function getScaleFactor():Number
		{
			var screenResolutionX:int = GlobalConfig.platformName != Platform.SIMULATOR ? Capabilities.screenResolutionX : (AbstractGameInfo.LANDSCAPE ? (GlobalConfig.isPhone ? ORIGINAL_X : ORIGINAL_X_TABLETTE) : (GlobalConfig.isPhone ? ORIGINAL_Y : ORIGINAL_Y_TABLETTE)); // WARNING : this reports the computer resolution in the simulator !
			var screenResolutionY:int = GlobalConfig.platformName != Platform.SIMULATOR ? Capabilities.screenResolutionY : (AbstractGameInfo.LANDSCAPE ? (GlobalConfig.isPhone ? ORIGINAL_Y : ORIGINAL_Y_TABLETTE) : (GlobalConfig.isPhone ? ORIGINAL_X : ORIGINAL_X_TABLETTE)); // WARNING : this reports the computer resolution in the simulator !
			var ratioX:Number = screenResolutionX / (AbstractGameInfo.LANDSCAPE ? (GlobalConfig.isPhone ? ORIGINAL_X : ORIGINAL_X_TABLETTE) : (GlobalConfig.isPhone ? ORIGINAL_Y : ORIGINAL_Y_TABLETTE));
			var ratioY:Number = screenResolutionY / (AbstractGameInfo.LANDSCAPE ? (GlobalConfig.isPhone ? ORIGINAL_Y : ORIGINAL_Y_TABLETTE) : (GlobalConfig.isPhone ? ORIGINAL_X : ORIGINAL_X_TABLETTE));
			
			if (ratioX < ratioY)
			{
				return ratioX;
			}
			else
			{
				return ratioY;
			}
		}
		
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
		public static var popupScrollArrow:Texture;
		
		// Particles textures and XMLs
		/**
		 * Particle texture used for confettis in HighScore and Podium screens. */		
		public static var particleConfettiTexture:Texture;
		/**
		 * Particle texture used for sparkles in HighScore and Podium screens. */		
		public static var particleSparklesTexture:Texture;
		/**
		 * Particle texture used in Boutique, TrophyMessage and HowToWinGifts screens. */		
		public static var particleRoundTexture:Texture;
		/**
		 * Particle texture used in the TournamentEndScreen. */		
		public static var particleStarTexture:Texture;
		
		/**
		 * Particle configuration used for confettis in HighScore and Podium screens. */		
		public static var particleConfettiXml:XML;
		/**
		 * Particle configuration used for sparkles in HighScore and Podium screens
		 * when the logos animates in. */		
		public static var particleSparklesXml:XML;
		public static var particleSlowXml:XML;
		public static var particleStarsXml:XML;
		public static var particleVortexXml:XML;
		public static var particleStarsLogoXml:XML;
		
//------------------------------------------------------------------------------------------------------------
//	Init
		
		public function Theme(scaleToDPI:Boolean = true)
		{
			super();
			this._scaleToDPI = scaleToDPI;
			this.initialize();
			this.dispatchEventWith(Event.COMPLETE);
		}
		
		/**
		 * Initializes the theme. Expected to be called by subclasses after the
		 * assets have been loaded and the skin texture atlas has been created.
		 */
		protected function initialize():void
		{
			initializeDimensions();
			initializeScale();
			initializeFonts();
			initializeTextures();
			initializeTexturesNew();
			initializeParticles();
			initializeGlobals();
			initializeStyleProviders();
		}
		
		protected var gridSize:int;
		protected var gutterSize:int;
		protected var smallGutterSize:int;
		protected var extraSmallGutterSize:int;
		protected var borderSize:int;
		protected var controlSize:int;
		protected var smallControlSize:int;
		protected var wideControlSize:int;
		protected var popUpFillSize:int;
		protected var thumbSize:int;
		protected var calloutBackgroundMinSize:int;
		protected var calloutVerticalArrowGap:int;
		protected var calloutHorizontalArrowGap:int;
		protected var shadowSize:int;
		protected function initializeDimensions():void
		{
			this.gridSize = 70;
			this.gutterSize = 20;
			this.smallGutterSize = 10;
			this.extraSmallGutterSize = 5;
			this.borderSize = 1;
			this.controlSize = 50;
			this.smallControlSize = 16;
			this.wideControlSize = 230;
			this.popUpFillSize = 300;
			this.thumbSize = 34;
			this.calloutBackgroundMinSize = 53;
			this.calloutVerticalArrowGap = -8;
			this.calloutHorizontalArrowGap = -7;
			this.shadowSize = 2;
		}
		
		protected function initializeScale():void
		{
			var starling:Starling = Starling.current;
			var nativeScaleFactor:Number = 1;
			if(starling.supportHighResolutions)
			{
				nativeScaleFactor = starling.nativeStage.contentsScaleFactor;
			}
			var scaledDPI:int = DeviceCapabilities.dpi / (starling.contentScaleFactor / nativeScaleFactor);
			this._originalDPI = scaledDPI;
			if(this._scaleToDPI)
			{
				if(DeviceCapabilities.isTablet(starling.nativeStage))
				{
					this._originalDPI = ORIGINAL_DPI_IPAD_RETINA;
				}
				else
				{
					this._originalDPI = ORIGINAL_DPI_IPHONE_RETINA;
				}
			}
			
			this.scaleFactor = GlobalConfig.dpiScale = scaledDPI / this._originalDPI;
			//if(GlobalConfig.deviceId != "simulator")
			//{
				this.scaleFactor = GlobalConfig.dpiScale = (getScaleFactor() + GlobalConfig.dpiScale) / 2; // moyenne des deux calculés (plus précis ?)
			//}
			//this.stageTextScale = this.scaleFactor / nativeScaleFactor; // TODO A remettre ?
		}
		
		protected function initializeFonts():void
		{
			// TextInput
			textInputTextFormat = new TextFormat(FONT_ARIAL, scaleAndRoundToDpi(25), COLOR_LIGHT_GREY, true);
			textInputPromptTextFormat = new TextFormat(FONT_ARIAL, scaleAndRoundToDpi(25), 0xcbcbcb, true, true);
			
			// Button
			buttonTextFormat                      = new TextFormat(FONT_SANSITA, scaleAndRoundToDpi(42), COLOR_BROWN);
			buttonTransparentBlueDarkerTextFormat = new TextFormat(FONT_SANSITA, scaleAndRoundToDpi(GlobalConfig.isPhone ? 26 : 32), COLOR_DARK_GREY);
			
			// ToggleSwitch
			//onThumbTextFormat  = new TextFormat(FONT_ARIAL, scaleAndRoundToDpi(24), COLOR_WHITE, true, true);
			//offThumbTextFormat = new TextFormat(FONT_ARIAL, scaleAndRoundToDpi(24), COLOR_VERY_LIGHT_GREY, true, true);
			
			// Radio
			radioTextFormat = new TextFormat(FONT_SANSITA, scaleAndRoundToDpi(24), COLOR_LIGHT_GREY);
			
			// PickerList
			pickerListButtonTextFormat               = new TextFormat(FONT_ARIAL, scaleAndRoundToDpi(26), COLOR_LIGHT_GREY, false, true);
			pickerListItemRendererTextFormat         = new TextFormat(FONT_ARIAL, scaleAndRoundToDpi(36), COLOR_LIGHT_GREY, true, true);
			pickerListItemRendererSelectedTextFormat = new TextFormat(FONT_ARIAL, scaleAndRoundToDpi(36), COLOR_ORANGE, true, true);
			
			pickerListDebugButtonTextFormat               = new TextFormat(FONT_ARIAL, scaleAndRoundToDpi(26), COLOR_LIGHT_GREY, false, true);
			pickerListDebugItemRendererTextFormat         = new TextFormat(FONT_ARIAL, scaleAndRoundToDpi(22), COLOR_LIGHT_GREY, true, true);
			pickerListDebugItemRendererSelectedTextFormat = new TextFormat(FONT_ARIAL, scaleAndRoundToDpi(22), COLOR_ORANGE, true, true);
			
			// AccountHistoryItemRenderer
			accoutHistoryIRTitleTextFormat = new TextFormat(FONT_ARIAL, scaleAndRoundToDpi(26), COLOR_DARK_GREY, true);
			
			// AccountItemRenderer
			accountIRTextFormat = new TextFormat(FONT_ARIAL, scaleAndRoundToDpi(24), COLOR_DARK_GREY, true);
			accountIRLabelTextFormat = new TextFormat(FONT_ARIAL, scaleAndRoundToDpi(32), COLOR_LIGHT_GREY);
			
			// FaqItemRenderer
			faqIRTextFormat = new TextFormat(FONT_ARIAL, scaleAndRoundToDpi(26), COLOR_DARK_GREY, true);
			
			// BoutiqueCategoryItemRenderer
			boutiqueCategoryIRTitleTextFormat = new TextFormat(FONT_ARIAL, scaleAndRoundToDpi(26), COLOR_LIGHT_GREY, true, false, null, null, null, TextFormatAlign.CENTER);
			
			// GiftHistoryItemRenderer
			giftIRTitleTextFormat = new TextFormat(FONT_ARIAL, scaleAndRoundToDpi(26), COLOR_DARK_GREY, true);
			
			// HistoryHeaderItemRenderer
			historyIRTitleTextFormat = new TextFormat(FONT_ARIAL, scaleAndRoundToDpi(26), COLOR_WHITE, true);
			
			// PaymentHistoryItemRenderer
			paymentIRTitleTextFormat = new TextFormat(FONT_ARIAL, scaleAndRoundToDpi(26), COLOR_DARK_GREY, true);
			
			// NewsItemRenderer
			newsIRTitleTextFormat = new TextFormat(FONT_ARIAL, scaleAndRoundToDpi(26), COLOR_DARK_GREY, true);
			newsIRMessageTextFormat = new TextFormat(FONT_ARIAL, scaleAndRoundToDpi(26), COLOR_LIGHT_GREY, true, true);
			
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
			
			// Base Label
			baseLabelTextFormat = new TextFormat(FONT_SANSITA, scaleAndRoundToDpi(24), COLOR_BLACK);
			
			// Game
			inGameSuccessTextFormat = new TextFormat(FONT_SANSITA, scaleAndRoundToDpi(46), 0xc6d29d);
			inGameFailTextFormat = new TextFormat(FONT_SANSITA, scaleAndRoundToDpi(46), 0xc52828);
			
			// Top
			labelMessageHighscorePodiumTextFormat = new TextFormat(FONT_SANSITA, scaleAndRoundToDpi(50), COLOR_WHITE, false, false, null, null, null, TextFormatAlign.CENTER);
			labelPodiumTopTextFormat = new TextFormat(FONT_SANSITA, scaleAndRoundToDpi(120), COLOR_ORANGE, false, false, null, null, null, TextFormatAlign.CENTER);
			
			// FreeGameEndScreen
			freeGameEndScreenContainerTitleTextFormat = new TextFormat(FONT_SANSITA, scaleAndRoundToDpi(GlobalConfig.isPhone ? 50 : 72), COLOR_ORANGE, false, false, null, null, null, TextFormatAlign.CENTER);
			
			// ScoreToPointsItemRenderer
			highScoreListHeaderTextFormat = new TextFormat(FONT_SANSITA, scaleAndRoundToDpi(30), COLOR_LIGHT_GREY, false, false, null, null, null, TextFormatAlign.CENTER);
		}
		
		// TrophyItemRenderer
		/** Highlights behind the trophy image. */
		public static var trophyHighlightTexture:Texture;
		/** Owned background texture (top right corner). */
		public static var trophyOwnedTexture:Texture;
		
		protected function initializeTexturesNew():void
		{
			// TrophyItemRenderer
			trophyHighlightTexture = AbstractEntryPoint.assets.getTexture("trophy-highlight");
			trophyOwnedTexture = AbstractEntryPoint.assets.getTexture("trophy-owned-corner-label");
		}
		
		protected function initializeTextures():void
		{
			//horizontalScrollBarThumbSkinTextures = new Scale3Textures(AbstractEntryPoint.assets.getTexture("horizontal-scroll-bar-thumb-skin"), SCROLL_BAR_THUMB_REGION1, SCROLL_BAR_THUMB_REGION2, Scale3Textures.DIRECTION_HORIZONTAL);
			//verticalScrollBarThumbSkinTextures = new Scale3Textures(AbstractEntryPoint.assets.getTexture("vertical-scroll-bar-thumb-skin"), SCROLL_BAR_THUMB_REGION1, SCROLL_BAR_THUMB_REGION2, Scale3Textures.DIRECTION_VERTICAL);
			
			infoManagerOverlay = AbstractEntryPoint.assets.getTexture("overlay-skin");
			
			// logos
			gameLogoTexture         = AbstractEntryPoint.assets.getTexture("logo-game");
			ludokadoLogoTexture     = AbstractEntryPoint.assets.getTexture("logo-ludokado");
			gameCenterTexture       = AbstractEntryPoint.assets.getTexture("game-center");
			blackLoaderTextures     = AbstractEntryPoint.assets.getTextures("MiniLoader");
			popupScrollArrow        = AbstractEntryPoint.assets.getTexture("popup-scroll-arrow");
			
			// 
			downArrowLists = AbstractEntryPoint.assets.getTexture("arrow-down-dark");
			downArrowShadow = AbstractEntryPoint.assets.getTexture("list-shadow");
			
			// Particles
			particleConfettiTexture = AbstractEntryPoint.assets.getTexture("particle-confetti");
			particleSparklesTexture = AbstractEntryPoint.assets.getTexture("particle-sparkle");
			particleRoundTexture    = AbstractEntryPoint.assets.getTexture("particle-round");
			particleStarTexture     = AbstractEntryPoint.assets.getTexture("particle-star");
			
			// ToggleSwitch
			toggleSwitchBackgroundSkinTextures              = AbstractEntryPoint.assets.getTexture("toggle-switch-background");
			toggleSwitchThumbBackgroundSkinTextures         = AbstractEntryPoint.assets.getTexture("toggle-switch-thumb-background");
			toggleSwitchThumbDisabledBackgroundSkinTextures = AbstractEntryPoint.assets.getTexture("toggle-switch-thumb-disabled-background");
			
			// Radio
			radioUpIconTexture               = AbstractEntryPoint.assets.getTexture("radio-background-skin");
			radioDownIconTexture             = AbstractEntryPoint.assets.getTexture("radio-background-down-skin");
			radioSelectedUpIconTexture       = radioDownIconTexture;
			radioSelectedDownIconTexture     = radioDownIconTexture;
			radioSelectedDisabledIconTexture = AbstractEntryPoint.assets.getTexture("radio-selected-disabled-icon"); // à retirer ?
			
			// PickerList
			pickerListButtonIconTexture = AbstractEntryPoint.assets.getTexture("arrow_down");
			//backgroundSkinTextures = new Scale9Textures(AbstractEntryPoint.assets.getTexture("background-skin"), DEFAULT_SCALE9_GRID);
			
			// GameTypeSelection
			topLeftLeavesTexture = AbstractEntryPoint.assets.getTexture("game-type-selection-deco-top-left");
			bottomLeftLeavesTexture = AbstractEntryPoint.assets.getTexture("game-type-selection-deco-bottom-left");
			bottomMiddleLeavesTexture = AbstractEntryPoint.assets.getTexture("game-type-selection-deco-bottom-middle");
			bottomRightLeavesTexture = AbstractEntryPoint.assets.getTexture("game-type-selection-deco-bottom-right");
			leftChainTexture = AbstractEntryPoint.assets.getTexture("lock-left");
			rightChainTexture = AbstractEntryPoint.assets.getTexture("lock-right");
			lockClosed = AbstractEntryPoint.assets.getTexture("lock");
			lockGlow = AbstractEntryPoint.assets.getTexture("MiniLueur");
			lockOpened = AbstractEntryPoint.assets.getTexture("unlock");
			
			// ScrollContainer
			tournamentEndArrowSkinTextures = AbstractEntryPoint.assets.getTexture("tournament-end-arrow"), TOURNAMENT_END_ARROW_REGION1, TOURNAMENT_END_ARROW_REGION2;
			scrollContainerResultGreyBackgroundSkinTexture = AbstractEntryPoint.assets.getTexture("scroll-container-result-grey-background-skin");
			scrollContainerAlertBackgroundSkinTexture = AbstractEntryPoint.assets.getTexture("alert-background-skin");
			scrollContainerResultLightCornerBottomRightBackgroundSkinTexture = AbstractEntryPoint.assets.getTexture("scroll-container-result-light-corner-bottom-right");
			scrollContainerResultLightCornerBottomLeftBackgroundSkinTexture = AbstractEntryPoint.assets.getTexture("scroll-container-result-light-corner-bottom-left");
			
			
			// ---------- N E W
			
			// buttons
			buttonSpecialSkinTextures                = AbstractEntryPoint.assets.getTexture("button-special");
			buttonYellowSkinTextures                 = AbstractEntryPoint.assets.getTexture("button-yellow");
			buttonWhiteSkinTextures                  = AbstractEntryPoint.assets.getTexture("button-white");
			facebookButtonSkinTextures               = AbstractEntryPoint.assets.getTexture("button-facebook");
			buttonBlueSkinTextures                   = AbstractEntryPoint.assets.getTexture("button-blue");
			buttonRedSkinTextures                    = AbstractEntryPoint.assets.getTexture("button-red");
			buttonGreenSkinTextures                  = AbstractEntryPoint.assets.getTexture("button-green");
			buttonDisabledSkinTextures               = AbstractEntryPoint.assets.getTexture("button-grey");
			buttonTransparentBlueDarkerUpSkinTexture = AbstractEntryPoint.assets.getTexture("button-transparent-blue-darker");
			
			this.verticalSimpleScrollBarThumbTexture = AbstractEntryPoint.assets.getTexture("vertical-scroll-bar-thumb-skin");
			this.horizontalSimpleScrollBarThumbTexture = AbstractEntryPoint.assets.getTexture("horizontal-scroll-bar-thumb-skin");
			
			// PageIndicator
			pageIndicatorSelectedTexture = AbstractEntryPoint.assets.getTexture("page-indicator-selected-skin");
			pageIndicatorNormalTexture   = AbstractEntryPoint.assets.getTexture("page-indicator-normal-skin");
			
			// Callout
			calloutSkinTexture        = AbstractEntryPoint.assets.getTexture("callout-background-skin");
			calloutTopArrowTexture    = AbstractEntryPoint.assets.getTexture("callout-arrow-top-skin");
			calloutRightArrowTexture  = AbstractEntryPoint.assets.getTexture("callout-arrow-right-skin");
			calloutBottomArrowTexture = AbstractEntryPoint.assets.getTexture("callout-arrow-bottom-skin");
			calloutLeftArrowTexture   = AbstractEntryPoint.assets.getTexture("callout-arrow-left-skin");
			
			// TextInput
			textinputBackgroundSkinTextures  = AbstractEntryPoint.assets.getTexture("textinput-background-skin");
			textinputFirstBackgroundTexture  = AbstractEntryPoint.assets.getTexture("textinput-first-background-skin");
			textinputLastBackgroundTexture   = AbstractEntryPoint.assets.getTexture("textinput-last-background-skin");
			textinputMiddleBackgroundTexture = AbstractEntryPoint.assets.getTexture("textinput-middle-background-skin");
		}
		
		/**
		 * Initializes the particles
		 */
		protected function initializeParticles():void
		{
			var fileStream:FileStream = new FileStream();
			
			fileStream.open( File.applicationDirectory.resolvePath( "assets/particles/particles_confetti.pex" ), FileMode.READ );
			particleConfettiXml = XML(fileStream.readUTFBytes(fileStream.bytesAvailable));
			
			fileStream.open( File.applicationDirectory.resolvePath( "assets/particles/particles_sparkles.pex" ), FileMode.READ );
			particleSparklesXml = XML(fileStream.readUTFBytes(fileStream.bytesAvailable));
			
			fileStream.open( File.applicationDirectory.resolvePath( "assets/particles/particles_slow.pex" ), FileMode.READ );
			particleSlowXml = XML(fileStream.readUTFBytes(fileStream.bytesAvailable));
			
			fileStream.open( File.applicationDirectory.resolvePath( "assets/particles/particles_stars.pex" ), FileMode.READ );
			particleStarsXml = XML(fileStream.readUTFBytes(fileStream.bytesAvailable));
			
			fileStream.open( File.applicationDirectory.resolvePath( "assets/particles/particles-vortex.pex" ), FileMode.READ );
			particleVortexXml = XML(fileStream.readUTFBytes(fileStream.bytesAvailable));
			
			fileStream.open( File.applicationDirectory.resolvePath( "assets/particles/particles_stars_logo.pex" ), FileMode.READ );
			particleStarsLogoXml = XML(fileStream.readUTFBytes(fileStream.bytesAvailable));
			
			// dispose
			fileStream.close();
			fileStream = null;
		}
		
		protected function initializeGlobals():void
		{
			FeathersControl.defaultTextRendererFactory = textRendererFactory;
			FeathersControl.defaultTextEditorFactory = textEditorFactory;
			
			PopUpManager.overlayFactory = popUpOverlayFactory;
			Callout.stagePaddingTop = Callout.stagePaddingRight = Callout.stagePaddingBottom = Callout.stagePaddingLeft = 16 * this.scaleFactor;
		}
		
		protected function initializeStyleProviders():void
		{
			
			//getStyleProviderForClass(GroupedList).defaultStyleFunction = groupedListInitializer;
			
			// Screen
			getStyleProviderForClass(Screen).defaultStyleFunction = screenInitializer;
			
			// Button
			//getStyleProviderForClass(Button).defaultStyleFunction = buttonInitializer; // TODO ????
			//getStyleProviderForClass(Button).setFunctionForStyleName(BUTTON_TRANSPARENT_BLUE_DARKER, buttonTransparentBlueDarkerInitializer);
			getStyleProviderForClass(Button).setFunctionForStyleName(BUTTON_EMPTY, buttonEmptyInitializer);
			
			// ToggleSwitch
			getStyleProviderForClass(ToggleSwitch).defaultStyleFunction = toggleSwitchInitializer;
			//setInitializerForClass(Button, buttonToggleSwitchInitializer, BUTTON_TOGGLE_SWITCH_THUMB); // avant quand le Button avait la propriété isSelected (qui maintenant a migré dans le ToggleButton)
			getStyleProviderForClass(ToggleButton).setFunctionForStyleName(BUTTON_TOGGLE_SWITCH_THUMB, buttonToggleSwitchInitializer);
			//getStyleProviderForClass(Button).setFunctionForStyleName(ToggleSwitch.DEFAULT_CHILD_NAME_ON_TRACK, toggleSwitchTrackInitializer);
			
			
			
			// PickerList
			/*getStyleProviderForClass(PickerList).defaultStyleFunction = pickerListInitializer;
			getStyleProviderForClass(PickerList).setFunctionForStyleName(PICKER_LIST_DEBUG, pickerListDebugInitializer);
			getStyleProviderForClass(Button).setFunctionForStyleName(PickerList.DEFAULT_CHILD_NAME_BUTTON, pickerListButtonInitializer);
			getStyleProviderForClass(DefaultListItemRenderer).setFunctionForStyleName(COMPONENT_NAME_PICKER_LIST_ITEM_RENDERER, pickerListItemRendererInitializer);
			getStyleProviderForClass(DefaultListItemRenderer).setFunctionForStyleName(PICKER_LIST_DEBUG_ITEM_RENDERER, pickerListDebugItemRendererInitializer);*/
			
			// ScrollContainer
			getStyleProviderForClass(ScrollContainer).setFunctionForStyleName(SCROLL_CONTAINER_WHITE, scrollContainerWhiteInitializer);
			getStyleProviderForClass(ScrollContainer).setFunctionForStyleName(TOURNAMENT_END_ARROW_CONTAINER, scrollContainerTournamentEndArrowInitializer);
			getStyleProviderForClass(ScrollContainer).setFunctionForStyleName(SCROLL_CONTAINER_RESULT_GREY, scrollContainerResultGreyInitializer);
			getStyleProviderForClass(ScrollContainer).setFunctionForStyleName(SCROLL_CONTAINER_ALERT, scrollContainerAlertInitializer);
			
			
			
			
			// ---------- N E W
			
			// simple scroll bar
			this.getStyleProviderForClass(SimpleScrollBar).defaultStyleFunction = this.setSimpleScrollBarStyles;
			this.getStyleProviderForClass(Button).setFunctionForStyleName(THEME_STYLE_NAME_VERTICAL_SIMPLE_SCROLL_BAR_THUMB, this.setVerticalSimpleScrollBarThumbStyles);
			this.getStyleProviderForClass(Button).setFunctionForStyleName(THEME_STYLE_NAME_HORIZONTAL_SIMPLE_SCROLL_BAR_THUMB, this.setHorizontalSimpleScrollBarThumbStyles);
			
			//scroll text
			this.getStyleProviderForClass(ScrollText).defaultStyleFunction = this.setScrollTextStyles;
			
			// list
			this.getStyleProviderForClass(List).defaultStyleFunction = this.setListStyles;
			
			//page indicator
			this.getStyleProviderForClass(PageIndicator).defaultStyleFunction = this.setPageIndicatorStyles;
			
			// scroll container
			this.getStyleProviderForClass(ScrollContainer).defaultStyleFunction = this.setScrollContainerStyles;
			this.getStyleProviderForClass(ScrollContainer).setFunctionForStyleName(SCROLL_CONTAINER_RESULT_LIGHT_CORNER_BOTTOM_RIGHT, scrollContainerResultCornerBottomRightInitializer);
			this.getStyleProviderForClass(ScrollContainer).setFunctionForStyleName(SCROLL_CONTAINER_RESULT_LIGHT_CORNER_BOTTOM_LEFT, scrollContainerResultCornerBottomLeftInitializer);
			
			//callout
			this.getStyleProviderForClass(Callout).defaultStyleFunction = this.setCalloutStyles;
			
			// TextInput
			this.getStyleProviderForClass(TextInput).defaultStyleFunction = this.setTextInputStyles;
			this.getStyleProviderForClass(TextInput).setFunctionForStyleName(TEXTINPUT_FIRST, setTextInputFirstStyles);
			this.getStyleProviderForClass(TextInput).setFunctionForStyleName(TEXTINPUT_LAST, setTextInputMiddleStyles);
			this.getStyleProviderForClass(TextInput).setFunctionForStyleName(TEXTINPUT_MIDDLE, setTextInputLastStyles);
			
			// Radio
			this.getStyleProviderForClass(Radio).defaultStyleFunction = setRadioStyles;
			
			// ToggleSwitch
			this.getStyleProviderForClass(ToggleSwitch).defaultStyleFunction = this.setToggleSwitchStyles;
			this.getStyleProviderForClass(Button).setFunctionForStyleName(ToggleSwitch.DEFAULT_CHILD_STYLE_NAME_THUMB, this.setSimpleButtonStyles);
			this.getStyleProviderForClass(ToggleButton).setFunctionForStyleName(ToggleSwitch.DEFAULT_CHILD_STYLE_NAME_THUMB, this.setSimpleButtonStyles);
			this.getStyleProviderForClass(Button).setFunctionForStyleName(ToggleSwitch.DEFAULT_CHILD_STYLE_NAME_ON_TRACK, this.setToggleSwitchTrackStyles);
			this.getStyleProviderForClass(TextBlockTextRenderer).setFunctionForStyleName(ToggleSwitch.DEFAULT_CHILD_STYLE_NAME_OFF_LABEL, this.setToggleSwitchOffLabelStyles);
			this.getStyleProviderForClass(TextBlockTextRenderer).setFunctionForStyleName(ToggleSwitch.DEFAULT_CHILD_STYLE_NAME_ON_LABEL, this.setToggleSwitchOnLabelStyles);
		}
		
		
		
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
		
		protected function imageLoaderFactory():ImageLoader
		{
			const image:ImageLoader = new ImageLoader();
			image.textureScale = this.scaleFactor;
			return image;
		}
		
//------------------------------------------------------------------------------------------------------------
//
//										S C R E E N
//
//------------------------------------------------------------------------------------------------------------
		
		protected function screenInitializer(screen:Screen):void
		{
			//screen.originalDPI = this._originalDPI;
		}
		
//------------------------------------------------------------------------------------------------------------
//
//												T O G G L E  S W I T C H
//
//------------------------------------------------------------------------------------------------------------
		
		public static const BUTTON_TOGGLE_SWITCH_THUMB:String = "button-toggle_switch_thumb";
		
		//protected var onThumbTextFormat:TextFormat;
		//protected var offThumbTextFormat:TextFormat;
		
		protected function toggleSwitchInitializer(toggle:ToggleSwitch):void
		{
			toggle.trackLayoutMode = ToggleSwitch.TRACK_LAYOUT_MODE_SINGLE;
			//toggle.customThumbName = BUTTON_TOGGLE_SWITCH_THUMB;
			toggle.thumbFactory = thumbFactory;
		}
		
		protected function thumbFactory():Button
		{
			return new ToggleButton();
		}
		
		/**
		 * Button used as a background for a ToggleSwitch component?
		 */		
		protected function toggleSwitchTrackInitializer(track:Button):void
		{
			//track.defaultSkin = new Scale9Image(toggleSwitchBackgroundSkinTextures, scaleFactor);
			track.minHeight = track.height = track.minTouchHeight = 44 * scaleFactor;
			track.minWidth = track.width = track.minTouchWidth = 60 * scaleFactor;
		}
		
		/**
		 * Button used as a thumb in a ToggleSwitch component.
		 */		
		/*protected function buttonToggleSwitchInitializer(button:Button):void
		{
			button.downSkin = new Scale9Image(toggleSwitchThumbBackgroundSkinTextures, scaleFactor);
			button.downLabelProperties.textFormat = onThumbTextFormat;
			
			button.defaultSkin = new Scale9Image(toggleSwitchThumbDisabledBackgroundSkinTextures, scaleFactor);
			button.defaultLabelProperties.textFormat = offThumbTextFormat;
			
			button.minHeight = button.height = button.minTouchHeight = 44 * scaleFactor;
			button.minWidth = button.width = button.minTouchWidth = 120 * scaleFactor;
		}*/
		
		protected function buttonToggleSwitchInitializer(button:ToggleButton):void
		{
			/*button.defaultSelectedSkin = new Scale9Image(toggleSwitchThumbBackgroundSkinTextures, scaleFactor);
			button.defaultSelectedLabelProperties.textFormat = onThumbTextFormat;
			
			button.defaultSkin = new Scale9Image(toggleSwitchThumbDisabledBackgroundSkinTextures, scaleFactor);
			button.defaultLabelProperties.textFormat = offThumbTextFormat;
			
			button.minHeight = button.height = button.minTouchHeight = 44 * scaleFactor;
			button.minWidth = button.width = button.minTouchWidth = 120 * scaleFactor;*/
		}
		
//------------------------------------------------------------------------------------------------------------
//
//												P A G E  I N D I C A T O R
//
//------------------------------------------------------------------------------------------------------------
		
		
		

		
//------------------------------------------------------------------------------------------------------------
//
//												R A D I O
//
//------------------------------------------------------------------------------------------------------------
		
		protected var radioUpIconTexture:Texture;
		protected var radioDownIconTexture:Texture;
		//protected var radioDisabledIconTexture:Texture;
		protected var radioSelectedUpIconTexture:Texture;
		protected var radioSelectedDownIconTexture:Texture;
		protected var radioSelectedDisabledIconTexture:Texture;
		protected var radioTextFormat:TextFormat;
		
		/*protected function radioInitializer(radio:Radio):void
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
		}*/
		
		protected function setRadioStyles(radio:Radio):void
		{
			var icon:ImageSkin = new ImageSkin(this.radioUpIconTexture);
			icon.selectedTexture = this.radioSelectedUpIconTexture;
			icon.setTextureForState(ButtonState.DOWN, this.radioDownIconTexture);
			//icon.setTextureForState(ButtonState.DISABLED, this.radioDisabledIconTexture);
			icon.setTextureForState(ButtonState.DOWN_AND_SELECTED, this.radioSelectedDownIconTexture);
			icon.setTextureForState(ButtonState.DISABLED_AND_SELECTED, this.radioSelectedDisabledIconTexture);
			radio.defaultIcon = icon;
			
			radio.gap = this.smallGutterSize;
		}
		
//------------------------------------------------------------------------------------------------------------
//
//												P I C K E R  L I S T
//
//------------------------------------------------------------------------------------------------------------
		
		public static const COMPONENT_NAME_PICKER_LIST_ITEM_RENDERER:String = "feathers-mobile-picker-list-item-renderer";
		protected static const DEFAULT_SCALE9_GRID:Rectangle = new Rectangle(5, 5, 22, 22);
		
		protected var pickerListButtonIconTexture:Texture;
		//protected var backgroundSkinTextures:Scale9Textures;
		
		protected var pickerListButtonTextFormat:TextFormat;
		protected var pickerListItemRendererTextFormat:TextFormat;
		protected var pickerListItemRendererSelectedTextFormat:TextFormat;
		
		protected var pickerListDebugButtonTextFormat:TextFormat;
		protected var pickerListDebugItemRendererTextFormat:TextFormat;
		protected var pickerListDebugItemRendererSelectedTextFormat:TextFormat;
		
		public static const PICKER_LIST_DEBUG:String = "picker-list-debug";
		public static const PICKER_LIST_DEBUG_ITEM_RENDERER:String = "picker-list-debug-item-renderer";
		
		/*protected function basePickerListInitializer(list:PickerList):void
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
		}*/
		
		/*protected function pickerListInitializer(list:PickerList):void
		{
			basePickerListInitializer(list);
			list.listProperties.itemRendererName = COMPONENT_NAME_PICKER_LIST_ITEM_RENDERER;
		}*/
		
		/*protected function pickerListDebugInitializer(list:PickerList):void
		{
			basePickerListInitializer(list);
			list.listProperties.itemRendererName = PICKER_LIST_DEBUG_ITEM_RENDERER;
		}*/
		
		
		/**
		 * Button used for the picker list
		 */		
		/*protected function pickerListButtonInitializer(button:Button):void
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
		}*/
		/*
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
		}*/
		/*
		protected function pickerListDebugItemRendererInitializer(renderer:BaseDefaultItemRenderer):void
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
			
			renderer.defaultLabelProperties.textFormat = pickerListDebugItemRendererTextFormat;
			renderer.downLabelProperties.textFormat = pickerListDebugItemRendererSelectedTextFormat;
			renderer.defaultSelectedLabelProperties.textFormat = pickerListDebugItemRendererSelectedTextFormat;
			
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
		}*/
			
//------------------------------------------------------------------------------------------------------------
//
//					    G A M E  M O D E  S E L E C T I O N  &  N O T I F I C A T I O N S
//
//------------------------------------------------------------------------------------------------------------
		
		/**
		 * Top left leaves. */		
		public static var topLeftLeavesTexture:Texture;
		/**
		 * Bottom left leaves. */
		public static var bottomLeftLeavesTexture:Texture;
		/**
		 * Bottom middle leaves. */
		public static var bottomMiddleLeavesTexture:Texture;
		/**
		 * Bottom right leaves. */
		public static var bottomRightLeavesTexture:Texture;
		
		/**
		 * Left chain. */
		public static var leftChainTexture:Texture;
		/**
		 * Right chain. */
		public static var rightChainTexture:Texture;
		/**
		 * Lock closed. */
		public static var lockClosed:Texture;
		/**
		 * Lock opened. */
		public static var lockOpened:Texture;
		/**
		 * Lock glow. */
		public static var lockGlow:Texture;

//------------------------------------------------------------------------------------------------------------
//
//								S C R O L L  C O N T A I N E R
//
//------------------------------------------------------------------------------------------------------------
		
//------------------------------------------------------------------------------------------------------------
//	White for the tutorial
		
		public static const SCROLL_CONTAINER_WHITE:String = "scroll-container-white";
		
		
		/**
		 * ScrollContainer with a white background (used for the tutorial).
		 */		
		protected function scrollContainerWhiteInitializer(container:ScrollContainer):void
		{
			setScrollContainerStyles(container);
			
			var skin:ImageSkin = new ImageSkin(this.textinputBackgroundSkinTextures);
			//skin.disabledTexture = this.textInputBackgroundDisabledTexture;
			//skin.setTextureForState(TextInputState.FOCUSED, this.textInputBackgroundFocusedTexture);
			skin.scale9Grid = TEXTINPUT_GRID;
			skin.width = this.wideControlSize;
			skin.height = this.controlSize;
			container.backgroundSkin = skin;
			
			container.minHeight = 60 * this.scaleFactor;
			container.padding = 5 * this.scaleFactor;
		}
		
//------------------------------------------------------------------------------------------------------------
//	With and arrow (TournamentEndScreen)
		
		/**
		 * The container used at the end of a tournament game (it is an arrow) */		
		public static const TOURNAMENT_END_ARROW_CONTAINER:String = "tournament-end-arrow-container";
		protected var tournamentEndArrowSkinTextures:Texture;
		protected static const TOURNAMENT_END_ARROW_REGION1:int = 26; // the x position westart to slice
		protected static const TOURNAMENT_END_ARROW_REGION2:int = 30; // the width after the x position
		
		/**
		 * ScrollContainer with an arrow as background (used in the TournamentEndScreen
		 * to display the number of stars need ed to reach the next podium).
		 */		
		protected function scrollContainerTournamentEndArrowInitializer(container:ScrollContainer):void
		{
			setScrollerStyles(container);
			
			var skin:ImageSkin = new ImageSkin(this.tournamentEndArrowSkinTextures);
			//skin.disabledTexture = this.textInputBackgroundDisabledTexture;
			//skin.setTextureForState(TextInputState.FOCUSED, this.textInputBackgroundFocusedTexture);
			skin.scale9Grid = new Rectangle(26, 0, 30, this.tournamentEndArrowSkinTextures.frameHeight);
			skin.width = this.wideControlSize;
			skin.height = this.controlSize;
			container.backgroundSkin = skin;
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
		protected var scrollContainerResultGreyBackgroundSkinTexture:Texture;
		
		/**
		 * ScrollContainer used for the convert container and the timer
		 * in both TournamentEndScreen and FreeGameEndScreen.
		 */		
		protected function scrollContainerResultGreyInitializer(container:ScrollContainer):void
		{
			setScrollContainerStyles(container);
			
			
			var skin:ImageSkin = new ImageSkin(this.scrollContainerResultGreyBackgroundSkinTexture);
			//skin.disabledTexture = this.textInputBackgroundDisabledTexture;
			//skin.setTextureForState(TextInputState.FOCUSED, this.textInputBackgroundFocusedTexture);
			skin.scale9Grid = SCROLL_CONTAINER_RESULT_GREY_GRID;
			skin.width = this.wideControlSize;
			skin.height = this.controlSize;
			container.backgroundSkin = skin;
			
			container.minHeight = 60 * this.scaleFactor; // same as text input
			
			const vlayout:VerticalLayout = new VerticalLayout();
			vlayout.horizontalAlign = VerticalLayout.HORIZONTAL_ALIGN_CENTER;
			vlayout.verticalAlign = VerticalLayout.VERTICAL_ALIGN_MIDDLE;
			vlayout.padding = 20 * scaleFactor;
			vlayout.gap = (GlobalConfig.isPhone ? 10 : 20) * scaleFactor;
			container.layout = vlayout;
		}
		
//------------------------------------------------------------------------------------------------------------
//	ScrollContainer used for the AlertButton in the header
		
		public static const SCROLL_CONTAINER_ALERT:String = "scroll-container-alert";
		protected var scrollContainerAlertBackgroundSkinTexture:Texture;
		
		protected function scrollContainerAlertInitializer(container:ScrollContainer):void
		{
			// FIXME besoin du layout ?
			const layout:HorizontalLayout = new HorizontalLayout();
			layout.horizontalAlign = HorizontalLayout.HORIZONTAL_ALIGN_CENTER;
			layout.verticalAlign = HorizontalLayout.VERTICAL_ALIGN_MIDDLE;
			
			container.layout = layout;
			
			var skin:ImageSkin = new ImageSkin(this.scrollContainerAlertBackgroundSkinTexture);
			//skin.disabledTexture = this.textInputBackgroundDisabledTexture;
			//skin.setTextureForState(TextInputState.FOCUSED, this.textInputBackgroundFocusedTexture);
			skin.scale9Grid = new Rectangle(10, 10, 10, 10);
			skin.width = this.wideControlSize;
			skin.height = this.controlSize;
			container.backgroundSkin = skin;
			
			
			
			
			
			container.minHeight = container.minWidth = 30 * this.scaleFactor; // same as text input
			container.horizontalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			container.verticalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			container.paddingTop = container.paddingBottom = 0;
			container.paddingLeft = container.paddingRight = 2 * this.scaleFactor;
		}
		
		

		
//------------------------------------------------------------------------------------------------------------
//
//								M E N U  I T E M  R E N D E R E R
		
		public static var baseLabelTextFormat:TextFormat;                       // Base label
		public static var accountIRTextFormat:TextFormat;                       // Account IR
		public static var accountIRLabelTextFormat:TextFormat;                  // Account IR
		public static var faqIRTextFormat:TextFormat;                           // FAQ IR
		public static var boutiqueCategoryIRTitleTextFormat:TextFormat;         // Boutique category message IR
		public static var giftIRTitleTextFormat:TextFormat;                     // Gift history IR
		public static var historyIRTitleTextFormat:TextFormat;                  // History header IR
		public static var paymentIRTitleTextFormat:TextFormat;                  // Payment history IR
		public static var newsIRTitleTextFormat:TextFormat;                     // news IR
		public static var newsIRMessageTextFormat:TextFormat;                   // news IR
		public static var settingsIRTextFormat:TextFormat;                      // settings IR
		public static var notLoggedInMessageTextFormat:TextFormat;              // not logged in container
		public static var notLoggedInButtonTextFormat:TextFormat;               // not logged in container
		public static var filleulRewardIRTextFormat:TextFormat;                 // filleul reward IR
		public static var rankHeaderIRTextFormat:TextFormat;                    // rank header IR
		public static var retryContainerLightTextFormat:TextFormat;             // retry container
		public static var retryContainerDarkTextFormat:TextFormat;              // retry container
		public static var accoutHistoryIRTitleTextFormat:TextFormat;            // Account history item renderer
		public static var infoManagerOverlay:Texture;                           // Info manager
		public static var freeGameEndScreenContainerTitleTextFormat:TextFormat; // Solo end screen
		public static var highScoreListHeaderTextFormat:TextFormat;             // High score list header
		public static var labelMessageHighscorePodiumTextFormat:TextFormat;     // Game top podium
		public static var labelPodiumTopTextFormat:TextFormat;                  // Game top podium
		public static var downArrowLists:Texture;                               // Arrows and shadow for the lists
		public static var downArrowShadow:Texture;                              // Arrows and shadow for the lists
		public static var inGameSuccessTextFormat:TextFormat;                   // In game
		public static var inGameFailTextFormat:TextFormat;                      // In game
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		// ------- N E W
		
		
		
		protected static function scrollBarFactory():SimpleScrollBar
		{
			return new SimpleScrollBar();
		}
		
		
		
	//-------------------------
	// List
	//-------------------------
		
		protected function setListStyles(list:List):void
		{
			this.setScrollerStyles(list);
			//list.backgroundSkin = new Quad(10, 10, COLOR_BACKGROUND_LIGHT); // TODO A remettre si besoin
		}
		
		
	//-------------------------
	// Shared
	//-------------------------
		
		protected function setScrollerStyles(scroller:Scroller):void
		{
			scroller.verticalScrollBarFactory = scrollBarFactory;
			scroller.horizontalScrollBarFactory = scrollBarFactory;
		}
		
		
		
	//-------------------------
	// SimpleScrollBar
	//-------------------------
		
		protected static const THEME_STYLE_NAME_VERTICAL_SIMPLE_SCROLL_BAR_THUMB:String = "topcoat-light-mobile-vertical-simple-scroll-bar-thumb";
		protected static const THEME_STYLE_NAME_HORIZONTAL_SIMPLE_SCROLL_BAR_THUMB:String = "topcoat-light-mobile-horizontal-simple-scroll-bar-thumb";
		
		protected var verticalSimpleScrollBarThumbTexture:Texture;
		protected var horizontalSimpleScrollBarThumbTexture:Texture;
		
		protected static const HORIZONTAL_SIMPLE_SCROLL_BAR_SCALE9_GRID:Rectangle = new Rectangle(5, 0, 3, 6);
		protected static const VERTICAL_SIMPLE_SCROLL_BAR_SCALE9_GRID:Rectangle = new Rectangle(0, 5, 6, 3);
		
		protected function setSimpleScrollBarStyles(scrollBar:SimpleScrollBar):void
		{
			if(scrollBar.direction === Direction.HORIZONTAL)
			{
				scrollBar.customThumbStyleName = THEME_STYLE_NAME_HORIZONTAL_SIMPLE_SCROLL_BAR_THUMB;
			}
			else //vertical
			{
				scrollBar.customThumbStyleName = THEME_STYLE_NAME_VERTICAL_SIMPLE_SCROLL_BAR_THUMB;
			}
			scrollBar.paddingTop = this.extraSmallGutterSize;
			scrollBar.paddingRight = this.extraSmallGutterSize;
			scrollBar.paddingBottom = this.extraSmallGutterSize;
		}
		
		protected function setHorizontalSimpleScrollBarThumbStyles(thumb:Button):void
		{
			var defaultSkin:Image = new Image(this.horizontalSimpleScrollBarThumbTexture);
			defaultSkin.scale9Grid = HORIZONTAL_SIMPLE_SCROLL_BAR_SCALE9_GRID;
			thumb.defaultSkin = defaultSkin;
			
			thumb.hasLabelTextRenderer = false;
		}
		
		protected function setVerticalSimpleScrollBarThumbStyles(thumb:Button):void
		{
			var defaultSkin:Image = new Image(this.verticalSimpleScrollBarThumbTexture);
			defaultSkin.scale9Grid = VERTICAL_SIMPLE_SCROLL_BAR_SCALE9_GRID;
			thumb.defaultSkin = defaultSkin;
			
			thumb.hasLabelTextRenderer = false;
		}
		
	//-------------------------
	// PageIndicator
	//-------------------------
		
		protected var pageIndicatorNormalTexture:Texture;
		protected var pageIndicatorSelectedTexture:Texture;
		
		protected function setPageIndicatorStyles(pageIndicator:PageIndicator):void
		{
			pageIndicator.normalSymbolFactory = pageIndicatorNormalSymbolFactory;
			pageIndicator.selectedSymbolFactory = pageIndicatorSelectedSymbolFactory;
			pageIndicator.gap = this.gutterSize;
			pageIndicator.padding = this.gutterSize;
			pageIndicator.minTouchWidth = this.controlSize;
			pageIndicator.minTouchHeight = this.controlSize;
			
			
			// ancien initialiseur
			/*pageIndicator.gap = 10 * this.scaleFactor;
			pageIndicator.paddingTop = pageIndicator.paddingRight = pageIndicator.paddingBottom =
					pageIndicator.paddingLeft = 6 * this.scaleFactor;
			pageIndicator.minTouchWidth = pageIndicator.minTouchHeight = 44 * this.scaleFactor;*/
		}
		
		protected function pageIndicatorNormalSymbolFactory():DisplayObject
		{
			var symbol:ImageLoader = new ImageLoader();
			symbol.source = this.pageIndicatorNormalTexture;
			//symbol.textureScale = this.scaleFactor; // TODO A remettre ?
			return symbol;
		}
		
		protected function pageIndicatorSelectedSymbolFactory():DisplayObject
		{
			var symbol:ImageLoader = new ImageLoader();
			symbol.source = this.pageIndicatorSelectedTexture;
			//symbol.textureScale = this.scaleFactor; // TODO A remettre ?
			return symbol;
		}
		
	//-------------------------
	// Callout
	//-------------------------
		
		protected var calloutSkinTexture:Texture;
		protected var calloutTopArrowTexture:Texture;
		protected var calloutRightArrowTexture:Texture;
		protected var calloutBottomArrowTexture:Texture;
		protected var calloutLeftArrowTexture:Texture;
		protected static const DEFAULT_CALLOUT_GRID:Rectangle = new Rectangle(40, 40, 20, 20);
		
		protected function setCalloutStyles(callout:Callout):void
		{
			var backgroundSkin:Image = new Image(this.calloutSkinTexture);
			backgroundSkin.scale9Grid = DEFAULT_CALLOUT_GRID;
			backgroundSkin.width = this.calloutBackgroundMinSize;
			backgroundSkin.height = this.calloutBackgroundMinSize;
			callout.backgroundSkin = backgroundSkin;
			
			var topArrowSkin:Image = new Image(this.calloutTopArrowTexture);
			callout.topArrowSkin = topArrowSkin;
			callout.topArrowGap = this.calloutVerticalArrowGap;
			
			var rightArrowSkin:Image = new Image(this.calloutRightArrowTexture);
			callout.rightArrowSkin = rightArrowSkin;
			callout.rightArrowGap = this.calloutHorizontalArrowGap;
			
			var bottomArrowSkin:Image = new Image(this.calloutBottomArrowTexture);
			callout.bottomArrowSkin = bottomArrowSkin;
			callout.bottomArrowGap = this.calloutVerticalArrowGap;
			
			var leftArrowSkin:Image = new Image(this.calloutLeftArrowTexture);
			callout.leftArrowSkin = leftArrowSkin;
			callout.leftArrowGap = this.calloutHorizontalArrowGap;
			
			callout.padding = this.gutterSize;
			
			// ancien initiliseur
			/*allout.backgroundSkin = backgroundSkin;
			
			const topArrowSkin:Image = new Image(this.calloutTopArrowTexture);
			topArrowSkin.scaleX = topArrowSkin.scaleY = this.scaleFactor;
			callout.topArrowSkin = topArrowSkin;
			
			const rightArrowSkin:Image = new Image(this.calloutRightArrowTexture);
			rightArrowSkin.scaleX = rightArrowSkin.scaleY = this.scaleFactor;
			callout.rightArrowSkin = rightArrowSkin;
			
			const bottomArrowSkin:Image = new Image(this.calloutBottomArrowTexture);
			bottomArrowSkin.scaleX = bottomArrowSkin.scaleY = this.scaleFactor;
			callout.bottomArrowSkin = bottomArrowSkin;
			
			const leftArrowSkin:Image = new Image(this.calloutLeftArrowTexture);
			leftArrowSkin.scaleX = leftArrowSkin.scaleY = this.scaleFactor;
			callout.leftArrowSkin = leftArrowSkin;
			
			callout.padding = 40 * this.scaleFactor;
			callout.bottomArrowGap = -20 * this.scaleFactor;
			callout.topArrowGap = -20 * this.scaleFactor;*/
		}
		
	//-------------------------
	// GroupedList
	//-------------------------
		
		protected function setGroupedListStyles(list:GroupedList):void
		{
			this.setScrollerStyles(list);
			//list.backgroundSkin = new Quad(10, 10, COLOR_BACKGROUND_LIGHT);
			//list.customFirstItemRendererStyleName = THEME_STYLE_NAME_GROUPED_LIST_FIRST_ITEM_RENDERER;
		}
		
	//-------------------------
	// TextInput
	//-------------------------
		
		protected function setBaseTextInputStyles(input:TextInput):void
		{
			// ancien code
			/*const backgroundSkin:Scale9Image = new Scale9Image(backgroundSkinTextures, scaleFactor);
			backgroundSkin.width = 264 * scaleFactor;
			backgroundSkin.height = (GlobalConfig.isPhone ? 70 : 80) * scaleFactor;
			input.backgroundSkin = backgroundSkin;
			
			input.minWidth = input.minHeight = (GlobalConfig.isPhone ? 70 : 80) * scaleFactor;
			input.minTouchWidth = input.minTouchHeight = 108 * scaleFactor;
			input.paddingTop = 16 * scaleFactor;
			input.paddingBottom = 10 * scaleFactor;
			input.paddingLeft = input.paddingRight = 14 * scaleFactor;
			input.textEditorProperties.fontFamily = "Helvetica";
			input.textEditorProperties.fontSize = 32 * this.scaleFactor;
			input.textEditorProperties.color = COLOR_LIGHT_GREY;
			
			input.promptProperties.textFormat = textInputPromptTextFormat;*/
			
			input.minWidth = this.wideControlSize;
			input.minHeight = this.controlSize;
			input.paddingTop = this.smallGutterSize;
			input.paddingRight = this.gutterSize;
			input.paddingBottom = this.smallGutterSize;
			input.paddingLeft = this.gutterSize;
			input.gap = this.smallGutterSize;
		}
		
		protected function setTextInputStyles(input:TextInput):void
		{
			var skin:ImageSkin = new ImageSkin(this.textinputBackgroundSkinTextures);
			//skin.disabledTexture = this.textInputBackgroundDisabledTexture;
			//skin.setTextureForState(TextInputState.FOCUSED, this.textInputBackgroundFocusedTexture);
			skin.scale9Grid = TEXTINPUT_GRID;
			skin.width = this.wideControlSize;
			skin.height = this.controlSize;
			input.backgroundSkin = skin;
			
			this.setBaseTextInputStyles(input);
		}
		
		/**
		 * TextInput with rounded corners on the top */
		public static const TEXTINPUT_FIRST:String = "textinput-first";
		protected static const TEXTINPUT_FIRST_GRID:Rectangle = new Rectangle(15, 16, 2, 11);
		protected var textinputFirstBackgroundTexture:Texture;
		
		protected function setTextInputFirstStyles(input:TextInput):void
		{
			var skin:ImageSkin = new ImageSkin(this.textinputFirstBackgroundTexture);
			//skin.disabledTexture = this.textInputBackgroundDisabledTexture;
			//skin.setTextureForState(TextInputState.FOCUSED, this.textInputBackgroundFocusedTexture);
			skin.scale9Grid = TEXTINPUT_FIRST_GRID;
			skin.width = this.wideControlSize;
			skin.height = this.controlSize;
			input.backgroundSkin = skin;
			
			this.setBaseTextInputStyles(input);
		}
		
		/**
		 * TextInput with rounded corners on the bottom */
		public static const TEXTINPUT_LAST:String = "textinput-last";
		protected static const TEXTINPUT_LAST_GRID:Rectangle = new Rectangle(15, 5, 2, 11);
		protected var textinputLastBackgroundTexture:Texture;
		
		protected function setTextInputMiddleStyles(input:TextInput):void
		{
			var skin:ImageSkin = new ImageSkin(this.textinputMiddleBackgroundTexture);
			//skin.disabledTexture = this.textInputBackgroundDisabledTexture;
			//skin.setTextureForState(TextInputState.FOCUSED, this.textInputBackgroundFocusedTexture);
			skin.scale9Grid = TEXTINPUT_LAST_GRID;
			skin.width = this.wideControlSize;
			skin.height = this.controlSize;
			input.backgroundSkin = skin;
			
			this.setBaseTextInputStyles(input);
		}
		
		/**
		 * TextInput with no corners */
		public static const TEXTINPUT_MIDDLE:String = "textinput-middle";
		protected static const TEXTINPUT_MIDDLE_GRID:Rectangle = new Rectangle(4, 4, 24, 24);
		protected var textinputMiddleBackgroundTexture:Texture;
		
		protected function setTextInputLastStyles(input:TextInput):void
		{
			var skin:ImageSkin = new ImageSkin(this.textinputBackgroundSkinTextures);
			//skin.disabledTexture = this.textInputBackgroundDisabledTexture;
			//skin.setTextureForState(TextInputState.FOCUSED, this.textInputBackgroundFocusedTexture);
			skin.scale9Grid = TEXTINPUT_MIDDLE_GRID;
			skin.width = this.wideControlSize;
			skin.height = this.controlSize;
			input.backgroundSkin = skin;
			
			this.setBaseTextInputStyles(input);
		}
		
		/*protected function setTextInputPromptStyles(textRenderer:TextBlockTextRenderer):void
		{
			textRenderer.elementFormat = this.darkUIElementFormat;
			textRenderer.disabledElementFormat = this.darkUIDisabledElementFormat;
		}*/
		
		protected var textInputPromptTextFormat:TextFormat;
		protected var textInputTextFormat:TextFormat;
		protected static const TEXTINPUT_GRID:Rectangle = new Rectangle(15, 15, 2, 2);
		protected var textinputBackgroundSkinTextures:Texture;
		
	//-------------------------
	// ScrollContainer
	//-------------------------
		
		protected function setScrollContainerStyles(container:ScrollContainer):void
		{
			this.setScrollerStyles(container);
		}
		
		//	White container with the bottom right corner squared
		
		protected static const SCROLL_CONTAINER_RESULT_GRID:Rectangle = new Rectangle(21, 20, 2, 2);
		
		/**
		 * Scroll container used at the end of a game session */
		public static const SCROLL_CONTAINER_RESULT_LIGHT_CORNER_BOTTOM_RIGHT:String = "scroll-container-result-light-corner-bottom-right";
		protected var scrollContainerResultLightCornerBottomRightBackgroundSkinTexture:Texture;
		
		/**
		 * Scroll container de fin de partie (affichant les résultats)
		 */
		protected function scrollContainerResultCornerBottomRightInitializer(container:ScrollContainer):void
		{
			setScrollContainerStyles(container);
			
			
			var skin:ImageSkin = new ImageSkin(this.scrollContainerResultLightCornerBottomRightBackgroundSkinTexture);
			//skin.disabledTexture = this.textInputBackgroundDisabledTexture;
			//skin.setTextureForState(TextInputState.FOCUSED, this.textInputBackgroundFocusedTexture);
			skin.scale9Grid = SCROLL_CONTAINER_RESULT_GRID;
			skin.width = this.wideControlSize;
			skin.height = this.controlSize;
			container.backgroundSkin = skin;
			
			// ancien code
			//container.backgroundSkin = new Scale9Image(this.scrollContainerResultLightCornerBottomRightBackgroundSkinTextures, this.scaleFactor);
			//container.minHeight = 60 * this.scaleFactor; // same as text input
			//container.padding = 10 * this.scaleFactor;
			
			const vlayout:VerticalLayout = new VerticalLayout();
			vlayout.horizontalAlign = VerticalLayout.HORIZONTAL_ALIGN_CENTER;
			vlayout.verticalAlign = VerticalLayout.VERTICAL_ALIGN_MIDDLE;
			vlayout.padding = (GlobalConfig.isPhone ? 30 : 30) * scaleFactor;
			vlayout.gap = (GlobalConfig.isPhone ? 10 : 20) * scaleFactor;
			container.layout = vlayout;
		}
		
		//	White container with the bottom left corner squared
		
		/**
		 * Scroll container used at the end of a game session */
		public static const SCROLL_CONTAINER_RESULT_LIGHT_CORNER_BOTTOM_LEFT:String = "scroll-container-result-light-corner-bottom-left";
		protected var scrollContainerResultLightCornerBottomLeftBackgroundSkinTexture:Texture;
		
		/**
		 * Scroll container de fin de partie (affichant les résultats)
		 */
		protected function scrollContainerResultCornerBottomLeftInitializer(container:ScrollContainer):void
		{
			setScrollContainerStyles(container);
			
			var skin:ImageSkin = new ImageSkin(this.scrollContainerResultLightCornerBottomLeftBackgroundSkinTexture);
			//skin.disabledTexture = this.textInputBackgroundDisabledTexture;
			//skin.setTextureForState(TextInputState.FOCUSED, this.textInputBackgroundFocusedTexture);
			skin.scale9Grid = SCROLL_CONTAINER_RESULT_GRID;
			skin.width = this.wideControlSize;
			skin.height = this.controlSize;
			container.backgroundSkin = skin;
			
			// old
			//container.backgroundSkin = new  Image(this.scrollContainerResultLightCornerBottomLeftBackgroundSkinTextures);
			//container.minHeight = 60 * this.scaleFactor; // same as text input
			//container.padding = 10 * this.scaleFactor;
			
			const vlayout:VerticalLayout = new VerticalLayout();
			vlayout.horizontalAlign = VerticalLayout.HORIZONTAL_ALIGN_CENTER;
			vlayout.verticalAlign = VerticalLayout.VERTICAL_ALIGN_MIDDLE;
			vlayout.padding = 30 * scaleFactor;
			vlayout.gap = (GlobalConfig.isPhone ? 10 : 20) * scaleFactor;
			container.layout = vlayout;
		}
		
		
	//-------------------------
	// ScrollText
	//-------------------------
		
		protected function setScrollTextStyles(text:ScrollText):void
		{
			this.setScrollerStyles(text);
			
			//text.textFormat = this.scrollTextTextFormat;
			//text.disabledTextFormat = this.scrollTextDisabledTextFormat;
			text.padding = this.gutterSize;
			text.paddingRight = this.gutterSize + this.smallGutterSize;
		}
		
	//-------------------------
	// Button
	//-------------------------
		
		public static var facebookButtonSkinTextures:Texture;
		public static var buttonBlueSkinTextures:Texture;
		public static var buttonRedSkinTextures:Texture;
		public static var buttonGreenSkinTextures:Texture;
		public static var buttonWhiteSkinTextures:Texture;
		public static var buttonYellowSkinTextures:Texture;
		public static var buttonSpecialSkinTextures:Texture;
		
		//	Yellow (common style)
		
		/**
		 * Common element format. */
		protected var buttonTextFormat:TextFormat;
		protected static const BUTTON_GRID:Rectangle = new Rectangle(32, 32, 24, 24);
		/**
		 * Disabled / Grey button */
		public static var buttonDisabledSkinTextures:Texture;
		
		
		//------------------------------------------------------------------------------------------------------------
		//	Transparent normal, white and blue (lighter and darker)
		
		public static const BUTTON_EMPTY:String = "button-empty";
		/**
		 * Transparent button used for the rules in the home screen */
		public static const BUTTON_TRANSPARENT_BLUE_DARKER:String = "button-transparent-blue-darker";
		protected var buttonTransparentBlueDarkerUpSkinTexture:Texture;
		protected var buttonTransparentBlueDarkerTextFormat:TextFormat;
		
		/**
		 * Use this button when we want to display a single icon and when we want
		 * to enhance the access.
		 */
		protected function buttonEmptyInitializer(button:Button):void
		{
			//button.scaleWhenDown = true;
			//button.scaleWhenDownValue = 0.9;
			//button.minWidth = 112 * this.scale;
			button.minHeight = 120 * this.scaleFactor;
			button.minTouchWidth = 130 * this.scaleFactor;
			button.minTouchHeight = 120 * this.scaleFactor;
		}
		
	//-------------------------
	// ToggleSwitch
	//-------------------------
		
		protected static const TOGGLE_SWITCH_BACKGROUND_GRID:Rectangle = new Rectangle(21, 25, 2, 4);
		protected var toggleSwitchBackgroundSkinTextures:Texture;
		protected var toggleSwitchThumbBackgroundSkinTextures:Texture;
		protected var toggleSwitchThumbDisabledBackgroundSkinTextures:Texture;
		
		//onThumbTextFormat  = ;
		//offThumbTextFormat = new TextFormat(FONT_ARIAL, scaleAndRoundToDpi(24), COLOR_VERY_LIGHT_GREY, true, true);
		
		protected function setToggleSwitchStyles(toggle:ToggleSwitch):void
		{
			toggle.trackLayoutMode = TrackLayoutMode.SINGLE;
		}
		
		//see Shared section for thumb styles
		
		protected function setToggleSwitchTrackStyles(track:Button):void
		{
			var skin:ImageSkin = new ImageSkin(this.toggleSwitchBackgroundSkinTextures);
			//skin.disabledTexture = this.toggleSwitchThumbDisabledBackgroundSkinTextures;
			skin.scale9Grid = TOGGLE_SWITCH_BACKGROUND_GRID;
			skin.width = Math.round(this.controlSize * 2.5);
			skin.height = this.controlSize;
			track.defaultSkin = skin;
			track.hasLabelTextRenderer = false;
		}
		
		protected function setToggleSwitchOffLabelStyles(textRenderer:TextBlockTextRenderer):void
		{
			var fd:FontDescription = new FontDescription(FONT_ARIAL);
			textRenderer.elementFormat = new ElementFormat(fd, scaleAndRoundToDpi(24), COLOR_VERY_LIGHT_GREY)//this.lightUIElementFormat;
			textRenderer.disabledElementFormat = new ElementFormat(fd, scaleAndRoundToDpi(24), COLOR_VERY_LIGHT_GREY)//this.lightUIDisabledElementFormat;
		}
		
		protected function setToggleSwitchOnLabelStyles(textRenderer:TextBlockTextRenderer):void
		{
			var fd:FontDescription = new FontDescription(FONT_ARIAL);
			textRenderer.elementFormat = new ElementFormat(fd, scaleAndRoundToDpi(24), COLOR_WHITE)//this.selectedUIElementFormat;
			textRenderer.disabledElementFormat = new ElementFormat(fd, scaleAndRoundToDpi(24), COLOR_WHITE)//this.lightUIDisabledElementFormat;
		}
		
		protected function setSimpleButtonStyles(button:Button):void
		{
			var skin:ImageSkin = new ImageSkin(this.toggleSwitchThumbBackgroundSkinTextures);
			//skin.setTextureForState(ButtonState.DOWN, this.buttonDownSkinTexture);
			skin.setTextureForState(ButtonState.DISABLED, this.toggleSwitchThumbDisabledBackgroundSkinTextures);
			skin.scale9Grid = TOGGLE_SWITCH_BACKGROUND_GRID;
			skin.width = this.controlSize;
			skin.height = this.controlSize;
			button.defaultSkin = skin;
			
			button.hasLabelTextRenderer = false;
			
			button.minWidth = button.minHeight = this.controlSize;
			button.minTouchWidth = button.minTouchHeight = this.gridSize;
		}
		
		
		
	}
}