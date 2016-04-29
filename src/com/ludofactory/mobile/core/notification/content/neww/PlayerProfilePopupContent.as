/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 1 septembre 2013
*/
package com.ludofactory.mobile.core.notification.content.neww
{
	
	import com.ludofactory.common.utils.Utilities;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.manager.MemberManager;
	import com.ludofactory.mobile.core.notification.content.AbstractPopupContent;
	import com.ludofactory.mobile.core.theme.Theme;
	import com.ludofactory.newClasses.IconButton;
	import com.ludofactory.newClasses.StatsData;
	import com.ludofactory.newClasses.StatsItemRenderer;
	import com.ludofactory.newClasses.ValueIconContainer;
	
	import feathers.controls.List;
	import feathers.controls.Scroller;
	import feathers.data.ListCollection;
	
	import starling.text.TextField;
	import starling.text.TextFormat;
	import starling.utils.Align;
	
	public class PlayerProfilePopupContent extends AbstractPopupContent
	{
		private static const TEST_DATA:Array = [ new StatsData({ title:"Stat 1", value:"Value 1" }),
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
			_photoContainer.width = _photoContainer.height = scaleAndRoundToDpi(88); // TODO change picture to be 88 naturally
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
		}
		
		override protected function draw():void
		{
			_userName.x = _photoContainer.width;  
			
			_highscoreContainer.width = _trophiesContainer.width = scaleAndRoundToDpi(200);
			_highscoreContainer.x = _trophiesContainer.x = actualWidth - _highscoreContainer.width;
			_trophiesContainer.y = _photoContainer.height - _trophiesContainer.height;
			
			_userName.width = _highscoreContainer.x - _userName.x;
			
			_statsList.y = _photoContainer.y + _photoContainer.height + scaleAndRoundToDpi(10);
			_statsList.width = actualWidth;
			
			super.draw();
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
		
		override public function dispose():void
		{
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