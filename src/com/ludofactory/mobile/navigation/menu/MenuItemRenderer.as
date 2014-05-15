/*
Copyright © 2006-2014 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 17 Août 2013
*/
package com.ludofactory.mobile.navigation.menu
{
	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.AbstractGameInfo;
	import com.ludofactory.mobile.core.controls.AbstractListItemRenderer;
	import com.ludofactory.mobile.core.events.LudoEventType;
	import com.ludofactory.mobile.core.test.config.GlobalConfig;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import feathers.controls.ImageLoader;
	import feathers.controls.Label;
	import feathers.controls.ScrollContainer;
	
	import starling.display.Quad;
	import starling.display.QuadBatch;
	
	/**
	 * Item renderer used by the menu to display all the categories
	 * of the application.
	 */	
	public class MenuItemRenderer extends AbstractListItemRenderer
	{
		/**
		 * The border */		
		private var _background:QuadBatch;
		
		/**
		 * The title */		
		private var _title:Label;
		
		/**
		 * The icon */		
		private var _icon:ImageLoader;
		
		/**
		 * Badge (alert number) container. */		
		private var _badgeContainer:ScrollContainer;
		
		/**
		 * Badge label (containing the number of alerts). */		
		private var _badgeLabel:Label;
		
		public function MenuItemRenderer()
		{
			super();
			isQuickHitAreaEnabled = true;
		}
		
		override protected function initialize():void
		{
			_background = new QuadBatch();
			_background.touchable = false;
			addChild(_background);
			
			_title = new Label();
			_title.touchable = false;
			addChild( _title );
			_title.textRendererProperties.textFormat = Theme.menuIRTextFormat;
			
			_icon = new ImageLoader();
			_icon.touchable = false;
			_icon.snapToPixels = true;
			addChild( _icon );
			
			_badgeContainer = new ScrollContainer();
			_badgeContainer.touchable = false;
			_badgeContainer.styleName = Theme.SCROLL_CONTAINER_BADGE;
			addChild( _badgeContainer );
			
			_badgeLabel = new Label();
			_badgeLabel.touchable = false;
			_badgeContainer.addChild( _badgeLabel );
			_badgeLabel.textRendererProperties.textFormat = Theme.menuIRBadgeTextFormat;
		}
		
		override protected function commitData():void
		{
			_title.text = _(_data.title); // necessary when the language change
			
			_badgeLabel.text = "" + _data.badgeNumber;
			_badgeContainer.visible = _data.badgeNumber == 0 ? false : true;
			
			_icon.source = AbstractEntryPoint.assets.getTexture(_data.textureName);
		}
		
		override protected function autoSizeIfNeeded():Boolean
		{
			const needsWidth:Boolean = isNaN(this.explicitWidth);
			const needsHeight:Boolean = isNaN(this.explicitHeight);
			if(!needsWidth && !needsHeight)
			{
				return false;
			}
			var newWidth:Number = this.explicitWidth;
			if(needsWidth)
			{
				newWidth = GlobalConfig.stageWidth / (AbstractGameInfo.LANDSCAPE ? 4 : 3);
			}
			var newHeight:Number = this.explicitHeight;
			if(needsHeight)
			{
				newHeight = owner.height / (AbstractGameInfo.LANDSCAPE ? 3 : 4);
			}
			return this.setSizeInternal(newWidth, newHeight, false);
		}
		
		override protected function layout():void
		{
			createBackground();
			
			_title.width = actualWidth;
			_title.validate();
			_title.y = (actualHeight - _stripeThickness) + (_stripeThickness - _title.height) * 0.5;
			
			_icon.height = (actualHeight - _stripeThickness) * (GlobalConfig.isPhone ? 0.8 : 0.7);
			_icon.validate();
			_icon.alignPivot();
			_icon.x = (actualWidth * 0.5) << 0;
			_icon.y = ((actualHeight - _stripeThickness) * 0.5) << 0;
			
			_badgeContainer.validate();
			_badgeContainer.x = actualWidth - _badgeContainer.width - scaleAndRoundToDpi(10);
			_badgeContainer.y = scaleAndRoundToDpi(10);
		}
		
		protected function createBackground():void
		{
			if( _background.numQuads == 0 )
			{
				// the background was not created
				// white stripe
				var quad:Quad = new Quad(actualWidth, _stripeThickness, 0xffffff);
				quad.y = actualHeight - _stripeThickness;
				_background.addQuad(quad);
				// grey stripe at the right
				quad.y = 0;
				quad.x = actualWidth - _borderThickness;
				quad.width = _borderThickness;
				quad.height = actualHeight;
				quad.color = 0xe6e6e6;
				_background.addQuad(quad);
				// grey stripe at the bottom
				quad.x = 0;
				quad.height = _borderThickness;
				quad.width = actualWidth;
				quad.y = actualHeight - _borderThickness;
				_background.addQuad(quad);
				
				quad = null;
			}
		}
		
		override protected function onTouched():void
		{
			owner.dispatchEventWith(LudoEventType.MENU_ICON_TOUCHED, false, _data.screenLinked);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Get / Set
		
		/**
		 * Menu category data. */		
		protected var _data:MenuItemData;
		
		override public function get data():Object
		{
			return this._data;
		}
		
		override public function set data(value:Object):void
		{
			if(this._data == value)
			{
				return;
			}
			this._data = MenuItemData(value);
			this.invalidate(INVALIDATION_FLAG_DATA);
		}
		
		/**
		 * The border thickness */		
		protected var _borderThickness:int;
		
		public function set borderThickness(val:int):void
		{
			_borderThickness = val;
		}
		
		/**
		 * The stripe thickness */		
		protected var _stripeThickness:int;
		
		public function set stripeThickness(val:int):void
		{
			_stripeThickness = val;
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
		
		override public function dispose():void
		{
			_background.reset();
			_background.removeFromParent(true);
			_background = null;
			
			_title.removeFromParent(true);
			_title = null;
			
			_icon.removeFromParent(true);
			_icon = null;
			
			_badgeLabel.removeFromParent(true);
			_badgeLabel = null;
			
			_badgeContainer.removeFromParent(true);
			_badgeContainer = null;
			
			_data = null;
			
			super.dispose();
		}
	}
}