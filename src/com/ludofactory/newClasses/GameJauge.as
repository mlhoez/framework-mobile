/**
 * Created by Maxime on 27/04/16.
 */
package com.ludofactory.newClasses
{
	
	import com.ludofactory.common.utils.Utilities;
	import com.ludofactory.common.utils.Utilities;
	import com.ludofactory.common.utils.logs.log;
	import com.ludofactory.common.utils.roundUp;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.theme.Theme;
	import com.ludofactory.newClasses.JaugeDataManager;
	
	import feathers.controls.ImageLoader;
	
	import starling.animation.Transitions;
	
	import starling.core.Starling;
	
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.text.TextField;
	import starling.text.TextFormat;
	
	public class GameJauge extends Sprite
	{
		/**
		 * Photo container. */
		private var _photoContainer:Image;
		/**
		 * the photo to display. */
		private var _photo:ImageLoader;
		/**
		 * Score container. */
		private var _scoreContainer:Image;
		/**
		 * Score label. */
		private var _scoreLabel:TextField;
		
		/**
		 * The tracked value, which is updated during the game. */
		private var _trackedValue:int = 0;
		
		/**
		 * The label displayed when the value is updated. */
		private var _addLabel:GameJaugeScoreLabel;
		
		/**
		 * Creates an in-game jauge.
		 * 
		 * @param photoSource The photo source can be an URL or a texture.
		 * @param initialValue The initial value to display in the score label.
		 */
		public function GameJauge(photoSource:Object, initialValue:int = 0)
		{
			super();
			
			_trackedValue = initialValue;
			
			_photoContainer = new Image(AbstractEntryPoint.assets.getTexture("photo-container-jauge"));
			_photoContainer.scale = GlobalConfig.dpiScale;
			addChild(_photoContainer);
			
			_photo = new ImageLoader();
			_photo.source = photoSource;
			_photo.width = _photoContainer.width * 0.9;
			_photo.height = _photoContainer.height * 0.9;
			_photo.x = _photoContainer.width * 0.05;
			_photo.y = _photoContainer.height * 0.05;
			addChild(_photo);
			
			_scoreContainer = new Image(AbstractEntryPoint.assets.getTexture("score-container-jauge"));
			_scoreContainer.scale = GlobalConfig.dpiScale;
			_scoreContainer.x = _photoContainer.width;
			_scoreContainer.y = roundUp((_photoContainer.height - _scoreContainer.height) * 0.5);
			addChild(_scoreContainer);
			
			_scoreLabel = new TextField(_scoreContainer.width, _scoreContainer.height, Utilities.splitThousands(_trackedValue), new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(30), 0xffde00));
			//_scoreLabel.border = true;
			_scoreLabel.autoScale = true;
			_scoreLabel.x = _scoreContainer.x;
			_scoreLabel.y = _scoreContainer.y;
			addChild(_scoreLabel);
			
			_addLabel = new GameJaugeScoreLabel();
			_addLabel.alignPivot();
			_addLabel.visible = false;
			_addLabel.scale = 0;
			_addLabel.x = _scoreContainer.x + _scoreContainer.width;
			_addLabel.y = _scoreContainer.y;
			addChild(_addLabel);
		}
		
//------------------------------------------------------------------------------------------------------------
//	
		
		/**
		 * Updates the score, displaying a label with the value added / substracted.
		 * 
		 * @param value
		 */
		public function updateScore(value:int):void
		{
			_trackedValue += value;
			_trackedValue = _trackedValue < 0 ? 0 : _trackedValue;
			_scoreLabel.text = Utilities.splitThousands(_trackedValue);
			
			Starling.juggler.removeTweens(_addLabel);
			_addLabel.visible = true;
			_addLabel.scale = 0;
			_addLabel.updateValue(value);
			Starling.juggler.tween(_addLabel, 0.75, { scale:1, transition:Transitions.EASE_OUT_BACK, onComplete:function():void{ _addLabel.visible = false; } });
			
		}
		
		/**
		 * Sets up the read data
		 * 
		 * @param data Array
		 */
		public function addReader(data:Array):void
		{
			_reader = new JaugeDataManager(data);
		}
		
		private var _reader:JaugeDataManager;
		
		/**
		 * When the main timer is updated, we need to update the reader and show the score variations accordingly.
		 * 
		 * @param currentTime
		 */
		public function onTimeUpdate(currentTime:int):void
		{
			//log("Update " + currentTime);
			if(_reader.currentData && _reader.currentData.timestamp == currentTime)
			{
				updateScore(_reader.currentData.score);
				_reader.getNext();
			}
		}
		
		/**
		 * Forces a value.
		 * 
		 * @param value
		 */
		public function setScore(value:int):void
		{
			_scoreLabel.text = Utilities.splitThousands(value);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
		
		override public function dispose():void
		{
			_photoContainer.removeFromParent(true);
			_photoContainer = null;
			
			_photo.removeFromParent(true);
			_photo = null;
			
			_scoreContainer.removeFromParent(true);
			_scoreContainer = null;
			
			_scoreLabel.removeFromParent(true);
			_scoreLabel = null;
			
			Starling.juggler.removeTweens(_addLabel);
			_addLabel.removeFromParent(true);
			_addLabel = null;
			
			_trackedValue = NaN;
			
			super.dispose();
		}
	}
}