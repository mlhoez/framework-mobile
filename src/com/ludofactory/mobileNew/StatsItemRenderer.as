/**
 * Created by Maxime on 26/04/2016.
 */
package com.ludofactory.mobileNew
{
	
	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.manager.MemberManager;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import feathers.controls.List;
	import feathers.controls.renderers.IListItemRenderer;
	import feathers.core.FeathersControl;
	
	import flash.geom.Rectangle;
	
	import starling.display.Image;
	
	import starling.events.Event;
	import starling.text.TextField;
	import starling.text.TextFormat;
	import starling.utils.Align;
	
	public class StatsItemRenderer extends FeathersControl implements IListItemRenderer 
	{
		/**
		 * The base height of a line in the list. */
		private static const BASE_HEIGHT:int = 80;
		
		/**
		 * The background. */
		private var _background:Image;
		/**
		 * The statistic title. */
		private var _title:TextField;
		/**
		 * The statistic value. */
		private var _value:TextField;
		
		public function StatsItemRenderer()
		{
			super();
			this.touchGroup = true;
			this.touchable = false;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			this.height = scaleAndRoundToDpi(BASE_HEIGHT);
			
			_background = new Image(AbstractEntryPoint.assets.getTexture("common-background-texture"));
			_background.scale9Grid = new Rectangle(1, 1, 2, 2);
			addChild(_background);
			
			_title = new TextField(5, this.height, "", new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(30), 0x000000, Align.LEFT));
			_title.touchable = false;
			_title.wordWrap = false;
			_title.autoScale = true;
			addChild(_title);
			
			_value = new TextField(5, this.height, "", new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(30), 0x000000, Align.RIGHT));
			_value.touchable = false;
			_value.wordWrap = false;
			_value.autoScale = true;
			addChild(_value);
		}
		
		override protected function draw():void
		{
			var dataInvalid:Boolean = this.isInvalid(INVALIDATION_FLAG_DATA);
			var sizeInvalid:Boolean = this.isInvalid(INVALIDATION_FLAG_SIZE);
			
			if(dataInvalid)
				this.commitData();
			
			sizeInvalid = this.autoSizeIfNeeded() || sizeInvalid;
			if(dataInvalid || sizeInvalid)
				this.layout();
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
			if( _data )
			{
				_title.text = _data.title;
				_value.text = (MemberManager.getInstance().isPremium || !_data.isMasked) ? _data.value : _("Masqué");
				_background.color = _index % 2 == 0 ? 0x494848 : 0x686868;
			}
		}
		
		protected function layout():void
		{
			_title.width = _value.width = _value.x = actualWidth * 0.5;
			_background.width = actualWidth;
			_background.height = actualHeight;
		}
		
//------------------------------------------------------------------------------------------------------------
//	Get - Set
		
		protected var _data:StatsData;
		
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
			this._data = StatsData(value);
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
			
			
			super.dispose();
		}
	}
}