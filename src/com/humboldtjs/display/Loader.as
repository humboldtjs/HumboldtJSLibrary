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
	import com.humboldtjs.audio.Audio;
	import com.humboldtjs.events.HJSEvent;
	import com.humboldtjs.net.URLRequest;
	
	/**
	 * A simple loader class that can manage loading Bitmap and Video
	 * instances. Note that the Video class isn't well supported yet since
	 * there are still numerous issues with video on various mobile devices,
	 * so YMMV.
	 */
	public class Loader extends DisplayObject
	{
		protected var _content:DisplayObject;
		protected var _src:String = "";
		protected var _complete:Boolean = false;
		protected var _farEnough:Boolean = false;
		
		/**
		 * If loading was complete returns the loaded content
		 */
		public function getContent():DisplayObject	{ return (_src !== "") ? _content : null; }
		
		/**
		 * Check if loading has completed
		 */
		public function getComplete():Boolean { return _complete; }
		
		/**
		 * Check if loading is far enough to use the asset
		 */
		public function getFarEnough():Boolean { return _farEnough; }
		
		/**
		 * @constructor
		 */
		public function Loader()
		{
			super();
		}
		
		/**
		 * Close the loader before finishing loading. Cleans up any event
		 * listeners and removes the content if it already existed.
		 */
		public function close():void
		{
			_src = "";
			// If we have content
			if (_content) {
				// Clean up the old listeners
				_content.removeEventListener(HJSEvent.COMPLETE, onLoadComplete);
				_content.removeEventListener(HJSEvent.FAR_ENOUGH, onFarEnough);
				_content.removeEventListener(HJSEvent.IO_ERROR, onLoadError);
				// And clear the content
				_content = null;
			}
		}
		
		/**
		 * Load an ISrcDisplayObject from the requested URL
		 */
		public function load(request:URLRequest):void
		{
			unload();
			
			_src = request.getUrl();
			
			// Based on the content type we create either a new Bitmap or Video
			switch(request.getContentType()) {
				case URLRequest.CONTENTTYPE_VIDEO:
					_content = new Video();
					break;
				case URLRequest.CONTENTTYPE_AUDIO:
					_content = new Audio();
					break;
				case URLRequest.CONTENTTYPE_IMAGE:
				default:
					_content = new Bitmap();
					break;
			}
			
			// Must be added to DOM before loading in order for mobile to load video
			addChild(_content);
			
			// Listener for the complete event
			_content.addEventListener(HJSEvent.COMPLETE, onLoadComplete);
			_content.addEventListener(HJSEvent.FAR_ENOUGH, onFarEnough);
			_content.addEventListener(HJSEvent.IO_ERROR, onLoadError);
			
			// And start loading
			(_content as ISrcDisplayObject).setSrc(_src);
		}
		
		/**
		 * Unload the current content and close the loader
		 */
		public function unload():void
		{
			close();
		}
		
		/**
		 * Handle load completion and send the appropriate events.
		 */
		protected function onLoadComplete(aEvent:HJSEvent):void
		{
			if (!_complete) {
				_complete = true;
				onFarEnough(null);
				dispatchEvent(new HJSEvent(HJSEvent.COMPLETE));
			}
		}
		
		protected function onFarEnough(aEvent:HJSEvent):void
		{
			if (!_farEnough) {
				_farEnough = true;
				dispatchEvent(new HJSEvent(HJSEvent.FAR_ENOUGH));
			}
		}
		
		protected function onLoadError(aEvent:HJSEvent):void
		{
			dispatchEvent(new HJSEvent(HJSEvent.IO_ERROR));
		}
	}
}