/*
LudoFactory
Framework mobile
Author  : Maxime Lhoez
Created : 8 août 2013
*/
package com.ludofactory.mobile.core.test.home.summary
{
	import com.freshplanet.nativeExtensions.AirNetworkInfo;
	import com.ludofactory.common.utils.Utility;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.HeartBeat;
	import com.ludofactory.mobile.core.events.LudoEventType;
	import com.ludofactory.mobile.core.authentication.MemberManager;
	import com.ludofactory.mobile.core.remoting.Remote;
	import com.ludofactory.mobile.core.test.push.GameSession;
	
	import flash.utils.getTimer;
	
	import feathers.core.FeathersControl;
	
	public class SummaryContainer extends FeathersControl
	{
		public static var IS_TIMER_OVER_AND_REQUEST_FAILED:Boolean = false;
		
		/**
		 * The base height. */		
		private const BASE_HEIGHT:int = 80;
		/**
		 * The scaled height. */		
		private var _scaledHeight:Number;
		
		/**
		 * The free container. */		
		private var _freeContainer:SummaryElement;
		/**
		 * The points container. */		
		private var _pointsContainer:SummaryElement;
		/**
		 * The credits container. */		
		private var _creditsContainer:SummaryElement;
		
		/**
		 * Timer variables. */		
		private var _previousTime:Number;
		private var _elapsedTime:Number;
		private var _totalTime:Number;
		
		public function SummaryContainer()
		{
			super();
			
			_scaledHeight = scaleAndRoundToDpi(BASE_HEIGHT);
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			_freeContainer = new SummaryElement( GameSession.PRICE_FREE );
			addChild(_freeContainer);
			
			_pointsContainer = new SummaryElement( GameSession.PRICE_POINT );
			addChild(_pointsContainer);
			
			_creditsContainer = new SummaryElement( GameSession.PRICE_CREDIT );
			addChild(_creditsContainer);
			
			updateData();
		}
		
		override protected function draw():void
		{
			super.draw();
			
			setSizeInternal(this.actualWidth, _scaledHeight, false);
			
			_freeContainer.height = _pointsContainer.height = _creditsContainer.height = this.actualHeight;
			
			_freeContainer.width = _creditsContainer.width = this.actualWidth * 0.3 - scaleAndRoundToDpi(10);
			_pointsContainer.width = this.actualWidth * 0.4 - scaleAndRoundToDpi(10) * 2;
			
			_freeContainer.x = scaleAndRoundToDpi(10);
			_pointsContainer.x = (_freeContainer.width + (scaleAndRoundToDpi(10) * 2)) << 0;
			_creditsContainer.x = (_pointsContainer.x + _pointsContainer.width + scaleAndRoundToDpi(10)) << 0;
			
			_freeContainer.validate();
			_freeContainer.y = _pointsContainer.y = _creditsContainer.y = ((actualHeight - _freeContainer.height) * 0.5) << 0;
		}
		
//------------------------------------------------------------------------------------------------------------
//	Timer handler
//------------------------------------------------------------------------------------------------------------
		
		public function updateData():void
		{
			HeartBeat.unregisterFunction(update);
			
			if( MemberManager.getInstance().isLoggedIn() )
			{
				if( MemberManager.getInstance().getNumFreeGameSessions() > 0 )
				{
					IS_TIMER_OVER_AND_REQUEST_FAILED = false;
					_freeContainer.setLabelText( "" + MemberManager.getInstance().getNumFreeGameSessions() );
				}
				else
				{
					if( IS_TIMER_OVER_AND_REQUEST_FAILED )
					{
						_freeContainer.setLabelText("???");
					}
					else
					{
						var nowInFrance:Date = Utility.getLocalFrenchDate();
						_totalTime = (86400 - (nowInFrance.hours * 60 * 60) - (nowInFrance.minutes * 60) - nowInFrance.seconds) * 1000;
						_previousTime = getTimer();
						HeartBeat.registerFunction(update);
					}
				}
				_pointsContainer.setLabelText( "" + Utility.splitThousands( MemberManager.getInstance().getPoints() ) );
				_creditsContainer.setLabelText( "" + Utility.splitThousands( MemberManager.getInstance().getCredits() ) );
			}
			else
			{
				_freeContainer.setLabelText( "" + ( MemberManager.getInstance().isLoggedIn() ? (MemberManager.getInstance().getNumFreeGameSessions()) : (MemberManager.getInstance().getNumFreeGameSessions() == 0 ? "???" : MemberManager.getInstance().getNumFreeGameSessions())) );
				//_pointsContainer.setLabelText( "" + ( MemberManager.getInstance().isLoggedIn() ? (MemberManager.getInstance().getPoints()) : (MemberManager.getInstance().getNumFreeGameSessions() == 0 ? "???" : MemberManager.getInstance().getPoints()))  );
				_pointsContainer.setLabelText( "" + MemberManager.getInstance().getPoints() );
				_creditsContainer.setLabelText( "-"  );
			}
		}
		
		/**
		 * Animates the summary.
		 */		
		public function animateSummary(data:Object):void
		{
			switch(data.type)
			{
				case GameSession.PRICE_FREE:
				{
					_freeContainer.animateChange( data.value );
					break;
				}
				case GameSession.PRICE_CREDIT:
				{
					_creditsContainer.animateChange( data.value );
					break;
				}
				case GameSession.PRICE_POINT:
				{
					_pointsContainer.animateChange( data.value );
					break;
				}
			}
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
				_freeContainer.setLabelText( "00:00:00" );
				if( AirNetworkInfo.networkInfo.isConnected() )
					Remote.getInstance().updateMises(onMisesUpdated, onMisesUpdated, onMisesUpdated, 1);
				else
					onMisesUpdated();
			}
			else
			{
				_freeContainer.setLabelText( (_h < 10 ? "0":"") + _h + ":" + (_m < 10 ? "0":"") + _m + ":" + (_s < 10 ? "0":"") + _s );
			}
			
		}
		
		private function onMisesUpdated(result:Object = null):void
		{
			if( MemberManager.getInstance().getNumFreeGameSessions() == 0 )
				IS_TIMER_OVER_AND_REQUEST_FAILED = true;
			else
				IS_TIMER_OVER_AND_REQUEST_FAILED = false;
			MemberManager.getInstance().dispatchEventWith(LudoEventType.UPDATE_SUMMARY);
		}
		
		/*private function onUpdateFreeTimer(min:int, sec:int, formattedTime:String):void
		{
			_freeContainer.setLabelText( formattedTime );
		}*/
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
//------------------------------------------------------------------------------------------------------------
		
		override public function dispose():void
		{
			HeartBeat.unregisterFunction(update);
			
			_freeContainer.removeFromParent(true);
			_freeContainer = null;
			
			_pointsContainer.removeFromParent(true);
			_pointsContainer = null;
			
			_creditsContainer.removeFromParent(true);
			_creditsContainer = null;
			
			super.dispose();
		}
	}
}