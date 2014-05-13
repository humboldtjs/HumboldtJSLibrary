/*
* HumboldtJSLibrary
* http://humboldtjs.com/
*
* Copyright (c) 2012 Daniël Haveman
* Licensed under the MIT license
* http://humboldtjs.com/license.html
*/
package com.humboldtjs.net
{
	import com.humboldtjs.xml.HJSXML;

	/**
	 * A prefix loader which loads XMLP files that have been generated using
	 * the xmlpconverter.jar application.
	 * 
	 * Returns a HJSXML object on callback.
	 */
	public class XMLPLoader extends PrefixLoader
	{
		/**
		 * @constructor
		 */
		public function XMLPLoader()
		{
			super();
		}
		
		/**
		 * Do the callback, but before doing so first process the JSONP
		 * into a HJSXML object.
		 */
		override protected function doCallback(aValue:*):void
		{
			var theXmlP:HJSXML = HJSXML.processXML(aValue);
			super.doCallback(theXmlP);
		}
	}
}