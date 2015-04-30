/*
Copyright © 2006-2015 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 23 mai 2014
*/
package com.ludofactory.mobile.core.avatar
{
	//import com.jirbo.airadc.AirAdColony;
	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.HeartBeat;
	import com.ludofactory.mobile.core.controls.AdvancedScreen;
	import com.ludofactory.mobile.core.config.GlobalConfig;

	import dragonBones.factorys.BaseFactory;

	import flash.events.Event;
	import flash.events.StatusEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	
	import dragonBones.Armature;
	import dragonBones.animation.WorldClock;
	import dragonBones.factorys.StarlingFactory;
	
	import feathers.controls.Button;
	
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.extensions.PDParticleSystem;
	import starling.textures.Texture;

	/**
	 * Avatar Screen
	 * 
	 * Référnce :
	 * 
	 * To add another DisplayObject to an existing Bone :
	 * 
	 * var horseHead:Bone = _armature.getBone("horseHead");
	 * var exhaust:PDParticleSystem = new PDParticleSystem(new XML(new ParticleCFG()), Texture.fromBitmap(new ParticleImage()));
	 * var particle:Slot = new Slot(new StarlingDisplayBridge());
	 * particle.fixedRotation = true;
	 * particle.display = exhaust;
	 * particle.origin.x = horseEye.global.x;
	 * particle.origin.y = horseEye.global.y;
	 * particle.zOrder = 100;
	 * horseHead.addChild(particle);
	 * 
	 * childArmature.animation.gotoAndPlay...
	 * childArmature.animation.getBone...
	 */	
	public class AvatarScreenTooki extends AdvancedScreen
	{
		private var _animList:Array = ["base", "anime1", "anime2"];
		private var _currentIndex:int = 0;
		private var _switchButton:Button;
		private var _switchWeaponButton:Button;
		
		private var _weapons:Array = ["clips/accessoire0", "clips/accessoire1"];
		private var _weaponIndex:int= 0;
		
		public function AvatarScreenTooki()
		{
			super();
			
			_fullScreen = true;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			
			
			AbstractEntryPoint.assets.enqueue(File.applicationDirectory.resolvePath("assets/avatar/"));
			AbstractEntryPoint.assets.loadQueue(onProgress);
			
			_switchButton = new Button();
			_switchButton.label = _("Changer anim");
			_switchButton.addEventListener(starling.events.Event.TRIGGERED, onSwitch);
			addChild(_switchButton);
			
			_switchWeaponButton = new Button();
			_switchWeaponButton.label = _("Changer arme");
			_switchWeaponButton.addEventListener(starling.events.Event.TRIGGERED, onSwitchWeapon);
			addChild(_switchWeaponButton);
			
			
			/*_adColony = new AirAdColony();
			if (_adColony.isSupported())
			{
				_adColony.adcContext.addEventListener(StatusEvent.STATUS, handleAdColonyEvent);
				if (_adColony.is_iOS)
				{
					cur_app_id = ios_app_id;
					cur_video_zone = ios_video_zone;
					cur_v4vc_zone = ios_v4vc_zone;
				}
				else
				{
					cur_app_id = android_app_id;
					cur_video_zone = android_video_zone;
					cur_v4vc_zone = android_v4vc_zone;
				}
				AdColony.configure("1.0",cur_app_id,cur_video_zone,cur_v4vc_zone);
			}*/
		}
		
		private function handleAdColonyEvent(event:StatusEvent):void
		{
			
		}
		
		
		//private var _adColony:AirAdColony;
		
		override protected function draw():void
		{
			super.draw();
			
			if( isInvalid(INVALIDATION_FLAG_DATA) )
			{
				_switchWeaponButton.validate();
				_switchWeaponButton.x = actualWidth - _switchWeaponButton.width;
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Loading progress
		
		private function onProgress(ratio:Number):void
		{
			if( ratio == 1 )
				createAvatar();
		}
		
		private var _factory:StarlingFactory;
		private var _armature:Armature;
		
		private function createAvatar():void
		{
			var img:Image = new Image( AbstractEntryPoint.assets.getTexture("bg"));
			//img.scaleX = img.scaleY = Utilities.getScaleToFill(actualWidth, actualHeight, img.width, img.height);
			img.width = actualWidth;
			img.height = actualHeight;
			addChildAt(img, 0);
			
			// v1
			_factory = new StarlingFactory();
			//_factory.addTextureAtlas(AbstractEntryPoint.assets.getTextureAtlas("texture"), "Zombie");
			//_factory.addSkeletonData(XMLDataParser.parseSkeletonData(AbstractEntryPoint.assets.getXml("skeleton")));
			//onComplete();
			
			// v2
			_factory.scaleForTexture = GlobalConfig.isPhone ? GlobalConfig.dpiScale * 2 : GlobalConfig.dpiScale * 4;  // = uniquement avec un swf mergé
			var myFileStream:FileStream = new FileStream();
			myFileStream.open(File.applicationDirectory.resolvePath("assets/test/Tooki.dbswf"), FileMode.READ);
			var file_byte:ByteArray = new ByteArray();
			myFileStream.readBytes(file_byte, 0, myFileStream.bytesAvailable);
			_factory.parseData(file_byte, "Tooki");
			_factory.addEventListener(flash.events.Event.COMPLETE, onComplete);
		}
		
		private function onComplete(event:flash.events.Event = null):void
		{
			_armature = _factory.buildArmature("tooki", null, null, "Tooki");
			// 1 = name of the armature = movieclip containing animations in Flash Pro
			
			
			_armature.display.scaleX = _armature.display.scaleY = GlobalConfig.isPhone ? GlobalConfig.dpiScale * 2 : GlobalConfig.dpiScale * 4;
			
			addChild(_armature.display as Sprite);
			
			_armature.display.x = GlobalConfig.stageWidth * (GlobalConfig.isPhone ? 0.5 : 0.35);
			_armature.display.y = (actualHeight) * (GlobalConfig.isPhone ? 0.6 : 0.7);
			
			WorldClock.clock.add(_armature);
			_armature.animation.gotoAndPlay(_animList[_currentIndex]);
			_armature.animation.timeScale = 0.65;
			
			(_armature.display as Sprite).addChild( new Quad(5, 5, 0xff0000) );
			
			HeartBeat.registerFunction(updateAvatar);
			
			
			//addChild(BaseFactory.TT);
			
			
			//var bone:Vector.<Bone> = (_armature.getBone("telephonepole") as Bone).armature.getBones();
			//var bone:Bone = _armature.getBone("telephonepole");
			//log("lol");
			
			//_armature.getBone("telephonepole").display = (new Quad(10,10,0x00ff00));
			
			/*var fileStream:FileStream = new FileStream();
			fileStream.open( File.applicationDirectory.resolvePath( "assets/particles/particles_pyramid.pex" ), FileMode.READ );
			var onTouchParticlesXml:XML = XML(fileStream.readUTFBytes(fileStream.bytesAvailable));
			fileStream.close();
			
			_onTouchParticles = new PDParticleSystem(onTouchParticlesXml, Theme.particleSparklesTexture);
			_onTouchParticles.touchable = false;
			_onTouchParticles.maxNumParticles = 300;
			_onTouchParticles.scaleX = _onTouchParticles.scaleY = GlobalConfig.dpiScale;
			Starling.juggler.add(_onTouchParticles);*/
			
			
			//var b:Bone = new Bone();
			//b.display = _onTouchParticles;
			//b.visible = true;
			
			
			//_onTouchParticles.start(100);
			
			//_armature.addBone(b, "telephonepole");
			//_armature.addChild(b);
			//addChild(_onTouchParticles);
			//var arr:Array = _armature.getBone("telephonepole").slot.displayList;
			//arr.push(_onTouchParticles);
		//	_armature.
		}
		
		private var _onTouchParticles:PDParticleSystem;
		
		private function updateAvatar(elapsedTime:int):void
		{
			WorldClock.clock.advanceTime(-1);
		}
		
		private function onSwitchWeapon(event:starling.events.Event):void
		{
			_weaponIndex++;
			if( _weaponIndex >= _weapons.length )
				_weaponIndex = 0;
			
			if( _armature.getBone("accessoire").display )
				_armature.getBone("accessoire").display.dispose();
			_armature.getBone("accessoire").display = _factory.getTextureDisplay(_weapons[_weaponIndex], "Tooki");
		}
		
		/**
		 * Switch the current animation.
		 */		
		private function onSwitch(event:starling.events.Event):void
		{
			_currentIndex++;
			if( _currentIndex > _animList.length - 1 )
				_currentIndex = 0;
			_armature.animation.gotoAndPlay(_animList[_currentIndex]);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
		
		override public function dispose():void
		{
			// TODO
			
			super.dispose();
		}
		
	}
}