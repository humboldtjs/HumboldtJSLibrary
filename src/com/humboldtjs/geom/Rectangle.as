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
		protected var _x:Number;
		protected var _y:Number;
		protected var _width:Number;
		protected var _height:Number;

		public function getX():Number												{ return _x; }
		public function setX(aValue:Number):void									{ _x = aValue; }

		public function getY():Number												{ return _y; }
		public function setY(aValue:Number):void									{ _y = aValue; }

		public function getWidth():Number											{ return _width; }
		public function setWidth(aValue:Number):void								{ _width = aValue; }

		public function getHeight():Number											{ return _height; }
		public function setHeight(aValue:Number):void								{ _height = aValue; }

		public function Rectangle(aX:Number, aY:Number, aWidth:Number, aHeight:Number)
		{
			_x = aX;
			_y = aY;
			_width = aWidth;
			_height = aHeight;
		}
		
		public function clone():Rectangle
		{
			return new Rectangle(_x, _y, _width, _height);
		}
	}
}