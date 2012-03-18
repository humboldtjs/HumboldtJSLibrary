/*
* HumboldtJSLibrary
* http://humboldtjs.com/
*
* Copyright (c) 2012 Daniël Haveman
* Licensed under the MIT license
* http://humboldtjs.com/license.html
*/
package com.humboldtjs.display
{
	import com.humboldtjs.events.EventDispatcher;
	import com.humboldtjs.system.Application;
	
	import dom.document;
	import dom.domobjects.HTMLElement;

	/**
	 * The standard DisplayObject. This is modelled after the Flash
	 * DisplayObject and can be used in very similar way. Each DisplayObject
	 * will by default create a corresponding HTML DIV element. When extending
	 * DisplayObject you can change what type of HTML element gets created
	 * by setting the mElementType before calling the super() in the constructor.
	 */
	public class DisplayObject extends EventDispatcher
	{
		protected var mElement:HTMLElement;
		protected var mElementType:String = "";
		protected var mChildren:Array;
		
		protected var mX:Number = -999999;
		protected var mY:Number = -999999;
		protected var mZIndex:int = 0;
		protected var mRight:Number = -999999;
		protected var mBottom:Number = -999999;
		protected var mWidth:Number = -1;
		protected var mHeight:Number = -1;
		protected var mPercentWidth:Number = -1;
		protected var mPercentHeight:Number = -1;
		protected var mAlpha:Number = 1;
		protected var mVisible:Boolean = true;
		protected var mParent:DisplayObject = null;
		
		/**
		 * Set the parent element. This is called from within addChild.
		 */
		protected function setParent(aParent:DisplayObject):void
		{
			mParent = aParent;
		}
		
		/**
		 * The current instance's parent DisplayObject
		 */
		public function getParent():DisplayObject { return mParent; }
		
		/**
		 * A reference to the Stage object if we can find it. If not will return null
		 */
		public function getStage():Stage
		{
			var theApplication:Application = getApplication();
			if (theApplication == null)
				return null;
			
			return getApplication().getStage();
		}
		
		/**
		 * A reference to the root Application object if we can find it. If not
		 * will return null
		 */
		public function getApplication():Application
		{
			var theApplication:DisplayObject = this;
			
			while (!(theApplication is Application) && (theApplication != null)) {
				theApplication = theApplication.getParent();
			}
			if (theApplication == null)
				return null;
			
			return theApplication as Application;
		}
		
		/**
		 * The z-index
		 */
		public function getZIndex():Number { return mZIndex; }
		/**
		 * The z-index
		 */
		public function setZIndex(value:Number):void
		{
			if (mZIndex == value) return;
			mZIndex = value;
			mElement.style.zIndex = "" + Math.round(value);
		}
		
		/**
		 * The visibility
		 */
		public function getVisible():Boolean { return mVisible; }
		/**
		 * The visibility
		 */
		public function setVisible(value:Boolean):void
		{
			if (mVisible == value) return;
			mVisible = value;
			mElement.style.display = mVisible ? "block" : "none";
		}
		
		/**
		 * The opacity
		 */
		public function getAlpha():Number { return mAlpha; }
		/**
		 * The opacity
		 */
		public function setAlpha(value:Number):void
		{
			if (mAlpha == value) return;
			mAlpha = value;
			mElement.style.opacity = mAlpha.toFixed(1);
			mElement.style.filter = "alpha(opacity=" + Math.round(mAlpha * 100) + ")";
			if (mAlpha == 0) {
				mElement.style.display = "none";
			} else {
				mElement.style.display = "block";
			}
		}
		
		/**
		 * The x position (left)
		 */
		public function getX():Number { return mX; }
		/**
		 * The x position (left)
		 */
		public function setX(value:Number):void
		{
			if (mX == value) return;
			mX = value;
			if (isNaN(mX))
				mElement.style.left = null;
			else
				mElement.style.left = Math.round(mX) + "px";
		}
		
		/**
		 * The right position
		 */
		public function getRight():Number { return mRight; }
		/**
		 * The right position
		 */
		public function setRight(value:Number):void
		{
			if (mRight == value) return;
			mRight = value;
			if (isNaN(mRight))
				mElement.style.right = null;
			else
				mElement.style.right = Math.round(mRight) + "px";
		}
		
		/**
		 * The y position (top)
		 */
		public function getY():Number { return mY; }
		/**
		 * The y position (top)
		 */
		public function setY(value:Number):void
		{
			if (mY == value) return;
			mY = value;
			if (isNaN(mY))
				mElement.style.top = null;
			else
				mElement.style.top = Math.round(mY) + "px";
		}
		
		/**
		 * The bottom position
		 */
		public function getBottom():Number { return mBottom; }
		/**
		 * The bottom position
		 */
		public function setBottom(value:Number):void
		{
			if (mBottom == value) return;
			mBottom = value;
			if (isNaN(mBottom))
				mElement.style.bottom = null;
			else
				mElement.style.bottom = Math.round(mBottom) + "px";
		}
		
		/**
		 * The scaleX. Only provided for compatibility with Flash.
		 * ScaleX will always return 1 and setting it will be ignored.
		 */
		public function getScaleX():Number { return 1; }
		/**
		 * The scaleX. Only provided for compatibility with Flash.
		 * ScaleX will always return 1 and setting it will be ignored.
		 */
		public function setScaleX(value:Number):void {}

		/**
		 * The scaleY. Only provided for compatibility with Flash.
		 * ScaleY will always return 1 and setting it will be ignored.
		 */
		public function getScaleY():Number { return 1; }
		/**
		 * The scaleY. Only provided for compatibility with Flash.
		 * ScaleY will always return 1 and setting it will be ignored.
		 */
		public function setScaleY(value:Number):void {}
		
		/**
		 * The unscaledWidth
		 */
		public function getUnscaledWidth():Number { return mElement.clientWidth; }
		/**
		 * The unscaledHeight
		 */
		public function getUnscaledHeight():Number { return mElement.clientHeight; }
		
		/**
		 * The width
		 */
		public function getWidth():Number { return Math.max(0, mWidth); }
		/**
		 * The width
		 */
		public function setWidth(value:Number):void
		{
			if (mWidth == value) return;
			mWidth = value;
			mPercentHeight = NaN;
			if (isNaN(mWidth))
				mElement.style.width = null;
			else
				mElement.style.width = Math.round(mWidth) + "px";
		}
		
		/**
		 * The height
		 */
		public function getHeight():Number { return Math.max(0, mHeight); }
		/**
		 * The height
		 */
		public function setHeight(value:Number):void
		{
			if (mHeight == value) return;
			mHeight = value;
			mPercentHeight = NaN;
			if (isNaN(mHeight))
				mElement.style.height = null;
			else
				mElement.style.height = Math.round(mHeight) + "px";
		}
		
		/**
		 * The width as a percentage
		 */
		public function getPercentWidth():Number { return Math.max(0, mPercentWidth); }
		/**
		 * The width as a percentage
		 */
		public function setPercentWidth(value:Number):void
		{
			if (mPercentWidth == value) return;
			mPercentWidth = value;
			mWidth = NaN;
			if (isNaN(mPercentWidth))
				mElement.style.width = null;
			else
				mElement.style.width = Math.round(mPercentWidth) + "%";
		}
		
		/**
		 * The height as a percentage
		 */
		public function getPercentHeight():Number { return Math.max(0, mPercentHeight); }
		/**
		 * The height as a percentage
		 */
		public function setPercentHeight(value:Number):void
		{
			if (mPercentHeight == value) return;
			mPercentHeight = value;
			mHeight = NaN;
			if (isNaN(mPercentHeight))
				mElement.style.height = null;
			else
				mElement.style.height = Math.round(mPercentHeight) + "%";
		}
		
		/**
		 * The DisplayObject's HTMLElement
		 */
		public function getHtmlElement():HTMLElement { return mElement; }
		
		/**
		 * The number of children this DisplayObject has
		 */
		public function getNumChildren():int { return mChildren.length; }
		
		/**
		 * @constructor
		 */
		public function DisplayObject()
		{
			super();
			
			if (mElementType == "" && mElement == null) {
				mElementType = "div";
			}
			
			mElement = document.createElement(mElementType);
			mElement.style.position = "absolute";
			mElement.style.zIndex = "0";
			
			setX(0);
			setY(0);
			
			mChildren = new Array();
		}
		
		/**
		 * Add a DisplayObject as a child to this DisplayObject. Automatically
		 * sets the child's parent to this.
		 * 
		 * @param aChild The child to add
		 */
		public function addChild(aChild:DisplayObject):void
		{
			var theIndex:int = mChildren.indexOf(aChild);

			// If the element already exists as a child, we first remove it
			// this makes sure that the child is added at the top later
			if (theIndex != -1) {
				if (theIndex != mChildren.length - 1) {
					mChildren.splice(theIndex, 1);
				} else {
					return;
				}
			}
			
			mChildren.push(aChild);
			mElement.appendChild(aChild.getHtmlElement());
			
			aChild.setParent(this);
		}
		
		/**
		 * Add a DisplayObject as a child to this DisplayObject at a certain
		 * position. If you have not touched the z-index this influences the
		 * draw order. Also automatically sets the child's parent to this.
		 * 
		 * @param aChild The child to add
		 * @param aIndex The position to add the child at
		 */
		public function addChildAt(aChild:DisplayObject, aIndex:int):void
		{
			var theIndex:int = mChildren.indexOf(aChild);

			// If the element already exists as a child, we first remove it
			// this makes sure that the child is added at the top later
			if (theIndex != -1) {
				if (theIndex != mChildren.length - 1) {
					mChildren.splice(theIndex, 1);
				} else {
					return;
				}
			}

			// If the position to add the child at is too high (larger than
			// the current number of children) then just add it at the top
			if (aIndex >= mChildren.length) {
				addChild(aChild);
				return;
			}
			
			// Otherwise add it at the requested position
			mChildren.splice(aIndex, 0, aChild);
			mElement.insertBefore(aChild.getHtmlElement(), mElement.childNodes[aIndex]);
			
			aChild.setParent(this);
		}
		
		/**
		 * Remove a child DisplayObject from this DisplayObject
		 * 
		 * @param aChild The DisplayObject to remove
		 */
		public function removeChild(aChild:DisplayObject):void
		{
			if (mChildren.indexOf(aChild) == -1) return;
			
			removeChildAt(mChildren.indexOf(aChild));
		}
		
		/**
		 * Remove a the child DisplayObject at the given index from this DisplayObject
		 * 
		 * @param aIndex The index at which to remove the child
		 */
		public function removeChildAt(aIndex:int):void
		{
			var theChild:DisplayObject = mChildren[aIndex];
			
			mChildren.splice(aIndex, 1);
			mElement.removeChild(theChild.getHtmlElement());
			
			theChild.setParent(null);
		}
		
		/**
		 * Return the child at the given index
		 * 
		 * @param aIndex The index at which to find the child
		 * @return The DisplayObject at the given index 
		 */
		public function getChildAt(aIndex:int):DisplayObject
		{
			return mChildren[aIndex];
		}
	}
}