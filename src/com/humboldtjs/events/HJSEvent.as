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
	 * The base HumboldtJS event class. Any event that you send (other than
	 * HTML events used in HtmlUtils) should extend HJSEvent.
	 */
	public class HJSEvent
	{
		public static const COMPLETE:String = "complete";
		public static const FAR_ENOUGH:String = "farEnough";
		public static const IO_ERROR:String = "error";
		public static const ENTER_FRAME:String = "enterFrame";
		
		protected var _type:String;
		protected var _currentTarget:EventDispatcher;				// Should always be an EventDispatcher, but made Object to be more flexible in the future
		protected var _isDefaultPrevented:Boolean;
		protected var _stopImmediatePropagation:Boolean;
		
		/**
		 * The event type
		 */
		public function getType():String					{ return _type; }
		/**
		 * The event type
		 */
		public function setType(value:String):void			{ _type = value; }
		
		/**
		 * Whether the event is cancelable
		 */
		public function getCancelable():Boolean				{ return true; }
		
		/**
		 * The current target from which the event was sent
		 */
		public function getCurrentTarget():EventDispatcher	{ return _currentTarget; }
		
		/**
		 * @constructor
		 */
		public function HJSEvent(aType:String)
		{
			_isDefaultPrevented = false;
			_stopImmediatePropagation = false;
			setType(aType);
		}
		
		/**
		 * Prevent the default processing of the event. Since these events
		 * usually don't have a default, this usually does nothing.
		 */
		public function preventDefault():void
		{
			_isDefaultPrevented = true;
		}
		
		/**
		 * Whether preventDefault has been called on this event.
		 */
		public function isDefaultPrevented():Boolean
		{
			return _isDefaultPrevented;
		}
		
		/**
		 * Immediately stops propagating the event. The event handler that
		 * called this function will be the last to get the event, and any
		 * processing afterwards will be aborted.
		 */
		public function stopImmediatePropagation():void
		{
			_stopImmediatePropagation = true;
		}
	}
}