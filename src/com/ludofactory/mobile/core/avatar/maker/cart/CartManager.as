/*
 Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
 Framework mobile
 Author  : Maxime Lhoez
 Created : 17 Décembre 2014
*/
package com.ludofactory.mobile.core.avatar.maker.cart
{
	
	import com.ludofactory.mobile.core.avatar.test.config.LudokadoBones;
	import com.ludofactory.mobile.core.avatar.test.manager.LKConfigManager;
	import com.ludofactory.mobile.core.avatar.test.manager.LudokadoBoneConfiguration;
	
	/**
	 * A BasketManager is used by the Ludokado Avatar Maker in order to store all the selected items for purchase.
	 * 
	 * The properties are updated as the items are selected / deselected in the list.
	 * 
	 * This data is finally used in order to display the final basket when the user wants to save the current
	 * configuration (meaning that some items may be purchased) and if it is validated on the server side
	 * (enough cookies, etc.), the GlobbyConfiguration will be upated accordingly in order to save the current
	 * configuration.
	 */
	public class CartManager
	{
		/**
		 * Current instance. */
		private static var _instance:CartManager;
		
		/**
		 * The hat selected for purchase. */
		private var _hatToPurchase:CartData;
		/**
		 * The hair selected for purchase. */
		private var _hairToPurchase:CartData;
		/**
		 * The eyebrows selected for purchase. */
		private var _eyebrowsToPurchase:CartData;
		/**
		 * The eyes selected for purchase. */
		private var _eyesToPurchase:CartData;
		/**
		 * The nose selected for purchase. */
		private var _noseToPurchase:CartData;
		/**
		 * The mouth selected for purchase. */
		private var _mouthToPurchase:CartData;
		/**
		 * The moustache selected for purchase. */
		private var _moustacheToPurchase:CartData;
		/**
		 * The beard selected for purchase. */
		private var _beardToPurchase:CartData;
		/**
		 * The shirt selected for purchase. */
		private var _shirtToPurchase:CartData;
		/**
		 * The left hand selected for purchase. */
		private var _leftHandToPurchase:CartData;
		/**
		 * The right hand selected for purchase. */
		private var _rightHandToPurchase:CartData;
		/**
		 * The face custom selected for purchase. */
		private var _faceCustomToPurchase:CartData;
		/**
		 * The epaulet selected for purchase. */
		private var _epauletToPurchase:CartData;
		
		/**
		 * The skin color selected for purchase. */
		private var _skinColorToPurchase:CartData;
		/**
		 * The eyes color selected for purchase. */
		private var _eyesColorToPurchase:CartData;
		/**
		 * The hair color selected for purchase. */
		private var _hairColorToPurchase:CartData;
		/**
		 * The lips selected for purchase. */
		private var _lipsColorToPurchase:CartData;
		
		/**
		 * The age selected for purchase. */
		private var _ageToPurchase:CartData;
		
		public function CartManager(sk:SecurityKey)
		{
			if(sk == null)
				throw new Error("Erreur : Echec de l'instanciation : Utiliser GlobbiesBasket.getInstance() au lieu de new.");
		}

//------------------------------------------------------------------------------------------------------------
//	Update

		/**
		 * Updates the cart.
		 * 
		 * If the item given in paramters is already owned or if it's a default item (extracted id queals to 0),
		 * we don't count it in the cart.
		 */
		public function updateCart(itemData:CartData):void
		{
			// || deleted, or we won't be able to purchase behaviors of items with an extracted id == 0
			_instance[("_" + itemData.armatureSectionType + "ToPurchase")] = (itemData.isOwned /*|| itemData.extractedId == 0*/) ? null : itemData;
		}
		
		public function removeFromCart(itemData:CartData):void
		{
			_instance[("_" + itemData.armatureSectionType + "ToPurchase")] = null;
		}
		
		public function getTotal():Number
		{
			var total:Number = 0;
			var armatureName:String;
			for (var i:int = 0; i < LudokadoBones.PURCHASABLE_ITEMS.length; i++)
			{
				armatureName = LudokadoBones.PURCHASABLE_ITEMS[i];
				if(_instance[("_" + armatureName + "ToPurchase")] && CartData(_instance[("_" + armatureName + "ToPurchase")]).isChecked
				&& !CartData(_instance[("_" + armatureName + "ToPurchase")]).isLocked)
					total += CartData(_instance[("_" + armatureName + "ToPurchase")]).price;
			}
			
			//log("Total = " + total);
			
			return total;
		}
		
		public function hasCheckedItem():Boolean
		{
			var armatureName:String;
			for (var i:int = 0; i < LudokadoBones.PURCHASABLE_ITEMS.length; i++)
			{
				armatureName = LudokadoBones.PURCHASABLE_ITEMS[i];
				if(_instance[("_" + armatureName + "ToPurchase")] && CartData(_instance[("_" + armatureName + "ToPurchase")]).isChecked)
					return true;
			}
			
			return false;
		}

		/**
		 * Determines if there is at least one item in the basket.
		 */
		public function hasItemsInBasket():Boolean
		{
			var armatureName:String;
			for (var i:int = 0; i < LudokadoBones.PURCHASABLE_ITEMS.length; i++)
			{
				armatureName = LudokadoBones.PURCHASABLE_ITEMS[i];
				if(_instance[("_" + armatureName + "ToPurchase")])
					return true;
			}
			return false;
		}
		
		public function generateDataProvider():Vector.<CartData>
		{
			var armatureName:String;
			var dataProvider:Vector.<CartData> = new Vector.<CartData>();
			for (var i:int = 0; i < LudokadoBones.PURCHASABLE_ITEMS.length; i++)
			{
				armatureName = LudokadoBones.PURCHASABLE_ITEMS[i];
				if(_instance[("_" + armatureName + "ToPurchase")])
					dataProvider.push( CartData(this[("_" + armatureName + "ToPurchase")]) );
			}
			
			return dataProvider;
		}

		/**
		 * Empties the cart.
		 * 
		 * This is called when the user resets the Globby or when he clicks on "Cancel" in order
		 * to set up its original configuration before any change.
		 */
		public function emptyCart():void
		{
			var armatureName:String;
			for (var i:int = 0; i < LudokadoBones.PURCHASABLE_ITEMS.length; i++)
			{
				armatureName = LudokadoBones.PURCHASABLE_ITEMS[i];
				_instance[("_" + armatureName + "ToPurchase")] = null;
			}
		}
		
		/**
		 * Updates the cart after a purchase in order to keep the deselected items for purchase.
		 */
		public function updateCartAfterPurchase():void
		{
			var armatureName:String;
			for (var i:int = 0; i < LudokadoBones.PURCHASABLE_ITEMS.length; i++)
			{
				armatureName = LudokadoBones.PURCHASABLE_ITEMS[i];
				if(_instance[("_" + armatureName + "ToPurchase")] != null && 
						CartData(_instance[("_" + armatureName + "ToPurchase")]).id == LudokadoBoneConfiguration(LKConfigManager.currentConfig[armatureName]).id )
				{
					// the id of the item in the cart matches the REAL id in the configuration, thus we know that this
					// item have been successfully purchased. We can remove it.
					_instance[("_" + armatureName + "ToPurchase")] = null;
				}
			}
		}
		
//------------------------------------------------------------------------------------------------------------
// Called when we save the avatar in the cart popup
		
		public function updateTemporaryConfigurationAfterItemSelectedOrSDeselected(item:CartData):void
		{
			if(item.isChecked)
			{
				// update the temporary configuration of the section
				LudokadoBoneConfiguration(LKConfigManager.currentConfig[item.armatureSectionType]).tempId = item.frameData ? item.frameData.id : item.itemData.id;
				LudokadoBoneConfiguration(LKConfigManager.currentConfig[item.armatureSectionType]).tempLinkageName = item.itemData.linkageName;
				LudokadoBoneConfiguration(LKConfigManager.currentConfig[item.armatureSectionType]).tempFrameName = item.frameData ? item.frameData.frameName : item.itemData.frameName;
				LudokadoBoneConfiguration(LKConfigManager.currentConfig[item.armatureSectionType]).isCheckedInCart = item.frameData ? !item.frameData.isLocked : !item.itemData.isLocked;
			}
			else
			{
				LudokadoBoneConfiguration(LKConfigManager.currentConfig[item.armatureSectionType]).resetToUser();
			}
		}
		
		/**
		 * When the user saves the avatar, we need to "cancel" temporarily the current configuration, so that
		 * the created PNG dos not contain the locked VIP items.
		 */
		public function resetConfigForLockedItems():void
		{
			var armatureName:String;
			for (var i:int = 0; i < LudokadoBones.PURCHASABLE_ITEMS.length; i++)
			{
				armatureName = LudokadoBones.PURCHASABLE_ITEMS[i];
				if(_instance[("_" + armatureName + "ToPurchase")] != null)
				{
					if(CartData(_instance[("_" + armatureName + "ToPurchase")]).isLocked)
						LudokadoBoneConfiguration(LKConfigManager.currentConfig[CartData(_instance[("_" + armatureName + "ToPurchase")]).armatureSectionType]).resetToUser();
				}
			}
		}
		
		/**
		 * When the user finished to save the avatar, we bring back the temporary configuration of the locked VIP items.
		 */
		public function bringBackConfigForLockedItem():void
		{
			var armatureName:String;
			for (var i:int = 0; i < LudokadoBones.PURCHASABLE_ITEMS.length; i++)
			{
				armatureName = LudokadoBones.PURCHASABLE_ITEMS[i];
				if(_instance[("_" + armatureName + "ToPurchase")] != null)
				{
					if(CartData(_instance[("_" + armatureName + "ToPurchase")]).isLocked)
					{
						// update the temporary configuration of the section
						LudokadoBoneConfiguration(LKConfigManager.currentConfig[CartData(_instance[("_" + armatureName + "ToPurchase")]).armatureSectionType]).tempId = CartData(_instance[("_" + armatureName + "ToPurchase")]).frameData ? CartData(_instance[("_" + armatureName + "ToPurchase")]).frameData.id : CartData(_instance[("_" + armatureName + "ToPurchase")]).itemData.id;
						LudokadoBoneConfiguration(LKConfigManager.currentConfig[CartData(_instance[("_" + armatureName + "ToPurchase")]).armatureSectionType]).tempLinkageName = CartData(_instance[("_" + armatureName + "ToPurchase")]).itemData.linkageName;
						LudokadoBoneConfiguration(LKConfigManager.currentConfig[CartData(_instance[("_" + armatureName + "ToPurchase")]).armatureSectionType]).tempFrameName = CartData(_instance[("_" + armatureName + "ToPurchase")]).frameData ? CartData(_instance[("_" + armatureName + "ToPurchase")]).frameData.frameName : CartData(_instance[("_" + armatureName + "ToPurchase")]).itemData.frameName;
						LudokadoBoneConfiguration(LKConfigManager.currentConfig[CartData(_instance[("_" + armatureName + "ToPurchase")]).armatureSectionType]).isCheckedInCart = CartData(_instance[("_" + armatureName + "ToPurchase")]).frameData ? !CartData(_instance[("_" + armatureName + "ToPurchase")]).frameData.isLocked : !CartData(_instance[("_" + armatureName + "ToPurchase")]).itemData.isLocked;
					}
				}
			}
		}
		
		/**
		 * 
		 */
		public function hasLockedItemsOnly():Boolean
		{
			var armatureName:String;
			var ret:Boolean = true;
			for (var i:int = 0; i < LudokadoBones.PURCHASABLE_ITEMS.length; i++)
			{
				armatureName = LudokadoBones.PURCHASABLE_ITEMS[i];
				if(_instance[("_" + armatureName + "ToPurchase")] != null)
				{
					if(CartData(_instance[("_" + armatureName + "ToPurchase")]).isLocked)
					{
						ret = true;
						LudokadoBoneConfiguration(LKConfigManager.currentConfig[CartData(_instance[("_" + armatureName + "ToPurchase")]).armatureSectionType]).resetToUser();
					}
					else
					{
						return false;
					}
				}
			}
			
			return ret;
		}
		
//------------------------------------------------------------------------------------------------------------
//	Singleton

		/**
		 * Singleton.
		 */
		public static function getInstance():CartManager
		{
			if(_instance == null)
				_instance = new CartManager(new SecurityKey());
			return _instance;
		}
		
	}
}

internal class SecurityKey{}