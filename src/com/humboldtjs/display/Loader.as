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
		protected var mContent:DisplayObject;
		protected var mSrc:String = "";
		protected var mComplete:Boolean = false;
		protected var mFarEnough:Boolean = false;
		
		/**
		 * If loading was complete returns the loaded content
		 */
		public function getContent():DisplayObject	{ return (mSrc !== "") ? mContent : null; }
		
		/**
		 * Check if loading has completed
		 */
		public function getComplete():Boolean { return mComplete; }
		
		/**
		 * Check if loading is far enough to use the asset
		 */
		public function getFarEnough():Boolean { return mFarEnough; }
		
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
			mSrc = "";
			// If we have content
			if (mContent) {
				// Clean up the old listeners
				mContent.removeEventListener(HJSEvent.COMPLETE, onLoadComplete);
				mContent.removeEventListener(HJSEvent.FAR_ENOUGH, onFarEnough);
				mContent.removeEventListener(HJSEvent.IO_ERROR, onLoadError);
				// And clear the content
				mContent = null;
			}
		}
		
		/**
		 * Load an ISrcDisplayObject from the requested URL
		 */
		public function load(request:URLRequest):void
		{
			unload();
			
			mSrc = request.getUrl();
			
			// Based on the content type we create either a new Bitmap or Video
			switch(request.getContentType()) {
				case URLRequest.CONTENTTYPE_VIDEO:
					mContent = new Video();
					break;
				case URLRequest.CONTENTTYPE_AUDIO:
					mContent = new Audio();
					break;
				case URLRequest.CONTENTTYPE_IMAGE:
				default:
					mContent = new Bitmap();
					break;
			}
			
			// Must be added to DOM before loading in order for mobile to load video
			addChild(mContent);
			
			// Listener for the complete event
			mContent.addEventListener(HJSEvent.COMPLETE, onLoadComplete);
			mContent.addEventListener(HJSEvent.FAR_ENOUGH, onFarEnough);
			mContent.addEventListener(HJSEvent.IO_ERROR, onLoadError);
			
			// And start loading
			(mContent as ISrcDisplayObject).setSrc(mSrc);
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
			if (!mComplete) {
				mComplete = true;
				onFarEnough(null);
				dispatchEvent(new HJSEvent(HJSEvent.COMPLETE));
			}
		}
		
		protected function onFarEnough(aEvent:HJSEvent):void
		{
			if (!mFarEnough) {
				mFarEnough = true;
				dispatchEvent(new HJSEvent(HJSEvent.FAR_ENOUGH));
			}
		}
		
		protected function onLoadError(aEvent:HJSEvent):void
		{
			dispatchEvent(new HJSEvent(HJSEvent.IO_ERROR));
		}
	}
}