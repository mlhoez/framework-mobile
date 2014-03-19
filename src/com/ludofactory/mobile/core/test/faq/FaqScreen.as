/*
LudoFactory
Framework mobile
Author  : Maxime Lhoez
Created : 1 septembre 2013
*/
package com.ludofactory.mobile.core.test.faq
{
	import com.freshplanet.nativeExtensions.AirNetworkInfo;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.Localizer;
	import com.ludofactory.mobile.core.controls.AbstractAccordionItem;
	import com.ludofactory.mobile.core.controls.Accordion;
	import com.ludofactory.mobile.core.controls.AdvancedScreen;
	import com.ludofactory.mobile.core.remoting.Remote;
	import com.ludofactory.mobile.core.storage.Storage;
	import com.ludofactory.mobile.core.storage.StorageConfig;
	import com.ludofactory.mobile.core.test.config.GlobalConfig;
	
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.MovieClip;
	import starling.display.Quad;
	
	/**
	 * Faq screen.
	 */	
	public class FaqScreen extends AdvancedScreen
	{
		/**
		 * The logo. */		
		private var _logo:Image;
		
		/**
		 * The list shadow */		
		private var _listShadow:Quad;
		
		/**
		 * The accordion. */		
		private var _accordion:Accordion;
		
		/**
		 * The loader. */		
		private var _loader:MovieClip;
		
		public function FaqScreen()
		{
			super();
			
			_whiteBackground = true;
			_appClearBackground = false;
			_fullScreen = false;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			_headerTitle = Localizer.getInstance().translate("FAQ.HEADER_TITLE");
			
			_logo = new Image( AbstractEntryPoint.assets.getTexture( "help-big-icon" ) );
			_logo.scaleX = _logo.scaleY = GlobalConfig.dpiScale;
			addChild( _logo );
			
			_loader = new MovieClip( AbstractEntryPoint.assets.getTextures("MiniLoader") );
			_loader.scaleX = _loader.scaleY = GlobalConfig.dpiScale;
			Starling.juggler.add( _loader );
			addChild(_loader);
			
			_listShadow = new Quad(50, scaleAndRoundToDpi(12), 0x000000);
			_listShadow.setVertexColor(0, 0xffffff);
			_listShadow.setVertexAlpha(0, 0);
			_listShadow.setVertexColor(1, 0xffffff);
			_listShadow.setVertexAlpha(1, 0);
			_listShadow.setVertexAlpha(2, 0.1);
			_listShadow.setVertexAlpha(3, 0.1);
			addChild(_listShadow);
			
			if( AirNetworkInfo.networkInfo.isConnected() )
			{
				Remote.getInstance().getFaq(onGetFaqSuccess, onGetFaqFailure, onGetFaqFailure, 1, advancedOwner.activeScreenID);
			}
			else
			{
				initializeFaq();
			}
		}
		override protected function draw():void
		{
			super.draw();
			
			if( isInvalid( INVALIDATION_FLAG_SIZE ) )
			{
				_logo.x = (actualWidth - _logo.width) * 0.5;
				_logo.y = scaleAndRoundToDpi( GlobalConfig.isPhone ? 10 : 20 );
				
				_listShadow.y = _logo.y + _logo.height + scaleAndRoundToDpi( GlobalConfig.isPhone ? 10 : 20 );
				_listShadow.width = this.actualWidth;
				
				if( _loader )
				{
					_loader.x = this.actualWidth * 0.5;
					_loader.y = (_listShadow.y + _listShadow.height) + ((actualHeight - (_listShadow.y + _listShadow.height)) - _loader.height) * 0.5;
				}
				
				if( _accordion )
				{
					_accordion.y = _listShadow.y + _listShadow.height;
					_accordion.width = this.actualWidth;
					_accordion.height = this.actualHeight - _accordion.y;
				}
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Handlers
//------------------------------------------------------------------------------------------------------------
		
		/**
		 * Initializes the FAQ.
		 */		
		private function initializeFaq():void
		{
			Starling.juggler.remove( _loader );
			_loader.removeFromParent(true);
			_loader = null;
			
			var panels:Vector.<AbstractAccordionItem> = new Vector.<AbstractAccordionItem>();
			var faq:Array = JSON.parse( Storage.getInstance().getProperty( StorageConfig.PROPERTY_FAQ )[Localizer.getInstance().lang] ) as Array;
			
			for(var i:int = 0; i < faq.length; i++)
				panels.push( new FaqAccordionItem( new FaqData(faq[i]) ) );
			
			_accordion = new Accordion();
			_accordion.dataProvider = panels;
			addChild(_accordion);
			
			invalidate(INVALIDATION_FLAG_SIZE);
		}
		
		/**
		 * The faq have been retreived, now we need to update the storage
		 * and then display the faq.
		 */		
		private function onGetFaqSuccess(result:Object):void
		{
			if( result != null && result.hasOwnProperty( "tabFaq" ) && result.tabFaq != null )
				Storage.getInstance().updateFaq(result);
			
			initializeFaq();
		}
		
		/**
		 * An error occurred while updating the FAQ.
		 * 
		 * <p>In this case, we just display the old version of
		 * the FAQ that was stored in the phone storage.</p>
		 */		
		private function onGetFaqFailure(error:Object = null):void
		{
			initializeFaq();
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
//------------------------------------------------------------------------------------------------------------
		
		override public function dispose():void
		{
			if( _loader )
			{
				Starling.juggler.remove( _loader );
				_loader.removeFromParent(true);
				_loader = null;
			}
			
			if( _accordion )
			{
				_accordion.removeFromParent(true);
				_accordion = null;
			}
			
			super.dispose();
		}
		
	}
}