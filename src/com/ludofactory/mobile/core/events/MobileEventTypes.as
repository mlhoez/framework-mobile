package com.ludofactory.mobile.core.events
{
	public class MobileEventTypes
	{
		/**
		 * The <code>LudoEventType.REFRESH_TOP</code> event type is used
		 * by TopDownRefreshableList when the user has requested a top
		 * refresh.
		 */
		public static const REFRESH_TOP:String = "refreshTop";
		
		/**
		 * The <code>LudoEventType.CLOSE_NOTIFICATION</code> event type is
		 * used by the NotificationManager when the user wants to close the
		 * notification.
		 */
		public static const CLOSE_NOTIFICATION:String = "closeNotification";
		
		/**
		 * The <code>LudoEventType.EXPAND_BEGIN</code> event type is used by
		 * the AccordionElement class when a panel is about to expand.
		 */
		public static const EXPAND_BEGIN:String = "expandBegin";
		
		/**
		 * The <code>LudoEventType.EXPAND_COMPLETE</code> event type is used by
		 * the AccordionElement class when a panel has fully expanded.
		 */
		public static const EXPAND_COMPLETE:String = "expandComplete";
		
		/**
		 * The <code>LudoEventType.COLLAPSE_BEGIN</code> event type is used by
		 * the AccordionElement class when a panel is about to collapse.
		 */
		public static const COLLAPSE_BEGIN:String = "collapseBegin";
		
		/**
		 * The <code>LudoEventType.COLLAPSE_COMPLETE</code> event type is used by
		 * the AccordionElement class when a panel has fully collapsed.
		 */
		public static const COLLAPSE_COMPLETE:String = "collapseComplete";
		
		/**
		 * The <code>LudoEventType.COLLAPSE_COMPLETE</code> event type is used by
		 * the AccordionElement class when a panel has fully collapsed.
		 */
		public static const LOG_OUT:String = "logOut";
		
		/**
		 * The <code>LudoEventType.COLLAPSE_COMPLETE</code> event type is used by
		 * the AccordionElement class when a panel has fully collapsed.
		 */
		public static const LIST_BOTTOM_UPDATE:String = "listBottomAutoUpdate";
		
		/**
		 * The <code>LudoEventType.COLLAPSE_COMPLETE</code> event type is used by
		 * the AccordionElement class when a panel has fully collapsed.
		 */
		public static const LIST_TOP_UPDATE:String = "listTopAutoUpdate";
		
		/**
		 * The <code>LudoEventType.COLLAPSE_COMPLETE</code> event type is used by
		 * the AccordionElement class when a panel has fully collapsed.
		 */
		public static const SAVE_ACCOUNT_INFORMATION:String = "saveAccountInformation";
		
		
		/**
		 * The <code>LudoEventType.COLLAPSE_COMPLETE</code> event type is used by
		 * the AccordionElement class when a panel has fully collapsed.
		 */
		public static const UPDATE_HEADER:String = "updateHeader";
		
		/**
		 * The <code>LudoEventType.COLLAPSE_COMPLETE</code> event type is used by
		 * the AccordionElement class when a panel has fully collapsed.
		 */
		public static const HIDE_MAIN_MENU:String = "hideMainMenu";
		
		/**
		 * The <code>LudoEventType.COLLAPSE_COMPLETE</code> event type is used by
		 * the AccordionElement class when a panel has fully collapsed.
		 */
		public static const SHOW_MAIN_MENU:String = "showMainMenu";
		
		
//------------------------------------------------------------------------------------------------------------
//
		
		/**
		 * The <code>MobileEventType.MEMBER_UPDATED</code> event type is dispatched by the MemberManager
		 * instance whenever the member object is parsed.
		 */
		public static const MEMBER_UPDATED:String = "update-member";
		
//------------------------------------------------------------------------------------------------------------
//	Pause
		
		public static const ANIMATION_IN_COMPLETE:String  = "animationInComplete";
		public static const ANIMATION_OUT_COMPLETE:String = "animationOutComplete";
		
		public static const RESUME:String = "resume";
		public static const EXIT:String   = "exit";
		
		public static const BUTTON_DOWN:String   = "button-down";
		public static const BUTTON_UP:String   = "button-up";
		
		
		
		
		
		
//------------------------------------------------------------------------------------------------------------
//	NEW
		
		
	// ----- Store / In-app purchases
		
		/**
		 * Dispatched by <code>Store.as</code> when the store have been initialized. */
		public static const STORE_INITIALIZED:String = "store-initialized";
		/**
		 * Dispatched by <code>Store.as</code> when the products have been loaded. */
		public static const STORE_PRODUCTS_LOADED:String = "store-products-loaded";
		/**
		 * Dispatched by <code>Store.as</code> when the products have NOT been loaded. */
		public static const STORE_PRODUCTS_NOT_LOADED:String = "store-products-not-loaded";
		/**
		 * Dispatched by <code>Store.as</code> when a purchase have been successfully made. */
		public static const STORE_PURCHASE_SUCCESS:String = "store-purchase-success";
		/**
		 * Dispatched by <code>Store.as</code> when a purchase have been cancelled. */
		public static const STORE_PURCHASE_CANCELLED:String = "store-purchase-cancelled";
		/**
		 * Dispatched by <code>Store.as</code> when a purchase have failed. */
		public static const STORE_PURCHASE_FAILED:String = "store-purchase-failed";
		
	// ----- Videos
		
		/**
		 * Dispatched by <code>AdManager.as</code> when a video have been viewed. */
		public static const VIDEO_SUCCESS:String = "video-success";
		/**
		 * Dispatched by <code>AdManager.as</code> when a video could not be viewed or have been cancelled. */
		public static const VIDEO_FAIL:String = "video-fail";
		/**
		 * Dispatched by <code>AdManager.as</code> when a video availability is updated. */
		public static const VIDEO_AVAILABILITY_UPDATE:String = "video-availability-update";
		
	// ----- Game Center
		
		/**
		 * Dispatched by <code>several classes</code> when the Game Center authentication was successfully made. */
		public static const GAME_CENTER_AUTHENTICATION_SUCCESS:String = "game-center-authentication-success";
		/**
		 * Dispatched by <code>several classes</code> when the Game Center authentication failed. */
		public static const GAME_CENTER_AUTHENTICATION_FAILURE:String = "game-center-authentication-failure";
		
	// ----- Tutorial
		
		/**
		 * Dispatched by <code>TutorialManager.as</code> when a new step is displayed. */
		public static const NEXT_TUTORIAL_STEP:String = "next-tutorial-step";
	}
}