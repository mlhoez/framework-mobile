/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 4 oct. 2013
*/
package com.ludofactory.mobile.navigation.alert
{
	import com.ludofactory.common.gettext.ISO_639_1;
	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.common.gettext.aliases._n;
	import com.ludofactory.common.utils.Utilities;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.AbstractGameInfo;
	import com.ludofactory.mobile.core.GameMode;
	import com.ludofactory.mobile.core.manager.MemberManager;
	import com.ludofactory.mobile.core.ScreenIds;
	import com.ludofactory.mobile.core.storage.Storage;
	import com.ludofactory.mobile.core.storage.StorageConfig;
	import com.ludofactory.mobile.navigation.achievements.TrophyData;
	import com.ludofactory.mobile.navigation.achievements.TrophyManager;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.push.AbstractElementToPush;
	import com.ludofactory.mobile.core.push.AlertType;
	import com.ludofactory.mobile.core.push.GameSession;
	import com.ludofactory.mobile.core.push.PushNewCSMessage;
	import com.ludofactory.mobile.core.push.PushNewCSThread;
	import com.ludofactory.mobile.core.push.PushState;
	import com.ludofactory.mobile.core.push.PushTrophy;
	import com.ludofactory.mobile.core.push.PushType;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import feathers.skins.IStyleProvider;
	
	import flash.geom.Point;
	import flash.text.TextFormat;
	
	import feathers.controls.ImageLoader;
	import feathers.controls.Label;
	import feathers.controls.List;
	import feathers.controls.renderers.IListItemRenderer;
	import feathers.core.FeathersControl;
	
	import starling.display.Quad;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.utils.formatString;
	
	/**
	 * Custom item renderer used in the CSThreadScreen to display
	 * a conversation between the user and the customer service.
	 */	
	public class AlertItemRenderer extends FeathersControl implements IListItemRenderer
	{
		private static const HELPER_POINT:Point = new Point();
		private static const HELPER_TOUCHES_VECTOR:Vector.<Touch> = new <Touch>[];
		protected var _touchPointID:int = -1;
		
		/**
		 * The minimum height of the item renderer */		
		private var _minItemHeight:int;
		
		/**
		 * The padding between the left side if the message container
		 * image and the message */		
		private var _paddingMessageLeft:int;	
		/**
		 * The padding between the right side if the message container
		 * image and the message */		
		private var _paddingMessageRight:int;
		/**
		 * The padding between the top side if the message container
		 * image and the message */		
		private var _paddingMessageTop:int;
		/**
		 * The padding between the bottom side if the message container
		 * image and the message */		
		private var _paddingMessageBottom:int;
		/**
		 * The gap between labels. */		
		private var _gap:int;
		
		/**
		 * The background. */		
		private var _background:Quad;
		/**
		 * The date of the message */		
		private var _date:Label;
		/**
		 * The message label */		
		private var _message:Label;
		/**
		 * The access button. */		
		private var _accessButton:Label;
		
		private var _savedWidth:Number;
		
		/**
		 * The icon. */		
		private var _icon:ImageLoader;
		
		public function AlertItemRenderer()
		{
			super();
			addEventListener(TouchEvent.TOUCH, touchHandler);
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			_minItemHeight = scaleAndRoundToDpi(100);
			_gap = scaleAndRoundToDpi(10);
			_paddingMessageTop = _paddingMessageBottom = scaleAndRoundToDpi(20);
			_paddingMessageLeft = _paddingMessageRight = scaleAndRoundToDpi(20);
			
			this.width = _savedWidth = GlobalConfig.stageWidth * (AbstractGameInfo.LANDSCAPE ? 0.6 : 0.8);
			this.height = _minItemHeight;
			
			_background = new Quad(this.width, _minItemHeight, 0xff0000);
			addChild(_background);
			
			_date = new Label();
			addChild(_date);
			_date.textRendererProperties.textFormat = new TextFormat(Theme.FONT_ARIAL, scaleAndRoundToDpi(28), Theme.COLOR_LIGHT_GREY, true);
			
			_message = new Label();
			addChild(_message);
			_message.textRendererProperties.textFormat = new TextFormat(Theme.FONT_ARIAL, scaleAndRoundToDpi(28), Theme.COLOR_DARK_GREY, true);
			
			_accessButton = new Label();
			_accessButton.text = _("Accéder");
			addChild(_accessButton);
			_accessButton.textRendererProperties.textFormat = new TextFormat(Theme.FONT_ARIAL, scaleAndRoundToDpi(24), 0x00a9f4, true);
			
			_icon = new ImageLoader();
			_icon.snapToPixels = true;
			_icon.scaleX = _icon.scaleY = GlobalConfig.dpiScale;
			_icon.alpha = 0.75;
			addChild(_icon);
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
			var newWidth:Number = this.explicitWidth;
			if(needsWidth)
			{
				newWidth = _background.width;
			}
			var newHeight:Number = this.explicitHeight;
			if(needsHeight)
			{
				newHeight = _background.height;
			}
			return this.setSizeInternal(newWidth, newHeight, false);
		}
		
		protected function commitData():void
		{
			if(this._owner)
			{
				if( _data )
				{
					_message.visible = _date.visible = true;
					
					_date.text = Utilities.formatDate(_data.creationDate);
					
					_accessButton.visible = false;
					
					if( _data.state == PushState.PUSHED )
					{
						// FIXME Essayer de mettre des messages plus précis peut être, ou une autre façon
						// d'afficher les élements pushés.
						_message.text = _data.pushSuccessMessage;
					}
					else
					{
						var textToDisplay:String;
						
						switch(_data.pushType)
						{
							case PushType.GAME_SESSION:
							{
								/*var priceText:String;
								switch (GameSession(_data).gamePrice)
								{
									case GameSession.PRICE_CREDIT: { priceText = Localizer.getInstance().translate("COMMON.WITH_CREDIT"); break; }
									case GameSession.PRICE_FREE:   { priceText = Localizer.getInstance().translate("COMMON.WITH_FREE");   break; }
									case GameSession.PRICE_POINT:  { priceText = Localizer.getInstance().translate("COMMON.WITH_POINT");  break; }
								}*/
								
								_icon.source = AbstractEntryPoint.assets.getTexture("header-game-session-simple-icon");
								
								_message.text = formatString( GameSession(_data).gameType == GameMode.SOLO ? _n("{0} Point sera définitivement crédité sur votre compte dès que vous serez connecté à internet.", "{0} Points seront définitivement crédités sur votre compte dès que vous serez connecté à internet.", GameSession(_data).numStarsOrPointsEarned) : _n("{0} Rubis sera définitivement comptabilisée pour le tournoi en cours dès que vous serez connecté à internet.", "{0} Rubis seront définitivement comptabilisées pour le tournoi en cours dès que vous serez connecté à internet.", GameSession(_data).numStarsOrPointsEarned),
									GameSession(_data).numStarsOrPointsEarned);
								
								break;
							}
							
							// Plus utilisé pour le moment carl es trophés sont intégrés dans l'objet GameSession, mais le laisser
							// afin de pouvoir intégrer plus tard des coupes dans l'appli (donc non liées à une partie)
							case PushType.TROPHY:
							{
								_icon.source = AbstractEntryPoint.assets.getTexture("header-trophy-simple-icon");
								
								var trophy:TrophyData = TrophyManager.getInstance().getTrophyDataById( PushTrophy(_data).trophyId);
								_message.text = formatString(_("Votre coupe {0} est en attente d'envoi."), trophy.title );
								
								break;
							}
							
							case PushType.CUSTOMER_SERVICE_NEW_THREAD:
							{
								_icon.source = AbstractEntryPoint.assets.getTexture("header-cs-simple-icon");
								
								textToDisplay = PushNewCSThread(_data).message.length <= 50 ? PushNewCSThread(_data).message : (PushNewCSThread(_data).message.slice(0, 50) + "...");
								_message.text = formatString(_("Votre message « {0} » adressé au service client sera envoyé dès que vous serez connecté à internet."), textToDisplay );
								
								break;
							}
								
							case PushType.CUSTOMER_SERVICE_NEW_MESSAGE:
							{
								_icon.source = AbstractEntryPoint.assets.getTexture("header-cs-simple-icon");
								
								textToDisplay = PushNewCSMessage(_data).message.length <= 50 ? PushNewCSMessage(_data).message : (PushNewCSMessage(_data).message.slice(0, 50) + "...");
								_message.text = formatString(_("Votre message « {0} » adressé au service client sera envoyé dès que vous serez connecté à internet."), textToDisplay );
								
								break;
							}
							case AlertType.CUSTOMER_SERVICE:
							{
								_icon.source = AbstractEntryPoint.assets.getTexture("header-cs-simple-icon");
								
								_accessButton.visible = true;
								_message.text = formatString(_n("Vous avez reçu {0} message du service client.", "Vous avez reçu {0} messages du service client.", AbstractEntryPoint.alertData.numCustomerServiceImportantAlerts), AbstractEntryPoint.alertData.numCustomerServiceImportantAlerts);
								
								break;
							}
							case AlertType.SPONSOR:
							{
								_icon.source = AbstractEntryPoint.assets.getTexture("header-sponsoring-simple-icon");
								
								_accessButton.visible = true;
								_message.text = formatString(_n("Vous avez {0} filleul accepté dans votre espace parrainage.", "Vous avez {0} filleuls acceptés dans votre espace parrainage.", AbstractEntryPoint.alertData.numSponsorAlerts), AbstractEntryPoint.alertData.numSponsorAlerts);
								
								break;
							}
							case AlertType.GIFTS:
							{
								_icon.source = AbstractEntryPoint.assets.getTexture("header-gifts-simple-icon");
								
								_accessButton.visible = true;
								_message.text = formatString(_n("Vous avez gagné {0} récompense.", "Vous avez gagné {0} récompenses.", AbstractEntryPoint.alertData.numGainAlerts), AbstractEntryPoint.alertData.numGainAlerts);
								break;
							}
							case AlertType.TROPHIES:
							{
								_icon.source = AbstractEntryPoint.assets.getTexture("header-trophy-simple-icon");
								
								_accessButton.visible = true;
								_message.text = formatString(_n("Vous avez gagné {0} coupe.", "Vous avez gagné {0} coupes.", AbstractEntryPoint.alertData.numTrophiesAlerts), AbstractEntryPoint.alertData.numTrophiesAlerts);
								break;
							}
							case AlertType.ANONYMOUS_GAME_SESSION:
							{
								_icon.source = AbstractEntryPoint.assets.getTexture("header-game-session-simple-icon");
								
								_accessButton.text = _("S'identifier");
								_accessButton.visible = true;
								_message.text = formatString(_n("{0} Rubis sera comptabilisée pour le tournoi en cours dès que vous serez identifié.", "{0} Rubis seront comptabilisées pour le tournoi en cours dès que vous serez identifié.", MemberManager.getInstance().getNumStarsEarnedInAnonymousGameSessions()), MemberManager.getInstance().getNumStarsEarnedInAnonymousGameSessions());
								break;
							}
							case AlertType.ANONYMOUS_TROPHIES:
							{
								_icon.source = AbstractEntryPoint.assets.getTexture("header-trophy-simple-icon");
								
								_accessButton.text = _("S'identifier");
								_accessButton.visible = true;
								_message.text = formatString(_n("{0} Coupe sera définitivement validée dès que vous serez identifié.", "{0} Coupes seront définitivement validées dès que vous serez identifié.", MemberManager.getInstance().getNumStarsEarnedInAnonymousGameSessions()), MemberManager.getInstance().getNumTrophiesEarnedInAnonymousGameSessions());
								break;
							}
							case AlertType.NEW_LANGAUGES:
							{
								_icon.source = AbstractEntryPoint.assets.getTexture("header-language-simple-icon");
								
								var newLanguages:Array = Storage.getInstance().getProperty(StorageConfig.PROPERTY_NEW_LANGUAGES).concat();
								for(var i:int; i < newLanguages.length; i++)
									newLanguages[i] = _(ISO_639_1[String(newLanguages[i]).toUpperCase()]); // replace by correct country name
								
								_accessButton.text = _("Accéder");
								_accessButton.visible = true;
								_message.text = formatString(_n("Une nouvelle langue est disponible : {0} !", "De nouvelles langues sont disponibles : {0} !", newLanguages.length), newLanguages.join(", "));
								break;
							}
						}
						
						textToDisplay = null;
					}
					
					if( _data.state == PushState.PUSHED )
						_background.color = ((_index % 2) == 0) ? 0xd04800 : 0xff5800;
					else
						_background.color = ((_index % 2) == 0) ? 0xf7f7f7 : 0xffffff;
				}
				else
				{
					_message.text = _date.text = "";
				}
			}
			else
			{
				_message.visible = _date.visible = false;
			}
		}
		
		protected function layout():void
		{
			_date.width = _message.width = _savedWidth - _paddingMessageLeft - _paddingMessageRight;
			
			_date.x = _message.x = _paddingMessageLeft;
			
			_date.y = _paddingMessageTop;
			_date.validate();
			
			_message.y = _date.y + _date.height + _gap;
			_message.validate();
			
			_accessButton.y = _message.y + _message.height;
			_accessButton.validate();
			_accessButton.x = _savedWidth - _paddingMessageRight - _accessButton.width;
			
			_background.height = Math.max((_message.y + _message.height + (_accessButton.visible ? _accessButton.height : 0)), _minItemHeight) + _paddingMessageBottom;
			
			_icon.validate();
			_icon.x = actualWidth - _icon.width;
			_icon.y = _paddingMessageTop;
			
			setSize(_savedWidth, _background.height);
		}
		
		protected var _data:AbstractElementToPush;
		
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
			this._data = AbstractElementToPush(value);
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
			this._owner = value;
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
		
		public function set minItemHeight(val:int):void
		{
			_minItemHeight = val;
		}
		
		public function set paddingMessageLeft(val:int):void
		{
			_paddingMessageLeft = val;
		}
		
		public function set paddingMessageRight(val:int):void
		{
			_paddingMessageRight = val;
		}
		
		public function set paddingMessageTop(val:int):void
		{
			_paddingMessageTop = val;
		}
		
		public function set paddingMessageBottom(val:int):void
		{
			_paddingMessageBottom = val;
		}
		
		public function set gap(val:int):void
		{
			_gap = val;
		}
		
		protected function touchHandler(event:TouchEvent):void
		{
			if(!this._isEnabled)
			{
				return;
			}
			
			const touches:Vector.<Touch> = event.getTouches(this, null, HELPER_TOUCHES_VECTOR);
			if(touches.length == 0)
			{
				//end of hover
				return;
			}
			if(this._touchPointID >= 0)
			{
				var touch:Touch;
				for each(var currentTouch:Touch in touches)
				{
					if(currentTouch.id == this._touchPointID)
					{
						touch = currentTouch;
						break;
					}
				}
				
				if(!touch)
				{
					//end of hover
					HELPER_TOUCHES_VECTOR.length = 0;
					return;
				}
				
				if(touch.phase == TouchPhase.ENDED)
				{
					this._touchPointID = -1;
					touch.getLocation(this, HELPER_POINT);
					var isInBounds:Boolean = this.hitTest(HELPER_POINT, true) != null;
					if(isInBounds)
					{
						switch(_data.pushType)
						{
							case AlertType.CUSTOMER_SERVICE:
							{
								AbstractEntryPoint.screenNavigator.showScreen( ScreenIds.HELP_HOME_SCREEN );
								break;
							}
							case AlertType.GIFTS:
							{
								AbstractEntryPoint.screenNavigator.screenData.indexToDisplayInMyAccount = 2;
								AbstractEntryPoint.screenNavigator.showScreen( ScreenIds.MY_ACCOUNT_SCREEN );
								break;
							}
							case AlertType.SPONSOR:
							{
								AbstractEntryPoint.screenNavigator.showScreen( ScreenIds.SPONSOR_FRIENDS_SCREEN );
								break;
							}
							case AlertType.TROPHIES:
							{
								AbstractEntryPoint.screenNavigator.showScreen( ScreenIds.TROPHY_SCREEN );
								break;
							}
							case AlertType.ANONYMOUS_GAME_SESSION:
							case AlertType.ANONYMOUS_TROPHIES:
							{
								AbstractEntryPoint.screenNavigator.showScreen( ScreenIds.AUTHENTICATION_SCREEN );
								break;
							}
							case AlertType.NEW_LANGAUGES:
							{
								AbstractEntryPoint.screenNavigator.showScreen( ScreenIds.SETTINGS_SCREEN );
								break;
							}
						}
					}
				}
			}
			else //if we get here, we don't have a saved touch ID yet
			{
				for each(touch in touches)
				{
					if(touch.phase == TouchPhase.BEGAN)
					{
						this._touchPointID = touch.id;
						break;
					}
				}
			}
			HELPER_TOUCHES_VECTOR.length = 0;
		}
		
		/**
		 * Required for the new Theme. */
		public static var globalStyleProvider:IStyleProvider;
		override protected function get defaultStyleProvider():IStyleProvider
		{
			return AlertItemRenderer.globalStyleProvider;
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
//------------------------------------------------------------------------------------------------------------
		
		override public function dispose():void
		{
			removeEventListener(TouchEvent.TOUCH, touchHandler);
			
			_background.removeFromParent(true);
			_background = null;
			
			_message.removeFromParent(true);
			_message = null;
			
			_date.removeFromParent(true);
			_date = null;
			
			_accessButton.removeFromParent(true);
			_accessButton = null;
			
			_data = null;
			
			super.dispose();
		}
	}
}