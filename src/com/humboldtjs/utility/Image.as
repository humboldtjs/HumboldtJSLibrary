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
		protected var _content:DisplayObject;
		protected var _contentWidth:int;
		protected var _contentHeight:int;
		protected var _bitmapCache:Canvas;
		
		protected var _loader:Loader;
		protected var _timer:int = -1;
		
		protected var _source:String = "";
		
		/**
		 * The source URL of the image to display
		 */
		public function getSource():String { return _source; }
		/**
		 * The source URL of the image to display
		 */
		public function setSource(value:String):void
		{
			if (_source != value) {
				// If a timer was running make sure to cancel it
				if (_timer != -1) {
					window.clearTimeout(_timer);
					_timer = -1;
				}
				
				_source = value;
				
				// Remove the old image
				removeChild(_content);
				_content = null;
				_contentWidth = 0;
				_contentHeight = 0;
				
				// And cancel the old loader
				_loader.close();
				
				// And finally load the new image
				_loader.load(new URLRequest(_source));
			} else {
				// If the value was the same and it was already loaded we
				// dispatch another HJSEvent.COMPLETE to notify any listening
				// component
				if (_contentWidth != 0 && _contentHeight != 0)
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
				_bitmapCache = new Canvas();
				_bitmapCache.setWidth(100);
				_bitmapCache.setHeight(100);
				addChild(_bitmapCache);
			} else {
				_bitmapCache = null;
			}
			
			setPercentWidth(100);
			setPercentHeight(100);
			
			// Listening for element resizes is very unreliable, so we listen
			// for window resizes, since they are propably what will trigger the
			// element resize anyway.
			HtmlUtils.addHtmlEventListener(window, "resize", onResize);
			
			_content = null;
			
			_loader = new Loader();
			_loader.addEventListener(HJSEvent.COMPLETE, onLoadComplete);
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
			if (_element.clientWidth == 0 || _element.clientHeight == 0) {
				window.setTimeout(onResize, 100);
				return;
			}
			
			if (_content != null) {

				// Let's scale to fill using the ScaleUtility
				var theScale:Number = ScaleUtility.calculateScaleFor(_contentWidth, _contentHeight, _element.clientWidth, _element.clientHeight, ScaleUtility.SCALE_FILL);
				
				if (_bitmapCache != null) {
					// If we have a bitmap cache (meaning we have Canvas support)
					// set it to the new size, and update the image
					_bitmapCache.setWidth(_element.clientWidth);
					_bitmapCache.setHeight(_element.clientHeight);
					_content.setX(-3000);
					_content.setY(-3000);
					
					var theContext:CanvasRenderingContext2D = _bitmapCache.getContext2D();
					theContext.drawImage(_content.getHtmlElement(), 0, 0, _contentWidth, _contentHeight, ((_element.clientWidth - _contentWidth * theScale) / 2), ((_element.clientHeight - _contentHeight * theScale) / 2), _contentWidth * theScale, _contentHeight * theScale);
					_content.getHtmlElement().style.display = "none";
				} else {
					// Otherwise just put the image in the right position at
					// the right size (will be slower though)
					_content.setWidth(_contentWidth * theScale);
					_content.setHeight(_contentHeight * theScale);
					_content.setX((_element.clientWidth - _contentWidth * theScale) / 2);
					_content.setY((_element.clientHeight - _contentHeight * theScale) / 2);
				}
			}
		}
		
		/**
		 * Called when loading is complete
		 */
		protected function onLoadComplete(aEvent:HJSEvent):void
		{
			// Put the loaded content on the screen
			_content = _loader.getContent();
			addChild(_content);

			if (_bitmapCache)
				addChild(_bitmapCache); // make sure the bitmapcache is above the image
			
			// Store the original size. This is used later when calculating
			// the scale to fill
			_contentWidth = _content.getHtmlElement().clientWidth;
			_contentHeight = _content.getHtmlElement().clientHeight;
			
			// If for whatever reason the size isn't available yet (can sometimes
			// happen when the load has completed but the DOM hasn't been recalculated
			// properly yet) we'll try again until it is.
			if (_contentWidth == 0 || _contentHeight == 0) {
				_timer = window.setTimeout(onLoadComplete, 100);
				return;
			}
			_timer = -1;

			// Re-layout the component now that everything is done
			onResize(null);
			
			dispatchEvent(new HJSEvent(HJSEvent.COMPLETE));
		}
	}
}