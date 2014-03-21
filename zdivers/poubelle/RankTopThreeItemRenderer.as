/*
LudoFactory
Framework mobile
Author  : Maxime Lhoez
Created : 8 sept. 2013
*/
package com.ludofactory.mobile.tournament.listing
{
	import com.ludofactory.mobile.core.theme.Theme;
	import com.ludofactory.mobile.utils.Utility;
	import com.ludofactory.mobile.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.utils.scaleToDpi;
	
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import app.AppEntryPoint;
	import app.config.Config;
	
	import feathers.controls.Label;
	import feathers.controls.List;
	import feathers.controls.renderers.IListItemRenderer;
	import feathers.core.FeathersControl;
	
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.QuadBatch;
	import starling.events.Event;
	
	/**
	 * Item renderer used to display the customer service messages.
	 */	
	public class RankTopThreeItemRenderer extends FeathersControl implements IListItemRenderer
	{
		/**
		 * The base height of a line in the list. */		
		private static const BASE_HEIGHT:int = 104;
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
		 * the user rank. */		
		private var _rank:Label;
		/**
		 * The user name. */		
		private var _name:Label;
		/**
		 * The number of stars. */		
		private var _stars:Label;
		/**
		 * Star image. */		
		private var _star:Image;
		
		/**
		 * The top stripe displayed on a side. */		
		private var _sideStripe:Quad;
		/**
		 * The bottom stripe only displayed in the last item renderer. */		
		private var _bottomStripe:Quad;
		
		/**
		 * The gradient background. */		
		private var _background:QuadBatch;
		
		public function RankTopThreeItemRenderer()
		{
			super();
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			_itemHeight = scaleToDpi( BASE_HEIGHT * (Config.isPhone ? 1:1.25) );
			_strokeThickness = scaleToDpi(BASE_STROKE_THICKNESS);
			
			this.width = GlobalConfig.stageWidth / 3;
			this.height = _itemHeight;
			
			_background = new QuadBatch();
			addChild(_background);
			
			const quad:Quad = new Quad(50, _itemHeight, 0xfffc00);
			quad.setVertexColor(2, 0xffc000);
			quad.setVertexColor(3, 0xffc000);
			_background.addQuad( quad );
			
			quad.height = scaleToDpi(12);
			quad.setVertexColor(0, 0x000000);
			quad.setVertexAlpha(0, 0.1);
			quad.setVertexColor(1, 0x000000);
			quad.setVertexAlpha(1, 0.1);
			quad.setVertexColor(2, 0xfffc00);
			quad.setVertexAlpha(2, 0);
			quad.setVertexColor(3, 0xfffc00);
			quad.setVertexAlpha(3, 0);
			_background.addQuad( quad );
			
			_sideStripe = new Quad(_strokeThickness, _itemHeight, 0xf8b100);
			_sideStripe.alpha = 0.25;
			_sideStripe.visible = false;
			addChild(_sideStripe);
			
			_bottomStripe = new Quad(50, _strokeThickness, 0x401800);
			addChild(_bottomStripe);
			
			_rank = new Label();
			addChild(_rank);
			_rank.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA_ONE, scaleAndRoundToDpi(46), 0xffa100, null, null, null, null, null, TextFormatAlign.CENTER);
			_rank.textRendererProperties.wordWrap = false;
			
			_name = new Label();
			addChild(_name);
			_name.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA_ONE, scaleAndRoundToDpi(24), 0x401800);
			_name.textRendererProperties.wordWrap = false;
			
			_stars = new Label();
			addChild(_stars);
			_stars.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA_ONE, scaleAndRoundToDpi(24), 0x401800);
			_stars.textRendererProperties.wordWrap = false;
			
			_star = new Image( AbstractEntryPoint.assets.getTexture("star-brown-icon") );
			_star.scaleX = _star.scaleY = Config.dpiScalez;
			addChild(_star);
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
			_rank.width = NaN;
			_rank.height = NaN;
			_rank.validate();
			var newWidth:Number = this.explicitWidth;
			if(needsWidth)
			{
				newWidth = _rank.width;
			}
			var newHeight:Number = this.explicitHeight;
			if(needsHeight)
			{
				newHeight = _rank.height;
			}
			return this.setSizeInternal(newWidth, newHeight, false);
		}
		
		protected function commitData():void
		{
			if(this._owner)
			{
				if( _data )
				{
					_rank.visible = _name.visible = _stars.visible = true;
					
					_rank.text = String(_data.rank);
					_name.text = _data.pseudo;
					_stars.text = Utility.splitThousands(_data.stars);
				}
				else
				{
					_rank.text = _name.text = _stars.text = "";
				}
			}
			else
			{
				_rank.visible = _name.visible = _stars.visible = false;
			}
		}
		
		protected function layout():void
		{
			_background.width = this.actualWidth;
			
			_bottomStripe.y = this.actualHeight - _strokeThickness;
			_bottomStripe.width = this.actualWidth;
			
			if( this.owner && this.owner.dataProvider && (this.owner.dataProvider.length - 1) == _index )
			{
				_sideStripe.visible = false;
			}
			else
			{
				_sideStripe.visible = true;
				_sideStripe.x = this.actualWidth - _strokeThickness;
			}
			
			_rank.width = this.actualWidth * 0.2;
			_rank.validate();
			_rank.y = (_itemHeight - _rank.height) * 0.5;
			
			_name.width = this.actualWidth * 0.8;
			_name.x = _rank.width;
			_name.validate();
			_name.y = (_itemHeight * 0.5) - _name.height;
			
			_stars.validate();
			_stars.x = _rank.width;
			_stars.y = _itemHeight * 0.5;
			
			_star.y = _stars.y + (_stars.height - _star.height) * 0.5;
			_star.x = _stars.x + _stars.width + scaleToDpi(5);
		}
		
		protected var _data:RankData;
		
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
			this._data = RankData(value);
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
		
		private var _isSelected:Boolean;
		
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
			
			_rank.removeFromParent(true);
			_rank = null;
			
			_stars.removeFromParent(true);
			_stars = null;
			
			_name.removeFromParent(true);
			_name = null;
			
			_sideStripe.removeFromParent(true);
			_sideStripe = null;
			
			_bottomStripe.removeFromParent(true);
			_bottomStripe = null;
			
			_star.removeFromParent(true);
			_star = null;
			
			_data = null;
			
			super.dispose();
		}
	}
}