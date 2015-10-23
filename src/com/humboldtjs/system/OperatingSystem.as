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
	import dom.navigator;
	import dom.window;

	public class OperatingSystem
	{
		public static const IOS:String = "iOS";
		public static const ANDROID:String = "Android";
		public static const WINDOWS:String = "Windows";
		public static const MAC:String = "Macintosh";
		public static const LINUX:String = "Linux";
		public static const UNKNOWN_UNIX:String = "UNIX";
		public static const UNKNOWN:String = "Unknown OS";
		
		public function OperatingSystem()
		{
		}
		
		public static function getInternetExplorerVersion():int
		{ 
			// Returns the version of Internet Explorer or a -1
			// (indicating the use of another browser)
			var rv:int = -1; // Return value assumes failure.
			if (window.navigator.appName == 'Microsoft Internet Explorer')
			{
				var ua:String = navigator.userAgent;
				var re:RegExp = new RegExp("MSIE ([0-9]{1,}[\.0-9]{0,})");
				if (re.exec(ua) != null)
					rv = parseFloat( RegExp["$1"] );
			}
			return rv;
		}
	}
}