/*
* HumboldtJSLibrary
* http://humboldtjs.com/
*
* Copyright (c) 2012 Daniël Haveman
* Licensed under the MIT license
* http://humboldtjs.com/license.html
*/
package com.humboldtjs.utility
{
	/**
	 * Helper class to help determine the scale of elements based on a
	 * preferred scalestyle, their dimensions, and the available space.
	 */
	public class ScaleUtility
	{
		/** The component is scaled to always fill the entire ViewDisplay boundaries. */
		public static const SCALE_FILL:int = 3;
		
		/** Same as SCALE_FILL however the component will never be smaller than it''s original size. */
		public static const SCALE_FILL_ONLY_LARGER:int = 4;
		
		/** The component is scaled to always fit but never exceed the ViewDisplay boundaries. */
		public static const SCALE_FIT:int = 1;
		
		/** Same as SCALE_FIT however the component will never be larger than it''s original size. */
		public static const SCALE_FIT_ONLY_SMALLER:int = 2;
		
		/** The component is not scaled. */
		public static const SCALE_NOSCALE:int = 0;
		
		/**
		 * Calculate the ideal scale for an element in a certain space
		 * using the given scale style.
		 *
		 * @param aDisplayObject The element to determine the scale for
		 * @param aWidth The width of the target area
		 * @param aHeight The height of the target area
		 * @param aScaleStyle The scalestyle to use to determine the scale
		 *
		 * @return The ideal scale
		 */
		public static function calculateScaleFor(aObjectWidth:Number, aObjectHeight:Number, aTargetWidth:Number, aTargetHeight:Number, aScaleStyle:int):Number
		{
			// And the we calculate the new scale based on one of the
			// scale styles
			var theScale:Number = 1;
			
			switch (aScaleStyle) {
				case SCALE_NOSCALE:
					theScale = 1;
					break;
				case SCALE_FIT:
					theScale = Math.min(aTargetWidth / aObjectWidth, aTargetHeight / aObjectHeight);
					break;
				case SCALE_FIT_ONLY_SMALLER:
					theScale = Math.min(aTargetWidth / aObjectWidth, aTargetHeight / aObjectHeight);
					theScale = Math.min(1, theScale);
					break;
				case SCALE_FILL:
					theScale = Math.max(aTargetWidth / aObjectWidth, aTargetHeight / aObjectHeight);
					break;
				case SCALE_FILL_ONLY_LARGER:
					theScale = Math.max(aTargetWidth / aObjectWidth, aTargetHeight / aObjectHeight);
					theScale = Math.max(1, theScale);
					break;
			}
			return theScale;
		}
	}
}