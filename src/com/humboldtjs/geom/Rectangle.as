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
	 * An object representing a Rectangle
	 */ 
	public class Rectangle
	{
		protected var mX:Number;
		protected var mY:Number;
		protected var mWidth:Number;
		protected var mHeight:Number;

		public function getX():Number												{ return mX; }
		public function setX(aValue:Number):void									{ mX = aValue; }

		public function getY():Number												{ return mY; }
		public function setY(aValue:Number):void									{ mY = aValue; }

		public function getWidth():Number											{ return mWidth; }
		public function setWidth(aValue:Number):void								{ mWidth = aValue; }

		public function getHeight():Number											{ return mHeight; }
		public function setHeight(aValue:Number):void								{ mHeight = aValue; }

		public function Rectangle(aX:Number, aY:Number, aWidth:Number, aHeight:Number)
		{
			mX = aX;
			mY = aY;
			mWidth = aWidth;
			mHeight = aHeight;
		}
		
		public function clone():Rectangle
		{
			return new Rectangle(mX, mY, mWidth, mHeight);
		}
	}
}