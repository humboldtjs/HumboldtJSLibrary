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
	import com.humboldtjs.events.HJSEvent;
	import com.humboldtjs.system.Convert;
	
	import dom.document;
	
	/**
	 * A simple bitmap class which loads and displays an image from a URL
	 *
	 * This class is wrapped by the Loader class which will give you a bit more
	 * feedback about how the loading is going, and as a final result will
	 * return a Bitmap object. 
	 */
	public class Bitmap extends DisplayObject implements ISrcDisplayObject
	{
		protected var _unscaledWidth:Number = 0;
		protected var _unscaledHeight:Number = 0;
		
		/**
		 * The unscaled width of the bitmap.
		 */
		override public function getUnscaledWidth():Number { return _unscaledWidth; }
		/**
		 * The unscaled height of the bitmap.
		 */
		override public function getUnscaledHeight():Number { return _unscaledHeight; }
		
		/**
		 * The source URL of the bitmap.
		 */
		public function getSrc():String					{ return _element.src; }
		/**
		 * The source URL of the bitmap.
		 */
		public function setSrc(value:String):void
		{
			_element.src = value;
			if (_element.complete)
				onLoadComplete();
		}
		
		/**
		 * @constructor
		 */
		public function Bitmap()
		{
			super();
			
			_element.onload = onLoadComplete;
			_element.onerror = onLoadError;
			_element.onabort = onLoadError;
		}
		
		override protected function initializeElement():void
		{
			_element = document.createElement("img");
		}
		
		/**
		 * Return a copy of the Bitmap with the same contents
		 */
		public function clone():ISrcDisplayObject
		{
			var theBitmap:Bitmap = new Bitmap();
			theBitmap._unscaledWidth = _unscaledWidth;
			theBitmap._unscaledHeight = _unscaledHeight;
			theBitmap.setSrc(getSrc());
			
			return theBitmap;
		}
		
		/**
		 * Called when loading of the bitmap has completed
		 */
		protected function onLoadComplete():void
		{
			if (_element["naturalWidth"]) {
				
				_unscaledWidth = _element.naturalWidth;
				_unscaledHeight = _element.naturalHeight;

			} else {
				
				// When IE has failed loading this image once before it
				// will use a 28x30 image-not-found-placeholder. This is
				// workaround for a bug where when requesting unscaled
				// size it will use this 28x30 from the cache instead.
				// Setting style to auto forces recalculation.
				_element.style.width = "auto";
				_element.style.height = "auto";
				
				document.body.appendChild(_element);
				if (_unscaledWidth == 0)
					_unscaledWidth = Convert.toInt(_element.width.toString());
				if (_unscaledHeight == 0)
					_unscaledHeight = Convert.toInt(_element.height.toString());

				document.body.removeChild(_element);
			}
			
			if (_parent)
				_parent.getHtmlElement().appendChild(_element);
			
			dispatchEvent(new HJSEvent(HJSEvent.COMPLETE));
		}
		
		/**
		 * Called when loading threw an error or was aborted for some reason
		 */
		protected function onLoadError():void
		{
			dispatchEvent(new HJSEvent(HJSEvent.IO_ERROR));
		}
	}
}