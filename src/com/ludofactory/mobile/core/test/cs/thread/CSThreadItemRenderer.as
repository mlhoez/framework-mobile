/*
Copyright © 2006-2014 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 25 août 2013
*/
package com.ludofactory.mobile.core.test.cs.thread
{
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.controls.ImageLoaderCache;
	import com.ludofactory.mobile.core.authentication.MemberManager;
	import com.ludofactory.mobile.core.test.config.GlobalConfig;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import feathers.controls.Label;
	import feathers.controls.List;
	import feathers.controls.renderers.IListItemRenderer;
	import feathers.controls.text.TextBlockTextRenderer;
	import feathers.core.FeathersControl;
	import feathers.display.Scale9Image;
	
	import starling.display.Quad;
	import starling.display.QuadBatch;
	import starling.events.Event;
	import starling.textures.Texture;
	
	/**
	 * Custom item renderer used in the CSThreadScreen to display
	 * a conversation between the user and the customer service.
	 */	
	public class CSThreadItemRenderer extends FeathersControl implements IListItemRenderer
	{
		/**
		 * The minimum height of the item renderer */		
		private var _minItemHeight:int;
		
		/**
		 * The stripe height */		
		private var _stripeHeight:Number;
		
		/**
		 * The grey line height displayed on top of the container. */		
		private var _lineHeight:int;
		
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
		 * The date of the message */		
		private var _date:Label;
		/**
		 * The message label */		
		private var _message:Label;
		
		/**
		 * The stripe displayed behind a message "bubble". This is an
		 * orange stripe with a shadow at the bottom. */		
		private var _stripe:QuadBatch;
		/**
		 * The message gradient. */		
		private var _gradient:Quad;
		/**
		 * The user picture. */		
		private var _picture:ImageLoaderCache;
		/**
		 * The message background (the bubble). */		
		private var _messageBackground:Scale9Image;
		
		public function CSThreadItemRenderer()
		{
			super();
			this.touchable = false;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			this.width = GlobalConfig.stageWidth;
			this.height = _minItemHeight;
			
			_lineHeight = scaleAndRoundToDpi(2);
			
			_gradient = new Quad(this.width, _minItemHeight, 0xffffff);
			_gradient.setVertexColor(3, 0xeeeeee);
			_gradient.setVertexColor(2, 0xfafafa);
			addChild(_gradient);
			
			_stripe = new QuadBatch();
			addChild(_stripe);
			
			var quad:Quad = new Quad(this.width * 0.25, _stripeHeight, Theme.COLOR_ORANGE);
			_stripe.addQuad(quad);
			
			quad.width = this.width;
			quad.height = _lineHeight;
			quad.color = 0xc0c0c0;
			_stripe.addQuad(quad);
			
			quad.height = scaleAndRoundToDpi(25);
			quad.width = this.width * 0.25;
			quad.y = _stripeHeight;
			quad.color = 0x000000;
			quad.setVertexAlpha(0, 0.2);
			quad.setVertexAlpha(1, 0.2);
			quad.setVertexColor(2, 0xffffff);
			quad.setVertexAlpha(2, 0);
			quad.setVertexColor(3, 0xffffff);
			quad.setVertexAlpha(3, 0);
			_stripe.addQuad(quad);
			
			addChild(_messageBackground);
			
			_picture = new ImageLoaderCache();
			_picture.snapToPixels = true;
			addChild(_picture);
			
			_date = new Label();
			addChild(_date);
			_date.textRendererProperties.textFormat = Theme.csThreadIRDateTextFormat;
			
			_message = new Label();
			addChild(_message);
			_message.textRendererProperties.textFormat = Theme.csThreadIRMessageTextFormat;
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
				newWidth = _stripe.width;
			}
			var newHeight:Number = this.explicitHeight;
			if(needsHeight)
			{
				newHeight = _stripe.height;
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
					
					_message.text = _data.message;
					_date.text = _data.sendDate;
					
					// small - normal - large - square
					// FIXME Intégrer ça plutôt : "https://graph.facebook.com/" + _facebookId + "/picture?type=large&width=" + int(actualHeight * 0.8) + "&height=" + int(actualHeight * 0.8);
					if( !_data.incoming )
						_picture.source = MemberManager.getInstance().getFacebookId() != 0 ? ("https://graph.facebook.com/" + MemberManager.getInstance().getFacebookId() + "/picture?type=square") : _csDefaultUserTexture;
					else
						_picture.source = _csDefaultTexture;
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
			_messageBackground.y = _lineHeight;
			_messageBackground.width = this.actualWidth - scaleAndRoundToDpi(89) - _paddingMessageRight;
			_date.width = _message.width = _messageBackground.width - _paddingMessageLeft - _paddingMessageRight;
			_date.y = _paddingMessageTop;
			
			_picture.width = scaleAndRoundToDpi(86) * 0.8;
			_picture.height = _stripeHeight * 0.8;
			_picture.y = (_stripeHeight - _picture.height) * 0.5;
			
			if( !_data.incoming )
			{
				_stripe.scaleX = -1;
				_stripe.x = this.actualWidth;
				
				_messageBackground.scaleX = -1;
				_messageBackground.x = this.actualWidth - scaleAndRoundToDpi(86);
				
				_date.textRendererProperties.textAlign = TextBlockTextRenderer.TEXT_ALIGN_RIGHT;
				_date.validate();
				_date.x = _messageBackground.x - _paddingMessageLeft - _date.width;
				
				_message.textRendererProperties.textAlign = TextBlockTextRenderer.TEXT_ALIGN_RIGHT;
				_message.validate();
				_message.x = _messageBackground.x - _paddingMessageLeft - _message.width;
				
				_gradient.scaleX = -1;
				_gradient.x = this.actualWidth;
				
				_picture.x = _messageBackground.x + ((this.actualWidth - _messageBackground.x) - _picture.width) * 0.5;
			}
			else
			{
				_stripe.scaleX = 1;
				_stripe.x = 0;
				
				_messageBackground.scaleX = 1;
				_messageBackground.x = scaleAndRoundToDpi(86);
				
				_date.textRendererProperties.textAlign = TextBlockTextRenderer.TEXT_ALIGN_LEFT;
				_date.validate();
				_date.x = _messageBackground.x + _paddingMessageLeft;
				
				_message.textRendererProperties.textAlign = TextBlockTextRenderer.TEXT_ALIGN_LEFT;
				_message.validate();
				_message.x = _messageBackground.x + _paddingMessageLeft;
				
				_gradient.scaleX = 1;
				_gradient.x = 0;
				
				_picture.x = (_messageBackground.x - _picture.width) * 0.5;
			}
			
			_message.y = _date.y + _date.height;
			
			_gradient.height = Math.max((_message.y + _message.height), _minItemHeight) + _paddingMessageBottom;
			_messageBackground.height = _gradient.height - _lineHeight; // because of the y offset (_lineHeight)
			
			setSize(this.actualWidth, _gradient.height);
		}
		
		protected var _data:CSThreadData;
		
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
			this._data = CSThreadData(value);
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
		
		public function set messageBackground(val:Scale9Image):void
		{
			_messageBackground = val;
		}
		
		public function set minItemHeight(val:int):void
		{
			_minItemHeight = val;
		}
		
		public function set stripeHeight(val:int):void
		{
			_stripeHeight = val;
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
		
		private var _csDefaultTexture:Texture;
		
		public function set csDefaultTexture(val:Texture):void
		{
			_csDefaultTexture = val;
		}
		
		private var _csDefaultUserTexture:Texture;
		
		public function set csDefaultUserTexture(val:Texture):void
		{
			_csDefaultUserTexture = val;
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
//------------------------------------------------------------------------------------------------------------
		
		override public function dispose():void
		{
			_stripe.reset();
			_stripe.removeFromParent(true);
			_stripe = null;
			
			_gradient.removeFromParent(true);
			_gradient = null;
			
			_messageBackground.removeFromParent(true);
			_messageBackground = null;
			
			_picture.removeFromParent(true);
			_picture = null;
			
			_message.removeFromParent(true);
			_message = null;
			
			_date.removeFromParent(true);
			_date = null;
			
			_data = null;
			
			super.dispose();
		}
	}
}