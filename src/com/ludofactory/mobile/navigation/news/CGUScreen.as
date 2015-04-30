/*
Copyright © 2006-2015 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 11 févr. 2014
*/
package com.ludofactory.mobile.navigation.news
{
	import com.freshplanet.nativeExtensions.AirNetworkInfo;
	import com.ludofactory.common.gettext.LanguageManager;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.controls.AdvancedScreen;
	import com.ludofactory.mobile.core.remoting.Remote;
	import com.ludofactory.mobile.core.storage.Storage;
	import com.ludofactory.mobile.core.storage.StorageConfig;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.theme.Theme;

	import feathers.controls.ScrollText;

	import flash.text.TextFormat;

	import starling.core.Starling;
	import starling.display.MovieClip;

	public class CGUScreen extends AdvancedScreen
	{
		private var _scrollText:ScrollText;
		
		/**
		 * The loader. */		
		private var _loader:MovieClip;
		
		public function CGUScreen()
		{
			super();
			
			_whiteBackground = true;
		}
		
		/**
		 * <ol><li></li></ol>
		 * <b>
		 * <i>
		 * <u>
		 */		
		override protected function initialize():void
		{
			super.initialize();
			
			_loader = new MovieClip( Theme.blackLoaderTextures );
			_loader.scaleX = _loader.scaleY = GlobalConfig.dpiScale;
			Starling.juggler.add( _loader );
			addChild(_loader);
			
			_scrollText = new ScrollText();
			_scrollText.isHTML = true;
			_scrollText.textFormat = new TextFormat("Arial", scaleAndRoundToDpi( GlobalConfig.isPhone ? 26 : 24 ));
			addChild(_scrollText);
			_scrollText.paddingTop = scaleAndRoundToDpi(70); // header's height
			_scrollText.paddingLeft = _scrollText.paddingRight = _scrollText.paddingBottom = scaleAndRoundToDpi(20);
			
			if( AirNetworkInfo.networkInfo.isConnected() )
			{
				Starling.juggler.delayCall(Remote.getInstance().getTermsAndConditions, 1, onGetTermsAndConditionsSuccess, onGetTermsAndConditionsFailure, onGetTermsAndConditionsFailure, 1, advancedOwner.activeScreenID);
			}
			else
			{
				initializeTermsAndConditions();
			}
		} 
		
		override protected function draw():void
		{
			super.draw();
			
			if( _loader )
			{
				_loader.x = (actualWidth - _loader.width) * 0.5;
				_loader.y = (actualHeight - _loader.height) * 0.5;
			}
			
			_scrollText.y = scaleAndRoundToDpi(-60); // header"s height
			_scrollText.width = actualWidth;
			_scrollText.height = actualHeight + scaleAndRoundToDpi(60);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Handlers
		
		/**
		 * The faq have been retreived, now we need to update the storage
		 * and then display the faq.
		 */		
		private function onGetTermsAndConditionsSuccess(result:Object):void
		{
			if( result != null && result.hasOwnProperty( "reglement" ) && result.reglement != null )
				Storage.getInstance().updateTermsAndConditions(result);
			
			initializeTermsAndConditions();
		}
		
		/**
		 * An error occurred while updating the FAQ.
		 * 
		 * <p>In this case, we just display the old version of
		 * the FAQ that was stored in the phone storage.</p>
		 */		
		private function onGetTermsAndConditionsFailure(error:Object = null):void
		{
			initializeTermsAndConditions();
		}
		
		/**
		 * 
		 */		
		private function initializeTermsAndConditions():void
		{
			Starling.juggler.remove( _loader );
			_loader.removeFromParent(true);
			_loader = null;
			
			_scrollText.text = Storage.getInstance().getProperty(StorageConfig.PROPERTY_TERMS_AND_CONDITIONS)[LanguageManager.getInstance().lang];
		}
		
//------------------------------------------------------------------------------------------------------------
//	
		/**
		 * Because ScrollText is using the native display, the content will
		 * be above everything. Then when the main menu is shown, the content
		 * will be above it : we don't want this to happen so we have to manually
		 * show / hide the text depending on whether the main menu is displaying
		 * or not.
		 */		
		public function updateView(isMainMenuDisplaying:Boolean):void
		{
			_scrollText.visible = !isMainMenuDisplaying;
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
		
		override public function dispose():void
		{
			if( _loader )
			{
				Starling.juggler.remove( _loader );
				_loader.removeFromParent(true);
				_loader = null;
			}
			
			_scrollText.removeFromParent(true);
			_scrollText = null;
			
			super.dispose();
		}
		
	}
}