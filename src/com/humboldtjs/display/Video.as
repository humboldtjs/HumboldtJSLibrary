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
	
	import dom.document;
	import dom.eventFunction;
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
				mElement.pause();
				mPaused = true;
				mElement.src = value;

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
			
			document.body.appendChild(mElement);
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
		}
		
		/**
		 * Pause video playback
		 */
		public function pause():void
		{
			mElement.pause();
		}
		
		/**
		 * Handle when loading of the video is complete
		 */
		protected function onLoadComplete():void
		{
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
				window.setTimeout(eventFunction(this, onLoadComplete), 100);
				return;
			}

			// Set the playhead time to the start of the video
			setCurrentTime(0);
			
			// If we don't have an explicit width & height, then we set the
			// internal size to the videoWidth and videoHeight (otherwise it
			// will remain 0x0 and we won't see anything)
			if (mWidth == -1 && mPercentWidth == -1)
				mElement.style.width = mElement.videoWidth;
			if (mHeight == -1 && mPercentHeight == -1)
				mElement.style.height = mElement.videoHeight;

			// Video has been loaded
			mHasVideo = true;
			
			// When the video has loaded we'll startup an event loop that will
			// notify any listeners of TIME_CHANGED events. This can then be
			// used for example to create custom player controls
			if (!mLoopRunning) {
				mLoopRunning = true;
				window.setTimeout(eventFunction(this, onEventLoop), 100);
			}

			// And we're done!
			dispatchEvent(new HJSEvent(HJSEvent.COMPLETE));
		}
		
		/**
		 * An eventloop which notifies listeners of changes in the timestamp of
		 * the video or when playback has ended (when the end of the video has
		 * been reached).
		 */
		protected function onEventLoop():void
		{
			// If we don't have a video anymore then stop the loop
			if (mSrc == "" || mSrc == null) {
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
			window.setTimeout(eventFunction(this, onEventLoop), 100);
		}
	}
}