/*
 Copyright © 2006-2015 Ludo Factory
 Avatar Maker - Ludokado
 Author  : Maxime Lhoez
 Created : 24 août 2015
*/
package com.ludofactory.mobile.core.avatar.maker.newItems
{
	
	import com.ludofactory.mobile.core.avatar.AvatarMakerAssets;
	import com.ludofactory.mobile.core.avatar.maker.items.ItemManager;
	import com.ludofactory.mobile.core.avatar.test.events.LKAvatarMakerEventTypes;
	
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
		 * Clowe button. */
		private var _closeButton:Button;
		
		/**
		 * New vip items container. */
		private var _newVipItemContainer:NewVipItemsContainer;
		/**
		 * New common items container. */
		private var _newCommonItemContainer:NewCommonItemsContainer;
		
		private var _displayBoth:Boolean = false;
		
		public function NewItemsPopup()
		{
			super();
			
			_displayBoth = ItemManager.getInstance().newVipItems.length > 0 && ItemManager.getInstance().newCommonItems.length > 0;
			
			_particles = new PDParticleSystem(AvatarMakerAssets.particleStarsXml, AvatarMakerAssets.starParticle);
			_particles.touchable = false;
			_particles.maxNumParticles = 75;
			_particles.emitterXVariance = _displayBoth ? 400 : 200;
			_particles.emitterYVariance = 180;
			addChild(_particles);
			
			_stripes = new Image(AvatarMakerAssets.newItemsStripes);
			_stripes.touchable = false;
			addChild(_stripes);
			
			_particles.emitterX = _stripes.width * 0.5;
			_particles.emitterY = _stripes.height * 0.5;
			
			_background = new Image(_displayBoth ? AvatarMakerAssets.newItemsPopupBothBackground : AvatarMakerAssets.newItemsPopupSingleBackground);
			_background.x = (_stripes.width - _background.width) * 0.5;
			_background.y = (_stripes.height - _background.height) * 0.5;
			addChild(_background);
			
			_closeButton = new Button(AvatarMakerAssets.newItemsCloseButton);
			_closeButton.addEventListener(Event.TRIGGERED, onClose);
			addChild(_closeButton);
			
			if(_displayBoth)
			{
				// we need to display new common items (when we add new ones in database) and new vip items (when the rank changes)
				_closeButton.x = 758;
				_closeButton.y = 293;
				
				_newVipItemContainer = new NewVipItemsContainer();
				_newVipItemContainer.x = 360;
				_newVipItemContainer.y = 280;
				addChild(_newVipItemContainer);
				
				_newCommonItemContainer = new NewCommonItemsContainer(true);
				_newCommonItemContainer.x = -35;
				_newCommonItemContainer.y = 280;
				addChild(_newCommonItemContainer);
			}
			else
			{
				_closeButton.x = 600;
				_closeButton.y = 288;
				
				if(ItemManager.getInstance().newVipItems.length > 0)
				{
					// we need to displya new vip items (when the rank changes)
					_newVipItemContainer = new NewVipItemsContainer();
					_newVipItemContainer.x = 200;
					_newVipItemContainer.y = 275;
					addChild(_newVipItemContainer);
				}
				else if(ItemManager.getInstance().newCommonItems.length > 0)
				{
					// we need to display new common items (when we add new ones in database)
					_newCommonItemContainer = new NewCommonItemsContainer();
					_newCommonItemContainer.x = 200;
					_newCommonItemContainer.y = 275;
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
			if(_newCommonItemContainer) _newCommonItemContainer.onMinimize();
		}
		
		/**
		 * Re-enable all stuff like particles.
		 */
		public function onMaximize():void
		{
			Starling.juggler.add(_particles);
			_particles.start();
			
			if(_newVipItemContainer) _newVipItemContainer.onMaximize();
			if(_newCommonItemContainer) _newCommonItemContainer.onMaximize();
		}

//------------------------------------------------------------------------------------------------------------
//	Dispose
		
		override public function dispose():void
		{
			Starling.juggler.remove( _particles );
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
			
			super.dispose();
		}
		
	}
}