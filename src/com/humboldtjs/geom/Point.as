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
		/**
		 * Returns the distance between pt1 and pt2.
		 * 
		 * @param aPoint1
		 * @param aPoint2
		 * @return
		 */
		[AutoScope=false]
		public static function distance(aPoint1:Point, aPoint2:Point):Number
		{
			var dx:Number = aPoint1._x - aPoint2._x;
			var dy:Number = aPoint1._y - aPoint2._y;
			
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
		[AutoScope=false]
		public static function interpolate(aPoint1:Point, aPoint2:Point, aFactor:Number):Point
		{
			return new Point(aFactor * (aPoint2._x - aPoint1._x) + aPoint1._x, 
							 aFactor * (aPoint2._y - aPoint1._y) + aPoint1._y);
		}
		
		//-----------------------------------------------------------------------------------------
		protected var _x:Number;
		protected var _y:Number;

		//-----------------------------------------------------------------------------------------
		public function getX():Number				{ return _x; }
		public function setX(value:Number):void		{ _x = value; }
		
		public function getY():Number				{ return _y; }
		public function setY(value:Number):void		{ _y = value; }

		//-----------------------------------------------------------------------------------------
		public function Point(aX:Number, aY:Number)
		{
			_x = aX;
			_y = aY;
		}
			
		/**
		 * Returns the length of the line segment from (0,0) to this Point.
		 * 
		 * @return length
		 */
		public function length():Number
		{
			return Math.sqrt(_x * _x + _y * _y);
		}
		
		/**
		 * Returns the squared length of the line segment from (0,0) to this Point.
		 * 
		 * @return length
		 */
		public function squaredLength():Number
		{
			return _x * _x + _y * _y;
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
			return new Point(_x + aPoint._x, _y + aPoint._y);
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
			return new Point(_x - aPoint._x, _y - aPoint._y);
		}
		
		/**
		 * Scales this point {@link Point} by specified point.
		 * 
		 * @param aPoint the value by which to multiply.
		 */
		public function scale(aPoint:Point):void
		{
			_x *= aPoint._x;
			_y *= aPoint._y;
		}
		
		/**
		 * Scales this point {@link Point} by specified scale.
		 * 
		 * @param aScale the value by which to multiply.
		 */
		public function scaleBy(aScale:Number):void
		{
			_x *= aScale;
			_y *= aScale;
		}
		
		/**
		 * Normalize the length of a point's vector to length equal to
		 * aScaleFactor.
		 * 
		 * @param aScaleFactor The length of the point's normalized vector.
		 */
		public function normalize(aScaleFactor:Number):void
		{
			if (length() == 0)
				return;
			
			var theFactor:Number = aScaleFactor / length(); 
	
			_x *= theFactor;
			_y *= theFactor;
		}
		
		/**
		 * Offsets this point {@link Point} by specified point.
		 * 
		 * @param aPoint the value by which to offset.
		 */
		public function offset(aPoint:Point):void
		{
			_x += aPoint._x;
			_y += aPoint._y;
		}
		
		public function clone():Point
		{
			return new Point(_x, _y);
		}
		
		public function equals(aPoint:Point):Boolean
		{
			if (aPoint == null)
				return false;
			
			return (_x == aPoint._x) && (_y == aPoint._y);
		}
		
		public function toString():String
		{
			return "Point(" + _x + "," + _y + ")";
		}
	}
}