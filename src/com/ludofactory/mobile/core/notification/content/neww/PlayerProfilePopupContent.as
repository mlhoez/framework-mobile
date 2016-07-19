/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 1 septembre 2013
*/
package com.ludofactory.mobile.core.notification.content.neww
{
	
	import com.ludofactory.common.utils.Utilities;
	import com.ludofactory.common.utils.logs.log;
	import com.ludofactory.common.utils.roundUp;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.AbstractGameInfo;
	import com.ludofactory.mobile.core.events.MobileEventTypes;
	import com.ludofactory.mobile.core.manager.MemberManager;
	import com.ludofactory.mobile.core.notification.content.AbstractPopupContent;
	import com.ludofactory.mobile.core.theme.Theme;
	import com.ludofactory.mobileNew.core.ads.AdManager;
	import com.ludofactory.mobileNew.IconButton;
	import com.ludofactory.mobileNew.PremiumContainer;
	import com.ludofactory.mobileNew.StatsData;
	import com.ludofactory.mobileNew.StatsItemRenderer;
	import com.ludofactory.mobileNew.core.display.ValueIconContainer;
	
	import feathers.controls.List;
	import feathers.controls.Scroller;
	import feathers.data.ListCollection;
	
	import starling.display.Quad;
	import starling.events.Event;
	
	import starling.filters.BlurFilter;
	
	import starling.text.TextField;
	import starling.text.TextFormat;
	import starling.utils.Align;
	
	public class PlayerProfilePopupContent extends AbstractPopupContent
	{
		private const TEST_DATA:Array = [ new StatsData({ title:"Stat 1", value:"Value 1" }),
												 new StatsData({ title:"Stat 2", value:"Value 2" }),
												 new StatsData({ title:"Stat 3", value:"Value 3" }),
												 new StatsData({ title:"Stat 4", value:"Value 4" }),
												 new StatsData({ title:"Stat 5", value:"Value 5" }),
												 new StatsData({ title:"Stat 6", value:"Value 6" }),
												 new StatsData({ title:"Stat 7", value:"Value 7" }),
												 new StatsData({ title:"Stat 8", value:"Value 8" }),
												 new StatsData({ title:"Stat 9", value:"Value 9" }) ];
		
		/**
		 * The photo container. */
		private var _photoContainer:IconButton;
		/**
		 * The title. */
		private var _userName:TextField;
		
		/**
		 * High score value container. */
		private var _highscoreContainer:ValueIconContainer;
		/**
		 * High score value container. */
		private var _trophiesContainer:ValueIconContainer;
		
		/**
		 * Statistics list. */
		private var _statsList:List;
		/**
		 * Premium content displayed if the user is not premium. */
		private var _premiumContent:PremiumContainer;
		
		public function PlayerProfilePopupContent()
		{
			super();
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			data = false;
			
			_photoContainer = new IconButton(AbstractEntryPoint.assets.getTexture("photo-container"), null, MemberManager.getInstance().facebookId != 0 ? ("https://graph.facebook.com/" + MemberManager.getInstance().facebookId + "/picture?type=square") : AbstractEntryPoint.assets.getTexture("default-photo"));
			_photoContainer.enabled = false;
			_photoContainer.width = _photoContainer.height = scaleAndRoundToDpi(88); // TODO change picture to be 88 natively
			addChild(_photoContainer);
			
			_userName = new TextField(scaleAndRoundToDpi(150), _photoContainer.height, "TEST test", new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(30), 0x000000, Align.LEFT));
			_userName.border = true;
			_userName.wordWrap = false;
			addChild(_userName);
			
			_highscoreContainer = new ValueIconContainer(AbstractEntryPoint.assets.getTexture("highscore-mini-icon"), AbstractEntryPoint.assets.getTexture("value-container"), Utilities.splitThousands(99999));
			addChild(_highscoreContainer);
			
			_trophiesContainer = new ValueIconContainer(AbstractEntryPoint.assets.getTexture("trophies-mini-icon"), AbstractEntryPoint.assets.getTexture("value-container"), Utilities.splitThousands(99999));
			addChild(_trophiesContainer);
			
			_statsList = new List();
			_statsList.isSelectable = false;
			_statsList.itemRendererType = StatsItemRenderer;
			_statsList.scrollBarDisplayMode = Scroller.SCROLL_BAR_DISPLAY_MODE_FLOAT;
			_statsList.verticalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			_statsList.horizontalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			_statsList.dataProvider = new ListCollection(TEST_DATA);
			addChild(_statsList);
			
			if(!MemberManager.getInstance().isPremium)
			{
				AdManager.getInstance().addEventListener(MobileEventTypes.VIDEO_SUCCESS, onStatsUnlocked);
				_premiumContent = new PremiumContainer();
				_statsList.addChild(_premiumContent);
			}
		}
		
		override protected function draw():void
		{
			if(isInvalid(INVALIDATION_FLAG_SIZE))
			{
				_userName.x = _photoContainer.width;  
				
				_highscoreContainer.width = _trophiesContainer.width = scaleAndRoundToDpi(200);
				_highscoreContainer.x = _trophiesContainer.x = actualWidth - _highscoreContainer.width;
				_trophiesContainer.y = _photoContainer.height - _trophiesContainer.height;
				
				_userName.width = _highscoreContainer.x - _userName.x;
				
				_statsList.y = _photoContainer.y + _photoContainer.height + scaleAndRoundToDpi(10);
				_statsList.width = actualWidth;
				
				if(_premiumContent)
				{
					_premiumContent.width = _statsList.width * 0.8;
					_premiumContent.y = scaleAndRoundToDpi(20);
					_premiumContent.x = roundUp((_statsList.width - _premiumContent.width) * 0.5);
				}
			}
			
			super.draw();
		}
		
//------------------------------------------------------------------------------------------------------------
//	Handlers
		
		private function onStatsUnlocked(event:Event):void
		{
			log("[PlayerProfilePopupContent] Statistics unlocked.");
			
			AdManager.getInstance().removeEventListener(MobileEventTypes.VIDEO_SUCCESS, onStatsUnlocked);
			_premiumContent.removeFromParent(true);
			_premiumContent = null;
			
			if(_statsList && _statsList.dataProvider)
			{
				var lenList:int = _statsList.dataProvider.length;
				for(var i:int = 0; i < lenList; i++)
				{
					StatsData(_statsList.dataProvider.getItemAt(i)).isMasked = false;
					_statsList.dataProvider.updateItemAt(i);
				}
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
		
		override public function dispose():void
		{
			if(_premiumContent)
			{
				AdManager.getInstance().removeEventListener(MobileEventTypes.VIDEO_SUCCESS, onStatsUnlocked);
				_premiumContent.removeFromParent(true);
				_premiumContent = null;
			}
			
			_photoContainer.removeFromParent(true);
			_photoContainer = null;
			
			_userName.removeFromParent(true);
			_userName = null;
			
			_highscoreContainer.removeFromParent(true);
			_highscoreContainer = null;
			
			_trophiesContainer.removeFromParent(true);
			_trophiesContainer = null;
			
			_statsList.removeFromParent(true);
			_statsList = null;
			
			super.dispose();
		}
	}
}