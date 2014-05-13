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
	 * A three dimensional coordinate transformation.
	 * -- implementation based on glMatrix --
	 */ 
	public class Matrix3D
	{
		protected var _rawData:Array; // To maintain in sync with flash, the array fills the matrix column first.
		
		public function getRawData():Array { return _rawData; }
		public function setRawData(aValue:Array):void				
		{ 
			if (aValue.length != 16) // the Array needs to have a length of exactly 16
				return;
			
			_rawData = aValue;
		}

		public function Matrix3D()
		{
			_rawData = new Array(1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1);
		}
		
		/**
		 * Clone the current Matrix3D instance.
		 */
		public function clone():Matrix3D
		{
			var theMatrix:Matrix3D = new Matrix3D();
			theMatrix.setRawData(_rawData.slice());
			return theMatrix;
		}

		/**
		 * Set a scaling matrix. 
		 * Note that all current values are overwritten, to avoid this multiply via append- or prependScale().
		 */ 
		public function setScaleMatrix(aScaleX:Number, aScaleY:Number, aScaleZ:Number, aScaleW:Number = 1):void
		{
			_rawData = new Array(aScaleX, 0, 0, 0, 0, aScaleY, 0, 0, 0, 0, aScaleZ, 0, 0, 0, 0, aScaleW);
		}
		
		/**
		 * Append a scaling matrix to the current matrix.
		 */
		public function appendScale(aScaleX:Number, aScaleY:Number, aScaleZ:Number, aScaleW:Number = 1):void
		{
			var theScaleMatrix:Matrix3D = new Matrix3D();
			theScaleMatrix.setScaleMatrix(aScaleX, aScaleY, aScaleZ, aScaleW);
			
			append(theScaleMatrix);
		}
		
		/**
		 * Prepend a scaling matrix to the current matrix.
		 */
		public function prependScale(aScaleX:Number, aScaleY:Number, aScaleZ:Number, aScaleW:Number = 1):void
		{
			var theScaleMatrix:Matrix3D = new Matrix3D();
			theScaleMatrix.setScaleMatrix(aScaleX, aScaleY, aScaleZ, aScaleW);
			
			prepend(theScaleMatrix);
		}
		
		/**
		 * Set a translation matrix. Note that all current values are overwritten, to avoid this
		 * multiply via append- or prependTranslation().
		 */ 
		public function setTranslationMatrix(aX:Number, aY:Number, aZ:Number):void
		{
			_rawData = new Array(1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, aX, aY, aZ, 1);
		}
		
		/**
		 * Append a translation matrix to the current matrix.
		 */
		public function appendTranslation(aX:Number, aY:Number, aZ:Number):void
		{
			var theTranslationMatrix:Matrix3D = new Matrix3D();
			theTranslationMatrix.setTranslationMatrix(aX, aY, aZ);
			
			append(theTranslationMatrix);
		}
		
		/**
		 * Prepend a translation matrix to the current matrix.
		 */
		public function prependTranslation(aX:Number, aY:Number, aZ:Number):void
		{
			// Note this may be optimized by inline code.
			var theTranslationMatrix:Matrix3D = new Matrix3D();
			theTranslationMatrix.setTranslationMatrix(aX, aY, aZ);
			
			prepend(theTranslationMatrix);
		}
		
		/**
		 * Set a rotation matrix. Note that all current values are overwritten, to avoid this
		 * multiply via append- or prependRotation().
		 * 
		 * @param	aAngle		The rotation angle in radians.
		 * @param	aAxis		The axis or direction of rotation. This vector should have a length of one. 
		 */ 
		public function setRotationMatrix(aAngle:Number, aAxis:Vector3D):void
		{
			var theAxisX:Number = aAxis.getX();
			var theAxisY:Number = aAxis.getY();
			var theAxisZ:Number = aAxis.getZ();
			
			var theSine:Number = Math.sin(aAngle);
			var theCosine:Number = Math.cos(aAngle);
			var theOneMinusCosine:Number = 1 - theCosine;
			
			// The rotation maxtrix.
			_rawData[0] = theAxisX * theAxisX * theOneMinusCosine + theCosine;
			_rawData[1] = theAxisY * theAxisX * theOneMinusCosine + theAxisZ * theSine; 
			_rawData[2] = theAxisZ * theAxisX * theOneMinusCosine - theAxisY * theSine;
			_rawData[3] = 0;
			
			_rawData[4] = theAxisX * theAxisY * theOneMinusCosine - theAxisZ * theSine;
			_rawData[5] = theAxisY * theAxisY * theOneMinusCosine + theCosine;
			_rawData[6] = theAxisZ * theAxisY * theOneMinusCosine + theAxisX * theSine;
			_rawData[7] = 0;
			
			_rawData[8] = theAxisX * theAxisZ * theOneMinusCosine + theAxisY * theSine;
			_rawData[9] = theAxisY * theAxisZ * theOneMinusCosine - theAxisX * theSine;
			_rawData[10] = theAxisZ * theAxisZ * theOneMinusCosine + theCosine;
			_rawData[11] = 0;
			
			_rawData[12] = 0; 
			_rawData[13] = 0; 
			_rawData[14] = 0; 
			_rawData[15] = 1; 
		}
		
		/**
		 * Set a rotation matrix via the Euler angles with convention X-Y-Z. Note that all current values
		 * are overwritten, to avoid this multiply via append- or prependRotation() instead.
		 * 
		 * @param	aAngleX		The Euler angle over the X-axis in radians.
		 * @param	aAngleY		The Euler angle over the Y-axis in radians.
		 * @param	aAngleZ		The Euler angle over the Z-axis in radians.
		 */ 
		public function setRotationMatrixByEulerAngles(aAngleX:Number, aAngleY:Number, aAngleZ:Number):void
		{
			var theSineX:Number = Math.sin(aAngleX);
			var theCosineX:Number = Math.cos(aAngleX);
			var theSineY:Number = Math.sin(aAngleY);
			var theCosineY:Number = Math.cos(aAngleY);
			var theSineZ:Number = Math.sin(aAngleZ);
			var theCosineZ:Number = Math.cos(aAngleZ);

			_rawData[0] = theCosineY * theCosineZ;
			_rawData[1] = theCosineY * theSineZ; 
			_rawData[2] = -theSineY;
			_rawData[3] = 0;
			
			_rawData[4] = -theCosineX * theSineZ + theSineX * theSineY * theCosineZ;
			_rawData[5] = theCosineX * theCosineZ + theSineX * theSineY * theSineZ;
			_rawData[6] = theSineX * theCosineY;
			_rawData[7] = 0;
			
			_rawData[8] = theSineX * theSineZ + theCosineX * theSineY * theCosineZ;
			_rawData[9] = -theSineX * theCosineZ + theCosineX * theSineY * theSineZ;
			_rawData[10] = theCosineX * theCosineY;
			_rawData[11] = 0;
			
			_rawData[12] = 0; 
			_rawData[13] = 0; 
			_rawData[14] = 0; 
			_rawData[15] = 1; 
		}
		
		/**
		 * Append a rotation matrix to the current matrix.
		 */
		public function appendRotation(aAngle:Number, aAxis:Vector3D):void
		{
			var theRotationMatrix:Matrix3D = new Matrix3D();
			theRotationMatrix.setRotationMatrix(aAngle, aAxis);
			
			append(theRotationMatrix);
		}
		
		/**
		 * Prepend a rotation matrix to the current matrix.
		 */
		public function prependRotation(aAngle:Number, aAxis:Vector3D):void
		{
			var theRotationMatrix:Matrix3D = new Matrix3D();
			theRotationMatrix.setRotationMatrix(aAngle, aAxis);
			
			prepend(theRotationMatrix);
		}
		
		/**
		 * Append a rotation by euler angles matrix to the current matrix.
		 */
		public function appendRotationByEulerAngles(aAngleX:Number, aAngleY:Number, aAngleZ:Number):void
		{
			var theRotationMatrix:Matrix3D = new Matrix3D();
			theRotationMatrix.setRotationMatrixByEulerAngles(aAngleX, aAngleY, aAngleZ);
			
			append(theRotationMatrix);
		}
		
		/**
		 * Append a rotation by euler angles matrix to the current matrix.
		 */
		public function prependRotationByEulerAngles(aAngleX:Number, aAngleY:Number, aAngleZ:Number):void
		{
			var theRotationMatrix:Matrix3D = new Matrix3D();
			theRotationMatrix.setRotationMatrixByEulerAngles(aAngleX, aAngleY, aAngleZ);
			
			prepend(theRotationMatrix);
		}
		
		/**
		 * Transposes the current matrix. Note this function is inplace and alters the matrix.
		 */ 
		public function transpose():void
		{
			var theEntry01:Number = _rawData[1];
			var theEntry02:Number = _rawData[2];
			var theEntry03:Number = _rawData[3];
			var theEntry12:Number = _rawData[6];
			var theEntry13:Number = _rawData[7];
			var theEntry23:Number = _rawData[11];
			
			_rawData[1] = _rawData[4];
			_rawData[2] = _rawData[8];
			_rawData[3] = _rawData[12];
			_rawData[4] = theEntry01;
			_rawData[6] = _rawData[9];
			_rawData[7] = _rawData[13];
			_rawData[8] = theEntry02;
			_rawData[9] = theEntry12;
			_rawData[11] = _rawData[14];
			_rawData[12] = theEntry03;
			_rawData[13] = theEntry13;
			_rawData[14] = theEntry23;
		}
		
		/**
		 * Transform a Vector3D using the Matrix
		 */
		public function transformVector(aVector:Vector3D):Vector3D
		{
			var theVecX:Number = aVector.getX();
			var theVecY:Number = aVector.getY();
			var theVecZ:Number = aVector.getZ();
			var theVecW:Number = aVector.getW();

			var theNewX:Number = _rawData[0] * theVecX + _rawData[4] * theVecY + _rawData[8] * theVecZ + _rawData[12];
			var theNewY:Number = _rawData[1] * theVecX + _rawData[5] * theVecY + _rawData[9] * theVecZ + _rawData[13];
			var theNewZ:Number = _rawData[2] * theVecX + _rawData[6] * theVecY + _rawData[10] * theVecZ + _rawData[14];
			var theNewW:Number = _rawData[3] * theVecX + _rawData[7] * theVecY + _rawData[11] * theVecZ + _rawData[15];

			var theVector:Vector3D = new Vector3D(theNewX, theNewY, theNewZ, theNewW);
			return theVector;
		}
		
		/**
		 * The inverse transformation of the matrix. Note this function is inplace and alters the matrix.
		 */ 
		public function invert():Boolean
		{
			// Code is optimized ugly.
			var theEntry00:Number = _rawData[0]; var theEntry01:Number = _rawData[1]; var theEntry02:Number = _rawData[2]; var theEntry03:Number = _rawData[3];
			var theEntry10:Number = _rawData[4]; var theEntry11:Number = _rawData[5]; var theEntry12:Number = _rawData[6]; var theEntry13:Number = _rawData[7];
			var theEntry20:Number = _rawData[8]; var theEntry21:Number = _rawData[9]; var theEntry22:Number = _rawData[10]; var theEntry23:Number = _rawData[11];
			var theEntry30:Number = _rawData[12]; var theEntry31:Number = _rawData[13]; var theEntry32:Number = _rawData[14]; var theEntry33:Number = _rawData[15];
				
			var theCross00:Number = theEntry00 * theEntry11 - theEntry01 * theEntry10; var theCross01:Number = theEntry00 * theEntry12 - theEntry02 * theEntry10;
			var theCross02:Number = theEntry00 * theEntry13 - theEntry03 * theEntry10; var theCross03:Number = theEntry01 * theEntry12 - theEntry02 * theEntry11;
			var theCross04:Number = theEntry01 * theEntry13 - theEntry03 * theEntry11; var theCross05:Number = theEntry02 * theEntry13 - theEntry03 * theEntry12;
			var theCross06:Number = theEntry20 * theEntry31 - theEntry21 * theEntry30; var theCross07:Number = theEntry20 * theEntry32 - theEntry22 * theEntry30;
			var theCross08:Number = theEntry20 * theEntry33 - theEntry23 * theEntry30; var theCross09:Number = theEntry21 * theEntry32 - theEntry22 * theEntry31;
			var theCross10:Number = theEntry21 * theEntry33 - theEntry23 * theEntry31; var theCross11:Number = theEntry22 * theEntry33 - theEntry23 * theEntry32;
				
			var invDet:Number = 1 / (theCross00 * theCross11 - theCross01 * theCross10 + theCross02 * theCross09 +
									 theCross03 * theCross08 - theCross04 * theCross07 + theCross05 * theCross06);
			if (!isFinite(invDet)) {
				trace("Matrix is no invertible.");
				return false;
			}
			
			_rawData[0] = (theEntry11 * theCross11 - theEntry12 * theCross10 + theEntry13 * theCross09) * invDet;
			_rawData[1] = (-theEntry01 * theCross11 + theEntry02 * theCross10 - theEntry03 * theCross09) * invDet;
			_rawData[2] = (theEntry31 * theCross05 - theEntry32 * theCross04 + theEntry33 * theCross03) * invDet;
			_rawData[3] = (-theEntry21 * theCross05 + theEntry22 * theCross04 - theEntry23 * theCross03) * invDet;
			_rawData[4] = (-theEntry10 * theCross11 + theEntry12 * theCross08 - theEntry13 * theCross07) * invDet;
			_rawData[5] = (theEntry00 * theCross11 - theEntry02 * theCross08 + theEntry03 * theCross07) * invDet;
			_rawData[6] = (-theEntry30 * theCross05 + theEntry32 * theCross02 - theEntry33 * theCross01) * invDet;
			_rawData[7] = (theEntry20 * theCross05 - theEntry22 * theCross02 + theEntry23 * theCross01) * invDet;
			_rawData[8] = (theEntry10 * theCross10 - theEntry11 * theCross08 + theEntry13 * theCross06) * invDet;
			_rawData[9] = (-theEntry00 * theCross10 + theEntry01 * theCross08 - theEntry03 * theCross06) * invDet;
			_rawData[10] = (theEntry30 * theCross04 - theEntry31 * theCross02 + theEntry33 * theCross00) * invDet;
			_rawData[11] = (-theEntry20 * theCross04 + theEntry21 * theCross02 - theEntry23 * theCross00) * invDet;
			_rawData[12] = (-theEntry10 * theCross09 + theEntry11 * theCross07 - theEntry12 * theCross06) * invDet;
			_rawData[13] = (theEntry00 * theCross09 - theEntry01 * theCross07 + theEntry02 * theCross06) * invDet;
			_rawData[14] = (-theEntry30 * theCross03 + theEntry31 * theCross01 - theEntry32 * theCross00) * invDet;
			_rawData[15] = (theEntry20 * theCross03 - theEntry21 * theCross01 + theEntry22 * theCross00) * invDet;
			
			return true;
		}
		
		/**
		 * Prepends a matrix by multiplying the current Matrix3D object by another Matrix3D object. 
		 * The result combines both matrix transformations. 
		 */ 
		public function prepend(aOtherMatrix:Matrix3D):void
		{
			var theEntry00:Number = _rawData[0]; var theEntry01:Number = _rawData[1];
			var theEntry02:Number = _rawData[2]; var theEntry03:Number = _rawData[3];
			var theEntry10:Number = _rawData[4]; var theEntry11:Number = _rawData[5];
			var theEntry12:Number = _rawData[6]; var theEntry13:Number = _rawData[7];
			var theEntry20:Number = _rawData[8]; var theEntry21:Number = _rawData[9];
			var theEntry22:Number = _rawData[10]; var theEntry23:Number = _rawData[11];
			var theEntry30:Number = _rawData[12]; var theEntry31:Number = _rawData[13];
			var theEntry32:Number = _rawData[14]; var theEntry33:Number = _rawData[15];
				
			var theOther00:Number = aOtherMatrix.getRawData()[0]; var theOther01:Number = aOtherMatrix.getRawData()[1];
			var theOther02:Number = aOtherMatrix.getRawData()[2]; var theOther03:Number = aOtherMatrix.getRawData()[3];
			var theOther10:Number = aOtherMatrix.getRawData()[4]; var theOther11:Number = aOtherMatrix.getRawData()[5];
			var theOther12:Number = aOtherMatrix.getRawData()[6]; var theOther13:Number = aOtherMatrix.getRawData()[7];
			var theOther20:Number = aOtherMatrix.getRawData()[8]; var theOther21:Number = aOtherMatrix.getRawData()[9];
			var theOther22:Number = aOtherMatrix.getRawData()[10]; var theOther23:Number = aOtherMatrix.getRawData()[11];
			var theOther30:Number = aOtherMatrix.getRawData()[12]; var theOther31:Number = aOtherMatrix.getRawData()[13];
			var theOther32:Number = aOtherMatrix.getRawData()[14]; var theOther33:Number = aOtherMatrix.getRawData()[15];
			
			_rawData[0] = theOther00 * theEntry00 + theOther01 * theEntry10 + theOther02 * theEntry20 + theOther03 * theEntry30;
			_rawData[1] = theOther00 * theEntry01 + theOther01 * theEntry11 + theOther02 * theEntry21 + theOther03 * theEntry31;
			_rawData[2] = theOther00 * theEntry02 + theOther01 * theEntry12 + theOther02 * theEntry22 + theOther03 * theEntry32;
			_rawData[3] = theOther00 * theEntry03 + theOther01 * theEntry13 + theOther02 * theEntry23 + theOther03 * theEntry33;
			_rawData[4] = theOther10 * theEntry00 + theOther11 * theEntry10 + theOther12 * theEntry20 + theOther13 * theEntry30;
			_rawData[5] = theOther10 * theEntry01 + theOther11 * theEntry11 + theOther12 * theEntry21 + theOther13 * theEntry31;
			_rawData[6] = theOther10 * theEntry02 + theOther11 * theEntry12 + theOther12 * theEntry22 + theOther13 * theEntry32;
			_rawData[7] = theOther10 * theEntry03 + theOther11 * theEntry13 + theOther12 * theEntry23 + theOther13 * theEntry33;
			_rawData[8] = theOther20 * theEntry00 + theOther21 * theEntry10 + theOther22 * theEntry20 + theOther23 * theEntry30;
			_rawData[9] = theOther20 * theEntry01 + theOther21 * theEntry11 + theOther22 * theEntry21 + theOther23 * theEntry31;
			_rawData[10] = theOther20 * theEntry02 + theOther21 * theEntry12 + theOther22 * theEntry22 + theOther23 * theEntry32;
			_rawData[11] = theOther20 * theEntry03 + theOther21 * theEntry13 + theOther22 * theEntry23 + theOther23 * theEntry33;
			_rawData[12] = theOther30 * theEntry00 + theOther31 * theEntry10 + theOther32 * theEntry20 + theOther33 * theEntry30;
			_rawData[13] = theOther30 * theEntry01 + theOther31 * theEntry11 + theOther32 * theEntry21 + theOther33 * theEntry31;
			_rawData[14] = theOther30 * theEntry02 + theOther31 * theEntry12 + theOther32 * theEntry22 + theOther33 * theEntry32;
			_rawData[15] = theOther30 * theEntry03 + theOther31 * theEntry13 + theOther32 * theEntry23 + theOther33 * theEntry33;
		}
		
		/**
		 * Appends the matrix by multiplying another Matrix3D object by the current Matrix3D object.
		 * The result combines both matrix transformations. You can multiply a Matrix3D object by
		 * many matrixes. The final Matrix3D object contains the result of all the transformations. 
		 */ 
		public function append(aOtherMatrix:Matrix3D):void
		{
			var theEntry00:Number = aOtherMatrix.getRawData()[0]; var theEntry01:Number = aOtherMatrix.getRawData()[1];
			var theEntry02:Number = aOtherMatrix.getRawData()[2]; var theEntry03:Number = aOtherMatrix.getRawData()[3];
			var theEntry10:Number = aOtherMatrix.getRawData()[4]; var theEntry11:Number = aOtherMatrix.getRawData()[5];
			var theEntry12:Number = aOtherMatrix.getRawData()[6]; var theEntry13:Number = aOtherMatrix.getRawData()[7];
			var theEntry20:Number = aOtherMatrix.getRawData()[8]; var theEntry21:Number = aOtherMatrix.getRawData()[9];
			var theEntry22:Number = aOtherMatrix.getRawData()[10]; var theEntry23:Number = aOtherMatrix.getRawData()[11];
			var theEntry30:Number = aOtherMatrix.getRawData()[12]; var theEntry31:Number = aOtherMatrix.getRawData()[13];
			var theEntry32:Number = aOtherMatrix.getRawData()[14]; var theEntry33:Number = aOtherMatrix.getRawData()[15];
			
			var theOther00:Number = _rawData[0]; var theOther01:Number = _rawData[1];
			var theOther02:Number = _rawData[2]; var theOther03:Number = _rawData[3];
			var theOther10:Number = _rawData[4]; var theOther11:Number = _rawData[5];
			var theOther12:Number = _rawData[6]; var theOther13:Number = _rawData[7];
			var theOther20:Number = _rawData[8]; var theOther21:Number = _rawData[9];
			var theOther22:Number = _rawData[10]; var theOther23:Number = _rawData[11];
			var theOther30:Number = _rawData[12]; var theOther31:Number = _rawData[13];
			var theOther32:Number = _rawData[14]; var theOther33:Number = _rawData[15];
			
			_rawData[0] = theOther00 * theEntry00 + theOther01 * theEntry10 + theOther02 * theEntry20 + theOther03 * theEntry30;
			_rawData[1] = theOther00 * theEntry01 + theOther01 * theEntry11 + theOther02 * theEntry21 + theOther03 * theEntry31;
			_rawData[2] = theOther00 * theEntry02 + theOther01 * theEntry12 + theOther02 * theEntry22 + theOther03 * theEntry32;
			_rawData[3] = theOther00 * theEntry03 + theOther01 * theEntry13 + theOther02 * theEntry23 + theOther03 * theEntry33;
			_rawData[4] = theOther10 * theEntry00 + theOther11 * theEntry10 + theOther12 * theEntry20 + theOther13 * theEntry30;
			_rawData[5] = theOther10 * theEntry01 + theOther11 * theEntry11 + theOther12 * theEntry21 + theOther13 * theEntry31;
			_rawData[6] = theOther10 * theEntry02 + theOther11 * theEntry12 + theOther12 * theEntry22 + theOther13 * theEntry32;
			_rawData[7] = theOther10 * theEntry03 + theOther11 * theEntry13 + theOther12 * theEntry23 + theOther13 * theEntry33;
			_rawData[8] = theOther20 * theEntry00 + theOther21 * theEntry10 + theOther22 * theEntry20 + theOther23 * theEntry30;
			_rawData[9] = theOther20 * theEntry01 + theOther21 * theEntry11 + theOther22 * theEntry21 + theOther23 * theEntry31;
			_rawData[10] = theOther20 * theEntry02 + theOther21 * theEntry12 + theOther22 * theEntry22 + theOther23 * theEntry32;
			_rawData[11] = theOther20 * theEntry03 + theOther21 * theEntry13 + theOther22 * theEntry23 + theOther23 * theEntry33;
			_rawData[12] = theOther30 * theEntry00 + theOther31 * theEntry10 + theOther32 * theEntry20 + theOther33 * theEntry30;
			_rawData[13] = theOther30 * theEntry01 + theOther31 * theEntry11 + theOther32 * theEntry21 + theOther33 * theEntry31;
			_rawData[14] = theOther30 * theEntry02 + theOther31 * theEntry12 + theOther32 * theEntry22 + theOther33 * theEntry32;
			_rawData[15] = theOther30 * theEntry03 + theOther31 * theEntry13 + theOther32 * theEntry23 + theOther33 * theEntry33;
		}
	}
}