package com.ludofactory.mobile.navigation.vip
{
	import com.greensock.TweenMax;
	import com.greensock.easing.Linear;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.controls.AbstractAccordionItem;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import flash.text.TextFormat;
	
	import feathers.controls.ImageLoader;
	import feathers.controls.Label;
	import feathers.controls.ScrollContainer;
	import feathers.layout.VerticalLayout;
	
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.QuadBatch;
	import starling.display.Sprite;
	import starling.events.TouchEvent;
	
	public class VipAccordionItem extends AbstractAccordionItem
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
		 * The vip privilege data. */		
		private var _vipPrivilegeData:VipPrivilegeData;
		
		/**
		 * The vip privilege description. */		
		private var _vipPrivilegedescription:Label;
		
		/**
		 * The background black border. */		
		private var _backgroundBorder:Quad;
		
		/**
		 * Icon displayed for new privileges. */		
		private var _newIcon:Image;
		
		/**
		 * The saved width to avoid visual bug when the
		 * element is expanding or collapsing. */		
		private var _newIconWidth:int;
		
		public function VipAccordionItem(vipPrivilegeData:VipPrivilegeData)
		{
			super();
			
			_vipPrivilegeData = vipPrivilegeData;
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
			_headerBackground.addQuad( quad );
			quad.y = scaleAndRoundToDpi(84);
			_headerBackground.addQuad( quad );

			headerHeight = scaleAndRoundToDpi(84);
			
			_newIcon = new Image( AbstractEntryPoint.assets.getTexture("vip-new-icon") );
			_newIcon.scaleX = _newIcon.scaleY = GlobalConfig.dpiScale;
			_newIcon.alignPivot();
			_newIcon.visible = false;
			_newIconWidth = _newIcon.width;
			_headerContainer.addChild(_newIcon);
			TweenMax.to(_newIcon, 0.4, { scaleX:(GlobalConfig.dpiScale - 0.15), scaleY:(GlobalConfig.dpiScale - 0.15), yoyo:true, repeat:-1, ease:Linear.easeNone });
			
			_headerTitle = new Label();
			_headerTitle.touchable = false;
			_headerTitle.text = _vipPrivilegeData.title;
			_headerContainer.addChild(_headerTitle);
			_headerTitle.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(32), Theme.COLOR_DARK_GREY);
			
			_arrow = new ImageLoader();
			_arrow.source = AbstractEntryPoint.assets.getTexture("arrow_down");
			_arrow.scaleX = _arrow.scaleY = GlobalConfig.dpiScale;
			_arrow.snapToPixels = true;
			_headerContainer.addChild(_arrow);
			
			_contentContainer = new ScrollContainer();
			_contentContainer.height = 0;
			addChild(_contentContainer);
			
			_backgroundBorder = new Quad(scaleAndRoundToDpi(40), 5, 0x292929);
			_contentContainer.addChild(_backgroundBorder);
			
			_shadow = new Quad(50, scaleAndRoundToDpi(12), 0x000000);
			_shadow.setVertexAlpha(0, 0.1);
			_shadow.setVertexAlpha(1, 0.1);
			_shadow.setVertexColor(2, 0xffffff);
			_shadow.setVertexAlpha(2, 0);
			_shadow.setVertexColor(3, 0xffffff);
			_shadow.setVertexAlpha(3, 0);
			_contentContainer.addChild(_shadow);
			
			_vipPrivilegedescription = new Label();
			_vipPrivilegedescription.touchable = false;
			_vipPrivilegedescription.text = _vipPrivilegeData.description;
			_contentContainer.addChild(_vipPrivilegedescription);
			_vipPrivilegedescription.textRendererProperties.textFormat = new TextFormat(Theme.FONT_ARIAL, scaleAndRoundToDpi(28), Theme.COLOR_DARK_GREY, true);
		}
		
		override protected function draw():void
		{
			super.draw();
			
			if( isInvalid( INVALIDATION_FLAG_SIZE ) )
			{
				_arrow.validate();
				_arrow.alignPivot();
				_arrow.x = (actualWidth - scaleAndRoundToDpi(20) - (_arrow.width * 0.5)) << 0;
				_arrow.y = (_headerBackground.height * 0.5) << 0;
				
				_newIcon.visible = _isNew;
				_newIcon.y = (_headerContainer.height * 0.5) << 0;
				_newIcon.x = (scaleAndRoundToDpi( GlobalConfig.isPhone ? 10 : 20 ) + (_newIconWidth * 0.5)) << 0;
				
				//_headerTitle.textRendererProperties.textFormat.color = _isNew ? Theme.COLOR_ORANGE : 0x565656;
				_headerTitle.x = _isNew ? (_newIcon.x + (_newIconWidth * 0.5) + scaleAndRoundToDpi( GlobalConfig.isPhone ? 10 : 20 )) : (scaleAndRoundToDpi( GlobalConfig.isPhone ? 20 : 40 ));
				_headerTitle.width = _arrow.x - _headerTitle.x - scaleAndRoundToDpi(20); // scaleAndRoundToDpi(20) = padding arrow
				_headerTitle.validate();
				_headerTitle.y = (_headerBackground.height - _headerTitle.height) * 0.5;
				
				_headerBackground.width = _contentContainer.width = _shadow.width = actualWidth;
				
				_vipPrivilegedescription.width = _contentContainer.width - _backgroundBorder.width - scaleAndRoundToDpi(40);
				_vipPrivilegedescription.x = _backgroundBorder.width + scaleAndRoundToDpi(20);
				_vipPrivilegedescription.y = scaleAndRoundToDpi(20);
				//_vipPrivilegedescription.x = (_contentContainer.width - _vipPrivilegedescription.width) * 0.5;
				_vipPrivilegedescription.validate();
				
				_maxContainerHeight = _vipPrivilegedescription.height + scaleAndRoundToDpi(40);
				
				_backgroundBorder.height = _maxContainerHeight;
			}
			
			if(needResize)
			{
				_contentContainer.height = _maxContainerHeight;
				needResize = false;
			}
		}
		
		private var _isNew:Boolean = false;
		
		public function get isNew():Boolean
		{
			return _isNew;
		}
		
		public function set isNew(val:Boolean):void
		{
			if( val == _isNew )
				return;
			_isNew = val;
			invalidate(INVALIDATION_FLAG_SIZE);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
//------------------------------------------------------------------------------------------------------------
		
		override public function dispose():void
		{
			TweenMax.killTweensOf(_newIcon);
			_newIcon.removeFromParent(true);
			_newIcon = null;
			
			_headerBackground.reset();
			_headerBackground.removeFromParent(true);
			_headerBackground = null;
			
			_headerTitle.removeFromParent(true);
			_headerTitle = null;
			
			_headerContainer.removeEventListener(TouchEvent.TOUCH, expandOrCollapseContent);
			_headerContainer.removeFromParent(true);
			_headerContainer = null;
			
			_backgroundBorder.removeFromParent(true);
			_backgroundBorder = null;
			
			_shadow.removeFromParent(true);
			_shadow = null;
			
			_vipPrivilegedescription.removeFromParent(true);
			_vipPrivilegedescription = null;
			
			_vipPrivilegeData = null;
			
			super.dispose();
		}
	}
}