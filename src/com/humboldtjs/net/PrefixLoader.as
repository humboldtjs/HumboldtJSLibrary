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
		protected static var _loadingQueue:Vector.<PrefixLoader> = new Vector.<PrefixLoader>();
		protected static var _isLoading:Boolean = false;
		
		protected var _content:*;
		protected var _script:HTMLScriptElement;
		protected var _prefix:String;	
		protected var _URLRequest:URLRequest;
		protected var _internalId:String;
		
		/**
		 * The JSONP prefix to use
		 */
		public function getPrefix():String				{ return _prefix; }
		/**
		 * The JSONP prefix to use
		 */
		public function setPrefix(aValue:String):void	{ _prefix = aValue; }

		/**
		 * The unique internal ID of this PrefixLoader. Is used to link the
		 * JSONP script back to this specific instance of PrefixLoader.
		 */
		public function getInternalId():String			{ return _internalId; }
		
		/**
		 * The loaded content
		 */
		public function getContent():*				{ return _content; }
		
		/**
		 * @constructor
		 */
		public function PrefixLoader()
		{
			super();
			_internalId = InternalId.generateInternalId("PrefixLoader");
			_prefix = "parse";
			
			_script = document.createElement("script") as HTMLScriptElement;

			_content = {};
		}
		
		/**
		 * Close the loader before finishing loading. Cleans up the head and
		 * removes the script.
		 */
		public function close():void
		{
			if (_loadingQueue.indexOf(this) != -1)
				_loadingQueue.splice(_loadingQueue.indexOf(this), 1);

			// Remove the old script
			var theHead:HTMLElement = document.getElementsByTagName("head")[0];
			if (_script.parentNode == theHead)
				theHead.removeChild(_script);

			_script["src"] = "";

			// And clear the content
			_content = null;
			
			// We create a new script element because IE9 refuses to reuse
			// the same script element; it will load the new script, but
			// never execute its content
			_script = document.createElement("script") as HTMLScriptElement;
		}
		
		/**
		 * Try to load a JSONP from the given URLRequest. If another
		 * PrefixLoader is already busy loading, this PrefixLoader's request
		 * will be queued and handled when the first loader finishes execution.
		 * This is to make sure multiple requests with the same prefix get
		 * handled properly.
		 */
		public function load(request:URLRequest):void
		{
			_URLRequest = request;
			
			if (_isLoading) {
				// If we're already loading then make sure this loader is on
				// the queue of stuff to load, and return
				
				if (_loadingQueue.indexOf(this) == -1)
					_loadingQueue.push(this);
				return;
			}
			
			// Call the actual loading code. This is separated from here so
			// when handling the next item in the queue the code can jump
			// there directly.
			tryLoad();
		}
		
		protected function tryLoad():void
		{
			unload();
			
			// We store the internal ID in the script to be able to do
			// some smart stuff with that in the future
			_script["src"] = _URLRequest.getUrl();
			_script.id = getInternalId();

			// Create the callback on the prefix
			window[getPrefix()] = doCallback;

			PrefixLoader._isLoading = true;
			
			// And add the script to the head to start loading
			var theHead:HTMLElement = document.getElementsByTagName("head")[0];
			theHead.appendChild(_script);
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
			PrefixLoader._isLoading = false;
			
			_content = aValue;
			
			// Load the next item if we have any of those.
			loadNextIfAvailable();
						
			// We're done!
			dispatchEvent(new HJSEvent(HJSEvent.COMPLETE));
		}
		
		/**
		 * Load the next item in the queue if any is available
		 */
		protected function loadNextIfAvailable():void
		{
			if (_loadingQueue.length > 0) {
				var thePrefixLoader:PrefixLoader = _loadingQueue.shift();
				thePrefixLoader.tryLoad();
			}
		}
	}
}