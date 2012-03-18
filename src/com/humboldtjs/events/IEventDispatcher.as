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
	import dom.domobjects.EventFunction;

	/**
	 * The interface for an EventDispatcher.
	 */
	public interface IEventDispatcher
	{
		function addEventListener(type:String, listener:EventFunction):void;
		function removeEventListener(type:String, listener:EventFunction):void;
		function dispatchEvent(event:HJSEvent):void;
		function hasEventListener(type:String):Boolean;
	}
}