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
	 * A Vector3D class. Can be used to represent a 3D point or 3D rotation.
	 */
	public class Vector3D
	{
		public static const DEGREES_TO_RADIANS:Number = Math.PI / 180;

		//-----------------------------------------------------------------------------------------
		/**
		 * Return the cross-product of two Vector3D's
		 */
		[AutoScope=false]
		public static function crossProduct(aVector1:Vector3D, aVector2:Vector3D):Vector3D
		{
			var theVector:Vector3D = new Vector3D(0, 0, 0);
			theVector._x = aVector1._y * aVector2._z - aVector1._z * aVector2._y;
			theVector._y = aVector1._z * aVector2._x - aVector1._x * aVector2._z;
			theVector._z = aVector1._x * aVector2._y - aVector1._y * aVector2._x;
			
			return theVector;
		}
		
		/**
		 * Return the Vector between two Vector3D's
		 */
		[AutoScope=false]
		public static function vector(aVector1:Vector3D, aVector2:Vector3D):Vector3D
		{
			var theVector:Vector3D = new Vector3D(0, 0, 0);
			theVector._x = aVector2._x - aVector1._x;
			theVector._y = aVector2._y - aVector1._y;
			theVector._z = aVector2._z - aVector1._z;
			
			return theVector;
		}
		
		//-----------------------------------------------------------------------------------------
		protected var _x:Number;
		protected var _y:Number;
		protected var _z:Number;
		protected var _w:Number;
		
		//-----------------------------------------------------------------------------------------
		public function getX():Number				{ return _x; }
		public function setX(value:Number):void		{ _x = value; }
		
		public function getY():Number				{ return _y; }
		public function setY(value:Number):void		{ _y = value; }
		
		public function getZ():Number				{ return _z; }
		public function setZ(value:Number):void		{ _z = value; }

		public function getW():Number				{ return _w; }
		public function setW(value:Number):void		{ _w = value; }
		
		//-----------------------------------------------------------------------------------------
		public function Vector3D(x:Number = 0, y:Number = 0, z:Number = 0, w:Number = 0)
		{
			_x = x;
			_y = y;
			_z = z;
			_w = w;
		}
		
		/**
		 * The magnitude of the vector (distance to 0, 0, 0)
		 */
		public function length():Number
		{
			return Math.sqrt(_x * _x + _y * _y + _z * _z);
		}
		
		/**
		 * Calculates the distance of the Vector3D to another Vector3D
		 */
		public function calculateDistanceTo(aVector:Vector3D):Number
		{
			var theDX:Number = aVector._x - _x;
			var theDY:Number = aVector._y - _y;
			var theDZ:Number = aVector._z - _z;

			return Math.sqrt(theDX * theDX + theDY * theDY + theDZ * theDZ);
		}
		
		/**
		 * Rotate the Vector3D over the three axis. Uses angles in radians.
		 */
		public function rotate(aX:Number, aY:Number, aZ:Number):void
		{
			var sx:Number = Math.sin(aX);
			var cx:Number = Math.cos(aX);
			var sy:Number = Math.sin(aY);
			var cy:Number = Math.cos(aY);
			var sz:Number = Math.sin(aZ);
			var cz:Number = Math.cos(aZ);
			
			var theNewX:Number = _x;
			var theNewY:Number = _y;
			var theNewZ:Number = _z;
			
			// rotation around X
			var theNewYPrime:Number = cx * theNewY - sx * theNewZ;
			theNewZ = sx * theNewY + cx * theNewZ;
			theNewY = theNewYPrime;
			
			// rotation around Y
			var theNewXPrime:Number = cy * theNewX + sy * theNewZ;
			theNewZ = -sy * theNewX + cy * theNewZ;
			theNewX = theNewXPrime;
			
			// rotation around Z
			theNewXPrime = cz * theNewX - sz * theNewY;
			theNewY = sz * theNewX + cz * theNewY;
			theNewX = theNewXPrime;
			
			_x = theNewX;
			_y = theNewY;
			_z = theNewZ;
		}
		
		/**
		 * Do a inverse rotation over the three axis using radian angles.
		 */
		public function inverseRotate(aX:Number, aY:Number, aZ:Number):void
		{
			var sx:Number = Math.sin(aX);
			var cx:Number = Math.cos(aX);
			var sy:Number = Math.sin(aY);
			var cy:Number = Math.cos(aY);
			var sz:Number = Math.sin(aZ);
			var cz:Number = Math.cos(aZ);
			
			var theNewX:Number = _x;
			var theNewY:Number = _y;
			var theNewZ:Number = _z;
			
			// Rotate with transposed Z matrix.
			theNewXPrime = cz * theNewX + sz * theNewY;
			theNewY = -sz * theNewX + cz * theNewY;
			theNewX = theNewXPrime;
			
			// Rotate with transposed Y matrix.
			var theNewXPrime:Number = cy * theNewX - sy * theNewZ;
			theNewZ = sy * theNewX + cy * theNewZ;
			theNewX = theNewXPrime;
			
			// Rotate with transposed X matrix.
			var theNewYPrime:Number = cx * theNewY + sx * theNewZ;
			theNewZ = -sx * theNewY + cx * theNewZ;
			theNewY = theNewYPrime;

			_x = theNewX;
			_y = theNewY;
			_z = theNewZ;
		}
		
		/**
		 * Rotate the current Vector3D over another Vector3D. Using the other
		 * Vector3D's x, y and z as rotations over those axis.
		 */
		public function rotateByVector(aVector:Vector3D):void
		{
			rotate(aVector._x, aVector._y, aVector._z);
		}

		/**
		 * Translate the Vector3D
		 */
		public function translate(aX:Number, aY:Number, aZ:Number):void
		{
			_x += aX;
			_y += aY;
			_z += aZ;
		}
		
		/**
		 * Add another Vector3D to the Vector3D 
		 */
		public function translateByVector(aVector:Vector3D):void
		{
			translate(aVector._x, aVector._y, aVector._z);
		}

		/**
		 * Scale the Vector3D
		 */
		public function scale(aX:Number, aY:Number, aZ:Number):void
		{
			_x *= aX;
			_y *= aY;
			_z *= aZ;
		}
		
		/**
		 * Multiply the Vector3D by another Vector3D
		 */
		public function scaleByVector(aVector:Vector3D):void
		{
			scale(aVector._x, aVector._y, aVector._z);
		}
		
		/**
		 * Scale the Vector3D by a single value
		 */
		public function scaleBy(aScale:Number):void
		{
			scale(aScale, aScale, aScale); 
		}

		/**
		 * Set the values of this Vector3D to those of another Vector3D
		 */
		public function assignFromVector3D(aVector3D:Vector3D):void
		{
			_x = aVector3D._x;
			_y = aVector3D._y;
			_z = aVector3D._z;
		}
		
		public function clone():Vector3D
		{
			return new Vector3D(_x, _y, _z);
		}
		
		public function toString():String
		{
			return "[ " + _x + ", " + _y + ", " + _z + " ]";
		}
	}
}