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
		 * The <code>LudoEventType.REFRESH_TOP</code> event type is used
		 * by TopDownRefreshableList when the user has requested a down
		 * refresh.
		 */
		public static const REFRESH_DOWN:String = "refreshDown";
		
		/**
		 * The <code>LudoEventType.MENU_ICON_TOUCHED</code> event type is
		 * used by Menu when the user touched an icon.
		 */
		public static const MENU_ICON_TOUCHED:String = "menuIconTouched";
		
		/**
		 * The <code>LudoEventType.MENU_ICON_TOUCHED</code> event type is
		 * used by Menu when the user touched an icon.
		 */
		public static const MAIN_MENU_TOUCHED:String = "mainMenuTouched";
		/**
		 * The <code>LudoEventType.MENU_ICON_TOUCHED</code> event type is
		 * used by Menu when the user touched an icon.
		 */
		public static const BACK_BUTTON_TOUCHED:String = "backButtonTouched";
		/**
		 * The <code>LudoEventType.MENU_ICON_TOUCHED</code> event type is
		 * used by Menu when the user touched an icon.
		 */
		public static const NEWS_BUTTON_TOUCHED:String = "newsButtonTouched";
		
		/**
		 * The <code>LudoEventType.CLOSE_NOTIFICATION</code> event type is
		 * used by the NotificationManager when the user wants to close the
		 * notification.
		 */
		public static const CLOSE_NOTIFICATION:String = "closeNotification";
		
		/**
		 * The <code>LudoEventType.BOUTIQUE_CATEGORY_TOUCHED</code> event
		 * type is used by the BoutiqueMainCatListing when the user wants to
		 * display a particlar category.
		 */
		public static const BOUTIQUE_CATEGORY_TOUCHED:String = "boutiqueCatTouched";
		
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
		public static const PURCHASE_ITEM:String = "purchaseItem";
		
		
		
		
		
		/**
		 * The <code>LudoEventType.COLLAPSE_COMPLETE</code> event type is used by
		 * the AccordionElement class when a panel has fully collapsed.
		 */
		public static const STORE_INITIALIZED:String = "storeInitialized";
		
		/**
		 * The <code>LudoEventType.COLLAPSE_COMPLETE</code> event type is used by
		 * the AccordionElement class when a panel has fully collapsed.
		 */
		public static const STORE_PRODUCTS_LOADED:String = "storeProductsLoaded";
		public static const STORE_PRODUCTS_NOT_LOADED:String = "storeProductsNotLoaded";
		
		/**
		 * The <code>LudoEventType.COLLAPSE_COMPLETE</code> event type is used by
		 * the AccordionElement class when a panel has fully collapsed.
		 */
		public static const STORE_PURCHASE_SUCCESS:String = "storePurchaseSuccess";
		/**
		 * The <code>LudoEventType.COLLAPSE_COMPLETE</code> event type is used by
		 * the AccordionElement class when a panel has fully collapsed.
		 */
		public static const OPEN_ALERTS_FROM_HEADER:String = "openAlerts";
		/**
		 * The <code>LudoEventType.COLLAPSE_COMPLETE</code> event type is used by
		 * the AccordionElement class when a panel has fully collapsed.
		 */
		public static const ALERT_COUNT_UPDATED:String = "alertCountUpdated";
		/**
		 * The <code>LudoEventType.COLLAPSE_COMPLETE</code> event type is used by
		 * the AccordionElement class when a panel has fully collapsed.
		 */
		public static const STORE_PURCHASE_CANCELLED:String = "storePurchaseCancelled";
		/**
		 * The <code>LudoEventType.COLLAPSE_COMPLETE</code> event type is used by
		 * the AccordionElement class when a panel has fully collapsed.
		 */
		public static const STORE_PURCHASE_FAILURE:String = "storePurchaseFailure";
		
		
		
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
		public static const UPDATE_HEADER_TITLE:String = "updateHeaderTitle";
		/**
		 * The <code>LudoEventType.COLLAPSE_COMPLETE</code> event type is used by
		 * the AccordionElement class when a panel has fully collapsed.
		 */
		public static const UPDATE_ALERT_CONTAINER_LIST:String = "updateAlertContainerList";
		
		
		
		
		
		
		/**
		 * The <code>LudoEventType.COLLAPSE_COMPLETE</code> event type is used by
		 * the AccordionElement class when a panel has fully collapsed.
		 */
		public static const ANIMATE_FOOTER:String = "animate-footer";
		
		
		
		/**
		 * The <code>LudoEventType.COLLAPSE_COMPLETE</code> event type is used by
		 * the AccordionElement class when a panel has fully collapsed.
		 */
		public static const HIDE_MAIN_MENU:String = "hideMainMenu";
		
		/**
		 * The <code>LudoEventType.COLLAPSE_COMPLETE</code> event type is used by
		 * the AccordionElement class when a panel has fully collapsed.
		 */
		public static const REFRESH_GIFTS_LIST:String = "refreshGiftsList";
		
		/**
		 * The <code>LudoEventType.COLLAPSE_COMPLETE</code> event type is used by
		 * the AccordionElement class when a panel has fully collapsed.
		 */
		public static const SHOW_MAIN_MENU:String = "showMainMenu";
		
		/**
		 * The <code>LudoEventType.COLLAPSE_COMPLETE</code> event type is used by
		 * the AccordionElement class when a panel has fully collapsed.
		 */
		public static const HEADER_VISIBILITY_CHANGED:String = "headerVisibilityChanged";
		
		public static const PROMO_UPDATED:String = "promoUpdated";
		
		
//------------------------------------------------------------------------------------------------------------
//
		
		/**
		 * The <code>MobileEventType.MEMBER_UPDATED</code> event type is dispatched by the MemberManager
		 * instance whenever the member object is parsed.
		 */
		public static const MEMBER_UPDATED:String = "update-member";
		
		
		
		
//------------------------------------------------------------------------------------------------------------
//	Game Center
		
		public static const GAME_CENTER_AUTHENTICATION_SUCCESS:String = "game-center-authentication-success";
		
		public static const GAME_CENTER_AUTHENTICATION_FAILURE:String = "game-center-authentication-failure";
		
//------------------------------------------------------------------------------------------------------------
//	Pause
		
		public static const ANIMATION_IN_COMPLETE:String  = "animationInComplete";
		public static const ANIMATION_OUT_COMPLETE:String = "animationOutComplete";
		
		public static const RESUME:String = "resume";
		public static const EXIT:String   = "exit";
		
		
		
		
		public static const BUTTON_DOWN:String   = "button-down";
		public static const BUTTON_UP:String   = "button-up";
		
		
		
		
		
		
	}
}