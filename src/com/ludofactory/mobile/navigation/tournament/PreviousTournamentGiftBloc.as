/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 25 nov. 2013
*/
package com.ludofactory.mobile.navigation.tournament
{
	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.AbstractGameInfo;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import feathers.controls.ImageLoader;
	import feathers.controls.Label;
	import feathers.core.FeathersControl;
	
	import starling.display.Image;
	import starling.display.Quad;
	import starling.utils.deg2rad;
	import starling.utils.formatString;
	
	public class PreviousTournamentGiftBloc extends FeathersControl
	{
		/**
		 * Stroke thickness. */		
		private var _strokeThickness:Number;
		
		/**
		 * Background stroke */		
		private var _stroke:Quad;
		/**
		 * Background gradient */		
		private var _gradient:Quad;
		
		/**
		 * Highlight ad */		
		protected var _highlightAd:ImageLoader;
		
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
			if( AbstractGameInfo.LANDSCAPE )
				width = scaleAndRoundToDpi(350);
			else
				height = scaleAndRoundToDpi(200);
			
			_stroke = new Quad(5, 5, 0xffffff);
			addChild(_stroke);
			
			_gradient = new Quad(5, 5, 0x0000ff);
			_gradient.setVertexColor(0, 0x43dfff);
			_gradient.setVertexColor(1, 0x43dfff);
			_gradient.setVertexColor(2, 0x02bbff);
			_gradient.setVertexColor(3, 0x02bbff);
			addChild(_gradient);
			
			_highlightAd = new ImageLoader();
			_highlightAd.source = AbstractEntryPoint.assets.getTexture("highlight-ad");
			_highlightAd.maintainAspectRatio = false;
			//_highlightAd.scaleX = _highlightAd.scaleY = GlobalConfig.dpiScale;
			//_highlightAd.textureScale = GlobalConfig.dpiScale;
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
			
			if( isInvalid(INVALIDATION_FLAG_SIZE ) )
			{
				_stroke.width = actualWidth;
				_stroke.height = actualHeight;
				
				_gradient.width = actualWidth - (_strokeThickness * 2);
				_gradient.height = actualHeight - (_strokeThickness * 2);
				_gradient.y = _strokeThickness;
				_gradient.x = _strokeThickness;
				
				if( AbstractGameInfo.LANDSCAPE )
				{
					_highlightAd.width = actualHeight;
					_highlightAd.height = actualWidth;
					_highlightAd.x = actualWidth;
					_highlightAd.rotation = deg2rad(90);
					
					_icon.x = (actualWidth - _icon.width) * 0.5;
					_icon.y = scaleAndRoundToDpi(GlobalConfig.isPhone ? 40 : 80);
					
					_title.width = actualWidth;
					_title.validate();
					_title.y = _icon.y + _icon.height + ((actualHeight - _icon.height - _icon.y) - _title.height) * 0.5;
				}
				else
				{
					_icon.x = scaleAndRoundToDpi(GlobalConfig.isPhone ? 10 : 80);
					_icon.y = (actualHeight - _icon.height) * 0.5;
					
					_title.width = actualWidth - _icon.x - _icon.width - scaleAndRoundToDpi(20);
					_title.validate();
					_title.x = _icon.x + _icon.width + scaleAndRoundToDpi(10);
					_title.y = (actualHeight - _title.height) * 0.5;
					
					_highlightAd.width = actualWidth;
					_highlightAd.height = actualHeight;
					_highlightAd.x = _strokeThickness;
					_highlightAd.y = _strokeThickness;
				}
				
				
			}
			
		}
		
		public function set title(val:String):void
		{
			_title.text = formatString(_("Votre gain sur ce tournoi :\n{0}"), val);
			invalidate( INVALIDATION_FLAG_SIZE );
		}
	}
}