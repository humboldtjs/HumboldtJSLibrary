/*
* HumboldtJSLibrary
* http://humboldtjs.com/
*
* Copyright (c) 2012 Daniël Haveman
* Licensed under the MIT license
* http://humboldtjs.com/license.html
*/
package com.humboldtjs.display
{
	/**
	 * A simple horizontal layout component. Uses float:left on it's children's
	 * HTML elements to layout the elements. Also serves as an example of how
	 * to modify addChild and removeChild to provide different layout behavior.
	 */
	public class HGroup extends DisplayObject
	{
		/**
		 * @constructor
		 */
		public function HGroup()
		{
			super();
		}
		
		/**
		 * Add child to the container. Modifies the HTML element's CSS to
		 * float:left to create a horizontal layout
		 */
		override public function addChild(aChild:DisplayObject):void
		{
			super.addChild(aChild);
			aChild.getHtmlElement().style.position = "relative";
			
			// all browsers support style.float, however since float is
			// a reserved javascript keyword, this can give weird errors
			// when used in conjunction with other tools (YUI compressor for
			// example). That's why we're using cssFloat and styleFloat
			// (because of course browser manufacturers couldn't agree on a 
			// single one...)
			aChild.getHtmlElement().style.cssFloat = "left";
			aChild.getHtmlElement().style.styleFloat = "left";
		}
	}
}