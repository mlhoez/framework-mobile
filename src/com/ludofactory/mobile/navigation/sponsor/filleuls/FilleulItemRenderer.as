/*
Copyright © 2006-2015 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 8 sept. 2013
*/
package com.ludofactory.mobile.navigation.sponsor.filleuls
{

	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.common.utils.log;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.notification.NotificationPopupManager;
	import com.ludofactory.mobile.core.notification.content.FilleulDetailNotificationContent;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.theme.Theme;

	import feathers.controls.ImageLoader;
	import feathers.controls.Label;
	import feathers.controls.List;
	import feathers.controls.renderers.IListItemRenderer;
	import feathers.core.FeathersControl;

	import flash.geom.Point;
	import flash.text.TextFormat;

	import starling.display.Quad;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;

	/**
	 * Item renderer used to display a contact with the ability to
	 * invite him / her individually.
	 */	
	public class FilleulItemRenderer extends FeathersControl implements IListItemRenderer
	{
		private static const HELPER_POINT:Point = new Point();
		private static const HELPER_TOUCHES_VECTOR:Vector.<Touch> = new <Touch>[];
		protected var touchPointID:int = -1;
		
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
		 * The global padding of the item renderer. */		
		private var _padding:int = 20;
		
		/**
		 * The background. */		
		private var _background:Quad;
		/**
		 * The top stripe displayed in each item renderer. */		
		private var _topStripe:Quad;
		/**
		 * The bottom stripe only displayed in the last item renderer. */		
		private var _bottomStripe:Quad;
		
		/**
		 * Name of the contact. */		
		private var _nameLabel:Label;
		/**
		 * The more icon. */		
		private var _moreIcon:ImageLoader;
		/**
		 * The state label. */		
		private var _stateLabel:Label;
		/**
		 * The state icon. */		
		private var _stateIcon:ImageLoader;
		
		public function FilleulItemRenderer()
		{
			super();
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			_itemHeight = scaleAndRoundToDpi(BASE_HEIGHT);
			_strokeThickness = scaleAndRoundToDpi(BASE_STROKE_THICKNESS);
			_padding *= GlobalConfig.dpiScale;
			
			this.width = GlobalConfig.stageWidth;
			this.height = _itemHeight;
			
			_background = new Quad(this.width, _itemHeight);
			_background.addEventListener(TouchEvent.TOUCH, onShowList);
			addChild(_background);
			
			_topStripe = new Quad(50, _strokeThickness, 0xbfbfbf);
			_topStripe.touchable = false;
			addChild(_topStripe);
			
			_bottomStripe = new Quad(50, _strokeThickness, 0xbfbfbf);
			_bottomStripe.touchable = false;
			_bottomStripe.visible = false;
			addChild(_bottomStripe);
			
			_nameLabel = new Label();
			_nameLabel.touchable = false;
			addChild(_nameLabel);
			_nameLabel.textRendererProperties.textFormat = Theme.filleulIRNameTextFormat;
			_nameLabel.textRendererProperties.wordWrap = false;
			
			_stateLabel = new Label();
			_stateLabel.touchable = false;
			addChild(_stateLabel);
			_stateLabel.textRendererProperties.wordWrap = false;
			
			_moreIcon = new ImageLoader();
			_moreIcon.touchable = false;
			_moreIcon.textureScale = GlobalConfig.dpiScale;
			_moreIcon.snapToPixels = true;
			addChild(_moreIcon);
			
			_stateIcon = new ImageLoader();
			_stateIcon.touchable = false;
			_stateIcon.snapToPixels = true;
			addChild(_stateIcon);
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
			_nameLabel.width = NaN;
			_nameLabel.height = NaN;
			_nameLabel.validate();
			var newWidth:Number = this.explicitWidth;
			if(needsWidth)
			{
				newWidth = _nameLabel.width;
			}
			var newHeight:Number = this.explicitHeight;
			if(needsHeight)
			{
				newHeight = _nameLabel.height;
			}
			return this.setSizeInternal(newWidth, newHeight, false);
		}
		
		protected function commitData():void
		{
			if(this._owner)
			{
				if( _data )
				{
					_nameLabel.visible = _stateLabel.visible = true;
					
					_nameLabel.text = _data.filleulName;
					
					log(_data.type);
					
					switch(_data.type)
					{
						case 0:
						{
							_stateIcon.source = AbstractEntryPoint.assets.getTexture("FilleulRefusedIcon");
							_moreIcon.source = AbstractEntryPoint.assets.getTexture("MoreRefusedIcon");
							_stateLabel.text = _("Refusé");
							TextFormat(_stateLabel.textRendererProperties.textFormat).color = 0xae1900;
							
							break;
						}
						case 1:
						{
							_stateIcon.source = AbstractEntryPoint.assets.getTexture("FilleulValidIcon");
							_moreIcon.source = AbstractEntryPoint.assets.getTexture("MoreValidIcon");
							_stateLabel.text = _("Validé");
							TextFormat(_stateLabel.textRendererProperties.textFormat).color = 0x43a01f;
							
							break;
						}
						case 2:
						{
							_stateIcon.source = AbstractEntryPoint.assets.getTexture("FilleulPendingIcon");
							_moreIcon.source = AbstractEntryPoint.assets.getTexture("MorePendingIcon");
							_stateLabel.text = _("En attente");
							TextFormat(_stateLabel.textRendererProperties.textFormat).color = 0x00a7d1;
							
							break;
						}
					}
				}
				else
				{
					_nameLabel.text = _stateLabel.text = "";
				}
			}
			else
			{
				_nameLabel.visible = _stateLabel.visible = false;
			}
		}
		
		protected function layout():void
		{
			_topStripe.width = this.actualWidth;
			
			if( this.owner && this.owner.dataProvider && (this.owner.dataProvider.length - 1) == _index )
			{
				_bottomStripe.visible = true;
				_bottomStripe.y = this.actualHeight - _strokeThickness;
				_bottomStripe.width = this.actualWidth;
			}
			else
			{
				_bottomStripe.visible = false;
			}
			
			
			_nameLabel.width = this.actualWidth - _padding;
			_nameLabel.validate();
			_nameLabel.y = (_itemHeight - _nameLabel.height) * 0.5;
			_nameLabel.x = _padding;
			
			_moreIcon.validate();
			_moreIcon.x = this.actualWidth - _moreIcon.width - _padding;
			_moreIcon.y = (_itemHeight - _moreIcon.height) * 0.5;
			
			_stateLabel.validate();
			_stateLabel.x = _moreIcon.x - _stateLabel.width - _padding;
			_stateLabel.y = (_itemHeight - _stateLabel.height) * 0.5;
			
			_stateIcon.validate();
			_stateIcon.x = _stateLabel.x - _stateIcon.width - _padding;
			_stateIcon.y = (_itemHeight - _stateIcon.height) * 0.5;
		}
//------------------------------------------------------------------------------------------------------------
//	Handlers
//------------------------------------------------------------------------------------------------------------
		
		/**
		 * Shows the contact elements list as a popup in order to allow
		 * the user to select to which email / phone number we will send
		 * the invitation (in case there are more than one element).
		 */		
		private function onShowList(event:TouchEvent):void
		{
			const touches:Vector.<Touch> = event.getTouches(this, null, HELPER_TOUCHES_VECTOR);
			if(touches.length == 0)
			{
				return;
			}
			if(this.touchPointID >= 0)
			{
				var touch:Touch;
				for each(var currentTouch:Touch in touches)
				{
					if(currentTouch.id == this.touchPointID)
					{
						touch = currentTouch;
						break;
					}
				}
				if(!touch)
				{
					HELPER_TOUCHES_VECTOR.length = 0;
					return;
				}
				if(touch.phase == TouchPhase.ENDED)
				{
					this.touchPointID = -1;
					
					touch.getLocation(this, HELPER_POINT);
					if(this.hitTest(HELPER_POINT, true) != null && !this._isSelected)
					{
						//NotificationManager.addNotification( new FilleulDetailNotification(_data) );
						NotificationPopupManager.addNotification( new FilleulDetailNotificationContent(_data) );
					}
				}
			}
			else
			{
				for each(touch in touches)
				{
					if(touch.phase == TouchPhase.BEGAN)
					{
						this.touchPointID = touch.id;
						break;
					}
				}
			}
			HELPER_TOUCHES_VECTOR.length = 0;
		}
		
		/**
		 * When the user scrolls whithin the parent, we need to clear
		 * the touch id so that this item events won't be triggered.
		 */		
		protected function onParentScroll(event:Event):void
		{
			this.touchPointID = -1;
		}
		
//------------------------------------------------------------------------------------------------------------
//	GET / SET
//------------------------------------------------------------------------------------------------------------
		
		protected var _data:FilleulData;
		
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
			this._data = FilleulData(value);
			this.invalidate(INVALIDATION_FLAG_DATA);
		}
		
		protected var _index:int = -1;
		
		public function get index():int
		{
			return this._index;
		}
		
		public function set index(value:int):void
		{
			if(this._index == value)
			{
				return;
			}
			this._index = value;
			this.invalidate(INVALIDATION_FLAG_DATA);
		}
		
		protected var _owner:List;
		
		public function get owner():List
		{
			return List(this._owner);
		}
		
		public function set owner(value:List):void
		{
			if(this._owner == value)
			{
				return;
			}
			if(this._owner)
			{
				this._owner.removeEventListener(Event.SCROLL, onParentScroll);
			}
			this._owner = value;
			if(this._owner)
			{
				this._owner.addEventListener(Event.SCROLL, onParentScroll);
			}
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
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
//------------------------------------------------------------------------------------------------------------
		
		override public function dispose():void
		{
			if( _owner )
				_owner.removeEventListener(Event.SCROLL, onParentScroll);
			
			_background.removeEventListener(TouchEvent.TOUCH, onShowList);
			_background.removeFromParent(true);
			_background = null;
			
			_topStripe.removeFromParent(true);
			_topStripe = null;
			
			_bottomStripe.removeFromParent(true);
			_bottomStripe = null;
			
			_nameLabel.removeFromParent(true);
			_nameLabel = null;
			
			_moreIcon.removeFromParent(true);
			_moreIcon = null;
			
			_stateIcon.removeFromParent(true);
			_stateIcon = null;
			
			_stateLabel.removeFromParent(true);
			_stateLabel = null;
			
			_data = null;
			
			super.dispose();
		}
	}
}