/*
* HumboldtJSLibrary
* http://humboldtjs.com/
*
* Copyright (c) 2012 Daniël Haveman
* Licensed under the MIT license
* http://humboldtjs.com/license.html
*/
package com.humboldtjs.display
{
	/**
	 * Interface for any DisplayObject that can have its source set. This is
	 * used by the Loader class to describe its return type
	 */
	public interface ISrcDisplayObject
	{
		function setSrc(value:String):void;
		function getSrc():String;
		
		function clone():ISrcDisplayObject;
	}
}