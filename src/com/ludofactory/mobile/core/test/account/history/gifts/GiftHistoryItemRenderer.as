/*
LudoFactory
Framework mobile
Author  : Maxime Lhoez
Created : 17 sept. 2013
*/
package com.ludofactory.mobile.core.test.account.history.gifts
{
	import com.freshplanet.nativeExtensions.AirNetworkInfo;
	import com.ludofactory.common.utils.Utility;
	import com.ludofactory.common.utils.log;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.Localizer;
	import com.ludofactory.mobile.core.controls.ArrowGroup;
	import com.ludofactory.mobile.core.events.LudoEventType;
	import com.ludofactory.mobile.core.manager.InfoContent;
	import com.ludofactory.mobile.core.manager.InfoManager;
	import com.ludofactory.mobile.core.remoting.Remote;
	import com.ludofactory.mobile.core.test.config.GlobalConfig;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import feathers.controls.GroupedList;
	import feathers.controls.Label;
	import feathers.controls.renderers.IGroupedListItemRenderer;
	import feathers.core.FeathersControl;
	
	import pl.mateuszmackowiak.nativeANE.dialogs.NativeAlertDialog;
	import pl.mateuszmackowiak.nativeANE.events.NativeDialogEvent;
	
	import starling.display.Quad;
	import starling.events.Event;
	import starling.utils.formatString;
	
	/**
	 * Item renderer used to display the customer service messages.
	 */	
	public class GiftHistoryItemRenderer extends FeathersControl implements IGroupedListItemRenderer
	{
		/**
		 * The base height of a line in the list. */		
		private static const BASE_HEIGHT:int = 80;
		/**
		 * The scaled item height. */		
		private var _itemHeight:Number;
		
		/**
		 * The base stroke thickness. */		
		private static const BASE_STROKE_THICKNESS:int = 2;
		/**
		 * The scaled stroke thickness. */		
		private var _strokeThickness:Number;
		
		/**
		 * Name of the trophy. */		
		private var _title:Label;
		
		/**
		 * The top stripe displayed in each item renderer. */		
		private var _topStripe:Quad;
		/**
		 * The bottom stripe only displayed in the last item renderer. */		
		private var _bottomStripe:Quad;
		/**
		 * The left stripe. */		
		private var _leftStripe:Quad;
		
		/**
		 * The background. */		
		private var _background:Quad;
		
		/**
		 * The background black border. */		
		private var _backgroundBorder:Quad;
		
		/**
		 * The global padding of the item renderer. */		
		private var _padding:int = 10;
		
		/**
		 * The exchange with cheque button. */		
		private var _exchangeWithChequeButton:ArrowGroup;
		
		/**
		 * The exchange with points button. */		
		private var _exchangeWithPointsButton:ArrowGroup;
		
		/**
		 * The background border width. */		
		private var _backgroundBorderWidth:int;
		
		/**
		 * The shadow. */		
		private var _shadow:Quad;
		
		public function GiftHistoryItemRenderer()
		{
			super();
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			_itemHeight = scaleAndRoundToDpi(BASE_HEIGHT);
			_strokeThickness = scaleAndRoundToDpi(BASE_STROKE_THICKNESS);
			_padding *= GlobalConfig.dpiScale;
			_backgroundBorderWidth = scaleAndRoundToDpi(40);
			
			this.width = GlobalConfig.stageWidth;
			//this.height = _itemHeight;
			
			_background = new Quad(this.width - _backgroundBorderWidth, _itemHeight, 0xf7f7f7);
			_background.x = _backgroundBorderWidth;
			addChild(_background);
			
			_leftStripe = new Quad(_strokeThickness, _itemHeight, 0xbfbfbf);
			_leftStripe.x = _backgroundBorderWidth;
			addChild(_leftStripe);
			
			_topStripe = new Quad(50, _strokeThickness, 0xbfbfbf);
			addChild(_topStripe);
			
			_bottomStripe = new Quad(50, _strokeThickness, 0xbfbfbf);
			_bottomStripe.visible = false;
			addChild(_bottomStripe);
			
			_backgroundBorder = new Quad(_backgroundBorderWidth, _itemHeight, 0x292929);
			addChild(_backgroundBorder);
			
			_shadow = new Quad(50, scaleAndRoundToDpi(12), 0x000000);
			_shadow.setVertexAlpha(0, 0.3);
			_shadow.setVertexAlpha(1, 0.3);
			_shadow.setVertexColor(2, 0xffffff);
			_shadow.setVertexAlpha(2, 0);
			_shadow.setVertexColor(3, 0xffffff);
			_shadow.setVertexAlpha(3, 0);
			addChild(_shadow);
			
			_title = new Label();
			addChild(_title);
			_title.textRendererProperties.textFormat = Theme.giftIRTitleTextFormat;
			
			_exchangeWithPointsButton = new ArrowGroup();
			_exchangeWithPointsButton.addEventListener(Event.TRIGGERED, onExchangeWithPoints);
			addChild(_exchangeWithPointsButton);
			
			_exchangeWithChequeButton = new ArrowGroup();
			_exchangeWithChequeButton.addEventListener(Event.TRIGGERED, onExchangeWithCheque);
			addChild(_exchangeWithChequeButton);
		}
		
		override protected function draw():void
		{
			const dataInvalid:Boolean = this.isInvalid(INVALIDATION_FLAG_DATA);
			const selectionInvalid:Boolean = this.isInvalid(INVALIDATION_FLAG_SELECTED);
			var sizeInvalid:Boolean = this.isInvalid(INVALIDATION_FLAG_SIZE);
			
			if(dataInvalid)
			{
				this.commitData();
			}
			
			sizeInvalid = this.autoSizeIfNeeded() || sizeInvalid;
			
			if(dataInvalid || sizeInvalid || dataInvalid)
			{
				this.layout();
			}
		}
		
		protected function autoSizeIfNeeded():Boolean
		{
			const needsWidth:Boolean = isNaN(this.explicitWidth);
			const needsHeight:Boolean = isNaN(this.explicitHeight);
			if(!needsWidth && !needsHeight)
			{
				return false;
			}
			_title.width = NaN;
			_title.height = NaN;
			_title.validate();
			var newWidth:Number = this.explicitWidth;
			if(needsWidth)
			{
				newWidth = _title.width;
			}
			var newHeight:Number = this.explicitHeight;
			if(needsHeight)
			{
				newHeight = _title.height;
			}
			return this.setSizeInternal(newWidth, newHeight, false);
		}
		
		protected function commitData():void
		{
			if(this._owner)
			{
				if( _data )
				{
					_title.visible = true;
					
					_title.text = formatString(Localizer.getInstance().translate("MY_GIFTS.FORMATTED_SENTENCE"), _data.hour, Utility.replaceCurrency(_data.description), _data.category, _data.status);
					
					_exchangeWithPointsButton.label = _data.exchangeableWithPoints;
					_exchangeWithChequeButton.label = Utility.replaceCurrency(_data.exchangeableWithCheque);
					
					_exchangeWithChequeButton.visible = _data.exchangeableWithCheque;
					_exchangeWithPointsButton.visible = _data.exchangeableWithPoints;
					
					_background.color = ((_itemIndex % 2) == 0) ? 0xf7f7f7 : 0xffffff;
				}
				else
				{
					_title.text = "";
				}
			}
			else
			{
				_title.visible = false;
			}
		}
		
		protected function layout():void
		{
			if( !_data )
				return;
			
			_topStripe.width = this.actualWidth;
			
			if( owner && _itemIndex == 0 )
			{
				_shadow.visible = true;
				_shadow.width = this.actualWidth;
			}
			else
			{
				_shadow.visible = false;
			}
			
			if( owner/* && owner.dataProvider && (owner.dataProvider.data.length - 1) == _groupIndex*/ && (owner.dataProvider.data[_groupIndex].children.length - 1) == _itemIndex)
			{
				_bottomStripe.visible = true;
				_bottomStripe.width = this.actualWidth;
			}
			else
			{
				
				_bottomStripe.visible = false;
			}
			
			_title.x = _backgroundBorder.width + _padding;
			_title.width = this.actualWidth - _backgroundBorder.width - _padding * 2;
			_title.validate();
			
			_exchangeWithPointsButton.validate();
			_exchangeWithChequeButton.validate();
			
			_background.height = _backgroundBorder.height = _leftStripe.height = Math.max( _itemHeight, (_title.height + scaleAndRoundToDpi(20) + (_data.exchangeableWithPoints ? _exchangeWithPointsButton.height : 0) + (_data.exchangeableWithCheque ? _exchangeWithChequeButton.height : 0)) );
			
			_title.y = _data.exchangeableWithPoints ? scaleAndRoundToDpi(10) : ((actualHeight - _title.height) * 0.5);
			
			_exchangeWithChequeButton.x = _exchangeWithPointsButton.x = _backgroundBorderWidth + _padding;
			
			_bottomStripe.y = this.actualHeight - _strokeThickness;
			_exchangeWithPointsButton.y = _title.y + _title.height;
			_exchangeWithChequeButton.y = _exchangeWithPointsButton.y + _exchangeWithPointsButton.height;
			
			setSize( actualWidth, _background.height );
		}
		
		protected var _data:GiftHistoryData;
		
		public function get data():Object
		{
			return this._data;
		}
		
		public function set data(value:Object):void
		{
			if(this._data == value)
			{
				return;
			}
			this._data = GiftHistoryData(value);
			this.invalidate(INVALIDATION_FLAG_DATA);
		}
		
		protected var _isSelected:Boolean;
		
		public function get isSelected():Boolean
		{
			return this._isSelected;
		}
		
		public function set isSelected(value:Boolean):void
		{
			if(this._isSelected == value)
			{
				return;
			}
			this._isSelected = value;
			this.invalidate(INVALIDATION_FLAG_SELECTED);
			this.dispatchEventWith(Event.CHANGE);
		}
		
		protected var _groupIndex:int = -1;
		
		public function get groupIndex():int
		{
			return this._groupIndex;
		}
		
		public function set groupIndex(value:int):void
		{
			this._groupIndex = value;
		}
		
		protected var _itemIndex:int = -1;
		
		public function get itemIndex():int
		{
			return this._itemIndex;
		}
		
		public function set itemIndex(value:int):void
		{
			this._itemIndex = value;
		}
		
		protected var _layoutIndex:int = -1;
		
		public function get layoutIndex():int
		{
			return this._layoutIndex;
		}
		
		public function set layoutIndex(value:int):void
		{
			this._layoutIndex = value;
		}
		
		protected var _owner:GroupedList;
		
		public function get owner():GroupedList
		{
			return GroupedList(this._owner);
		}
		
		public function set owner(value:GroupedList):void
		{
			if(this._owner == value)
			{
				return;
			}
			this._owner = value;
			this.invalidate(INVALIDATION_FLAG_DATA);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Handlers
//------------------------------------------------------------------------------------------------------------
		
		private function onExchangeWithCheque(event:Event):void
		{
			log("[GiftHistoryItemRender] Exchange gift with cheque");
			if( NativeAlertDialog.isSupported )
			{
				NativeAlertDialog.showAlert(Localizer.getInstance().translate("MY_GIFTS.EXCHANGE_CHEQUE_CONFIRM_ALERT_MESSAGE"), Localizer.getInstance().translate("MY_GIFTS.EXCHANGE_CONFIRM_ALERT_TITLE"), Vector.<String>([Localizer.getInstance().translate("COMMON.CANCEL"), Localizer.getInstance().translate("COMMON.CONFIRM")]), onAlertChequeClosed);
			}
			else
			{
				exchangeWithCheque();
			}
		}
		
		private function exchangeWithCheque():void
		{
			if( AirNetworkInfo.networkInfo.isConnected() )
			{
				InfoManager.show(Localizer.getInstance().translate("COMMON.LOADING"));
				Remote.getInstance().exchangeWithCheque( _data.giftId, _data.tableType, onExchangeSuccess, onExchangeFailure, onExchangeFailure, 1, AbstractEntryPoint.screenNavigator.activeScreenID);
			}
			else
			{
				InfoManager.showTimed(Localizer.getInstance().translate("COMMON.NOT_CONNECTED"), InfoManager.DEFAULT_DISPLAY_TIME, InfoContent.ICON_CROSS);
			}
		}
		
		private function onAlertChequeClosed(event:NativeDialogEvent):void
		{
			if( int(event.index) == 1 )
				exchangeWithCheque();
		}
		
		private function onExchangeWithPoints(event:Event):void
		{
			log("[GiftHistoryItemRender] Exchange gift with points");
			if( NativeAlertDialog.isSupported )
			{
				NativeAlertDialog.showAlert(Localizer.getInstance().translate("MY_GIFTS.EXCHANGE_POINTS_CONFIRM_ALERT_MESSAGE"), Localizer.getInstance().translate("MY_GIFTS.EXCHANGE_CONFIRM_ALERT_TITLE"), Vector.<String>([Localizer.getInstance().translate("COMMON.CANCEL"), Localizer.getInstance().translate("COMMON.CONFIRM")]), onAlertPointsClosed);
			}
			else
			{
				exchangeWithPoints();
			}
		}
		
		private function exchangeWithPoints():void
		{
			if( AirNetworkInfo.networkInfo.isConnected() )
			{
				InfoManager.show(Localizer.getInstance().translate("COMMON.LOADING"));
				Remote.getInstance().exchangeWithPoints( _data.giftId, _data.tableType, onExchangeSuccess, onExchangeFailure, onExchangeFailure, 1, AbstractEntryPoint.screenNavigator.activeScreenID);
			}
			else
			{
				InfoManager.showTimed(Localizer.getInstance().translate("COMMON.NOT_CONNECTED"), InfoManager.DEFAULT_DISPLAY_TIME, InfoContent.ICON_CROSS);
			}
		}
		
		private function onAlertPointsClosed(event:NativeDialogEvent):void
		{
			if( int(event.index) == 1 )
				exchangeWithPoints();
		}
		
		
		
		private function onExchangeSuccess(result:Object):void
		{
			switch(result.code)
			{
				case 0:
				case 2:
				{
					InfoManager.hide(result.txt, InfoContent.ICON_CROSS);
					break;
				}
				case 1: // ok
				{
					InfoManager.hide(result.txt, InfoContent.ICON_CHECK);
					owner.dispatchEventWith(LudoEventType.REFRESH_GIFTS_LIST);
					break;
				}
					
				default:
				{
					onExchangeFailure();
					break;
				}
			}
		}
		
		private function onExchangeFailure(error:Object = null):void
		{
			InfoManager.hide(Localizer.getInstance().translate("COMMON.QUERY_FAILURE"), InfoContent.ICON_CROSS, InfoManager.DEFAULT_DISPLAY_TIME);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
//------------------------------------------------------------------------------------------------------------
		
		override public function dispose():void
		{
			owner = null;
			
			_title.removeFromParent(true);
			_title = null;
			
			_topStripe.removeFromParent(true);
			_topStripe = null;
			
			_bottomStripe.removeFromParent(true);
			_bottomStripe = null;
			
			_background.removeFromParent(true);
			_background = null;
			
			_exchangeWithPointsButton.removeEventListener(Event.TRIGGERED, onExchangeWithPoints);
			_exchangeWithPointsButton.removeFromParent(true);
			_exchangeWithPointsButton = null;
			
			_exchangeWithChequeButton.removeEventListener(Event.TRIGGERED, onExchangeWithCheque);
			_exchangeWithChequeButton.removeFromParent(true);
			_exchangeWithChequeButton = null;
			
			_shadow.removeFromParent(true);
			_shadow = null;
			
			_data = null;
			
			super.dispose();
		}
	}
}