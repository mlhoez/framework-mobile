/**
 * Created by Maxime on 21/10/15.
 */
package com.ludofactory.mobile.core.avatar.test.manager
{
	
	import com.ludofactory.mobile.core.avatar.test.events.LKAvatarMakerEventTypes;
	
	import dragonBones.Armature;
	import dragonBones.factorys.StarlingFactory;
	
	import flash.events.Event;
	import flash.utils.ByteArray;
	
	import starling.events.EventDispatcher;
	import starling.textures.TextureSmoothing;
	
	public class FactoryManager extends EventDispatcher
	{
		private static var NUM_FACTORIES_TO_LOAD:int = 2;
		
		/**
		 * The custom native factory. */
		//private var _nativeFactory:NativeFactory;
		/**
		 * The Starling factory. */
		private var _starlingFactory:StarlingFactory;
		
		private var _numFactoriesLoaded:int = 0;
		
		public function FactoryManager()
		{
			// native
			//_nativeFactory = new NativeFactory();
			////CustomNativeFactory(_nativeFactory).areSubItemsAnimated = animated;
			////CustomNativeFactory(_nativeFactory).useBitmapDataTexture = _rasterized;
		
			// starling
			_starlingFactory = new StarlingFactory();
			StarlingFactory(_starlingFactory).displaySmoothing = TextureSmoothing.TRILINEAR;
			
			NUM_FACTORIES_TO_LOAD = 1;
		}
		
		/**
		 * Parse data.
		 * 
		 * @param data
		 */
		public function parseData(data:ByteArray):void
		{
			//_nativeFactory.addEventListener(Event.COMPLETE, onFactoryReady);
			//_nativeFactory.parseData(data);
			
			_starlingFactory.addEventListener(Event.COMPLETE, onFactoryReady);
			_starlingFactory.parseData(data);
		}
		
		/**
		 * On factory ready.
		 * 
		 * @param event
		 */
		private function onFactoryReady(event:Event):void
		{
			event.target.removeEventListener(Event.COMPLETE, onFactoryReady);
			_numFactoriesLoaded++;
			if(_numFactoriesLoaded == NUM_FACTORIES_TO_LOAD)
				dispatchEventWith(LKAvatarMakerEventTypes.ALL_FACTORIES_READY);
		}
		
		public function buildArmature(avatarDisplayType:String, armatureName:String, animationName:String = null, skeletonName:String = null, textureAtlasName:String = null, skinName:String = null):Armature
		{
			//if(avatarDisplayType == AvatarDisplayerType.NATIVE)
			//	return _nativeFactory.buildArmature(armatureName, animationName, skeletonName, textureAtlasName, skinName);
			//else
				return _starlingFactory.buildArmature(armatureName, animationName, skeletonName, textureAtlasName, skinName);
		}
		
	}
}