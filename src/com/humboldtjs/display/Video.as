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
	import dom.domobjects.Event;
	import dom.eventFunction;
	import dom.navigator;
	import dom.window;
	
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
		
		protected var mHasVideo:Boolean = false;
		protected var mLoopRunning:Boolean = false;
		protected var mSrc:String = "";
		
		protected var mEnded:Boolean = false;
		protected var mPaused:Boolean = true;
		protected var mCurrentTime:Number = 0;
		protected var mTimer:int = -1;
		protected var mTries:int = 0;
		
		/**
		 * The original video width
		 */
		override public function getUnscaledWidth():Number 		{ return mElement.videoWidth; }
		/**
		 * The original video height
		 */
		override public function getUnscaledHeight():Number 	{ return mElement.videoHeight; }
		
		/**
		 * The duration
		 */
		public function getDuration():Number 					{ return mElement.duration; }
		
		/**
		 * The current playhead time
		 */
		public function getCurrentTime():Number 				{ return mElement.currentTime; }
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
			mElement.currentTime = value;
		}
		
		/**
		 * The source URL of the video.
		 */
		public function getSrc():String							{ return mSrc; }
		/**
		 * The source URL of the video.
		 */
		public function setSrc(value:String):void
		{
			if (mSrc != value) {
				mSrc = value;
				mHasVideo = false;
				mElement.autoplay = false;
				mElement.controls = false;
				pause();
				mElement.src = value;
				
				mTries = 4;
				HtmlUtils.addHtmlEventListener(mElement, "canplaythrough", eventFunction(this, onLoadedFarEnough));
				HtmlUtils.addHtmlEventListener(mElement, "load", eventFunction(this, onLoadedFarEnough));
				
				if (Capabilities.getOs() == OperatingSystem.IOS || Capabilities.getOs() == OperatingSystem.ANDROID) {
					play();
					window.setTimeout(eventFunction(this, pause), 1);
				}

				clearTimer();
				
				onLoadComplete();
			}
		}
		
		/**
		 * Whether the video is loaded
		 */
		public function getHasVideo():Boolean					{ return mHasVideo; }
		
		/**
		 * @constructor
		 */
		public function Video()
		{
			mElementType = "video";
			
			super();
			
			EasyStyler.applyStyleObject(mElement, {"position":"absolute","top":"-3000px","left":"-3000px"});
			document.body.appendChild(mElement);
		}
		
		public function dispose():void
		{
			mHasVideo = false;
			
			// Clear the src attribute to make sure the video is garbage collected.
			if (mElement != null) mElement.src = "";
			clearTimer();
			removeHtmlEventListeners();
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
			mElement.play();
			mPaused = false;
		}
		
		/**
		 * Pause video playback
		 */
		public function pause():void
		{
			mElement.pause();
			mPaused = true;
		}
		
		/**
		 * Removes html eventlisteners.
		 */ 
		protected function removeHtmlEventListeners():void
		{
			HtmlUtils.removeHtmlEventListener(mElement, "canplaythrough", eventFunction(this, onLoadedFarEnough));
			HtmlUtils.removeHtmlEventListener(mElement, "load", eventFunction(this, onLoadedFarEnough));			
		}

		/**
		 * Removes html eventlisteners.
		 */ 
		protected function clearTimer():void
		{
			if (mTimer != -1) {
				window.clearTimeout(mTimer);
				mTimer = -1;
			}
		}

		/**
		 * Handle when loading of the video is complete
		 */
		protected function onLoadComplete():void
		{
			mTimer = -1;
			
			// stop trying to load if we don't have a source
			if (mSrc == "")
				return;
			
			// If NETWORK_NO_SOURCE it means loading failed
			if (mElement.error != null) {
				onLoadError();
				return;
			}
			
			// Also allow networkState 2; 'loading', as '1' may not always be set e.g. in chrome.
			// TODO: see if there is another way to signal that all data has been loaded.
			// Note: in principle we should also dispatch 'LoadedFarEnough' which is when readyState == 4. 
			if (mElement.videoWidth == 0 ||
				mElement.videoHeight == 0 ||
				mElement.duration == 0 ||
				isNaN(mElement.duration) ||
				!((mElement.readyState == 4 ||
					mElement.readyState == 3) &&
					(mElement.networkState == 1 ||
						mElement.networkState == 2))) {
				mTimer = window.setTimeout(eventFunction(this, onLoadComplete), 100);
				return;
			}
			
			if (mElement.readyState !== 4 && mTries > 0) {
				mTries--;
				mTimer = window.setTimeout(eventFunction(this, onLoadComplete), 50);
				return;
			}

			removeHtmlEventListeners();
			
			// Allready set complete
			if (mHasVideo) return;
			
			// Set the playhead time to the start of the video
			setCurrentTime(0);
			
			// If we don't have an explicit width & height, then we set the
			// internal size to the videoWidth and videoHeight (otherwise it
			// will remain 0x0 and we won't see anything)
			if (mWidth == -1 && mPercentWidth == -1)
				mElement.style.width = mElement.videoWidth + "px";
			if (mHeight == -1 && mPercentHeight == -1)
				mElement.style.height = mElement.videoHeight + "px";
			
			// Video has been loaded
			mHasVideo = true;
			
			// When the video has loaded we'll startup an event loop that will
			// notify any listeners of TIME_CHANGED events. This can then be
			// used for example to create custom player controls
			if (!mLoopRunning) {
				mLoopRunning = true;
				mTimer = window.setTimeout(eventFunction(this, onEventLoop), 100);
			}
			
			// And we're done!
			EasyStyler.applyStyleObject(mElement, {"top":"0px","left":"0px"});
			dispatchEvent(new HJSEvent(HJSEvent.COMPLETE));
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
			
			onLoadComplete();
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
		protected function onEventLoop():void
		{
			// If we don't have a video anymore then stop the loop
			if (mSrc == "" || mSrc == null || !mHasVideo) {
				mLoopRunning = false;
				return;
			}
			
			// If the playback has ended, send an event
			if (mEnded != mElement.ended) {
				mEnded = mElement.ended;
				if (mEnded)
					dispatchEvent(new HJSEvent(EVENT_ENDED));
			}
			
			// If the currentTime has changed then send an event
			if (mCurrentTime != mElement.currentTime) {
				mCurrentTime = mElement.currentTime;
				dispatchEvent(new DataEvent(EVENT_TIME_CHANGED, mCurrentTime));
			}
			
			// And loop
			mTimer = window.setTimeout(eventFunction(this, onEventLoop), 100);
		}
	}
}