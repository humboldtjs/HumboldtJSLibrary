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
	import dom.window;

	/**
	 * A class that functionally simulates the Flash stage. It provides an
	 * EnterFrame timer loop which can be used for animation, and allows you
	 * to control framerate 
	 */
	public class Stage extends DisplayObject
	{
		protected static const MAX_DELAY:Number = 1000;
		
		protected static var _stage:Stage;
		
		protected var _frameRate:Number = 25;
		protected var _frameDelay:Number = 40; // 1000 / 25
		protected var _hasFrameListener:Boolean = false; 
		protected var _requestAnimationFrame:String;
		
		/**
		 * Get's access to the application stage object
		 */
		public static function getInstance():Stage
		{
			if (_stage)
				return _stage;
			
			_stage = new Stage();
			return _stage;
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
			if (_requestAnimationFrame != "") return 60;
			return _frameRate;
		}
		
		/**
		 * The current framerate
		 */
		public function setFrameRate(value:Number):void
		{
			_frameRate = value;
			_frameDelay = 1000 / _frameRate;
		}
		
		/**
		 * @constructor
		 */
		public function Stage()
		{
			super();
			
			_element = document.body;
		
			_requestAnimationFrame = "";
			
			var theFunctions:Array = new Array("requestAnimationFrame", "webkitRequestAnimationFrame", "mozRequestAnimationFrame", "oRequestAnimationFrame", "msRequestAnimationFrame");
			for (var i:int = 0; i < theFunctions.length; i++) {
				if (window[theFunctions[i]] != null && _requestAnimationFrame == "") {
					_requestAnimationFrame = theFunctions[i];
				}
			}

			// start the frame loop
			doFrameLoop();
			kickRequestAnimationFrame();
		}
		
		/**
		 * To make sure the frame loop doesn't cost more overhead than strictly
		 * needed we cache whether there are actually any listeners for
		 * ENTER_FRAME, otherwise we skip all kinds of processing.
		 */
		override public function addEventListener(aType:String, aFunction:Function):void
		{
			if (aType == HJSEvent.ENTER_FRAME)
				_hasFrameListener = true;
			
			super.addEventListener(aType, aFunction);
		}
		
		/**
		 * To make sure the frame loop doesn't cost more overhead than strictly
		 * needed we cache whether there are actually any listeners for
		 * ENTER_FRAME, otherwise we skip all kinds of processing.
		 */
		override public function removeEventListener(aType:String, aFunction:Function):void
		{
			super.removeEventListener(aType, aFunction);
			
			if (aType == HJSEvent.ENTER_FRAME && !hasEventListener(HJSEvent.ENTER_FRAME))
				_hasFrameListener = false;
		}
		
		/**
		 * Process the current frame, and dispatch ENTER_FRAME events if needed
		 */
		protected function doFrameLoop():void
		{
			if (_hasFrameListener)
				dispatchEvent(new HJSEvent(HJSEvent.ENTER_FRAME));
			
			if (_requestAnimationFrame == "") {
				window.setTimeout(doFrameLoop, _frameDelay);
			} else {
				window[_requestAnimationFrame](doFrameLoop);
			}
		}
		
		protected function kickRequestAnimationFrame():void
		{
			if (_requestAnimationFrame != "") {
				window.setTimeout(kickRequestAnimationFrame, MAX_DELAY);
				window[_requestAnimationFrame](doNothing);
			}
		}
		
		protected function doNothing():void
		{
		}
	}
}