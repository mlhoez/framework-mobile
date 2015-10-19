/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 28 oct. 2013
*/
package com.ludofactory.mobile.navigation.authentication
{
	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.controls.ArrowGroup;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import feathers.controls.Label;
	import feathers.core.FeathersControl;
	
	import starling.core.Starling;
	import starling.display.MovieClip;
	import starling.events.Event;
	
	public class RetryContainer extends FeathersControl
	{
		/**
		 * The message. */		
		private var _message:Label;
		
		/**
		 * The retry button. */		
		private var _retryButton:ArrowGroup;
		
		/**
		 * The loader. */		
		private var _loader:MovieClip;
		
		/**
		 * If in loading mode, only the loader will be displayed. */		
		private var _loadingMode:Boolean = true;
		
		/**
		 * If in single message mode, only a message will be displayed. */		
		private var _singleMessageMode:Boolean = false;
		
		/**
		 * Whether the message is dark. */		
		private var _isMessageDark:Boolean = false;
		
		public function RetryContainer(isMessageDark:Boolean = false)
		{
			super();
			_isMessageDark = isMessageDark;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			_message = new Label();
			_message.touchable = false;
			_message.text = _("Vous ne pouvez pas afficher le contenu de cette page car vous n'êtes pas connecté à Internet.");
			addChild(_message);
			_message.textRendererProperties.textFormat = _isMessageDark ? Theme.retryContainerDarkTextFormat : Theme.retryContainerLightTextFormat;
			
			_retryButton = new ArrowGroup( _("Réessayer") );
			_retryButton.addEventListener(Event.TRIGGERED, onRetry);
			addChild(_retryButton);
			
			_loader = new MovieClip( Theme.blackLoaderTextures );
			_loader.touchable = false;
			_loader.scaleX = _loader.scaleY = GlobalConfig.dpiScale;
			_loader.alignPivot();
			Starling.juggler.add(_loader);
			addChild(_loader);
		}
		
		override protected function draw():void
		{
			super.draw();
			
			if( isInvalid(INVALIDATION_FLAG_SIZE) )
			{
				_message.width = actualWidth * (GlobalConfig.isPhone ? 0.9 : 0.7);
				_message.validate();
				_message.x = (actualWidth - _message.width) * 0.5;
				
				//if( _retryButton.width > actualWidth )
				//	_retryButton.width = actualWidth * 0.8;
				_retryButton.x = (actualWidth - _retryButton.width) * 0.5;
				
				_message.y = ((actualHeight - (_message.height + _retryButton.height + scaleAndRoundToDpi(GlobalConfig.isPhone ? 10 : 20))) * 0.5) << 0;
				_retryButton.y = _message.y + _message.height + scaleAndRoundToDpi(GlobalConfig.isPhone ? 10 : 20);
				
				_loader.x = actualWidth * 0.5;
				_loader.y = actualHeight * 0.5;
				
				_message.visible = !_loadingMode;
				_retryButton.visible = _loadingMode ? false : !_singleMessageMode;
				
				_loader.visible = _loadingMode;
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Handlers
		
		/**
		 * Start authentication process.
		 */		
		private function onRetry(event:Event):void
		{
			dispatchEventWith(Event.TRIGGERED);
		}
		
//------------------------------------------------------------------------------------------------------------
//	GET - SET
		
		public function set message(val:String):void
		{
			_message.text = val;
			loadingMode = false;
			invalidate( INVALIDATION_FLAG_SIZE );
		}
		
		public function set loadingMode(val:Boolean):void
		{
			if( _loadingMode == val )
				return;
			_loadingMode = val;
			invalidate( INVALIDATION_FLAG_SIZE );
		}
		
		public function set singleMessageMode(val:Boolean):void
		{
			if( _singleMessageMode == val )
				return;
			_singleMessageMode = val;
			loadingMode = false;
			invalidate( INVALIDATION_FLAG_SIZE );
		}
		
		public function set retryButtonMessage(val:String):void
		{
			_retryButton.label = val;
			loadingMode = false;
			invalidate( INVALIDATION_FLAG_SIZE );
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
		
		override public function dispose():void
		{
			_message.removeFromParent(true);
			_message = null;
			
			_retryButton.removeEventListener(Event.TRIGGERED, onRetry);
			_retryButton.removeFromParent(true);
			_retryButton = null;
			
			Starling.juggler.remove(_loader);
			_loader.removeFromParent(true);
			_loader = null;
			
			super.dispose();
		}
		
	}
}