/*
Copyright © 2006-2014 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 5 nov. 2013
*/
package com.ludofactory.mobile.navigation.account.history.settings
{
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.controls.AbstractAccordionItem;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import flash.text.TextFormat;
	
	import feathers.controls.ImageLoader;
	import feathers.controls.Label;
	import feathers.controls.LayoutGroup;
	import feathers.controls.ScrollContainer;
	import feathers.controls.Scroller;
	import feathers.layout.VerticalLayout;
	
	import starling.display.Quad;
	import starling.display.QuadBatch;
	import starling.display.Sprite;
	import starling.events.TouchEvent;
	
	public class SettingAccordionItem extends AbstractAccordionItem
	{
		/**
		 * The header container. */		
		private var _headerContainer:Sprite;
		
		/**
		 * The header. */		
		private var _headerBackground:QuadBatch;
		
		/**
		 * The header title. */		
		private var _headerTitle:Label;
		
		/**
		 * The content container's shadow. */		
		private var _shadow:Quad;
		
		/**
		 * The settings data. */		
		private var _content:LayoutGroup;
		
		private var _titleTranslationKey:String;
		
		public function SettingAccordionItem( titleTranslationKey:String, content:LayoutGroup )
		{
			super();
			
			_content = content;
			_titleTranslationKey = titleTranslationKey;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			const vlayout:VerticalLayout = new VerticalLayout();
			layout = vlayout;
			
			_headerContainer = new Sprite();
			_headerContainer.addEventListener(TouchEvent.TOUCH, expandOrCollapseContent);
			addChild(_headerContainer);
			
			_headerBackground = _headerBackground = new QuadBatch();
			_headerContainer.addChild(_headerBackground);
			
			var quad:Quad = new Quad(50, scaleAndRoundToDpi(84), 0xffffff);
			_headerBackground.addQuad( quad );
			quad.height = scaleAndRoundToDpi(2);
			quad.color = 0xbfbfbf;
			quad.y = scaleAndRoundToDpi(84);
			_headerBackground.addQuad( quad );
			
			_headerTitle = new Label();
			_headerTitle.touchable = false;
			_headerTitle.text = _titleTranslationKey;
			_headerContainer.addChild(_headerTitle);
			_headerTitle.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(36), Theme.COLOR_DARK_GREY);
			_headerTitle.textRendererProperties.wordWrap = false;
			
			_arrow = new ImageLoader();
			_arrow.source = AbstractEntryPoint.assets.getTexture("arrow_down");
			_arrow.scaleX = _arrow.scaleY = GlobalConfig.dpiScale;
			_arrow.snapToPixels = true;
			_headerContainer.addChild(_arrow);
			
			_contentContainer = new ScrollContainer();
			_contentContainer.verticalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			_contentContainer.horizontalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			_contentContainer.height = 0;
			addChild(_contentContainer);
			
			_shadow = new Quad(50, scaleAndRoundToDpi(12), 0x000000);
			_shadow.setVertexAlpha(0, 0.1);
			_shadow.setVertexAlpha(1, 0.1);
			_shadow.setVertexColor(2, 0xffffff);
			_shadow.setVertexAlpha(2, 0);
			_shadow.setVertexColor(3, 0xffffff);
			_shadow.setVertexAlpha(3, 0);
			_contentContainer.addChild(_shadow);
			
			_contentContainer.addChild( _content );
			
		}
		
		override protected function draw():void
		{
			super.draw();
			
			const sizeInvalid:Boolean = isInvalid( INVALIDATION_FLAG_SIZE );
			if( sizeInvalid )
			{
				_headerTitle.validate();
				_headerTitle.y = (_headerBackground.height - _headerTitle.height) * 0.5;
				_headerTitle.x = scaleAndRoundToDpi(20);
				_headerTitle.width = this.actualWidth - (_headerTitle.x * 2);
				
				_headerBackground.width = _contentContainer.width = _shadow.width = this.actualWidth;
				
				_content.width = _contentContainer.width;
				_content.validate();
				
				_arrow.validate();
				_arrow.alignPivot();
				_arrow.x = actualWidth - scaleAndRoundToDpi(20) - (_arrow.width * 0.5);
				_arrow.y = _headerBackground.height * 0.5;
				
				_maxContainerHeight = _content.height;
			}
			
			if(needResize)
			{
				_contentContainer.height = _maxContainerHeight;
				needResize = false;
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
//------------------------------------------------------------------------------------------------------------
		
		override public function dispose():void
		{
			_headerContainer.removeEventListener(TouchEvent.TOUCH, expandOrCollapseContent);
			
			_headerBackground.reset();
			_headerBackground.removeFromParent(true);
			_headerBackground = null;
			
			_headerTitle.removeFromParent(true);
			_headerTitle = null;
			
			_headerContainer.removeFromParent(true);
			_headerContainer = null;
			
			_shadow.removeFromParent(true);
			_shadow = null;
			
			_content.removeFromParent(true);
			_content = null;
			
			super.dispose();
		}
		
	}
}