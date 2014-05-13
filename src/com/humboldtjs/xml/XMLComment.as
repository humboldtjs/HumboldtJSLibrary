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
	 * Represents a Comment in an XML node.
	 */
	public class XMLComment extends HJSXML
	{
		protected var _comment:String = "";
		
		/**
		 * The string content of the comment
		 */
		public function getComment():String { return _comment; }
		
		/**
		 * @constructor
		 */
		public function XMLComment(aComment:String)
		{
			super();
			_comment = aComment;
		}
	}
}