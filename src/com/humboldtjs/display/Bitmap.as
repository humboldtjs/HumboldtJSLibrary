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
	
	import dom.eventFunction;

	/**
	 * A simple bitmap class which loads and displays an image from a URL
	 *
	 * This class is wrapped by the Loader class which will give you a bit more
	 * feedback about how the loading is going, and as a final result will
	 * return a Bitmap object. 
	 */
	public class Bitmap extends DisplayObject implements ISrcDisplayObject
	{
		protected var mUnscaledWidth:Number = 0;
		protected var mUnscaledHeight:Number = 0;
		
		/**
		 * The unscaled width of the bitmap.
		 */
		override public function getUnscaledWidth():Number { return mUnscaledWidth; }
		/**
		 * The unscaled height of the bitmap.
		 */
		override public function getUnscaledHeight():Number { return mUnscaledHeight; }
		
		/**
		 * The source URL of the bitmap.
		 */
		public function getSrc():String					{ return mElement.src; }
		/**
		 * The source URL of the bitmap.
		 */
		public function setSrc(value:String):void
		{
			mElement.src = value;
			if (mElement.complete)
				onLoadComplete();
		}
		
		/**
		 * @constructor
		 */
		public function Bitmap()
		{
			mElementType = "img";
			
			super();
			
			mElement.onload = eventFunction(this, onLoadComplete);
			mElement.onerror = eventFunction(this, onLoadError);
			mElement.onabort = eventFunction(this, onLoadError);
		}
		
		/**
		 * Return a copy of the Bitmap with the same contents
		 */
		public function clone():ISrcDisplayObject
		{
			var theBitmap:Bitmap = new Bitmap();
			theBitmap.setSrc(getSrc());
			
			return theBitmap;
		}
		
		/**
		 * Called when loading of the bitmap has completed
		 */
		protected function onLoadComplete():void
		{
			if (mUnscaledWidth == 0)
				mUnscaledWidth = Convert.toInt(mElement.width.toString());
			if (mUnscaledHeight == 0)
				mUnscaledHeight = Convert.toInt(mElement.height.toString());
			
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