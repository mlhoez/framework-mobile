/*
Copyright © 2006-2014 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 27 sept. 2013
*/
package com.ludofactory.mobile.core.test.sponsor.info
{
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.Localizer;
	import com.ludofactory.mobile.core.authentication.MemberManager;
	import com.ludofactory.mobile.core.test.config.GlobalConfig;
	import com.ludofactory.mobile.core.theme.Theme;
	import com.ludofactory.mobile.core.storage.Storage;
	import com.ludofactory.mobile.core.storage.StorageConfig;
	
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import feathers.controls.ImageLoader;
	import feathers.controls.Label;
	import feathers.controls.List;
	import feathers.controls.renderers.IListItemRenderer;
	import feathers.core.FeathersControl;
	import feathers.display.Scale3Image;
	
	import starling.events.Event;
	
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
		private var _title:Label;
		
		/**
		 *  */		
		private var _bonusLabel:Label;
		private var _equalLabel:Label;
		
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
			
			addChild(_backgroundSkin);
			
			_title = new Label();
			addChild(_title);
			_title.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(38), Theme.COLOR_WHITE);
			
			_bonusLabel = new Label();
			addChild(_bonusLabel);
			
			_equalLabel = new Label();
			_equalLabel.text = "=";
			addChild(_equalLabel);
			_equalLabel.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(38), Theme.COLOR_WHITE, false, false, null, null, null, TextFormatAlign.CENTER);
			
			_image = new ImageLoader();
			_image.textureScale = GlobalConfig.dpiScale;
			addChild(_image);
		}
		
		public function set backgroundSkin(val:Scale3Image):void { _backgroundSkin = val; }
		
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
					
					_title.text = Localizer.getInstance().translate(_data.rank);
					
					_image.source = AbstractEntryPoint.assets.getTexture( _data.iconTextureName );
					
					_bonusLabel.text = Localizer.getInstance().translate(_data.bonus);
					
					if( _index < 2 )
					{
						if( _index == 0 && !MemberManager.getInstance().isLoggedIn() )
							_bonusLabel.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(26), 0xf6ff00, false, false, null, null, null, TextFormatAlign.RIGHT);
						else
							_bonusLabel.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(38), 0xf6ff00, false, false, null, null, null, TextFormatAlign.RIGHT);
					}
					else
					{ 
						_bonusLabel.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi( (Storage.getInstance().getProperty(StorageConfig.PROPERTY_SPONSOR_REWARD_TYPE) == 1 ? 32 : 72) ), 0xf6ff00, false, false, null, null, null, TextFormatAlign.RIGHT);
					}
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
			
			_title.x = _image.width + scaleAndRoundToDpi(20);
			_title.width = this.owner.width - _image.width - scaleAndRoundToDpi(20);
			_title.validate();
			_title.y = (_itemHeight - _title.height) * 0.5;
			
			_equalLabel.x = _image.width + scaleAndRoundToDpi(20);
			_equalLabel.width = this.owner.width - _image.width - scaleAndRoundToDpi(20);
			_equalLabel.validate();
			_equalLabel.y = (_itemHeight - _equalLabel.height) * 0.5;
			
			_bonusLabel.width = this.owner.width * 0.98;
			_bonusLabel.validate();
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