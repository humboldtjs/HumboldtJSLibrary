package com.humboldtjs.utility
{
	public class ArrayUtils
	{
		/**
		 * Arrays are equal if the sequence of array members are equal by reference.
		 * If the order does not matter the arrays need to be sorted first. In case
		 * array members contain references to objects, equality is base on references
		 * and not on the actual data within the object.
		 */
		[AutoScope=false]
		public static function areEqual(aArray:Array, aOtherArray:Array):Boolean
		{
			if (aArray === aOtherArray) return true;
			if (aArray == null || aOtherArray == null) return false;
			if (!(aArray is Array) || !(aOtherArray is Array)) return false;
			if (aArray.length != aOtherArray.length) return false;
			
			for (var theIndex:int = 0; theIndex < aOtherArray.length; ++theIndex) {
				if (aArray[theIndex] !== aOtherArray[theIndex]) return false;
			}
			return true;
		}
	}
}