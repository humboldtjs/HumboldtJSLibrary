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
	import com.humboldtjs.system.Capabilities;
	import com.humboldtjs.system.Logger;
	
	import dom.domobjects.CanvasRenderingContext2D;

	/**
	 * A simple DisplayObject that provides a Canvas and 2D context.
	 */
	public class Canvas extends DisplayObject
	{
		/**
		 * The 2D drawing context for this canvas
		 */
		public function getContext2D():CanvasRenderingContext2D
		{
			return mElement.getContext("2d");
		}
		
		/**
		 * Set the width of the Canvas drawing area 
		 */
		override public function setWidth(value:Number):void
		{
			if (mWidth == value) return;
			mWidth = value;
			mElement.width = value.toString();
		}
		
		/**
		 * Set the height of the Canvas drawing area 
		 */
		override public function setHeight(value:Number):void
		{
			if (mHeight == value) return;
			mHeight = value;
			mElement.height = value.toString();
		}
		
		/**
		 * @constructor
		 */
		public function Canvas()
		{
			mElementType = "canvas";
			
			super();
			
			if (!Capabilities.getHasCanvasSupport())
				Logger.error("Canvas tag is being used, but isn't supported by this browser");
			
			// This is only for modern browsers, and will need a different workaround for IE
			// A possible solution can be found at: http://www.vinylfox.com/forwarding-mouse-events-through-layers/
			
			// This is to make Canvas's non-clickable. This is done mainly to allow a convas
			// to draw over other elements and be pretty much ignored. However this may not
			// always be what you want, if so be sure to delete the pointerEvents property
			mElement.style.pointerEvents = "none";
		}
	}
}