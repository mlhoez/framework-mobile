/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 9 sept. 2013
*/
package com.ludofactory.mobile.navigation.highscore
{
	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import feathers.controls.Label;
	import feathers.core.FeathersControl;
	
	import starling.display.Quad;
	import starling.display.QuadBatch;
	
	/**
	 * Header used at the top of the highscore list.
	 */	
	public class HighScoreListHeader extends FeathersControl
	{
		/**
		 * The base height of a line in the list. */		
		private static const BASE_HEIGHT:int = 60;
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
		 * The header quad batch. */		
		private var _header:QuadBatch;
		/**
		 * The rank label. */		
		private var _rankLabel:Label;
		/**
		 * The name label. */		
		private var _nameLabel:Label;
		/**
		 * The stars label. */		
		private var _scoreLabel:Label;
		
		public function HighScoreListHeader()
		{
			super();
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			_itemHeight = scaleAndRoundToDpi( BASE_HEIGHT * (GlobalConfig.isPhone ? 1:1.25) );
			_strokeThickness = scaleAndRoundToDpi(BASE_STROKE_THICKNESS);
			
			_header = new QuadBatch();
			addChild(_header);
			
			_rankLabel = new Label();
			_rankLabel.text = _("Rang");
			addChild(_rankLabel);
			_rankLabel.textRendererProperties.textFormat = Theme.highScoreListHeaderTextFormat;
			
			_nameLabel = new Label();
			_nameLabel.text = _("Nom");
			addChild(_nameLabel);
			_nameLabel.textRendererProperties.textFormat = Theme.highScoreListHeaderTextFormat;
			
			_scoreLabel = new Label();
			_scoreLabel.text = _("Score");
			addChild(_scoreLabel);
			_scoreLabel.textRendererProperties.textFormat = Theme.highScoreListHeaderTextFormat;
		}
		
		override protected function draw():void
		{
			super.draw();
			
			if( isInvalid( INVALIDATION_FLAG_SIZE ) )
			{
				var quad:Quad = new Quad(this.actualWidth, _itemHeight, 0xfbfbfb);
				_header.addQuad( quad );
				
				quad.x = this.actualWidth * 0.25;
				quad.width = this.actualWidth * 0.5;
				quad.color = 0xeeeeee;
				_header.addQuad( quad );
				
				quad.x = 0;
				quad.y = _itemHeight - _strokeThickness;
				quad.width  = this.actualWidth;
				quad.height = _strokeThickness;
				quad.color  = 0xbfbfbf;
				_header.addQuad( quad );
				
				_rankLabel.width = _scoreLabel.width = this.actualWidth * 0.25;
				_nameLabel.width = this.actualWidth * 0.5;
				_rankLabel.validate();
				_rankLabel.y = _nameLabel.y = _scoreLabel.y = (this.actualHeight - _rankLabel.height) * 0.5;
				_nameLabel.x = this.actualWidth * 0.25;
				_scoreLabel.x = this.actualWidth * 0.75;
				
				setSizeInternal(actualWidth, _itemHeight, true);
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
//------------------------------------------------------------------------------------------------------------
		
		override public function dispose():void
		{
			_header.reset();
			_header.removeFromParent(true);
			_header = null;
			
			_rankLabel.removeFromParent(true);
			_rankLabel = null;
			
			_nameLabel.removeFromParent(true);
			_nameLabel = null;
			
			_scoreLabel.removeFromParent(true);
			_scoreLabel = null;
			
			super.dispose();
		}
		
	}
}