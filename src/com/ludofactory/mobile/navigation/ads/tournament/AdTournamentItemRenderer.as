/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 25 nov. 2013
*/
package com.ludofactory.mobile.navigation.ads.tournament
{
	
	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.common.utils.roundUp;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.AbstractGameInfo;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import feathers.controls.Button;
	import feathers.controls.ImageLoader;
	import feathers.controls.Label;
	import feathers.controls.List;
	import feathers.controls.renderers.IListItemRenderer;
	import feathers.core.FeathersControl;
	import feathers.skins.IStyleProvider;
	
	import flash.filters.DropShadowFilter;
	import flash.text.TextFormat;
	
	import starling.display.Quad;
	import starling.events.Event;
	import starling.utils.deg2rad;
	
	public class AdTournamentItemRenderer extends FeathersControl implements IListItemRenderer
	{
		private const BASE_STROKE_THICKNESS:int = 3;
		private var _strokeThickness:Number;
		
		/**
		 * Background stroke */		
		private var _stroke:Quad;
		/**
		 * Background gradient */		
		private var _gradient:Quad;
		/**
		 * Highlight ad */		
		protected var _highlightAd:ImageLoader;
		
		/**
		 * The title */		
		private var _title:Label;
		/**
		 * The title */		
		private var _giftName:Label;
		/**
		 * The button */		
		private var _adButton:Button;
		/**
		 * Ad icon */		
		protected var _giftImage:ImageLoader;
		/**
		 * The medal. */		
		private var _medal:ImageLoader;
		
		public function AdTournamentItemRenderer()
		{
			super();
		}
		
		override protected function initialize():void
		{
			_strokeThickness = scaleAndRoundToDpi(BASE_STROKE_THICKNESS);
			
			_stroke = new Quad(5, 5, 0xffffff);
			addChild(_stroke);
			
			_gradient = new Quad(5, 5, 0x0000ff);
			_gradient.setVertexColor(0, 0x43dfff);
			_gradient.setVertexColor(1, 0x43dfff);
			_gradient.setVertexColor(2, 0x02bbff);
			_gradient.setVertexColor(3, 0x02bbff);
			addChild(_gradient);
			
			_highlightAd = new ImageLoader();
			_highlightAd.source = AbstractEntryPoint.assets.getTexture("highlight-ad");
			_highlightAd.maintainAspectRatio = false;
			_highlightAd.alpha = 0.5;
			addChild(_highlightAd);
			
			_adButton = new Button();
			_adButton.styleName = AbstractGameInfo.LANDSCAPE ? Theme.BUTTON_AD_LANDSCAPE : Theme.BUTTON_AD;
			addChild(_adButton);
			
			_giftImage = new ImageLoader();
			//_giftImage.scaleX = _giftImage.scaleY = GlobalConfig.dpiScalez;
			_giftImage.snapToPixels = true;
			addChild(_giftImage);
			
			_medal = new ImageLoader();
			_medal.scaleX = _medal.scaleY = GlobalConfig.dpiScale;
			_medal.snapToPixels = true;
			addChild(_medal);
			
			_title = new Label();
			_title.text = AbstractGameInfo.LANDSCAPE ? _("Classez-vous\net gagnez :") : _("Classez-vous et gagnez :");
			addChild(_title);
			_title.textRendererProperties.wordWrap = AbstractGameInfo.LANDSCAPE;
			_title.textRendererProperties.nativeFilters = [ new DropShadowFilter(0, 75, 0xffffff, 1, 8, 8, 5) ];
			
			_giftName = new Label();
			addChild(_giftName);
			_giftName.textRendererProperties.wordWrap = AbstractGameInfo.LANDSCAPE;
			_giftName.textRendererProperties.nativeFilters = [ new DropShadowFilter(0, 75, 0xffffff, 1, 8, 8, 5) ];
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
			this._title.width = NaN;
			this._title.height = NaN;
			this._title.validate();
			var newWidth:Number = this.explicitWidth;
			if(needsWidth)
			{
				newWidth = this._title.width;
			}
			var newHeight:Number = this.explicitHeight;
			if(needsHeight)
			{
				newHeight = this._title.height;
			}
			return this.setSizeInternal(newWidth, newHeight, false);
		}
		
		protected function commitData():void
		{
			if(this._owner)
			{
				_adButton.visible = _stroke.visible = _gradient.visible = _highlightAd.visible = true;
				
				if(this._data)
				{
					_giftName.text = _data.giftName;
					_adButton.label = _data.buttonName;
					_giftImage.source = _data.giftImageUrl;
					
					if( _index == 0 )
					{
						_gradient.setVertexColor(0, 0xffbb00);
						_gradient.setVertexColor(1, 0xffbb00);
						_gradient.setVertexColor(2, 0xff7e00);
						_gradient.setVertexColor(3, 0xff7e00);
						
						_medal.source = AbstractEntryPoint.assets.getTexture("gold-medal-big");
						_giftName.textRendererProperties.textFormat = _firstTextFormat;
						_title.textRendererProperties.textFormat = _firstTextFormat;
					}
					else if( _index == 1 )
					{
						_gradient.setVertexColor(0, 0xb9b9b9);
						_gradient.setVertexColor(1, 0xb9b9b9);
						_gradient.setVertexColor(2, 0x4d4d4d);
						_gradient.setVertexColor(3, 0x4d4d4d);
						
						_medal.source = AbstractEntryPoint.assets.getTexture("silver-medal-big");
						_giftName.textRendererProperties.textFormat = _secondTextFormat;
						_title.textRendererProperties.textFormat = _secondTextFormat;
					}
					else
					{
						_gradient.setVertexColor(0, 0xe4856c);
						_gradient.setVertexColor(1, 0xe4856c);
						_gradient.setVertexColor(2, 0x8d4732);
						_gradient.setVertexColor(3, 0x8d4732);
						
						_medal.source = AbstractEntryPoint.assets.getTexture("bronze-medal-big");
						_giftName.textRendererProperties.textFormat = _thirdTextFormat;
						_title.textRendererProperties.textFormat = _thirdTextFormat;
					}
				}
				else
				{
					this._title.text = "";
				}
			}
			else
			{
				_title.text = null;
				_adButton.visible = _stroke.visible = _gradient.visible = _highlightAd.visible = false;
			}
		}
		
		protected function layout():void
		{
			this.width = owner.width;
			this.height = owner.height;
			
			_stroke.width = actualWidth;
			_stroke.height = actualHeight;
			
			_gradient.width = actualWidth - (_strokeThickness * 2);
			_gradient.height = actualHeight - (_strokeThickness * 2);
			_gradient.y = _strokeThickness;
			_gradient.x = _strokeThickness;
			
			if( AbstractGameInfo.LANDSCAPE )
			{
				_highlightAd.width = actualHeight;
				_highlightAd.height = actualWidth;
				_highlightAd.x = actualWidth;
				_highlightAd.rotation = deg2rad(90);
			}
			else
			{
				_highlightAd.height = actualHeight;
				_highlightAd.width = actualWidth;
				_highlightAd.x = _strokeThickness;
				_highlightAd.y = _strokeThickness;
			}
			
			if( AbstractGameInfo.LANDSCAPE )
			{
				_adButton.width = actualWidth;
				_adButton.y = actualHeight - scaleAndRoundToDpi(GlobalConfig.isPhone ? 98 : 108) - _adButton.height - scaleAndRoundToDpi(20); // 10 de padding du play bouton + 10 au dessus du bouton
				
				_title.width = _giftName.width = actualWidth * 0.9;
				_title.validate();
				_giftName.validate();
				_medal.validate();
				_title.x = _giftName.x = (actualWidth - _title.width) * 0.5;
				_title.y = _medal.height + ((_adButton.y - _medal.height) - (_title.height + _giftName.height)) * 0.5;
				_giftName.y = _title.y + _title.height;
				
				_giftImage.width = actualWidth * 0.8;
				_giftImage.validate();
				_giftImage.y = scaleAndRoundToDpi(30);
				_giftImage.x = roundUp((actualWidth - _giftImage.width) * 0.5);
			}
			else
			{
				_adButton.validate();
				_adButton.x = actualWidth - _adButton.width;
				_adButton.y = actualHeight - _adButton.height - scaleAndRoundToDpi(20);
				
				_title.validate();
				_title.x = actualWidth - _title.width - scaleAndRoundToDpi(10);
				_title.y = (_adButton.y * 0.5) - _title.height;
				
				_giftName.validate();
				_giftName.x = actualWidth - _giftName.width - scaleAndRoundToDpi(10);
				_giftName.y = _adButton.y * 0.5;
				
				_giftImage.height = actualHeight * 0.95;
				_giftImage.validate();
				_giftImage.y = (actualHeight - _giftImage.height) * 0.5;
				_giftImage.x = scaleAndRoundToDpi( GlobalConfig.isPhone ? 50 : 100 );
			}
			
			_medal.x = scaleAndRoundToDpi( GlobalConfig.isPhone ? 20 : 70 );
			_medal.y = _strokeThickness;
		}
		
		protected var _data:AdTournamentData;
		
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
			this._data = AdTournamentData(value);
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
		
		private var _firstTextFormat:TextFormat;
		public function set firstTextFormat(val:TextFormat):void
		{
			_firstTextFormat = val;
		}
		
		private var _secondTextFormat:TextFormat;
		public function set secondTextFormat(val:TextFormat):void
		{
			_secondTextFormat = val;
		}
		
		private var _thirdTextFormat:TextFormat;
		public function set thirdTextFormat(val:TextFormat):void
		{
			_thirdTextFormat = val;
		}
		
		/**
		 * Required for the new Theme. */
		public static var globalStyleProvider:IStyleProvider;
		override protected function get defaultStyleProvider():IStyleProvider
		{
			return AdTournamentItemRenderer.globalStyleProvider;
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
//------------------------------------------------------------------------------------------------------------
		
		override public function dispose():void
		{
			_stroke.removeFromParent(true);
			_stroke = null;
			
			_gradient.removeFromParent(true);
			_gradient = null;
			
			_title.removeFromParent(true);
			_title = null;
			
			_adButton.removeFromParent(true);
			_adButton = null;
			
			_highlightAd.removeFromParent(true);
			_highlightAd = null;
			
			_giftImage.removeFromParent(true);
			_giftImage = null;
			
			_data = null;
			
			super.dispose();
		}
	}
}