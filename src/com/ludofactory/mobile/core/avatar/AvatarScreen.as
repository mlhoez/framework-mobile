/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 23 mai 2014
*/
package com.ludofactory.mobile.core.avatar
{
	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.common.utils.logs.log;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.HeartBeat;
	import com.ludofactory.mobile.core.controls.AdvancedScreen;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	
	import dragonBones.Armature;
	import dragonBones.Bone;
	import dragonBones.animation.WorldClock;
	import dragonBones.factorys.StarlingFactory;
	
	import feathers.controls.Button;
	
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.extensions.PDParticleSystem;
	
	/**
	 * Avatar Screen
	 */	
	public class AvatarScreen extends AdvancedScreen
	{
		private var _animList:Array = ["anim_idle", "anim_walk", "anim_smash", "anim_throw", "anim_death"];
		private var _animList2:Array = ["anim_idle", "anim_walk", "anim_eat", "anim_pop", "anim_death"];
		private var _animListImp:Array = ["anim_land", "anim_walk", "anim_eat", "anim_thrown", "anim_death"];
		private var _animListDolph:Array = ["anim_idle", "anim_walkdolphin", "anim_walk", "anim_jumpinpool", "anim_ride", "anim_dolphinjump", "anim_eat", "anim_swim", "anim_death"];
		private var _animListPole:Array = ["anim_walk", "anim_death", "anim_eat", "anim_idle", "anim_run", "anim_jump"];
		private var _currentIndex:int = 0;
		private var _currentIndexDolph:int = 0;
		private var _currentIndexPole:int = 0;
		private var _switchButton:Button;
		private var _switchWeaponButton:Button;
		
		private var _weapons:Array = ["Zombie_gargantuar_folder/Zombie_gargantuar_telephonepole", "Zombie_gargantuar_folder/weapon1", "Zombie_gargantuar_folder/weapon2", "Zombie_gargantuar_folder/weapon3"];
		private var _weaponIndex:int= 0;
		
		public function AvatarScreen()
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
			_switchButton.label = "Changer anim";
			_switchButton.addEventListener(starling.events.Event.TRIGGERED, onSwitch);
			addChild(_switchButton);
			
			_switchWeaponButton = new Button();
			_switchWeaponButton.label = "Changer arme";
			_switchWeaponButton.addEventListener(starling.events.Event.TRIGGERED, onSwitchWeapon);
			addChild(_switchWeaponButton);
		}
		
		override protected function draw():void
		{
			if( isInvalid(INVALIDATION_FLAG_DATA) )
			{
				
				_switchWeaponButton.validate();
				_switchWeaponButton.x = actualWidth - _switchWeaponButton.width;
			}
			
			super.draw();
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
		private var _armature2:Armature;
		private var _armatureImp:Armature;
		private var _armatureDolph:Armature;
		private var _armaturePole:Armature;
		
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
			_factory.scaleForTexture = GlobalConfig.dpiScale;  // = uniquement avec un swf mergé
			var myFileStream:FileStream = new FileStream();
			myFileStream.open(File.applicationDirectory.resolvePath("assets/test/Zombie.dbswf"), FileMode.READ);
			var file_byte:ByteArray = new ByteArray();
			myFileStream.readBytes(file_byte, 0, myFileStream.bytesAvailable);
			_factory.parseData(file_byte);
			_factory.addEventListener(flash.events.Event.COMPLETE, onComplete);
		}
		
		private function onComplete(event:flash.events.Event = null):void
		{
			_armature = _factory.buildArmature("Zombie_gargantuar", null, null, "Zombie");
			_armature2 = _factory.buildArmature("Zombie_jackbox", null, null, "Zombie");
			_armatureImp = _factory.buildArmature("Zombie_imp", null, null, "Zombie");
			_armatureDolph = _factory.buildArmature("Zombie_dolphinrider", null, null, "Zombie");
			_armaturePole = _factory.buildArmature("Zombie_polevaulter", null, null, "Zombie");
			// 1 = name of the armature = movieclip containing animations in Flash Pro
			
			_armature.display.scaleX = _armature.display.scaleY = GlobalConfig.dpiScale;
			_armature2.display.scaleX = _armature2.display.scaleY = GlobalConfig.dpiScale;
			_armatureImp.display.scaleX = _armatureImp.display.scaleY = GlobalConfig.dpiScale;
			_armaturePole.display.scaleX = _armaturePole.display.scaleY = GlobalConfig.dpiScale;
			_armatureDolph.display.scaleX = _armatureDolph.display.scaleY = GlobalConfig.dpiScale;
			
			addChild(_armature.display as Sprite);
			addChild(_armature2.display as Sprite);
			addChild(_armatureImp.display as Sprite);
			addChild(_armatureDolph.display as Sprite);
			addChild(_armaturePole.display as Sprite);
			
			_armature.display.x = GlobalConfig.stageWidth * 0.85;
			_armature.display.y = (actualHeight) * 0.15;
			
			_armature2.display.x = GlobalConfig.stageWidth * 0.85;
			_armature2.display.y = (actualHeight) * 0.3;
			
			_armatureImp.display.x = GlobalConfig.stageWidth * 0.85;
			_armatureImp.display.y = (actualHeight) * 0.45;
			
			_armatureDolph.display.x = GlobalConfig.stageWidth * 0.85;
			_armatureDolph.display.y = (actualHeight) * 0.60;
			
			_armaturePole.display.x = GlobalConfig.stageWidth * 0.85;
			_armaturePole.display.y = (actualHeight) * 0.75;
			
			WorldClock.clock.add(_armature);
			WorldClock.clock.add(_armature2);
			WorldClock.clock.add(_armatureImp);
			WorldClock.clock.add(_armatureDolph);
			WorldClock.clock.add(_armaturePole);
			_armature.animation.gotoAndPlay(_animList[_currentIndex]);
			_armature2.animation.gotoAndPlay(_animList2[_currentIndex]);
			_armatureImp.animation.gotoAndPlay(_animListImp[_currentIndex]);
			_armatureDolph.animation.gotoAndPlay(_animListDolph[_currentIndexDolph]);
			_armaturePole.animation.gotoAndPlay(_animListPole[_currentIndexPole]);
			_armature.animation.timeScale = 0.85;
			_armature2.animation.timeScale = 0.75;
			_armatureImp.animation.timeScale = 0.75;
			_armatureDolph.animation.timeScale = 0.75;
			_armaturePole.animation.timeScale = 0.75;
			
			(_armature.display as Sprite).addChild( new Quad(5, 5, 0xff0000) );
			(_armature2.display as Sprite).addChild( new Quad(5, 5, 0xff0000) );
			(_armatureImp.display as Sprite).addChild( new Quad(5, 5, 0xff0000) );
			(_armatureDolph.display as Sprite).addChild( new Quad(5, 5, 0xff0000) );
			
			HeartBeat.registerFunction(updateAvatar);
			
			//var bone:Vector.<Bone> = (_armature.getBone("telephonepole") as Bone).armature.getBones();
			var bone:Bone = _armature.getBone("telephonepole");
			log("lol");
			
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
		
		private function updateAvatar(frameElapsedTime:int, totalElapsedTime:int):void
		{
			WorldClock.clock.advanceTime(-1);
		}
		
		private function onSwitchWeapon(event:starling.events.Event):void
		{
			_weaponIndex++;
			if( _weaponIndex >= _weapons.length )
				_weaponIndex = 0;
			
			if( _armature.getBone("telephonepole").display )
				_armature.getBone("telephonepole").display.dispose();
			_armature.getBone("telephonepole").display = _factory.getTextureDisplay(_weapons[_weaponIndex], "Zombie");
		}
		
		/**
		 * Switch the current animation.
		 */		
		private function onSwitch(event:starling.events.Event):void
		{
			_currentIndex++;
			_currentIndexDolph++;
			_currentIndexPole++;
			if( _currentIndex > _animList.length - 1 )
				_currentIndex = 0;
			if( _currentIndexDolph > _animListDolph.length - 1 )
				_currentIndexDolph = 0;
			if( _currentIndexPole > _animListPole.length - 1 )
				_currentIndexPole = 0;
			_armature.animation.gotoAndPlay(_animList[_currentIndex]);
			_armature2.animation.gotoAndPlay(_animList2[_currentIndex]);
			_armatureImp.animation.gotoAndPlay(_animListImp[_currentIndex]);
			_armatureDolph.animation.gotoAndPlay(_animListDolph[_currentIndexDolph]);
			_armaturePole.animation.gotoAndPlay(_animListPole[_currentIndexPole]);
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