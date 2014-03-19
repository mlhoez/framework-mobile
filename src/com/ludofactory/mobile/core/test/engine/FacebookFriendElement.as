/*
LudoFactory
Framework mobile
Author  : Maxime Lhoez
Created : 12 nov. 2013
*/
package com.ludofactory.mobile.core.test.engine
{
	import com.ludofactory.common.utils.Utility;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.test.config.GlobalConfig;
	import com.ludofactory.mobile.core.theme.Theme;
	import com.ludofactory.mobile.core.authentication.MemberManager;
	
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import feathers.controls.ImageLoader;
	import feathers.controls.Label;
	import feathers.core.FeathersControl;
	import feathers.display.Scale9Image;
	
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.MovieClip;
	
	public class FacebookFriendElement extends FeathersControl
	{
		/**
		 * The container's background. */		
		private var _background:Scale9Image;
		
		/**
		 * The rank flag. */		
		private var _flag:Image;
		
		/**
		 * The score label. */		
		private var _scoreLabel:Label;
		
		/**
		 * The loader */		
		private var _loader:MovieClip;
		
		/**
		 * The name label. */		
		private var _nameLabel:Label;
		
		/**
		 * The user's picture. */		
		private var _picture:ImageLoader;
		
		/**
		 * The rank value. */		
		private var _rankLabel:Label;
		
		/**
		 * The current rank. */		
		private var _currentRank:int;
		/**
		 * The previous rank. */		
		private var _previousRank:int;
		/**
		 * The Facebook id. */		
		private var _facebookId:String;
		/**
		 * The current score. */		
		private var _currentScore:int;
		/**
		 * The previous score. */		
		private var _previousScore:int
		/**
		 * The name. */		
		private var _name:String;
		/**
		 * Whether the data belongs to the current user. */		
		private var _isMe:Boolean;
		
		private var _arrayPosition:int;
		
		public function FacebookFriendElement(data:Object, arrayPosition:int)
		{
			super();
			
			_currentRank = int(data.classement);
			_previousRank = int(data.last_classement);
			_facebookId = String(data.id_facebook);
			_currentScore = int(data.score);
			_previousScore = int(data.last_score);
			_name = data.nom;
			_isMe = MemberManager.getInstance().getId() == int(data.id) ? true : false;
			_arrayPosition = arrayPosition;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			addChild(_background);
			
			_scoreLabel = new Label();
			_scoreLabel.text = Utility.splitThousands( Number(_previousScore) );
			addChild(_scoreLabel);
			_scoreLabel.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(40), Theme.COLOR_ORANGE, false, false, null, null, null, TextFormatAlign.RIGHT);
			_scoreLabel.textRendererProperties.wordWrap = false;
			
			_nameLabel = new Label();
			_nameLabel.text = _name;
			addChild(_nameLabel);
			_nameLabel.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(26), Theme.COLOR_LIGHT_GREY);
			_nameLabel.textRendererProperties.wordWrap = false;
			
			_loader = new MovieClip(AbstractEntryPoint.assets.getTextures("MiniLoader"));
			_loader.scaleX = _loader.scaleY = GlobalConfig.dpiScale;
			Starling.juggler.add( _loader );
			addChild(_loader);
			
			_picture = new ImageLoader();
			_picture.snapToPixels = true;
			addChild(_picture);
			
			_flag = new Image( AbstractEntryPoint.assets.getTexture("facebook-friend-rank-flag") );
			_flag.scaleX = _flag.scaleY = GlobalConfig.dpiScale;
			addChild(_flag);
			
			_rankLabel = new Label();
			_rankLabel.text = String(_previousRank);
			addChild(_rankLabel);
			_rankLabel.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(32), Theme.COLOR_WHITE, false, false, null, null, null, TextFormatAlign.CENTER);
			_rankLabel.textRendererProperties.wordWrap = false;
		}
		
		override protected function draw():void
		{
			super.draw();
			
			_background.width = actualWidth;
			_background.height = actualHeight;
			
			_picture.source = "https://graph.facebook.com/" + _facebookId + "/picture?type=large&width=" + int(actualHeight * 0.8) + "&height=" + int(actualHeight * 0.8);
			_picture.x = scaleAndRoundToDpi(20);
			_picture.height = _picture.width = actualHeight * 0.8;
			_picture.y = actualHeight * 0.1;
			
			_loader.x = _picture.x + (_picture.width * 0.5) - (_loader.width * 0.5);
			_loader.y = _picture.y + (_picture.height * 0.5) - (_loader.height * 0.5);
			
			_scoreLabel.validate();
			_scoreLabel.x = actualWidth - _scoreLabel.width - scaleAndRoundToDpi(20);
			_scoreLabel.y = scaleAndRoundToDpi(20);
			
			_nameLabel.validate();
			_nameLabel.x = _picture.x + _picture.width + scaleAndRoundToDpi(10);
			_nameLabel.y = actualHeight - _nameLabel.height - scaleAndRoundToDpi(20);
			
			_rankLabel.width = _flag.width;
		}
		
//------------------------------------------------------------------------------------------------------------
//	Get / Set
//------------------------------------------------------------------------------------------------------------
		
		public function set background(val:Scale9Image):void
		{
			_background = val;
		}
		
		public function setScoreAndRankValue():void
		{
			_scoreLabel.text = String(_currentScore);
			_scoreLabel.validate();
			_scoreLabel.x = actualWidth - _scoreLabel.width - scaleAndRoundToDpi(20);
			
			_rankLabel.text = String(_currentRank);
			_rankLabel.validate();
		}
		
		public function get arrayPosition():int
		{
			return _arrayPosition;
		}
		
		public function get isMe():Boolean
		{
			return _isMe;
		}
		
		public function get friendName():String
		{
			return _name;
		}
		
		public function get currentScore():int
		{
			return _currentScore;
		}
		
		public function getUpValue():String
		{
			return (_previousRank - _currentRank) < 0 ? ("" + (_previousRank - _currentRank)) : ("+" + (_previousRank - _currentRank));
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
//------------------------------------------------------------------------------------------------------------
		
		override public function dispose():void
		{
			_background.removeFromParent(true);
			_background = null;
			
			Starling.juggler.remove( _loader );
			_loader.removeFromParent(true);
			_loader = null;
			
			_picture.source = null;
			_picture.removeFromParent(true);
			_picture = null;
			
			super.dispose();
		}
	}
}