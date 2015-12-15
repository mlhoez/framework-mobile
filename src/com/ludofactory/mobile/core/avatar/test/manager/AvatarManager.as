/**
 * Created by Maxime on 06/07/15.
 */
package com.ludofactory.mobile.core.avatar.test.manager
{
	
	import com.adobe.images.PNGEncoder;
	import com.greensock.TweenMax;
	import com.ludofactory.common.encryption.Base64;
	import com.ludofactory.common.utils.Utilities;
	import com.ludofactory.common.utils.log;
	import com.ludofactory.mobile.core.avatar.test.config.AvatarDisplayerType;
	import com.ludofactory.mobile.core.avatar.test.config.AvatarGenderType;
	import com.ludofactory.mobile.core.avatar.test.config.LudokadoBones;
	import com.ludofactory.mobile.core.avatar.test.events.LKAvatarMakerEventTypes;
	
	import dragonBones.Armature;
	import dragonBones.Bone;
	import dragonBones.animation.WorldClock;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.FrameLabel;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.display.PixelSnapping;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedSuperclassName;
	
	import starling.core.Starling;
	import starling.display.Image;
	import starling.events.Event;
	import starling.events.EventDispatcher;
	import starling.textures.TextureSmoothing;
	
	/**
	 * Avatar manager.
	 */
	public class AvatarManager extends EventDispatcher
	{
		
		private static var _instance:AvatarManager;
		
	// ---------- Helper values
		
		// common
		
		/**
		 * Helper matrix used to scale the assets when the avatar is rasterized. */
		private var HELPER_MATRIX:Matrix;
		/**
		 * Helper bitamp data used to avoid too much memory allocations. */
		private var HELPER_BITMAP_DATA:BitmapData;
		/**
		 * Helper bitamp used to avoid too much memory allocations. */
		private var HELPER_BITMAP:Bitmap;
		
		/**
		 * Helper content used to store the assets retrieved from the SWFs assets. */
		private var HELPER_CONTENT:DisplayObject;
		
		protected static var HELPER_LABELS:Array = [];
		protected static var HELPER_LENGTH:int = 0;
		
		// native displayer
		
		/**
		 * Helper container used to store the rasterized assets. */
		private var HELPER_CONTAINER:Sprite;
		
	// ---------- Other
		
		/**
		 * The avatar itself. */
		private var _avatar:Armature;
		/**
		 * The scale factor (used when the avatar is rasterized). */
		private var _scale:Number;
		
		/**
		 * Helper bone. */
		private var _helperBone:Bone;
		/**
		 * Helper display. */
		private var _helperDisplay:Object;
		
		/**
		 * The assets loader. */
		private var _assetsLoader:Loader;
		/**
		 * Array of assets to load. */
		private var _assetsToLoad:Array;
		/**
		 * The stored assets. */
		private var _assets:Dictionary;
		
		private var _rasterized:Boolean = false;
		
		/**
		 *  */
		private var _binaryDataLoader:URLLoader;
		
		private var _armatureUrl:String;
		
		private var _urlRequest:URLRequest;
		
		private var _factoryManager:FactoryManager;
		
		public function AvatarManager(sk:SecurityKey)
		{
			if(sk == null)
				throw new Error("Erreur : Echec de l'instanciation : Utiliser AvatarManager.getInstance() au lieu de new.");
		}
		
//------------------------------------------------------------------------------------------------------------
//
		
		/**
		 * Initializes the AvatarManager
		 * 
		 * @param armatureUrl use AvatarManagerType
		 * @param assetsToLoad use AvatarManagerType
		 * @param scale
		 */
		public function initialize(armatureUrl:String, assetsToLoad:Array, scale:Number = 1):void
		{
			_scale = scale;
			_armatureUrl = armatureUrl;
			_assetsToLoad = assetsToLoad;
			
			_factoryManager = new FactoryManager();
			
			// build the dictionary
			_assets = new Dictionary();
			
			// load the armature as ByteArray
			_urlRequest = new URLRequest();
			_urlRequest.url = _armatureUrl;
			var header:URLRequestHeader = new URLRequestHeader("pragma", "no-cache");
			_urlRequest.data = new URLVariables("cache=no+cache");
			_urlRequest.method = URLRequestMethod.POST;
			_urlRequest.requestHeaders.push(header);
			
			_binaryDataLoader = new URLLoader();
			_binaryDataLoader.dataFormat = URLLoaderDataFormat.BINARY;
			_binaryDataLoader.addEventListener(flash.events.Event.COMPLETE, onArmatureLoaded);
			_binaryDataLoader.addEventListener(IOErrorEvent.IO_ERROR, onArmatureNotLoaded);
			_binaryDataLoader.load(_urlRequest);
		}
		
		/**
		 * The armature have been loaded.
		 */
		private function onArmatureLoaded(event:flash.events.Event):void
		{
			log("[AvatarManager] Armature loaded.");
			
			_binaryDataLoader.removeEventListener(flash.events.Event.COMPLETE, onArmatureLoaded);
			_binaryDataLoader.removeEventListener(IOErrorEvent.IO_ERROR, onArmatureNotLoaded);
			
			// parse the armature
			
			_factoryManager.addEventListener(LKAvatarMakerEventTypes.ALL_FACTORIES_READY, onFactoriesReady);
			_factoryManager.parseData(_binaryDataLoader.data);
		}
		
		/**
		 * Once the factory is ready and the armature data parsed, we can start to load all the assets
		 *
		 * //_avatar.animation.timeScale = 0.5;
		 * 
		 * @param event
		 */
		private function onFactoriesReady(event:starling.events.Event):void
		{
			_factoryManager.removeEventListener(LKAvatarMakerEventTypes.ALL_FACTORIES_READY, onFactoriesReady);
			
			var ldrContext:LoaderContext = new LoaderContext(false, ApplicationDomain.currentDomain);
			
			_urlRequest.url = _assetsToLoad[0].assetsUrl;
			_assetsLoader = new Loader();
			_assetsLoader.contentLoaderInfo.addEventListener(flash.events.Event.COMPLETE, onAssetsLoaded);
			_assetsLoader.load(_urlRequest, ldrContext);
		}
		
		/**
		 * The armature could not be loaded.
		 */
		private function onArmatureNotLoaded(event:IOErrorEvent):void
		{
			log("[AvatarManager] Armature not loaded.");
			
			_binaryDataLoader.removeEventListener(flash.events.Event.COMPLETE, onArmatureLoaded);
			_binaryDataLoader.removeEventListener(IOErrorEvent.IO_ERROR, onArmatureNotLoaded);
			
			// TODO displatcher un event ici, puis deux cas :
			//  - soit on est sur mobile et il faut alors prendre l'armature par défaut (dernière mise à jour) puis charger les assets
			//  - soit on est sur le site et il faut afficher une erreur
			dispatchEventWith(LKAvatarMakerEventTypes.ARMATURE_NOT_LOADED);
		}
		
		/**
		 * When the assets have been loaded.
		 */
		private function onAssetsLoaded(event:flash.events.Event):void {
			
			if (_assetsToLoad.length > 0)
			{
				var data:Object = _assetsToLoad.shift();
				_assets[data.genderId] = event.target as LoaderInfo;
			}
			
			if (_assetsToLoad.length > 0)
			{
				// load next
				_assetsLoader.contentLoaderInfo.removeEventListener(flash.events.Event.COMPLETE, onAssetsLoaded);
				
				// we need to create a new one or the contentLoaderInfo will be erased at each new loading
				_assetsLoader = new Loader();
				_assetsLoader.contentLoaderInfo.addEventListener(flash.events.Event.COMPLETE, onAssetsLoaded);
				_urlRequest.url = _assetsToLoad[0].assetsUrl;
				_assetsLoader.load(_urlRequest);
			}
			else
			{
				// ready
				_assetsLoader.contentLoaderInfo.removeEventListener(flash.events.Event.COMPLETE, onAssetsLoaded);
				
				// FIXME A remettre si besoin
				Starling.current.nativeStage.addEventListener(flash.events.Event.ENTER_FRAME, onNativeEnterFrameHandler);
				
				// FIXME chercher comment améliorer ça, si pas de délais, certains éléments ne s'affichent pas 'ne semblent pas être dispo)
				Starling.juggler.delayCall(dispatchEventWith, 1, LKAvatarMakerEventTypes.AVATAR_READY)
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	
		
		/**
		 * Sets the temporary items to the given armature.
		 * 
		 * @param avatar
		 */
		private function setTempItems(avatar:Armature):void
		{
			var currentConfig:LKAvatarConfig = LKConfigManager.getConfigByGender(AvatarData(avatar.userData).genderId);
			
			// then update the graphics accordingly (not all of them because some are linked)
			// the skin color will update the right and left hands, the head, nose and body (for the humans only), faceCustom (boy & girl)
			update(avatar, LudokadoBones.SKIN_COLOR, currentConfig.skinColor.tempLinkageName);
			// the hair color will update the hair, eyebrows, back hair, moustache (potato & boy), beard (boy) and only for the potato : body
			update(avatar, LudokadoBones.HAIR_COLOR, currentConfig.hairColor.tempLinkageName);
			// the eyes color will update the eyes
			update(avatar, LudokadoBones.EYES_COLOR, currentConfig.eyesColor.tempLinkageName);
			// the lips color will update the mouth
			update(avatar, LudokadoBones.LIPS_COLOR, currentConfig.lipsColor.tempLinkageName);
			// update the shirt
			update(avatar, LudokadoBones.SHIRT, currentConfig.shirt.tempLinkageName);
			// update the hat
			update(avatar, LudokadoBones.HAT, currentConfig.hat.tempLinkageName);
			// and the pant for humans
			if(LKConfigManager.currentGenderId != AvatarGenderType.POTATO)
				update(avatar, LudokadoBones.PANT, currentConfig.pant.tempLinkageName);
			// the epaulet for the potato
			if(LKConfigManager.currentGenderId == AvatarGenderType.POTATO)
				update(avatar, LudokadoBones.EPAULET, currentConfig.epaulet.tempLinkageName);
		}
		
		/**
		 * Sets the user items for the given armature.
		 * 
		 * @param avatar
		 */
		private function setUserItems(avatar:Armature):void
		{
			var currentConfig:LKAvatarConfig = LKConfigManager.getConfigByGender(AvatarData(avatar.userData).genderId);
			
			log("Current config = ");
			log(currentConfig);
			
			// then update the graphics accordingly (not all of them because some are linked)
			// the skin color will update the right and left hands, the head, nose and body (for the humans only), faceCustom (boy & girl)
			update(avatar, LudokadoBones.SKIN_COLOR, currentConfig.skinColor.linkageName);
			// the hair color will update the hair, eyebrows, back hair, moustache (potato & boy), beard (boy) and only for the potato : body
			update(avatar, LudokadoBones.HAIR_COLOR, currentConfig.hairColor.linkageName);
			// the eyes color will update the eyes
			update(avatar, LudokadoBones.EYES_COLOR, currentConfig.eyesColor.linkageName);
			// the lips color will update the mouth
			update(avatar, LudokadoBones.LIPS_COLOR, currentConfig.lipsColor.linkageName);
			// update the shirt
			update(avatar, LudokadoBones.SHIRT, currentConfig.shirt.linkageName);
			// update the hat
			update(avatar, LudokadoBones.HAT, currentConfig.hat.linkageName);
			// and the pant for humans
			if(LKConfigManager.currentGenderId != AvatarGenderType.POTATO)
				update(avatar, LudokadoBones.PANT, currentConfig.pant.linkageName);
			// the epaulet for the potato
			if(LKConfigManager.currentGenderId == AvatarGenderType.POTATO)
				update(avatar, LudokadoBones.EPAULET, currentConfig.epaulet.linkageName);
		}
		
		/**
		 * Main update loop.
		 */
		/*private function onStarlingEnterFrameHandler(event:starling.events.Event):void
		{
			WorldClock.clock.advanceTime(-1);
		}*/
		
		/**
		 * Main update loop.
		 */
		private function onNativeEnterFrameHandler(event:flash.events.Event):void
		{
			WorldClock.clock.advanceTime(-1);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Update
		
		/**
		 * Updates the armature section with the new display.
		 *
		 * @param avatar The avatar to update
		 * @param armatureSection
		 * @param linkageName
		 */
		public function update(avatar:Armature, armatureSection:String, linkageName:String):void
		{
			linkageName = linkageName == "" ? (armatureSection + "_0") : linkageName;
			//log("Setting " + linkageName + " for " + armatureSection);
			
			if(armatureSection == LudokadoBones.HAT) // Changement de chapeau
			{
				if(AvatarData(avatar.userData).genderId == AvatarGenderType.POTATO)
				{
					// update the back hair for the potato because the back hair is linked to the hat
					LKConfigManager.getBoneConfigByGender(AvatarData(avatar.userData).genderId, LudokadoBones.BACK_HAIR).tempLinkageName = (LudokadoBones.BACK_HAIR + "_" + LKConfigManager.getBoneConfigByGender(AvatarData(avatar.userData).genderId, LudokadoBones.HAT).tempLinkageExtractedId);
					update(avatar, LudokadoBones.BACK_HAIR, LKConfigManager.getBoneConfigByGender(AvatarData(avatar.userData).genderId, LudokadoBones.BACK_HAIR).tempLinkageName);
				}
				else
				{
					// for humans, we need to update the hair because a hat can only be worn with the hair_0
					update(avatar, LudokadoBones.HAIR, LKConfigManager.getBoneConfigByGender(AvatarData(avatar.userData).genderId, LudokadoBones.HAIR).tempLinkageName);
				}
			}
			
			if(armatureSection == LudokadoBones.HAIR) // Changement de cheveux
			{
				if(AvatarData(avatar.userData).genderId != AvatarGenderType.POTATO)
				{
					if(LKConfigManager.getBoneConfigByGender(AvatarData(avatar.userData).genderId, LudokadoBones.HAT).tempLinkageExtractedId != 0)
					{
						// we updated the hair for the humans. Because the hair cannot be updated if a hat is worn, we
						// need to force the hair_0
						linkageName = LudokadoBones.HAIR +"_0";
					}
					
					LKConfigManager.getBoneConfigByGender(AvatarData(avatar.userData).genderId, LudokadoBones.BACK_HAIR).tempLinkageName = (LudokadoBones.BACK_HAIR + "_" + LKConfigManager.getBoneConfigByGender(AvatarData(avatar.userData).genderId, LudokadoBones.HAIR).tempLinkageExtractedId);
					update(avatar, LudokadoBones.BACK_HAIR, LKConfigManager.getBoneConfigByGender(AvatarData(avatar.userData).genderId, LudokadoBones.BACK_HAIR).tempLinkageName);
				}
			}
			
			if(armatureSection == LudokadoBones.HAIR_COLOR) // Changement de couleur des cheveux
			{
				update(avatar, LudokadoBones.EYEBROWS, LKConfigManager.getBoneConfigByGender(AvatarData(avatar.userData).genderId, LudokadoBones.EYEBROWS).tempLinkageName);
				update(avatar, LudokadoBones.HAIR, LKConfigManager.getBoneConfigByGender(AvatarData(avatar.userData).genderId, LudokadoBones.HAIR).tempLinkageName);
				update(avatar, LudokadoBones.BACK_HAIR, LKConfigManager.getBoneConfigByGender(AvatarData(avatar.userData).genderId, LudokadoBones.BACK_HAIR).tempLinkageName);
				
				if(AvatarData(avatar.userData).genderId == AvatarGenderType.POTATO)
				{
					update(avatar, LudokadoBones.BODY, LKConfigManager.getBoneConfigByGender(AvatarData(avatar.userData).genderId, LudokadoBones.BODY).tempLinkageName);
				}
				
				if(AvatarData(avatar.userData).genderId == AvatarGenderType.POTATO || AvatarData(avatar.userData).genderId == AvatarGenderType.BOY)
				{
					update(avatar, LudokadoBones.MOUSTACHE, LKConfigManager.getBoneConfigByGender(AvatarData(avatar.userData).genderId, LudokadoBones.MOUSTACHE).tempLinkageName);
				}
				
				if(AvatarData(avatar.userData).genderId == AvatarGenderType.BOY)
				{
					update(avatar, LudokadoBones.BEARD, LKConfigManager.getBoneConfigByGender(AvatarData(avatar.userData).genderId, LudokadoBones.BEARD).tempLinkageName);
				}
				
				return;
			}
			
			if(armatureSection == LudokadoBones.SKIN_COLOR) // Changement de couleur de peau
			{
				// changement de la frame des mains, tête, bouche et body (sauf Mr Patate)
				update(avatar, LudokadoBones.LEFT_HAND, LKConfigManager.getBoneConfigByGender(AvatarData(avatar.userData).genderId, LudokadoBones.LEFT_HAND).tempLinkageName);
				update(avatar, LudokadoBones.RIGHT_HAND, LKConfigManager.getBoneConfigByGender(AvatarData(avatar.userData).genderId, LudokadoBones.RIGHT_HAND).tempLinkageName);
				update(avatar, LudokadoBones.HEAD, LKConfigManager.getBoneConfigByGender(AvatarData(avatar.userData).genderId, LudokadoBones.HEAD).tempLinkageName);
				update(avatar, LudokadoBones.NOSE, LKConfigManager.getBoneConfigByGender(AvatarData(avatar.userData).genderId, LudokadoBones.NOSE).tempLinkageName);
				
				if(AvatarData(avatar.userData).genderId != AvatarGenderType.POTATO)
				{
					update(avatar, LudokadoBones.BODY, LKConfigManager.getBoneConfigByGender(AvatarData(avatar.userData).genderId, LudokadoBones.BODY).tempLinkageName);
					update(avatar, LudokadoBones.FACE_CUSTOM, LKConfigManager.getBoneConfigByGender(AvatarData(avatar.userData).genderId, LudokadoBones.FACE_CUSTOM).tempLinkageName);
				}
				
				return;
			}
			
			if(armatureSection == LudokadoBones.EYES_COLOR) // Changements de la couleur des yeux :
			{
				// = changement de la frame des yeux
				update(avatar, LudokadoBones.EYES, LKConfigManager.getBoneConfigByGender(AvatarData(avatar.userData).genderId, LudokadoBones.EYES).tempLinkageName);
				return;
			}
			
			if(armatureSection == LudokadoBones.LIPS_COLOR) // Changements de la couleur des lèvres :
			{
				// = changement de la frame de la bouche
				update(avatar, LudokadoBones.MOUTH, LKConfigManager.getBoneConfigByGender(AvatarData(avatar.userData).genderId, LudokadoBones.MOUTH).tempLinkageName);
				return;
			}
			
			if(armatureSection == LudokadoBones.AGE) // Changement de l'age
			{
				update(avatar, LudokadoBones.HEAD, LKConfigManager.getBoneConfigByGender(AvatarData(avatar.userData).genderId, LudokadoBones.HEAD).tempLinkageName);
				return;
			}
			
			// ------------------
			
			// retrieve the bone from the avatar
			_helperBone = avatar.getBone(armatureSection);
			// then get the asset from the correct asset file
			_helperDisplay = getAsset(avatar, armatureSection, linkageName);
			
			// we found both of them
			if (_helperBone && _helperDisplay)
			{
				_helperDisplay.name = armatureSection;
				_helperBone.display = _helperDisplay;
				if(getQualifiedSuperclassName(_helperDisplay).indexOf("flash") != -1)
				{
					// for flash assets (i.e. vector assets, we enable the click on bones)
					_helperDisplay.mouseChildren = false;
					_helperDisplay.mouseEnabled = true;
				}
				else
				{
					// for Starling assets, we make them non touchable (because the textures are squared, we would need
					// to use pixel pefect touch to be able to click on bones)
					_helperDisplay.touchable = AvatarData(avatar.userData).isTouchable;
				}
				// tell the app we updated a bone
				dispatchEventWith(LKAvatarMakerEventTypes.UPDATED_BONE);
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Utils
		
		
		/**
		 * Finds an asset by linkage name and returns it.
		 *
		 * The result will be a Sprite if the items must be rasterized, something else otherwise.
		 * 
		 * @param avatar
		 * @param boneName
		 * @param assetLinkageName
		 * 
		 * @return
		 */
		private function getAsset(avatar:Armature, boneName:String, assetLinkageName:String):*
		{
			// no matter what happens and specially if the item is not found, it's better to empty the section
			removeDisplayFromBone(avatar, _helperBone);
			
			try
			{
				HELPER_CONTENT = new (_assets[AvatarData(avatar.userData).genderId].applicationDomain.getDefinition(assetLinkageName) as Class)();
			}
			catch(error:Error)
			{
				log("[WARNING] The item " + assetLinkageName + " from the section " + boneName + " does not exist.");
				return new MovieClip();
			}
			
			if (HELPER_CONTENT is MovieClip)
			{
				// first go to the good main frame (which is the declination)
				if(hasLabel(HELPER_CONTENT as MovieClip, LKConfigManager.getBoneConfigByGender(AvatarData(avatar.userData).genderId, boneName).tempFrameName))
					(HELPER_CONTENT as MovieClip).gotoAndStop(LKConfigManager.getBoneConfigByGender(AvatarData(avatar.userData).genderId, boneName).tempFrameName);
				
				// then check for any linked sub movie clips
				checkForClipsToChange(LKConfigManager.getConfigByGender(AvatarData(avatar.userData).genderId), HELPER_CONTENT as MovieClip);
			}
			
			try
			{
				if (_rasterized || AvatarData(avatar.userData).displayType == AvatarDisplayerType.STARLING)
				{
					var bounds:Rectangle = HELPER_CONTENT.getBounds(HELPER_CONTENT);
					if(bounds.width == 0 && bounds.height == 0)
						return HELPER_CONTAINER = new Sprite();
					
					// retrieve the bounds
					HELPER_MATRIX = new Matrix();
					HELPER_MATRIX.translate(bounds.x * -1, bounds.y * -1);
					
					if(HELPER_BITMAP)
					{
						HELPER_BITMAP.bitmapData.dispose();
						HELPER_BITMAP.bitmapData = null;
					}
					HELPER_BITMAP = null;
					
					if(HELPER_BITMAP_DATA)
					{
						HELPER_BITMAP_DATA.dispose();
					}
					HELPER_BITMAP_DATA = null;
					
					// then draw tha MovieClip / Sprite into a Bitmap
					HELPER_BITMAP_DATA = new BitmapData(getNearest2N(HELPER_CONTENT.width), getNearest2N(HELPER_CONTENT.height), true, 0xFFFFFF);
					HELPER_BITMAP_DATA.drawWithQuality(HELPER_CONTENT, HELPER_MATRIX, null, null, null, true, StageQuality.BEST);
					HELPER_BITMAP = new Bitmap(HELPER_BITMAP_DATA, PixelSnapping.NEVER, true);
				
					if(AvatarData(avatar.userData).displayType == AvatarDisplayerType.NATIVE)
					{
						// native
						// handle pivot point in native display list
						HELPER_BITMAP.x = bounds.x;
						HELPER_BITMAP.y = bounds.y;
						
						HELPER_CONTAINER = new Sprite();
						HELPER_CONTAINER.addChild(HELPER_BITMAP);
					}
					else
					{
						// starling
						var image:Image = Image.fromBitmap(HELPER_BITMAP);
						image.smoothing = TextureSmoothing.BILINEAR;
						image.pivotX = -bounds.x;
						image.pivotY = -bounds.y;
						return image;
					}
				
					// just in case, stop it
					if( (HELPER_CONTENT is MovieClip))
						(HELPER_CONTENT as MovieClip).gotoAndStop(1);
				
					HELPER_CONTENT = null;
					return HELPER_CONTAINER;
				}
				else
				{
					return HELPER_CONTENT;
				}
			}
			catch(error:Error)
			{
				log("Error when rasterizing : " + error);
			}
		}
		
		
		
		private function hasLabel(clip:MovieClip, frameLabelToCheck:String):Boolean
		{
			if(frameLabelToCheck == null || frameLabelToCheck == "")
				return false;
			
			HELPER_LABELS = clip.currentLabels;
			HELPER_LENGTH = HELPER_LABELS.length;
			for (var i:int = 0; i < HELPER_LENGTH; i++)
			{
				if(frameLabelToCheck == FrameLabel(HELPER_LABELS[i]).name)
					return true;
			}
			return false;
		}
		
		/**
		 * recursively
		 */
		private function checkForClipsToChange(config:LKAvatarConfig, clip:MovieClip):void
		{
			if( clip.getChildByName(LudokadoBones.AGE) )
			{
				if( hasLabel(clip.getChildByName(LudokadoBones.AGE) as MovieClip, LudokadoBoneConfiguration(config[LudokadoBones.AGE]).tempFrameName) )
					(clip.getChildByName(LudokadoBones.AGE) as MovieClip).gotoAndStop(LudokadoBoneConfiguration(config[LudokadoBones.AGE]).tempFrameName);
				
				checkForClipsToChange(config, clip.getChildByName(LudokadoBones.AGE) as MovieClip);
			}
			
			if( clip.getChildByName(LudokadoBones.HAIR_COLOR) )
			{
				if( hasLabel(clip.getChildByName(LudokadoBones.HAIR_COLOR) as MovieClip, LudokadoBoneConfiguration(config[LudokadoBones.HAIR_COLOR]).tempFrameName) )
					(clip.getChildByName(LudokadoBones.HAIR_COLOR) as MovieClip).gotoAndStop(LudokadoBoneConfiguration(config[LudokadoBones.HAIR_COLOR]).tempFrameName);
				
				checkForClipsToChange(config, clip.getChildByName(LudokadoBones.HAIR_COLOR) as MovieClip);
			}
			
			if( clip.getChildByName(LudokadoBones.SKIN_COLOR) )
			{
				if( hasLabel(clip.getChildByName(LudokadoBones.SKIN_COLOR) as MovieClip, LudokadoBoneConfiguration(config[LudokadoBones.SKIN_COLOR]).tempFrameName) )
					(clip.getChildByName(LudokadoBones.SKIN_COLOR) as MovieClip).gotoAndStop(LudokadoBoneConfiguration(config[LudokadoBones.SKIN_COLOR]).tempFrameName);
				
				checkForClipsToChange(config, clip.getChildByName(LudokadoBones.SKIN_COLOR) as MovieClip);
			}
			
			if( clip.getChildByName(LudokadoBones.EYES_COLOR) )
			{
				if( hasLabel(clip.getChildByName(LudokadoBones.EYES_COLOR) as MovieClip, LudokadoBoneConfiguration(config[LudokadoBones.EYES_COLOR]).tempFrameName) )
					(clip.getChildByName(LudokadoBones.EYES_COLOR) as MovieClip).gotoAndStop(LudokadoBoneConfiguration(config[LudokadoBones.EYES_COLOR]).tempFrameName);
				
				checkForClipsToChange(config, clip.getChildByName(LudokadoBones.EYES_COLOR) as MovieClip);
			}
			
			if( clip.getChildByName(LudokadoBones.LIPS_COLOR) )
			{
				if( hasLabel(clip.getChildByName(LudokadoBones.LIPS_COLOR) as MovieClip, LudokadoBoneConfiguration(config[LudokadoBones.LIPS_COLOR]).tempFrameName) )
					(clip.getChildByName(LudokadoBones.LIPS_COLOR) as MovieClip).gotoAndStop(LudokadoBoneConfiguration(config[LudokadoBones.LIPS_COLOR]).tempFrameName);
				
				checkForClipsToChange(config, clip.getChildByName(LudokadoBones.LIPS_COLOR) as MovieClip);
			}
		}
		
		/**
		 * Helper function to quickly remove a displayObject from a bone.
		 */
		public function removeDisplayFromBone(avatar:Armature, bone:Bone):void
		{
			if (!bone || !bone.display)
				return;
			
			if(bone.display.parent)
			{
				if(AvatarData(avatar.userData).displayType == AvatarDisplayerType.NATIVE)
				{
					bone.display.parent.removeChild(bone.display);
				}
				else
				{
					// also dispose the texture or we get the following error :
					// Error #3691: La limite de ressources correspondant à ce type de ressources a été dépassée.
					Image(bone.display).texture.dispose();
					Image(bone.display).removeFromParent(true);
				}
			}
			bone.display = null;
		}
		
		/**
		 * Returns the nearest POT value.
		 */
		private static function getNearest2N(_n:uint):uint
		{
			return _n & _n - 1 ? 1 << _n.toString(2).length : _n;
		}
		
//------------------------------------------------------------------------------------------------------------
//	Image creation (only for native display list)
		
		//private var _tempImg:Image;
		
		public function getPng(genderId:int, useTemporaryItems:Boolean):void
		{
			var avatar:Armature = getAvatar(genderId, AvatarDisplayerType.NATIVE);
			WorldClock.clock.add(avatar);
			avatar.animation.gotoAndPlay("fixed");
			
			if(useTemporaryItems) setTempItems(avatar);
			else setUserItems(avatar);
			
			Starling.juggler.delayCall(getBitmapData, 0.5, avatar);
		}
		
		/**
		 * get image to avatar
		 */
		public function getBitmapData(avatarToDraw:Armature):void
		{
			// get bounds
			var bounds:Rectangle = (avatarToDraw.display as DisplayObject).getBounds(avatarToDraw.display as DisplayObject);
			// then scale the avatar to fit the reference size
			var scale:Number = Utilities.getScaleToFill(LKConfigManager.imageRefDimensions.width, LKConfigManager.imageRefDimensions.height, LKConfigManager.imageDimensions.width, LKConfigManager.imageDimensions.height); // 440x600 = ref (avatar designed for) - other is the size to fit in
			
			HELPER_MATRIX = new Matrix();
			HELPER_MATRIX.scale(scale, scale);
			var gap:int = 70;
			HELPER_MATRIX.translate((LKConfigManager.imageDimensions.width * 0.5 + gap), (LKConfigManager.imageDimensions.height + ((bounds.height + bounds.y) * -scale)));
			
			HELPER_BITMAP_DATA = new BitmapData(LKConfigManager.imageDimensions.width, LKConfigManager.imageDimensions.height, true, 0xFFFFFF);
			HELPER_BITMAP_DATA.drawWithQuality(avatarToDraw.display as Sprite, HELPER_MATRIX, null, null, null, true, StageQuality.HIGH);
			
			HELPER_BITMAP = new Bitmap(HELPER_BITMAP_DATA, PixelSnapping.NEVER, true);
			HELPER_BITMAP.smoothing = true;
			
			/*if(!_tempImg)
			{
				_tempImg = new Image(Texture.fromBitmap(HELPER_BITMAP));
				_tempImg.touchable = false;
				_tempImg.scaleX = _tempImg.scaleY = 0.85;
				_tempImg.alpha = 0.75;
				(Starling.current.root as StarlingRoot).addChild(_tempImg);
			}
			else
			{
				_tempImg.texture = Texture.fromBitmap(HELPER_BITMAP);
			}*/
			
			dispatchEventWith(LKAvatarMakerEventTypes.AVATAR_IMAGE_CREATED, false, Base64.encodeByteArray(PNGEncoder.encode(HELPER_BITMAP.bitmapData)));
			
			HELPER_BITMAP.bitmapData.dispose();
			HELPER_BITMAP.bitmapData = null;
			HELPER_BITMAP = null;
			
			WorldClock.clock.remove(avatarToDraw);
			avatarToDraw.dispose();
			avatarToDraw = null;
		}
		
//------------------------------------------------------------------------------------------------------------
//	
		
		/**
		 * Changes the current avatar.
		 * 
		 * @param avatarDisplayType Whether native or starling display
		 */
		public function changeAvatar(avatarDisplayType:String):void
		{
			disposeCurrent();
			
			var savedPosition:Point = _avatar ? new Point(_avatar.display.x, _avatar.display.y) : new Point();
			
			_avatar = _factoryManager.buildArmature(avatarDisplayType, AvatarGenderType.gerGenderNameById(LKConfigManager.currentGenderId));
			_avatar.userData = new AvatarData(LKConfigManager.currentGenderId, avatarDisplayType, false);
			_avatar.cacheFrameRate = 60;
			WorldClock.clock.add(_avatar);
			
			/*if(_type == AvatarDisplayerType.STARLING)
				_avatar.display.addEventListener(starling.events.Event.ENTER_FRAME, onStarlingEnterFrameHandler);
			else
				_avatar.display.addEventListener(flash.events.Event.ENTER_FRAME, onNativeEnterFrameHandler);*/
			
			_avatar.animation.gotoAndPlay(LKConfigManager.defaultAnimationName);
			_avatar.display.scaleX = _avatar.display.scaleY = _scale;
			_avatar.display.x = savedPosition.x;
			_avatar.display.y = savedPosition.y;
			
			savedPosition = null;
			
			TweenMax.delayedCall(5, setUserItems, [_avatar]);
			TweenMax.delayedCall(10, setUserItems, [_avatar]);
			
			dispatchEventWith(starling.events.Event.COMPLETE);
		}
		
		/**
		 * Returns an avatar, built with the current gender configuration.
		 * 
		 * @param genderId The gender id
		 * @param avatarDisplayType Whether native or starling display
		 * 
		 * @return
		 */
		public function getAvatar(genderId:int, avatarDisplayType:String):Armature
		{
			var avatar:Armature = _factoryManager.buildArmature(avatarDisplayType, AvatarGenderType.gerGenderNameById(genderId));
			avatar.userData = new AvatarData(genderId, avatarDisplayType, true);
			avatar.animation.gotoAndPlay(LKConfigManager.defaultAnimationName);
			
			// if the avatar is owned, we need to show its configuration so that the user is not confused
			if(LKConfigManager.getConfigByGender(genderId).isOwned)
				setUserItems(avatar);
			
			return avatar;
		}
		
//------------------------------------------------------------------------------------------------------------
//	Get - Set
		
		public function get currentAvatar():Armature { return _avatar; }
		public function get currentAvatarDisplayType():String { return AvatarData(_avatar.userData).displayType; }
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
		
		public function disposeCurrent():void
		{
			if( _avatar )
			{
				if(AvatarData(currentAvatar.userData).displayType == AvatarDisplayerType.STARLING)
				{
					//_avatar.display.removeEventListener(starling.events.Event.ENTER_FRAME, onStarlingEnterFrameHandler);
					_avatar.display.removeFromParent(true);
				}
				else
				{
					//_avatar.display.removeEventListener(flash.events.Event.ENTER_FRAME, onNativeEnterFrameHandler);
					_avatar.display.parent.removeChild(_avatar.display);
				}
				WorldClock.clock.remove(_avatar);
				_avatar.dispose();
				
				// TODO unload assets
			}
		}
		
		public function dispose():void
		{
			// TODO dispose tout
			
			disposeCurrent();
			
			// remove events, etc.
		}
		
//------------------------------------------------------------------------------------------------------------
//	Singleton
		
		/**
		 * Singleton.
		 */
		public static function getInstance():AvatarManager
		{
			if(_instance == null)
				_instance = new AvatarManager(new SecurityKey());
			return _instance;
		}
		
	}
}

internal class SecurityKey{}