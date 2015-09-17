/**
 * Created by Maxime on 14/09/15.
 */
package com.ludofactory.mobile.core.promo
{
	
	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.mobile.core.events.MobileEventTypes;
	import com.ludofactory.mobile.core.manager.TimerManager;
	
	import starling.events.EventDispatcher;
	
	/**
	 * Promo manager.
	 */
	public class PromoManager extends EventDispatcher
	{
		private static var _instance:PromoManager;
		
		/**
		 * Timer used to display the remaining time until the end of the promo. */
		private var _timerManager:TimerManager;
		
		/**
		 * The promo data. */
		private var _promoData:PromoData;
		/**
		 * The promo content to update. */
		//private var _promoContent:PromoContent;
		
		/**
		 * Whether a promo is pending. */
		private var _isPromoPending:Boolean = false;
		
		private var _promoContentList:Vector.<PromoContent> = new Vector.<PromoContent>();
		
		private var _helperText:String = "";
		
		public function PromoManager(sk:SecurityKey)
		{
			if(sk == null)
				throw new Error("Erreur : Echec de l'instanciation : Utiliser PromoManager.getInstance() au lieu de new.");
		}
		
		/**
		 * Builds a promo.
		 * 
		 * The timer have to be running even in background so that the remaining time is always correct.
		 * 
		 * @param rawPromoData
		 */
		public function buildPromo(rawPromoData:Object):void
		{
			// by security, we check if the time left has a valid value
			if("timeLeft" in rawPromoData && rawPromoData.timeLeft > 0)
			{
				_promoData = new PromoData(rawPromoData);
				
				if(_timerManager)
					_timerManager.dispose();
				_timerManager = new TimerManager(_promoData.timeLeft, 1, onTimerUpdate, null, onTimerOver, true);
				_timerManager.start();
				
				_isPromoPending = true;
				dispatchEventWith(MobileEventTypes.PROMO_UPDATED);
			}
			else
			{
				// just in case
				_isPromoPending = false;
				dispatchEventWith(MobileEventTypes.PROMO_UPDATED);
			}
		}
		
		/**
		 * Gives the PromoManager a content to udpdate.
		 * 
		 * This fonction is calle whenever the user goes to the StoreScreen or the StakeSelectionScreen.
		 * 
		 * @param isCompact Which display style we want : compact or not
		 */
		public function getPromoContent(isCompact:Boolean):PromoContent
		{
			if(_isPromoPending)
			{
				var promoContent:PromoContent = new PromoContent(_promoData, isCompact);
				_promoContentList.push(promoContent);
				return promoContent;
			}
			return null;
		}
		
		/**
		 * Called if a promo is displaying but the PHP returned no promo.
		 */
		public function removePromo(promoContent:PromoContent):void
		{
			_promoContentList.splice(_promoContentList.indexOf(promoContent), 1);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Timer handlers
		
		/**
		 * on timer update.
		 * 
		 * @param timeLeft
		 */
		private function onTimerUpdate(timeLeft:int):void
		{
			if( _promoContentList.length <= 0 )
				return; // no need to update here if the displayer is not on screen (while playing for example)
			
			if( _timerManager.currentDay != 0 )
			{
				// display days and hours XXdYY (ex : 1d18)
				_helperText = (_timerManager.currentDay < 10 ? ("0" + _timerManager.currentDay) : _timerManager.currentDay) + _("j")
						+ (_timerManager.currentHour < 10 ? ("0" + _timerManager.currentHour) : _timerManager.currentHour);
			}
			else if( _timerManager.currentHour != 0 )
			{
				// display hours and minutes XXhYY (ex : 18h20)
				_helperText = (_timerManager.currentHour < 10 ? ("0" + _timerManager.currentHour) : _timerManager.currentHour) + _("h")
						+ (_timerManager.currentMin < 10 ? ("0" + _timerManager.currentMin) : _timerManager.currentMin);
			}
			else
			{
				// display minutes and seconds XXmYY (ex : 20m10)
				_helperText = (_timerManager.currentMin < 10 ? ("0" + _timerManager.currentMin) : _timerManager.currentMin) + _("m")
						+ (_timerManager.currentSec < 10 ? ("0" + _timerManager.currentSec) : _timerManager.currentSec);
			}
			
			for (var i:int = 0; i < _promoContentList.length; i++)
			{
				if(_timerManager.currentDay == 0 && _timerManager.currentMin <= 30 && _timerManager.currentSec == 0 || _timerManager.currentMin <= 29)
					_promoContentList[i].updateLabelColor();
				_promoContentList[i].timerLabelText = _helperText;
			}
		}
		
		/**
		 * When the promo ends, we need to clear all the associated data, the timer, etc.
		 */
		private function onTimerOver():void
		{
			if(_timerManager)
				_timerManager.dispose();
			_timerManager = null;
			
			_promoData = null;
			
			for (var i:int = 0; i < _promoContentList.length; i++)
			{
				// the screen will remove it, so simply stop it here
				 _promoContentList[i].onTimerOver();
			}
			
			_isPromoPending = false;
			dispatchEventWith(MobileEventTypes.PROMO_UPDATED);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Get - Set
		
		public function get isPromoPending():Boolean { return _isPromoPending; }
		
//------------------------------------------------------------------------------------------------------------
//	
		
		public static function getInstance():PromoManager
		{
			if(_instance == null)
				_instance = new PromoManager(new SecurityKey());
			return _instance;
		}
		
	}
}

internal class SecurityKey{}