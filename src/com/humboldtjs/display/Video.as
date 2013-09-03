/*
* HumboldtJSLibrary
* http://humboldtjs.com/
*
* Copyright (c) 2012 Daniël Haveman
* Co-authored by Ruud op den Kelder
* Licensed under the MIT license
* http://humboldtjs.com/license.html
*/
package com.humboldtjs.display
{
	import com.humboldtjs.display.video.FlashVideoFallback;
	import com.humboldtjs.events.DataEvent;
	import com.humboldtjs.events.HJSEvent;
	import com.humboldtjs.system.Capabilities;
	import com.humboldtjs.utility.EasyStyler;
	
	import dom.document;
	import dom.domobjects.HTMLElement;
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
			
		public static const HTML_VIDEO_TAG:String = "video"; 
		public static const FLASH_VIDEO_TAG:String = "object"; 
		
		public static const EVENT_ENDED:String = "ended";
		public static const EVENT_TIME_CHANGED:String = "timechanged";

		protected var mHasVideo:Boolean = false;
		protected var mLoopRunning:Boolean = false;
		protected var mSrc:String = "";
		
		protected var mEnded:Boolean = false;
		protected var mPaused:Boolean = true;
		protected var mCurrentTime:Number = 0;
		protected var mFlashVideoFallback:FlashVideoFallback = null; 

		/**
		 * The original video width
		 */
		override public function getUnscaledWidth():Number 		{ return (mFlashVideoFallback != null) ? mFlashVideoFallback.getUnscaledWidth() : mElement.videoWith; }
		/**
		 * The original video height
		 */
		override public function getUnscaledHeight():Number 	{ return (mFlashVideoFallback != null) ? mFlashVideoFallback.getUnscaledHeight() : mElement.videoHeight; }

		/**
		 * The duration
		 */
		public function getDuration():Number 					{ return (mFlashVideoFallback != null) ? mFlashVideoFallback.getDuration() : mElement.duration; }

		/**
		 * The current playhead time
		 */
		public function getCurrentTime():Number 				{ return (mFlashVideoFallback != null) ? mFlashVideoFallback.getCurrentTime() : mElement.currentTime; }

		/**
		 * The current playhead time
		 * 
		 * Work around a bug on iPad where setting currentTime to 0 makes later calls to currentTime stop working. 
		 * This also prevents the ended event being triggered.
		 * 
		 * @see http://stackoverflow.com/questions/3874070/missing-html5-video-ended-event-on-ipad
		 */
		public function setCurrentTime(value:Number):void		{ (mFlashVideoFallback != null) ? mFlashVideoFallback.setCurrentTime(value) : mElement.currentTime = (value==0) ? 0.01 : value; }

		/**
		 * The source URL of the video.
		 */
		public function getSrc():String							{ return mSrc; }
		
		public function getLoop():Boolean						{ return mLoop; }
		public function setLoop(aValue:Boolean):void 			{ mLoop = aValue;
			if (mFlashVideoFallback != null)
				mFlashVideoFallback.setLoop(aValue); 		
			else
				mElement.loop = aValue;
		}
		
		public function getAutoPlay():Boolean					{return mAutoPlay; }
		public function setAutoPlay(aValue:Boolean):void		{mAutoPlay = aValue;
			if (mFlashVideoFallback != null)
				mFlashVideoFallback.setAutoPlay(aValue); 		
			else
				mElement.autoplay = aValue;
		}
		
		protected var mAutoPlay:Boolean;
		protected var mLoop:Boolean;
		
		private var _frames:int = 0;
		
		/**
		 * The source URL of the video.
		 */
		public function setSrc(value:String):void
		{
			if (mSrc != value) {		
				mSrc = value;
				mHasVideo = false;
				mPaused = true;		
				load();	
			}
		}
		
		private function load():void
		{
			if (mFlashVideoFallback != null) {
				mFlashVideoFallback.load(mSrc); 
			} else {
				mElement.autoplay = false;
				mElement.controls = false;
				mElement.pause();
				mElement.src = mSrc;
				onHTMLVideoLoadComplete();
			}
		}
		
		/**
		 * Handle when loading of the video is complete
		 */
		protected function onHTMLVideoLoadComplete():void
		{
			// If NETWORK_NO_SOURCE it means loading failed
			if (mElement.networkState == 3)
			{
				dispatchEvent(new HJSEvent(HJSEvent.IO_ERROR));
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
				window.setTimeout(eventFunction(this, onHTMLVideoLoadComplete), 100);
				return;
			}
		
			// Set the playhead time to the start of the video
			setCurrentTime(0);
			onLoadComplete(null); 
		}
	
		/**
		 * Whether the video is loaded
		 */
		public function getHasVideo():Boolean					{ return mHasVideo; }

		public function useFallback():Boolean
		{
			return !Capabilities.getHasVideo();
		}
		
		/**
		 * @constructor
		 */
		public function Video()
		{
			mElementType = useFallback() ? Video.FLASH_VIDEO_TAG : Video.HTML_VIDEO_TAG ;
			
			super();
		
			EasyStyler.applyStyleObject(mElement, {"position":"absolute","top":"-3000px","left":"-3000px"});
			
			if (useFallback()) { 
				mFlashVideoFallback = new FlashVideoFallback(mElement);    
				mFlashVideoFallback.addEventListener(HJSEvent.COMPLETE, eventFunction(this, onLoadComplete)); 
				mFlashVideoFallback.addEventListener(HJSEvent.IO_ERROR, eventFunction(this, onLoadError)); 
				mFlashVideoFallback.addEventListener(FlashVideoFallback.VIDEO_ENDED, eventFunction(this, onVideoEnded)); 
			}
		}
		
		/**
		 * Return a copy of the Video with the same contents
		 */
		public function clone():ISrcDisplayObject {
			var theVideo:Video = new Video();
			theVideo.setSrc(getSrc());
			return theVideo;
		}
		
		/**
		 * Start video playback
		 */
		public function play():void {
			if (mElement.play != null)
				mElement.play();
			else 
				window.setTimeout(eventFunction(this, play), 10);	
		}
		
		/**
		 * Pause video playback
		 */
		public function pause():void {
			if (mElement.pause != null)
				mElement.pause();
			else 
				window.setTimeout(eventFunction(this, pause), 10);	
		}
		
		/**
		 * stop the video playback
		 */ 
		public function stop():void {
			if (mFlashVideoFallback != null) {
				mFlashVideoFallback.stop();
			} else {
				pause();
				setCurrentTime(0.0); 
			}
		}
		
		/**
		 * Handle when loading of the video is complete
		 */
		protected function onLoadComplete(aEvent:HJSEvent):void
		{
			// Video has been loaded
			mHasVideo = true;
			
			// If we don't have an explicit width & height, then we set the
			// internal size to the videoWidth and videoHeight (otherwise it
			// will remain 0x0 and we won't see anything)
			if (mWidth == -1 && mPercentWidth == -1)
				mElement.style.width = String(getUnscaledWidth());
			if (mHeight == -1 && mPercentHeight == -1)
				mElement.style.height = String(getUnscaledHeight());
			
			// And we're done!
			EasyStyler.applyStyleObject(mElement, {"position":"absolute","top":"0px","left":"0px"});
						
			// When the video has loaded we'll startup an event loop that will
			// notify any listeners of TIME_CHANGED events. This can then be
			// used for example to create custom player controls
			if (!mLoopRunning) {
				mLoopRunning = true;
				window.setTimeout(eventFunction(this, onEventLoop), 100);
			}
			dispatchEvent(new HJSEvent(HJSEvent.COMPLETE));
		}
		
		/**
		 * Called when loading threw an error or was aborted for some reason
		 */
		protected function onLoadError(aEvent:HJSEvent):void
		{
			dispatchEvent(new HJSEvent(HJSEvent.IO_ERROR));
		}
		
		protected function onVideoEnded(aEvent:HJSEvent):void
		{
			dispatchEvent(new HJSEvent(EVENT_ENDED));
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
			
			if (mFlashVideoFallback == null) {
				// If the playback has ended, send an event
				if (mEnded != mElement.ended)  {
					mEnded = mElement.ended;
					if (mEnded)
						dispatchEvent(new HJSEvent(EVENT_ENDED));
				}
			}

			// If the currentTime has changed then send an event
			if (mCurrentTime != getCurrentTime()) {
				mCurrentTime = getCurrentTime();
				dispatchEvent(new DataEvent(EVENT_TIME_CHANGED, mCurrentTime));
			}
			
			// And loop
			window.setTimeout(eventFunction(this, onEventLoop), 100);
		}
	}
}