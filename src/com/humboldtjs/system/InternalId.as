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
	 * Utility class that can generate unique IDs.
	 */
	public class InternalId
	{
		protected static var _internalCounter:int = 0;
		
		public function InternalId()
		{
		}
		
		/**
		 * Generate a unique ID with the given prefix.
		 * 
		 * @param aPrefix The string to place in front of the unique ID. Usually the classname for the object you are generating an ID for.
		 */
		public static function generateInternalId(aPrefix:String):String
		{
			var theId:String = aPrefix + "_@" + _internalCounter;
			_internalCounter++;
			
			return theId;
		}
	}
}