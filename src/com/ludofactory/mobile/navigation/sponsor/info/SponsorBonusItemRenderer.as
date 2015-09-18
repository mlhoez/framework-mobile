/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 27 sept. 2013
*/
package com.ludofactory.mobile.navigation.sponsor.info
{
	
	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import feathers.controls.ImageLoader;
	import feathers.controls.List;
	import feathers.controls.renderers.IListItemRenderer;
	import feathers.core.FeathersControl;
	import feathers.display.Scale3Image;
	import feathers.skins.IStyleProvider;
	
	import starling.events.Event;
	import starling.text.TextField;
	import starling.text.TextFieldAutoSize;
	import starling.utils.HAlign;
	import starling.utils.VAlign;
	
	/**
	 * Item renderer used to display the customer service messages.
	 */	
	public class SponsorBonusItemRenderer extends FeathersControl implements IListItemRenderer
	{
		/**
		 * The base height of a line in the list. */		
		private static const BASE_HEIGHT:int = 80;
		/**
		 * The scaled item height. */		
		private var _itemHeight:Number;
		
		/**
		 * Name of the trophy. */		
		private var _title:TextField;
		
		/**
		 *  */		
		private var _bonusLabel:TextField;
		private var _equalLabel:TextField;
		
		private var _image:ImageLoader;
		
		/**
		 * The background. */		
		private var _backgroundSkin:Scale3Image;
		
		public function SponsorBonusItemRenderer()
		{
			super();
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			_itemHeight = scaleAndRoundToDpi(BASE_HEIGHT);
			
			//this.width = GlobalConfig.stageWidth;
			this.height = _itemHeight;
			
			_backgroundSkin = new Scale3Image(Theme.sponsorBonusBackground, GlobalConfig.dpiScale);
			addChild(_backgroundSkin);
			
			var savedHeight:int;
			
			_title = new TextField(5, _itemHeight, "0", Theme.FONT_SANSITA, scaleAndRoundToDpi(38), Theme.COLOR_WHITE);
			_title.autoSize = TextFieldAutoSize.VERTICAL;
			savedHeight = _title.height;
			_title.hAlign = HAlign.LEFT;
			_title.vAlign = VAlign.CENTER;
			_title.autoSize = TextFieldAutoSize.NONE;
			_title.autoScale = true;
			_title.border = true;
			addChild(_title);
			
			_equalLabel = new TextField(5, _itemHeight, _("="), Theme.FONT_SANSITA, scaleAndRoundToDpi(38), Theme.COLOR_WHITE);
			_equalLabel.autoSize = TextFieldAutoSize.HORIZONTAL;
			_equalLabel.border = true;
			_equalLabel.vAlign = VAlign.CENTER;
			addChild(_equalLabel);
			
			_bonusLabel = new TextField(5, savedHeight, "0", Theme.FONT_SANSITA, scaleAndRoundToDpi(38), 0xf6ff00);
			_bonusLabel.hAlign = HAlign.RIGHT;
			_bonusLabel.vAlign = VAlign.CENTER;
			_bonusLabel.border = true;
			_bonusLabel.autoScale = true;
			addChild(_bonusLabel);
			
			_image = new ImageLoader();
			_image.textureScale = GlobalConfig.dpiScale;
			addChild(_image);
		}
		
		public function set backgroundSkin(val:Scale3Image):void { _backgroundSkin = val; }
		
		override protected function draw():void
		{
			var dataInvalid:Boolean = this.isInvalid(INVALIDATION_FLAG_DATA);
			var sizeInvalid:Boolean = this.isInvalid(INVALIDATION_FLAG_SIZE);
			
			if(dataInvalid)
				this.commitData();
			
			if(dataInvalid || sizeInvalid)
				this.layout();
		}
		
		protected function commitData():void
		{
			if(this._owner)
			{
				if( _data )
				{
					_title.visible = true;
					_title.text = _data.rank;
					_image.source = AbstractEntryPoint.assets.getTexture( _data.iconTextureName );
					_bonusLabel.text = _data.bonus;
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
			_image.validate();
			_image.y = int((_itemHeight - _image.height) * 0.5);
			
			_backgroundSkin.x = _image.width * 0.5;
			_backgroundSkin.width = this.owner.width - _backgroundSkin.x;
			_backgroundSkin.y = int( (_itemHeight - _backgroundSkin.height) * 0.5 );
			
			// center the "="
			_equalLabel.x = _image.width + ((this.owner.width - _image.width) - _equalLabel.width) * 0.5;
			
			_title.x = _image.width + scaleAndRoundToDpi(10);
			_title.width = _equalLabel.x - _title.x;
			_title.y = (_itemHeight - _title.height) * 0.5;
			
			_bonusLabel.x = _equalLabel.x + _equalLabel.width;
			_bonusLabel.width = this.owner.width - _bonusLabel.x - scaleAndRoundToDpi(10);
			_bonusLabel.y = (_itemHeight - _bonusLabel.height) * 0.5;
		}
		
		protected var _data:SponsorBonusData;
		
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
			this._data = SponsorBonusData(value);
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
		
		private var _index:int = -1;
		
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
		
		/**
		 * Required for the new Theme. */
		public static var globalStyleProvider:IStyleProvider;
		override protected function get defaultStyleProvider():IStyleProvider
		{
			return SponsorBonusItemRenderer.globalStyleProvider;
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
//------------------------------------------------------------------------------------------------------------
		
		override public function dispose():void
		{
			owner = null;
			
			_title.removeFromParent(true);
			_title = null;
			
			
			_backgroundSkin.removeFromParent(true);
			_backgroundSkin = null;
			
			_data = null;
			
			super.dispose();
		}
	}
}