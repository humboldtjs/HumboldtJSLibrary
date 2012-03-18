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
		private var mX:Number;
		private var mY:Number;
		private var mZ:Number;
		private var mW:Number;
		
		public static const DEGREES_TO_RADIANS:Number = Math.PI / 180;

		public function getX():Number				{ return mX; }
		public function setX(value:Number):void		{ mX = value; }
		
		public function getY():Number				{ return mY; }
		public function setY(value:Number):void		{ mY = value; }
		
		public function getZ():Number				{ return mZ; }
		public function setZ(value:Number):void		{ mZ = value; }

		public function getW():Number				{ return mW; }
		public function setW(value:Number):void		{ mW = value; }
		
		public function Vector3D(x:Number = 0, y:Number = 0, z:Number = 0, w:Number = 0)
		{
			mX = x;
			mY = y;
			mZ = z;
			mW = w;
		}
		
		/**
		 * The magnitude of the vector (distance to 0, 0, 0)
		 */
		public function length():Number
		{
			return Math.sqrt(mX * mX + mY * mY + mZ * mZ);
		}
		
		/**
		 * Calculates the distance of the Vector3D to another Vector3D
		 */
		public function calculateDistanceTo(aVector:Vector3D):Number
		{
			var theDX:Number = aVector.mX - mX;
			var theDY:Number = aVector.mY - mY;
			var theDZ:Number = aVector.mZ - mZ;

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
			
			var theNewX:Number = mX;
			var theNewY:Number = mY;
			var theNewZ:Number = mZ;
			
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
			
			mX = theNewX;
			mY = theNewY;
			mZ = theNewZ;
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
			
			var theNewX:Number = mX;
			var theNewY:Number = mY;
			var theNewZ:Number = mZ;
			
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

			mX = theNewX;
			mY = theNewY;
			mZ = theNewZ;
		}
		
		/**
		 * Rotate the current Vector3D over another Vector3D. Using the other
		 * Vector3D's x, y and z as rotations over those axis.
		 */
		public function rotateByVector(aVector:Vector3D):void
		{
			rotate(aVector.getX(), aVector.getY(), aVector.getZ());
		}

		/**
		 * Translate the Vector3D
		 */
		public function translate(aX:Number, aY:Number, aZ:Number):void
		{
			mX += aX;
			mY += aY;
			mZ += aZ;
		}
		
		/**
		 * Add another Vector3D to the Vector3D 
		 */
		public function translateByVector(aVector:Vector3D):void
		{
			translate(aVector.getX(), aVector.getY(), aVector.getZ());
		}

		/**
		 * Scale the Vector3D
		 */
		public function scale(aX:Number, aY:Number, aZ:Number):void
		{
			mX *= aX;
			mY *= aY;
			mZ *= aZ;
		}
		
		/**
		 * Multiply the Vector3D by another Vector3D
		 */
		public function scaleByVector(aVector:Vector3D):void
		{
			scale(aVector.getX(), aVector.getY(), aVector.getZ());
		}
		
		/**
		 * Scale the Vector3D by a single value
		 */
		public function scaleBy(aScale:Number):void
		{
			scale(aScale, aScale, aScale); 
		}

		/**
		 * Return the cross-product of two Vector3D's
		 */
		public static function crossProduct(aVector1:Vector3D, aVector2:Vector3D):Vector3D
		{
			var theVector:Vector3D = new Vector3D(0, 0, 0);
			theVector.mX = aVector1.mY * aVector2.mZ - aVector1.mZ * aVector2.mY;
			theVector.mY = aVector1.mZ * aVector2.mX - aVector1.mX * aVector2.mZ;
			theVector.mZ = aVector1.mX * aVector2.mY - aVector1.mY * aVector2.mX;
			
			return theVector;
		}
		
		/**
		 * Return the Vector between two Vector3D's
		 */
		public static function vector(aVector1:Vector3D, aVector2:Vector3D):Vector3D
		{
			var theVector:Vector3D = new Vector3D(0, 0, 0);
			theVector.mX = aVector2.mX - aVector1.mX;
			theVector.mY = aVector2.mY - aVector1.mY;
			theVector.mZ = aVector2.mZ - aVector1.mZ;
			
			return theVector;
		}
		
		/**
		 * Set the values of this Vector3D to those of another Vector3D
		 */
		public function assignFromVector3D(aVector3D:Vector3D):void
		{
			mX = aVector3D.mX;
			mY = aVector3D.mY;
			mZ = aVector3D.mZ;
		}
		
		public function clone():Vector3D
		{
			return new Vector3D(mX, mY, mZ);
		}
		
		public function toString():String
		{
			return "[ " + mX + ", " + mY + ", " + mZ + " ]";
		}
	}
}