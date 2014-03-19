package com.ludofactory.mobile.core.controls
{
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.utils.Dictionary;
	
	import feathers.controls.ImageLoader;
	
	import starling.events.Event;
	import starling.textures.Texture;
	
	/**
	 * ...
	 * @author Enrique David Calatayud Pujalte
	 */
	public class ImageLoaderCache extends ImageLoader
	{
		public static var MAX_ITEMS:uint = 100;
		private static var cacheList:Dictionary = new Dictionary();
		private static var cacheListOrder:Array = new Array();
		
		public function ImageLoaderCache() {
			super();
		}
		
		public static function clear():void {
			for each(var item:Bitmap in ImageLoaderCache.cacheList) {
				item.bitmapData.dispose();
			}
			ImageLoaderCache.cacheList = new Dictionary();
			ImageLoaderCache.cacheListOrder = new Array();
		}
		
		public static function remove(id:String):void {
			if (ImageLoaderCache.cacheList[id]) {
				ImageLoaderCache.cacheList[id].bitmapData.dispose();
				ImageLoaderCache.cacheList[id] = null;
				ImageLoaderCache.cacheListOrder.splice(ImageLoaderCache.cacheListOrder.indexOf(id), 1);
			}
		}
		
		override protected function commitData():void
		{
			if (!(this._source is Texture)) {
				const sourceURL:String = this._source as String;
				
				if (sourceURL != this._lastURL) {
					if (ImageLoaderCache.cacheList[sourceURL] != null) {
						this._lastURL = null;
						this._isLoaded = false;
						this._texture = null;
						
						this._texture = Texture.fromBitmap(ImageLoaderCache.cacheList[sourceURL]);
						this.refreshCurrentTexture();
						this._isLoaded = true;
						this.invalidate(INVALIDATION_FLAG_SIZE);
						this.dispatchEventWith(starling.events.Event.COMPLETE);
						return;
					}
				}
			}
			super.commitData();
		}
		
		override protected function loader_completeHandler(event:flash.events.Event):void
		{
			const bitmap:Bitmap = Bitmap(this.loader.content);
			this.loader.contentLoaderInfo.removeEventListener(flash.events.Event.COMPLETE, loader_completeHandler);
			this.loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, loader_errorHandler);
			this.loader.contentLoaderInfo.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, loader_errorHandler);
			this.loader = null;
			
			this._texture = Texture.fromBitmap(bitmap);
			this.refreshCurrentTexture();
			this._isLoaded = true;
			this.invalidate(INVALIDATION_FLAG_SIZE);
			this.dispatchEventWith(starling.events.Event.COMPLETE);
			
			if (ImageLoaderCache.cacheList[this._source] == null) {
				if (ImageLoaderCache.cacheListOrder.length >= MAX_ITEMS) {
					remove(ImageLoaderCache.cacheListOrder[0]);
				}
				ImageLoaderCache.cacheList[this._source] = bitmap;
				ImageLoaderCache.cacheListOrder.push(this._source);
			}
		}
		
	}
}