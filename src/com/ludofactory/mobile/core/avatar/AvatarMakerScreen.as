/**
 * Created by Maxime on 14/12/15.
 */
package com.ludofactory.mobile.core.avatar
{
	
	import com.greensock.TweenMax;
	import com.greensock.easing.Power1;
	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.common.utils.Utilities;
	import com.ludofactory.common.utils.logs.log;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.AbstractGameInfo;
	import com.ludofactory.mobile.core.avatar.maker.cart.CartData;
	import com.ludofactory.mobile.core.avatar.maker.cart.CartManager;
	import com.ludofactory.mobile.core.avatar.maker.data.AvatarFrameData;
	import com.ludofactory.mobile.core.avatar.maker.data.AvatarItemData;
	import com.ludofactory.mobile.core.avatar.maker.items.ItemManager;
	import com.ludofactory.mobile.core.avatar.maker.items.ItemSelector;
	import com.ludofactory.mobile.core.avatar.test.config.AvatarDisplayerType;
	import com.ludofactory.mobile.core.avatar.test.config.LudokadoBones;
	import com.ludofactory.mobile.core.avatar.test.events.LKAvatarMakerEventTypes;
	import com.ludofactory.mobile.core.avatar.test.manager.AvatarManager;
	import com.ludofactory.mobile.core.avatar.test.manager.LKConfigManager;
	import com.ludofactory.mobile.core.avatar.test.manager.LudokadoBoneConfiguration;
	import com.ludofactory.mobile.core.controls.AdvancedScreen;
	import com.ludofactory.mobile.core.manager.InfoContent;
	import com.ludofactory.mobile.core.manager.InfoManager;
	import com.ludofactory.mobile.core.remoting.Remote;
	
	import dragonBones.Armature;
	
	import starling.core.Starling;
	import starling.display.Button;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.utils.HAlign;
	import starling.utils.VAlign;
	
	public class AvatarMakerScreen extends AdvancedScreen
	{
		/**
		 * Helper item data. */
		private var HELPER_ITEM_DATA:AvatarItemData;
		/**
		 * Helper frame data. */
		private var HELPER_FRAME_DATA:AvatarFrameData;
		
		/**
		 * Whether we randomize on all items or just the owned ones. */
		public static const RANDOMIZE_ON_ALL_ITEMS:Boolean = true;
		
		/**
		 * Array of non touchable bones in the displayer.
		 * It is used in order to limit the number of listeners added on the bones. */
		private const NON_TOUCHABLE_BONES:Array = [ LudokadoBones.EYEBROWS, LudokadoBones.PANT, LudokadoBones.HEAD ];
		private const EXCLUDED_SECTIONS_ON_RANDOM:Array = [ LudokadoBones.BACK_HAIR ];
		
		// https://itunes.apple.com/lookup?id=712282637
		
	// ---------- UI
		
		/**
		 * Item selector (list of items). */
		private var _itemSelector:ItemSelector;
		
	// ---------- Buttons
		
		/**
		 * Button isplayed when there are news items to show for the current gender. */
		private var _newItemsbutton:Button;
		
		
		private var _isChangingGender:Boolean = false;
		
		
		public function AvatarMakerScreen()
		{
			super();
			
			_appDarkBackground = true;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			/*new LKConfigManager();
			LKConfigManager.initialize(JSON.parse('{"pngWidth":860,"eyesColor":{"itemId":296,"frameId":"black","itemLinkageName":"eyesColor_0"},"nose":{"itemId":184,"frameId":"defaut","itemLinkageName":"nose_3"},"moustache":{"itemId":407,"frameId":"defaut","itemLinkageName":"moustache_2"},"pngHeight":660,"mouth":{"itemId":115,"frameId":"defaut","itemLinkageName":"mouth_6"},"beard":{"itemId":401,"frameId":"defaut","itemLinkageName":"beard_1"},"leftHand":{"itemId":129,"frameId":"level_1","itemLinkageName":"leftHand_2"},"hat":{"itemId":82,"frameId":"brown","itemLinkageName":"hat_3"},"rightHand":{"itemId":572,"frameId":"level_4","itemLinkageName":"rightHand_4"},"skinColor":{"itemId":262,"frameId":"white","itemLinkageName":"skinColor_0"},"shirt":{"itemId":206,"frameId":"red","itemLinkageName":"shirt_0"},"hair":{"itemId":35,"frameId":"defaut","itemLinkageName":"hair_0"},"pngRefHeight":660,"age":{"itemId":353,"frameId":"age_2","itemLinkageName":"age_2"},"pngRefWidth":860,"faceCustom":{"itemId":416,"frameId":"defaut","itemLinkageName":"faceCustom_2"},"eyebrows":{"itemId":1,"frameId":"defaut","itemLinkageName":"eyebrows_0"},"idGender":1,"eyes":{"itemId":15,"frameId":"defaut","itemLinkageName":"eyes_0"},"hairColor":{"itemId":253,"frameId":"black","itemLinkageName":"hairColor_5"}}'));
			
			InfoManager.show(_("Chargement..."));*/
			
			_itemSelector = new ItemSelector();
			_itemSelector.addEventListener(LKAvatarMakerEventTypes.ITEM_SELECTED, onItemSelected);
			addChild(_itemSelector);
			
			_newItemsbutton = new Button(AbstractEntryPoint.assets.getTexture("new-items-button"));
			_newItemsbutton.alpha = 0;
			_newItemsbutton.visible = false;
			_newItemsbutton.alignPivot(HAlign.CENTER, VAlign.TOP);
			_newItemsbutton.addEventListener(Event.TRIGGERED, onDisplayNewItems);
			addChild(_newItemsbutton);
			
			addChild(AvatarManager.getInstance().currentAvatar.display as Sprite);
		}
		
		override protected function draw():void
		{
			super.draw();
			
			if(isInvalid(INVALIDATION_FLAG_SIZE))
			{
				if(AbstractGameInfo.LANDSCAPE)
				{
					_itemSelector.x = scaleAndRoundToDpi(20);
					_itemSelector.width = actualWidth - scaleAndRoundToDpi(40);
					_itemSelector.height = scaleAndRoundToDpi(200);
					_itemSelector.y = actualHeight - _itemSelector.height - scaleAndRoundToDpi(10);
					
					_newItemsbutton.x = 600;
					
					AvatarManager.getInstance().currentAvatar.display.scaleX = AvatarManager.getInstance().currentAvatar.display.scaleY = 1;
					AvatarManager.getInstance().currentAvatar.display.scaleX =
							AvatarManager.getInstance().currentAvatar.display.scaleY = Utilities.getScaleToFillHeight(AvatarManager.getInstance().currentAvatar.display.height, actualHeight * 0.8);
					AvatarManager.getInstance().currentAvatar.display.x = actualWidth * 0.5;
					AvatarManager.getInstance().currentAvatar.display.y = actualHeight;
					
					InfoManager.show(_("Chargement..."));
					Remote.getInstance().getItemsList(onGetItemsSuccess, onGetItemsFail, onGetItemsFail, 2, advancedOwner.activeScreenID);
				}
				else
				{
					
				}
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Remote handlers
		
		/**
		 * Get items callback.
		 */
		private function onGetItemsSuccess(result:Object):void
		{
			if(result.code == 1)
			{
				ItemManager.getInstance().parseData(result);
				//_sectionSelector.setData(); // FIXME A décommenter
				
				_itemSelector.updateItems(ItemManager.getInstance().items[LudokadoBones.EYES], LudokadoBones.EYES); // FIXME A bouger, juste pour le temps du test la
				
				_newItemsbutton.alpha = 0;
				_newItemsbutton.visible = false;
				//TweenMax.killTweensOf(_newItemsbutton);
				if(ItemManager.getInstance().hasNewItemsToShow())
				{
					TweenMax.to(_newItemsbutton, 0.5, { autoAlpha:1 });
					TweenMax.to(_newItemsbutton, 0.5, { scaleX:1.1, scaleY:1.1, ease:Power1.easeInOut, yoyo:true, repeat:-1 });
				}
				
				if(_isChangingGender)
				{
					// FIXME Bloc à décommenter
					/*Starling.juggler.delayCall(hidePopup, 1, _avatarChangePopup, function():void
					{
						_avatarChangePopup.dispose();
						_avatarChangePopup = null;
					});*/
					Starling.juggler.delayCall(InfoManager.hide, 1 , ["", InfoContent.ICON_CROSS, 0]);
					if(ItemManager.getInstance().hasNewItemsToShow())
						TweenMax.delayedCall(1.75, onDisplayNewItems);
				}
				else
				{
					InfoManager.hide("", InfoContent.ICON_CROSS, 0);
					if(ItemManager.getInstance().hasNewItemsToShow())
						onDisplayNewItems();
				}
			}
			else
			{
				InfoManager.hide("", InfoContent.ICON_CROSS, 0);
			}
		}
		
		private function onGetItemsFail(error:Object):void
		{
			// TODO à finaliser avec un retry container
			InfoManager.hide(_("Impossible d'initialiser..."), InfoContent.ICON_CROSS);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Handlers
		
		/**
		 * When an item is selected whthin the list, we need to show / hide the basket icon on concerned
		 * Parts and the "Save" button. It will also update the list of currently selected items for purchase
		 * in order to display the basket pop up when the "Save" button will be clicked.
		 *
		 * Note that "event.data" will contain the AvatarItemData associated to the selected item.
		 */
		private function onItemSelected(event:Event):void
		{
			// item data
			HELPER_ITEM_DATA = AvatarItemData(event.data.itemData);
			// frame data
			HELPER_FRAME_DATA = AvatarFrameData(event.data.behaviorData);
			
			log("[AvatarMakerScreen] " + HELPER_ITEM_DATA.name + " selected.");
			log("     - Database id : " + (HELPER_FRAME_DATA ? HELPER_FRAME_DATA.id : HELPER_ITEM_DATA.id));
			log("     - Section : " + HELPER_ITEM_DATA.armatureSectionType);
			log("     - Flash linkage name : " + HELPER_ITEM_DATA.linkageName);
			log("     - Flash extracted id : " + HELPER_ITEM_DATA.extractedId);
			log("     - Frame name : " + (HELPER_FRAME_DATA ? HELPER_FRAME_DATA.frameName : HELPER_ITEM_DATA.frameName));
			
			// update the temporary configuration of the section
			LudokadoBoneConfiguration(LKConfigManager.currentConfig[HELPER_ITEM_DATA.armatureSectionType]).tempId = HELPER_FRAME_DATA ? HELPER_FRAME_DATA.id : HELPER_ITEM_DATA.id;
			LudokadoBoneConfiguration(LKConfigManager.currentConfig[HELPER_ITEM_DATA.armatureSectionType]).tempLinkageName = HELPER_ITEM_DATA.linkageName;
			LudokadoBoneConfiguration(LKConfigManager.currentConfig[HELPER_ITEM_DATA.armatureSectionType]).tempFrameName = HELPER_FRAME_DATA ? HELPER_FRAME_DATA.frameName : HELPER_ITEM_DATA.frameName;
			LudokadoBoneConfiguration(LKConfigManager.currentConfig[HELPER_ITEM_DATA.armatureSectionType]).isCheckedInCart = HELPER_FRAME_DATA ? !HELPER_FRAME_DATA.isLocked : !HELPER_ITEM_DATA.isLocked;
			
			// update the displayer
			updateDisplayer(HELPER_ITEM_DATA.armatureSectionType, HELPER_ITEM_DATA.linkageName);
			// update the basket
			CartManager.getInstance().updateCart(new CartData(HELPER_ITEM_DATA, HELPER_FRAME_DATA));
			// update the state icon on the section selector
			//_sectionSelector.onBasketUpdated(HELPER_ITEM_DATA.armatureSectionType); // FIXME A décommenter
			
			checkButtonsState();
		}
		
		public function updateDisplayer(armatureSection:String, itemLinkageName:String):void
		{
			AvatarManager.getInstance().update(AvatarManager.getInstance().currentAvatar, armatureSection, itemLinkageName);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Utils
		
		/**
		 * Check the button states (for the cancel and save buttons)
		 */
		private function checkButtonsState():void
		{
			// TODO à remettre
			
			//_cancelButton.enabled = !LKConfigManager.currentConfig.isUserConfiguration();
			//_cancelButton.fontColor = _cancelButton.enabled ? 0xffffff : 0x808080;
			
			//_saveButton.enabled = !LKConfigManager.currentConfig.isUserConfiguration();
			//_saveButton.fontColor = _saveButton.enabled ? 0xffffff : 0x808080;
			
			// TODO utiliser CartManager.getInstance().hasLockedItemsOnly() pour afficher une popup de confirmation
		}
		
//------------------------------------------------------------------------------------------------------------
//	New items
		
		/**
		 * Opens the new items popup.
		 */
		private function onDisplayNewItems(event:Event = null):void
		{
			
		}
		/*private function onDisplayNewItems(event:Event = null):void
		{
			if(!_newItemsPopup)
			{
				_newItemsPopup = new NewItemsPopup();
				_newItemsPopup.alignPivot();
			}
			_newItemsPopup.addEventListener(LKAvatarMakerEventTypes.CLOSE_NEW_ITEMS_POPUP, onNewItemsPopupClosed);
			_newItemsPopup.addEventListener(LKAvatarMakerEventTypes.ON_NEW_ITEM_SELECTED, onItemSelectFromNewItemsPopup);
			
			_newItemsPopup.onMaximize();
			showPopup(_newItemsPopup);
		}*/
		
		/**
		 * The new items popup have been minimized.
		 */
		/*private function onNewItemsPopupClosed(event:Event):void
		{
			_newItemsPopup.removeEventListener(LKAvatarMakerEventTypes.CLOSE_NEW_ITEMS_POPUP, onNewItemsPopupClosed);
			_newItemsPopup.removeEventListener(LKAvatarMakerEventTypes.ON_NEW_ITEM_SELECTED, onItemSelectFromNewItemsPopup);
			_newItemsPopup.onMinimize();
			hidePopup(_newItemsPopup);
		}*/
		
		/**
		 * When a new item have been selected from the new items popup.
		 */
		/*private function onItemSelectFromNewItemsPopup(event:Event):void
		{
			_newItemsPopup.dispatchEventWith(LKAvatarMakerEventTypes.CLOSE_NEW_ITEMS_POPUP);
			
			// TODO a améliorer
			var itemData:AvatarItemData = AvatarItemData(event.data);
			onItemSelected(new Event(LKAvatarMakerEventTypes.ITEM_SELECTED, false, {itemData:itemData, behaviorData:(ItemManager.getInstance().newItemHasBehaviors(itemData) ? (itemData.hasBehaviors ? itemData.behaviors[0] : null) : null)}));
			ItemManager.getInstance().updateSelectedStates(false);
			_itemSelector.onNewItemSelected(itemData);
			checkButtonsState();
		}*/
		
//------------------------------------------------------------------------------------------------------------
//	
		
		override public function dispose():void
		{
			AvatarManager.getInstance().disposeAvatar(AvatarManager.getInstance().currentAvatar);
			
			_itemSelector.removeEventListener(LKAvatarMakerEventTypes.ITEM_SELECTED, onItemSelected);
			_itemSelector.removeFromParent(true);
			_itemSelector = null;
			
			
			super.dispose();
		}
		
	}
}