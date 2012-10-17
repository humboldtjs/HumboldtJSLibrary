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
			
		/**
		 * Returns the length of the line segment from (0,0) to this Point.
		 * 
		 * @return length
		 */
		public function length():Number
		{
			return Math.sqrt(mX * mX + mY * mY);
		}
		
		/**
		 * Returns the squared length of the line segment from (0,0) to this Point.
		 * 
		 * @return length
		 */
		public function squaredLength():Number
		{
			return mX * mX + mY * mY;
		}
	
		/**
		 * Add the specified {@link Point} to this point and return the result. Does
		 * not modified this {@link Point}.
		 * 
		 * @param aPoint the value to add
		 * @return the resulting point
		 */
		public function add(aPoint:Point):Point
		{
			return new Point(mX + aPoint.getX(), mY + aPoint.getY());
		}
		
		/**
		 * Add the specified {@link Point} to this point and return the result. Does
		 * not modified this {@link Point}.
		 * 
		 * @param aPoint the value to add
		 * @return the resulting point
		 */
		public function subtract(aPoint:Point):Point 
		{
			return new Point(mX - aPoint.getX(), mY - aPoint.getY());
		}
		
		/**
		 * Scales this point {@link Point} by specified point.
		 * 
		 * @param aPoint the value by which to multiply.
		 */
		public function scale(aPoint:Point):void
		{
			mX *= aPoint.getX();
			mY *= aPoint.getY();
		}
		
		/**
		 * Scales this point {@link Point} by specified scale.
		 * 
		 * @param aScale the value by which to multiply.
		 */
		public function scaleBy(aScale:Number):void
		{
			mX *= aScale;
			mY *= aScale;
		}
		
		public function normalize(aScaleFactor:Number):void
		{
			var theFactor:Number = aScaleFactor/ length(); 
	
			mX *= theFactor;
			mY *= theFactor;
		}
		
		/**
		 * Offsets this point {@link Point} by specified point.
		 * 
		 * @param aPoint the value by which to offset.
		 */
		public function offset(aPoint:Point):void
		{
			mX += aPoint.getX();
			mY += aPoint.getY();
		}
		
		public function clone():Point
		{
			return new Point(mX, mY);
		}
		
		public function equals(aPoint:Point):Boolean
		{
			if (aPoint == null)
				return false;
			
			return (mX == aPoint.getX()) && (mY == aPoint.getY());
		}
		
		public function toString():String
		{
			return "Point(" + mX + "," + mY + ")";
		}
		
		/**
		 * Returns the distance between pt1 and pt2.
		 * 
		 * @param aPoint1
		 * @param aPoint2
		 * @return
		 */
		public static function distance(aPoint1:Point, aPoint2:Point):Number
		{
			var dx:Number = aPoint1.getX() - aPoint2.getX();
			var dy:Number = aPoint1.mY - aPoint2.mY;
			
			return Math.sqrt((dx * dx + dy * dy));
		}
		
		/**
		 * Determines the interpolated point between two specified points.
		 * 
		 * @param aPoint1	The base point.
		 * @param aPoint2	The other point.
		 * @param aFactor	An interpolation factor, 0 returns aPoint1 and 1 returns aPoint2.
		 * 
		 * @return Point
		 */
		public static function interpolate(aPoint1:Point, aPoint2:Point, aFactor:Number):Point
		{
			return new Point(aFactor * (aPoint2.getX() - aPoint1.getX()) + aPoint1.getX(), 
							 aFactor * (aPoint2.getY() - aPoint1.getY()) + aPoint1.getY());
		}
	}
}