/*
Copyright © 2006-2015 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 19 Juin 2013
*/
package com.ludofactory.mobile.core.display
{
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	
	import flash.display.GradientType;
	import flash.geom.Matrix;
	
	import feathers.core.FeathersControl;
	
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.QuadBatch;
	import starling.textures.GradientTexture;
	
	public class TiledBackground extends FeathersControl
	{
		public static const BLUE_BACKGROUND:int = 0;
		public static const WHITE_BACKGROUND:int = 1;
		private var _color:int;
		
		private var _stripeWidth:Number;
		private var _stripeStep:Number;
		
		/**
		 * Gradient background */		
		private var _gradientBackground:Image;
		
		/**
		 * Quad batch. */		
		private var _backgroundQuadBatch:QuadBatch;
		
		public function TiledBackground(color:int)
		{
			super();
			
			touchable = false;
			_color = color;
			_stripeWidth = scaleAndRoundToDpi(70);
			_stripeStep = scaleAndRoundToDpi(90);
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			_backgroundQuadBatch = new QuadBatch();
			addChild(_backgroundQuadBatch);
		}
		
		override protected function draw():void
		{
			if( this.actualWidth == 0 )
				return;
			
			super.draw();
			
			const numStripes:int = actualWidth / (_stripeWidth + (_stripeWidth - _stripeStep));
			var stripe:Quad;
			var step:int = 0;
			var i:int;
			
			if( _color == BLUE_BACKGROUND )
			{
				const matrix:Matrix = new Matrix();
				matrix.createGradientBox(this.actualWidth , this.actualHeight, Math.PI/2); // rotation here - 45°
				_gradientBackground = new Image( GradientTexture.create( this.actualWidth, this.actualHeight, GradientType.LINEAR, [0x02649b, 0x53e5ff, 0x02649b], [1, 1, 1], [0, 75, 255], matrix) );
				addChildAt(_gradientBackground, 0);
				
				stripe = new Quad(_stripeWidth, this.actualHeight, 0xffffff);
				stripe.alpha = 0.08;
				
				for(i = 0; i < numStripes; i++)
				{
					stripe.x = step;
					_backgroundQuadBatch.addQuad(stripe);
					step += _stripeStep;
				}
			}
			else
			{
				stripe = new Quad(this.actualWidth, this.actualHeight, 0xaeaeae);
				_backgroundQuadBatch.addQuad(stripe);
				
				stripe.width = _stripeWidth
				stripe.color = 0xffffff;
				stripe.alpha = 0.15;
				
				for(i = 0; i < numStripes; i++)
				{
					stripe.x = step;
					_backgroundQuadBatch.addQuad(stripe);
					step += _stripeStep;
				}
				
				stripe.x = 0;
				stripe.alpha = 1;
				stripe.width = this.actualWidth * 0.75;
				stripe.setVertexAlpha(1, 0);
				stripe.setVertexAlpha(3, 0);
				_backgroundQuadBatch.addQuad(stripe);
				
				stripe.x = this.actualWidth * 0.25;
				stripe.setVertexAlpha(1, 1);
				stripe.setVertexAlpha(3, 1);
				stripe.setVertexAlpha(0, 0);
				stripe.setVertexAlpha(2, 0);
				_backgroundQuadBatch.addQuad(stripe);
			}
			
			stripe.dispose();
			stripe = null;
			
			this.flatten();
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
//------------------------------------------------------------------------------------------------------------
		
		override public function dispose():void
		{
			/*_tiledBackground.removeFromParent(true);
			_tiledBackground = null;*/
			
			//_gradientBackground.removeFromParent(true);
			//_gradientBackground = null;
			
			//_background.removeFromParent(true);
			//_background = null;
			
			super.dispose();
		}
		
	}
}