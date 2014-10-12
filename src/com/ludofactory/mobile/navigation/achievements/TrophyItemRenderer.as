/*
Copyright © 2006-2014 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 31 août 2013
*/
package com.ludofactory.mobile.navigation.achievements
{
	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import feathers.controls.ImageLoader;
	import feathers.controls.Label;
	import feathers.controls.List;
	import feathers.controls.renderers.IListItemRenderer;
	import feathers.core.FeathersControl;
	
	import starling.display.Image;
	import starling.display.Quad;
	import starling.events.Event;
	import starling.utils.HAlign;
	import starling.utils.VAlign;
	import starling.utils.deg2rad;
	
	/**
	 * Item renderer used to display the customer service messages.
	 */	
	public class TrophyItemRenderer extends FeathersControl implements IListItemRenderer
	{
		/**
		 * The base height of a line in the list. */		
		private static const BASE_HEIGHT:int = 170;
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
		 * The description of the trophy. */		
		private var _message:Label;
		/**
		 * The reward of the trophy. */		
		private var _reward:Label;
		
		private var _titleBackground:Quad;
		
		/**
		 * The top stripe displayed in each item renderer. */		
		private var _topStripe:Quad;
		/**
		 * The bottom stripe only displayed in the last item renderer. */		
		private var _bottomStripe:Quad;
		
		/**
		 * The gradient displayed when the trophy is owned. */		
		private var _obtainedGradient:Quad;
		
		/**
		 * The background. */		
		private var _background:Quad;
		
		/**
		 * The label displayed on the top right corner when the trophy is owned. */		
		private var _ownedLabelImage:Image;
		
		/**
		 * The ownled label. */		
		private var _ownedLabel:Label;
		
		/**
		 * Highlights */		
		private var _highlights:Image;
		
		/**
		 * The trophy image. */		
		private var _trophyImage:ImageLoader;
		
		/**
		 * The global padding of the item renderer. */		
		private var _padding:int = 10;
		
		private var _highlightImage:Image
		
		public function TrophyItemRenderer()
		{
			super();
			touchable = false;
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
			addChild(_background);
			
			_obtainedGradient = new Quad(scaleAndRoundToDpi(186), _itemHeight, 0xff0000);
			addChild(_obtainedGradient);
			
			_topStripe = new Quad(50, _strokeThickness, 0xbfbfbf);
			addChild(_topStripe);
			
			_highlights.width = _obtainedGradient.width;
			_highlights.height = _obtainedGradient.height;
			addChild(_highlights);
			
			_bottomStripe = new Quad(50, _strokeThickness, 0xbfbfbf);
			_bottomStripe.visible = false;
			addChild(_bottomStripe);
			
			_titleBackground = new Quad(50, scaleAndRoundToDpi(34));
			_titleBackground.setVertexColor(0, 0x292929);
			_titleBackground.setVertexColor(1, 0x4d4d4d);
			_titleBackground.setVertexColor(2, 0x292929);
			_titleBackground.setVertexColor(3, 0x4d4d4d);
			addChild(_titleBackground);
			
			_title = new Label();
			addChild(_title);
			_title.textRendererProperties.textFormat = Theme.trophyIRTitleTF;
			
			_message = new Label();
			addChild(_message);
			_message.textRendererProperties.textFormat = Theme.trophyIRMessageTF;
			
			_reward = new Label();
			addChild(_reward);
			_reward.textRendererProperties.textFormat = Theme.trophyIRRewardTF;
			
			addChild(_ownedLabelImage);
			
			_trophyImage = new ImageLoader();
			_trophyImage.snapToPixels = true;
			addChild(_trophyImage);
			
			_ownedLabel = new Label();
			_ownedLabel.text = _("Obtenue");
			addChild(_ownedLabel);
			_ownedLabel.textRendererProperties.textFormat = Theme.trophyIROwnedTF;
			_ownedLabel.textRendererProperties.wordWrap = false;
			_ownedLabel.validate();
			_ownedLabel.alignPivot(HAlign.LEFT, VAlign.BOTTOM);
			_ownedLabel.rotation = deg2rad(30);
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
					_title.visible = _message.visible = _reward.visible = true;
					
					_title.text = _data.title;
					_message.text = _data.description;
					_reward.text = _data.reward;
					_trophyImage.source = AbstractEntryPoint.assets.getTexture(_data.textureName);
					
					if( TrophyManager.getInstance().canWinTrophy( _data.id ) )
					{
						//TweenMax.killTweensOf(_highlights);
						
						_trophyImage.color = 0x8F8F8F;
						_trophyImage.alpha = 0.8;
						_highlights.color = 0xffffff;
						
						// FIXME Essayer ça :
						/*
							var fil:ColorMatrixFilter = new ColorMatrixFilter();
							_tournamentButton.filter = fil;
							fil.adjustSaturation( -1 );
							fil.adjustBrightness( -0.3 );
						*/
						
						_ownedLabelImage.visible = false;
						_ownedLabel.visible = false;
						
						_obtainedGradient.setVertexColor(0, 0xe7e7e7);
						_obtainedGradient.setVertexColor(1, 0xe7e7e7);
						_obtainedGradient.setVertexColor(2, 0x919191);
						_obtainedGradient.setVertexColor(3, 0x919191);
						
						_reward.textRendererProperties.textFormat = Theme.trophyIRRewardOwnedTF;
					}
					else
					{
						//_highlights.alpha = 1;
						//TweenMax.to(_highlights, 0.75, { alpha: 0.15, repeat:-1, yoyo:true, ease:Linear.easeNone });
						
						_trophyImage.color = 0xffffff;
						_trophyImage.alpha = 1;
						_highlights.color = 0xfff000;
						
						_ownedLabelImage.visible = true;
						_ownedLabel.visible = true;
						
						_obtainedGradient.setVertexColor(0, 0xb5e404);
						_obtainedGradient.setVertexColor(1, 0xb5e404);
						_obtainedGradient.setVertexColor(2, 0x2a6514);
						_obtainedGradient.setVertexColor(3, 0x2a6514);
						
						_reward.textRendererProperties.textFormat = Theme.trophyIRRewardTF;
					}
				}
				else
				{
					_title.text = _message.text = _reward.text = "";
				}
			}
			else
			{
				_title.visible = _message.visible = _reward.visible = false;
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
			
			_highlights.height = _obtainedGradient.height - _strokeThickness;
			_highlights.y = _strokeThickness;
			
			_trophyImage.width = actualWidth * 0.7;
			_trophyImage.height = actualHeight * 0.7;
			_trophyImage.validate();
			_trophyImage.x = (_obtainedGradient.width - _trophyImage.width) * 0.5;
			_trophyImage.y = (_obtainedGradient.height - _trophyImage.height) * 0.5;
			
			//_title.y = _strokeThickness;
			_title.x = _obtainedGradient.width + _padding;
			_title.width = this.actualWidth - _obtainedGradient.width - _padding * 2;
			_title.validate();
			
			_titleBackground.x = _title.x - _padding * 0.5;
			_titleBackground.width = actualWidth - _titleBackground.x;
			_titleBackground.y = (_title.height - _titleBackground.height) * 0.5;
			
			_message.width = this.actualWidth - _obtainedGradient.width - _padding * 2;
			_message.x = _obtainedGradient.width + _padding;
			_message.validate();
			_message.y = (actualHeight - _message.height) * 0.5;
			
			_reward.width = this.actualWidth - _obtainedGradient.width - _padding * 2;
			_reward.x = _obtainedGradient.width + _padding;
			_reward.validate();
			_reward.y = actualHeight - _strokeThickness - _reward.height;
			
			_ownedLabelImage.x = this.actualWidth - _ownedLabelImage.width;
			_ownedLabelImage.y = 0 /* _strokeThickness */; // avant que " = _strokeThickness" quand on utilise la font Arial Black
			
			_ownedLabel.width = scaleAndRoundToDpi(170);
			_ownedLabel.x = _ownedLabelImage.x + scaleAndRoundToDpi(6);
			_ownedLabel.y = _ownedLabelImage.y - scaleAndRoundToDpi(3); // avant "6" quand on utilise la font Arial Black
		}
		
		protected var _data:TrophyData;
		
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
			this._data = TrophyData(value);
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
		
//------------------------------------------------------------------------------------------------------------
//	GET / SET
//------------------------------------------------------------------------------------------------------------
		
		public function set highlights(val:Image):void
		{
			_highlights = val;
		}
		
		public function set ownedLabelImage(val:Image):void
		{
			_ownedLabelImage = val;
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
//------------------------------------------------------------------------------------------------------------
		
		override public function dispose():void
		{
			_title.removeFromParent(true);
			_title = null;
			
			_message.removeFromParent(true);
			_message = null;
			
			_reward.removeFromParent(true);
			_reward = null;
			
			_topStripe.removeFromParent(true);
			_topStripe = null;
			
			_bottomStripe.removeFromParent(true);
			_bottomStripe = null;
			
			_obtainedGradient.removeFromParent(true);
			_obtainedGradient = null;
			
			_background.removeFromParent(true);
			_background = null;
			
			_ownedLabel.removeFromParent(true);
			_ownedLabel = null;
			
			_ownedLabelImage.removeFromParent(true);
			_ownedLabelImage = null;
			
			_highlights.removeFromParent(true);
			_highlights = null;
			
			_data = null;
			
			super.dispose();
		}
	}
}