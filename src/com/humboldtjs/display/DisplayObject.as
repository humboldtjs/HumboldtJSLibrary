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
	 * by overriding the initializeElement method.
	 */
	public class DisplayObject extends EventDispatcher
	{
		public static const DEFAULT_DATA_ID_ATTRIBUTE_NAME:String = "data-id";
		
		protected var _element:HTMLElement;
		protected var _classNames:Array = null;
		protected var _children:Array;
		
		protected var _x:Number = -999999;
		protected var _y:Number = -999999;
		protected var _zIndex:int = 0;
		protected var _right:Number = -999999;
		protected var _bottom:Number = -999999;
		protected var _width:Number = -1;
		protected var _height:Number = -1;
		protected var _percentWidth:Number = -1;
		protected var _percentHeight:Number = -1;
		protected var _alpha:Number = 1;
		protected var _visible:Boolean = true;
		protected var _parent:DisplayObject = null;
		protected var _dataIdAttributeName:String = DEFAULT_DATA_ID_ATTRIBUTE_NAME;
		protected var _dataId:String = "";
		
		/**
		 * Add a classname to the HTML element used to render this displayobject.
		 * This requires the className to be defined in an external css.
		 * 
		 * @param The classname to add
		 */
		public function addClassName(aClassName:String):void
		{
			if (_classNames == null) _classNames = new Array();
			if (_classNames.indexOf(aClassName) == -1) {
				_classNames.push(aClassName);
			}
			if (_element != null) {
				_element.className = _classNames.join(" ");
			}
		}
		
		/**
		 * Remove a classname from the HTML element used to render this displayobject.
		 * 
		 * @param The className to remove
		 */
		public function removeClassName(aClassName:String):void
		{
			if (_classNames == null) _classNames = new Array();
			if (_classNames.indexOf(aClassName) != -1) {
				_classNames.splice(_classNames.indexOf(aClassName), 1);
			}
			if (_element != null) {
				_element.className = _classNames.join(" ");
			}
		}
		
		/**
		 * Set the parent element. This is called from within addChild.
		 */
		protected function setParent(aParent:DisplayObject):void
		{
			_parent = aParent;
		}
		
		/**
		 * The current instance's parent DisplayObject
		 */
		public function getParent():DisplayObject { return _parent; }
		
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
		public function getZIndex():int { return _zIndex; }
		/**
		 * The z-index
		 */
		public function setZIndex(value:int):void
		{
			if (_zIndex == value) return;
			_zIndex = value;
			_element.style.zIndex = "" + value;
		}
		
		/**
		 * The visibility
		 */
		public function getVisible():Boolean { return _visible; }
		/**
		 * The visibility
		 */
		public function setVisible(value:Boolean):void
		{
			if (_visible == value) return;
			_visible = value;
			_element.style.display = _visible ? "block" : "none";
		}
		
		/**
		 * The opacity
		 */
		public function getAlpha():Number { return _alpha; }
		/**
		 * The opacity
		 */
		public function setAlpha(value:Number):void
		{
			if (_alpha == value) return;
			_alpha = value;
			_element.style.opacity = _alpha.toFixed(1);
			_element.style.filter = "alpha(opacity=" + Math.round(_alpha * 100) + ")";
			if (_alpha == 0) {
				_element.style.display = "none";
			} else {
				_element.style.display = "block";
			}
		}
		
		/**
		 * The x position (left)
		 */
		public function getX():Number { return _x; }
		/**
		 * The x position (left)
		 */
		public function setX(value:Number):void
		{
			if (_x == value) return;
			_x = value;
			if (isNaN(_x))
				_element.style.left = null;
			else
				_element.style.left = _x + "px";
		}
		
		/**
		 * The right position
		 */
		public function getRight():Number { return _right; }
		/**
		 * The right position
		 */
		public function setRight(value:Number):void
		{
			if (_right == value) return;
			_right = value;
			if (isNaN(_right))
				_element.style.right = null;
			else
				_element.style.right = _right + "px";
		}
		
		/**
		 * The y position (top)
		 */
		public function getY():Number { return _y; }
		/**
		 * The y position (top)
		 */
		public function setY(value:Number):void
		{
			if (_y == value) return;
			_y = value;
			if (isNaN(_y))
				_element.style.top = null;
			else
				_element.style.top = _y + "px";
		}
		
		/**
		 * The bottom position
		 */
		public function getBottom():Number { return _bottom; }
		/**
		 * The bottom position
		 */
		public function setBottom(value:Number):void
		{
			if (_bottom == value) return;
			_bottom = value;
			if (isNaN(_bottom))
				_element.style.bottom = null;
			else
				_element.style.bottom = _bottom + "px";
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
		public function getUnscaledWidth():Number { return _element.clientWidth; }
		/**
		 * The unscaledHeight
		 */
		public function getUnscaledHeight():Number { return _element.clientHeight; }
		
		/**
		 * The width
		 */
		public function getWidth():Number { return Math.max(0, _width); }
		/**
		 * The width
		 */
		public function setWidth(value:Number):void
		{
			if (_width == value) return;
			_width = value;
			_percentWidth = NaN;
			if (isNaN(_width))
				_element.style.width = null;
			else
				_element.style.width = _width + "px";
		}
		
		/**
		 * The height
		 */
		public function getHeight():Number { return Math.max(0, _height); }
		/**
		 * The height
		 */
		public function setHeight(value:Number):void
		{
			if (_height == value) return;
			_height = value;
			_percentHeight = NaN;
			if (isNaN(_height))
				_element.style.height = null;
			else
				_element.style.height = _height + "px";
		}
		
		/**
		 * The width as a percentage
		 */
		public function getPercentWidth():Number { return Math.max(0, _percentWidth); }
		/**
		 * The width as a percentage
		 */
		public function setPercentWidth(value:Number):void
		{
			if (_percentWidth == value) return;
			_percentWidth = value;
			_width = NaN;
			if (isNaN(_percentWidth))
				_element.style.width = null;
			else
				_element.style.width = _percentWidth + "%";
		}
		
		/**
		 * The height as a percentage
		 */
		public function getPercentHeight():Number { return Math.max(0, _percentHeight); }
		/**
		 * The height as a percentage
		 */
		public function setPercentHeight(value:Number):void
		{
			if (_percentHeight == value) return;
			_percentHeight = value;
			_height = NaN;
			if (isNaN(_percentHeight))
				_element.style.height = null;
			else
				_element.style.height = _percentHeight + "%";
		}
		
		/**
		 * Get the name of the attribute itself (instead of the value) used on the DOM. 
		 */
		public function getDataIdAttributeName():String { return _dataIdAttributeName; }
		/**
		 * Set the name of the attribute itself (instead of the value) used on the DOM.
		 * In case the attribute was already added, the function performs an update. 
		 */
		public function setDataIdAttributeName(value:String):void
		{
			var theOldDataId:String = getDataId();
			if (theOldDataId != null && theOldDataId != "") {
				_element.removeAttribute(_dataIdAttributeName);
			}
			
			_dataIdAttributeName = value;
			
			if (theOldDataId != null && theOldDataId != "") {
				setDataId(theOldDataId);
			}
		}
		
		/**
		 * Get the data id name of the element on DOM.
		 * Returns null or "" when the attribute has not been set.
		 */
		public function getDataId():String { return _element.getAttribute(_dataIdAttributeName); }
		/**
		 * Set the data id name of the element on DOM.
		 */
		public function setDataId(value:String):void
		{
			_element.setAttribute(_dataIdAttributeName, value);
		}
		
		/**
		 * The DisplayObject's HTMLElement
		 */
		public function getHtmlElement():HTMLElement { return _element; }
		
		/**
		 * The number of children this DisplayObject has
		 */
		public function getNumChildren():int { return _children.length; }
		
		/**
		 * @constructor
		 */
		public function DisplayObject()
		{
			super();
			
			initializeElement();
			initializeStyle();
			
			_children = new Array();
		}
		
		protected function initializeElement():void
		{
			_element = document.createElement("div");
		}
		
		protected function initializeStyle():void
		{
			if (_classNames == null) _classNames = new Array();
			if (_classNames.length == 0) {
				_element.style.position = "absolute";
				_element.style.zIndex = "0";
			
				setX(0);
				setY(0);
			} else {
				_element.className = _classNames.join(" ");
			}
		}
		
		/**
		 * Add a DisplayObject as a child to this DisplayObject. Automatically
		 * sets the child's parent to this.
		 * 
		 * @param aChild The child to add
		 */
		public function addChild(aChild:DisplayObject):void
		{
			var theIndex:int = _children.indexOf(aChild);

			// If the element already exists as a child, we first remove it
			// this makes sure that the child is added at the top later
			if (theIndex != -1) {
				if (theIndex != _children.length - 1) {
					_children.splice(theIndex, 1);
				} else {
					return;
				}
			}
			
			_children.push(aChild);
			_element.appendChild(aChild.getHtmlElement());
			
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
			var theIndex:int = _children.indexOf(aChild);

			// If the element already exists as a child, we first remove it
			// this makes sure that the child is added at the top later
			if (theIndex != -1) {
				if (theIndex != _children.length - 1) {
					_children.splice(theIndex, 1);
				} else {
					return;
				}
			}

			// If the position to add the child at is too high (larger than
			// the current number of children) then just add it at the top
			if (aIndex >= _children.length) {
				addChild(aChild);
				return;
			}
			
			// Otherwise add it at the requested position
			_children.splice(aIndex, 0, aChild);
			_element.insertBefore(aChild.getHtmlElement(), _element.childNodes[aIndex]);
			
			aChild.setParent(this);
		}
		
		/**
		 * Remove a child DisplayObject from this DisplayObject
		 * 
		 * @param aChild The DisplayObject to remove
		 */
		public function removeChild(aChild:DisplayObject):void
		{
			if (_children.indexOf(aChild) == -1) return;
			
			removeChildAt(_children.indexOf(aChild));
		}
		
		/**
		 * Remove a the child DisplayObject at the given index from this DisplayObject
		 * 
		 * @param aIndex The index at which to remove the child
		 */
		public function removeChildAt(aIndex:int):void
		{
			var theChild:DisplayObject = _children[aIndex];
			
			_children.splice(aIndex, 1);
			_element.removeChild(theChild.getHtmlElement());
			
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
			return _children[aIndex];
		}
	}
}