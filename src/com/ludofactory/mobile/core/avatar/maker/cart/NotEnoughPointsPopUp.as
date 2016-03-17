/*
 Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
 Framework mobile
 Author  : Maxime Lhoez
 Created : 17 Avril 2015
*/
package com.ludofactory.mobile.core.avatar.maker.cart
{
	
	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.common.utils.roundUp;
    import com.ludofactory.common.utils.scaleAndRoundToDpi;
    import com.ludofactory.mobile.ButtonFactory;
	import com.ludofactory.mobile.MobileButton;
	import com.ludofactory.mobile.core.avatar.AvatarMakerAssets;
	import com.ludofactory.mobile.core.avatar.test.events.LKAvatarMakerEventTypes;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.config.GlobalConfig;
    import com.ludofactory.mobile.core.theme.Theme;
	
	import starling.display.Button;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.text.TextField;
	import starling.utils.HAlign;
	import starling.utils.VAlign;
	
	public class NotEnoughPointsPopUp extends Sprite
	{
        /**
         * The popup background. */
        private var _background:Image;

        /**
         * The popup title. */
        private var _titleLabel:TextField;
		/**
		 * The popup description. */
        private var _descriptionLabel:TextField;
		/**
		 * The tool tip label. */
        private var _toolTipLabel:TextField;
        
        /**
         * The close button. */
        private var _closeButton:Button;
        /**
         * The validation button. */
        private var _validateButton:MobileButton;
        
        public function NotEnoughPointsPopUp()
        {
            super();

            _background = new Image(AvatarMakerAssets.notEnoughPointsPopupBackgroundTexture);
            _background.scaleX = _background.scaleY = GlobalConfig.dpiScale;
            addChild(_background);

            _titleLabel = new TextField(_background.width, scaleAndRoundToDpi(50), _("VOUS N'AVEZ PAS ASSEZ DE POINTS"), Theme.FONT_OSWALD, 40, 0xffffff);
	        _titleLabel.y = scaleAndRoundToDpi(16);
            _titleLabel.autoScale = true;
            _titleLabel.batchable = true;
            addChild(_titleLabel);

            //_descriptionLabel = new TextField(_background.width - 40, 40, "Comment obtenir plus de <b>Points</b> pour acheter des <b>trucs cool</b> pour mon avatar ?", Theme.FONT_OSWALD, 18, 0x838383);
            _descriptionLabel = new TextField(_background.width - scaleAndRoundToDpi(40), scaleAndRoundToDpi(100), _("Il vous manque encore quelques Points à récolter mon Capitaine !"), Theme.FONT_OSWALD, scaleAndRoundToDpi(26), 0x838383);
            _descriptionLabel.touchable = false;
            _descriptionLabel.isHtmlText = true;
            _descriptionLabel.autoScale = true;
            _descriptionLabel.batchable = true;
            //_descriptionLabel.border = true;
            _descriptionLabel.hAlign = HAlign.CENTER;
            _descriptionLabel.y = scaleAndRoundToDpi(75);
            _descriptionLabel.x = scaleAndRoundToDpi(20);
            addChild(_descriptionLabel);
            
            //_toolTipLabel = new TextField(310, 180, "<textformat leading='-4'>Que vous gagnez ou perdez,<br />vous <font size='20'><b>gagnez des Points</b><br /></font></textformat><font size='20'><b>à chaque partie</b></font> jouée !<font size='10'><br /><br /></font><textformat leading='-4'><p align='right' ><font size='15'>Il y a un tas d'objets que vous pourriez acheter<br />avec tous ces <b>Points</b>, pensez-y !</font></p></textformat>", Theme.FONT_OSWALD , 18 , 0x838383);
            _toolTipLabel = new TextField(scaleAndRoundToDpi(570), scaleAndRoundToDpi(160), _("Retirez des objets ou continuez à vous amuser sur l'application et ces objets seront à vous !"), Theme.FONT_OSWALD, scaleAndRoundToDpi(26), 0x838383);
            _toolTipLabel.touchable = false;
            _toolTipLabel.batchable = true;
            _toolTipLabel.isHtmlText = true;
            _toolTipLabel.autoScale = true;
            //_toolTipLabel.border = true;
            _toolTipLabel.hAlign = HAlign.LEFT;
            _toolTipLabel.vAlign = VAlign.CENTER;
            _toolTipLabel.x = scaleAndRoundToDpi(278);
            _toolTipLabel.y = scaleAndRoundToDpi(200);
            addChild(_toolTipLabel);
	
	        _closeButton = new Button(AvatarMakerAssets.closeButton);
	        _closeButton.addEventListener(Event.TRIGGERED, onClose);
	        _closeButton.x = _background.width - _closeButton.width - scaleAndRoundToDpi(16);
	        _closeButton.y = scaleAndRoundToDpi(34);
	        _closeButton.scaleWhenDown = GlobalConfig.dpiScale - (0.1 * GlobalConfig.dpiScale);
	        addChild(_closeButton);
	
	        _validateButton = ButtonFactory.getButton(_("Continuer"), ButtonFactory.GREEN);
	        _validateButton.addEventListener(Event.TRIGGERED, onClose);
	        _validateButton.x = roundUp((_background.width - _validateButton.width) * 0.72);
	        _validateButton.y = roundUp(_background.height - _validateButton.height - scaleAndRoundToDpi(25));
	        addChild(_validateButton);
        }
	
//------------------------------------------------------------------------------------------------------------
//	Get - Set
	
	    /**
	     * Closes the popup.
	     */
        private function onClose(event:Event):void
        {
	        //_validateButton.enabled = false;
	        //_closeButton.enabled = false;
	        
            dispatchEventWith(LKAvatarMakerEventTypes.CLOSE_NOT_ENOUGH_COOKIES, false, false);
        }
	
//------------------------------------------------------------------------------------------------------------
//	Dispose
	    
	    override public function dispose():void
	    {
		    _background.removeFromParent(true);
		    _background = null;
		    
		    _titleLabel.removeFromParent(true);
		    _titleLabel = null;
		
		    _descriptionLabel.removeFromParent(true);
		    _descriptionLabel = null;
		
		    _toolTipLabel.removeFromParent(true);
		    _toolTipLabel = null;
		
		    _closeButton.removeEventListener(Event.TRIGGERED, onClose);
		    _closeButton.removeFromParent(true);
		    _closeButton = null;
		    
		    _validateButton.removeEventListener(Event.TRIGGERED, onClose);
		    _validateButton.removeFromParent(true);
		    _validateButton =  null;
		    
		    super.dispose();
	    }
	    
    }
}
