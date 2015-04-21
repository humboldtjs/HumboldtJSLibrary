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
	import com.humboldtjs.display.Stage;
	import com.humboldtjs.events.HJSEvent;
	import com.humboldtjs.utility.easing.Sine;
	
	import dom.domobjects.HTMLElement;
	
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
		protected var _object:*;
		protected var _element:HTMLElement;
		protected var _animationMap:Array;
		protected var _hasEventListener:Boolean = false;
		
		public var ease:Function;
		
		public function getTarget():*
		{
			return _object;
		}
		
		public function isAnimating():Boolean
		{
			return _animationMap.length > 0;
		}
		
		/**
		 * @constructor
		 */
		public function Animator(aElement:*)
		{
			if (typeof aElement["getHtmlElement"] == "function") {
				_object = aElement;
				_element = aElement.getHtmlElement();
			} else {
				_object = null;
				_element = aElement;
			}
			_animationMap = [];
			ease = Sine.ease;
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
		 * @param aDuration The target duration in seconds to take. The actual time may differ slightly due to the actual achieved framerate
		 * @param aValue The numerical value to animate towards
		 * @param aRoundFactor The factor to use when rounding the value
		 * @param aPostFix The string to append to the rounded value. E.g. "px" for style values that require it.
		 * @param aCompleteFunction The EventFunction that needs to be called when the animation is done
		 * @param aPreFix An optional string to prepend to the rounded value. E.g. "translate(" for a transform.
		 */
		public function animatePropertyTo(aProperty:String, aDuration:Number, aValue:Number, aRoundFactor:Number, aPostFix:String, aCompleteFunction:Function = null, aPreFix:String = "", aDelay:Number = 0):void
		{
			var theStart:Number = NaN;
			var isFunction:Boolean = false;
			var theTestProperty:String = aProperty;
			if (theTestProperty.substr(0, 1) == "-") theTestProperty = theTestProperty.substr(1);
			
			var theGetter:String = "get" + theTestProperty.substr(0, 1).toUpperCase() + theTestProperty.substr(1);
			var theSetter:String = "set" + theTestProperty.substr(0, 1).toUpperCase() + theTestProperty.substr(1);
			if (_object != null &&
				typeof _object[theGetter] == "function" &&
				typeof _object[theSetter] == "function") {
				isFunction = true;
			}
			
			if (isFunction) {
				theStart = _object[theGetter]();
			} else {
				if (theTestProperty == "opacity" || theTestProperty == "autoOpacity" || theTestProperty == "alpha" || theTestProperty == "autoAlpha")
					theTestProperty = "opacity";
				try {
					theStart = parseFloat(_element.style[theTestProperty].toString().split(aPostFix).join("").split(aPreFix).join(""));
				} catch(e:Error) {}
			}
			
			if (isNaN(theStart)) {
				if (theTestProperty == "opacity") {
					theStart = 1;
				} else {
					theStart = 0;
				}
			}
			
			if (theTestProperty == "opacity") {
				var theDisplayState:String = "block";
				try {
					theDisplayState = _element.style.display;
				} catch(e:Error) {}
				
				theStart = theDisplayState == "none" ? 0 : theStart;
			}
			
			// First look if there is already an animation going on for this
			// property
			var theAnimation:Object = {};
			var theAnimationExists:Boolean = false;
			for (var i:int = 0; i < _animationMap.length; i++) {
				if (_animationMap[i].property == aProperty) {
					theAnimation = _animationMap[i];
					theAnimationExists = true;
				}
			}
			
			// If there is already an animation going on, and it has the same
			// end value, then we don't need to do anything
			if (theAnimationExists && theAnimation.end == aValue)
				return;
			
			// Otherwise set the properties for the animation
			if (isFunction) {
				theAnimation.property = theSetter;
			} else {
				theAnimation.property = aProperty;
			}
			theAnimation.isFunction = isFunction;
			theAnimation.start = theStart;
			theAnimation.end = aValue;
			theAnimation.position = 0;
			theAnimation.time = (new Date()).getTime() / 1000 + aDelay;
			theAnimation.duration = aDuration;
			theAnimation.roundFactor = aRoundFactor;
			theAnimation.postFix = aPostFix;
			theAnimation.preFix = aPreFix;
			theAnimation.complete = aCompleteFunction;
			
			// If it already existed we just updated the existing animation
			// otherwise we have to add it to the animation map
			if (!theAnimationExists)
				_animationMap.push(theAnimation);
			
			// And we make sure the animation is actually started
			if (!_hasEventListener) {
				Stage.getInstance().addEventListener(HJSEvent.ENTER_FRAME, animationLoop);
				_hasEventListener = true;
			}
		}
		
		/**
		 * Stops the current animation.
		 */
		public function stop():void
		{
			for (var i:int = _animationMap.length - 1; i >= 0; i--) {
				_animationMap.splice(i, 1);				
			}
			
			Stage.getInstance().removeEventListener(HJSEvent.ENTER_FRAME, animationLoop);
			_hasEventListener = false;
		}
		
		/**
		 * The main animation loop. Processes all currently running animations.
		 */
		protected function animationLoop(aEvent:HJSEvent):void
		{
			// Loop through the current map of running animations
			for (var i:int = _animationMap.length - 1; i >= 0; i--) {
				
				var theAnimation:Object = _animationMap[i];
				// Increment the time position
				theAnimation.position = ((new Date()).getTime() / 1000 - theAnimation.time) / theAnimation.duration;
				if (theAnimation.position < 0) theAnimation.position = 0;
				if (theAnimation.position > 1) theAnimation.position = 1;
				
				// Calculate the new value (using the rounding procedure as
				// mentioned in the documentation for animatePropertyTo
				var theValue:* = ease(theAnimation.position, 0.5) * (theAnimation.end - theAnimation.start) + theAnimation.start;
				theValue = Math.round(theValue * theAnimation.roundFactor) / theAnimation.roundFactor;
				
				if (theAnimation.isFunction) {
					_object[theAnimation.property](theValue);
				} else {
					theValue = theAnimation.preFix + theValue.toString() + theAnimation.postFix;
					
					var theObject:Object = {};
					theObject[theAnimation.property] = theValue;
					
					EasyStyler.applyStyleObject(_element, theObject);
				}
				
				// If the animation is done, remove it from the list and
				// call the complete function
				if (theAnimation.position >= 1) {
					_animationMap.splice(i, 1);
					if (theAnimation.complete) {
						theAnimation.complete(this);
					}
				}
			}
			
			// And if there is anything more to animate call the animation loop
			// again after a short while.
			if (_animationMap.length == 0) {
				Stage.getInstance().removeEventListener(HJSEvent.ENTER_FRAME, animationLoop);
				_hasEventListener = false;
			}
		}
	}
}