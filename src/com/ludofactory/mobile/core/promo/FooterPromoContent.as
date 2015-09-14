/**
 * Created by Maxime on 14/09/15.
 */
package com.ludofactory.mobile.core.promo
{
	
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import starling.display.Sprite;
	import starling.text.TextField;
	import starling.text.TextFieldAutoSize;
	
	public class FooterPromoContent extends Sprite
	{
		private var _label:TextField;
		
		private var _promoContent:PromoContent;
		
		public function FooterPromoContent()
		{
			_label = new TextField(5, 5, "0", Theme.FONT_SANSITA, scaleAndRoundToDpi(26), Theme.COLOR_DARK_GREY);
			_label.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
			//addChild(_label);
		}
		
		public function update():void
		{
			if(PromoManager.getInstance().isPromoPending)
			{
				if(!_promoContent)
				{
					// there is no promo, so build one
					_promoContent = PromoManager.getInstance().getPromoContent(true);
					//_promoContent.y = _label.height;
					addChild(_promoContent);
				}
			}
			else
			{
				if(_promoContent)
				{
					PromoManager.getInstance().removePromo(_promoContent);
					_promoContent.removeFromParent(true);
				}
				_promoContent = null;
			}
		}
		
		public function set labelText(val:String):void
		{
			_label.text = val;
		}
	}
}