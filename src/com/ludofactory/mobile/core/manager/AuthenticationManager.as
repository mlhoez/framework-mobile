/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 24 juil. 2013
*/
package com.ludofactory.mobile.core.manager
{

	import com.ludofactory.mobile.navigation.authentication.*;
	import com.ludofactory.common.utils.logs.log;
	import com.ludofactory.mobile.core.controls.AdvancedScreenNavigator;
	import com.ludofactory.mobile.core.model.ScreenIds;
	
	/**
	 * Checks whether the user is logged in and if he has completed the
	 * whole process to know where he should be redirected.
	 *
	 * <p>The following example calls the authentication manager to ask the
	 * user to authenticate, and redirects to the home screen in case the
	 * back button is touched, and to the complete screen when the process
	 * is finished :</p>
	 *
	 * <listing version="3.0">
	 * AuthenticationManager.startAuthenticationProcess(this.advancedOwner, AdvancedScreen.HOME_SCREEN, this.advancedOwner.activeScreenID);
	 * </listing>
	 */
	public class AuthenticationManager
	{
		public function AuthenticationManager()
		{
			
		}
		
		/**
		 * Starts the authentication process.
		 * 
		 * We can see two different possibilities :
		 *  <p>- The user is logged in and have successfully registered a pseudo : in this case, he will be
		 *    directly redirected the the complete screen.</p>
		 *  <p>- The user is logged in but have not registered a pseudo : in this case, he will be redirected
		 *    to the pseudo choice screen to complete the process, and then he will be redirected to the
		 *    complete screen.</p>
		 *  <p>- The user is not logged in : in this case, he will be redirected to the log in screen to start
		 *    the process.</p>
		 * 
		 * @param advancedScreenNavigator The AdvancedScreenNavigator used to navigate automatically through screens.
		 * @param completeScreenId The complete screen identifier
		 * @param backScreenId The back screen identifier
		 * 
		 */		
		public static function startAuthenticationProcess(advancedScreenNavigator:AdvancedScreenNavigator, completeScreenId:String):void
		{
			if( MemberManager.getInstance().isLoggedIn() )
			{
				if( MemberManager.getInstance().pseudo == "" || MemberManager.getInstance().pseudo == null )
				{
					// user is logged in, but he may have not finished all the steps such as the validation
					// of his pseudo, thus we need to send him to the PseudoChoiceScreen.
					log("[AuthenticationManager] User is logged in and have NOT completed the registering process (didn't choose a pseudo).");
					advancedScreenNavigator.showScreen( ScreenIds.PSEUDO_CHOICE_SCREEN );
				}
				else
				{
					log("[AuthenticationManager] User is logged in and have completed the registering process.");
					advancedScreenNavigator.showScreen( completeScreenId );
				}
			}
			else
			{
				log("[AuthenticationManager] User is not logged in, start authentication...");
				advancedScreenNavigator.showScreen( ScreenIds.REGISTER_SCREEN );
			}
		}
	}
}