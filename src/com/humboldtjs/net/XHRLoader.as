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
	import com.humboldtjs.events.EventDispatcher;
	import com.humboldtjs.events.HJSEvent;
	import com.humboldtjs.system.OperatingSystem;
	
	import dom.window;
	import dom.domobjects.Event;
	import dom.domobjects.HTMLElement;
	import dom.jsobjects.ActiveXObject;
	import dom.jsobjects.XDomainRequest;
	import dom.jsobjects.XMLHttpRequest;

	/**
	 * A simple loader that uses XMLHttpRequests to load either XML or TEXT
	 * data. If you want to load an XML you need to set the content type of
	 * the URLRequest to XML as well, otherwise the loader will return a
	 * text representation of the XML file.
	 * 
	 * Note that loading XMLs potentially returns something quite different
	 * based on the browser you are using (IE vs. the rest).
	 * 
	 * This loader also contains a factory method for creating an XMLHttpRequest
	 * instance which you can use in custom code.
	 */
	public class XHRLoader extends EventDispatcher
	{
		/** The XMLHttpRequest is unsent */
		public static const XHR_UNSENT:int = 0;
		/** The XMLHttpRequest connection has been opened */
		public static const XHR_OPENED:int = 1;
		/** The XMLHttpRequest headers have been received */
		public static const XHR_HEADERS_RECEIVED:int = 2;
		/** The XMLHttpRequest is loading */
		public static const XHR_LOADING:int = 3;
		/** The XMLHttpRequest is done */
		public static const XHR_DONE:int = 4;
		
		protected var _request:XMLHttpRequest;
		protected var _content:*;
		protected var _contentType:String = "";
		protected static var _isLegacyIE:Boolean = false;
		
		/**
		 * Returns a browser-independent XMLHttpRequest object which can be used
		 * to load additional text or XML files.
		 */
		public static function getXMLHttpRequestObject():XMLHttpRequest
		{
			var theXHR:XMLHttpRequest = null;
			_isLegacyIE = (OperatingSystem.getInternetExplorerVersion() != -1 && OperatingSystem.getInternetExplorerVersion() < 10);
			if (_isLegacyIE) {
				theXHR = new XDomainRequest();
			} else {
				if(window.XMLHttpRequest && !(window.ActiveXObject)) {
					try {
						// If supported use the native XMLHttpRequest functionality
						theXHR = new XMLHttpRequest();
					} catch(e:Error) {
						// We're out of options
						theXHR = null;
					}
				} else if(window.ActiveXObject) {
					try {
						// Internet Explorer 7.0 and up use Msxml2 ActiveXObject
						theXHR = new ActiveXObject("Msxml2.XMLHTTP");
					} catch(e:Error) {
						try {
							// Internet Explorer 6.0 uses the old XML ActiveXObject
							theXHR = new ActiveXObject("Microsoft.XMLHTTP");
						} catch(e:Error) {
							// We're out of options
							theXHR = null;
						}
					}
				}
			}
			
			return theXHR;
		}

		/**
		 * The loaded content
		 */
		public function getContent():*				{ return _content; }

		/**
		 * @constructor
		 */
		public function XHRLoader()
		{
			super();
			_request = getXMLHttpRequestObject();
			_contentType = URLRequest.CONTENTTYPE_TEXT;
		}
		
		/**
		 * Close the loader before finishing loading..
		 */
		public function close():void
		{
			_request.abort();
		}
		
		/**
		 * Try to load a Text from the given URLRequest.
		 */
		public function load(request:URLRequest):void
		{
			_contentType = request.getContentType();
			if (_isLegacyIE) {
				_request.open(request.getMethod(), request.getUrl());
				_request["onerror"] = onXDomainRequestError;	
				_request["onload"] = onXDomainRequestLoad;	
				_request["ontimeout"] = onXDomainRequestError;	
				_request.send(null);
			} else {
				_request.open(request.getMethod(), request.getUrl(), true);
				_request["onreadystatechange"] = onReadyStateChange;
				_request.send(request.getData());
			}
		}
		
		/**
		 * Unload the current content and close the loader
		 */
		public function unload():void
		{
			close();
		}
		
		protected function onXDomainRequestLoad(e:Event = null):void {
			var theResponseText:String = _request.responseText;
			_content = theResponseText;
			dispatchEvent(new HJSEvent(HJSEvent.COMPLETE));
		}
		
		protected function onXDomainRequestError(e:Event = null):void {
			
		}
		
		protected function onReadyStateChange():void
		{
			if (_request.readyState == XHR_DONE) {

				var theResponseText:String = _request.responseText;
				var theResponseXML:HTMLElement = _request.responseXML;

				// If the requested response type is XML and the actual
				// response is null or empty, it means either the XML was
				// malformed OR the XML wasn't parsed. This second issue
				// happens on IE6.0 when the XML is loaded from the local
				// filesystem, and some other cache edge-cases.
				if (_contentType == URLRequest.CONTENTTYPE_XML && (theResponseXML == null || theResponseXML.childNodes.length == 0) && theResponseText != "") {

					// Some of the code below will not return an XMLDocument
					// but just something which behaves the same. This var is
					// untyped to prevent us having to cast it to an
					// XMLDocument (which would return null, and defeat the
					// purpose)
					var theXMLDocument:*;
					
					// Try to use the standards DOMParser object to parse to
					// XML into an XMLDOM, but if that is not available fall-
					// back to the IE XMLDOM COM object.
					if (window["DOMParser"]) {
						var theDOMParser:Object = new window["DOMParser"]();
						theXMLDocument = theDOMParser.parseFromString(theResponseText, "text/xml");
					} else {
						theXMLDocument = new ActiveXObject("Microsoft.XMLDOM");
						theXMLDocument.async = "false";
						theXMLDocument.loadXML(theResponseText);
					}
					theResponseXML = theXMLDocument;
				}
				
				// Set the return content to the appropriate type
				if (_contentType == URLRequest.CONTENTTYPE_XML) {
					_content = theResponseXML;
				} else {
					_content = theResponseText;
				}
				
				// And we're done
				dispatchEvent(new HJSEvent(HJSEvent.COMPLETE));
			}
		}
	}
}