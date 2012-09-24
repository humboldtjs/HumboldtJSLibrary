package com.humboldtjs.utility
{
	/**
	 * A simple parser utility that allows for DOM-like operations on a string
	 * containing HTML.
	 */
	public class HtmlParser
	{
		/**
		 * Return the HTML element with a given ID as a string representation.
		 * 
		 * @param aId The ID to search for (case-insensitive)
		 * @param aHtml The HTML or HTML-snippet to search through
		 */
		public static function getElementById(aId:String, aHtml:String):String
		{
			return getElementsBySubstring(" id=\"" + aId + "\"", aHtml)[0];
		}
		
		/**
		 * Return the HTML elements which contain the matching classname
		 * exactly. Note that it will only find elements which have exactly
		 * <code>class="[aClassName]"</code> in it. This means that if you
		 * want to find an element which has two classnames you will need to
		 * provide both and spaced exactly as used in the HTML.
		 * 
		 * @param aClassName The classname (or classnames) to match the HTML element to (case-insensitive)
		 * @param aHtml The HTML or HTML-snippet to search through
		 */
		public static function getElementsByClassName(aClassName:String, aHtml:String):Array
		{
			return getElementsBySubstring(" class=\"" + aClassName + "\"", aHtml);
		}
		
		/**
		 * Given an HTML element (e.g. the result of either getElementById or
		 * getElementsByClassName) will return it's inner HTML and remove its
		 * outer tags.
		 * 
		 * @param aHtml the HTML or HTML-snippet to strip the outer tags from
		 */
		public static function getInnerHtml(aHtml:String):String
		{
			var theStartPosition:int = aHtml.indexOf(">");
			var theEndPosition:int = aHtml.lastIndexOf("<");
			if (theStartPosition == -1 || theEndPosition == -1) return aHtml;
			
			return aHtml.substr(theStartPosition + 1, theEndPosition - theStartPosition - 1);
		}
		
		/**
		 * Finds each HTML element which encloses the given search string. This
		 * search is case insensitive.
		 * 
		 * @param aSubstring The string to search for (case-insensitive)
		 * @param aHtml The HTML or HTML-snippet to search through
		 */
		public static function getElementsBySubstring(aSubstring:String, aHtml:String):Array
		{
			// The search will be done case-insensitive, but the result will
			// preserve the original case
			var theOriginalHtml:String = aHtml;
			var theHtml:String = theOriginalHtml.toLowerCase();
			var theSearch:String = aSubstring.toLowerCase();

			var theInstances:Array = [];
			var theCurrentPosition:int = 0;
			while (theHtml.indexOf(theSearch, theCurrentPosition) != -1) {

				// If we have find a result we look for the opening tag before
				// it, and then try to find its matching closing tags.
				// Like most HTML browsers we simply ignore all non-compatible
				// that are thrown in between.
				var theIdPosition:int = theHtml.indexOf(theSearch, theCurrentPosition);
				var theTagPosition:int = theHtml.lastIndexOf("<", theIdPosition);
				var theTagName:String = theHtml.substr(0, theIdPosition + theSearch.length).substr(theTagPosition + 1).split(" ")[0];
				
				// We keep track of an indent level, to make sure that e.g. a
				// div with multiple divs inside will match to the correct
				// closing tag
				var theIndent:int = 1;
				var theSearchPosition:int = theTagPosition;
				while (theSearchPosition < theHtml.length && theIndent > 0) {
					
					var theOpenPosition:int = theHtml.indexOf("<" + theTagName, theSearchPosition + theTagName.length);
					var theClosePosition:int = theHtml.indexOf("</" + theTagName, theSearchPosition + theTagName.length);
					
					// If there is a new opening tag before the closing tag
					// we indent one further, and if the closing tag is before
					// the opening tag descrease the indent. And finally if
					// there is no closing tag then we just skip to the end of
					// the HTML.
					if (theOpenPosition < theClosePosition && theOpenPosition != -1) {
						theIndent++;
						theSearchPosition = theOpenPosition;
					} else if (theClosePosition != -1) {
						theIndent--;
						theSearchPosition = theClosePosition;
					} else {
						theSearchPosition = theHtml.length;
					}
					
				}
				// Either we've found the closing tag, or if there was no
				// correctly matched closing tag we jump to the end of the HTML.
				var theTagClosePosition:int = theHtml.indexOf(">", theSearchPosition);
				if (theTagClosePosition != -1) {
					theCurrentPosition = theTagClosePosition + 1;
				} else {
					theCurrentPosition = theSearchPosition;
				}

				// And add it to the results list
				theInstances.push(theOriginalHtml.substr(theTagPosition, theCurrentPosition - theTagPosition));
			}
			
			return theInstances;
		}
	}
}