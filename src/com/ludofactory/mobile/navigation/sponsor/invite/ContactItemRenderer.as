/*
Copyright © 2006-2015 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 8 sept. 2013
*/
package com.ludofactory.mobile.navigation.sponsor.invite
{
	import com.freshplanet.nativeExtensions.AirNetworkInfo;
	import com.gamua.flox.Flox;
	import com.greensock.TweenMax;
	import com.greensock.easing.Bounce;
	import com.greensock.easing.Elastic;
	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.manager.InfoContent;
	import com.ludofactory.mobile.core.manager.InfoManager;
	import com.ludofactory.mobile.core.remoting.Remote;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import flash.geom.Point;
	
	import feathers.controls.Button;
	import feathers.controls.GroupedList;
	import feathers.controls.Label;
	import feathers.controls.List;
	import feathers.controls.Scroller;
	import feathers.controls.popups.IPopUpContentManager;
	import feathers.controls.popups.VerticalCenteredPopUpContentManager;
	import feathers.controls.renderers.IListItemRenderer;
	import feathers.core.FeathersControl;
	import feathers.data.HierarchicalCollection;
	
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.MovieClip;
	import starling.display.Quad;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	
	/**
	 * Item renderer used to display a contact with the ability to
	 * invite him / her individually.
	 */	
	public class ContactItemRenderer extends FeathersControl implements IListItemRenderer
	{
		private static const HELPER_POINT:Point = new Point();
		private static const HELPER_TOUCHES_VECTOR:Vector.<Touch> = new <Touch>[];
		protected var touchPointID:int = -1;
		
		/**
		 * The base height of a line in the list. */		
		private static const BASE_HEIGHT:int = 80;
		/**
		 * The scaled item height. */		
		private var _itemHeight:Number;
		
		/**
		 * The base stroke thickness. */		
		private static const BASE_STROKE_THICKNESS:int = 2;
		/**
		 * The scaled stroke thickness. */		
		private var _strokeThickness:Number;
		
		/**
		 * The global padding of the item renderer. */		
		private var _padding:int = 20;
		
		/**
		 * The background. */		
		private var _background:Quad;
		/**
		 * The top stripe displayed in each item renderer. */		
		private var _topStripe:Quad;
		/**
		 * The bottom stripe only displayed in the last item renderer. */		
		private var _bottomStripe:Quad;
		
		/**
		 * Name of the contact. */		
		private var _nameLabel:Label;
		/**
		 * Sub category choice title */		
		private var _contactLabel:Label;
		/**
		 * The down arrow */		
		private var _arrowDown:Image;
		/**
		 * The invite button */		
		private var _inviteButton:Button;
		
		/**
		 * The contact elements list */		
		private var _contactElementsList:GroupedList;
		/**
		 * The popup content manager used to display the contact elements list. */		
		private var _popUpContentManager:IPopUpContentManager;
		
		/**
		 * The loader. */		
		private var _loader:MovieClip;
		
		/**
		 * The check icon. */		
		private var _checkIcon:Image;
		
		/**
		 * Whether the contact have been invited or not */		
		private var _isInvited:Boolean = false;
		
		/**
		 * Whether the contact is inviting or not. */		
		private var _isInviting:Boolean = false;
		
		public function ContactItemRenderer()
		{
			super();
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			_itemHeight = scaleAndRoundToDpi(BASE_HEIGHT);
			_strokeThickness = scaleAndRoundToDpi(BASE_STROKE_THICKNESS);
			_padding *= GlobalConfig.dpiScale;
			
			this.width = GlobalConfig.stageWidth;
			this.height = _itemHeight;
			
			_background = new Quad(this.width, _itemHeight);
			addChild(_background);
			
			_topStripe = new Quad(50, _strokeThickness, 0xbfbfbf);
			_topStripe.touchable = false;
			addChild(_topStripe);
			
			_bottomStripe = new Quad(50, _strokeThickness, 0xbfbfbf);
			_bottomStripe.touchable = false;
			_bottomStripe.visible = false;
			addChild(_bottomStripe);
			
			_nameLabel = new Label();
			_nameLabel.touchable = false;
			addChild(_nameLabel);
			_nameLabel.textRendererProperties.textFormat = Theme.contactIRNameTextFormat;
			_nameLabel.textRendererProperties.wordWrap = false;
			
			_contactLabel = new Label();
			_contactLabel.touchable = false;
			addChild( _contactLabel );
			_contactLabel.textRendererProperties.textFormat = Theme.contactIRValueTextFormat;
			_contactLabel.textRendererProperties.wordWrap = false;
			
			_arrowDown = new Image( AbstractEntryPoint.assets.getTexture("arrow_down") );
			_arrowDown.touchable = false;
			_arrowDown.scaleX = _arrowDown.scaleY = GlobalConfig.dpiScale;
			_arrowDown.alignPivot();
			addChild(_arrowDown);
			
			_inviteButton = new Button();
			_inviteButton.styleName = Theme.BUTTON_FLAT_GREEN;
			_inviteButton.label = _("Inviter");
			_inviteButton.addEventListener(Event.TRIGGERED, onInvite);
			addChild(_inviteButton);
			
			_loader = new MovieClip(Theme.blackLoaderTextures);
			_loader.scaleX = _loader.scaleY = GlobalConfig.dpiScale;
			_loader.alignPivot();
			_loader.visible = false;
			_loader.touchable = false;
			_loader.alpha = 0;
			Starling.juggler.add(_loader);
			addChild(_loader);
			
			_contactElementsList = new GroupedList();
			_contactElementsList.verticalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			_contactElementsList.horizontalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			_contactElementsList.styleName = Theme.SUB_CATEGORY_GROUPED_LIST;
			_contactElementsList.typicalItem = { nom: "Item 1000" };
			_contactElementsList.isSelectable = true;
			_contactElementsList.itemRendererProperties.labelField = "nom";
			
			const centerStage:VerticalCenteredPopUpContentManager = new VerticalCenteredPopUpContentManager();
			centerStage.marginTop = centerStage.marginRight = centerStage.marginBottom =
				centerStage.marginLeft = scaleAndRoundToDpi( GlobalConfig.isPhone ? 24:200 );
			_popUpContentManager = centerStage;
			
			_checkIcon = new Image( AbstractEntryPoint.assets.getTexture("SponsorCheckIcon") );
			_checkIcon.scaleX = _checkIcon.scaleY = GlobalConfig.dpiScale;
			_inviteButton.disabledIcon = _checkIcon;
		}
		
		override protected function draw():void
		{
			const dataInvalid:Boolean = this.isInvalid(INVALIDATION_FLAG_DATA);
			const selectionInvalid:Boolean = this.isInvalid(INVALIDATION_FLAG_SELECTED);
			var sizeInvalid:Boolean = this.isInvalid(INVALIDATION_FLAG_SIZE);
			
			if(dataInvalid)
			{
				this.commitData();
			}
			
			sizeInvalid = this.autoSizeIfNeeded() || sizeInvalid;
			
			if(dataInvalid || sizeInvalid || dataInvalid)
			{
				this.layout();
			}
		}
		
		protected function autoSizeIfNeeded():Boolean
		{
			const needsWidth:Boolean = isNaN(this.explicitWidth);
			const needsHeight:Boolean = isNaN(this.explicitHeight);
			if(!needsWidth && !needsHeight)
			{
				return false;
			}
			_nameLabel.width = NaN;
			_nameLabel.height = NaN;
			_nameLabel.validate();
			var newWidth:Number = this.explicitWidth;
			if(needsWidth)
			{
				newWidth = _nameLabel.width;
			}
			var newHeight:Number = this.explicitHeight;
			if(needsHeight)
			{
				newHeight = _nameLabel.height;
			}
			return this.setSizeInternal(newWidth, newHeight, false);
		}
		
		protected function commitData():void
		{
			if(this._owner)
			{
				if( _data )
				{
					_nameLabel.visible = _contactLabel.visible = true;
					
					_nameLabel.text = _data.name;
					_contactLabel.text = _data.selectedContactElement;
					
					switch(_data.sponsorType)
					{
						case SponsorTypes.EMAIL:
						{
							if( _data.emails.length > 1 )
							{
								_background.addEventListener(TouchEvent.TOUCH, onShowList);
								_arrowDown.visible = true;
								
								_contactElementsList.dataProvider = new HierarchicalCollection([ { header: "", children: _data.emails } ]);
								_contactElementsList.setSelectedLocation(0,0);
								_contactElementsList.addEventListener(Event.CHANGE, onContactElementSelected);
							}
							else
							{
								_arrowDown.visible = false;
							}
							break;
						}
						case SponsorTypes.SMS:
						{
							if( _data.phones.length > 1 )
							{
								_background.addEventListener(TouchEvent.TOUCH, onShowList);
								_arrowDown.visible = true;
								
								_contactElementsList.dataProvider = new HierarchicalCollection([ { header: "", children: _data.phones } ]);
								_contactElementsList.setSelectedLocation(0,0);
								_contactElementsList.addEventListener(Event.CHANGE, onContactElementSelected);
							}
							else
							{
								_arrowDown.visible = false;
							}
							break;
						}
					}
				}
				else
				{
					_contactElementsList.removeEventListener(Event.CHANGE, onContactElementSelected);
					_background.removeEventListener(TouchEvent.TOUCH, onShowList);
					_arrowDown.visible = false;
					_nameLabel.text = _contactLabel.text = "";
				}
			}
			else
			{
				_contactElementsList.removeEventListener(Event.CHANGE, onContactElementSelected);
				_background.removeEventListener(TouchEvent.TOUCH, onShowList);
				_arrowDown.visible = false;
				_nameLabel.visible = _contactLabel.visible = false;
			}
		}
		
		protected function layout():void
		{
			_topStripe.width = this.actualWidth;
			_topStripe.visible = _index == 0 ? false : true;
			
			if( this.owner && this.owner.dataProvider && (this.owner.dataProvider.length - 1) == _index )
			{
				_bottomStripe.visible = true;
				_bottomStripe.y = this.actualHeight - _strokeThickness;
				_bottomStripe.width = this.actualWidth;
			}
			else
			{
				_bottomStripe.visible = false;
			}
			
			_contactElementsList.width = this.actualWidth * 0.8;
			
			_nameLabel.width = this.actualWidth * 0.5 - _padding;
			_nameLabel.validate();
			_nameLabel.y = ((_itemHeight * 0.5) - _nameLabel.height) * 0.5;
			_nameLabel.x = _padding;
			
			_contactLabel.validate();
			_contactLabel.y = ((_itemHeight * 0.5) - _nameLabel.height) * 0.5 + (_itemHeight * 0.5);
			_contactLabel.x = _padding;
			
			_arrowDown.x = _contactLabel.x + _contactLabel.width + scaleAndRoundToDpi(10) + _arrowDown.width * 0.5;
			_arrowDown.y = (this.actualHeight - _contactLabel.height) * 0.5 + _contactLabel.y - _arrowDown.height * 0.5;
			
			_inviteButton.height = this.actualHeight * 0.7;
			_inviteButton.width = this.actualWidth * 0.3;
			_inviteButton.alignPivot();
			_inviteButton.x = _loader.x = this.actualWidth - (_inviteButton.width * 0.5) - scaleAndRoundToDpi(20);
			_inviteButton.y = _loader.y = this.actualHeight * 0.5;
		}
//------------------------------------------------------------------------------------------------------------
//	Handlers
//------------------------------------------------------------------------------------------------------------
		
		/**
		 * Try to invite the contact, whether by email or sms.
		 */		
		private function onInvite(event:Event):void
		{
			if( AirNetworkInfo.networkInfo.isConnected() )
			{
				Flox.logEvent("Parrainage par " + (_data.sponsorType == SponsorTypes.SMS ? "sms" : "email"), { Total:"Total" });
				
				_isInviting = true;
				touchable = false;
				
				TweenMax.to(_inviteButton, 0.75, { scaleX:0, scaleY:0, autoAlpha:0, ease:Bounce.easeOut });
				TweenMax.to(_loader, 1, { delay:0.5, scaleX:GlobalConfig.dpiScale, scaleY:GlobalConfig.dpiScale, autoAlpha:1, ease:Elastic.easeOut });
				
				TweenMax.delayedCall(1.25, Remote.getInstance().parrainer, [ _data.sponsorType, [ { identifiant:_data.selectedContactElement, filleul:_data.name } ], onParrainageSuccess, onParrainageFailure, onParrainageFailure, 2, AbstractEntryPoint.screenNavigator.activeScreenID ]);
			}
			else
			{
				InfoManager.showTimed(_("Aucune connexion Internet."), InfoManager.DEFAULT_DISPLAY_TIME, InfoContent.ICON_CROSS);
			}
		}
		
		/**
		 * The parrainage was a success.
		 * 
		 * <p>If the <code>result.code</code> is 0, this means that the user
		 * could not be authenticated in the server side or that the parameters
		 * sent were invalid or that we could not send the email because it is 
		 * already in the database (existing account in Ludokado to we can't 
		 * invite him as a sponsor) or that the mail is not allowed. In this
		 * case, we disable the "invite" button and change the label to indicate
		 * that an error occurred.</p>
		 * 
		 * <p>Otherwise if it is equal to 1, this means that the email could
		 * be sent. In this case, we disable the "invite" button and change the
		 * label to indicate that the email / sms have been sent.</p>
		 */		
		public function onParrainageSuccess(result:Object):void
		{
			_isInviting = false;
			
			switch(result.code)
			{
				case 0: // error
				{
					Flox.logEvent("Parrainage par " + (_data.sponsorType == SponsorTypes.SMS ? "sms" : "email"), { Etat:"Echec" });
					InfoManager.showTimed(result.txt, 1.5, InfoContent.ICON_CROSS);
					onParrainageFailure();
					break;
				}
				case 1: // success
				{
					result = (result.tab_parrainage as Array)[0];
					
					switch(result.code)
					{
						case 0:
						{
							Flox.logEvent("Parrainage par " + (_data.sponsorType == SponsorTypes.SMS ? "sms" : "email"), { Etat:"Echec" });
							
							_isInvited = true;
							touchable = false;
							
							_inviteButton.isEnabled = false;
							_inviteButton.label = _("Echec");
							TweenMax.to(_inviteButton, 0.75, { delay:0.5, scaleX:1, scaleY:1, autoAlpha:1, ease:Bounce.easeOut });
							TweenMax.to(_loader, 0.75, { scaleX:0, scaleY:0, autoAlpha:0, ease:Bounce.easeOut });
							
							break;
						}
						case 1:
						{
							Flox.logEvent("Parrainage par " + (_data.sponsorType == SponsorTypes.SMS ? "sms" : "email"), { Etat:"Succes" });
							
							_isInvited = true;
							touchable = false;
							
							_inviteButton.isEnabled = false;
							_inviteButton.label = _("Envoyé");
							TweenMax.to(_inviteButton, 0.75, { delay:0.5, scaleX:1, scaleY:1, autoAlpha:1, ease:Bounce.easeOut });
							TweenMax.to(_loader, 0.75, { scaleX:0, scaleY:0, autoAlpha:0, ease:Bounce.easeOut });
							
							break;
						}
							
						default:
						{
							onParrainageFailure();
							break;
						}
					}
					
					break;
				}
			}
		}
		
		/**
		 * An error occurred while trying to send the email / sms.
		 */		
		private function onParrainageFailure(error:Object = null):void
		{
			Flox.logEvent("Parrainage par " + (_data.sponsorType == SponsorTypes.SMS ? "sms" : "email"), { Etat:"Echec" });
			
			_isInviting = false;
			touchable = true;
			
			_inviteButton.label = _("Réessayer");
			TweenMax.to(_inviteButton, 0.75, { delay:0.5, scaleX:1, scaleY:1, autoAlpha:1, ease:Bounce.easeOut });
			TweenMax.to(_loader, 0.75, { scaleX:0, scaleY:0, autoAlpha:0, ease:Bounce.easeOut });
		}
		
		/**
		 * When a contact element is selected in the grouped list displayed as
		 * a popup (whether a phone number or an email), we update the label
		 * field and the current selected contact element. This way, when the
		 * user touches the "invite all" button, we know which element to use
		 * to send the invitation.
		 */		
		private function onContactElementSelected(event:Event):void
		{
			_popUpContentManager.close();
			_data.selectedContactElement = String(_contactElementsList.selectedItem);
			_contactLabel.text = _data.selectedContactElement;
		}
		
		/**
		 * Called by <code>SponsorInviteScreen</code> when the user touches
		 * the "invite all" button to display a loader in place of the "invite"
		 * button to show that the request is processing. At the same time, the
		 * item renderer becomes untouchable in order to avoid double requests
		 * for the same contact.
		 */		
		public function setInviteMode():void
		{
			touchable = false;
			_isInviting = true;
			
			TweenMax.to(_inviteButton, 0.75, { scaleX:0, scaleY:0, autoAlpha:0, ease:Bounce.easeOut });
			TweenMax.to(_loader, 0.75, { delay:0.5, scaleX:GlobalConfig.dpiScale, scaleY:GlobalConfig.dpiScale, autoAlpha:1, ease:Bounce.easeOut });
		}
		
		/**
		 * Called by <code>SponsorInviteScreen</code> when the "invite all" request
		 * failed. The item renderer will become touchable and we'll display a "retry"
		 * button to invite the user to try again.
		 */		
		public function hideInviteMode():void
		{
			_isInviting = false;
			touchable = true;
			
			_inviteButton.label = _("Réessayer");
			TweenMax.to(_inviteButton, 0.75, { delay:0.5, scaleX:1, scaleY:1, autoAlpha:1, ease:Bounce.easeOut });
			TweenMax.to(_loader, 0.75, { scaleX:0, scaleY:0, autoAlpha:0, ease:Bounce.easeOut });
		}
		
		/**
		 * Shows the contact elements list as a popup in order to allow
		 * the user to select to which email / phone number we will send
		 * the invitation (in case there are more than one element).
		 */		
		private function onShowList(event:TouchEvent):void
		{
			const touches:Vector.<Touch> = event.getTouches(this, null, HELPER_TOUCHES_VECTOR);
			if(touches.length == 0)
			{
				return;
			}
			if(this.touchPointID >= 0)
			{
				var touch:Touch;
				for each(var currentTouch:Touch in touches)
				{
					if(currentTouch.id == this.touchPointID)
					{
						touch = currentTouch;
						break;
					}
				}
				if(!touch)
				{
					HELPER_TOUCHES_VECTOR.length = 0;
					return;
				}
				if(touch.phase == TouchPhase.ENDED)
				{
					this.touchPointID = -1;
					
					touch.getLocation(this, HELPER_POINT);
					if(this.hitTest(HELPER_POINT, true) != null && !this._isSelected)
					{
						_popUpContentManager.open(_contactElementsList, this);
					}
				}
			}
			else
			{
				for each(touch in touches)
				{
					if(touch.phase == TouchPhase.BEGAN)
					{
						this.touchPointID = touch.id;
						break;
					}
				}
			}
			HELPER_TOUCHES_VECTOR.length = 0;
		}
		
		/**
		 * When the user scrolls whithin the parent, we need to clear
		 * the touch id so that this item events won't be triggered.
		 */		
		protected function onParentScroll(event:Event):void
		{
			this.touchPointID = -1;
		}
		
//------------------------------------------------------------------------------------------------------------
//	GET / SET
//------------------------------------------------------------------------------------------------------------
		
		protected var _data:ContactData;
		
		public function get data():Object
		{
			return this._data;
		}
		
		public function set data(value:Object):void
		{
			if(this._data == value)
			{
				return;
			}
			this._data = ContactData(value);
			this.invalidate(INVALIDATION_FLAG_DATA);
		}
		
		protected var _index:int = -1;
		
		public function get index():int
		{
			return this._index;
		}
		
		public function set index(value:int):void
		{
			if(this._index == value)
			{
				return;
			}
			this._index = value;
			this.invalidate(INVALIDATION_FLAG_DATA);
		}
		
		protected var _owner:List;
		
		public function get owner():List
		{
			return List(this._owner);
		}
		
		public function set owner(value:List):void
		{
			if(this._owner == value)
			{
				return;
			}
			if(this._owner)
			{
				this._owner.removeEventListener(Event.SCROLL, onParentScroll);
			}
			this._owner = value;
			if(this._owner)
			{
				this._owner.addEventListener(Event.SCROLL, onParentScroll);
			}
			this.invalidate(INVALIDATION_FLAG_DATA);
		}
		
		protected var _isSelected:Boolean;
		
		public function get isSelected():Boolean
		{
			return this._isSelected;
		}
		
		public function set isSelected(value:Boolean):void
		{
			if(this._isSelected == value)
			{
				return;
			}
			this._isSelected = value;
			this.invalidate(INVALIDATION_FLAG_SELECTED);
			this.dispatchEventWith(Event.CHANGE);
		}
		
		public function get isInviting():Boolean 
		{
			return _isInviting;
		}
		
		public function get isInvited():Boolean
		{
			return _isInvited;
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
//------------------------------------------------------------------------------------------------------------
		
		override public function dispose():void
		{
			if( _owner )
				_owner.removeEventListener(Event.SCROLL, onParentScroll);
			
			TweenMax.killTweensOf(_inviteButton);
			TweenMax.killTweensOf(_loader);
			
			_background.removeEventListener(TouchEvent.TOUCH, onShowList);
			_background.removeFromParent(true);
			_background = null;
			
			_topStripe.removeFromParent(true);
			_topStripe = null;
			
			_bottomStripe.removeFromParent(true);
			_bottomStripe = null;
			
			_nameLabel.removeFromParent(true);
			_nameLabel = null;
			
			_contactLabel.removeFromParent(true);
			_contactLabel = null;
			
			_arrowDown.removeFromParent(true);
			_arrowDown = null;
			
			_inviteButton.removeEventListener(Event.TRIGGERED, onInvite);
			_inviteButton.removeFromParent(true);
			_inviteButton = null;
			
			_popUpContentManager.close();
			_popUpContentManager.dispose();
			_popUpContentManager = null;
			
			_contactElementsList.removeEventListener(Event.CHANGE, onContactElementSelected);
			_contactElementsList.removeFromParent(true);
			_contactElementsList = null;
			
			Starling.juggler.remove(_loader);
			_loader.removeFromParent(true);
			_loader = null;
			
			_checkIcon.removeFromParent(true);
			_checkIcon = null;
			
			_data = null;
			
			super.dispose();
		}
	}
}


