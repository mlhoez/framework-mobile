/*
Copyright © 2006-2015 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 8 août 2013
*/
package com.ludofactory.mobile.navigation.home.summary
{
	import com.freshplanet.nativeExtensions.AirNetworkInfo;
	import com.ludofactory.common.utils.Utilities;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.HeartBeat;
	import com.ludofactory.mobile.core.events.LudoEventType;
	import com.ludofactory.mobile.core.manager.MemberManager;
	import com.ludofactory.mobile.core.remoting.Remote;
	import com.ludofactory.mobile.core.push.GameSession;
	
	import flash.utils.getTimer;
	
	import feathers.core.FeathersControl;
	
	public class SummaryContainer extends FeathersControl
	{
		public static var IS_TIMER_OVER_AND_REQUEST_FAILED:Boolean = false;
		
		/**
		 * The scaled height of the container (80 by default). */		
		private var _containerHeight:Number;
		
		/**
		 * The free container. */		
		//private var _freeContainer:SummaryElement;
		/**
		 * The points container. */		
		//private var _pointsContainer:SummaryElement;
		/**
		 * The credits container. */		
		//private var _creditsContainer:SummaryElement;
		
		/**
		 * Timer variables. */		
		private var _previousTime:Number;
		private var _elapsedTime:Number;
		private var _totalTime:Number;
		
		public function SummaryContainer()
		{
			super();
			
			_containerHeight = scaleAndRoundToDpi(80);
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			/*_freeContainer = new SummaryElement( GameSession.PRICE_FREE );
			addChild(_freeContainer);
			
			_pointsContainer = new SummaryElement( GameSession.PRICE_POINT );
			addChild(_pointsContainer);
			
			_creditsContainer = new SummaryElement( GameSession.PRICE_CREDIT );
			addChild(_creditsContainer);*/
			
			updateData();
		}
		
		override protected function draw():void
		{
			super.draw();
			
			/*setSizeInternal(this.actualWidth, _containerHeight, false);
			
			_freeContainer.height = _pointsContainer.height = _creditsContainer.height = this.actualHeight;
			
			_freeContainer.width = _creditsContainer.width = this.actualWidth * 0.3 - scaleAndRoundToDpi(10);
			_pointsContainer.width = this.actualWidth * 0.4 - scaleAndRoundToDpi(10) * 2;
			
			_freeContainer.x = scaleAndRoundToDpi(10);
			_pointsContainer.x = (_freeContainer.width + (scaleAndRoundToDpi(10) * 2)) << 0;
			_creditsContainer.x = (_pointsContainer.x + _pointsContainer.width + scaleAndRoundToDpi(10)) << 0;
			
			_freeContainer.validate();
			_freeContainer.y = _pointsContainer.y = _creditsContainer.y = ((actualHeight - _freeContainer.height) * 0.5) << 0;*/
		}
		
//------------------------------------------------------------------------------------------------------------
//	Timer handler
		
		public function updateData():void
		{
			// Gérer ici le cas = 0 etc.
			
			
		}
		
		/**
		 * Animates the summary.
		 */		
		public function animateSummary(data:Object):void
		{
			
		}
		
		private var _h:int;
		private var _m:int;
		private var _s:int;
		
		/**
		 * 
		 */		
		private function update(elapsedTime:Number):void
		{
			_elapsedTime = getTimer() - _previousTime;
			_previousTime = getTimer();
			_totalTime -= _elapsedTime;
			
			_h = Math.round(_totalTime / 1000) / 3600;
			_m = (Math.round(_totalTime / 1000) / 60) % 60;
			_s = Math.round(_totalTime / 1000) % 60;
			
			// if 0 = update and stop timer
			if( _h <= 0 && _m <= 0 && _s <= 0 )
			{
				HeartBeat.unregisterFunction(update);
				//_freeContainer.setLabelText( "00:00:00" );
				if( AirNetworkInfo.networkInfo.isConnected() )
					Remote.getInstance().updateMises(onMisesUpdated, onMisesUpdated, onMisesUpdated, 1);
				else
					onMisesUpdated();
			}
			else
			{
				//_freeContainer.setLabelText( (_h < 10 ? "0":"") + _h + ":" + (_m < 10 ? "0":"") + _m + ":" + (_s < 10 ? "0":"") + _s );
			}
			
		}
		
		private function onMisesUpdated(result:Object = null):void
		{
			if( MemberManager.getInstance().getNumTokens() == 0 )
				IS_TIMER_OVER_AND_REQUEST_FAILED = true;
			else
				IS_TIMER_OVER_AND_REQUEST_FAILED = false;
			MemberManager.getInstance().dispatchEventWith(LudoEventType.UPDATE_SUMMARY);
		}
		
		/*private function onUpdateFreeTimer(min:int, sec:int, formattedTime:String):void
		{
			_freeContainer.setLabelText( formattedTime );
		}*/
	}
}