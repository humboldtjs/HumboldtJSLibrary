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
	import com.humboldtjs.geom.Rectangle;
	import com.humboldtjs.geom.Vector3D;
	
	import dom.domobjects.HTMLElement;
	import dom.jsobjects.ActiveXObject;
	import dom.window;
	
	/**
	 * A converter utility class to reliably parse strings into other
	 * types.
	 */
	public class Convert
	{
		public function Convert() {}
		
		/**
		 * Return an untyped value.
		 */
		public static function toUnTyped(aValue:*):*
		{
			return aValue;
		}
		
		/**
		 * Parse a string to an HTMLElement XML document
		 */
		public static function toXML(aValue:String):HTMLElement
		{
			aValue = StringEx.trim(aValue);
			
			if (aValue.indexOf("<?") == 0) {
				aValue = aValue.substr(aValue.indexOf("?>") + 2);
			}
			
			var theXmlDoc:HTMLElement;
			
			// Depending on which browser we either need to use the standard
			// DOMParser or an ActiveXObject (on IE)
			if (window["DOMParser"]) {
				var theParser:Object;
				theParser = new window["DOMParser"]();
				theXmlDoc = theParser.parseFromString(aValue, "text/xml");
			} else {
				theXmlDoc = toUnTyped(new ActiveXObject("Microsoft.XMLDOM"));
				theXmlDoc.async = "false";
				theXmlDoc.loadXML(aValue); 
			}
			
			return theXmlDoc;
		}
		
		/**
		 * Convert the input to a floating point number.
		 */
		public static function toNumber(aValue:String):Number
		{
			aValue = StringEx.trim(aValue);
			aValue = stripLeadingZeros(aValue).split(",").join("");
			aValue = stripTrailingZeros(aValue).split(",").join("");
			if (aValue.substr(aValue.length - 2) == ".0") aValue = aValue.substr(0, aValue.length - 2);
			
			if (parseFloat(aValue).toString() != aValue) 
				return 0;
			else
				return parseFloat(aValue);
		}
		
		/**
		 * Convert the input to a Vector3D. This assumes the input is comma
		 * delimited and used Euler angles in its notation.
		 */
		public static function toEulerAngles3D(aValue:String):Vector3D
		{
			var theParameters:Array = toArray(aValue);
			return new Vector3D(toNumber(theParameters[0]) * Vector3D.DEGREES_TO_RADIANS, toNumber(theParameters[1]) * Vector3D.DEGREES_TO_RADIANS, toNumber(theParameters[2]) * Vector3D.DEGREES_TO_RADIANS);
		}
		
		/**
		 * Convert the input to a Vector3D. This assumes the input is comma
		 * delimited and used radian angles in its notation.
		 */
		public static function toVector3D(aValue:String):Vector3D
		{
			var theParameters:Array = toArray(aValue);
			return new Vector3D(toNumber(theParameters[0]), toNumber(theParameters[1]), toNumber(theParameters[2]));
		}
		
		/**
		 * Convert the input to a Rectangle. Assumes a comma delimited list of
		 * four values, x, y, width, height
		 */
		public static function toRectangle(aValue:String):Rectangle
		{
			var theParameters:Array = toArray(aValue);
			return new Rectangle(toNumber(theParameters[0]), toNumber(theParameters[1]), toNumber(theParameters[2]), toNumber(theParameters[3]));
		}
		
		/**
		 * Convert the input to a whole number integer
		 */
		public static function toInt(aValue:String):int
		{
			aValue = StringEx.trim(aValue);
			
			var theBase:int = 10;
			if (aValue.substr(0, 1) == "#") {
				aValue = aValue.substr(1);
				theBase = 16;
			}
			
			aValue = stripLeadingZeros(aValue);
			if (parseInt(aValue, theBase).toString(theBase) != aValue)
				return 0;
			else
				return parseInt(aValue, theBase);
		}
		
		/**
		 * Convert the input to an array. Assumes an unquoted comma delimited
		 * string.
		 */
		public static function toArray(aValue:String):Array
		{
			var theDelimiter:RegExp = /,\s*/;
			if (aValue == "") return [];

			var theArray:Array = aValue.split(theDelimiter);
			if (theArray.length == 0)
				return [];
			else
				return theArray;
		}
		
		/**
		 * Convert the input to a string. If the input is null returns an
		 * empty string.
		 */
		public static function toStr(aValue:String):String
		{
			if (aValue)
				return aValue;
			
			return "";
		}
		
		/**
		 * Conver the input to a boolean. Valid values for "true" are "true", "yes"
		 * and "1", anything else returns false.
		 */
		public static function toBoolean(aValue:String):Boolean
		{
			aValue = StringEx.trim(aValue).toLowerCase();
			
			if (aValue == "true" || aValue == "yes" || aValue == "1") {
				return true;
			} else 
				if (aValue == "false" || aValue == "no" || aValue == "0" || aValue == "-1") {
					return false;
				} else {
					return false; // optionally set to something else?
				}
		}
		
		/**
		 * Strip a numerical string of its leading zeros.
		 * This method does not handle different locales and different decimal
		 * separators.
		 * 
		 * @param aValue The numerical string to parse
		 */
		protected static function stripLeadingZeros(aValue:String):String
		{
			aValue = StringEx.trim(aValue).replace(/^[0]+/,'');
			
			if (aValue == "") return "0";
			if (aValue.substr(0, 1) == ".") aValue = "0" + aValue;
			
			return aValue;
		}
		
		/**
		 * Strip a numerical string of its trailing zeros (after the decimal point).
		 * This method does not handle different locales and different decimal
		 * separators.
		 * 
		 * @param aValue The numerical string to parse
		 */
		protected static function stripTrailingZeros(aValue:String):String
		{
			if (aValue.indexOf(".") == -1) return aValue;
			
			aValue = StringEx.trim(aValue).replace(/[0]+$/,'');
			
			if (aValue == "") return "0";
			if (aValue.substr(aValue.length - 1) == ".") aValue = aValue.substr(0, aValue.length - 1);			
			
			return aValue;
		}
	}
}