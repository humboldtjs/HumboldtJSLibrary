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
	 * An EventDispatcher is an object that can easily send events (HJSEvent).
	 * Any event has a named type, and objects can register and deregister
	 * themselves as listeners for events of a certain type using the
	 * addEventListener and removeEventListener methods. 
	 */
	public class EventDispatcher implements IEventDispatcher
	{
		protected var mListeners:Array;
		
		/**
		 * @constructor
		 */
		public function EventDispatcher()
		{
			mListeners = [];
		}
		
		/**
		 * Add an EventFunction as a listener to events of the given type.
		 * Whenever that type of event is dispatched the Eventfunction will
		 * be called.
		 * 
		 * @param aType The type name of the event to listen for
		 * @param aFunction The EventFunction to call when the event is dispatched
		 */
		public function addEventListener(aType:String, aFunction:Function):void
		{
			var theIn:* = aFunction;
			
			var theListener:Object;

			// First check if the event is already registered. If so skip
			// adding it again
			for (var i:int = mListeners.length - 1; i >= 0; i--) {
				theListener = mListeners[i];

				// An EventFunction is similar to a normal Function, but is bound
				// to an instance, and has a couple of properties that can be
				// used to check if two different EventFunction instances have the
				// same values (same object, same method). If so then they count
				// as being the same.
				if (theListener.t == aType && 
					theListener.s == theIn.s &&
					theListener.f == theIn.f) return;
			}
			
			// Store the listener that is being registered, so we can remove it
			// again later.
			theListener = {t: aType, e: theIn, s: theIn.s, f: theIn.f};
			mListeners.push(theListener);
		}
		
		/**
		 * Check whether the EventDispatcher has any listeners for the given
		 * type.
		 * 
		 * @param aType The string name of the event type to check for
		 */
		public function hasEventListener(aType:String):Boolean
		{
			var theListener:Object;
			
			for (var i:int = mListeners.length - 1; i >= 0; i--) {
				theListener = mListeners[i];
				if (theListener.t == aType) return true;
			}
			
			return false;
		}
			
		/**
		 * Remove an EventFunction as a listener to events of the given type.
		 * 
		 * @param aType The type name of the event to remove from
		 * @param aFunction The EventFunction to remove as listener
		 */
		public function removeEventListener(aType:String, aFunction:Function):void
		{
			var theIn:* = aFunction;
			var theListener:Object;
			
			// Loop through all registered listeners and remove it if it has
			// a matching event
			for (var i:int = mListeners.length - 1; i >= 0; i--) {
				theListener = mListeners[i];
				
				// An EventFunction is similar to a normal Function, but is bound
				// to an instance, and has a couple of properties that can be
				// used to check if two different EventFunction instances have the
				// same values (same object, same method). If so then they count
				// as being the same.
				if (theListener.t == aType && 
					theListener.s == theIn.s &&
					theListener.f == theIn.f) {
					
					mListeners.splice(i, 1);
				}
			}
		}
		
		/**
		 * Dispatch an event. Every event that is dispatched must extend
		 * HJSEvent. The method that receives the event must also accept an
		 * HJSEvent, but ideally would receive an event of the same type that
		 * was dispatched.
		 * 
		 * The HJSEvent will contain a currentTarget (getCurrentTarget()) that
		 * points towards the EventDispatcher instance that sent the message.
		 */
		public function dispatchEvent(aEvent:HJSEvent):void
		{
			var theListener:Object;
			var theType:String = aEvent.getType();
			
			// Set the currentTarget to the instance dispatching the event
			aEvent["mCurrentTarget"] = this;

			// Operate on a copy, because listeners may be modified in the
			// listening callback
			var theListeners:Array = mListeners.slice();
			// Loop through all listeners that might be interested in this event
			for (var i:int = theListeners.length - 1; i >= 0; i--) {
				theListener = theListeners[i];
				
				if (theListener.t == theType) {
					theListener.e(aEvent);
					
					// Check whether stop immediate propagation has been called
					// in the last listener function
					if (aEvent["mStopImmediatePropagation"] == true) return;
				}
			}
		}
	}
}