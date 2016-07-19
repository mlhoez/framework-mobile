/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 18 sept. 2013
*/
package com.ludofactory.mobile.core.notification.content.neww.highscore
{
	
	import com.ludofactory.mobile.core.notification.content.neww.duel.*;
	
	import com.ludofactory.common.gettext.LanguageManager;
	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.common.utils.Utilities;
	import com.ludofactory.common.utils.logs.log;
	import com.ludofactory.common.utils.roundUp;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.ButtonFactory;
	import com.ludofactory.mobile.FacebookButton;
	import com.ludofactory.mobile.core.AbstractGameInfo;
	import com.ludofactory.mobile.core.manager.MemberManager;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import feathers.controls.Callout;
	import feathers.controls.Label;
	import feathers.controls.List;
	import feathers.controls.renderers.IListItemRenderer;
	import feathers.core.FeathersControl;
	
	import flash.geom.Point;
	
	import starling.display.MeshBatch;
	import starling.display.Quad;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.text.TextField;
	import starling.text.TextFormat;
	import starling.utils.StringUtil;
	
	public class HighscoreRankingItemRenderer extends FeathersControl implements IListItemRenderer
	{
		private static const HELPER_POINT:Point = new Point();
		private static const HELPER_TOUCHES_VECTOR:Vector.<Touch> = new <Touch>[];
		protected var _touchPointID:int = -1;
		
		private static var _isCalloutDisplaying:Boolean = false;
		private static var _calloutLabel:Label;
		private static var _callout:Callout;
		
		/**
		 * The base height of a line in the list. */		
		private static const BASE_HEIGHT:int = 60;
		
		/**
		 * The base stroke thickness. */		
		private static const BASE_STROKE_THICKNESS:int = 2;
		/**
		 * The scaled stroke thickness. */		
		private var _strokeThickness:Number;
		
		/**
		 * Whether the elements have already been positioned. */		
		private var _elementsPositioned:Boolean = false;
		
		/**
		 * The idle background. */		
		private var _idleBackground:MeshBatch;
		/**
		 * 	The selected background. */		
		private var _selectedBackground:MeshBatch;
		
		/**
		 * The rank label. */		
		private var _rankLabel:TextField;
		/**
		 * The name label. */		
		private var _pseudoLabel:TextField;
		/**
		 * The number of stars label. */		
		private var _numCupsLabel:TextField;

		/**
		 * Facebook button that will associate the account or directly publish, depending on the actual state. */
		private var _facebookButton:FacebookButton;
		
		public function HighscoreRankingItemRenderer()
		{
			super();
			//this.touchable = false;
			addEventListener(TouchEvent.TOUCH, touchHandler);
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			_strokeThickness = scaleAndRoundToDpi(BASE_STROKE_THICKNESS);
			
			this.height = scaleAndRoundToDpi(BASE_HEIGHT);
			
			// labels
			_rankLabel = new TextField(50, this.height, "99 999", new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(30), 0x353535));
			_rankLabel.autoScale = true;
			//_rankLabel.border = true;
			_rankLabel.touchable = false;
			_rankLabel.wordWrap = false;
			addChild(_rankLabel);
			
			_pseudoLabel = new TextField(5, this.height, "99 999", new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(30), 0x353535));
			_pseudoLabel.autoScale = true;
			//_pseudoLabel.border = true;
			_pseudoLabel. touchable = false;
			_pseudoLabel.wordWrap = false;
			addChild(_pseudoLabel);
			
			_numCupsLabel = new TextField(5, this.height, "99 999", new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(30), 0x353535));
			_numCupsLabel.autoScale = true;
			//_numCupsLabel.border = true;
			_numCupsLabel.touchable = false;
			_numCupsLabel.wordWrap = false;
			addChild(_numCupsLabel);
		}
		
		override protected function draw():void
		{
			const dataInvalid:Boolean = this.isInvalid(INVALIDATION_FLAG_DATA);
			var sizeInvalid:Boolean = this.isInvalid(INVALIDATION_FLAG_SIZE);
			
			if(dataInvalid)
			{
				this.commitData();
			}
			
			sizeInvalid = this.autoSizeIfNeeded() || sizeInvalid;
			
			if(dataInvalid || sizeInvalid)
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
			_rankLabel.width = NaN;
			_rankLabel.height = NaN;
			var newWidth:Number = this.explicitWidth;
			if(needsWidth)
			{
				newWidth = _rankLabel.width;
			}
			var newHeight:Number = this.explicitHeight;
			if(needsHeight)
			{
				newHeight = _rankLabel.height;
			}
			return this.setSizeInternal(newWidth, newHeight, false);
		}
		
		protected function commitData():void
		{
			if( _data)
			{
				_rankLabel.format.color = _pseudoLabel.format.color = _numCupsLabel.format.color = _data.isMe ? 0x401800 : 0x353535;
				
				_rankLabel.text =  Utilities.splitThousands(_data.rank);
				_pseudoLabel.text = _data.pseudo;
				_numCupsLabel.text =  Utilities.splitThousands(_data.score);
				
				if(!_selectedBackground)
				{
					// idle
					_idleBackground = new MeshBatch();
					const background:Quad = new Quad( this.actualWidth, this.height, 0xfbfbfb );
					_idleBackground.addMesh( background );
					background.x = actualWidth * 0.25;
					background.width = actualWidth * 0.5;
					background.color = 0xeeeeee;
					_idleBackground.addMesh( background );
					background.x = 0;
					background.y = this.height - _strokeThickness;
					background.width  = actualWidth;
					background.height = _strokeThickness;
					background.color  = 0xbfbfbf;
					_idleBackground.addMesh( background );
					addChildAt(_idleBackground, 0);
					
					// selected
					_selectedBackground = new MeshBatch();
					background.y = 0;
					background.color = 0xffd800;
					background.height = this.height;
					_selectedBackground.addMesh( background );
					background.x = actualWidth * 0.25;
					background.width = actualWidth * 0.5;
					background.color = 0xffb400;
					_selectedBackground.addMesh( background );
					addChildAt(_selectedBackground, 0);
				}
				_selectedBackground.visible = _data.isMe;
				_idleBackground.visible = !_selectedBackground.visible;
			}
		}
		
		protected function layout():void
		{
			if(!_elementsPositioned)
			{
				_rankLabel.width = _numCupsLabel.width = actualWidth * 0.25;
				_pseudoLabel.width = actualWidth * 0.5;
				
				_numCupsLabel.x = actualWidth * 0.75;
				_pseudoLabel.x = actualWidth * 0.25;
				
				_elementsPositioned = true;
			}

			if(_data.isMe)
			{
				if(!_facebookButton)
				{
					_facebookButton = ButtonFactory.getFacebookButton(_("Partager mon score !"), ButtonFactory.FACEBOOK_TYPE_SHARE, StringUtil.format(_("Qui sera capable de me battre sur {0} ?"), AbstractGameInfo.GAME_NAME),
							"",
							StringUtil.format(_("Venez me défiez et tenter de battre mon meilleur score de {0} !"), MemberManager.getInstance().highscore),
							_("http://www.ludokado.com/"),
							StringUtil.format(_("http://img.ludokado.com/img/frontoffice/{0}/mobile/publication/publication_highscore.jpg"), LanguageManager.getInstance().lang));
					_facebookButton.y = actualHeight;
					_facebookButton.x = roundUp((actualWidth - _facebookButton.width) * 0.5);
					addChild(_facebookButton);
				}
				
				_selectedBackground.height = _idleBackground.height = actualHeight + _facebookButton.height + scaleAndRoundToDpi(10);
				setSize(this.actualWidth, (actualHeight + _facebookButton.height + scaleAndRoundToDpi(10)));
			}
			else
			{
				if(_facebookButton)
				{
					_facebookButton.removeFromParent(true);
					_facebookButton = null;
				}
				
				_selectedBackground.height = _idleBackground.height = actualHeight;
				setSize(this.actualWidth, actualHeight);
			}
		}
		
		protected var _data:HighscoreRankingData;
		
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
			this._data = HighscoreRankingData(value);
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
				this._owner.removeEventListener(Event.SCROLL, owner_scrollHandler);
			}
			this._owner = value;
			if(this._owner)
			{
				this._owner.addEventListener(Event.SCROLL, owner_scrollHandler);
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
					var isInBounds:Boolean = this.hitTest(HELPER_POINT) != null;
					if(isInBounds)
					{
						/*if( _data.isTruncated )
						{
							if( !_isCalloutDisplaying )
							{
								_isCalloutDisplaying = true;
								if( !_calloutLabel )
								{
									_calloutLabel = new Label();
								}
								_calloutLabel.text = _data.pseudo + " (" + _data.countryCode + ")";
								_callout = Callout.show(_calloutLabel, this, Callout.DIRECTION_UP, false);
								_callout.disposeContent = false;
								_callout.touchable = false;
								_callout.addEventListener(Event.REMOVED_FROM_STAGE, onCalloutRemoved);
								_calloutLabel.textRendererProperties.textFormat = new TextFormat(Theme.FONT_ARIAL, scaleAndRoundToDpi(26), Theme.COLOR_DARK_GREY, false, false, null, null, null, TextFormatAlign.CENTER);
								_calloutLabel.textRendererProperties.wordWrap = false;
							}
						}*/
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
		
		private function onCalloutRemoved(event:Event):void
		{
			event.target.removeEventListener(Event.REMOVED_FROM_STAGE, onCalloutRemoved);
			_isCalloutDisplaying = false;
		}
		
		protected function owner_scrollHandler(event:Event):void
		{
			this._touchPointID = -1;
			if( _callout )
			{
				_callout.removeFromParent(true);
				_callout = null;
			}
		}
		
		protected var _factoryID:String;
		
		public function get factoryID():String
		{
			return this._factoryID;
		}
		
		public function set factoryID(value:String):void
		{
			this._factoryID = value;
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
		
		override public function dispose():void
		{
			removeEventListener(TouchEvent.TOUCH, touchHandler);
			
			if( this._owner )
				this._owner.removeEventListener(Event.SCROLL, owner_scrollHandler);
			
			_idleBackground.clear();
			_idleBackground.removeFromParent(true);
			_idleBackground = null;
			
			_selectedBackground.clear();
			_selectedBackground.removeFromParent(true);
			_selectedBackground = null;
			
			_numCupsLabel.removeFromParent(true);
			_numCupsLabel = null;
			
			_pseudoLabel.removeFromParent(true);
			_pseudoLabel = null;
			
			_rankLabel.removeFromParent(true);
			_rankLabel = null;
			
			_data = null;
			
			if( _calloutLabel )
			{
				_calloutLabel.removeFromParent(true);
				_calloutLabel = null;
			}
			
			if( _callout )
			{
				_callout.removeFromParent(true);
				_callout = null;
			}
			
			if(_facebookButton)
			{
				_facebookButton.removeFromParent(true);
				_facebookButton = null;
			}
			
			super.dispose();
		}
	}
}