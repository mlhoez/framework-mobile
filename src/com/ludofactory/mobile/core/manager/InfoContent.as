/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 6 janv. 2013
*/
package com.ludofactory.mobile.core.manager
{
	
	import com.greensock.TweenMax;
	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import feathers.controls.Label;
	import feathers.core.FeathersControl;
	
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.display.MovieClip;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.text.TextField;
	import starling.utils.VAlign;
	
	/**
	 * InfoContent is the content displayed by the InfoManager when
	 * some information needs to be displayed the the user on the
	 * screen.
	 * 
	 * @see com.ludofactory.mobile.core.manager.InfoManager
	 */	
	public class InfoContent extends Sprite
	{
		/**
		 * Displays a loader. */		
		public static const ICON_LOADER:int = 0;
		/**
		 * Displays a check icon. */		
		public static const ICON_CHECK:int = 1;
		/**
		 * Displays a cross icon. */		
		public static const ICON_CROSS:int = 2;
		/**
		 * No icon displayed. */		
		public static const ICON_NOTHING:int = 3;
		
		/**
		 * The value of the icon to display.
		 * 
		 * @see #ICON_CHECK
		 * @see #ICON_CROSS
		 * @see #ICON_NOTHING */		
		private var _icon:int = ICON_CHECK;
		
		/**
		 * Message to display. */		
		private var _message:TextField;
		
		/**
		 * Loader. */		
		private var _loader:MovieClip;
		/**
		 * Image displayed when some action succeed. */		
		private var _checkImage:Image;
		
		/**
		 * Image displayed when some action failed. */		
		private var _crossImage:Image;
		
		/**
		 * Blac overlay. */		
		private var _overlay:Image;
		
		/**
		 * Label that tells the user to touch the screen
		 * to close the informaiton. */		
		private var _tapToCloseLabel:Label;
		
		/**
		 * Whether the information is closable. */		
		private var _closable:Boolean = false;
		
		private var _component:DisplayObject;
		
		public function InfoContent()
		{
			super();
			
			addEventListener(Event.ADDED_TO_STAGE, initialize);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Handlers
		
		/**
		 * Initialize the component. This function is called only once
		 * the first time the component is added to the stage.
		 */		
		protected function initialize(event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, initialize);
			
			_overlay = new Image(Theme.infoManagerOverlay);
			addChild(_overlay);
			
			_checkImage = new Image(AbstractEntryPoint.assets.getTexture("Check"));
			_checkImage.scaleX = _checkImage.scaleY = GlobalConfig.dpiScale;
			_checkImage.alignPivot();
			_checkImage.visible = false;
			_checkImage.touchable = false;
			addChild(_checkImage);
			
			_crossImage = new Image(AbstractEntryPoint.assets.getTexture("Cross"));
			_crossImage.scaleX = _crossImage.scaleY = GlobalConfig.dpiScale;
			_crossImage.alignPivot();
			_crossImage.visible = false;
			_crossImage.touchable = false;
			addChild(_crossImage);
			
			_loader = new MovieClip(AbstractEntryPoint.assets.getTextures("Loader"), 20);
			_loader.scaleX = _loader.scaleY = GlobalConfig.dpiScale;
			_loader.alignPivot();
			_loader.touchable = false;
			addChild(_loader);
			
			_message = new TextField(5, 5, "", Theme.FONT_SANSITA, scaleAndRoundToDpi(32), Theme.COLOR_WHITE);
			_message.touchable = false;
			_message.vAlign = VAlign.TOP;
			_message.autoScale = true;
			addChild(_message);
			
			_tapToCloseLabel = new Label();
			_tapToCloseLabel.touchable = false;
			_tapToCloseLabel.text = _("Tapotez n'importe où pour continuer...");
			addChild(_tapToCloseLabel);
			_tapToCloseLabel.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(GlobalConfig.isPhone ? 24 : 30), Theme.COLOR_WHITE, false, false, null, null, null, TextFormatAlign.CENTER);
			
			stage.addEventListener(Event.RESIZE, draw);
			
			onAddedToStage();
			
			draw();
		}
		
		/**
		 * Layout the content.
		 * 
		 * <p>This function is called after the first initialization of the
		 * component and whenever the application is resized (so when the
		 * orientation changes principally).</p>
		 */		
		protected function draw(event:Event = null):void
		{
			_overlay.width = GlobalConfig.stageWidth;
			_overlay.height = GlobalConfig.stageHeight;
			
			_checkImage.x = _crossImage.x = _loader.x = GlobalConfig.stageWidth * 0.5;
			_checkImage.y = (GlobalConfig.stageHeight * 0.5) - _checkImage.height;
			_crossImage.y = (GlobalConfig.stageHeight * 0.5) - _crossImage.height;
			_loader.y = (GlobalConfig.stageHeight * 0.5) - _loader.height;
			
			_message.width = GlobalConfig.stageWidth * 0.9;
			_message.x = (GlobalConfig.stageWidth - _message.width) * 0.5;
			_message.y = (GlobalConfig.stageHeight * 0.5) + scaleAndRoundToDpi(10);
			_message.height = GlobalConfig.stageHeight - _message.y;
			
			_tapToCloseLabel.width = GlobalConfig.stageWidth;
			_tapToCloseLabel.validate();
			_tapToCloseLabel.y = GlobalConfig.stageHeight - _tapToCloseLabel.height - scaleAndRoundToDpi(10);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Handlers
		
		protected function onAddedToStage():void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
			
			icon = ICON_LOADER;
			Starling.juggler.add(_loader);
			_tapToCloseLabel.alpha = 1;
			TweenMax.to(_tapToCloseLabel, 0.75, { alpha:0.25, repeat:-1, yoyo:true });
		}
		
		/**
		 * When the info is removed from the stage, we need to remove the
		 * loader from the juggler and kill the tweens of the "tap to close"
		 * label.
		 */		
		protected function onRemovedFromStage(event:Event):void
		{
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
			
			Starling.juggler.remove(_loader);
			TweenMax.killTweensOf( _tapToCloseLabel );
		}
		
//------------------------------------------------------------------------------------------------------------
//	Set
		
		/**
		 * Sets the message.
		 */		
		public function set message(val:String):void
		{
			_message.visible = true;
			_message.alpha = 1;
			_message.text = val;
		}
		
		/**
		 * Whether the info is closable.
		 */		
		public function set closable(val:Boolean):void
		{
			_closable = val;
			_tapToCloseLabel.visible = _closable;
		}
		
		/**
		 * Sets the icon to display.
		 */		
		public function set icon(val:int):void
		{
			_icon = val;
			
			_loader.visible = _checkImage.visible = _crossImage.visible = false;
			
			switch(_icon)
			{
				case ICON_LOADER:
				{
					_loader.visible = true;
					_loader.alpha = 1;
					break;
				}
				case ICON_CHECK:
				{
					_checkImage.visible = true;
					_checkImage.alpha = 0;
					_checkImage.scaleX = _checkImage.scaleY = GlobalConfig.dpiScale + 0.4;
					TweenMax.to(_checkImage, 0.25, { alpha:1, scaleX:GlobalConfig.dpiScale, scaleY:GlobalConfig.dpiScale });
					break;
				}
				case ICON_CROSS:
				{
					_crossImage.visible = true;
					_crossImage.alpha = 0;
					_crossImage.scaleX = _crossImage.scaleY = GlobalConfig.dpiScale + 0.4;
					TweenMax.to(_crossImage, 0.25, { alpha:1, scaleX:GlobalConfig.dpiScale, scaleY:GlobalConfig.dpiScale });
					break;
				}
			}
		}
		
		/**
		 * Set a component to display.
		 */		
		public function set component(val:DisplayObject):void
		{
			_component = val;
			
			if( _crossImage.visible ) TweenMax.to(_crossImage, 0.5, { autoAlpha:0 });
			if( _checkImage.visible ) TweenMax.to(_checkImage, 0.5, { autoAlpha:0 });
			if( _loader.visible )     TweenMax.to(_loader, 0.5, { autoAlpha:0 });
			if( _message.visible )    TweenMax.to(_message, 0.5, { autoAlpha:0 });
			
			_component.visible = false;
			addChild(_component);
			TweenMax.to(_component, 0.5, { autoAlpha:1 });
			
			if( _component is FeathersControl )
			{
				_component.width = GlobalConfig.stageWidth;
				_component.height = GlobalConfig.stageHeight;
			}
			else
			{
				_component.x = (GlobalConfig.stageWidth - _component.width) * 0.5;
				_component.y = (GlobalConfig.stageHeight - _component.height) * 0.5;
			}
		}
	}
}