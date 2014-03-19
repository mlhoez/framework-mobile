/*
LudoFactory
Framework mobile
Author  : Maxime Lhoez
Created : 30 août 2013
*/
package com.ludofactory.mobile.core.test.cs.thread
{
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.test.config.GlobalConfig;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import flash.text.TextFormat;
	
	import feathers.controls.Label;
	import feathers.core.FeathersControl;
	
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.QuadBatch;
	
	/**
	 * Alert displayed at the top of the CSThreadScreen when a message have
	 * been sent or if not.
	 * 
	 * <p>This class is initialized with a message and a boolean indicating
	 * if this is a success or a failure message (the color of the background
	 * and the icon will change in this case).</p>
	 */	
	public class CSThreadAlert extends FeathersControl
	{
		private static const BASE_HEIGHT:int = 120;
		private var _minimumHeight:Number;
		
		private static const COLOR_FAILURE_STROKE:uint = 0xff3000;
		private static const COLOR_FAILURE_SHADOW:uint = 0xd61800;
		private static const COLOR_FAILURE:uint = 0xff1e00;
		
		private static const COLOR_SUCCESS_STROKE:uint = 0xb0dc00;
		private static const COLOR_SUCCESS_SHADOW:uint = 0x89b100;
		private static const COLOR_SUCCESS:uint = 0x96bb00;
		
		/**
		 * The background. */		
		private var _background:QuadBatch;
		
		/**
		 * The message to display. */		
		private var _message:String;
		
		/**
		 * The message label. */		
		private var _messageLabel:Label;
		
		/**
		 * The cross icon. */		
		private var _icon:Image;
		
		/**
		 * Determines the color and icon of the alert. */		
		private var _success:Boolean;
		
		public function CSThreadAlert(message:String, success:Boolean)
		{
			super();
			
			_message = message;
			_success = success;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			_minimumHeight = scaleAndRoundToDpi(BASE_HEIGHT);
			
			_icon = new Image( AbstractEntryPoint.assets.getTexture( _success ? "Check":"Cross" ) );
			_icon.scaleX = _icon.scaleY = GlobalConfig.dpiScale;
			addChild(_icon);
			
			_messageLabel = new Label();
			_messageLabel.text = _message;
			addChild(_messageLabel);
			_messageLabel.textRendererProperties.textFormat = new TextFormat(Theme.FONT_ARIAL, scaleAndRoundToDpi(25), Theme.COLOR_WHITE, true);
		}
		
		/**
		 * If the component's dimensions have not been set explicitly, it will
		 * measure its content and determine an ideal size for itself. If the
		 * <code>explicitWidth</code> or <code>explicitHeight</code> member
		 * variables are set, those value will be used without additional
		 * measurement. If one is set, but not the other, the dimension with the
		 * explicit value will not be measured, but the other non-explicit
		 * dimension will still need measurement.
		 *
		 * <p>Calls <code>setSizeInternal()</code> to set up the
		 * <code>actualWidth</code> and <code>actualHeight</code> member
		 * variables used for layout.</p>
		 *
		 * <p>Meant for internal use, and subclasses may override this function
		 * with a custom implementation.</p>
		 */
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
				newWidth = this.actualWidth;
			}
			
			var newHeight:Number = this.explicitHeight;
			if(needsHeight)
			{
				if(_messageLabel)
				{
					_messageLabel.x = scaleAndRoundToDpi(40) + _icon.width; // 20 (icon padding left + 20 (icon padding right)
					_messageLabel.width = this.actualWidth - _messageLabel.x - scaleAndRoundToDpi(20);
					_messageLabel.validate();
					newHeight = _messageLabel.height;
				}
				else
				{
					newHeight = 0;
				}
				newHeight += scaleAndRoundToDpi(20); // 10 padding top and bottom
				newHeight = newHeight < _minimumHeight ? _minimumHeight : newHeight;
			}
			
			return this.setSizeInternal(newWidth, newHeight, false);
		}
		
		override protected function draw():void
		{
			super.draw();
			
			var sizeInvalid:Boolean = this.autoSizeIfNeeded() || sizeInvalid;
			
			if (sizeInvalid )
			{
				this.layout();
			}
		}
		
		private function layout():void
		{
			_messageLabel.y = (this.actualHeight - _messageLabel.height) * 0.5;
			
			createBackground();
			_background.width = this.actualWidth;
			
			_icon.x = scaleAndRoundToDpi(20);
			_icon.y = (this.actualHeight - _icon.height) * 0.5;
		}
		
		private function createBackground():void
		{
			_background = new QuadBatch();
			addChildAt(_background, 0);
			
			var quad:Quad = new Quad(this.actualWidth, this.actualHeight - scaleAndRoundToDpi(12), _success ? COLOR_SUCCESS_STROKE:COLOR_FAILURE_STROKE);
			_background.addQuad(quad);
			
			quad.width = this.actualWidth - scaleAndRoundToDpi(4);
			quad.height = this.actualHeight - scaleAndRoundToDpi(4) - scaleAndRoundToDpi(12);
			quad.x = scaleAndRoundToDpi(2);
			quad.y = scaleAndRoundToDpi(2);
			quad.color = _success ? COLOR_SUCCESS:COLOR_FAILURE;
			_background.addQuad(quad);
			
			quad.color = _success ? COLOR_SUCCESS_SHADOW:COLOR_FAILURE_SHADOW;
			quad.width = scaleAndRoundToDpi(5);
			quad.setVertexAlpha(0, 1);
			quad.setVertexAlpha(1, 0);
			quad.setVertexAlpha(2, 1);
			quad.setVertexAlpha(3, 0);
			_background.addQuad(quad);
			
			quad.x = this.actualWidth - scaleAndRoundToDpi(2) - quad.width;
			quad.setVertexAlpha(0, 0);
			quad.setVertexAlpha(1, 1);
			quad.setVertexAlpha(2, 0);
			quad.setVertexAlpha(3, 1);
			_background.addQuad(quad);
			
			quad.x = scaleAndRoundToDpi(2);
			quad.width = this.actualWidth - scaleAndRoundToDpi(4);
			quad.height = scaleAndRoundToDpi(5);
			quad.y = scaleAndRoundToDpi(2);
			quad.setVertexAlpha(0, 1);
			quad.setVertexAlpha(1, 1);
			quad.setVertexAlpha(2, 0);
			quad.setVertexAlpha(3, 0);
			_background.addQuad(quad);
			
			quad.y = this.actualHeight - scaleAndRoundToDpi(2) - quad.height - scaleAndRoundToDpi(12);
			quad.setVertexAlpha(0, 0);
			quad.setVertexAlpha(1, 0);
			quad.setVertexAlpha(2, 1);
			quad.setVertexAlpha(3, 1);
			_background.addQuad(quad);
			
			quad.y = this.actualHeight - scaleAndRoundToDpi(12);
			quad.color = 0x000000;
			quad.setVertexAlpha(0, 0.2);
			quad.setVertexAlpha(1, 0.2);
			quad.setVertexColor(2, 0xffffff);
			quad.setVertexAlpha(2, 0);
			quad.setVertexColor(3, 0xffffff);
			quad.setVertexAlpha(3, 0);
			_background.addQuad(quad);
			
			quad.dispose();
			quad = null;
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
//------------------------------------------------------------------------------------------------------------
		
		override public function dispose():void
		{
			if( _background )
			{
				_background.reset();
				_background.removeFromParent(true);
				_background = null;
			}
			
			if( _icon )
			{
				_icon.removeFromParent(true);
				_icon = null;
			}
			
			if( _messageLabel)
			{
				_messageLabel.removeFromParent(true);
				_messageLabel = null;
			}
			
			super.dispose();
		}
	}
}