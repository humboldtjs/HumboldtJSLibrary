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
		protected var mName:String;
		protected var mValue:String;
		
		/**
		 * The attribute's name
		 */
		public function getName():String { return mName; }
		/**
		 * The attribute's value
		 */
		public function getValue():String { return mValue; }
		
		/**
		 * @constructor
		 */
		public function XMLAttribute(aName:String, aValue:String)
		{
			mName = aName;
			mValue = aValue;
		}
	}
}