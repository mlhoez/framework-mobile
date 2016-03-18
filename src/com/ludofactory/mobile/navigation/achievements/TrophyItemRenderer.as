/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 31 août 2013
*/
package com.ludofactory.mobile.navigation.achievements
{
	
	import com.ludofactory.common.gettext.Domains;
	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.common.gettext.aliases._d;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import feathers.controls.ImageLoader;
	import feathers.controls.List;
	import feathers.controls.renderers.IListItemRenderer;
	import feathers.core.FeathersControl;
	
	import starling.display.Image;
	import starling.display.MeshBatch;
	import starling.display.Quad;
	import starling.events.Event;
	import starling.text.TextField;
	import starling.text.TextFormat;
	import starling.utils.Align;
	import starling.utils.deg2rad;
	
	/**
	 * Item renderer used to display the trophies.
	 */	
	public class TrophyItemRenderer extends FeathersControl implements IListItemRenderer
	{
		// ------------------ Layout properties
		
		private static const TITLE_HEIGHT:int = 34;
		private var _titleHeight:Number;
		
		/**
		 * The base height of a line in the list. */		
		private static const BASE_HEIGHT:int = 130;
		/**
		 * The scaled item height. */		
		private var _itemHeight:Number;
		
		/**
		 * The base stroke thickness. */		
		private static const BASE_STROKE_THICKNESS:int = 2;
		/**
		 * The scaled stroke thickness. */		
		private var _strokeThickness:Number;
		
		// ------------------ Properties
		
		/**
		 * The background. */
		private var _background:MeshBatch;
		/**
		 * The bottom stripe only displayed in the last item renderer. */
		private var _bottomStripe:Quad;
		
		/**
		 * Name of the trophy. */		
		private var _title:TextField;
		/**
		 * The description of the trophy. */		
		private var _description:TextField;
		/**
		 * The reward of the trophy. */		
		//private var _reward:TextField;
		
		/**
		 * The gradient displayed when the trophy is owned. */		
		private var _obtainedGradient:Quad;
		/**
		 * Highlights */
		private var _highlights:Image;
		/**
		 * The trophy image. */
		private var _trophyImage:ImageLoader;
		
		/**
		 * The label displayed on the top right corner when the trophy is owned. */		
		private var _ownedLabelImage:Image;
		/**
		 * The owned label. */		
		private var _ownedLabel:TextField;
		
		/**
		 * The global padding of the item renderer. */		
		private var _padding:int = 10;
		
		public function TrophyItemRenderer()
		{
			super();
			touchable = false;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			_titleHeight = scaleAndRoundToDpi(TITLE_HEIGHT);
			_itemHeight = scaleAndRoundToDpi(BASE_HEIGHT);
			_strokeThickness = scaleAndRoundToDpi(BASE_STROKE_THICKNESS);
			_padding *= GlobalConfig.dpiScale;
			
			this.width = GlobalConfig.stageWidth;
			this.height = _itemHeight;
			
			buildBackground();
			
			_obtainedGradient = new Quad(scaleAndRoundToDpi(130), _itemHeight, 0xff0000);
			addChild(_obtainedGradient);
			
			_highlights = new Image(Theme.trophyHighlightTexture);
			_highlights.scaleX = _highlights.scaleY = GlobalConfig.dpiScale;
			_highlights.width = _obtainedGradient.width;
			_highlights.height = _obtainedGradient.height;
			addChild(_highlights);
			
			_bottomStripe = new Quad(50, _strokeThickness, 0xbfbfbf);
			_bottomStripe.visible = false;
			addChild(_bottomStripe);
			
			_title = new TextField(5, 5, "", new TextFormat(Theme.FONT_ARIAL, scaleAndRoundToDpi(28), 0xffffff));
			_title.autoScale = true;
			_title.format.verticalAlign = Align.CENTER;
			_title.format.horizontalAlign = Align.LEFT;
			addChild(_title);
			
			_description = new TextField(5, 5, "", new TextFormat(Theme.FONT_ARIAL, scaleAndRoundToDpi(26), Theme.COLOR_LIGHT_GREY));
			_description.format.italic = true;
			_description.autoScale = true;
			_description.format.verticalAlign = Align.CENTER;
			_description.format.horizontalAlign = Align.LEFT;
			addChild(_description);
			
			/*_reward = new TextField(5, 5, "", new TextFormat(Theme.FONT_ARIAL, scaleAndRoundToDpi(26), Theme.COLOR_LIGHT_GREY));
			_reward.format.italic = true;
			_reward.autoScale = true;
			_reward.format.verticalAlign = Align.CENTER;
			_reward.format.horizontalAlign = Align.LEFT;
			addChild(_reward);*/
			
			_ownedLabelImage = new Image(Theme.trophyOwnedTexture);
			_ownedLabelImage.scaleX = _ownedLabelImage.scaleY = GlobalConfig.dpiScale;
			addChild(_ownedLabelImage);
			
			_trophyImage = new ImageLoader();
			_trophyImage.pixelSnapping = true;
			addChild(_trophyImage);
			
			_ownedLabel = new TextField(_ownedLabelImage.width - scaleAndRoundToDpi(20), scaleAndRoundToDpi(40), "", new TextFormat(Theme.FONT_ARIAL, scaleAndRoundToDpi(28), Theme.COLOR_WHITE));
			_ownedLabel.autoScale = true;
			_ownedLabel.format.verticalAlign = Align.CENTER;
			_ownedLabel.text = _("Obtenue");
			// wordwrap = false ?
			addChild(_ownedLabel);
			_ownedLabel.alignPivot(Align.LEFT, Align.BOTTOM);
			_ownedLabel.rotation = deg2rad(30);
		}
		
		private function buildBackground():void
		{
			_background = new MeshBatch();
			addChild(_background);
			addChild(_background);
			
			// white background
			var helperQuad:Quad;
			helperQuad = new Quad(GlobalConfig.stageWidth, _itemHeight);
			_background.addMesh(helperQuad);
			
			// top stripe
			helperQuad.color = 0xbfbfbf;
			helperQuad.height = _strokeThickness;
			_background.addMesh(helperQuad);
			
			// title background
			helperQuad.width = GlobalConfig.stageWidth;
			helperQuad.y = _strokeThickness;
			helperQuad.height = scaleAndRoundToDpi(34);
			helperQuad.setVertexColor(0, 0x292929);
			helperQuad.setVertexColor(1, 0x4d4d4d);
			helperQuad.setVertexColor(2, 0x292929);
			helperQuad.setVertexColor(3, 0x4d4d4d);
			_background.addMesh(helperQuad);
			
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
					_title.visible = _description.visible = /*_reward.visible =*/ true;
					
					_title.text = _d(Domains.GAME, _data.title);
					_description.text = _d(Domains.GAME, _data.description);
					//_reward.text = _d(Domains.GAME, _data.reward);
					_trophyImage.source = _data.textureName.indexOf("http") >= 0 ? _data.textureName : AbstractEntryPoint.assets.getTexture(_data.textureName);
					
					// not owned
					if( TrophyManager.getInstance().canWinTrophy( _data.id ) )
					{
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
						
						//_reward.format.color = Theme.COLOR_ORANGE;
					}
					else
					{
						_trophyImage.color = 0xffffff;
						_trophyImage.alpha = 1;
						_highlights.color = 0xfff000;
						
						_ownedLabelImage.visible = true;
						_ownedLabel.visible = true;
						
						_obtainedGradient.setVertexColor(0, 0xb5e404);
						_obtainedGradient.setVertexColor(1, 0xb5e404);
						_obtainedGradient.setVertexColor(2, 0x2a6514);
						_obtainedGradient.setVertexColor(3, 0x2a6514);
						
						//_reward.format.color = Theme.COLOR_LIGHT_GREY;
					}
				}
				else
				{
					_title.text = _description.text = /*_reward.text =*/ "";
				}
			}
			else
			{
				_title.visible = _description.visible = /*_reward.visible =*/ false;
			}
		}
		
		protected function layout():void
		{
			_bottomStripe.y = this.actualHeight - _strokeThickness;
			_bottomStripe.width = this.actualWidth;
			_bottomStripe.visible = (this.owner && this.owner.dataProvider && (this.owner.dataProvider.length - 1) == _index);
			
			_highlights.height = _obtainedGradient.height - _strokeThickness;
			_highlights.y = _strokeThickness;
			
			_trophyImage.width = actualWidth * 0.7;
			_trophyImage.height = actualHeight * 0.7;
			_trophyImage.validate();
			_trophyImage.x = (_obtainedGradient.width - _trophyImage.width) * 0.5;
			_trophyImage.y = (_obtainedGradient.height - _trophyImage.height) * 0.5;
			
			_title.x = _obtainedGradient.width + _padding;
			_title.y = _strokeThickness;
			_title.width = this.actualWidth - _obtainedGradient.width - _padding * 2;
			_title.height = _titleHeight;
			
			/*_reward.x = _obtainedGradient.width + _padding;
			_reward.y = actualHeight - _strokeThickness - _titleHeight;
			_reward.width = this.actualWidth - _obtainedGradient.width - _padding * 2;
			_reward.height = _titleHeight;*/
			
			_description.x = _obtainedGradient.width + _padding;
			_description.y = _title.y + _titleHeight;
			_description.width = this.actualWidth - _obtainedGradient.width - _padding * 2;
			_description.height = this.actualHeight - _description.y;
			
			_ownedLabelImage.x = this.actualWidth - _ownedLabelImage.width;
			
			//_ownedLabel.width = scaleAndRoundToDpi(170);
			_ownedLabel.x = _ownedLabelImage.x + scaleAndRoundToDpi(38);
			_ownedLabel.y = _ownedLabelImage.y + scaleAndRoundToDpi(22);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Get - Set
		
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
		
		protected var _factoryID:String;
		
		public function get factoryID():String
		{
			return this._factoryID;
		}
		
		public function set factoryID(value:String):void
		{
			this._factoryID = value;
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
		
		override public function dispose():void
		{
			_background.clear();
			_background.removeFromParent(true);
			_background = null;
			
			_bottomStripe.removeFromParent(true);
			_bottomStripe = null;
			
			_title.removeFromParent(true);
			_title = null;
			
			_description.removeFromParent(true);
			_description = null;
			
			/*_reward.removeFromParent(true);
			_reward = null;*/
			
			_obtainedGradient.removeFromParent(true);
			_obtainedGradient = null;
			
			_highlights.removeFromParent(true);
			_highlights = null;
			
			_trophyImage.source = null;
			_trophyImage.removeFromParent(true);
			_trophyImage = null;
			
			_ownedLabelImage.removeFromParent(true);
			_ownedLabelImage = null;
			
			_ownedLabel.removeFromParent(true);
			_ownedLabel = null;
			
			_data = null;
			
			super.dispose();
		}
		
	}
}