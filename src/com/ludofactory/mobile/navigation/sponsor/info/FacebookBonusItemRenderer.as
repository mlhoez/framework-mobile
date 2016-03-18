/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 27 sept. 2013
*/
package com.ludofactory.mobile.navigation.sponsor.info
{
	
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import feathers.controls.ImageLoader;
	import feathers.controls.List;
	import feathers.controls.renderers.IListItemRenderer;
	import feathers.core.FeathersControl;
	import feathers.skins.IStyleProvider;
	
	import flash.geom.Rectangle;
	
	import starling.display.Image;
	import starling.events.Event;
	import starling.text.TextField;
	import starling.text.TextFormat;
	import starling.utils.Align;
	
	/**
	 * Item renderer used to display the customer service messages.
	 */	
	public class FacebookBonusItemRenderer extends FeathersControl implements IListItemRenderer
	{
		/**
		 * The base height of a line in the list. */		
		private static const BASE_HEIGHT:int = 66;
		/**
		 * The scaled item height. */		
		private var _itemHeight:Number;
		
		/**
		 * Name of the trophy. */		
		private var _title:TextField;
		
		private var _image:ImageLoader;
		
		/**
		 * The background. */		
		private var _backgroundSkin:Image;
		
		public function FacebookBonusItemRenderer()
		{
			super();
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			_itemHeight = scaleAndRoundToDpi(BASE_HEIGHT);
			
			this.height = _itemHeight;
			
			_backgroundSkin = new Image(AbstractEntryPoint.assets.getTexture("facebook-popup-single-container"));
			_backgroundSkin.scale = GlobalConfig.dpiScale;
			_backgroundSkin.scale9Grid = new Rectangle(28, 0, 10, _backgroundSkin.texture.frameHeight);
			addChild(_backgroundSkin);
			
			_title = new TextField(5, _itemHeight, "sdfdsfsdfdsfsfds", new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(35), Theme.COLOR_WHITE));
			_title.format.horizontalAlign = Align.LEFT;
			_title.format.verticalAlign = Align.CENTER;
			_title.autoScale = true;
			addChild(_title);
			
			_image = new ImageLoader();
			_image.textureScale = GlobalConfig.dpiScale;
			addChild(_image);
		}
		
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
			if(this._owner && _data)
			{
				_title.text = _data.title;
				_image.source = AbstractEntryPoint.assets.getTexture( _data.iconTextureName );
			}
		}
		
		protected function layout():void
		{
			_image.validate();
			_image.y = int((_itemHeight - _image.height) * 0.5);
			_image.x = scaleAndRoundToDpi(20);
			
			_backgroundSkin.width = this.owner.width;
			
			_title.x = _image.x + _image.width + scaleAndRoundToDpi(10);
			_title.width = this.owner.width - _title.x;
		}
		
		protected var _data:FacebookBonusData;
		
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
			this._data = FacebookBonusData(value);
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
			return FacebookBonusItemRenderer.globalStyleProvider;
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