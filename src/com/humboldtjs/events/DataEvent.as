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
	 * A simple HJSEvent that adds a data field
	 */
	public class DataEvent extends HJSEvent
	{
		public var data:*;
		
		public function DataEvent(aType:String, aData:*)
		{
			super(aType);
			
			data = aData;
		}
	}
}