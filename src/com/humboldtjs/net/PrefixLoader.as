/*
* HumboldtJSLibrary
* http://humboldtjs.com/
*
* Copyright (c) 2012 DaniÃ«l Haveman
* Licensed under the MIT license
* http://humboldtjs.com/license.html
*/
package com.humboldtjs.net
{
	import com.humboldtjs.events.EventDispatcher;
	import com.humboldtjs.events.HJSEvent;
	import com.humboldtjs.system.InternalId;
	
	import dom.document;
	import dom.domobjects.HTMLElement;
	import dom.domobjects.HTMLScriptElement;
	import dom.eventFunction;
	import dom.window;
	
	/**
	 * The PrefixLoader is a simple loader that loads data using the JSONP
	 * method. It will load a file by creating a script and adding it to the
	 * DOM. Then when the script gets executed a "parse" method inside will
	 * call back to the PrefixLoader and handle sending the loaded data
	 * back into the HumboldtJS application.
	 * 
	 * By default the parse method is "parse" and as such it expects your
	 * JSONP to be prefixed by that parse method. You can define different
	 * parse methods using the setPrefix method.
	 */
	public class PrefixLoader extends EventDispatcher
	{
		protected static const IDENTIFIER_ISLOADING:String = "IsLoading";
		protected static const IDENTIFIER_LOADQUEUE:String = "LoadQueue";
		
		protected var mContent:*;
		protected var mScript:HTMLScriptElement;
		protected var mPrefix:String;		
		protected var mInternalId:String;
		
		protected static var mCallbacks:Vector.<PrefixLoader> = new Vector.<PrefixLoader>();
		protected static var mPrefixIndex:Object = new Object();
		
		/**
		 * The JSONP prefix to use
		 */
		public function getPrefix():String				{ return mPrefix; }
		/**
		 * The JSONP prefix to use
		 */
		public function setPrefix(aValue:String):void	{ mPrefix = aValue; }

		/**
		 * The unique internal ID of this PrefixLoader. Is used to link the
		 * JSONP script back to this specific instance of PrefixLoader.
		 */
		public function getInternalId():String			{ return mInternalId; }
		
		/**
		 * The loaded content
		 */
		public function getContent():*				{ return mContent; }
		
		/**
		 * @constructor
		 */
		public function PrefixLoader()
		{
			super();
			mInternalId = InternalId.generateInternalId("PrefixLoader");
			mPrefix = "parse";
			
			if (typeof window[getPrefix() + IDENTIFIER_ISLOADING] == "undefined" || window[getPrefix() + IDENTIFIER_ISLOADING] == null)
				window[getPrefix() + IDENTIFIER_ISLOADING] = false;
			if (typeof window[getPrefix() + IDENTIFIER_LOADQUEUE] == "undefined" || window[getPrefix() + IDENTIFIER_LOADQUEUE] == null)
				window[getPrefix() + IDENTIFIER_LOADQUEUE] = new Vector.<URLRequest>();
			
			mScript = document.createElement("script") as HTMLScriptElement;

			mContent = {};
		}
		
		/**
		 * Close the loader before finishing loading. Cleans up the head and
		 * removes the script.
		 */
		public function close():void
		{
			if (!window[getPrefix() + IDENTIFIER_ISLOADING]) return;
						
			// Remove the old script
			var theHead:HTMLElement = document.getElementsByTagName("head")[0];
			theHead.removeChild(mScript);

			mScript["src"] = "";

			// Try to clean up the prefix callbacks a bit.
			mPrefixIndex[getPrefix()]--;
			if (mPrefixIndex[getPrefix()] == 0) {
				window[getPrefix()] = null;
			}
			
			// And clear the content
			mContent = null;
		}
		
		/**
		 * Load a JSONP from the give URLRequest.
		 */
		public function load(request:URLRequest):void
		{
			// If we are currently loading, store the item in a queue
			if (window[getPrefix() + IDENTIFIER_ISLOADING] == true)
			{
				window[getPrefix() + IDENTIFIER_LOADQUEUE] = window[getPrefix() + IDENTIFIER_LOADQUEUE].concat(request);
				mCallbacks.push(this);
				return;
			}
			
			unload();
			
			// We store the internal ID in the script to be able to do
			// some smart stuff with that in the future
			mScript["src"] = request.getUrl();
			mScript.id = getInternalId();

			// Create the callback on the prefix
			window[getPrefix()] = eventFunction(this, doCallback);
			if (mCallbacks.indexOf(this) != -1) // Should always be != -1 otherwise something will go wrong.
				mCallbacks.unshift(this); // Put it at the beginning
			
			// Then we keep track of how often a prefix callback is used to
			// be able to clean up properly when nothing is being loaded anymore
			if (mPrefixIndex[getPrefix()] == null) mPrefixIndex[getPrefix()] = 0;
			mPrefixIndex[getPrefix()]++;
			
			window[getPrefix() + IDENTIFIER_ISLOADING] = true;
			
			// And add the script to the head to start loading
			var theHead:HTMLElement = document.getElementsByTagName("head")[0];
			theHead.appendChild(mScript);
		}
		
		/**
		 * Unload the current content and close the loader
		 */
		public function unload():void
		{
			close();
		}
		
		/**
		 * Handle the callback as instructed by the prefix.
		 */
		protected function doCallback(aValue:*):void
		{
			unload();
			
			mContent = aValue;
						
			// We're done!
			dispatchEvent(new HJSEvent(HJSEvent.COMPLETE));
			
			// Load the next item if we have any of those.
			loadNextIfAvailable();
		}
		
		/**
		 * Load the next item in the queue if any is available
		 */
		protected function loadNextIfAvailable():void
		{
			window[getPrefix() + IDENTIFIER_ISLOADING] = false;
			
			if (window[getPrefix() + IDENTIFIER_LOADQUEUE].length > 0)
			{
				var theUrlRequest:URLRequest = window[getPrefix() + IDENTIFIER_LOADQUEUE].shift();
				
				// Find the next prefixloader and load the matching item from the queue in it.
				var thePrefixLoader:PrefixLoader = mCallbacks.shift();
				thePrefixLoader.load(theUrlRequest);
			}
		}
	}
}