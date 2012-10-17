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
	
	import dom.document;
	import dom.domobjects.EventFunction;
	import dom.eventFunction;
	import dom.window;

	/**
	 * A class that functionally simulates the Flash stage. It provides an
	 * EnterFrame timer loop which can be used for animation, and allows you
	 * to control framerate 
	 */
	public class Stage extends DisplayObject
	{
		protected static var mStage:Stage;
		
		protected var mFrameRate:Number = 25;
		protected var mFrameDelay:Number = 40; // 1000 / 25
		protected var mHasFrameListener:Boolean = false; 
		
		protected var mRequestAnimationFrame:String;
		
		/**
		 * Get's access to the application stage object
		 */
		public static function getInstance():Stage
		{
			if (mStage)
				return mStage;
			
			mStage = new Stage();
			return mStage;
		}
		
		/**
		 * Try to execute a callback on the next animation frame. This will
		 * either use the native requestAnimationFrame of the browser or will
		 * use a timeout with a duration of 1000ms / target framerate.
		 */
		public function requestAnimationFrame(aCallback:EventFunction):void
		{
			if (mRequestAnimationFrame == "") {
				window.setTimeout(aCallback, mFrameDelay);
			} else {
				window[mRequestAnimationFrame](aCallback);
			}
			
		}
		
		/**
		 * Every DisplayObject has a stage, and Stage inherits from DisplayObject
		 * so this returns itself.
		 */
		override public function getStage():Stage
		{
			return this;
		}
		
		/**
		 * The current framerate
		 */
		public function getFrameRate():Number
		{
			if (mRequestAnimationFrame != "") return 60;
			return mFrameRate;
		}
		
		/**
		 * The current framerate
		 */
		public function setFrameRate(value:Number):void
		{
			mFrameRate = value;
			mFrameDelay = 1000 / mFrameRate;
		}
		
		/**
		 * @constructor
		 */
		public function Stage()
		{
			super();
			
			mElement = document.body;
		
			mRequestAnimationFrame = "";
			
			var theFunctions:Array = new Array("requestAnimationFrame", "webkitRequestAnimationFrame", "mozRequestAnimationFrame", "oRequestAnimationFrame", "msRequestAnimationFrame");
			for (var i:int = 0; i < theFunctions.length; i++) {
				if (window[theFunctions[i]] != null) mRequestAnimationFrame = theFunctions[i];
			}

			// start the frame loop
			doFrameLoop();
		}
		
		/**
		 * To make sure the frame loop doesn't cost more overhead than strictly
		 * needed we cache whether there are actually any listeners for
		 * ENTER_FRAME, otherwise we skip all kinds of processing.
		 */
		override public function addEventListener(aType:String, aFunction:EventFunction):void
		{
			if (aType == HJSEvent.ENTER_FRAME)
				mHasFrameListener = true;
			
			super.addEventListener(aType, aFunction);
		}
		
		/**
		 * To make sure the frame loop doesn't cost more overhead than strictly
		 * needed we cache whether there are actually any listeners for
		 * ENTER_FRAME, otherwise we skip all kinds of processing.
		 */
		override public function removeEventListener(aType:String, aFunction:EventFunction):void
		{
			super.removeEventListener(aType, aFunction);
			
			if (aType == HJSEvent.ENTER_FRAME && !hasEventListener(HJSEvent.ENTER_FRAME))
				mHasFrameListener = false;
		}
		
		/**
		 * Process the current frame, and dispatch ENTER_FRAME events if needed
		 */
		protected function doFrameLoop():void
		{
			if (mHasFrameListener)
				dispatchEvent(new HJSEvent(HJSEvent.ENTER_FRAME));
			
			requestAnimationFrame(eventFunction(this, doFrameLoop));
		}
	}
}