/*
* HumboldtJSLibrary
* http://humboldtjs.com/
*
* Copyright (c) 2012 Daniël Haveman
* Licensed under the MIT license
* http://humboldtjs.com/license.html
*/
package com.humboldtjs.geom
{
	/**
	 * A two dimensional coordinate (x, y) representation.
	 */ 
	public class Point
	{
		private var mX:Number;
		private var mY:Number;

		public function getX():Number				{ return mX; }
		public function setX(value:Number):void		{ mX = value; }
		
		public function getY():Number				{ return mY; }
		public function setY(value:Number):void		{ mY = value; }

		public function Point(aX:Number, aY:Number)
		{
			mX = aX;
			mY = aY;
		}
	}
}