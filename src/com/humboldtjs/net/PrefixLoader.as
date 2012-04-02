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
			if (typeof window[getPrefix() + "L"] == "undefined" || window[getPrefix() + "L"] == null)
				window[getPrefix() + "L"] = false;
			if (typeof window[getPrefix() + "Q"] == "undefined" || window[getPrefix() + "Q"] == null)
				window[getPrefix() + "Q"] = new Vector.<URLRequest>();
			mScript = document.createElement("script") as HTMLScriptElement;

			mContent = {};
		}
		
		/**
		 * Close the loader before finishing loading. Cleans up the head and
		 * removes the script.
		 */
		public function close():void
		{
			if (!window[getPrefix() + "L"]) return;
						
			// Remove the old script
			var theHead:HTMLElement = document.getElementsByTagName("head")[0];
			
			// First find the correct script tag.
			var theScripts:Array = theHead.getElementsByTagName("script");
			for (var i:int = 0; i < theScripts.length; i++)
			{
				if (theScripts[i].id == getInternalId())
					mScript = theScripts[i];
			}
			//trace("Found it? " + mScript.id + " -- " + getInternalId());
			//theHead.removeChild(mScript);
			mScript["src"] = "";

			// Try to clean up the prefix callbacks a bit.
			mPrefixIndex[getPrefix()]--;
			if (mPrefixIndex[getPrefix()] == 0) {
				window[getPrefix()] = null;
			}
			
			// And clear the content
			mContent = null;
			
			/*mScript = document.createElement("script") as HTMLScriptElement;
			
			mContent = {};*/

		}
		
		/**
		 * Load a JSONP from the give URLRequest.
		 */
		public function load(request:URLRequest):void
		{
			trace("Load from " + getPrefix() + " " + getInternalId());
			trace(typeof window[getPrefix() + "Q"]);
			if (window[getPrefix() + "L"] == true)
			{
				trace("in q " + request.getUrl());
				window[getPrefix() + "Q"] = window[getPrefix() + "Q"].concat(request);
				trace(window[getPrefix() + "Q"].length);
				mCallbacks.push(this);
				return;
			}
			
			unload();
			
			trace("l " + request.getUrl());
			// We store the internal ID in the script to be able to do
			// some smart stuff with that in the future
			mScript["src"] = request.getUrl();
			mScript.id = getInternalId();
			trace("Created new script element: " + mScript.id);

			// Create the callback on the prefix
			window[getPrefix()] = eventFunction(this, doCallback);//onCallback;
			if (mCallbacks.indexOf(this) != -1)
				mCallbacks.unshift(this);
			
			// Then we keep track of how often a prefix callback is used to
			// be able to clean up properly when nothing is being loaded anymore
			if (mPrefixIndex[getPrefix()] == null) mPrefixIndex[getPrefix()] = 0;
				mPrefixIndex[getPrefix()]++;
			
			window[getPrefix() + "L"] = true;
			
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
		 * Handle the callback
		 */
		protected function doCallback(aValue:*):void
		{
			trace("Do callback " + getInternalId());
			unload();
			
			mContent = aValue;
						
			// We're done!
			dispatchEvent(new HJSEvent(HJSEvent.COMPLETE));
			
			loadNextIfAvailable();
		}
		
		protected function loadNextIfAvailable():void
		{
			trace("Loadnext from " + getPrefix() + " :::: " + window[getPrefix() + "L"] + " :::: " + window[getPrefix() + "Q"] + " :::: " + window[getPrefix() + "Q"].length);
			window[getPrefix() + "L"] = false;
			
			if (window[getPrefix() + "Q"].length > 0)
			{
				var theUrlRequest:URLRequest = window[getPrefix() + "Q"].shift();
				trace("out q " + theUrlRequest.getUrl());
				var thePrefixLoader:PrefixLoader = mCallbacks.shift();
				thePrefixLoader.load(theUrlRequest);
			}
		}
		
		/**
		 * Handle all JSON callbacks, and figure out the right PrefixLoader and
		 * have it handle the rest of the callback.
		 */
		protected static function onCallback(aValue:*):void
		{
			var thePrefixLoader:PrefixLoader = mCallbacks.shift();
			trace("onCallback called for " + thePrefixLoader.getInternalId() + " with: " + aValue);
			thePrefixLoader.doCallback(aValue);
		}
	}
}