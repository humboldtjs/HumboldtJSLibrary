/*
* HumboldtJSLibrary
* http://humboldtjs.com/
*
* Copyright (c) 2012 Daniël Haveman
* Licensed under the MIT license
* http://humboldtjs.com/license.html
*/
package com.humboldtjs.xml
{
	/**
	 * Represents an attribute on an XML node
	 */
	public class XMLAttribute
	{
		protected var _name:String;
		protected var _value:String;
		
		/**
		 * The attribute's name
		 */
		public function getName():String { return _name; }
		/**
		 * The attribute's value
		 */
		public function getValue():String { return _value; }
		
		/**
		 * @constructor
		 */
		public function XMLAttribute(aName:String, aValue:String)
		{
			_name = aName;
			_value = aValue;
		}
	}
}