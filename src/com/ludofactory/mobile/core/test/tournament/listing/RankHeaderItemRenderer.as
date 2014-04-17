/*
Copyright © 2006-2014 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 14 oct. 2013
*/
package com.ludofactory.mobile.core.test.tournament.listing
{
	import com.ludofactory.common.utils.Utilities;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.test.config.GlobalConfig;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import feathers.controls.GroupedList;
	import feathers.controls.ImageLoader;
	import feathers.controls.Label;
	import feathers.controls.renderers.IGroupedListHeaderOrFooterRenderer;
	import feathers.core.FeathersControl;
	
	import starling.display.Quad;
	import starling.display.QuadBatch;
	import starling.events.Event;
	
	/**
	 * Item renderer used to display the header in the tournaments ranking list.
	 */	
	public class RankHeaderItemRenderer extends FeathersControl implements IGroupedListHeaderOrFooterRenderer
	{
		/**
		 * The base height of a line in the list. */		
		private static const BASE_HEIGHT:int = 60;
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
		 * The background. */		
		private var _backgroundFirst:QuadBatch;
		/**
		 * The background. */		
		private var _backgroundSecond:QuadBatch;
		/**
		 * The background. */		
		private var _backgroundThird:QuadBatch;
		/**
		 * The background. */		
		private var _background:QuadBatch;
		
		
		/**
		 * Name of the current gift. */		
		private var _title:Label;
		
		private var _medal:ImageLoader;
		
		public function RankHeaderItemRenderer()
		{
			super();
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			_itemHeight = scaleAndRoundToDpi(BASE_HEIGHT);
			_strokeThickness = scaleAndRoundToDpi(BASE_STROKE_THICKNESS);
			
			this.width = GlobalConfig.stageWidth;
			this.height = _itemHeight;
			
			var background:Quad;
			
			// Version 1 couleur
			/*_background = new QuadBatch();
			addChild(_background);
			
			var background:Quad = new Quad( this.actualWidth, _itemHeight, 0xffdd00 );
			_background.addQuad( background );
			
			background.setVertexColor(0, 0xffc313);
			background.setVertexColor(1, 0xffc313);
			background.setVertexColor(2, 0xffdd00);
			background.setVertexColor(3, 0xffdd00);
			_background.addQuad( background );
			
			background.color = 0xbfbfbf;
			background.height = _strokeThickness;
			background.y = _itemHeight - _strokeThickness;
			_background.addQuad( background );*/
			
			// Version plusieurs couleurs
			// background
			_backgroundFirst = new QuadBatch();
			_backgroundFirst.visible = false;
			addChild(_backgroundFirst);
			
			background = new Quad( this.actualWidth, _itemHeight, 0xffdd00 );
			_backgroundFirst.addQuad( background );
			
			background.setVertexColor(0, 0xffc313);
			background.setVertexColor(1, 0xffc313);
			background.setVertexColor(2, 0xffdd00);
			background.setVertexColor(3, 0xffdd00);
			_backgroundFirst.addQuad( background );
			
			// second
			_backgroundSecond = new QuadBatch();
			_backgroundSecond.visible = false;
			addChild(_backgroundSecond);
			
			background = new Quad( this.actualWidth, _itemHeight, 0xffdd00 );
			_backgroundSecond.addQuad( background );
			
			background.setVertexColor(0, 0x7e7e7e);
			background.setVertexColor(1, 0x7e7e7e);
			background.setVertexColor(2, 0xdbdbdb);
			background.setVertexColor(3, 0xdbdbdb);
			_backgroundSecond.addQuad( background );
			
			// third
			_backgroundThird = new QuadBatch();
			_backgroundThird.visible = false;
			addChild(_backgroundThird);
			
			background = new Quad( this.actualWidth, _itemHeight, 0xffdd00 );
			_backgroundThird.addQuad( background );
			
			background.setVertexColor(0, 0xa74b2a);
			background.setVertexColor(1, 0xa74b2a);
			background.setVertexColor(2, 0xde846d);
			background.setVertexColor(3, 0xde846d);
			_backgroundThird.addQuad( background );
			
			// common
			_background = new QuadBatch();
			_background.visible = false;
			addChild(_background);
			
			background = new Quad( this.actualWidth, _itemHeight, 0xffdd00 );
			_background.addQuad( background );
			
			background.setVertexColor(0, 0x01c6f5);
			background.setVertexColor(1, 0x01c6f5);
			background.setVertexColor(2, 0xb6f1ff);
			background.setVertexColor(3, 0xb6f1ff);
			_background.addQuad( background );
			
			// common stroke
			background.color = 0xbfbfbf;
			background.height = _strokeThickness;
			background.y = _itemHeight - _strokeThickness;
			_backgroundFirst.addQuad( background );
			_backgroundSecond.addQuad( background );
			_backgroundThird.addQuad( background );
			_background.addQuad( background );
			
			// we don't need this anymore
			background.dispose();
			background = null;
			
			_title = new Label();
			addChild(_title);
			_title.textRendererProperties.textFormat = Theme.rankHeaderIRTextFormat;
			_title.textRendererProperties.wordWrap = false;
			
			_medal = new ImageLoader();
			//_medal.scaleX = _medal.scaleY = GlobalConfig.dpiScalez;
			_medal.snapToPixels = true;
			addChild(_medal);
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
					
					_title.text = Utilities.replaceCurrency(String(_data));
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
			/*_title.width = this.actualWidth;
			_title.validate();
			_title.y = (_itemHeight - _title.height) * 0.5;*/
			
			_title.x = scaleAndRoundToDpi(20);
			_title.validate();
			_title.y = (_itemHeight - _title.height) * 0.5;
			
			// Commenter ça pour supprimer la différenciation ds couleurs des headers.
				_backgroundFirst.visible = _backgroundSecond.visible = _backgroundThird.visible = _background.visible = false;
				//log("group index = " + _groupIndex);
				if( _data )
				{
					if( RankHeaderData(_data).indice == 1 )
					{
						_medal.source = AbstractEntryPoint.assets.getTexture("gold-medal-small");
						_backgroundFirst.visible = true;
					}
					else if( RankHeaderData(_data).indice == 2 )
					{
						_medal.source = AbstractEntryPoint.assets.getTexture("silver-medal-small");
						_backgroundSecond.visible = true;
					}
					else if( RankHeaderData(_data).indice == 3 )
					{
						_medal.source = AbstractEntryPoint.assets.getTexture("bronze-medal-small");
						_backgroundThird.visible = true;
					}
					else
					{
						_medal.source = null;
						_background.visible = true;
					}
				}
				
			_medal.x = scaleAndRoundToDpi(10);
			_medal.height = actualHeight * 0.9;
			_medal.validate();
			
			_title.x = _medal.x + _medal.width + scaleAndRoundToDpi(10);
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
			this._data = value;
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
//	Dispose
//------------------------------------------------------------------------------------------------------------
		
		override public function dispose():void
		{
			owner = null;
			
			_title.removeFromParent(true);
			_title = null;
			
			_background.reset();
			_background.removeFromParent(true);
			_background = null;
			
			_data = null;
			
			super.dispose();
		}
	}
}