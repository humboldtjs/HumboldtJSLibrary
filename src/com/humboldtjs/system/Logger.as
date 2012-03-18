/*
* HumboldtJSLibrary
* http://humboldtjs.com/
*
* Copyright (c) 2012 Daniël Haveman
* Licensed under the MIT license
* http://humboldtjs.com/license.html
*/
package com.humboldtjs.system
{
	import dom.alert;
	import dom.window;

	/**
	 * Allows logging to the default browser console. Basically does the same
	 * thing as trace, but also allows to log warnings and errors.
	 */
	public class Logger
	{
		public function Logger()
		{
		}
		
		/**
		 * Write a message or object to the console.
		 * 
		 * @param aMessage The message or object to write
		 */
		public static function log(aMessage:*):void
		{
			if (window.console && window.console.log) {
				window.console.log(aMessage);
			}
		}

		/**
		 * Write a message or object to the console as a warning.
		 * 
		 * @param aMessage The message or object to write
		 */
		public static function warn(aMessage:*):void
		{
			if (window.console && window.console.warn) {
				window.console.warn(aMessage);
			}
		}
		
		/**
		 * Write a message or object to the console as an error
		 * 
		 * @param aMessage The message or object to write
		 */
		public static function error(aMessage:*):void
		{
			if (window.console && window.console.error) {
				window.console.error(aMessage);
			} else {
				alert(aMessage);
			}
		}
	}
}