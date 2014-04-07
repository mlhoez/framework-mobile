/*
LudoFactory
Framework mobile
Author  : Maxime Lhoez
Created : 4 oct. 2013
*/
package com.ludofactory.mobile.core.test.alert
{
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.Localizer;
	import com.ludofactory.mobile.core.authentication.MemberManager;
	import com.ludofactory.mobile.core.events.LudoEventType;
	import com.ludofactory.mobile.core.test.push.AbstractElementToPush;
	import com.ludofactory.mobile.core.test.push.AlertType;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import feathers.controls.Button;
	import feathers.controls.Label;
	import feathers.controls.List;
	import feathers.controls.Scroller;
	import feathers.core.FeathersControl;
	import feathers.data.ListCollection;
	import feathers.layout.VerticalLayout;
	
	import starling.display.Quad;
	import starling.events.Event;
	
	/**
	 * The alert container.
	 */	
	public class AlertContainer extends FeathersControl
	{
		/**
		 * The background. */		
		private var _background:Quad;
		
		/**
		 * The title. */		
		private var _title:Label;
		
		/**
		 * The alert list. */		
		private var _list:List;
		
		/**
		 * The close button. */		
		private var _closeButton:Button;
		
		public function AlertContainer()
		{
			super();
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			_background = new Quad(5, 5);
			_background.touchable = false;
			addChild(_background);
			
			_title = new Label();
			_title.touchable = false;
			_title.text = Localizer.getInstance().translate("ALERT.TITLE");
			addChild(_title);
			_title.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(32), Theme.COLOR_ORANGE, false, false, null, null, null, TextFormatAlign.CENTER);
			
			const layout:VerticalLayout = new VerticalLayout();
			layout.hasVariableItemDimensions = true;
			layout.manageVisibility = true;
			layout.useVirtualLayout = true;
			
			_list = new List();
			//_list.dataProvider = new ListCollection( AbstractEntryPoint.pushManager.elementsToPush );
			_list.layout = layout;
			_list.verticalScrollPolicy = Scroller.SCROLL_POLICY_AUTO;
			_list.horizontalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			_list.scrollBarDisplayMode = Scroller.SCROLL_BAR_DISPLAY_MODE_FLOAT;
			_list.isSelectable = false;
			_list.itemRendererType = AlertItemRenderer;
			addChild(_list);
			
			_closeButton = new Button();
			_closeButton.nameList.add( Theme.BUTTON_EMPTY );
			_closeButton.addEventListener(Event.TRIGGERED, onClose);
			_closeButton.label = Localizer.getInstance().translate("ALERT.CLOSE_BUTTON_LABEL");
			addChild(_closeButton);
			_closeButton.minHeight = _closeButton.minTouchHeight = scaleAndRoundToDpi(90);
			_closeButton.defaultLabelProperties.textFormat = new TextFormat(Theme.FONT_ARIAL, scaleAndRoundToDpi(30), Theme.COLOR_DARK_GREY, true, true);
		}
		
		override protected function draw():void
		{
			super.draw();
			
			_background.width = this.actualWidth;
			_background.height = this.actualHeight;
			
			_title.y = scaleAndRoundToDpi(10);
			_title.width = this.actualWidth;
			_title.validate();
			
			_closeButton.validate();
			_closeButton.x = (actualWidth - _closeButton.width) * 0.5;
			_closeButton.y = actualHeight - _closeButton.height;
			
			_list.y = _title.y + _title.height + scaleAndRoundToDpi(10);
			_list.width = this.actualWidth;
			_list.height = _closeButton.y - _list.y;
		}
		
		public function updateContent():void
		{
			_list.dataProvider = new ListCollection( AbstractEntryPoint.pushManager.elementsToPush.concat() );
			if( AbstractEntryPoint.alertData.numCustomerServiceImportantAlerts > 0 )
				_list.dataProvider.unshift( new AbstractElementToPush(AlertType.CUSTOMER_SERVICE) );
			if( AbstractEntryPoint.alertData.numSponsorAlerts > 0 )
				_list.dataProvider.unshift( new AbstractElementToPush(AlertType.SPONSOR) );
			if( AbstractEntryPoint.alertData.numGainAlerts > 0 )
				_list.dataProvider.unshift( new AbstractElementToPush(AlertType.GIFTS) );
			if( AbstractEntryPoint.alertData.numTrophiesAlerts > 0 )
				_list.dataProvider.unshift( new AbstractElementToPush(AlertType.TROPHIES) );
			
			if( !MemberManager.getInstance().isLoggedIn() && MemberManager.getInstance().getNumStarsEarnedInAnonymousGameSessions() > 0)
			{
				_list.dataProvider.unshift( new AbstractElementToPush(AlertType.ANONYMOUS_GAME_SESSION) )
			}
			if( !MemberManager.getInstance().isLoggedIn() && MemberManager.getInstance().getNumTrophiesEarnedInAnonymousGameSessions() > 0)
			{
				_list.dataProvider.unshift( new AbstractElementToPush(AlertType.ANONYMOUS_TROPHIES) )
			}
		}
		
		public function updateList():void
		{
			if( _list.dataProvider && _list.dataProvider.length > 0 )
			{
				var len:int = _list.dataProvider.length;
				for( var i:int = 0; i < len; i++)
					_list.dataProvider.updateItemAt(i);
			}
		}
		
		/**
		* The AlertContainer (i.e. the Drawer) have been closed, in this
		* case we can remove all AbstractElementToPush whose state is
		* PushState.PUSHED so that we won't show them next time the Drawer
		* is opened.
		*/
		override public function set visible(value:Boolean):void
		{
			super.visible = value;
			if( visible )
			{
				//AbstractEntryPoint.screenNavigator.clipContent = false;
				AbstractEntryPoint.pushManager.removeAllPushedElementsAfterBeeingSeen();
				// Update texts
				_title.text = Localizer.getInstance().translate("ALERT.TITLE");
				_closeButton.label = Localizer.getInstance().translate("ALERT.CLOSE_BUTTON_LABEL");
			}
		}
		
		/**
		 * Close the alerts
		 */		
		private function onClose(event:Event):void
		{
			dispatchEventWith(LudoEventType.OPEN_ALERTS);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
//------------------------------------------------------------------------------------------------------------
		
		override public function dispose():void
		{
			_background.removeFromParent(true);
			_background = null;
			
			_title.removeFromParent(true);
			_title = null;
			
			_list.removeFromParent(true);
			_list = null;
			
			super.dispose();
		}
		
	}
}