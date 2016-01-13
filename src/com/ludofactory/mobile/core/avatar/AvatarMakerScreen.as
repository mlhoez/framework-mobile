/**
 * Created by Maxime on 14/12/15.
 */
package com.ludofactory.mobile.core.avatar
{
	
	import com.greensock.TweenMax;
	import com.greensock.easing.Back;
	import com.greensock.easing.ElasticOut;
	import com.greensock.easing.Power1;
	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.common.utils.Utilities;
	import com.ludofactory.common.utils.logs.log;
	import com.ludofactory.common.utils.roundUp;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.ButtonFactory;
	import com.ludofactory.mobile.MobileButton;
	import com.ludofactory.mobile.MobileSimpleButton;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.AbstractGameInfo;
	import com.ludofactory.mobile.core.avatar.maker.cart.CartData;
	import com.ludofactory.mobile.core.avatar.maker.cart.CartManager;
	import com.ludofactory.mobile.core.avatar.maker.cart.CartPopup;
	import com.ludofactory.mobile.core.avatar.maker.cart.NotEnoughPointsPopUp;
	import com.ludofactory.mobile.core.avatar.maker.data.AvatarFrameData;
	import com.ludofactory.mobile.core.avatar.maker.data.AvatarItemData;
	import com.ludofactory.mobile.core.avatar.maker.items.ItemManager;
	import com.ludofactory.mobile.core.avatar.maker.items.ItemSelector;
	import com.ludofactory.mobile.core.avatar.maker.newItems.NewItemsPopup;
	import com.ludofactory.mobile.core.avatar.maker.sections.SectionSelector;
	import com.ludofactory.mobile.core.avatar.test.config.AvatarDisplayerType;
	import com.ludofactory.mobile.core.avatar.test.config.AvatarGenderType;
	import com.ludofactory.mobile.core.avatar.test.config.LudokadoBones;
	import com.ludofactory.mobile.core.avatar.test.events.LKAvatarMakerEventTypes;
	import com.ludofactory.mobile.core.avatar.test.manager.AvatarManager;
	import com.ludofactory.mobile.core.avatar.test.manager.LKConfigManager;
	import com.ludofactory.mobile.core.avatar.test.manager.LudokadoBoneConfiguration;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.controls.AdvancedScreen;
	import com.ludofactory.mobile.core.events.MobileEventTypes;
	import com.ludofactory.mobile.core.manager.InfoContent;
	import com.ludofactory.mobile.core.manager.InfoManager;
	import com.ludofactory.mobile.core.remoting.Remote;
	
	import starling.core.Starling;
	import starling.display.BlendMode;
	import starling.display.Button;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.filters.ColorMatrixFilter;
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
		
		/**
		 * Avatars background. */
		private var _background:Image;
		
	// ---------- UI
		
		/**
		 * Item selector (list of items). */
		private var _itemSelector:ItemSelector;
		/**
		 * Section selector. */
		private var _sectionSelector:SectionSelector;
		
	// ---------- Buttons
		
		/**
		 * Button isplayed when there are news items to show for the current gender. */
		private var _newItemsbutton:Button;
		/**
		 * The preview button. */
		private var _previewButton:MobileSimpleButton;
		
		private var _cancelButton:MobileButton;
		
		private var _randomizeButton:MobileButton;
		
		private var _saveButton:MobileButton;
		
	// ---------- Popups
		
		/**
		 * Black overlay displayed behind the popups. */
		private var _overlay:Quad;
		/**
		 * Cart popup. */
		private var _cartPopup:CartPopup;
		/**
		 * Popup displayed when the user wants to validate the cart but does not have enough points. */
		private var _notEnoughCookiesPopup:NotEnoughPointsPopUp;
		/**
		 * Popup displaying the new items (new items with the new vip rank or recently added in the database). */
		private var _newItemsPopup:NewItemsPopup;
		
		
		private var _isChangingGender:Boolean = false;
		
		
		public function AvatarMakerScreen()
		{
			super();
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			/*new LKConfigManager();
			LKConfigManager.initialize(JSON.parse('{"pngWidth":860,"eyesColor":{"itemId":296,"frameId":"black","itemLinkageName":"eyesColor_0"},"nose":{"itemId":184,"frameId":"defaut","itemLinkageName":"nose_3"},"moustache":{"itemId":407,"frameId":"defaut","itemLinkageName":"moustache_2"},"pngHeight":660,"mouth":{"itemId":115,"frameId":"defaut","itemLinkageName":"mouth_6"},"beard":{"itemId":401,"frameId":"defaut","itemLinkageName":"beard_1"},"leftHand":{"itemId":129,"frameId":"level_1","itemLinkageName":"leftHand_2"},"hat":{"itemId":82,"frameId":"brown","itemLinkageName":"hat_3"},"rightHand":{"itemId":572,"frameId":"level_4","itemLinkageName":"rightHand_4"},"skinColor":{"itemId":262,"frameId":"white","itemLinkageName":"skinColor_0"},"shirt":{"itemId":206,"frameId":"red","itemLinkageName":"shirt_0"},"hair":{"itemId":35,"frameId":"defaut","itemLinkageName":"hair_0"},"pngRefHeight":660,"age":{"itemId":353,"frameId":"age_2","itemLinkageName":"age_2"},"pngRefWidth":860,"faceCustom":{"itemId":416,"frameId":"defaut","itemLinkageName":"faceCustom_2"},"eyebrows":{"itemId":1,"frameId":"defaut","itemLinkageName":"eyebrows_0"},"idGender":1,"eyes":{"itemId":15,"frameId":"defaut","itemLinkageName":"eyes_0"},"hairColor":{"itemId":253,"frameId":"black","itemLinkageName":"hairColor_5"}}'));
			
			InfoManager.show(_("Chargement..."));*/
			
			_background = new Image(AbstractEntryPoint.assets.getTexture("avatars-background"));
			addChild(_background);
			
			addChild(AvatarManager.getInstance().currentAvatar.display as Sprite);
			
			_itemSelector = new ItemSelector();
			_itemSelector.addEventListener(LKAvatarMakerEventTypes.ITEM_SELECTED, onItemSelected);
			addChild(_itemSelector);
			
			_sectionSelector = new SectionSelector();
			addChild(_sectionSelector);
			_sectionSelector.addEventListener(LKAvatarMakerEventTypes.PART_SELECTED, onSectionSelected);
			
			_newItemsbutton = new Button(AbstractEntryPoint.assets.getTexture("new-items-button"));
			_newItemsbutton.alpha = 0;
			_newItemsbutton.visible = false;
			_newItemsbutton.alignPivot(HAlign.CENTER, VAlign.TOP);
			_newItemsbutton.addEventListener(Event.TRIGGERED, onDisplayNewItems);
			addChild(_newItemsbutton);
			
			_previewButton = new MobileSimpleButton(AvatarMakerAssets.previewButtonTexture);
			_previewButton.scaleX = _previewButton.scaleY = GlobalConfig.dpiScale;
			_previewButton.addEventListener(MobileEventTypes.BUTTON_DOWN, onPreviewEnabled);
			_previewButton.addEventListener(MobileEventTypes.BUTTON_UP, onPreviewDisabled);
			addChild(_previewButton);
			
			_randomizeButton = ButtonFactory.getButton("Rand", ButtonFactory.YELLOW);
			_randomizeButton.addEventListener(Event.TRIGGERED, onRandomize);
			_randomizeButton.scaleWhenDown = 0.9;
			addChild(_randomizeButton);
			
			_cancelButton = ButtonFactory.getButton("Reset", ButtonFactory.RED);
			_cancelButton.enabled = false;
			_cancelButton.addEventListener(Event.TRIGGERED, onCancel);
			_cancelButton.scaleWhenDown = 0.9;
			addChild(_cancelButton);
			
			_saveButton = ButtonFactory.getButton("Save", ButtonFactory.GREEN);
			_saveButton.enabled = false;
			_saveButton.addEventListener(Event.TRIGGERED, onSave);
			_saveButton.scaleWhenDown = 0.9;
			addChild(_saveButton);
			
			// --
			
			_overlay = new Quad(GlobalConfig.stageWidth, GlobalConfig.stageHeight, 0x000000);
			_overlay.alpha = 0;
			_overlay.visible = false;
			_overlay.touchable = true;
			
			_cartPopup = new CartPopup();
			_cartPopup.alpha = 0;
			_cartPopup.visible = false;
			_cartPopup.alignPivot();
			
			_notEnoughCookiesPopup = new NotEnoughPointsPopUp();
			_notEnoughCookiesPopup.alpha = 0;
			_notEnoughCookiesPopup.visible = false;
			_notEnoughCookiesPopup.alignPivot();
		}
		
		override protected function draw():void
		{
			super.draw();
			
			if(isInvalid(INVALIDATION_FLAG_SIZE))
			{
				_background.width = actualWidth;
				_background.height = actualHeight;
				
				if(AbstractGameInfo.LANDSCAPE)
				{
					_itemSelector.height = scaleAndRoundToDpi(170); // the size must be 10 less than the item renderer max height
					
					_saveButton.x = roundUp((actualWidth - _saveButton.width) * 0.5);
					_saveButton.y = actualHeight - _saveButton.height;
					
					_cancelButton.width = _randomizeButton.width = scaleAndRoundToDpi(130);
					
					_cancelButton.y = _randomizeButton.y = _saveButton.y;
					_cancelButton.x = _saveButton.x + _saveButton.width;
					_randomizeButton.x = _saveButton.x - _randomizeButton.width;
					
					_itemSelector.x = scaleAndRoundToDpi(5);
					_itemSelector.y = scaleAndRoundToDpi(5);
					_itemSelector.width = scaleAndRoundToDpi(GlobalConfig.isPhone ? 200 : 270);
					_itemSelector.height = actualHeight - (_itemSelector.y * 2);
					
					_sectionSelector.y = scaleAndRoundToDpi(5);
					_sectionSelector.height = actualHeight - (_itemSelector.y * 2);
					_sectionSelector.width = scaleAndRoundToDpi(150);
					_sectionSelector.x = actualWidth - _sectionSelector.width - scaleAndRoundToDpi(5);
					
					_previewButton.x = (actualWidth - _previewButton.width) * 0.5;
					
					_newItemsbutton.x = 600;
					
					/*var matrix:Vector.<Number> = new Vector.<Number>();
					matrix = matrix.concat([0, 0, 0, 0, 0]); // red
					matrix = matrix.concat([0, 0, 0, 0, 0]); // green
					matrix = matrix.concat([0, 0, 0, 0, 0]); // blue
					matrix = matrix.concat([1, 1, 1, 1, 1]); // alpha*/
					//var filter:ColorMatrixFilter = new ColorMatrixFilter();
					//filter.adjustContrast(0.5);
					//filter.tint(0x000000, 1);
					
					//avatar.display.alpha = 0.5;
					//avatar.display.filters = filters;
					
					//(AvatarManager.getInstance().currentAvatar.display as Sprite).filter = filter;
					AvatarManager.getInstance().currentAvatar.display.scaleX = AvatarManager.getInstance().currentAvatar.display.scaleY = 1;
					AvatarManager.getInstance().currentAvatar.display.scaleX =
							AvatarManager.getInstance().currentAvatar.display.scaleY = Utilities.getScaleToFillHeight(AvatarManager.getInstance().currentAvatar.display.height, actualHeight * 0.9);
					AvatarManager.getInstance().currentAvatar.display.x = actualWidth * 0.5;
					AvatarManager.getInstance().currentAvatar.display.y = actualHeight;
					
					_cartPopup.x = roundUp(actualWidth * 0.5);
					_cartPopup.y = roundUp(actualHeight * 0.5);
					
					_notEnoughCookiesPopup.x = roundUp(actualWidth * 0.5);
					_notEnoughCookiesPopup.y = roundUp(actualHeight * 0.5);
					
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
				_sectionSelector.setData();
				
				//_itemSelector.updateItems(ItemManager.getInstance().items[LudokadoBones.EYES], LudokadoBones.EYES); // FIXME A bouger, juste pour le temps du test la
				
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
//	Button handlers
		
		/**
		 * Randomizes the character (when the button have been clicked).
		 *
		 * <p>By default, random items will be picked up in the whole list (not only in the already bought ones).</p>
		 *
		 * <p>If you want to disable this behavior, i.e if you only want to randomize on the owned items only, set
		 * the property <code>RANDOMIZE_ON_ALL_ITEMS</code> of this class to false.</p>
		 */
		private function onRandomize(event:Event):void
		{
			log("[AvatarMakerScreen] Randomizing the avatar.");
			
			// empty the cart
			CartManager.getInstance().emptyCart();
			
			var sectionItemsList:Vector.<AvatarItemData>;
			var tempItems:Vector.<AvatarItemData>;
			var itemData:AvatarItemData;
			var selectedRandomItem:AvatarItemData;
			var selectedBehaviorData:AvatarFrameData;
			var i:int;
			
			// loop through all the sections (from the global items list)
			for(var key:String in ItemManager.getInstance().items )
			{
				// avoid the random on some sections like back hair, because back hair cannot be changed directly
				if(EXCLUDED_SECTIONS_ON_RANDOM.indexOf(key) > -1)
				{
					log("[" + key + "] excluded from random");
					continue;
				}
				
				// then retrieve all the available items of this section
				sectionItemsList = ItemManager.getInstance().items[key];
				tempItems = new Vector.<AvatarItemData>();
				
				selectedBehaviorData = null;
				selectedRandomItem = null;
				
				// loop through all the items and save the ones we can use to randomize on this section
				for (i = 0; i < sectionItemsList.length; i++)
				{
					itemData = sectionItemsList[i];
					if(RANDOMIZE_ON_ALL_ITEMS || itemData.isOwned || (itemData.behaviors.length > 0 && itemData.hasOwnedBehaviors()))
						tempItems.push(itemData);
				}
				
				// now on the valid items we saved in the temporary list, we will choose only one of them
				if(RANDOMIZE_ON_ALL_ITEMS || tempItems.length > 1)
				{
					// get a random item
					selectedRandomItem = tempItems[Utilities.getRandomArrayIndex(tempItems.length)];
					
					// if the item has behaviors, we need to select a random bahvior also
					if(selectedRandomItem.behaviors.length > 0)
					{
						// the item has behaviors
						var tempBehaviorsData:Vector.<AvatarFrameData> = new Vector.<AvatarFrameData>();
						for (i = 0; i < selectedRandomItem.behaviors.length; i++)
						{
							var behaviorData:AvatarFrameData = selectedRandomItem.behaviors[i];
							if(RANDOMIZE_ON_ALL_ITEMS || behaviorData.isOwned)
								tempBehaviorsData.push(behaviorData);
						}
						
						// get a random behavior
						selectedBehaviorData = tempBehaviorsData[Utilities.getRandomArrayIndex(tempBehaviorsData.length)];
						
						LudokadoBoneConfiguration(LKConfigManager.currentConfig[selectedRandomItem.armatureSectionType]).tempId = selectedBehaviorData.id;
						LudokadoBoneConfiguration(LKConfigManager.currentConfig[selectedRandomItem.armatureSectionType]).tempLinkageName = selectedRandomItem.linkageName;
						LudokadoBoneConfiguration(LKConfigManager.currentConfig[selectedRandomItem.armatureSectionType]).tempFrameName = selectedBehaviorData.frameName;
						LudokadoBoneConfiguration(LKConfigManager.currentConfig[selectedRandomItem.armatureSectionType]).isCheckedInCart = !selectedBehaviorData.isLocked;
					}
					else
					{
						// no behavior, so we clear the frame name
						LudokadoBoneConfiguration(LKConfigManager.currentConfig[selectedRandomItem.armatureSectionType]).tempId = selectedRandomItem.id;
						LudokadoBoneConfiguration(LKConfigManager.currentConfig[selectedRandomItem.armatureSectionType]).tempLinkageName = selectedRandomItem.linkageName;
						LudokadoBoneConfiguration(LKConfigManager.currentConfig[selectedRandomItem.armatureSectionType]).tempFrameName = selectedRandomItem.frameName;
						LudokadoBoneConfiguration(LKConfigManager.currentConfig[selectedRandomItem.armatureSectionType]).isCheckedInCart = !selectedRandomItem.isLocked;
					}
					
					//log("Random item selected : " + selectedRandomItem.name + " for section " + key);
					
					// update the displayer
					updateDisplayer(selectedRandomItem.armatureSectionType, selectedRandomItem.linkageName);
					// then add the item to the cart (checks on whether the item is owned or not will be done in the CartManager)
					CartManager.getInstance().updateCart(new CartData(AvatarItemData(selectedRandomItem), AvatarFrameData(selectedBehaviorData)));
				}
			}
			
			// update the main items list and the current display
			ItemManager.getInstance().updateSelectedStates(false);
			_itemSelector.updateCurrentList();
			checkButtonsState();
		}
		
		/**
		 * When the cancel button is touched, we reset the avatar configuration.
		 */
		private function onCancel(event:Event = null):void
		{
			// empty the cart
			CartManager.getInstance().emptyCart();
			// bring back the user configuration
			LKConfigManager.resetToUserConfiguration();
			// update the isSelected states in the list accordingly
			ItemManager.getInstance().updateSelectedStates(true);
			// and the items currently displaying
			_itemSelector.updateCurrentList();
			// update the save button state
			checkButtonsState();
			
			// then update the graphics accordingly (not all of them because some are linked)
			// the skin color will update the right and left hands, the head, nose and body (for the humans only), faceCustom (boy & girl)
			updateDisplayer(LudokadoBones.SKIN_COLOR, LKConfigManager.currentConfig.skinColor.linkageName);
			// the hair color will update the hair, eyebrows, back hair, moustache (potato & boy), beard (boy) and only for the potato : body
			updateDisplayer(LudokadoBones.HAIR_COLOR, LKConfigManager.currentConfig.hairColor.linkageName);
			// the eyes color will update the eyes
			updateDisplayer(LudokadoBones.EYES_COLOR, LKConfigManager.currentConfig.eyesColor.linkageName);
			// the lips color will update the mouth
			updateDisplayer(LudokadoBones.LIPS_COLOR, LKConfigManager.currentConfig.lipsColor.linkageName);
			// update the shirt
			updateDisplayer(LudokadoBones.SHIRT, LKConfigManager.currentConfig.shirt.linkageName);
			// update the hat
			updateDisplayer(LudokadoBones.HAT, LKConfigManager.currentConfig.hat.linkageName);
			// and the pant for humans
			if(LKConfigManager.currentGenderId !== AvatarGenderType.POTATO)
				updateDisplayer(LudokadoBones.PANT, LKConfigManager.currentConfig.pant.linkageName);
			// the epaulet for the potato
			if(LKConfigManager.currentGenderId == AvatarGenderType.POTATO)
				updateDisplayer(LudokadoBones.EPAULET, LKConfigManager.currentConfig.epaulet.linkageName);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Handlers
		
		/**
		 * When a section is selected, we need to update the list of purchasable / selectable
		 * items in the list.
		 *
		 * Note that "event.data" will contain the armature section group (ArmatureSectionType).
		 */
		private function onSectionSelected(event:Event):void
		{
			_itemSelector.updateItems(ItemManager.getInstance().items[String(event.data)], String(event.data));
		}
		
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
			_sectionSelector.onBasketUpdated(HELPER_ITEM_DATA.armatureSectionType);
			
			checkButtonsState();
		}
		
		public function updateDisplayer(armatureSection:String, itemLinkageName:String):void
		{
			AvatarManager.getInstance().update(AvatarManager.getInstance().currentAvatar, armatureSection, itemLinkageName);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Basket events
		
		private function onSave(event:Event = null):void
		{
			if( !CartManager.getInstance().hasItemsInBasket() )
			{
				// if no items in basket, the user just updated the configuration with already bought items
				InfoManager.show(_("Chargement..."));
				AvatarManager.getInstance().addEventListener(LKAvatarMakerEventTypes.AVATAR_IMAGE_CREATED, onImageCreated);
				AvatarManager.getInstance().getPng(LKConfigManager.currentGenderId, true);
			}
			else
			{
				_cartPopup.updateBasket();
				_cartPopup.addEventListener(LKAvatarMakerEventTypes.CLOSE_BASKET_POPUP, onBasketPopupClosed);
				_cartPopup.addEventListener(LKAvatarMakerEventTypes.ITEM_SELECTED_OR_DESELECTED, onItemSelectedOrDeselectedFromCart);
				showPopup(_cartPopup);
			}
		}
		
		private function onItemSelectedOrDeselectedFromCart(event:Event):void
		{
			// update the isSelected states in the list accordingly
			ItemManager.getInstance().updateSelectedStates(false);
			// and the items currently displaying
			_itemSelector.updateCurrentList();
			
			updateDisplayer(CartData(event.data).armatureSectionType, LKConfigManager.getBoneConfigByGender(LKConfigManager.currentGenderId, CartData(event.data).armatureSectionType).tempLinkageName);
		}
		
		private function onImageCreated(event:Event):void
		{
			AvatarManager.getInstance().removeEventListener(LKAvatarMakerEventTypes.AVATAR_IMAGE_CREATED, onImageCreated);
			Remote.getInstance().saveAvatar(String(event.data), onAvatarSaved, null, null, 1, advancedOwner.activeScreenID);
		}
		
		/**
		 * The user successfully saved the new configuration.
		 */
		private function onAvatarSaved(result:Object):void
		{
			if(result.code == 1)
			{
				// then parse the configuration (it will validate what have been bought)
				LKConfigManager.parseData(result.data["avatarConfiguration"]);
				// hide the loader
				InfoManager.hide(_("Votre avatar a bien été sauvegardé."), InfoContent.ICON_CHECK);
				
				checkButtonsState();
			}
			else
			{
				InfoManager.hide(_("Une erreur est surevenue lors de l'enregistrement de votre avatar.\n\nMerci de réessayer."), InfoContent.ICON_CROSS);
			}
		}
		
		/**
		 * When the basket pop
		 */
		private function onBasketPopupClosed(event:Event):void
		{
			if(event.data == LKAvatarMakerEventTypes.CONFIRM_NOT_ENOUGH_COOKIES)
			{
				_notEnoughCookiesPopup.addEventListener(LKAvatarMakerEventTypes.CLOSE_NOT_ENOUGH_COOKIES, onNotEnoughCokkiesPopupClosed);
				
				_notEnoughCookiesPopup.alpha = 0;
				_notEnoughCookiesPopup.visible = false;
				addChild(_notEnoughCookiesPopup);
				_notEnoughCookiesPopup.scaleX = _notEnoughCookiesPopup.scaleY = 1.2;
				TweenMax.to(_notEnoughCookiesPopup, 0.25, { autoAlpha:1 });
				TweenMax.to(_notEnoughCookiesPopup, 1, { scaleX:1, scaleY:1, ease:new ElasticOut(1, 0.6) });
				
				TweenMax.to(_cartPopup, 0.25, { autoAlpha:0 });
				
				return;
			}
			
			_cartPopup.removeEventListener(LKAvatarMakerEventTypes.CLOSE_BASKET_POPUP, onBasketPopupClosed);
			_cartPopup.removeEventListener(LKAvatarMakerEventTypes.ITEM_SELECTED_OR_DESELECTED, onItemSelectedOrDeselectedFromCart);
			hidePopup(_cartPopup);
			
			// if true == the items were succesfully purchased (or at least a part of them)
			if( event.data == true )
			{
				CartManager.getInstance().updateCartAfterPurchase();
				ItemManager.getInstance().updateListAfterPurchase();
				_itemSelector.updateCurrentList();
				
				checkButtonsState();
			}
		}
		
		private function onNotEnoughCokkiesPopupClosed(event:Event):void
		{
			_notEnoughCookiesPopup.removeEventListener(LKAvatarMakerEventTypes.CLOSE_NOT_ENOUGH_COOKIES, onNotEnoughCokkiesPopupClosed);
			TweenMax.to(_notEnoughCookiesPopup, 0.25, { autoAlpha:0, onComplete:_notEnoughCookiesPopup.removeFromParent });
			TweenMax.to(_cartPopup, 0.25, { autoAlpha:1 });
		}
		
//------------------------------------------------------------------------------------------------------------
//	Popup management
		
		/**
		 * Shows a popup.
		 */
		private function showPopup(popupToShow:starling.display.DisplayObject):void
		{
			_overlay.alpha = 0;
			_overlay.visible = false;
			addChild(_overlay);
			
			popupToShow.alpha = 0;
			popupToShow.visible = false;
			addChild(popupToShow);
			
			// then show the overlay and the popup
			TweenMax.killTweensOf(_overlay);
			TweenMax.to(_overlay, 0.25, { autoAlpha:0.75, onComplete:function():void
			{
				_overlay.addEventListener(TouchEvent.TOUCH, onTouchOverlay);
				_overlay.useHandCursor = true;
				_overlay.touchable = true;
			} });
			
			if(popupToShow is NewItemsPopup)
			{
				popupToShow.alpha = 1;
				popupToShow.visible = true;
				popupToShow.scaleX = popupToShow.scaleY = 0;
				popupToShow.x = _newItemsbutton.x;
				popupToShow.y = _newItemsbutton.y;
				TweenMax.to(popupToShow, 0.5, { x:(roundUp(actualWidth * 0.5)), y:(roundUp(actualHeight * 0.5)), scaleX:1, scaleY:1, ease:Back.easeOut });
			}
			else
			{
				popupToShow.scaleX = popupToShow.scaleY = 1.2;
				TweenMax.to(popupToShow, 0.25, { autoAlpha:1 });
				TweenMax.to(popupToShow, 1, { scaleX:1, scaleY:1, ease:new ElasticOut(1, 0.6) });
			}
		}
		
		/**
		 * Hides a popup.
		 */
		private function hidePopup(popupToHide:starling.display.DisplayObject, callback:Function = null):void
		{
			_overlay.removeEventListener(TouchEvent.TOUCH, onTouchOverlay);
			
			if(popupToHide is NewItemsPopup)
			{
				TweenMax.to(_overlay, 0.25, { autoAlpha:0, onComplete:function():void
				{
					_overlay.touchable = false;
					_overlay.removeFromParent();
				} });
				TweenMax.to(popupToHide, 0.25, { autoAlpha:0, scaleX:0, scaleY:0, x:_newItemsbutton.x, y:_newItemsbutton.y, onComplete:function():void
				{
					popupToHide.removeFromParent();
				}});
			}
			else
			{
				TweenMax.allTo([_overlay, popupToHide], 0.25, { autoAlpha:0, onComplete:function():void
				{
					_overlay.touchable = false;
					_overlay.removeFromParent();
					popupToHide.removeFromParent();
				} });
			}
			
			if(callback)
				TweenMax.delayedCall(0.25, callback);
		}
		
		/**
		 * When the overlay is touched, we need to close the popup that is currently displaying.
		 */
		private function onTouchOverlay(event:TouchEvent):void
		{
			if(event.getTouch(_overlay, TouchPhase.ENDED))
			{
				if(_notEnoughCookiesPopup && _notEnoughCookiesPopup.visible)
					_notEnoughCookiesPopup.dispatchEventWith(LKAvatarMakerEventTypes.CLOSE_NOT_ENOUGH_COOKIES);
				
				if(_newItemsPopup && _newItemsPopup.visible == true)
					_newItemsPopup.dispatchEventWith(LKAvatarMakerEventTypes.CLOSE_NEW_ITEMS_POPUP);
				
				if(_cartPopup.visible)
					_cartPopup.dispatchEventWith(LKAvatarMakerEventTypes.CLOSE_BASKET_POPUP);
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Utils
		
		/**
		 * Check the button states (for the cancel and save buttons)
		 */
		private function checkButtonsState():void
		{
			// TODO à remettre
			
			_cancelButton.enabled = !LKConfigManager.currentConfig.isUserConfiguration();
			//_cancelButton.fontColor = _cancelButton.enabled ? 0xffffff : 0x808080;
			
			_saveButton.enabled = !LKConfigManager.currentConfig.isUserConfiguration();
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
		
		private function onPreviewEnabled(event:Event):void
		{
			_itemSelector.visible = false;
			_cancelButton.visible = false;
			_randomizeButton.visible = false;
			_saveButton.visible = false;
			
			/*AvatarManager.getInstance().currentAvatar.display.scaleX = AvatarManager.getInstance().currentAvatar.display.scaleY = 1;
			AvatarManager.getInstance().currentAvatar.display.scaleX =
					AvatarManager.getInstance().currentAvatar.display.scaleY = Utilities.getScaleToFillHeight(AvatarManager.getInstance().currentAvatar.display.height, actualHeight);
			AvatarManager.getInstance().currentAvatar.display.x = actualWidth * 0.5;
			AvatarManager.getInstance().currentAvatar.display.y = actualHeight;*/
		}
		
		private function onPreviewDisabled(event:Event):void
		{
			_itemSelector.visible = true;
			_cancelButton.visible = true;
			_randomizeButton.visible = true;
			_saveButton.visible = true;
			
			/*AvatarManager.getInstance().currentAvatar.display.scaleX = AvatarManager.getInstance().currentAvatar.display.scaleY = 1;
			AvatarManager.getInstance().currentAvatar.display.scaleX =
					AvatarManager.getInstance().currentAvatar.display.scaleY = Utilities.getScaleToFillHeight(AvatarManager.getInstance().currentAvatar.display.height, actualHeight * 0.8);
			AvatarManager.getInstance().currentAvatar.display.x = actualWidth * 0.5;
			AvatarManager.getInstance().currentAvatar.display.y = _itemSelector.y + scaleAndRoundToDpi(10);*/
		}
		
//------------------------------------------------------------------------------------------------------------
//	
		
		override public function dispose():void
		{
			CartManager.getInstance().emptyCart();
			
			onCancel();
			
			AvatarManager.getInstance().disposeAvatar(AvatarManager.getInstance().currentAvatar);
			
			_itemSelector.removeEventListener(LKAvatarMakerEventTypes.ITEM_SELECTED, onItemSelected);
			_itemSelector.removeFromParent(true);
			_itemSelector = null;
			
			_sectionSelector.removeEventListener(LKAvatarMakerEventTypes.PART_SELECTED, onSectionSelected);
			_sectionSelector.removeFromParent(true);
			_sectionSelector = null;
			
			_previewButton.removeEventListener(MobileEventTypes.BUTTON_DOWN, onPreviewEnabled);
			_previewButton.removeEventListener(MobileEventTypes.BUTTON_UP, onPreviewDisabled);
			_previewButton.removeFromParent(true);
			_previewButton = null;
			
			
			super.dispose();
		}
		
	}
}