/*
Copyright © 2006-2014 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 3 sept. 2013
*/
package com.ludofactory.mobile.core.test.vip
{
	import com.freshplanet.nativeExtensions.AirNetworkInfo;
	import com.greensock.TweenMax;
	import com.greensock.easing.Linear;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.Localizer;
	import com.ludofactory.mobile.core.authentication.MemberManager;
	import com.ludofactory.mobile.core.controls.AbstractAccordionItem;
	import com.ludofactory.mobile.core.controls.Accordion;
	import com.ludofactory.mobile.core.controls.AdvancedScreen;
	import com.ludofactory.mobile.core.controls.ArrowGroup;
	import com.ludofactory.mobile.core.controls.ScreenIds;
	import com.ludofactory.mobile.core.manager.InfoContent;
	import com.ludofactory.mobile.core.manager.InfoManager;
	import com.ludofactory.mobile.core.remoting.Remote;
	import com.ludofactory.mobile.core.storage.Storage;
	import com.ludofactory.mobile.core.storage.StorageConfig;
	import com.ludofactory.mobile.core.test.config.GlobalConfig;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import flash.geom.Point;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import feathers.controls.Label;
	
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.display.MovieClip;
	import starling.display.Quad;
	import starling.display.QuadBatch;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.textures.Texture;
	import starling.utils.deg2rad;
	import starling.utils.formatString;
	
	public class VipScreen extends AdvancedScreen
	{
		/**
		 *   */		
		public static const INVALIDATION_FLAG_RANK:String = "rank";
		public static const INVALIDATION_FLAG_REDRAW:String = "redraw";
		
		private const RANK_IMAGES_NAME:Array = [ "Rank-1", "Rank-2", "Rank-3", "Rank-4", "Rank-5", "Rank-6",
												 "Rank-7", "Rank-8", "Rank-9", "Rank-10", "Rank-11", "Rank-12"];
		/**
		 * The loader. */		
		private var _loader:MovieClip;
		
		/**
		 * The rank title label. */		
		private var _rankTitleLabel:Label;
		/**
		 * The access condition label. */		
		private var _conditionLabel:Label;
		/**
		 * The reload buton for when the user comes from
		 * the store. */		
		private var _reloadButton:ArrowGroup;
		
		private var _resendMailButton:ArrowGroup;
		
		/**
		 * The list shadow */		
		private var _topShadow:Quad;
		
		/**
		 * All the rank icons. */		
		private var _rankImages:Vector.<Image>;
		private var _cachedRankImage:Image;
		
		/**
		 * All the glows. */		
		private var _glows:Vector.<Image>;
		private var _cachedGlow:Image;
		
		/**
		 * The array of ranks data. */		
		private var _ranksData:Array;
		
		/**
		 * The number of ranks. */		
		private var _numRanks:Number;
		/**
		 * The common icon width. */		
		private var _iconWidth:Number;
		/**
		 * The common icon height. */		
		private var _iconHeight:Number;
		
		private var _quadBatch:QuadBatch;
		
		/**
		 * The current index. */		
		private var _currentIndex:Number = 0;
		
		private var _isDragging:Boolean = false;
		
		private var _targetIndex:int;
		
		/**
		 * The is the current index when the user started to drag */		
		private var _startDragIndex:Number = 0;
		/**
		 * It is the current position of the mouse based on the
		 * center of the screen. -1 on the left side, 0 in the
		 * center and 1 on the right side. */		
		private var _dragXLocationFromCenter:Number = 0;
		/**
		 * It is the start position of the mouse based on the
		 * center of the screen. -1 on the left side, 0 in the
		 * center and 1 on the right side. */	
		private var _beginDragXLocationFromCenter:Number = 0;
		
		/**
		 * The distance between two objects in the list. */		
		private var _itemsGap:Number;
		/**
		 * The center of the list. */		
		private var _centerX:Number;
		
		/**
		 * The target scale and alpha of items. */		
		private var _targetScaleAndAlpha:Number;
		private var _targetAlpha:Number;
		
		/**
		 * Y position of icons. */		
		private var _iconsYPosition:Number;
		
		
		private var _previousPrivilege:DisplayObject;
		private var _currentPrivilege:DisplayObject;
		
		private var _defaultRankInformationLabel:Label;
		
		/**
		 * Whether the content is initialized. */		
		private var _isContentInitialized:Boolean = false;
		
		/**
		 * The transparent background used for touch vent. */		
		private var _touchBackground:Quad;
		
		
		
		/**
		 * The white background displayed behind the privileges. */		
		private var _whiteContentBackground:Quad;
		/**
		 * The main accordion used to display the privileges. */		
		private var _accordion:Accordion;
		/**
		 * All the privileges.
		 * This is an array containing vectors of VipAccordionItems. */		
		private var _privileges:Array;
		
		
		
		public function VipScreen()
		{
			super();
			
			_whiteBackground = true;
			_fullScreen = false;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			_headerTitle = Localizer.getInstance().translate("VIP.HEADER_TITLE");
			
			_loader = new MovieClip( AbstractEntryPoint.assets.getTextures("MiniLoader") );
			_loader.scaleX = _loader.scaleY = GlobalConfig.dpiScale;
			_loader.alignPivot();
			addChild(_loader);
			Starling.juggler.add(_loader);
			
			if( AirNetworkInfo.networkInfo.isConnected() )
			{
				TweenMax.delayedCall(0.75, Remote.getInstance().getVip, [onGetVipSuccess, onGetVipFailure, onGetVipFailure, 1, advancedOwner.activeScreenID]);
			}
			else
			{
				TweenMax.delayedCall(0.75, onGetVipFailure);
			}
		}
		
		private function initializeContent():void
		{
			Starling.juggler.remove(_loader);
			_loader.removeFromParent(true);
			_loader = null;
			
			var temp:Array = JSON.parse( Storage.getInstance().getProperty( StorageConfig.PROPERTY_VIP )[Localizer.getInstance().lang] ) as Array;
			_ranksData = [];
			for(var i:int = 0; i < temp.length; i++)
				_ranksData.push( new VipData(temp[i]) );
			
			if( MemberManager.getInstance().isLoggedIn() )
			{
				if( advancedOwner.screenData.vipScreenInitializedFromStore )
				{
					_currentIndex = _targetIndex = MemberManager.getInstance().getRank() >= 12 ? 11 : MemberManager.getInstance().getRank();
				}
				else
				{
					_currentIndex = _targetIndex = (MemberManager.getInstance().getRank() - 1);
				}
			}
			else
			{
				_currentIndex = _targetIndex = 0;
			}
			
			_whiteContentBackground = new Quad(5, 5, 0xffffff);
			_whiteContentBackground.touchable = false;
			addChild(_whiteContentBackground);
			
			_quadBatch = new QuadBatch();
			addChild(_quadBatch);
			
			_touchBackground = new Quad(50, 50, 0x000000);
			_touchBackground.alpha = 0;
			_touchBackground.addEventListener(TouchEvent.TOUCH, onTouchHandler);
			addChild(_touchBackground);
			
			_rankTitleLabel = new Label();
			_rankTitleLabel.touchable = false;
			_rankTitleLabel.text = (_ranksData[ _currentIndex ] as VipData).rankName;
			addChild(_rankTitleLabel);
			_rankTitleLabel.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(GlobalConfig.isPhone ? 56 : 70), Theme.COLOR_ORANGE, false, false, null, null, null, TextFormatAlign.CENTER);
			
			_conditionLabel = new Label();
			_conditionLabel.touchable = false;
			_conditionLabel.text = (_ranksData[ _currentIndex ] as VipData).condition;
			addChild(_conditionLabel);
			_conditionLabel.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(GlobalConfig.isPhone ? 30 : 40), Theme.COLOR_DARK_GREY, false, false, null, null, null, TextFormatAlign.CENTER);
			
			if( advancedOwner.screenData.vipScreenInitializedFromStore )
			{
				// if the user is coming from the store, we need to add a reload button
				// so that he can go back to the store screen without using the back button.
				_reloadButton = new ArrowGroup(Localizer.getInstance().translate("VIP.RELOAD_BUTTON_LABEL"));
				_reloadButton.addEventListener(Event.TRIGGERED, onReload);
				addChild(_reloadButton);
			}
			
			if( MemberManager.getInstance().isLoggedIn() && _currentIndex == 0 )
			{
				_resendMailButton = new ArrowGroup(Localizer.getInstance().translate("VIP.SEND_MAIL_BUTTON_LABEL"));
				_resendMailButton.addEventListener(Event.TRIGGERED, onResendMail);
				addChild(_resendMailButton);
			}
			
			_topShadow = new Quad(50, scaleAndRoundToDpi(12), 0x000000);
			_topShadow.touchable = false;
			_topShadow.setVertexColor(0, 0xffffff);
			_topShadow.setVertexAlpha(0, 0);
			_topShadow.setVertexColor(1, 0xffffff);
			_topShadow.setVertexAlpha(1, 0);
			_topShadow.setVertexAlpha(2, 0.1);
			_topShadow.setVertexAlpha(3, 0.1);
			addChild(_topShadow);
			
			_defaultRankInformationLabel = new Label();
			_defaultRankInformationLabel.touchable = false;
			_defaultRankInformationLabel.visible = false;
			_defaultRankInformationLabel.text = VipData(_ranksData[0]).presentation;
			addChild(_defaultRankInformationLabel);
			_defaultRankInformationLabel.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(32), Theme.COLOR_DARK_GREY, false, false, null, null, null, TextFormatAlign.CENTER);
			
			_rankImages = new Vector.<Image>();
			_glows = new Vector.<Image>();
			_privileges = [];
			var accordionElements:Vector.<AbstractAccordionItem>;
			var vipData:VipData;
			var glowTexture:Texture = AbstractEntryPoint.assets.getTexture("HighScoreGlow");
			
			for(i = 0; i < _ranksData.length; i++)
			{
				// create glow and animate
				_cachedGlow = new Image( glowTexture );
				_glows.push( _cachedGlow );
				if( i == 0 )
					TweenMax.to(_cachedGlow, 10, { rotation:deg2rad(360), ease:Linear.easeNone, onUpdate:validateNow, repeat:-1 });
				else
					TweenMax.to(_cachedGlow, 10, { rotation:deg2rad(360), ease:Linear.easeNone, repeat:-1 });
					
				_rankImages.push( new Image( AbstractEntryPoint.assets.getTexture( RANK_IMAGES_NAME[i] ) ) );
				
				// current rank data
				vipData = _ranksData[i];
				
				// create accordion elements
				accordionElements = new Vector.<AbstractAccordionItem>();
				for(var j:int = 0; j < vipData.content.length; j++)
					accordionElements.push( new VipAccordionItem( vipData.content[j] ) );
				_privileges.push( accordionElements );
			}
			
			_accordion = new Accordion();
			_accordion.visible = false;
			var tmp:Vector.<AbstractAccordionItem> = new Vector.<AbstractAccordionItem>();
			for(var k:int = _privileges.length - 1; k >= 0; k--)
				tmp = tmp.concat( _privileges[k].concat() );
			_accordion.dataProvider = tmp;
			addChild(_accordion);
			
			glowTexture.dispose();
			glowTexture = null;
			
			_cachedRankImage = _rankImages[0];
			_cachedRankImage.scaleX = _cachedRankImage.scaleY = GlobalConfig.dpiScale;
			_iconWidth = _cachedRankImage.width;
			_iconHeight = _cachedRankImage.height;
			_numRanks = _rankImages.length;
			
			_isContentInitialized = true;
			
			invalidate( INVALIDATION_FLAG_SIZE );
			invalidate( INVALIDATION_FLAG_RANK );
		}
		
		override protected function draw():void
		{
			if( _loader )
			{
				_loader.x = this.actualWidth * 0.5;
				_loader.y = this.actualHeight * 0.5;
			}
			
			if( isInvalid(INVALIDATION_FLAG_SIZE) && _isContentInitialized )
			{
				_rankTitleLabel.y = scaleAndRoundToDpi(20);
				_rankTitleLabel.width = actualWidth;
				_rankTitleLabel.validate();
				
				_iconsYPosition = _rankTitleLabel.y + _rankTitleLabel.height + (_iconHeight * 0.5) + scaleAndRoundToDpi(GlobalConfig.isPhone ? 10 : 40);
				
				_conditionLabel.y = _iconsYPosition + (_iconHeight * 0.5) + scaleAndRoundToDpi(GlobalConfig.isPhone ? 10 : 40);
				_conditionLabel.width = actualWidth * 0.95;
				_conditionLabel.x = (actualWidth - _conditionLabel.width) * 0.5;
				_conditionLabel.validate();
				
				if( _reloadButton )
				{
					_reloadButton.validate();
					_reloadButton.x = (actualWidth - _reloadButton.width) * 0.5;
				}
				
				if( _resendMailButton )
				{
					_resendMailButton.validate();
					_resendMailButton.x = (actualWidth - _resendMailButton.width) * 0.5;
				}
				
				_topShadow.width = actualWidth;
				_accordion.width = _whiteContentBackground.width = actualWidth;
				
				if( _currentPrivilege && !(_currentPrivilege is Label) )
					_currentPrivilege.width = this.actualWidth;
				
				_touchBackground.width = this.actualWidth;
				_touchBackground.height = this.actualHeight;
				
				_itemsGap = this.actualWidth * (GlobalConfig.isPhone ? 0.5:0.5);
				_centerX = this.actualWidth * 0.5;
				
				_defaultRankInformationLabel.width = this.actualWidth * 0.9;
				_defaultRankInformationLabel.x = (actualWidth - _defaultRankInformationLabel.width) * 0.5;
				_defaultRankInformationLabel.validate();
				
				
				validateNow();
			}
			
			if( isInvalid( INVALIDATION_FLAG_RANK ) && _isContentInitialized )
			{
				displayRank();
			}
			
			if( isInvalid( INVALIDATION_FLAG_REDRAW ) && _isContentInitialized )
			{
				_conditionLabel.validate();
				
				_topShadow.y = _conditionLabel.y + _conditionLabel.height + scaleAndRoundToDpi(GlobalConfig.isPhone ? 10 : 40) + ((_reloadButton && _reloadButton.visible) ? _reloadButton.height : 0) + ((_resendMailButton && _resendMailButton.visible) ? _resendMailButton.height : 0);
				
				if( _resendMailButton )
					_resendMailButton.y = _conditionLabel.y + _conditionLabel.height;
				if( _reloadButton )
					_reloadButton.y = _conditionLabel.y + _conditionLabel.height;
				
				_accordion.y = _whiteContentBackground.y = _topShadow.y + _topShadow.height;
				_accordion.height = _whiteContentBackground.height = actualHeight - _accordion.y;
				
				if( _currentPrivilege && !(_currentPrivilege is Label) )
				{
					_currentPrivilege.y = _topShadow.y + _topShadow.height;
					_currentPrivilege.height = actualHeight - _currentPrivilege.y;
				}
				
				_defaultRankInformationLabel.y = _whiteContentBackground.y + (_whiteContentBackground.height * 0.5) - (_defaultRankInformationLabel.height * 0.5);
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Handlers
//------------------------------------------------------------------------------------------------------------
		
		/**
		 * The rank informations have been successfully updated.
		 */		
		private function onGetVipSuccess(result:Object):void
		{
			if( result != null && result.hasOwnProperty("tab_vip") && result.tab_vip )
				Storage.getInstance().updateVip(result);
			
			initializeContent();
		}
		
		/**
		 * We could not update the rank informations.
		 */		
		private function onGetVipFailure(error:Object = null):void
		{
			initializeContent();
		}
		
		/**
		 * The user was coming from
		 */		
		private function onReload(event:Event):void
		{
			advancedOwner.showScreen( ScreenIds.STORE_SCREEN );
		}
		
//------------------------------------------------------------------------------------------------------------
//	Motion
//------------------------------------------------------------------------------------------------------------
		
		/**
		 * The main enter frame handler.
		 */		
		private function validateNow(event:Event=null):void
		{
			_quadBatch.reset();
			
			for (var i:int = 0; i < _numRanks; i++) 
			{
				var xLocation:Number = _centerX + (i - _currentIndex) * _itemsGap - (_iconWidth * 0.5);
				if(xLocation + _iconWidth > 0 && xLocation < this.actualWidth)
				{
					_targetScaleAndAlpha = GlobalConfig.dpiScale - Math.abs( (xLocation + (_iconWidth * 0.5) - _centerX) / this.actualWidth * 0.3 ); //0.3 tel
					_targetAlpha = GlobalConfig.dpiScale - Math.abs( (xLocation + (_iconWidth * 0.5) - _centerX) / this.actualWidth);
					
					_cachedGlow = _glows[i];
					_cachedGlow.scaleX = _cachedGlow.scaleY = GlobalConfig.dpiScale;
					_cachedGlow.alignPivot();
					_cachedRankImage = _rankImages[i];
					_cachedRankImage.scaleX = _cachedRankImage.scaleY = GlobalConfig.dpiScale;
					_cachedRankImage.alignPivot();
					_cachedGlow.y = _cachedRankImage.y = _iconsYPosition;
					_cachedGlow.x = _cachedRankImage.x = xLocation + (_iconWidth * 0.5);
					_cachedRankImage.scaleX = _cachedRankImage.scaleY = /*_cachedRankImage.alpha = */_targetScaleAndAlpha;
					
					_cachedGlow.scaleX = _cachedGlow.scaleY =  _targetScaleAndAlpha;
					_cachedGlow.alpha =  _targetAlpha - 0.5;
					
					_quadBatch.addImage(_cachedGlow);
					_quadBatch.addImage(_cachedRankImage);
					
					_cachedRankImage.dispose();
					_cachedGlow.dispose();
				}
			}
		}
		
		/**
		 * On touch handler.
		 */		
		private function onTouchHandler(event:TouchEvent):void
		{
			var touch:Touch = event.getTouch(this);
			
			if( touch )
			{
				var point:Point = touch.getLocation(this);
				if(touch.phase == TouchPhase.BEGAN)
				{
					removeEventListener(Event.ENTER_FRAME, executeMotion);
					_beginDragXLocationFromCenter = (point.x - _centerX) / _centerX;
					_startDragIndex = _currentIndex;
					_isDragging = true;
				}
				else if(touch.phase == TouchPhase.MOVED)
				{
					if(_isDragging)
					{
						_dragXLocationFromCenter = (point.x - _centerX) / _centerX;
						
						_currentIndex = _startDragIndex - (_dragXLocationFromCenter - _beginDragXLocationFromCenter);
						
						if(_currentIndex < -0.5)
							_currentIndex = -0.5;
						
						if(_currentIndex > ((_numRanks - 1) + 0.5))
							_currentIndex = (_numRanks - 1) + 0.5;
						
						validateNow();
					}
				}
				else
				{
					if(_isDragging)
					{
						validateNow();
						finishTouchByMotion(point.x);
						_isDragging = false;
					}
				}
			}
		}
		
		private function finishTouchByMotion(endX:Number):void
		{
			_targetIndex = Math.round(_currentIndex);
			
			if( _targetIndex == _currentIndex)
				return;
			
			if(_dragXLocationFromCenter < 0 && _dragXLocationFromCenter < 0.5 && _targetIndex >= 0)
				_targetIndex = Math.ceil(_currentIndex);
			if(_dragXLocationFromCenter > 0 && _dragXLocationFromCenter > 0.5)
				_targetIndex = Math.floor(_currentIndex);
			
			if( _targetIndex < 0 )
				_targetIndex = 0;
			if( _targetIndex > _numRanks - 1 )
				_targetIndex = _numRanks - 1;
			
			addEventListener(Event.ENTER_FRAME, executeMotion);
			
			displayRank();
		}
		
		private function executeMotion(event:Event):void
		{
			_currentIndex += (_targetIndex - _currentIndex) * 0.25;
			validateNow();
			if(Math.abs(_currentIndex - _targetIndex) <= 0.001)
			{
				_currentIndex = _targetIndex;
				onTweenComplete();
			}
		}
		
		private function onTweenComplete():void
		{
			removeEventListener(Event.ENTER_FRAME, executeMotion);
			
			if(_currentIndex < 0)
				_currentIndex = 0;
			
			if(_currentIndex > _numRanks - 1)
				_currentIndex = _numRanks - 1;
			
			_dragXLocationFromCenter = 0;
			_beginDragXLocationFromCenter = 0;
			
			validateNow();
		}
		
		/**
		 * Updates all the informations related to the displayed
		 * rank.
		 */		
		private function displayRank():void
		{
			_previousPrivilege = _currentPrivilege;
			
			_rankTitleLabel.text = (_ranksData[ _targetIndex ] as VipData).rankName;
			
			if( _reloadButton )
				_reloadButton.visible = false;
			if( _resendMailButton )
				_resendMailButton.visible = false;
			
			if( MemberManager.getInstance().isLoggedIn() /*&& _targetIndex != 0 && _targetIndex != 1*/)
			{
				if( MemberManager.getInstance().getRank() - 1 == _targetIndex )
				{
					_conditionLabel.text = Localizer.getInstance().translate("VIP.PRIVILEGES_RANK_IS_USER_RANK");
				}
				else if( _targetIndex < MemberManager.getInstance().getRank() - 1 )
				{
					_conditionLabel.text = Localizer.getInstance().translate("VIP.PRIVILEGES_RANK_ALREADY_EARNED");
				}
				else
				{
					if( _targetIndex == 1 )
					{
						if( _resendMailButton )
							_resendMailButton.visible = true;
					}
					
					if( (_ranksData[ _targetIndex ] as VipData).accessValue == -1)
					{
						_conditionLabel.text = (_ranksData[ _targetIndex ] as VipData).condition;
					}
					else
					{
						if( (_ranksData[ _targetIndex ] as VipData).accessValue - MemberManager.getInstance().getNumCreditsBought() <= 0 )
						{
							_conditionLabel.text = formatString(VipData(_ranksData[1]).condition, ( (_ranksData[ _targetIndex ] as VipData).accessValue - MemberManager.getInstance().getNumCreditsBought() ));
						}
						else
						{
							if( _reloadButton )
								_reloadButton.visible = true;
							_conditionLabel.text = formatString(VipData(_ranksData[_targetIndex]).condition, ( (_ranksData[ _targetIndex ] as VipData).accessValue - MemberManager.getInstance().getNumCreditsBought() ));
						}
					}
				}
			}
			else
			{
				_conditionLabel.text = formatString((_ranksData[ _targetIndex ] as VipData).condition, (_ranksData[ _targetIndex ] as VipData).accessValue);
			}
			
			invalidate( INVALIDATION_FLAG_REDRAW );
			
			if( _targetIndex == 0 )
			{
				_currentPrivilege = _defaultRankInformationLabel;
				if( _previousPrivilege == _currentPrivilege)
					return;
				
				if( _previousPrivilege )
					TweenMax.to(_previousPrivilege, 0.25, { autoAlpha:0 });
				
				TweenMax.to(_currentPrivilege, 0.25, { autoAlpha:1 });
			}
			else
			{
				var indexesToSetVisible:Array = [];
				var newPrivilegesIndexes:Array = [];
				for(var i:int = _targetIndex; i >= 0; i--)
				{
					for(var j:int = 0; j < _privileges[i].length; j++)
					{
						indexesToSetVisible.push( AbstractAccordionItem(_privileges[i][j]).index );
						if( i == _targetIndex )
						{
							// = new privilège par rapport au rang précédent
							newPrivilegesIndexes.push( AbstractAccordionItem(_privileges[i][j]).index );
						}
					}
				}
				
				_accordion.testVip( indexesToSetVisible, newPrivilegesIndexes );
				
				_currentPrivilege = _accordion;
				if( _previousPrivilege == _currentPrivilege)
					return;
				
				if( _previousPrivilege )
					TweenMax.to(_previousPrivilege, 0.25, { autoAlpha:0 });
				
				TweenMax.allTo([_currentPrivilege], 0.25, { autoAlpha:1 });
				TweenMax.to(_defaultRankInformationLabel, 0.25, { autoAlpha:0 });
			}
		}
		
		override public function onBack():void
		{
			TweenMax.killAll();
			super.onBack();
		}
		
		private function onResendMail(event:Event):void
		{
			if( AirNetworkInfo.networkInfo.isConnected() )
				Remote.getInstance().resendValidationEmail(onValidationEmailSent, onValidationEmailNotSent, onValidationEmailNotSent, 1, advancedOwner.activeScreenID);
			else
				InfoManager.showTimed(Localizer.getInstance().translate("COMMON.NOT_CONNECTED"), InfoManager.DEFAULT_DISPLAY_TIME, InfoContent.ICON_CROSS);
		}
		
		private function onValidationEmailSent(result:Object):void
		{
			InfoManager.showTimed(result.txt, 2, InfoContent.ICON_CHECK);
		}
		
		private function onValidationEmailNotSent(error:Object = null):void
		{
			InfoManager.hide(Localizer.getInstance().translate("COMMON.QUERY_FAILURE"), InfoContent.ICON_CROSS, InfoManager.DEFAULT_DISPLAY_TIME);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
//------------------------------------------------------------------------------------------------------------
		
		override public function dispose():void
		{
			AbstractEntryPoint.screenNavigator.screenData.vipScreenInitializedFromStore = false;
			
			removeEventListener(Event.ENTER_FRAME, executeMotion);
			
			if( _loader )
			{
				Starling.juggler.remove(_loader);
				_loader.removeFromParent(true);
				_loader = null;
			}
			
			if( _isContentInitialized )
			{
				while(_glows.length != 0)
				{
					_cachedGlow = _glows.pop();
					TweenMax.killTweensOf(_cachedGlow);
					_cachedGlow.removeFromParent(true);
					_cachedGlow = null;
				}
				
				while(_rankImages.length != 0)
				{
					_cachedRankImage = _rankImages.pop();
					_cachedRankImage.removeFromParent(true);
					_cachedRankImage = null;
				}
				
				_accordion.removeFromParent(true);
				_accordion = null;
				
				if( _previousPrivilege )
				{
					_previousPrivilege.removeFromParent(true);
					_previousPrivilege = null;
				}
				
				_touchBackground.removeEventListener(TouchEvent.TOUCH, onTouchHandler);
				_touchBackground.removeFromParent(true);
				_touchBackground = null;
				
				_topShadow.removeFromParent(true);
				_topShadow = null;
				
				_quadBatch.reset();
				_quadBatch.removeFromParent(true);
				_quadBatch = null;
				
				_rankTitleLabel.removeFromParent(true);
				_rankTitleLabel = null;
				
				_conditionLabel.removeFromParent(true);
				_conditionLabel = null;
				
				_defaultRankInformationLabel.removeFromParent(true);
				_defaultRankInformationLabel =  null;
				
				_whiteContentBackground.removeFromParent(true);
				_whiteContentBackground = null;
				
				if( _reloadButton )
				{
					_reloadButton.removeEventListener(Event.TRIGGERED, onReload);
					_reloadButton.removeFromParent(true);
					_reloadButton = null;
				}
				
				if( _resendMailButton )
				{
					_resendMailButton.removeEventListener(Event.TRIGGERED, onResendMail);
					_resendMailButton.removeFromParent(true);
					_resendMailButton = null;
				}
			}
			
			super.dispose();
		}
		
	}
}