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
		protected static var _instance:EasyStyler;
		
		protected static var _fontEmbedStyleSheet:HTMLElement;
		protected static var _fontEmbedList:Vector.<String>;
		protected static var _stylePrefixMap:Object;
		
		protected var _styles:Object;
		
		/**
		 * Apply a previously registered style to an HTML element
		 * 
		 * @param aElement The HTML element to apply the style properties to
		 * @param aStyleName The string name of the registered style to apply
		 */
		public static function applyStyle(aElement:HTMLElement, aStyleName:String):void
		{
			applyStyleObject(aElement, getInstance()._styles[aStyleName]);
		}
		
		protected static function addFontEmbed(theValue:String):void
		{
			if (_fontEmbedList == null) {
				_fontEmbedList = new Vector.<String>();
			}
			if (_fontEmbedStyleSheet == null) {
				_fontEmbedStyleSheet = document.createElement("div");
				_fontEmbedStyleSheet.style.position = "absolute";
				_fontEmbedStyleSheet.style.top = "-3000px";
				document.body.appendChild(_fontEmbedStyleSheet);
			}
			
			if (_fontEmbedList.indexOf(theValue) == -1) {
				_fontEmbedList.push(theValue);
			}
			
			updateFontEmbedStyleSheet();
		}
		
		protected static function updateFontEmbedStyleSheet():void
		{
			var theStyleSheet:String = "";
			for (var i:int = 0; i < _fontEmbedList.length; i++) {
				var theFont:String = _fontEmbedList[i];
				theStyleSheet += "@font-face {\n" +
					"\tfont-family:'" + theFont.substr(theFont.lastIndexOf("/") + 1) + "';\n" +
					"\tsrc:url('" + theFont + ".eot');\n" +
					"\tsrc:url('" + theFont + ".eot?#iefix') format('embedded-opentype'),\n" +
					"\turl('" + theFont + ".woff') format('woff'),\n" +
					"\turl('" + theFont + ".ttf') format('truetype'),\n" +
					"\turl('" + theFont + ".svg#" + theFont.substr(theFont.lastIndexOf("/") + 1) + "') format('svg');\n" +
					"\tfont-weight: normal;\n" +
					"\tfont-style: normal;\n" +
					"}";
			}
			
			_fontEmbedStyleSheet.innerHTML = "<style>"+theStyleSheet+"</style>";
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
			if (aStyleObject && getInstance()) {
				var theKey:String = "";
				for (theKey in aStyleObject) {
					var theValue:* = aStyleObject[theKey];
					if (theKey.substr(0, 1) == "-") {
						theKey = theKey.substr(1);
					}
					if (theKey.indexOf("-") != -1) {
						var theKeyParts:Array = theKey.split("-");
						for (var i:int = 1; i < theKeyParts.length; i++) {
							theKeyParts[i] = theKeyParts[i].substr(0, 1).toUpperCase() + theKeyParts[i].substr(1);
						}
						theKey = theKeyParts.join("");
					}
					if (_stylePrefixMap[theKey]) theKey = _stylePrefixMap[theKey];
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
			if (_instance) {
				return _instance;
			}
			
			_instance = new EasyStyler();
			_instance.initialize();
			return _instance;
		}
		
		protected function initialize():void
		{
			var thePrefixes:Array = ["webkit", "ms", "Moz", "o"];
			EasyStyler._stylePrefixMap = {};
			var theElement:HTMLElement = document.createElement("div");
			
			for (var theKey:String in theElement.style) {
				for (var i:int = 0; i < thePrefixes.length; i++) {
					if (theKey.substr(0, thePrefixes[i].length) == thePrefixes[i]) {
						var theShortKey:String = theKey.substr(thePrefixes[i].length);
						if (theShortKey.substr(0, 1) == theShortKey.substr(0, 1).toUpperCase()) {
							theShortKey = theShortKey.substr(0, 1).toLowerCase() + theShortKey.substr(1);
							if (theElement.style[theShortKey] == undefined) {
								EasyStyler._stylePrefixMap[theShortKey] = theKey;
							}
						}
					}
				}
			}
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
			getInstance()._styles[aStyleName] = aValues;
		}
		
		/**
		 * @constructor
		 */
		public function EasyStyler()
		{
			_styles = {};
		}
	}
}