/*
* HumboldtJSLibrary
* http://humboldtjs.com/
*
* Copyright (c) 2012 Daniël Haveman
* Licensed under the MIT license
* http://humboldtjs.com/license.html
*/
package com.humboldtjs.utility
{
    import com.humboldtjs.utility.easing.Sine;
    
    import dom.domobjects.HTMLElement;
    import dom.eventFunction;
    import dom.window;

	/**
	 * Time based animator. Can take an HTML element and perform simple
	 * linear time based animations. Takes into account things like vendor
	 * prefixes, and some browser differences (e.g. opacity).
	 * 
	 * Note that this operates on an HTML element, and will cause desync from its
	 * corresponding DisplayObject.
	 */
    public class Animator
	{
		protected var mElement:HTMLElement;
		protected var mAnimationMap:Array;
		protected var mTimer:int = -1;

		/**
		 * @constructor
		 */
		public function Animator(aElement:HTMLElement)
		{
			mAnimationMap = [];
			mElement = aElement;
		}
		
		/**
		 * Animate a property of the HTML element's style over towards a certain
		 * value over time. The value will automatically get rounded using the
		 * following algorithm:
		 * 
		 * newValue = Math.round(targetValue * aRoundFactor) / aRoundFactor
		 * 
		 * So to round to quarters you would enter aRoundFactor = 4.
		 * 
		 * When you animate a property you can prepend that property with a "-"
		 * symbol. If you do so the property will get prefixed with all the
		 * standard vender prefixes.
		 * 
		 * Note that the properties need to use the Javascript naming style!
		 * This means e.g. "fontSize" instead of "font-size".
		 * 
		 * @param aProperty The style property to animate using Javascript notation
		 * @param aValue The numerical value to animate towards
		 * @param aRoundFactor The factor to use when rounding the value
		 * @param aPostFix The string to append to the rounded value. E.g. "px" for style values that require it.
		 * @param aCompleteFunction The EventFunction that needs to be called when the animation is done
		 */
		public function animatePropertyTo(aProperty:String, aValue:Number, aRoundFactor:Number, aPostFix:String, aCompleteFunction:Function):void
		{
			var theStart:Number = parseFloat(mElement.style[aProperty].toString().split(aPostFix).join(""));
			if (isNaN(theStart)) theStart = 0;
			
			// First look if there is already an animation going on for this
			// property
			var theAnimation:Object = {};
			var theAnimationExists:Boolean = false;
			for (var i:int = 0; i < mAnimationMap.length; i++) {
				if (mAnimationMap[i].property == aProperty) {
					theAnimation = mAnimationMap[i];
					theAnimationExists = true;
				}
			}

			// If there is already an animation going on, and it has the same
			// end value, then we don't need to do anything
			if (theAnimationExists && theAnimation.end == aValue)
				return;
			
			// Otherwise set the properties for the animation
			theAnimation.property = aProperty;
			theAnimation.start = theStart;
			theAnimation.end = aValue;
			theAnimation.position = 0;
			theAnimation.speed = 0.05;
			theAnimation.roundFactor = aRoundFactor;
			theAnimation.postFix = aPostFix;
			theAnimation.complete = aCompleteFunction;
			
			// If it already existed we just updated the existing animation
			// otherwise we have to add it to the animation map
			if (!theAnimationExists)
				mAnimationMap.push(theAnimation);
			
			// And we make sure the animation is actually started
			if (mTimer == -1)
				animationLoop();
		}
		
		/**
		 * Stops the current animation.
		 */
		public function stop():void
		{
			for (var i:int = mAnimationMap.length - 1; i >= 0; i--) {
				mAnimationMap.splice(i, 1);				
			}
			
			if (mTimer > -1)
			{
				window.clearTimeout(mTimer);
				mTimer = -1;
			}
		}
		
		/**
		 * The main animation loop. Processes all currently running animations.
		 */
		protected function animationLoop():void
		{
			// Loop through the current map of running animations
			for (var i:int = mAnimationMap.length - 1; i >= 0; i--) {
				
				var theAnimation:Object = mAnimationMap[i];
				// Increment the time position
				theAnimation.position += theAnimation.speed;
				
				// Calculate the new value (using the rounding procedure as
				// mentioned in the documentation for animatePropertyTo
				var theValue:Number = Sine.ease(theAnimation.position, 0.5) * (theAnimation.end - theAnimation.start) + theAnimation.start;
				theValue = Math.round(theValue * theAnimation.roundFactor) / theAnimation.roundFactor;

				// Opacity is special. There we cannot simply set the value and
				// the vendor prefixes. Here we have to apply a specific IE
				// hack as well.
				// Also when the value == 1 we remove the opacity filter entirely
				// to prevent some redraw issues on mobile
				if (theAnimation.property == "opacity") {
					if (theValue == 1) {
						delete mElement.style[theAnimation.property];
						delete mElement.style["filter"];
					} else {
						mElement.style[theAnimation.property] = theValue.toString() + theAnimation.postFix;
						mElement.style["filter"] = 'alpha(opacity=' + theValue * 100 + ')';
					}
					if (theValue == 0) {
						mElement.style.display = "none";
					} else {
						mElement.style.display = "block";
					}
				} else {
					var theFinalValue:String = theValue.toString() + theAnimation.postFix;
					
					// If the property name is prefixed with a "-" we add all
					// the major vendor prefixes. Mainly for animating experimental
					// CSS3 properties.
					if (theAnimation.property.substr(0, 1) == "-") {
						var theKey:String = theAnimation.property.substr(1);
						var theUCName:String = theKey.substr(0, 1).toUpperCase() + theKey.substr(1); 
						mElement.style["Webkit" + theUCName] = theFinalValue;
						mElement.style["Ms" + theUCName] = theFinalValue;
						mElement.style["Moz" + theUCName] = theFinalValue;
						mElement.style["O" + theUCName] = theFinalValue;
					}
					mElement.style[theAnimation.property] = theFinalValue;
				}

				// If the animation is done, remove it from the list and
				// call the complete function
				if (theAnimation.position >= 1) {
					mAnimationMap.splice(i, 1);
					if (theAnimation.complete) {
						theAnimation.complete();
					}
				}
			}

			// And if there is anything more to animate call the animation loop
			// again after a short while.
			if (mAnimationMap.length > 0) {
				mTimer = window.setTimeout(eventFunction(this, animationLoop), 25);
			} else {
				mTimer = -1;
			}
		}
	}
}