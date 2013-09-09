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
	import dom.document;
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
		
		protected static var mFontEmbedStyleSheet:HTMLElement;
		protected static var mFontEmbedList:Vector.<String>;

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
		
		protected static function addFontEmbed(theValue:String):void
		{
			if (mFontEmbedList == null) {
				mFontEmbedList = new Vector.<String>();
			}
			if (mFontEmbedStyleSheet == null) {
				mFontEmbedStyleSheet = document.createElement("style");
				document.getElementsByTagName("head")[0].appendChild(mFontEmbedStyleSheet);
			}
			
			if (mFontEmbedList.indexOf(theValue) == -1) {
				mFontEmbedList.push(theValue);
			}
			
			updateFontEmbedStyleSheet();
		}
		
		protected static function updateFontEmbedStyleSheet():void
		{
			var theStyleSheet:String = "";
			for (var i:int = 0; i < mFontEmbedList.length; i++) {
				var theFont:String = mFontEmbedList[i];
				theStyleSheet += "@font-face {\n" +
					"\tfont-family:'" + theFont.substr(theFont.lastIndexOf("/") + 1) + "';\n" +
					"\tsrc:url('" + theFont + ".eot');\n" +
					"\tsrc:url('" + theFont + ".eot?#iefix') format('embedded-opentype'),\n" +
					"\turl('" + theFont + ".woff') format('woff'),\n" +
					"\turl('" + theFont + ".ttf') format('truetype'),\n" +
					"\turl('" + theFont + ".svg#" + theFont + "') format('svg');\n" +
					"\tfont-weight: normal;\n" +
					"\tfont-style: normal;\n" +
					"}";
			}
			
			mFontEmbedStyleSheet.innerHTML = theStyleSheet;
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
						aElement.style["ms" + theUCName] = theValue;
						aElement.style["Moz" + theUCName] = theValue;
						aElement.style["O" + theUCName] = theValue;
					}
					if (theKey == "fontEmbed") {
						addFontEmbed(theValue);
					} else if (theKey == "opacity" || theKey == "autoOpacity" || theKey == "alpha" || theKey == "autoAlpha") {
						if (theValue == 1) {
							aElement.style["filter"] = null;
							aElement.style["opacity"] = null;
							try {
								delete aElement.style["filter"];
								delete aElement.style["opacity"];
							} catch (e:Error) {
								// If this fails it is because IE doesn't allow
								// us to delete properties.
							}
						} else {
							aElement.style["opacity"] = theValue;
							aElement.style["filter"] = 'alpha(opacity=' + theValue * 100 + ')';
						}
						if (theKey == "autoOpacity" || theKey == "autoAlpha") {
							if (theValue == 0) {
								aElement.style.display = "none";
							} else {
								aElement.style.display = "block";
							}
						}
					} else {
						try {
							aElement.style[theKey] = theValue;
						} catch (e:Error) {
							// Try catch because IE throws an error if a value
							// is entered that it thinks is invalid 
						}
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