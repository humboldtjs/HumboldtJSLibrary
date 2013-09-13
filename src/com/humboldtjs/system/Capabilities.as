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
	import dom.document;
	import dom.domobjects.HTMLElement;
	import dom.navigator;
	import dom.screen;
	import dom.window;

	/**
	 * Utility class to detect environment capabilities.
	 */
	public class Capabilities
	{
		/**
		 * Does the browser have Canvas support? You should use this method
		 * to detect this before using the Canvas class.
		 */
		public static function getHasCanvasSupport():Boolean
		{
			return (document.createElement("canvas")["getContext"] != null);
		}
		
		/**
		 * Does the browser support CSS3 transforms?
		 */
		public static function getHasCSS3TransformSupport():Boolean
		{
			var style:* = document.createElement("div").style;
			return (typeof style.MozTransform !== "undefined" ||
				typeof style.WebkitTransform !== "undefined" ||
				typeof style.msTransform !== "undefined" ||
				typeof style.OTransform !== "undefined" ||
				typeof style.transform !== "undefined");
		}
		
		/**
		 * Does the browser have a Retina display? You should use this method
		 * to detect whether to use pixel-doubled images or not.
		 */
		public static function getHasRetinaSupport():Boolean
		{
			if (typeof window["devicePixelRatio"] !== "undefined") {
				return window["devicePixelRatio"] > 1;
			}
			return false;
		}
		
		/**
		 * Does the browser support fullscreen mode? You should use this method
		 * to detect this before setting fullscreen on an Application instance.
		 */
		public static function getHasFullScreen():Boolean
		{
			if (HtmlUtils.getPropertyFromListWithVendor(document.body, ["requestFullscreen", "requestFullScreen"]) !== null) {
				return true;
			}
			return false;
		}
		
		/**
		 * Whether the device is a touch-based device.
		 */
		public static function getHasTouchscreen():Boolean
		{
			return (navigator.userAgent.indexOf("iPhone") != -1 || 
				navigator.userAgent.indexOf("iPod") != -1 || 
				navigator.userAgent.indexOf("iPad") != -1 ||
				navigator.userAgent.indexOf("Android") != -1);
		}
		
		/**
		 * Whether the Audio tag is supported. Note that this doesn't tell
		 * you whether a certain codec is supported or if there are any
		 * platform specific quirks you still have to deal with.
		 */
		public static function getHasAudio():Boolean
		{
			return document.createElement("audio")["src"] !== undefined;
		}
		
		/**
		 * Whether the Video tag is supported. Note that this doesn't tell
		 * you whether a certain codec is supported or if there are any
		 * platform specific quirks you still have to deal with.
		 */
		public static function getHasVideo():Boolean
		{
			return document.createElement("video")["src"] !== undefined;
		}
		
		/**
		 * Whether video with the mimetype video/mp4 can be decoded by the
		 * browser. This requires Video tag support to be available.
		 */
		public static function getHasMp4():Boolean
		{
			return videoMimeSupported("video/mp4");
		}
		
		/**
		 * Whether video with the mimetype video/webm can be decoded by the
		 * browser. This requires Video tag support to be available.
		 */
		public static function getHasWebm():Boolean
		{
			return videoMimeSupported("video/webm");
		}
		
		/**
		 * Get a user's prefered language. This should normally be the same
		 * language as the browser or OS. If this language could not be
		 * determined will return a default of "en-us". 
		 */
		public static function getLanguage():String
		{
			return (navigator["language"] === undefined) ? "en-us" : navigator["language"];
		}
		
		/**
		 * Returns the Operating System a user is using. Valid return values
		 * are:
		 * 
		 * iOS
		 * Android
		 * Windows
		 * Macintosh
		 * Linux
		 * UNIX
		 */
		public static function getOs():String
		{
			if (navigator.userAgent.indexOf("iPhone") != -1) return OperatingSystem.IOS; 
			if (navigator.userAgent.indexOf("iPod") != -1) return OperatingSystem.IOS; 
			if (navigator.userAgent.indexOf("iPad") != -1) return OperatingSystem.IOS; 
			if (navigator.userAgent.indexOf("Android") != -1) return OperatingSystem.ANDROID; 
			if (navigator.appVersion.indexOf("Win") != -1) return OperatingSystem.WINDOWS;
			if (navigator.appVersion.indexOf("Mac") != -1) return OperatingSystem.MAC;
			if (navigator.appVersion.indexOf("Linux") != -1) return OperatingSystem.LINUX;
			if (navigator.appVersion.indexOf("X11") != -1) return OperatingSystem.UNKNOWN_UNIX;
			
			return OperatingSystem.UNKNOWN;
		}
		
		/**
		 * Get a manufacturer ID. This is provided purely for compatibility with
		 * flash (which would return the OS prepended with "Flash ").
		 */
		public static function getManufacturer():String
		{
			return "HumboldtJS " + getOs();
		}
		
		/**
		 * The total screen width.
		 */
		public static function getScreenResolutionX():Number
		{
			return getOs() == OperatingSystem.IOS ? screen.height : screen.width;
		}
		
		/**
		 * The total screen height.
		 */
		public static function getScreenResolutionY():Number
		{
			return getOs() == OperatingSystem.IOS ? screen.width : screen.height;	
		}
		
		/**
		 * The available screen width, without taskbars, menus, etc.
		 */
		public static function getScreenAvailableX():Number
		{
			return screen.availWidth;	
		}
		
		/**
		 * The available screen height, without taskbars, menus, etc.
		 */
		public static function getScreenAvailableY():Number
		{
			return screen.availHeight;
		}
		
		/**
		 * The pixel-aspect-ratio. This should be 1.0 if a pixel is square.
		 * There is a known case when using a resolution of 1280x1024 where
		 * pixels are non-square. This can be used to adjust for that.
		 */
		public static function getPixelAspectRatio():Number
		{
			return (getScreenResolutionX() == 1280 && getScreenResolutionY() == 1024) ? 0.9375 : 1;
		}
		
		/**
		 * Returns the version of HumboldtJS used to compile the application.
		 */
		public static function getVersion():String
		{
			return window["__humboldtjs"]["version"];
		}
		
		/**
		 * Detect whether video with a certain mime type is supported. Is used
		 * to detect mp4 or webm support, but can also be used for other
		 * formats.
		 * 
		 * @param aMime The mime-type to check for 
		 */
		public static function videoMimeSupported(aMime:String):Boolean
		{
			var theCanPlay:Boolean = false;
			var theVideo:HTMLElement = document.createElement("video");
			if (theVideo["canPlayType"] && theVideo["canPlayType"](aMime).replace(/no/, ''))
				theCanPlay = true;
			
			return theCanPlay;
		}
	}
}