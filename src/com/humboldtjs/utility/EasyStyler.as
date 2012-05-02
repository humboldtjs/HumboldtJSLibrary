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
	import dom.domobjects.HTMLElement;

	/**
	 * A utility class which makes it easy to style HTML elements. You can
	 * register styles using names and then easily apply them to HTML elements
	 * very similarly to CSS. The benefits of having it in code are that if
	 * your application runs in a page over which you have no direct control
	 * managing styles this way is easier.
	 * 
	 * In addition it manages dealing with some browser differences and
	 * vendor prefixes.
	 */
	public class EasyStyler
	{
		protected static var mInstance:EasyStyler;

		protected var mStyles:Object;
		
		/**
		 * Apply a previously registered style to an HTML element
		 * 
		 * @param aElement The HTML element to apply the style properties to
		 * @param aStyleName The string name of the registered style to apply
		 */
		public static function applyStyle(aElement:HTMLElement, aStyleName:String):void
		{
			applyStyleObject(aElement, getInstance().mStyles[aStyleName]);
		}

		/**
		 * Apply a set of style properties according to a style object definition.
		 * The style object is an Object where its indices are CSS style
		 * properties using the JavaScript notations. When prefixed with a "-"
		 * vendor prefixes for all major browser vendors are automatically
		 * prefixed. This is useful for easily using experimental CSS3 properties.
		 * 
		 * @param aElement The HTML element to apply the style properties to
		 * @param aStyleObject The object containing the style properties to apply
		 */
		public static function applyStyleObject(aElement:HTMLElement, aStyleObject:Object):void
		{
			if (aStyleObject) {
				var theKey:String = "";
				for (theKey in aStyleObject) {
					var theValue:* = aStyleObject[theKey];
					if (theKey.substr(0, 1) == "-") {
						theKey = theKey.substr(1);
						var theUCName:String = theKey.substr(0, 1).toUpperCase() + theKey.substr(1); 
						aElement.style["Webkit" + theUCName] = theValue;
						aElement.style["Ms" + theUCName] = theValue;
						aElement.style["Moz" + theUCName] = theValue;
						aElement.style["O" + theUCName] = theValue;
					}
					if (theKey == "opacity") {
						if (theValue == 1) {
							aElement.style["filter"] = null;
							aElement.style[theKey] = null;
							try {
								delete aElement.style["filter"];
								delete aElement.style[theKey];
							} catch (e:Error) {
								// If this fails it is because IE doesn't allow
								// us to delete properties.
							}
						} else {
							aElement.style[theKey] = theValue;
							aElement.style["filter"] = 'alpha(opacity=' + theValue * 100 + ')';
						}
						if (theValue == 0) {
							aElement.style.display = "none";
						} else {
							aElement.style.display = "block";
						}
					} else {
						aElement.style[theKey] = theValue;
					}
				}
			}
		}
			
		/**
		 * Retrieve the instance of the EasyStyler that maintains the list of
		 * style definitions.
		 */
		protected static function getInstance():EasyStyler
		{
			if (mInstance) {
				return mInstance;
			}
			
			mInstance = new EasyStyler();
			return mInstance;
		}
		
		/**
		 * Register a new object style definition under a name. This allows
		 * you to quickly apply stylesets that are used multiple times within
		 * an application similar to CSS.
		 * The style object is an Object where its indices are CSS style
		 * properties using the JavaScript notations. When prefixed with a "-"
		 * vendor prefixes for all major browser vendors are automatically
		 * prefixed. This is useful for easily using experimental CSS3 properties.
		 * 
		 * @param aElement The HTML element to apply the style properties to
		 * @param aStyleObject The object containing the style properties to apply
		 */
		public static function defineStyle(aStyleName:String, aValues:Object):void
		{
			getInstance().mStyles[aStyleName] = aValues;
		}
		
		/**
		 * @constructor
		 */
		public function EasyStyler()
		{
			mStyles = {};
		}
	}
}