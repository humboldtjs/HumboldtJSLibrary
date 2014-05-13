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
	/**
	 * An object representing a request to a URL. This class doesn't actually
	 * do anything itself, but is used in e.g. loaders to figure out how to
	 * load certain things.
	 */
	public class URLRequest
	{
		public static const CONTENTTYPE_IMAGE:String = "image";
		public static const CONTENTTYPE_VIDEO:String = "video";
		public static const CONTENTTYPE_AUDIO:String = "audio";
		public static const CONTENTTYPE_TEXT:String = "text";
		public static const CONTENTTYPE_XML:String = "xml";
		
		public static const METHOD_GET:String = "get";
		public static const METHOD_POST:String = "post";
		
		protected var _contentType:String = "image";
		protected var _data:Object;
		protected var _method:String = "get";
		protected var _url:String = "";
		
		/**
		 * The content type to request
		 */
		public function getContentType():String				{ return _contentType; }
		/**
		 * The content type to request
		 */
		public function setContentType(value:String):void	{ _contentType = value; }

		/**
		 * The data object to send with the request
		 */
		public function getData():Object					{ return _data; }
		/**
		 * The data object to send with the request
		 */
		public function setData(value:Object):void			{ _data = value; }
		
		/**
		 * The method to do the request with (either METHOD_GET or METHOD_POST)
		 */
		public function getMethod():String					{ return _method; }
		/**
		 * The method to do the request with (either METHOD_GET or METHOD_POST)
		 */
		public function setMethod(value:String):void 		{ _method = value; }
		
		/**
		 * The URL to request
		 */
		public function getUrl():String						{ return _url; }
		/**
		 * The URL to request
		 */
		public function setUrl(value:String):void			{ _url = value; }
		
		/**
		 * @constructor
		 */
		public function URLRequest(aUrl:String)
		{
			_data = {};
			
			setUrl(aUrl);
		}
	}
}