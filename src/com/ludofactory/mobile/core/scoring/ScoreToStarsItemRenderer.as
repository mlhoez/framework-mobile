/*
Copyright © 2006-2015 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 26 juil. 2013
*/
package com.ludofactory.mobile.core.scoring
{
	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.common.utils.Utilities;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import feathers.controls.Label;
	import feathers.controls.List;
	import feathers.controls.renderers.IListItemRenderer;
	import feathers.core.FeathersControl;
	
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.QuadBatch;
	import starling.display.Sprite;
	import starling.events.Event;
	
	public class ScoreToStarsItemRenderer extends FeathersControl implements IListItemRenderer
	{
		private const BASE_HEIGHT:int = 48;
		private var _itemHeight:Number;
		
		private const BASE_STROKE_THICKNESS:int = 2;
		private var _strokeThickness:Number;
		
		private static var _textWidth:Number;
		
		private var _elementsPositioned:Boolean;
		
		private var _idleContainer:Sprite;
		private var _idleQuadBatch:QuadBatch;
		private var _level:Label;
		private var _pointsWithCredits:Label;
		
		private var _starIcon:Image;
		
		public function ScoreToStarsItemRenderer()
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
			_textWidth = GlobalConfig.stageWidth * 0.5;
			
			this.width = GlobalConfig.stageWidth;
			this.height = _itemHeight;
			
			// idle
			_idleContainer = new Sprite();
			addChild(_idleContainer);
			
			_idleQuadBatch = new QuadBatch();
			const background:Quad = new Quad( _textWidth, _itemHeight, 0xfbfbfb );
			_idleQuadBatch.addQuad( background );
			background.x = _textWidth;
			background.color = 0xeeeeee;
			_idleQuadBatch.addQuad( background );
			background.x = 0;
			background.y = _itemHeight - _strokeThickness;
			background.width  = _textWidth * 2;
			background.height = _strokeThickness;
			background.color  = 0xbfbfbf;
			_idleQuadBatch.addQuad( background );
			_idleContainer.addChild( _idleQuadBatch );
			
			_level = new Label();
			_level.text = "999999";
			_idleContainer.addChild(_level);
			_level.textRendererProperties.textFormat = Theme.scoreToPointsIRTextFormat;
			
			_pointsWithCredits = new Label();
			_pointsWithCredits.text = "999999";
			_idleContainer.addChild(_pointsWithCredits);
			_pointsWithCredits.textRendererProperties.textFormat = Theme.scoreToPointsIRTextFormat;
			
			_starIcon = new Image( AbstractEntryPoint.assets.getTexture("ruby") );
			_starIcon.scaleX = _starIcon.scaleY = (GlobalConfig.dpiScale - 0.4) < 0.3 ? 0.3 : (GlobalConfig.dpiScale - 0.4);
			addChild(_starIcon);
		}
		
		override protected function draw():void
		{
			const dataInvalid:Boolean = this.isInvalid(INVALIDATION_FLAG_DATA);
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
			_level.width = NaN;
			_level.height = NaN;
			_level.validate();
			var newWidth:Number = this.explicitWidth;
			if(needsWidth)
			{
				newWidth = _level.width;
				newWidth += this._paddingLeft + this._paddingRight;
			}
			var newHeight:Number = this.explicitHeight;
			if(needsHeight)
			{
				newHeight = _level.height;
			}
			return this.setSizeInternal(newWidth, newHeight, false);
		}
		
		protected function commitData():void
		{
			if(this._owner)
			{
				if( _data )
				{
					if( _isFirstItem )
					{
						_level.text = "< " +  Utilities.splitThousands( (_data.sup + 1) );
					}
					else if( _isLastItem )
					{
						_level.text = "> " + Utilities.splitThousands( (_data.inf - 1) );
					}
					else
					{
						_level.text = Utilities.splitThousands( _data.inf ) + " " + _("à") + " " + Utilities.splitThousands( _data.sup );
					}
					
					_pointsWithCredits.text = Utilities.splitThousands( _data.stars ); 
				}
				else
				{
					_idleContainer.visible = false;
				}
			}
			else
			{
				_idleContainer.visible = false;
			}
		}
		
		protected function layout():void
		{
			if( !_elementsPositioned )
			{
				_level.width = _pointsWithCredits.width = _textWidth;
				
				_pointsWithCredits.x = _textWidth;
				
				_level.validate();
				_level.y = _pointsWithCredits.y = (_itemHeight - _level.height) * 0.5;
				
				_starIcon.x = _textWidth + (_textWidth * 0.5) + scaleAndRoundToDpi(25);
				_starIcon.y = (actualHeight - _starIcon.height) * 0.5;
				
				_elementsPositioned = true;
			}
		}
		
		protected var _data:ScoreToStarsData;
		
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
			this._data = ScoreToStarsData(value);
			this.invalidate(INVALIDATION_FLAG_DATA);
		}
		
		protected var _index:int = -1;
		
		public function get index():int
		{
			return this._index;
		}
		
		public function set index(value:int):void
		{
			this._index = value;
			if(this._owner && this._owner.dataProvider)
			{
				this.isLastItem = this._index == this._owner.dataProvider.length - 1;
			}
			this.isFirstItem = this._index == 0;
		}
		
		protected var _isFirstItem:Boolean = false;
		
		public function get isFirstItem():Boolean
		{
			return this._isFirstItem;
		}
		
		public function set isFirstItem(value:Boolean):void
		{
			if(this._isFirstItem == value)
			{
				return;
			}
			this._isFirstItem = value;
			this.invalidate(INVALIDATION_FLAG_SELECTED);
		}
		
		protected var _isLastItem:Boolean = false;
		
		public function get isLastItem():Boolean
		{
			return this._isLastItem;
		}
		
		public function set isLastItem(value:Boolean):void
		{
			if(this._isLastItem == value)
			{
				return;
			}
			this._isLastItem = value;
			this.invalidate(INVALIDATION_FLAG_SELECTED);
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
			if(this._owner && this._owner.dataProvider)
			{
				this.isLastItem = this._index == this._owner.dataProvider.length - 1;
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
			_idleQuadBatch.reset();
			_idleQuadBatch.removeFromParent(true);
			_idleQuadBatch = null;
			
			_pointsWithCredits.removeFromParent(true);
			_pointsWithCredits = null;
			
			_level.removeFromParent(true);
			_level = null;
			
			_idleContainer.removeFromParent(true);
			_idleContainer = null;
			
			super.dispose();
		}
	}
}