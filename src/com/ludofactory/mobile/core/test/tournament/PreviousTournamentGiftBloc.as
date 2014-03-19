/*
LudoFactory
Framework mobile
Author  : Maxime Lhoez
Created : 25 nov. 2013
*/
package com.ludofactory.mobile.core.test.tournament
{
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.Localizer;
	import com.ludofactory.mobile.core.test.config.GlobalConfig;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import feathers.controls.Label;
	import feathers.core.FeathersControl;
	
	import starling.display.Image;
	import starling.display.Quad;
	import starling.utils.formatString;
	
	public class PreviousTournamentGiftBloc extends FeathersControl
	{
		/**
		 * Stroke thickness. */		
		private var _strokeThickness:Number;
		/**
		 * Item height. */		
		private var _itemHeight:Number;
		
		/**
		 * Background stroke */		
		private var _stroke:Quad;
		/**
		 * Background gradient */		
		private var _gradient:Quad;
		
		/**
		 * Highlight ad */		
		protected var _highlightAd:Image;
		
		/**
		 * Icon. */		
		protected var _icon:Image;
		
		/**
		 * The gift won. */		
		private var _title:Label;
		
		public function PreviousTournamentGiftBloc()
		{
			super();
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			_strokeThickness = scaleAndRoundToDpi(3);
			this.height = _itemHeight = scaleAndRoundToDpi(200)
			
			_stroke = new Quad(5, _itemHeight, 0xffffff);
			addChild(_stroke);
			
			_gradient = new Quad(5, _itemHeight - (_strokeThickness * 2), 0x0000ff);
			_gradient.setVertexColor(0, 0x43dfff);
			_gradient.setVertexColor(1, 0x43dfff);
			_gradient.setVertexColor(2, 0x02bbff);
			_gradient.setVertexColor(3, 0x02bbff);
			addChild(_gradient);
			
			_highlightAd = new Image(AbstractEntryPoint.assets.getTexture("highlight-ad"));
			_highlightAd.scaleX = _highlightAd.scaleY = GlobalConfig.dpiScale;
			addChild(_highlightAd);
			
			_icon = new Image( AbstractEntryPoint.assets.getTexture("previous-tournament-win-icon") );
			_icon.scaleX = _icon.scaleY = GlobalConfig.dpiScale;
			addChild(_icon);
			
			_title = new Label();
			_title.text = "";
			addChild(_title);
			_title.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(32), Theme.COLOR_WHITE, false, false, null, null, null, TextFormatAlign.CENTER);
		}
		
		override protected function draw():void
		{
			super.draw();
			
			_stroke.width = this.actualWidth;
			_gradient.width = this.actualWidth - (_strokeThickness * 2);
			_gradient.y = _strokeThickness;
			_gradient.x = _strokeThickness;
			
			_highlightAd.width = this.actualWidth;
			_highlightAd.x = _strokeThickness;
			_highlightAd.y = _strokeThickness;
			
			_icon.x = scaleAndRoundToDpi(GlobalConfig.isPhone ? 10 : 80);
			_icon.y = (actualHeight - _icon.height) * 0.5;
			
			_title.width = actualWidth - _icon.x - _icon.width - scaleAndRoundToDpi(20);
			_title.validate();
			_title.x = _icon.x + _icon.width + scaleAndRoundToDpi(10);
			_title.y = (actualHeight - _title.height) * 0.5;
		}
		
		public function set title(val:String):void
		{
			_title.text = formatString(Localizer.getInstance().translate("PREVIOUS_TOURNAMENTS.GIFT_ON_TOURNAMENT_LABEL"), val);
			invalidate( INVALIDATION_FLAG_SIZE );
		}
	}
}