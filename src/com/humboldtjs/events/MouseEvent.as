/*
* HumboldtJSLibrary
* http://humboldtjs.com/
*
* Copyright (c) 2012 Daniël Haveman
* Licensed under the MIT license
* http://humboldtjs.com/license.html
*/
package com.humboldtjs.events
{
	/**
	 * A mouse event.
	 * 
	 * @TODO this class needs to provide info about the current mouse state
	 */
	public class MouseEvent extends HJSEvent
	{
		public static const CLICK:String = "click";
		
		/**
		 * @constructor
		 */
		public function MouseEvent(aType:String)
		{
			super(aType);
		}
	}
}