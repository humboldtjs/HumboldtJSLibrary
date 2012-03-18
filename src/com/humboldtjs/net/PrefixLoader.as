/*
* HumboldtJSLibrary
* http://humboldtjs.com/
*
* Copyright (c) 2012 Daniël Haveman
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
		protected var mIsLoading:Boolean;
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
			mIsLoading = false;
			mScript = document.createElement("script") as HTMLScriptElement;

			mContent = {};
		}
		
		/**
		 * Close the loader before finishing loading. Cleans up the head and
		 * removes the script.
		 */
		public function close():void
		{
			if (!mIsLoading) return;
			
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
			unload();
			
			// We store the internal ID in the script to be able to do
			// some smart stuff with that in the future
			mScript["src"] = request.getUrl();
			mScript.id = getInternalId();

			// Create the callback on the prefix
			window[getPrefix()] = onCallback;
			mCallbacks.push(this);
			
			// Then we keep track of how often a prefix callback is used to
			// be able to clean up properly when nothing is being loaded anymore
			if (mPrefixIndex[getPrefix()] == null) mPrefixIndex[getPrefix()] = 0;
			mPrefixIndex[getPrefix()]++;
			
			mIsLoading = true;
			
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
			unload();
			
			mContent = aValue;

			// We're done!
			dispatchEvent(new HJSEvent(HJSEvent.COMPLETE));
		}
		
		/**
		 * Handle all JSON callbacks, and figure out the right PrefixLoader and
		 * have it handle the rest of the callback.
		 */
		protected static function onCallback(aValue:*):void
		{
			var thePrefixLoader:PrefixLoader = mCallbacks.shift();
			thePrefixLoader.doCallback(aValue);
		}
	}
}