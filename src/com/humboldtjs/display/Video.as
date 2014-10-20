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
	import com.humboldtjs.events.DataEvent;
	import com.humboldtjs.events.HJSEvent;
	import com.humboldtjs.system.Capabilities;
	import com.humboldtjs.system.HtmlUtils;
	import com.humboldtjs.system.OperatingSystem;
	import com.humboldtjs.utility.EasyStyler;
	
	import dom.document;
	import dom.navigator;
	import dom.window;
	import dom.domobjects.Event;
	
	/**
	 * A simple Video class which deals with some of the weird issues with
	 * HTML5 video. This already supports a few different platforms and situations
	 * however you still have to determine whether to load an MP4 or WEBM
	 * using the Capabilities class first.
	 * 
	 * Note there are still numerous issues with various mobile browsers which
	 * have varying degrees of support for HTML5.
	 */
	public class Video extends DisplayObject implements ISrcDisplayObject
	{
		public static const VIDEO_MP4:String = "mp4";
		public static const VIDEO_WEBM:String = "webm";
		
		public static const EVENT_ENDED:String = "ended";
		public static const EVENT_TIME_CHANGED:String = "timechanged";
		
		// A required fuzz-factor to compare the time of the total video duration and that of the last buffered frame.
		public static const DURATION_TIME_FUZZINES:int = 0.5 / 25.0;
		
		protected var _hasVideo:Boolean = false;
		protected var _loopRunning:Boolean = false;
		protected var _src:String = "";
		
		protected var _ended:Boolean = false;
		protected var _paused:Boolean = true;
		protected var _currentTime:Number = 0;
		protected var _timer:int = -1;
		protected var _tries:int = 0;
		protected var _timeout:int = 0;
		
		/**
		 * The original video width
		 */
		override public function getUnscaledWidth():Number 		{ return _element.videoWidth; }
		/**
		 * The original video height
		 */
		override public function getUnscaledHeight():Number 	{ return _element.videoHeight; }
		
		/**
		 * The duration
		 */
		public function getDuration():Number 					{ return _element.duration; }
		
		/**
		 * The current playhead time
		 */
		public function getCurrentTime():Number 				{ return _element.currentTime; }
		/**
		 * The current playhead time
		 */
		public function setCurrentTime(value:Number):void
		{
			// Work around a bug on iPad where setting currentTime to 0 makes
			// later calls to currentTime stop working. This also prevents the
			// ended event being triggered.
			// @see http://stackoverflow.com/questions/3874070/missing-html5-video-ended-event-on-ipad
			if (value == 0)
				value = 0.01;

			if (isNaN(_element.duration)) return;
			_element.currentTime = value;
		}
		
		/**
		 * The source URL of the video.
		 */
		public function getSrc():String							{ return _src; }
		/**
		 * The source URL of the video.
		 */
		public function setSrc(value:String):void
		{
			if (_src != value) {
				_src = value;
				_hasVideo = false;
				_element.autoplay = false;
				_element.controls = false;
				_element.setAttribute("webkit-playsinline", 1);
				_element.setAttribute("playsinline", 1);

				pause();
				_element.src = value;
				
				_tries = 4;
				HtmlUtils.addHtmlEventListener(_element, "canplay", onCanPlay);
				HtmlUtils.addHtmlEventListener(_element, "canplaythrough", onLoadedFarEnough);
				HtmlUtils.addHtmlEventListener(_element, "load", onLoadedFarEnough);
				
				if (Capabilities.getOs() == OperatingSystem.IOS || Capabilities.getOs() == OperatingSystem.ANDROID) {
					play();
					
					if (Capabilities.getOs() == OperatingSystem.ANDROID) {
						// controls must be set to true because otherwise video
						// will sometimes only show up as a black square (on our
						// Samsung Galaxy S3). Setting controls to enabled will
						// make it render properly.
						_element.controls = true;
					}
				}

				clearTimer();
				
				handleLoadedFarEnough();
			}
		}
		
		/**
		 * Whether the video is loaded
		 */
		public function getHasVideo():Boolean					{ return _hasVideo; }
		
		/**
		 * @constructor
		 */
		public function Video()
		{
			super();
			
			EasyStyler.applyStyleObject(_element, {"position":"absolute","top":"-3000px","left":"-3000px"});
			document.body.appendChild(_element);
		}
		
		override protected function initializeElement():void
		{
			_element = document.createElement("video");
		}
		
		public function dispose():void
		{
			_hasVideo = false;
			
			// Clear the src attribute to make sure the video is garbage collected.
			_src = "";
			if (_element != null) { 
				if (_element.parentNode) {
					_element.parentNode.removeChild(_element);
				}
				window.setTimeout(removeSrc, 1000);
			}
			clearTimer();
			removeHtmlEventListeners();
		}
		
		public function removeSrc():void
		{
			if (_element) {
				_element.src = "";
			}
		}
		
		/**
		 * Return a copy of the Video with the same contents
		 */
		public function clone():ISrcDisplayObject
		{
			var theVideo:Video = new Video();
			theVideo.setSrc(getSrc());
			
			return theVideo;
		}
		
		/**
		 * Start video playback
		 */
		public function play():void
		{
			_element.play();
			_paused = false;
		}
		
		/**
		 * Pause video playback
		 */
		public function pause():void
		{
			_element.pause();
			_paused = true;
		}
		
		/**
		 * Removes html eventlisteners.
		 */ 
		protected function removeHtmlEventListeners():void
		{
			HtmlUtils.removeHtmlEventListener(_element, "canplay", onCanPlay);
			HtmlUtils.removeHtmlEventListener(_element, "canplaythrough", onLoadedFarEnough);
			HtmlUtils.removeHtmlEventListener(_element, "load", onLoadedFarEnough);			
		}

		/**
		 * Removes html eventlisteners.
		 */ 
		protected function clearTimer():void
		{
			if (_timer != -1) {
				window.clearTimeout(_timer);
				_timer = -1;
			}
		}
		
		protected function onCanPlay(aEvent:Event):void
		{
			if (Capabilities.getOs() != OperatingSystem.ANDROID) {
				pause();
			}
		}

		/**
		 * onLoadedFarEnough events on iOS devices, wait for these events
		 * before setting complete in order to not show QT logo
		 * @param aEvent
		 * 
		 */		
		protected function onLoadedFarEnough(aEvent:Event):void
		{
			removeHtmlEventListeners();
			
			handleLoadedFarEnough();
		}
		
		protected function handleLoadedFarEnough():void
		{
			clearTimer();
			
			// stop trying to load if we don't have a source
			if (_src == "")
				return;
			
			// If NETWORK_NO_SOURCE it means loading failed
			if (_element.error != null) {
				onLoadError();
				return;
			}
			
			// Also allow networkState 2; 'loading', as '1' may not always be set e.g. in chrome.
			// TODO: see if there is another way to signal that all data has been loaded.
			// Note: in principle we should also dispatch 'LoadedFarEnough' which is when readyState == 4. 
			if (_element.videoWidth == 0 ||
				_element.videoHeight == 0 ||
				_element.duration == 0 ||
				isNaN(_element.duration) ||
				!((_element.readyState == 4 ||
					_element.readyState == 3) &&
					(_element.networkState == 1 ||
						_element.networkState == 2))) {
				_timer = window.setTimeout(handleLoadedFarEnough, 100);
				return;
			}
			
			if (_element.readyState !== 4 && _tries > 0) {
				_tries--;
				_timer = window.setTimeout(handleLoadedFarEnough, 50);
				return;
			}
			
			removeHtmlEventListeners();
			
			// Allready set complete
			if (_hasVideo) return;
			
			// Set the playhead time to the start of the video
			setCurrentTime(0);
			if (Capabilities.getOs() != OperatingSystem.ANDROID) {
				pause();
			}
			
			// If we don't have an explicit width & height, then we set the
			// internal size to the videoWidth and videoHeight (otherwise it
			// will remain 0x0 and we won't see anything)
			if (_width == -1 && _percentWidth == -1)
				_element.style.width = _element.videoWidth + "px";
			if (_height == -1 && _percentHeight == -1)
				_element.style.height = _element.videoHeight + "px";
			
			// Video has been loaded
			_hasVideo = true;
			
			// When the video has loaded we'll startup an event loop that will
			// notify any listeners of TIME_CHANGED events. This can then be
			// used for example to create custom player controls
			if (!_loopRunning) {
				_loopRunning = true;
				Stage.getInstance().addEventListener(HJSEvent.ENTER_FRAME, onEventLoop);
			}
			
			// And we're done!
			EasyStyler.applyStyleObject(_element, {"top":"0px","left":"0px"});
			dispatchEvent(new HJSEvent(HJSEvent.FAR_ENOUGH));

			handleLoadComplete();
		}
				
		/**
		 * Handle when loading of the video is complete
		 */
		protected function handleLoadComplete():void
		{
			_timer = -1;
			
			// stop trying to load if we don't have a source
			if (_src == "")
				return;
			
			var theBufferedranges:int = typeof _element.buffered !== "undefined" ? _element.buffered.length : 0;
			if (navigator.appVersion.indexOf("MSIE") == -1 && (theBufferedranges == 0 || _element.buffered.end(theBufferedranges - 1) < (_element.duration - DURATION_TIME_FUZZINES))) {
				_timer = window.setTimeout(handleLoadComplete, 50);
				return;
			}
			
			dispatchEvent(new HJSEvent(HJSEvent.COMPLETE));
		}
		
		/**
		 * Called when loading threw an error or was aborted for some reason
		 */
		protected function onLoadError():void
		{
			dispatchEvent(new HJSEvent(HJSEvent.IO_ERROR));
		}
		
		/**
		 * An eventloop which notifies listeners of changes in the timestamp of
		 * the video or when playback has ended (when the end of the video has
		 * been reached).
		 */
		protected function onEventLoop(aEvent:HJSEvent):void
		{
			// If we don't have a video anymore then stop the loop
			if (_src == "" || _src == null || !_hasVideo) {
				Stage.getInstance().removeEventListener(HJSEvent.ENTER_FRAME, onEventLoop);
				_loopRunning = false;
				return;
			}
			
			// If the playback has ended, send an event
			// Our Samsung Galaxy S4 in the stock browser doesn't set the .ended
			// property, so we also check whether we've reached the end-time of
			// the video (within 1 frame accurate @25 fps).
			var isAtEnd:Boolean = (_element.currentTime > 0 && _element.currentTime > _element.duration - 0.12);
			if (isAtEnd && _element.loop) {
				setCurrentTime(0);
				_element.play();
				isAtEnd = false;
			}
			var isEnded:Boolean = _element.ended || isAtEnd; 
			if (_ended != isEnded) {
				_ended = isEnded;
				if (_ended) {
					pause();
					dispatchEvent(new HJSEvent(EVENT_ENDED));
				}
			}
			
			// If the currentTime has changed then send an event
			var theTime:Number = Math.round(_element.currentTime * 25) / 25;
			if (_currentTime != theTime) {
				_timeout = 0;
				_currentTime = theTime;
				dispatchEvent(new DataEvent(EVENT_TIME_CHANGED, _currentTime));
			} else if (!_paused && !isAtEnd) {
				_timeout++;
				// On our Samsung Galaxy S3 sometimes video does not start. When
				// this happens the currentTime gets stuck at a weird value.
				// This is to detect whether we should be playing back (!_paused)
				// and if so and the currentTime doesn't change for too long then
				// we give the video another kick to start playing.
				if (_timeout > 15) {
					_element.pause();
					_element.play();
					_timeout = 0;
				}
			}
		}
	}
}