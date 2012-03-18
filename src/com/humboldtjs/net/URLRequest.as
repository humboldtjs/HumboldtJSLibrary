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
		
		public static const METHOD_GET:String = "get";
		public static const METHOD_POST:String = "post";
		
		protected var mContentType:String = "image";
		protected var mData:Object;
		protected var mMethod:String = "get";
		protected var mUrl:String = "";
		
		/**
		 * The content type to request
		 */
		public function getContentType():String				{ return mContentType; }
		/**
		 * The content type to request
		 */
		public function setContentType(value:String):void	{ mContentType = value; }

		/**
		 * The data object to send with the request
		 */
		public function getData():Object					{ return mData; }
		/**
		 * The data object to send with the request
		 */
		public function setData(value:Object):void			{ mData = value; }
		
		/**
		 * The method to do the request with (either METHOD_GET or METHOD_POST)
		 */
		public function getMethod():String					{ return mMethod; }
		/**
		 * The method to do the request with (either METHOD_GET or METHOD_POST)
		 */
		public function setMethod(value:String):void 		{ mMethod = value; }
		
		/**
		 * The URL to request
		 */
		public function getUrl():String						{ return mUrl; }
		/**
		 * The URL to request
		 */
		public function setUrl(value:String):void			{ mUrl = value; }
		
		/**
		 * @constructor
		 */
		public function URLRequest(aUrl:String)
		{
			mData = {};
			
			setUrl(aUrl);
		}
	}
}