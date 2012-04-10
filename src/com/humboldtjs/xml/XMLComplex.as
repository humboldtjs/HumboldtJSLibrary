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
	 * Represents an XML node with Complex content. This content can have
	 * children, attributes. Each of those children can be either Simple content
	 * (just a string) or another node with Complex content.	
	 */
	public class XMLComplex extends HJSXML
	{
		protected var mName:String;
		protected var mAt:Vector.<XMLAttribute>;
		protected var mValue:Vector.<HJSXML>;
		
		/**
		 * The node name
		 */
		override public function getName():String { return mName; };
		/**
		 * A list of children of this node
		 */
		override public function getChildren():Vector.<HJSXML> { return mValue; }
		/**
		 * A list of attributes of this node
		 */
		override public function getAttributes():Vector.<XMLAttribute> { return mAt; }
		
		/**
		 * @constructor
		 */
		public function XMLComplex(aName:String = "", aAt:Vector.<XMLAttribute> = null, aValue:Vector.<HJSXML> = null)
		{
			mName = aName;
			
			mValue = new Vector.<HJSXML>();
			if (aValue != null) {
				for (var i:int = 0; i < aValue.length; i++) {
					
					// Each value should be a HJSXML, but if the file was
					// loaded from an XMLP then it is still only an object
					// structure and needs to be processed first
					if (aValue[i] is HJSXML) {
						mValue.push(aValue[i]);
					} else {
						if (typeof aValue[i] !== "undefined")
							mValue.push(processXML(aValue[i]));
					}
				}
			}
			
			mAt = new Vector.<XMLAttribute>();
			if (mAt != null) {
				for (var key:String in aAt) {
					// Each value should be a XMLAttribute, but if the file was
					// loaded from an XMLP then it is still only a key value
					// pair in an object structure and the XMLAttribute needs
					// to be created first
					if (aAt[key] is XMLAttribute) {
						mAt.push(aAt[key]);
					} else {
						var untyped:* = aAt[key];
						mAt.push(new XMLAttribute(key, untyped));
					}
				}
			}
		}
	}
}