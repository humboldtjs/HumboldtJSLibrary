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
	import com.humboldtjs.display.Canvas;
	import com.humboldtjs.display.DisplayObject;
	import com.humboldtjs.display.Loader;
	import com.humboldtjs.events.HJSEvent;
	import com.humboldtjs.net.URLRequest;
	import com.humboldtjs.system.Capabilities;
	import com.humboldtjs.system.HtmlUtils;
	
	import dom.domobjects.CanvasRenderingContext2D;
	import dom.domobjects.Event;
	import dom.window;
	
	/**
	 * An Image display component which scales its content to fit. It uses
	 * a Canvas to cache its contents for performance if Canvas support is
	 * available in the browser.
	 */
	public class Image extends DisplayObject
	{
		protected var mContent:DisplayObject;
		protected var mContentWidth:int;
		protected var mContentHeight:int;
		protected var mBitmapCache:Canvas;
		
		protected var mLoader:Loader;
		protected var mTimer:int = -1;
		
		protected var mSource:String = "";
		
		/**
		 * The source URL of the image to display
		 */
		public function getSource():String { return mSource; }
		/**
		 * The source URL of the image to display
		 */
		public function setSource(value:String):void
		{
			if (mSource != value) {
				// If a timer was running make sure to cancel it
				if (mTimer != -1) {
					window.clearTimeout(mTimer);
					mTimer = -1;
				}
				
				mSource = value;
				
				// Remove the old image
				removeChild(mContent);
				mContent = null;
				mContentWidth = 0;
				mContentHeight = 0;
				
				// And cancel the old loader
				mLoader.close();
				
				// And finally load the new image
				mLoader.load(new URLRequest(mSource));
			} else {
				// If the value was the same and it was already loaded we
				// dispatch another HJSEvent.COMPLETE to notify any listening
				// component
				if (mContentWidth != 0 && mContentHeight != 0)
					dispatchEvent(new HJSEvent(HJSEvent.COMPLETE));
			}
		}
		
		/**
		 * @constructor
		 */
		public function Image()
		{
			super();
			
			// If we have Canvas support we'll create a bitmap cache to draw
			// the image to. Doing anything with scaled images is extremely
			// slow, so we draw to an unscaled canvas and hide the image itself
			// which makes everything super fast again.
			if (Capabilities.getHasCanvasSupport()) {
				mBitmapCache = new Canvas();
				mBitmapCache.setWidth(100);
				mBitmapCache.setHeight(100);
				addChild(mBitmapCache);
			} else {
				mBitmapCache = null;
			}
			
			setPercentWidth(100);
			setPercentHeight(100);
			
			// Listening for element resizes is very unreliable, so we listen
			// for window resizes, since they are propably what will trigger the
			// element resize anyway.
			HtmlUtils.addHtmlEventListener(window, "resize", onResize);
			
			mContent = null;
			
			mLoader = new Loader();
			mLoader.addEventListener(HJSEvent.COMPLETE, onLoadComplete);
		}
		
		/**
		 * When the window resizes, this probably means the element resized as
		 * well. When this happens we'll re-layout our component, and if needed
		 * updated the Canvas cache.
		 */
		protected function onResize(aEvent:Event):void
		{
			// If we don't have a size yet, we'll just delay processing until
			// we do
			if (mElement.clientWidth == 0 || mElement.clientHeight == 0) {
				window.setTimeout(onResize, 100);
				return;
			}
			
			if (mContent != null) {

				// Let's scale to fill using the ScaleUtility
				var theScale:Number = ScaleUtility.calculateScaleFor(mContentWidth, mContentHeight, mElement.clientWidth, mElement.clientHeight, ScaleUtility.SCALE_FILL);
				
				if (mBitmapCache != null) {
					// If we have a bitmap cache (meaning we have Canvas support)
					// set it to the new size, and update the image
					mBitmapCache.setWidth(mElement.clientWidth);
					mBitmapCache.setHeight(mElement.clientHeight);
					mContent.setX(-3000);
					mContent.setY(-3000);
					
					var theContext:CanvasRenderingContext2D = mBitmapCache.getContext2D();
					theContext.drawImage(mContent.getHtmlElement(), 0, 0, mContentWidth, mContentHeight, ((mElement.clientWidth - mContentWidth * theScale) / 2), ((mElement.clientHeight - mContentHeight * theScale) / 2), mContentWidth * theScale, mContentHeight * theScale);
					mContent.getHtmlElement().style.display = "none";
				} else {
					// Otherwise just put the image in the right position at
					// the right size (will be slower though)
					mContent.setWidth(mContentWidth * theScale);
					mContent.setHeight(mContentHeight * theScale);
					mContent.setX((mElement.clientWidth - mContentWidth * theScale) / 2);
					mContent.setY((mElement.clientHeight - mContentHeight * theScale) / 2);
				}
			}
		}
		
		/**
		 * Called when loading is complete
		 */
		protected function onLoadComplete(aEvent:HJSEvent):void
		{
			// Put the loaded content on the screen
			mContent = mLoader.getContent();
			addChild(mContent);

			if (mBitmapCache)
				addChild(mBitmapCache); // make sure the bitmapcache is above the image
			
			// Store the original size. This is used later when calculating
			// the scale to fill
			mContentWidth = mContent.getHtmlElement().clientWidth;
			mContentHeight = mContent.getHtmlElement().clientHeight;
			
			// If for whatever reason the size isn't available yet (can sometimes
			// happen when the load has completed but the DOM hasn't been recalculated
			// properly yet) we'll try again until it is.
			if (mContentWidth == 0 || mContentHeight == 0) {
				mTimer = window.setTimeout(onLoadComplete, 100);
				return;
			}
			mTimer = -1;

			// Re-layout the component now that everything is done
			onResize(null);
			
			dispatchEvent(new HJSEvent(HJSEvent.COMPLETE));
		}
	}
}