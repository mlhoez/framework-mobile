/**
 * Created by Maxime on 21/04/2016.
 */
package com.ludofactory.newClasses
{
	
	import com.greensock.TweenMax;
	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.common.utils.Utilities;
	import com.ludofactory.common.utils.roundUp;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.controls.AdvancedScreen;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import starling.display.BlendMode;
	
	import starling.display.Image;
	import starling.display.Quad;
	import starling.filters.BlurFilter;
	import starling.text.TextField;
	import starling.text.TextFieldAutoSize;
	import starling.text.TextFormat;
	
	public class GameChoiceScreen extends AdvancedScreen
	{
		/**
		 * Background. */
		private var _background:Image;
		/**
		 * Thunder stripes. */
		private var _thunderStripes:Image;
		
		/**
		 * Solo blue color overlay. */
		private var _soloColorOverlay:Quad;
		/**
		 * Solo text. */
		private var _soloTitle:TextField;
		/**
		 * Duel description. */
		private var _soloDescription:TextField;
		
		/**
		 * Solo blue color overlay. */
		private var _duelColorOverlay:Quad;
		/**
		 * Duel text. */
		private var _duelTitle:TextField;
		/**
		 * Duel description. */
		private var _duelDescription:TextField;
		
		public function GameChoiceScreen()
		{
			super();
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			_background = new Image(AbstractEntryPoint.assets.getTexture("dark-background"));
			_background.filter = new BlurFilter(1, 1);
			_background.touchable = false;
			addChild(_background);
			
			_soloColorOverlay = new Quad(5, 5, 0x00b2c2);
			_soloColorOverlay.blendMode = BlendMode.MULTIPLY;
			addChild(_soloColorOverlay);
			
			_duelColorOverlay = new Quad(5, 5, 0x31bc00);
			_duelColorOverlay.blendMode = BlendMode.MULTIPLY;
			addChild(_duelColorOverlay);
			
			_thunderStripes = new Image(AbstractEntryPoint.assets.getTexture("thunder-stripes"));
			_thunderStripes.scale = GlobalConfig.dpiScale;
			addChild(_thunderStripes);
			
			_soloTitle = new TextField(5, scaleAndRoundToDpi(100), _("Solo"), new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(60), 0xffffff));
			_soloTitle.touchable = false;
			_soloTitle.autoScale = true;
			_soloTitle.border = true;
			addChild(_soloTitle);
			
			_soloDescription = new TextField(5, 5, _("Entrainez-vous et dépassez votre meilleur score !"), new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(20), 0xffffff));
			_soloDescription.touchable = false;
			_soloDescription.autoSize = TextFieldAutoSize.VERTICAL;
			_soloDescription.border = true;
			addChild(_soloDescription);
			
			_duelTitle = new TextField(5, scaleAndRoundToDpi(100), _("Duel"), new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(60), 0xffffff));
			_duelTitle.touchable = false;
			_duelTitle.autoScale = true;
			_duelTitle.border = true;
			addChild(_duelTitle);
			
			_duelDescription = new TextField(5, 5, _("Effectuez des duels mondiaux et devenez le meilleur !"), new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(20), 0xffffff));
			_duelDescription.touchable = false;
			_duelDescription.autoSize = TextFieldAutoSize.VERTICAL;
			_duelDescription.border = true;
			addChild(_duelDescription);
		}
		
		override protected function draw():void
		{
			super.draw();
			
			if(isInvalid(INVALIDATION_FLAG_SIZE))
			{
				_background.scale = Utilities.getScaleToFill(_background.width, _background.height, actualWidth, actualHeight);
				_background.x = roundUp((actualWidth - _background.width) * 0.5);
				_background.y = roundUp((actualHeight - _background.height) * 0.5);
				
				_soloColorOverlay.width = _duelColorOverlay.width = _duelColorOverlay.x = actualWidth * 0.5;
				_soloColorOverlay.height = _duelColorOverlay.height = actualHeight;
				
				_thunderStripes.height = actualHeight;
				_thunderStripes.x = roundUp((actualWidth - _thunderStripes.width) * 0.5);
				_thunderStripes.y = roundUp((actualHeight - _thunderStripes.height) * 0.5);
				
				_soloTitle.width = _soloDescription.width = actualWidth * 0.5;
				_soloTitle.y = roundUp((actualHeight - _soloTitle.height - _soloDescription.height) * 0.5);
				_soloDescription.y = roundUp(_soloTitle.y + _soloTitle.height);
				
				_duelTitle.x = _duelDescription.x = actualWidth * 0.5;
				_duelTitle.width = _duelDescription.width = actualWidth * 0.5;
				_duelTitle.y = roundUp((actualHeight - _duelTitle.height - _duelDescription.height) * 0.5);
				_duelDescription.y = roundUp(_duelTitle.y + _duelTitle.height);
				
				TweenMax.to(_background, 0.5, { delay:0.0, alpha:0.75 });
				TweenMax.to(_background.filter, 0.5, { delay:0.0, blurX:20, blurY:20 });
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	
		
		override public function dispose():void
		{
			_background.filter.dispose();
			_background.filter = null;
			_background.removeFromParent(true);
			_background = null;
			
			_soloTitle.removeFromParent(true);
			_soloTitle = null;
			
			_duelTitle.removeFromParent(true);
			_duelTitle = null;
			
			super.dispose();
		}
		
	}
}