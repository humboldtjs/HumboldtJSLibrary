/*
* HumboldtJSLibrary
* http://humboldtjs.com/
*
* Copyright (c) 2012 Daniël Haveman
* Licensed under the MIT license
* http://humboldtjs.com/license.html
*/
package com.humboldtjs.utility.easing
{
	/**
	 * A simple Sine easing function based on the standard Robert Penner
	 * easing functions.
	 */
	public class Sine
	{
		public function Sine()
		{
		}
		
		public static function ease(fraction:Number, easeInFraction:Number):Number
		{
			var easeOutFraction:Number = 1 - easeInFraction;
			
			if (fraction <= easeInFraction && easeInFraction > 0)
				return easeInFraction * easeIn(fraction/easeInFraction);
			else
				return easeInFraction + easeOutFraction *
					easeOut((fraction - easeInFraction)/easeOutFraction);
		}
		
		public static function easeIn(fraction:Number):Number
		{
			return 1 - Math.cos(fraction * Math.PI/2);
		}
		
		public static function easeOut(fraction:Number):Number
		{
			return Math.sin(fraction * Math.PI/2);
		}
	}
}