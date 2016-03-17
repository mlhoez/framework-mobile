/*
 Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
 Framework mobile
 Author  : Maxime Lhoez
 Created : 24 Août 2015
*/
package com.ludofactory.mobile.core.avatar.maker.newItems
{
	
	import com.ludofactory.common.utils.Utilities;
	import com.ludofactory.common.utils.roundUp;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.avatar.AvatarMakerAssets;
	import com.ludofactory.mobile.core.avatar.maker.items.ItemManager;
	import com.ludofactory.mobile.core.avatar.test.events.LKAvatarMakerEventTypes;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	
	import starling.core.Starling;
	import starling.display.Button;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.extensions.PDParticleSystem;
	
	/**
	 * Popup displaying new items.
	 */
	public class NewItemsPopup extends Sprite
	{
		/**
		 * Main particles. */
		private var _particles:PDParticleSystem;
		/**
		 * Stripes displayed behind everything. */
		private var _stripes:Image;
		/**
		 * The popup background. */
		private var _background:Image;
		/**
		 * The black overlay. */
		private var _overlay:Quad;
		
		/**
		 * New vip items container. */
		private var _newVipItemContainer:NewVipItemsContainer;
		/**
		 * New common items container. */
		private var _newCommonItemContainer:NewCommonItemsContainer;
		
		/**
		 * Clowe button. */
		private var _closeButton:Button;
		
		public function NewItemsPopup()
		{
			super();
			
			var displayBoth:Boolean = ItemManager.getInstance().newVipItems.length > 0 && ItemManager.getInstance().newCommonItems.length > 0;
			
			_particles = new PDParticleSystem(AvatarMakerAssets.particleStarsXml, AvatarMakerAssets.starParticle);
			_particles.touchable = false;
			_particles.maxNumParticles = 75;
			_particles.emitterXVariance = GlobalConfig.stageWidth * 0.5;
			_particles.emitterYVariance = GlobalConfig.stageHeight * 0.5;
			addChild(_particles);
			
			_stripes = new Image(AvatarMakerAssets.newItemsStripes);
			_stripes.scaleX = _stripes.scaleY = Utilities.getScaleToFill(_stripes.width, _stripes.height, GlobalConfig.stageWidth, GlobalConfig.stageHeight, true);
			_stripes.touchable = false;
			_stripes.x = roundUp((GlobalConfig.stageWidth - _stripes.width) * 0.5);
			_stripes.y = roundUp((GlobalConfig.stageHeight - _stripes.height) * 0.5);
			addChild(_stripes);
			
			_particles.emitterX = GlobalConfig.stageWidth * 0.5;
			_particles.emitterY = GlobalConfig.stageHeight * 0.5;
			
			_background = new Image(displayBoth ? AvatarMakerAssets.newItemsPopupBothBackground : AvatarMakerAssets.newItemsPopupSingleBackground);
			_background.scaleX = _background.scaleY = GlobalConfig.dpiScale;
			_background.x = roundUp((GlobalConfig.stageWidth - _background.width) * 0.5);
			_background.y = roundUp((GlobalConfig.stageHeight - _background.height) * 0.5);
			addChild(_background);
			
			_closeButton = new Button(AvatarMakerAssets.newItemsCloseButton);
			_closeButton.scaleX = _closeButton.scaleY = GlobalConfig.dpiScale;
			_closeButton.addEventListener(Event.TRIGGERED, onClose);
			addChild(_closeButton);
			
			if(displayBoth)
			{
				// we need to display new common items (when we add new ones in database) and new vip items (when the rank changes)
				_closeButton.x = _background.x + _background.width - scaleAndRoundToDpi(46);
				_closeButton.y = _background.y + scaleAndRoundToDpi(26);
				
				_newVipItemContainer = new NewVipItemsContainer(true);
				_newVipItemContainer.x = _background.x + scaleAndRoundToDpi(14);
				_newVipItemContainer.y = _background.y + scaleAndRoundToDpi(-4);
				addChild(_newVipItemContainer);
				
				_newCommonItemContainer = new NewCommonItemsContainer(true);
				_newCommonItemContainer.x = _background.x + _background.width - _newCommonItemContainer.width - scaleAndRoundToDpi(30);
				_newCommonItemContainer.y = _background.y + scaleAndRoundToDpi(30);
				addChild(_newCommonItemContainer);
			}
			else
			{
				_closeButton.x = _background.x + _background.width - scaleAndRoundToDpi(59);
				_closeButton.y = _background.y + scaleAndRoundToDpi(16);
				
				if(ItemManager.getInstance().newVipItems.length > 0)
				{
					// we need to displya new vip items (when the rank changes)
					_newVipItemContainer = new NewVipItemsContainer();
					_newVipItemContainer.x = _background.x + scaleAndRoundToDpi(20);
					_newVipItemContainer.y = _background.y + scaleAndRoundToDpi(10);
					addChild(_newVipItemContainer);
				}
				else if(ItemManager.getInstance().newCommonItems.length > 0)
				{
					// we need to display new common items (when we add new ones in database)
					_newCommonItemContainer = new NewCommonItemsContainer();
					_newCommonItemContainer.x = _background.x + scaleAndRoundToDpi(90);
					_newCommonItemContainer.y = _background.y + scaleAndRoundToDpi(40);
					addChild(_newCommonItemContainer);
				}
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Handlers

		/**
		 * Closes the popup.
		 */
		private function onClose(event:Event):void
		{
			dispatchEventWith(LKAvatarMakerEventTypes.CLOSE_NEW_ITEMS_POPUP);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Memory and performance management
		
		/**
		 * Disable all stuff like particles.
		 */
		public function onMinimize():void
		{
			Starling.juggler.remove(_particles);
			_particles.stop();
			
			if(_newVipItemContainer) _newVipItemContainer.onMinimize();
		}
		
		/**
		 * Re-enable all stuff like particles.
		 */
		public function onMaximize():void
		{
			Starling.juggler.add(_particles);
			_particles.start();
			
			if(_newVipItemContainer) _newVipItemContainer.onMaximize();
		}

//------------------------------------------------------------------------------------------------------------
//	Dispose
		
		override public function dispose():void
		{
			Starling.juggler.remove(_particles);
			_particles.stop(true);
			_particles.removeFromParent(true);
			_particles = null;
			
			_stripes.removeFromParent(true);
			_stripes = null;
			
			_background.removeFromParent(true);
			_background = null;
			
			if(_overlay)
			{
				_overlay.removeFromParent(true);
				_overlay = null;
			}
			
			if(_newVipItemContainer)
			{
				_newVipItemContainer.removeFromParent(true);
				_newVipItemContainer = null;
			}
			
			if(_newCommonItemContainer)
			{
				_newCommonItemContainer.removeFromParent(true);
				_newCommonItemContainer = null;
			}
			
			_closeButton.removeEventListener(Event.TRIGGERED, onClose);
			_closeButton.removeFromParent(true);
			_closeButton = null;
			
			super.dispose();
		}
		
	}
}