/*
* HumboldtJSLibrary
* http://humboldtjs.com/
*
* Copyright (c) 2012 Daniël Haveman
* Licensed under the MIT license
* http://humboldtjs.com/license.html
*/
package com.humboldtjs.system
{
	import com.humboldtjs.display.DisplayObject;
	import com.humboldtjs.display.Stage;
	
	import dom.document;
	import dom.domobjects.Event;
	import dom.domobjects.HTMLElement;
	import dom.eventFunction;
	import dom.navigator;
	import dom.window;
	
	/**
	 * The root of any HumboldtJS application. This class manages adding the
	 * app to the DOM
	 */
	public class Application extends DisplayObject
	{
		protected var mApplicationRoot:HTMLElement;
		protected var mFullScreen:Boolean = false;
		protected var mStage:Stage;
		
		/**
		 * Whether the application should run fullscreen or not. Does not work
		 * in all browsers. Use Capabilities.getHasFullScreen() to test whether
		 * it is supported first
		 * 
		 * @see com.humboldtjs.system.Capabilities
		 */
		public function getFullScreen():Boolean { return mFullScreen; }
		/**
		 * Whether the application should run fullscreen or not. Does not work
		 * in all browsers. Use Capabilities.getHasFullScreen() to test whether
		 * it is supported first
		 * 
		 * @see com.humboldtjs.system.Capabilities
		 */
		public function setFullScreen(value:Boolean):void
		{
			if (mFullScreen != value) {
				mFullScreen = value;
				
				if (mFullScreen) {

					// if fullscreen is possible first attempt to do it the
					// standards way, otherwise fallback to webkit specific
					// code
					if (Capabilities.getHasFullScreen()) {
						if (document.body["requestFullScreen"])
							document["fullScreenEnabled"]();
						else if (document.body["webkitRequestFullScreen"])
							document.body["webkitRequestFullScreen"]();
					}
					HtmlUtils.addHtmlEventListener(document, "fullscreenchange", eventFunction(this, onFullScreenChange));
					HtmlUtils.addHtmlEventListener(document, "webkitfullscreenchange", eventFunction(this, onFullScreenChange));
				} else {
					if (Capabilities.getHasFullScreen()) {
						if (document["cancelFullScreen"])
							document["cancelFullScreen"]();
						else if (document["webkitCancelFullScreen"])
							document["webkitCancelFullScreen"]();
					}
					onFullScreenChange(null);
				}
			}
		}
		
		/**
		 * Returns a reference to the stage object.
		 * 
		 * @see com.humboldtjs.display.Stage
		 */
		override public function getStage():Stage
		{
			return mStage;
		}

		/**
		 * @constructor
		 */
		public function Application()
		{
			super();
			
			// try to figure out whether we're supposed to add ourselves to
			// a specific parent element or otherwise add to document.body
			if (window["__humboldtjs"].appId != -1) {
				mApplicationRoot = document.getElementById(window["__humboldtjs"].appId);
			} else {
				mApplicationRoot = document.body;
			}
			
			// make sure we have a stage object
			mStage = Stage.getInstance();
			
			// some default styling - make the app fit to the size of its
			// container, but clip everything that extends beyond it
			mElement.style.overflow = "hidden";
			mElement.style.width = "100%";
			mElement.style.height = "100%";
			
			// if the DOM is accessible then continue initialization, otherwise
			// wait for the DOM load event
			if (document.body) {
				_initialize(null);
			} else {
				HtmlUtils.addHtmlEventListener(window, "load", eventFunction(this, _initialize));
			}
		}
		
		/**
		 * DOM is accessible, so now we can continue setting up our application
		 */
		protected function _initialize(aEvent:Event):void
		{
			if (HtmlUtils.hasHtmlEventListener(document.body, "load"))
				HtmlUtils.removeHtmlEventListener(window, "load", eventFunction(this, _initialize));
			
			// add a listener to the resize event this is used on mobile devices
			// to re-hide the browser-chrome after a rotation occurred
			HtmlUtils.addHtmlEventListener(window, "resize", eventFunction(this, onResize));
			onResize(null);
			
			initialize();
		}
		
		/**
		 * On mobile devices whenever the screen resizes we make sure we hide
		 * the browser chrome again
		 */
		protected function onResize(aEvent:Event):void
		{
			var isIpad:Boolean = navigator.userAgent.indexOf("iPad") != -1;
			var isFullScreen:Boolean = navigator["standalone"];
			
			// Start out by adding the height of the location bar to the width, so that
			// we can scroll past it
			if (Capabilities.getOs() == OperatingSystem.IOS) {
				// iOS reliably returns the innerWindow size for documentElement.clientHeight
				// but window.innerHeight is sometimes the wrong value after rotating
				// the orientation
				var theHeight:int = document.documentElement.clientHeight;
				
				// Only add extra padding to the height on iphone / ipod, since the ipad
				// browser doesn't scroll off the location bar.
				// And don't do it when running fullscreen (when run as a web app).
				if (!isIpad && !isFullScreen) theHeight += 60;
				
				setHeight(theHeight);
				window.scrollTo(0, 1);
			} else if (Capabilities.getOs() == OperatingSystem.ANDROID) {
				// The stock Android browser has a location bar height of 56 pixels, but
				// this very likely could be broken in other Android browsers.
				setHeight(window.innerHeight + 56);
				window.scrollTo(0, 1);
			}
		}
		
		/**
		 * Initialize the application and add it to the DOM. This is the typical
		 * entry point your application should override to provide its own
		 * functionality.
		 */
		protected function initialize():void
		{
			mApplicationRoot.appendChild(mElement);
		}

		/**
		 * When we return from fullscreen mode this method takes care of
		 * cleanup. It also triggers a window resize event because this does
		 * not happen automatically even though the size DOES change.
		 */
		protected function onFullScreenChange(aEvent:Event):void
		{
			if (document["webkitIsFullScreen"] || document["fullscreen"])
				return;
			
			HtmlUtils.removeHtmlEventListener(document, "fullscreenchange", eventFunction(this, onFullScreenChange));
			HtmlUtils.removeHtmlEventListener(document, "webkitfullscreenchange", eventFunction(this, onFullScreenChange));
			mFullScreen = false;
			
			// trigger a resize event because the browser will not always trigger this 
			// event correctly when returning from fullscreen
			if (document["createEvent"]) {
				var theEvent:Event = document["createEvent"]('HTMLEvents');
				theEvent["initEvent"]("resize", true, false);
				window.dispatchEvent(theEvent);
			} else if (window["createEventObject"]) {
				window["fireEvent"]("onresize");
			}
		}
	}
}