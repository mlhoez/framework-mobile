/*
Copyright © 2006-2014 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 14 oct. 2013
*/
package com.ludofactory.mobile.core.navigation.sponsor.filleuls
{
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import flash.text.TextFormat;
	
	import feathers.controls.Label;
	import feathers.controls.List;
	import feathers.controls.renderers.IListItemRenderer;
	import feathers.core.FeathersControl;
	
	import starling.display.Image;
	import starling.events.Event;
	
	public class FilleulRewardItemRenderer extends FeathersControl implements IListItemRenderer
	{
		private const BASE_HEIGHT:int = 48;
		private var _itemHeight:Number;
		
		private const BASE_STROKE_THICKNESS:int = 2;
		private var _strokeThickness:Number;
		
		private static var _textWidth:Number;
		
		private var _elementsPositioned:Boolean;
		
		
		private var _stateIcon:Image;
		private var _rewardLabel:Label;
		private var _rewardDate:Label;
		
		private var _isWon:Boolean;
		
		public function FilleulRewardItemRenderer()
		{
			super();
			this.touchable = false;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			_elementsPositioned = false;
			
			_itemHeight = scaleAndRoundToDpi(BASE_HEIGHT);
			_strokeThickness = scaleAndRoundToDpi(BASE_STROKE_THICKNESS);
			
			this.height = _itemHeight;
			
			_stateIcon = new Image( AbstractEntryPoint.assets.getTexture("filleul-reward-check-icon") );
			_stateIcon.scaleX = _stateIcon.scaleY = GlobalConfig.dpiScale;
			addChild(_stateIcon);
			
			_rewardLabel = new Label();
			_rewardLabel.text = "999999";
			addChild(_rewardLabel);
			_rewardLabel.textRendererProperties.textFormat = Theme.filleulRewardIRTextFormat;
			
			_rewardDate = new Label();
			_rewardDate.text = "999999";
			addChild(_rewardDate);
			_rewardDate.textRendererProperties.textFormat = Theme.filleulRewardIRTextFormat;
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
			
			if(dataInvalid || sizeInvalid)
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
			_rewardLabel.width = NaN;
			_rewardLabel.height = NaN;
			_rewardLabel.validate();
			var newWidth:Number = this.explicitWidth;
			if(needsWidth)
			{
				newWidth = _rewardLabel.width;
				newWidth += this._paddingLeft + this._paddingRight;
			}
			var newHeight:Number = this.explicitHeight;
			if(needsHeight)
			{
				newHeight = _rewardLabel.height;
			}
			return this.setSizeInternal(newWidth, newHeight, false);
		}
		
		protected function commitData():void
		{
			if(this._owner)
			{
				if( _data )
				{
					_isWon = _data.date == "-" ? false : true;
					
					_stateIcon.visible = _isWon;
					
					_rewardLabel.text = _data.reward;
					_rewardDate.text = _data.date;
					
					if( _isWon )
					{
						TextFormat(_rewardLabel.textRendererProperties.textFormat).color = Theme.COLOR_ORANGE;
						TextFormat(_rewardDate.textRendererProperties.textFormat).color = Theme.COLOR_ORANGE;
					}
				}
				else
				{
					
				}
			}
			else
			{
				
			}
		}
		
		protected function layout():void
		{
			_rewardLabel.width = _rewardDate.width = (actualWidth - _stateIcon.width) * 0.5;
			
			_rewardLabel.x = _stateIcon.width + scaleAndRoundToDpi(10);
			_rewardDate.x = _rewardLabel.x + _rewardLabel.width;
			
			_rewardLabel.validate();
			_rewardDate.validate();
			
			_rewardDate.y = _rewardLabel.y = (_itemHeight - _rewardDate.height) * 0.5;
			_stateIcon.y = (_itemHeight - _stateIcon.height) * 0.5;
		}
		
		protected var _data:Object;
		
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
			this._data = Object(value);
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
			this._owner = value;
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
		
		protected var _paddingTop:Number = 0;
		
		public function get paddingTop():Number
		{
			return this._paddingTop;
		}
		
		public function set paddingTop(value:Number):void
		{
			if(this._paddingTop == value)
			{
				return;
			}
			this._paddingTop = value;
			this.invalidate(INVALIDATION_FLAG_STYLES);
		}
		
		protected var _paddingRight:Number = 0;
		
		public function get paddingRight():Number
		{
			return this._paddingRight;
		}
		
		public function set paddingRight(value:Number):void
		{
			if(this._paddingRight == value)
			{
				return;
			}
			this._paddingRight = value;
			this.invalidate(INVALIDATION_FLAG_STYLES);
		}
		
		protected var _paddingBottom:Number = 0;
		
		public function get paddingBottom():Number
		{
			return this._paddingBottom;
		}
		
		public function set paddingBottom(value:Number):void
		{
			if(this._paddingBottom == value)
			{
				return;
			}
			this._paddingBottom = value;
			this.invalidate(INVALIDATION_FLAG_STYLES);
		}
		
		protected var _paddingLeft:Number = 0;
		
		public function get paddingLeft():Number
		{
			return this._paddingLeft;
		}
		
		public function set paddingLeft(value:Number):void
		{
			if(this._paddingLeft == value)
			{
				return;
			}
			this._paddingLeft = value;
			this.invalidate(INVALIDATION_FLAG_STYLES);
		}
		
		override public function dispose():void
		{
			_rewardDate.removeFromParent(true);
			_rewardDate = null;
			
			_rewardLabel.removeFromParent(true);
			_rewardLabel = null;
			
			_stateIcon.removeFromParent(true);
			_stateIcon = null;
			
			super.dispose();
		}
	}
}