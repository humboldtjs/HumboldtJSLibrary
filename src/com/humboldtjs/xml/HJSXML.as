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
	 * An HumboldtJS type XML object. You can create these XML variants by
	 * using the xmlpconverter.jar program in your ant build script. This processes
	 * an XML into a JSONP format that can be loaded using the XMLPLoader and
	 * processed using this HJSXML class.
	 * 
	 * Using an HJSXML object is very similar to the XML class in Flash, however
	 * with the notable exception of a lack of E4X support.
	 * 
	 * This was created mainly to combat the inconsistencies between browsers
	 * when using the native XML support, and the extreme slowness of the native
	 * support under some browsers.
	 */
	public class HJSXML
	{
		/**
		 * The node name
		 */
		public function getName():String { return ""; };
		/**
		 * A list of children of this node
		 */
		public function getChildren():Vector.<HJSXML> { return new Vector.<HJSXML>(); }
		/**
		 * A list of attributes of this node
		 */
		public function getAttributes():Vector.<XMLAttribute> { return new Vector.<XMLAttribute>(); }

		/**
		 * Process a piece of JSON (formatted using xmlpconverter.jar) into an
		 * HJSXML node structure.
		 */
		public static function processXML(aData:*):HJSXML
		{
			if (aData is Array) {
				// process the root node
				return processXML(aData[0]);
			} else
			if (aData is String) {
				// if it's just a string, then it is a simple node
				return new XMLSimple(aData);
			} else {
				if (aData.comment) {
					// we have a comment
					return new XMLComment(aData.comment);
				} else {
					// the default type of node
					return new XMLComplex(aData.name, aData.at, aData.value);
				}
			}
		}
		
		/**
		 * @constructor
		 */
		public function HJSXML()
		{
		}
		
		/**
		 * Return all children with the given name that are listed directly
		 * under this node (does not work recursively).
		 * 
		 * If none are found it will return an empty list.
		 * 
		 * @param aName The name of the node
		 * 
		 * @return An array of HJSXML nodes
		 */
		public function getChild(aName:String):Vector.<HJSXML>
		{
			var theReturn:Vector.<HJSXML> = new Vector.<HJSXML>();
			var theChildren:Vector.<HJSXML> = getChildren();
			for (var theIndex:int = 0; theIndex < theChildren.length; theIndex++)
				if (theChildren[theIndex].getName() == aName)
					theReturn.push(theChildren[theIndex]);
			
			return theReturn;
		}
		
		/**
		 * Returns an attribute with the given name if it exists. If no attribute
		 * with that name exists it will return null.
		 * 
		 * @param aName The attribute's name
		 * @return An XMLAttribute for the give name
		 */
		public function getAttribute(aName:String):XMLAttribute
		{
			var theAttributes:Vector.<XMLAttribute> = getAttributes();
			for (var theIndex:int = 0; theIndex < theAttributes.length; theIndex++) {
				if (theAttributes[theIndex].getName() == aName)
					return theAttributes[theIndex];
			}
			
			return null;
		}
		
		/**
		 * Returns an attribute's value for the given name if it exists. If no
		 * attribute with that name exists it will return null.
		 * 
		 * @param aName The attribute's name
		 * @return The value if the XMLAttribute for the given name
		 */
		public function getAttributeValue(aName:String):String
		{
			var theAttribute:XMLAttribute = getAttribute(aName);
			return ((theAttribute != null) ? theAttribute.getValue() : null); 
		}
		
		/**
		 * Whether the XML node has simple content or complex content. It has
		 * simple content it has only one child that is a string (a XMLSimple
		 * node).
		 */
		public function getHasSimpleContent():Boolean
		{
			var theChildren:Vector.<HJSXML> = getChildren();
			return (theChildren.length == 1 && theChildren[0] is XMLSimple)
		}
		
		/**
		 * If the node has simple content then return that simple content's
		 * string value. If it does not have simple content, then returns null.
		 */
		public function getSimpleContent():String
		{
			var theChildren:Vector.<HJSXML> = getChildren();
			if (theChildren.length == 1 && theChildren[0] is XMLSimple) {
				return (theChildren[0] as XMLSimple).getValue();
			}

			return null;
		}
	}
}