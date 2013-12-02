/*
* HumboldtJSLibrary
* http://humboldtjs.com/
*
* Copyright (c) 2012 Daniël Haveman
* Licensed under the MIT license
* http://humboldtjs.com/license.html
*/
package com.humboldtjs.utility
{
	import dom.window;

	/**
	 * Utility class to call functions after a time delay.
	 */
	public class DelayedCall
	{
		protected static var mTimers:Array = new Array();
		
		/**
		 * Call the EventFunction after a certain time.
		 * 
		 * @param aFunction The EventFunction to call
		 * @param aTime The time to delay calling the function
		 */
		public static function call(aFunction:Function, aTime:int = 0):void
		{
			if (hasCall(aFunction))
				cancelCall(aFunction);
			
			var theTimer:int = window.setTimeout(aFunction, aTime);
			
			mTimers.push({t:theTimer, f:aFunction});
		}
		
		/**
		 * Whether there is a delayed call planned to the given EventFunction
		 * 
		 * @param aFunction The EventFunction to check
		 */
		public static function hasCall(aFunction:Function):Boolean
		{
			var theIn:* = aFunction;
			for (var i:int = 0; i < mTimers.length; i++) {
				var theF:* = mTimers[i].f;
				if (theF.s == theIn.s && theF.f == theIn.f) return true;
			}
			
			return false;
		}
		
		/**
		 * Cancel a delayed call to the given EventFunction. If the EventFunction
		 * has previously been set for a delayed call, but that delayed call has
		 * not yet happened. 
		 * 
		 * @param aFunction The EventFunction to which the delayed call needs to be cancelled.
		 */
		public static function cancelCall(aFunction:Function):void
		{
			var theIn:* = aFunction;
			for (var i:int = mTimers.length - 1; i >= 0; i--) {
				var theF:* = mTimers[i].f;
				if (theF.s == theIn.s && theF.f == theIn.f) 
					mTimers.splice(i, 1);
			}
		}
		
		public function DelayedCall()
		{
		}
	}
}