/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 17 sept. 2013
*/
package com.ludofactory.mobile.navigation.account.history.settings
{
	import com.freshplanet.nativeExtensions.AirNetworkInfo;
	import com.greensock.TweenMax;
	import com.greensock.easing.Bounce;
	import com.greensock.easing.Elastic;
	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractGameInfo;
	import com.ludofactory.mobile.core.controls.CustomToggleSwitch;
	import com.ludofactory.mobile.core.events.LudoEventType;
	import com.ludofactory.mobile.core.manager.InfoContent;
	import com.ludofactory.mobile.core.manager.InfoManager;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import feathers.controls.Button;
	import feathers.controls.Label;
	import feathers.controls.List;
	import feathers.controls.TextInput;
	import feathers.controls.renderers.IListItemRenderer;
	import feathers.core.FeathersControl;
	
	import starling.core.Starling;
	import starling.display.MovieClip;
	import starling.display.Quad;
	import starling.events.Event;
	import starling.utils.formatString;
	
	/**
	 * Item renderer used to display the customer service messages.
	 */	
	public class AccountItemRenderer extends FeathersControl implements IListItemRenderer
	{
		/**
		 * The base height of a line in the list. */		
		private static const BASE_HEIGHT:int = 80;
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
		 * The top stripe displayed in each item renderer. */		
		private var _topStripe:Quad;
		/**
		 * The bottom stripe only displayed in the last item renderer. */		
		private var _bottomStripe:Quad;
		/**
		 * The left stripe. */		
		private var _leftStripe:Quad;
		/**
		 * The background. */		
		private var _background:Quad;
		/**
		 * The background black border. */		
		private var _backgroundBorder:Quad;
		
		/**
		 * The global padding of the item renderer. */		
		private var _padding:int = 10;
		
		/**
		 * The control to display. */		
		private var _control:FeathersControl;
		
		/**
		 * The save button */		
		private var _saveButton:Button;
		
		/**
		 * The loader. */		
		private var _loader:MovieClip;
		
		/**
		 * The background border width. */		
		private var _backgroundBorderWidth:int;
		
		private var _helpText:Label;
		
		public function AccountItemRenderer()
		{
			super();
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			_itemHeight = scaleAndRoundToDpi(BASE_HEIGHT);
			_strokeThickness = scaleAndRoundToDpi(BASE_STROKE_THICKNESS);
			_padding *= GlobalConfig.dpiScale;
			_backgroundBorderWidth = scaleAndRoundToDpi(40);
			
			this.width = GlobalConfig.stageWidth;
			this.height = _itemHeight;
			
			_background = new Quad(this.width - _backgroundBorderWidth, _itemHeight, 0xf7f7f7);
			_background.x = _backgroundBorderWidth;
			addChild(_background);
			
			_leftStripe = new Quad(_strokeThickness, _itemHeight, 0xbfbfbf);
			_leftStripe.x = _backgroundBorderWidth;
			addChild(_leftStripe);
			
			_topStripe = new Quad(50, _strokeThickness, 0xbfbfbf);
			addChild(_topStripe);
			
			_bottomStripe = new Quad(50, _strokeThickness, 0xbfbfbf);
			_bottomStripe.visible = false;
			addChild(_bottomStripe);
			
			_backgroundBorder = new Quad(_backgroundBorderWidth, _itemHeight, 0x292929);
			addChild(_backgroundBorder);
			
			_title = new Label();
			_title.touchable = false;
			addChild(_title);
			_title.textRendererProperties.textFormat = Theme.accountIRTextFormat;
			
			_helpText = new Label();
			_helpText.touchable = false;
			_helpText.visible = false;
			addChild(_helpText);
			_helpText.textRendererProperties.textFormat = Theme.accountIRTextFormat;
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
					_title.visible = true;
					
					_title.text = _data.title;
					
					if( _data.hasOwnProperty("isSaveButton") )
					{
						_saveButton = new Button();
						_saveButton.styleName = Theme.BUTTON_FLAT_GREEN;
						_saveButton.label = _("Sauvegarder");
						_saveButton.addEventListener(Event.TRIGGERED, onSave);
						addChild(_saveButton);
						
						_loader = new MovieClip(Theme.blackLoaderTextures);
						_loader.scaleX = _loader.scaleY = GlobalConfig.dpiScale;
						_loader.alignPivot();
						_loader.visible = false;
						_loader.touchable = false;
						_loader.alpha = 0;
						Starling.juggler.add(_loader);
						addChild(_loader);
					}
					else
					{
						_control = _data.accessory;
						if( _control )
							addChild(_control);
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
			_topStripe.width = this.actualWidth;
			
			if( owner/* && owner.dataProvider && (owner.dataProvider.data.length - 1) == _groupIndex*/ && (owner.dataProvider.length - 1) == _index)
			{
				_bottomStripe.visible = true;
				_bottomStripe.y = this.actualHeight - _strokeThickness;
				_bottomStripe.width = this.actualWidth;
			}
			else
			{
				
				_bottomStripe.visible = false;
			}
			
			_title.x = _backgroundBorder.width + _padding;
			_title.width = this.actualWidth - _backgroundBorder.width - _padding * 2;
			_title.validate();
			_title.y = (_itemHeight - _title.height) * 0.5;
			
			if( _control )
			{
				if( _control is Label )
				{
					Label(_control).textRendererProperties.textFormat = Theme.accountIRLabelTextFormat;
					Label(_control).textRendererProperties.wordWrap = false;
					_control.validate();
					_control.x = actualWidth - _control.width - _padding;
					_control.y = (_itemHeight - _control.height) * 0.5;
				}
				else
				{
					if( _control is CustomToggleSwitch )
					{
						_control.width = (actualWidth - _title.x) * (GlobalConfig.isPhone ? 0.35 : 0.25);
						_control.validate();
					}
					else
					{
						if( _control is TextInput )
							TextInput(_control).paddingTop = scaleAndRoundToDpi(12);
						_control.width = (actualWidth - _title.x) * 0.6;
						_control.height = actualHeight * 0.8;
					}
					
					_control.x = actualWidth - _control.width - _padding;
					_control.y = (_itemHeight - _control.height) * 0.5;
				}
			}
			
			if( _data.hasOwnProperty("isSaveButton") )
			{
				_saveButton.height = this.actualHeight * 0.7;
				_saveButton.width = this.actualWidth * 0.4;
				_saveButton.alignPivot();
				_saveButton.x = _loader.x = this.actualWidth - (_saveButton.width * 0.5) - scaleAndRoundToDpi(20);
				_saveButton.y = _loader.y = this.actualHeight * 0.5;
			}
			
			if( _data.hasOwnProperty("helpTextTranslation") )
			{
				_helpText.visible = true;
				_helpText.text = formatString(_data.helpTextTranslation, AbstractGameInfo.GAME_NAME);
				_helpText.x = _backgroundBorder.width + _padding;
				_helpText.width = this.actualWidth - _backgroundBorder.width - _padding * 2;
				_helpText.validate();
				_helpText.y = _itemHeight;
				
				_background.height = _backgroundBorder.height = _leftStripe.height = _helpText.y + _helpText.height + _padding;
				
				setSize(actualWidth, _background.height);
			}
			else
			{
				setSize(actualWidth, _itemHeight);
				_helpText.visible = false;
			}
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
			this._data = Object(value);
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
		
		protected var _index:int = -1;
		
		public function get index():int
		{
			return this._index;
		}
		
		public function set index(value:int):void
		{
			this._index = value;
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
		
//------------------------------------------------------------------------------------------------------------
//	Handlers
//------------------------------------------------------------------------------------------------------------
		
		/**
		 * Update the group.
		 */		
		private function onSave(event:Event):void
		{
			if( AirNetworkInfo.networkInfo.isConnected() )
			{
				touchable = false;
				
				TweenMax.to(_saveButton, 0.75, { scaleX:0, scaleY:0, autoAlpha:0, ease:Bounce.easeOut });
				TweenMax.to(_loader, 1, { delay:0.5, scaleX:GlobalConfig.dpiScale, scaleY:GlobalConfig.dpiScale, autoAlpha:1, ease:Elastic.easeOut, onComplete:owner.dispatchEventWith, onCompleteParams:[LudoEventType.SAVE_ACCOUNT_INFORMATION, false] });
			}
			else
			{
				InfoManager.showTimed(_("Aucune connexion Internet."), InfoManager.DEFAULT_DISPLAY_TIME, InfoContent.ICON_CROSS);
			}
		}
		
		public function onUpdateComplete():void
		{
			touchable = true;
			
			TweenMax.to(_saveButton, 0.75, { delay:0.5, scaleX:1, scaleY:1, autoAlpha:1, ease:Bounce.easeOut });
			TweenMax.to(_loader, 0.75, { scaleX:0, scaleY:0, autoAlpha:0, ease:Bounce.easeOut });
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
//------------------------------------------------------------------------------------------------------------
		
		override public function dispose():void
		{
			owner = null;
			
			_title.removeFromParent(true);
			_title = null;
			
			_topStripe.removeFromParent(true);
			_topStripe = null;
			
			_bottomStripe.removeFromParent(true);
			_bottomStripe = null;
			
			_leftStripe.removeFromParent(true);
			_leftStripe = null;
			
			_background.removeFromParent(true);
			_background = null;
			
			_backgroundBorder.removeFromParent(true);
			_backgroundBorder = null;
			
			if( _saveButton )
			{
				_saveButton.removeEventListener(Event.TRIGGERED, onSave);
				_saveButton.removeFromParent(true);
				_saveButton = null;
			}
			
			if( _loader )
			{
				Starling.juggler.remove(_loader);
				_loader.removeFromParent(true);
				_loader = null;
			}
			
			_control = null;
			
			_data = null;
			
			super.dispose();
		}
	}
}