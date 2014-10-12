/*
Copyright © 2006-2014 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 28 août 2013
*/
package com.ludofactory.mobile.navigation.shop.bid.finished
{
	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.common.utils.Utilities;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.notification.NotificationManager;
	import com.ludofactory.mobile.core.notification.content.AbstractNotification;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import feathers.controls.ImageLoader;
	import feathers.controls.Label;
	import feathers.events.FeathersEventType;
	import feathers.layout.VerticalLayout;
	
	import starling.core.Starling;
	import starling.display.MovieClip;
	import starling.events.Event;
	
	public class FinishedBidDetailNotification extends AbstractNotification
	{
		/**
		 * The title */		
		private var _notificationTitle:Label;
		
		/**
		 * The gift image. */		
		private var _image:ImageLoader;
		
		/**
		 * The gift name. */		
		private var _giftName:Label;
		
		/**
		 * The gift description. */		
		private var _giftDescription:Label;
		
		/**
		 * Name of the winner. */		
		private var _winner:Label;
		
		/**
		 * The date. */		
		private var _date:Label;
		
		/**
		 * Finished bid item data. */		
		private var _finishedBidItemData:FinishedBidItemData;
		
		/**
		 * Loader used while the image is loading. */		
		private var _imageLoader:MovieClip;
		
		/**
		 * If we need to resize the notification */		
		private var _needResize:Boolean = false;
		
		public function FinishedBidDetailNotification(finishedBidItemData:FinishedBidItemData)
		{
			super();
			
			_finishedBidItemData = finishedBidItemData;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			const vlayout:VerticalLayout = new VerticalLayout();
			vlayout.horizontalAlign = VerticalLayout.HORIZONTAL_ALIGN_CENTER;
			vlayout.verticalAlign = VerticalLayout.VERTICAL_ALIGN_TOP;
			vlayout.padding = scaleAndRoundToDpi(GlobalConfig.isPhone ? 10:20);
			vlayout.gap = scaleAndRoundToDpi(GlobalConfig.isPhone ? 20:40);
			_container.layout = vlayout;
			
			_notificationTitle = new Label();
			_notificationTitle.text = _("Enchère terminée");
			_container.addChild(_notificationTitle);
			_notificationTitle.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(40), Theme.COLOR_DARK_GREY, false, false, null, null, null, TextFormatAlign.CENTER);
			
			_image = new ImageLoader();
			_image.addEventListener(Event.COMPLETE, onImageLoaded);
			_image.addEventListener(FeathersEventType.ERROR, onImageError);
			_image.source = _finishedBidItemData.imageUrl;
			_container.addChild(_image);
			
			_imageLoader = new MovieClip( Theme.blackLoaderTextures );
			_imageLoader.scaleX = _imageLoader.scaleY = GlobalConfig.dpiScale;
			_container.addChild(_imageLoader);
			Starling.juggler.add(_imageLoader);
			
			_giftName = new Label();
			_giftName.text = Utilities.replaceCurrency(_finishedBidItemData.name);
			_container.addChild(_giftName);
			_giftName.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(32), Theme.COLOR_DARK_GREY, false, false, null, null, null, TextFormatAlign.CENTER);
			
			_giftDescription = new Label();
			_giftDescription.text = _finishedBidItemData.description;
			_container.addChild(_giftDescription);
			_giftDescription.textRendererProperties.textFormat = new TextFormat(Theme.FONT_ARIAL, scaleAndRoundToDpi(26), Theme.COLOR_DARK_GREY, true, true);
			
			_winner = new Label();
			_winner.text = _finishedBidItemData.winnerName;
			_container.addChild(_winner);
			_winner.textRendererProperties.textFormat = new TextFormat(Theme.FONT_ARIAL, scaleAndRoundToDpi(32), Theme.COLOR_LIGHT_GREY, true, false, null, null, null, TextFormatAlign.CENTER);
			
			_date = new Label();
			_date.text = _finishedBidItemData.date;
			_container.addChild(_date);
			_date.textRendererProperties.textFormat = new TextFormat(Theme.FONT_ARIAL, scaleAndRoundToDpi(32), Theme.COLOR_LIGHT_GREY, true, false, null, null, null, TextFormatAlign.CENTER);
		}
		
		override protected function draw():void
		{
			_container.width = _giftDescription.width = _giftName.width =
				_notificationTitle.width = _winner.width = _date.width = this.actualWidth - padSide * 2 - scaleAndRoundToDpi( GlobalConfig.isPhone ? 40:60 );
			_container.x = (this.actualWidth - _container.width) * 0.5;
			
			if( _image.isLoaded )
			{
				_image.validate();
				if( _image.height > GlobalConfig.stageHeight * 0.4 )
					_image.height = GlobalConfig.stageHeight * 0.4;
				
				if( _image.width > _container.width )
					_image.width = _container.width;
			}
			
			super.draw();
			
			if( _needResize )
			{
				_needResize = false;
				NotificationManager.replaceNotification();
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Handlers
//------------------------------------------------------------------------------------------------------------
		
		/**
		 * When the image have correctly been loaded.
		 */		
		protected function onImageLoaded(event:Event):void
		{
			Starling.juggler.remove(_imageLoader);
			_imageLoader.removeFromParent(true);
			_imageLoader = null;
			
			_image.alpha = 0;
			Starling.juggler.tween(_image, 0.75, { alpha:1 });
			
			_needResize = true;
			_container.invalidate(INVALIDATION_FLAG_SIZE);
			this.invalidate(INVALIDATION_FLAG_SIZE);
		}
		
		/**
		 * When the image could not be loaded.
		 */		
		protected function onImageError(event:Event):void
		{
			this.invalidate(INVALIDATION_FLAG_SIZE);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
//------------------------------------------------------------------------------------------------------------
		
		override public function dispose():void
		{
			_notificationTitle.removeFromParent(true);
			_notificationTitle = null;
			
			_image.removeEventListener(Event.COMPLETE, onImageLoaded);
			_image.removeEventListener(FeathersEventType.ERROR, onImageError);
			_image.removeFromParent(true);
			_image = null;
			
			_giftName.removeFromParent(true);
			_giftName = null;
			
			_giftDescription.removeFromParent(true);
			_giftDescription = null;
			
			_winner.removeFromParent(true);
			_winner = null;
			
			_date.removeFromParent(true);
			_date = null;
			
			if( _imageLoader )
			{
				Starling.juggler.remove(_imageLoader);
				_imageLoader.removeFromParent(true);
				_imageLoader = null;
			}
			
			_finishedBidItemData = null;
			
			super.dispose();
		}
	}
}