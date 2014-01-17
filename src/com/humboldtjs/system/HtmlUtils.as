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
	import com.humboldtjs.geom.Point;
	
	import dom.domobjects.Event;
	import dom.domobjects.HTMLElement;
	import dom.window;

	/**
	 * Some utility methods that help with dealing with HTML elements and their
	 * browser and device differences.
	 * 
	 * Mainly deals with the abstraction of differences between HTML events.
	 */
	public class HtmlUtils
	{
		protected static var mListeners:Array = null;
		
		/**
		 * Given an Event triggered by the DOM will return the position of the
		 * mouse when that event occurred. Is intended for use with mouse and
		 * touch events caught using the bindPress/UnPress/Move events.
		 */
		public static function getPosition(aEvent:Event):Point
		{
			if (typeof aEvent === "undefined") return null;
				
			var theX:Number = aEvent.clientX;
			var theY:Number = aEvent.clientY;
			
			if (typeof aEvent["touches"] !== "undefined") {
				theX = aEvent["touches"][0].clientX;
				theY = aEvent["touches"][0].clientY;
			}
			
			return new Point(theX, theY);
		}
		
		/**
		 * Find a supported property on an object; pass in a bunch of possible
		 * property names and it will return the property name for the first one
		 * it finds. This is useful to find a bunch of variations with vendor
		 * prefixes.
		 */
		public static function getPropertyFromListWithVendor(aObject:Object, aPropertyList:Array):String
		{
			if (aPropertyList == null) return null;
			
			var theVendors:Array = ["webkit", "moz", "o", "ms"];
			
			for (var i:int = 0; i < aPropertyList.length; i++) {
				var theName:String = aPropertyList[i];
				var theUCName:String = theName.substr(0, 1).toUpperCase() + theName.substr(1);

				if (typeof aObject[theName] !== "undefined")
					return theName;
				
				for (var j:int = 0; j < theVendors.length; j++) {
					if (typeof aObject[theVendors[j] + theUCName] !== "undefined")
						return theVendors[j] + theUCName;
				}
			}
			
			return null;
		}
		
		/**
		 * Listen to when an HTML element gets a mousedown or touchstart. This
		 * allows you to capture the start of a drag action regardless of whether
		 * the user is on a touchscreen or using a mouse.
		 * 
		 * @param aElement The HTML element to bind the event on
		 * @param aFunction The EventFunction to call when the press happens
		 */
		public static function bindPress(aElement:Object, aFunction:Function):void
		{
			if (Capabilities.getHasTouchscreen()) {
				addHtmlEventListener(aElement, "touchstart", aFunction);
			} else {
				addHtmlEventListener(aElement, "mousedown", aFunction);
			}
		}
		
		/**
		 * Listen to when an HTML element gets a mousemove or touchmove. This
		 * allows you to capture the move during a drag action regardless of whether
		 * the user is on a touchscreen or using a mouse.
		 * 
		 * @param aElement The HTML element to bind the event on
		 * @param aFunction The EventFunction to call when the move happens
		 */
		public static function bindMove(aElement:Object, aFunction:Function):void
		{
			if (Capabilities.getHasTouchscreen()) {
				addHtmlEventListener(aElement, "touchmove", aFunction);
			} else if (aElement.addEventListener) {
				addHtmlEventListener(window, "mousemove", aFunction);
			} else {
				addHtmlEventListener(aElement, "mousemove", aFunction);
			}
		}
		
		/**
		 * Listen to when an HTML element gets a mouseup, touchend or touchcancel. This
		 * allows you to capture the end of a drag action regardless of whether
		 * the user is on a touchscreen or using a mouse.
		 * 
		 * @param aElement The HTML element to bind the event on
		 * @param aFunction The EventFunction to call when the unpress happens
		 */
		public static function bindUnPress(aElement:Object, aFunction:Function):void
		{
			if (Capabilities.getHasTouchscreen()) {
				addHtmlEventListener(window, "touchend", aFunction);
				addHtmlEventListener(window, "touchcancel", aFunction);
			} else if (aElement.addEventListener) {
				addHtmlEventListener(window, "mouseup", aFunction);
			} else {
				addHtmlEventListener(aElement, "mouseup", aFunction);
			}
		}
		
		/**
		 * Stop listening to the Press events.
		 * 
		 * @param aElement The HTML element that the the event was bound to
		 * @param aFunction The EventFunction that the press was bound to
		 */
		public static function unbindPress(aElement:Object, aFunction:Function):void
		{
			if (Capabilities.getHasTouchscreen()) {
				removeHtmlEventListener(aElement, "touchstart", aFunction);
			} else {
				removeHtmlEventListener(aElement, "mousedown", aFunction);
			}
		}
		
		/**
		 * Stop listening to the Move events.
		 * 
		 * @param aElement The HTML element that the the event was bound to
		 * @param aFunction The EventFunction that the move was bound to
		 */
		public static function unbindMove(aElement:Object, aFunction:Function):void
		{
			if (Capabilities.getHasTouchscreen()) {
				removeHtmlEventListener(aElement, "touchmove", aFunction);
			} else if (aElement.addEventListener) {
				removeHtmlEventListener(window, "mousemove", aFunction);
			} else {
				removeHtmlEventListener(aElement, "mousemove", aFunction);
			}
		}
		
		/**
		 * Stop listening to the UnPress events.
		 * 
		 * @param aElement The HTML element that the the event was bound to
		 * @param aFunction The EventFunction that the unpress was bound to
		 */
		public static function unbindUnPress(aElement:Object, aFunction:Function):void
		{
			if (Capabilities.getHasTouchscreen()) {
				removeHtmlEventListener(window, "touchend", aFunction);
				removeHtmlEventListener(window, "touchcancel", aFunction);
			} else if (aElement.addEventListener) {
				removeHtmlEventListener(window, "mouseup", aFunction);
			} else {
				removeHtmlEventListener(aElement, "mouseup", aFunction);
			}
		}
		
		public static function addHtmlEventListenerWithVendor(aElement:Object, aType:String, aFunction:Function):void
		{
			addHtmlEventListener(aElement, aType, aFunction);
			addHtmlEventListener(aElement, "webkit" + aType, aFunction);
			addHtmlEventListener(aElement, "moz" + aType, aFunction);
			addHtmlEventListener(aElement, "o" + aType, aFunction);
			addHtmlEventListener(aElement, "ms" + aType, aFunction);
		}
		
		public static function removeHtmlEventListenerWithVendor(aElement:Object, aType:String, aFunction:Function):void
		{
			removeHtmlEventListener(aElement, aType, aFunction);
			removeHtmlEventListener(aElement, "webkit" + aType, aFunction);
			removeHtmlEventListener(aElement, "moz" + aType, aFunction);
			removeHtmlEventListener(aElement, "o" + aType, aFunction);
			removeHtmlEventListener(aElement, "ms" + aType, aFunction);
		}
		
		/**
		 * Start listening to an HTML DOM event. When the event is triggered
		 * the EventFunction will be called with the dom Event that
		 * was triggered. This will automatically handle the different methods
		 * of event listening between different browsers.
		 * 
		 * @param aElement The HTML element to bind the event to
		 * @param aType The string name of the event to listen for
		 * @param aFunction The EventFunction that should be called when the event is triggered
		 */
		public static function addHtmlEventListener(aElement:Object, aType:String, aFunction:Function):void
		{
			var theIn:* = aFunction;

			if (mListeners == null) mListeners = [];
			
			var theListener:Object = null;
			
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
					theListener.f == theIn.f &&
					theListener.l == aElement) return;
			}
			
			// Store the listener that is being registered, so we can remove it
			// again later.
			theListener = {t: aType, e: theIn, s: theIn.s, f: theIn.f, l: aElement};
			mListeners.push(theListener);

			// Some browsers use addEventListener and others use attachEvent so
			// we do a quick check and use the appropriate one
			if (theListener.l.addEventListener) {
				theListener.l.addEventListener(theListener.t, theListener.e, false);
			} else if (theListener.l.attachEvent) {
				theListener.l.attachEvent("on" + theListener.t, theListener.e);
			}
		}
		
		/**
		 * Check whether an HTML element has any event listeners bound to it.
		 * This only takes into account events that have been bound using the
		 * HtmlUtils class.
		 * 
		 * @param aElement The HTML element to check for listeners
		 * @param aType The string name of the event to check for
		 */
		public static function hasHtmlEventListener(aElement:Object, aType:String):Boolean
		{
			if (mListeners == null) mListeners = [];
			
			var theListener:Object = null;
			
			for (var i:int = mListeners.length - 1; i >= 0; i--) {
				theListener = mListeners[i];
				if (theListener.t == aType &&
					theListener.l == aElement) return true;
			}
			
			return false;
		}
		
		/**
		 * Stop listening to an HTML DOM event. You can unregister even with a
		 * different EventFunction as long as the instance and method are the
		 * same.
		 * 
		 * @param aElement The HTML element to unbind the event from
		 * @param aType The string name of the event to unbind
		 * @param aFunction The EventFunction that references the instance and method that the event was bound to
		 */
		public static function removeHtmlEventListener(aElement:Object, aType:String, aFunction:Function):void
		{
			var theIn:* = aFunction;
			
			if (mListeners == null) mListeners = [];
			
			var theListener:Object = null;
			
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
					theListener.f == theIn.f &&
					theListener.l == aElement) {
					
					mListeners.splice(i, 1);
					i = 0;
				}
			}
			
			// If there is no listener then we return without doing anything
			if (theListener == null) return;

			// Some browsers use removeEventListener and others use detachEvent so
			// we do a quick check and use the appropriate one
			if (theListener.l.removeEventListener) {
				theListener.l.removeEventListener(theListener.t, theListener.e, false);
			} else if (theListener.l.detachEvent) {
				theListener.l.detachEvent("on" + theListener.t, theListener.e);
			}
		}
		
		/**
		 * Recursively search a given HTML element for a child with the requested
		 * ID.
		 * 
		 * @param aId The ID to search for
		 * @param aParentObject The parent HTML element to search through
		 */
		public static function getHtmlElementById(aId:String, aParentObject:HTMLElement):HTMLElement
		{
			var theParentObject:HTMLElement = aParentObject;
			
			for (var i:int = 0; i < theParentObject.childNodes.length; i++)	{
				var theElement:HTMLElement = theParentObject.childNodes[i];
				
				if (theElement.id == aId)
					return theElement;
				
				var theRecursiveCheckedElement:HTMLElement = HtmlUtils.getHtmlElementById(aId, theElement);
				
				if (theRecursiveCheckedElement != null)
					return theRecursiveCheckedElement;
			}
			
			return null;
		}
	}
}