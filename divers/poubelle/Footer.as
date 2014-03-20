package com.ludofactory.mobile.core.controls
{
	import com.ludofactory.mobile.application.config.GlobalConfig;
	import com.ludofactory.mobile.core.membership.MemberManager;
	
	import app.AppEntryPoint;
	
	import feathers.controls.TabBar;
	import feathers.data.ListCollection;
	
	import starling.display.Image;
	
	public class Footer extends TabBar
	{
		/**
		 * The default value added to the <code>nameList</code> of the first tab.
		 *
		 * @see feathers.core.IFeathersControl#nameList
		 */
		public static const DEFAULT_CHILD_NAME_FIRST_TAB:String = "feathers-tab-bar-first-tab";
		
		/**
		 * The default value added to the <code>nameList</code> of the last tab.
		 *
		 * @see feathers.core.IFeathersControl#nameList
		 */
		public static const DEFAULT_CHILD_NAME_LAST_TAB:String = "feathers-tab-bar-last-tab";
		
		/**
		 * The gifts icon. */		
		private var _giftsIcon:Image;
		
		/**
		 * The sponsor icon. */		
		private var _sponsorIcon:Image;
		
		/**
		 * The menu icon. */		
		private var _menuIcon:Image;
		
		/**
		 * The high score icon. */		
		private var _highScoreIcon:Image;
		
		/**
		 * The store icon. */		
		private var _storeIcon:Image;
		
		/**
		 * The log out icon. */		
		private var _logInIcon:Image;
		
		/**
		 * The logged in data provider. */		
		private var _loggedInDataProvider:ListCollection;
		/**
		 * the logged out data provider. */		
		private var _loggedOutDataProvider:ListCollection;
		
		public function Footer()
		{
			super();
			
			firstTabName = DEFAULT_CHILD_NAME_FIRST_TAB;
			lastTabName = DEFAULT_CHILD_NAME_LAST_TAB;
			tabFactory = badgedTabFactory;
		}
		
		private function badgedTabFactory():BadgedButton
		{
			return new BadgedButton();
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			toggleGroup.isSelectionRequired = false;
			
			_giftsIcon = new Image( AbstractEntryPoint.assets.getTexture("FooterGiftsIcon") );
			_giftsIcon.scaleX = _giftsIcon.scaleY = GlobalConfig.dpiScalez;
			
			_sponsorIcon = new Image( AbstractEntryPoint.assets.getTexture("FooterParrainageIcon") );
			_sponsorIcon.scaleX = _sponsorIcon.scaleY = GlobalConfig.dpiScalez;
			
			_menuIcon = new Image( AbstractEntryPoint.assets.getTexture("FooterMenuIcon") );
			_menuIcon.scaleX = _menuIcon.scaleY = GlobalConfig.dpiScalez;
			
			_highScoreIcon = new Image( AbstractEntryPoint.assets.getTexture("FooterHighScoreIcon") );
			_highScoreIcon.scaleX = _highScoreIcon.scaleY = GlobalConfig.dpiScalez;
			
			_storeIcon = new Image( AbstractEntryPoint.assets.getTexture("FooterStoreIcon") );
			_storeIcon.scaleX = _storeIcon.scaleY = GlobalConfig.dpiScalez;
			
			_logInIcon = new Image( AbstractEntryPoint.assets.getTexture("FooterLoginIcon") );
			_logInIcon.scaleX = _logInIcon.scaleY = GlobalConfig.dpiScalez;
			
			_loggedInDataProvider = new ListCollection( [ { label:"", defaultIcon:_highScoreIcon },
														  { label:"", defaultIcon:_giftsIcon },
														  { label:"", defaultIcon:_menuIcon },
														  { label:"", defaultIcon:_sponsorIcon },
														  { label:"", defaultIcon:_storeIcon } ] );
			
			_loggedOutDataProvider = new ListCollection( [ { label:"", defaultIcon:_highScoreIcon },
														   { label:"", defaultIcon:_giftsIcon },
														   { label:"", defaultIcon:_menuIcon },
														   { label:"", defaultIcon:_sponsorIcon },
														   { label:"", defaultIcon:_logInIcon } ] );
			
			dataProvider = MemberManager.getInstance().isLoggedIn() ? _loggedInDataProvider : _loggedOutDataProvider;
		}
		
		public function updateBadges():void
		{
			// FIXME Update bagdes here
			// Use : AbstractEntryPoint.alertData.something
			// lorsque les écrans du footer sont affichés, faire un requête pour updater le footer
			BadgedButton(activeTabs[0]).badgeCount = 100;
		}
		
		/**
		 * Updates to footer buttons depending on the actual state of
		 * the player (logged in or not).
		 * 
		 * @param loggedIn Whether the user is logged in
		 */		
		public function updateDataProvider(loggedIn:Boolean):void
		{
			dataProvider = loggedIn ? _loggedInDataProvider : _loggedOutDataProvider;
			selectedIndex = -1;
		}
		
		
	}
}