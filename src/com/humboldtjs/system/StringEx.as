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
	/**
	 * A utility class which adds some missing string parsing functionality
	 */
	public class StringEx
	{
		public function StringEx() {}
		
		/**
		 * Trim a string of leading and trailing whitespace.
		 * 
		 * @param aValue The string to parse
		 */
		public static function trim(aValue:String):String
		{
			return aValue.replace(/^\s*/, "").replace(/\s*$/, "");			
		}
	}
}