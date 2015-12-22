/**
 * Created by Maxime on 29/09/15.
 */
package com.ludofactory.mobile.core.avatar.maker
{
	
	import com.ludofactory.desktop.ServerEventType;
	import com.ludofactory.desktop.tools.log;
	import com.ludofactory.desktop.tools.splitThousands;
	import com.ludofactory.server.data.ServerData;
	import com.ludofactory.server.starling.theme.Theme;
	
	import feathers.core.FeathersControl;
	import feathers.display.Scale3Image;
	
	import starling.display.Image;
	import starling.events.Event;
	
	import starling.text.TextField;
	import starling.text.TextFieldAutoSize;
	
	public class PointsCounter extends FeathersControl
	{
		/**
		 * Counter background. */
		private var _background:Scale3Image;
		/**
		 * Counter label. */
		private var _counterLabel:TextField;
		/**
		 * Points icon. */
		private var _pointsIcon:Image;
		
		public function PointsCounter()
		{
			super();
			
			this.height = 38;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			_background = new Scale3Image(Theme.counterPointsBackground);
			addChild(_background);
			
			_counterLabel = new TextField(5, this.height, splitThousands(ServerData.totalPoints.value), Theme.FONT_OSWALD, 20, 0xffffff);
			_counterLabel.autoSize = TextFieldAutoSize.HORIZONTAL;
			addChild(_counterLabel);
			
			_pointsIcon = new Image(Theme.cartPointBigIconTexture);
			addChild(_pointsIcon);
			
			ServerData.totalPoints.addEventListener(ServerEventType.SECURE_PROPERTY_UPDATED, onCountUpdated);
		}
		
		override protected function draw():void
		{
			super.draw();
			
			if(isInvalid(INVALIDATION_FLAG_SIZE))
			{
				_background.width = actualWidth;
				_background.height = actualHeight;
				
				_counterLabel.x = 20 + (_background.width - _counterLabel.width - 45 - _pointsIcon.width) * 0.5;
				
				_pointsIcon.x = _counterLabel.x + _counterLabel.width + 5;
				_pointsIcon.y = _counterLabel.y + (_counterLabel.height - _pointsIcon.height) * 0.5;
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Handlers
		
		private function onCountUpdated(event:Event):void
		{
			_counterLabel.text = splitThousands(ServerData.totalPoints.value);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Get
		
		/**
		 * The width returned is always 0 I don't know why, so this is a hack to be able to center
		 * this componenet correctly in the AvatarMakerScreen.
		 */
		public function get backgroundWidth():int
		{
			return _background.width;
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
		
		override public function dispose():void
		{
			ServerData.totalPoints.removeEventListener(ServerEventType.SECURE_PROPERTY_UPDATED, onCountUpdated);
			
			_background.removeFromParent(true);
			_background = null;
			
			_counterLabel.removeFromParent(true);
			_counterLabel = null;
			
			_pointsIcon.removeFromParent(true);
			_pointsIcon = null;
			
			super.dispose();
		}
		
	}
}