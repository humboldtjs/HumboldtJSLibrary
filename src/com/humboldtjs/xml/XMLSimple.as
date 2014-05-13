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
	 * Represents Simple content in an XML node.
	 */
	public class XMLSimple extends HJSXML
	{
		protected var _value:String = "";
		
		public function getValue():String { return _value; }
		
		public function XMLSimple(aData:String)
		{
			super();
			_value = aData;
		}
	}
}