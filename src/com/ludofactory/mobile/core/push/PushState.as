/*
Copyright © 2006-2014 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 2 oct. 2013
*/
package com.ludofactory.mobile.core.push
{
	public class PushState
	{
		/**
		 * The element is waiting to be pushed. */		
		public static const WAITING:String = "waiting";
		/**
		 * The element is currently being pushed. */		
		public static const PENDING:String = "pending";
		/**
		 * The element have been pushed. */		
		public static const PUSHED:String  = "pushed";
	}
}