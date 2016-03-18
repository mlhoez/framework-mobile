/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 19 sept. 2013
*/
package com.ludofactory.mobile.navigation.account.history.settings
{
	
	import com.freshplanet.nativeExtensions.AirNetworkInfo;
	import com.greensock.TweenMax;
	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.controls.AbstractAccordionItem;
	import com.ludofactory.mobile.core.controls.Accordion;
	import com.ludofactory.mobile.core.manager.InfoContent;
	import com.ludofactory.mobile.core.manager.InfoManager;
	import com.ludofactory.mobile.core.manager.MemberManager;
	import com.ludofactory.mobile.core.remoting.Remote;
	import com.ludofactory.mobile.navigation.authentication.NotLoggedInContainer;
	import com.ludofactory.mobile.navigation.authentication.RetryContainer;
	
	import feathers.core.FeathersControl;
	
	import starling.events.Event;
	import starling.utils.StringUtil;
	
	public class PersonalInformationsContainer extends FeathersControl
	{
		/**
		 * The mail alert. */		
		private var _mailAlert:AccountMailAlert;
		
		/**
		 * The authentication container. */		
		private var _authenticationContainer:NotLoggedInContainer;
		/**
		 * The retry container. */		
		private var _retryContainer:RetryContainer;
		
		/**
		 * The accordion. */		
		private var _accordion:Accordion;
		
		public function PersonalInformationsContainer()
		{
			super();
		}
		
		override protected function initialize():void
		{
			_authenticationContainer = new NotLoggedInContainer();
			_authenticationContainer.visible = false;
			addChild(_authenticationContainer);
			
			_retryContainer = new RetryContainer();
			_retryContainer.addEventListener(Event.TRIGGERED, onRetry);
			_retryContainer.visible = false;
			addChild(_retryContainer);
			
			if( MemberManager.getInstance().isLoggedIn() )
			{
				_retryContainer.visible = true;
				if( AirNetworkInfo.networkInfo.isConnected() )
				{
					TweenMax.delayedCall(0.5, Remote.getInstance().getAccountInformations, [onGetAccountInformationsSuccess, onGetAccountInformationsFailure, onGetAccountInformationsFailure, 2, AbstractEntryPoint.screenNavigator.activeScreenID]);
				}
				else
				{
					_retryContainer.loadingMode = false;
				}
			}
			else
			{
				_authenticationContainer.visible = true;
			}
		}
		
		override protected function draw():void
		{
			super.draw();
			
			if( _mailAlert )
			{
				_mailAlert.width = this.actualWidth;
				_mailAlert.validate();
				_mailAlert.y = this.actualHeight - _mailAlert.height;
			}
			
			if( _accordion )
			{
				_accordion.width = this.actualWidth;
				_accordion.height = _mailAlert ? (this.actualHeight - _mailAlert.height):this.actualHeight;
			}
			
			_authenticationContainer.width = _retryContainer.width = actualWidth;
			_authenticationContainer.height = _retryContainer.height = actualHeight;
		}
		
//------------------------------------------------------------------------------------------------------------
//	Handlers
//------------------------------------------------------------------------------------------------------------
		
		/**
		 * The payments could be retreived.
		 * 
		 * <p>Because the request is heavy, we only display the
		 * last 20 elements from the history. We don't allow the
		 * user to request an update or load the next payments by
		 * scrolling at the end of the list.</p>
		 */		
		private function onGetAccountInformationsSuccess(result:Object):void
		{
			switch(result.code)
			{
				case 0: // invalid data
				case 2: // Impossible de récupérer les objs membre ou vipt
				case 3: // impossible de récupérer la liste des pays
				{
					_retryContainer.loadingMode = false;
					_retryContainer.singleMessageMode = true;
					_retryContainer.message = result.txt;
					
					break;
				}
				case 1: // success
				{
					_retryContainer.visible = false;
					
					if( result.alerte.validation_mail != null )
					{
						// the user didn't click on the link in the mail to validate this
						// email adress. In this case we need to display something on top
						// of the screen to indicate that he must do this to validate his
						// account.
						
						_mailAlert = new AccountMailAlert( StringUtil.format(_("Validez votre compte et bénéficier d'avantages VIP en cliquant sur le lien envoyé à l'adresse : {0}"), result.connexion.mail), false);
						addChild( _mailAlert );
					}
					else if( result.alerte.changement_mail != null )
					{
						// the user has requested a change for his email adress. In this
						// case we need to tell him that a request is pending on that he
						// must click on this email to validate this adress.
						
						_mailAlert = new AccountMailAlert( StringUtil.format(_("Validez la modification de votre email en cliquant sur le lien envoyé à l'adresse : {0}"), result.alerte.changement_mail), false);
						addChild( _mailAlert );
					}
					invalidate( INVALIDATION_FLAG_DATA );
					
					var panels:Vector.<AbstractAccordionItem> = new Vector.<AbstractAccordionItem>();
					panels.push( new SettingAccordionItem( _("Informations personnelles"), new PersonalSettingsContainer( result.perso ) ) );
					panels.push( new SettingAccordionItem( _("Adresse"), new AddressSettingsContainer( result.adresse ) ) );
					//if( result.pseudo && "modifiy" in result.pseudo && result.pseudo.modifiy == true )
						panels.push( new SettingAccordionItem( _("Pseudo"), new PseudoSettingsContainer( result.pseudo ) ) );
					panels.push( new SettingAccordionItem( _("Email"), new EmailSettingsContainer( result.connexion ) ) );
					panels.push( new SettingAccordionItem( _("Changer le mot de passe"), new PasswordSettingsContainer( result.connexion ) ) );
					panels.push( new SettingAccordionItem( _("Notifications push"), new NotificationSettingsContainer( result.notification ) ) );
					
					_accordion = new Accordion();
					_accordion.dataProvider = panels;
					addChild(_accordion);
					
					invalidate();
					
					break;
				}
					
				default:
				{
					onGetAccountInformationsFailure();
					break;
				}
			}
		}
		
		/**
		 * There was an error while trying to retreive the account informations.
		 * 
		 * <p>In this case we display an error message and a button to retry.</p>
		 */		
		private function onGetAccountInformationsFailure(error:Object = null):void
		{
			_retryContainer.message = _("Une erreur est survenue, veuillez réessayer.");
			_retryContainer.loadingMode = false;
		}
		
		/**
		 * If an error occurred while retreiving the account informations or if
		 * the user was not connected when this componenent was created, we need
		 * to show a retry button so that he doesn't need to leave and come back
		 * to the view to load the data.
		 */		
		private function onRetry(event:Event):void
		{
			if( AirNetworkInfo.networkInfo.isConnected() )
			{
				_retryContainer.loadingMode = true;
				Remote.getInstance().getAccountInformations(onGetAccountInformationsSuccess, onGetAccountInformationsFailure, onGetAccountInformationsFailure, 2, AbstractEntryPoint.screenNavigator.activeScreenID);
			}
			else
			{
				InfoManager.showTimed(_("Aucune connexion Internet."), InfoManager.DEFAULT_DISPLAY_TIME, InfoContent.ICON_CROSS);
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
//------------------------------------------------------------------------------------------------------------
		
		override public function dispose():void
		{
			_authenticationContainer.removeFromParent(true);
			_authenticationContainer = null;
			
			_retryContainer.removeEventListener(Event.TRIGGERED, onRetry);
			_retryContainer.removeFromParent(true);
			_retryContainer = null;
			
			if( _mailAlert )
			{
				_mailAlert.removeFromParent(true);
				_mailAlert = null;
			}
			
			super.dispose();
		}
		
	}
}