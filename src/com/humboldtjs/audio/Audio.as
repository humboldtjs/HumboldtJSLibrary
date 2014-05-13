/*
* HumboldtJSLibrary
* http://humboldtjs.com/
*
* Copyright (c) 2012 Daniël Haveman
* Licensed under the MIT license
* http://humboldtjs.com/license.html
*/
package com.humboldtjs.audio
{
	import com.humboldtjs.display.DisplayObject;
	import com.humboldtjs.display.ISrcDisplayObject;
	import com.humboldtjs.display.Stage;
	import com.humboldtjs.events.DataEvent;
	import com.humboldtjs.events.HJSEvent;
	import com.humboldtjs.system.Capabilities;
	import com.humboldtjs.system.HtmlUtils;
	import com.humboldtjs.system.OperatingSystem;
	
	import dom.document;
	import dom.domobjects.Event;
	import dom.window;
	
	/**
	 * A simple Audio class which deals with some of the weird issues with
	 * HTML5 Audio. This already supports a few different platforms and situations
	 * however you still have to determine whether to load an MP4 or WEBM
	 * using the Capabilities class first.
	 * 
	 * Note there are still numerous issues with various mobile browsers which
	 * have varying degrees of support for HTML5.
	 */
	public class Audio extends DisplayObject implements ISrcDisplayObject
	{
		public static const AUDIO_MP3:String = "mp3";
		
		public static const EVENT_ENDED:String = "ended";
		public static const EVENT_TIME_CHANGED:String = "timechanged";
		
		protected var _hasAudio:Boolean = false;
		protected var _loopRunning:Boolean = false;
		protected var _src:String = "";
		
		protected var _ended:Boolean = false;
		protected var _paused:Boolean = true;
		protected var _currentTime:Number = 0;
		protected var _timer:int = -1;
		protected var _tries:int = 0;
		
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
			_element.currentTime = value;
		}
		
		/**
		 * The source URL of the audio.
		 */
		public function getSrc():String							{ return _src; }
		/**
		 * The source URL of the audio.
		 */
		public function setSrc(value:String):void
		{
			if (_src != value) {
				_src = value;
				_hasAudio = false;
				_element.preload = true;
				_element.autoplay = false;
				_element.controls = false;
				pause();
				_element.src = value;
				
				_tries = 4;
				HtmlUtils.addHtmlEventListener(_element, "load", onLoadedFarEnough);
				
				if (Capabilities.getOs() == OperatingSystem.IOS || Capabilities.getOs() == OperatingSystem.ANDROID) {
					play();
					window.setTimeout(pause, 1);
				}
				
				clearTimer();
				
				onLoadComplete();
			}
		}
		
		/**
		 * Whether the audio is loaded
		 */
		public function getHasAudio():Boolean					{ return _hasAudio; }
		
		/**
		 * @constructor
		 */
		public function Audio()
		{
			super();
			
			document.body.appendChild(_element);
		}
		
		override protected function initializeElement():void
		{
			_element = document.createElement("audio");
		}
		
		public function dispose():void
		{
			_hasAudio = false;
			
			// Clear the src attribute to make sure the audio is garbage collected.
			if (_element != null) _element.src = "";
			clearTimer();
			removeHtmlEventListeners();
		}
		
		/**
		 * Return a copy of the Audio with the same contents
		 */
		public function clone():ISrcDisplayObject
		{
			var theAudio:Audio = new Audio();
			theAudio.setSrc(getSrc());
			
			return theAudio;
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
		
		/**
		 * Handle when loading of the video is complete
		 */
		protected function onLoadComplete():void
		{
			_timer = -1;
			
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
			if (_element.duration == 0 ||
				isNaN(_element.duration) ||
				!((_element.readyState == 4 ||
					_element.readyState == 3) &&
					(_element.networkState == 1 ||
						_element.networkState == 2))) {
				_timer = window.setTimeout(onLoadComplete, 100);
				return;
			}
			
			if (_element.readyState !== 4 && _tries > 0) {
				_tries--;
				_timer = window.setTimeout(onLoadComplete, 50);
				return;
			}
			
			removeHtmlEventListeners();
			
			// Allready set complete
			if (_hasAudio) return;
			
			// Set the playhead time to the start of the video
			setCurrentTime(0);
			
			// Video has been loaded
			_hasAudio = true;
			
			// When the video has loaded we'll startup an event loop that will
			// notify any listeners of TIME_CHANGED events. This can then be
			// used for example to create custom player controls
			if (!_loopRunning) {
				_loopRunning = true;
				Stage.getInstance().addEventListener(HJSEvent.ENTER_FRAME, onEventLoop);
			}
			
			// And we're done!
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
		protected function onEventLoop(aEvent:HJSEvent):void
		{
			// If we don't have a video anymore then stop the loop
			if (_src == "" || _src == null || !_hasAudio) {
				Stage.getInstance().removeEventListener(HJSEvent.ENTER_FRAME, onEventLoop);
				_loopRunning = false;
				return;
			}
			
			// If the playback has ended, send an event
			if (_ended != _element.ended) {
				_ended = _element.ended;
				if (_ended)
					dispatchEvent(new HJSEvent(EVENT_ENDED));
			}
			
			// If the currentTime has changed then send an event
			if (_currentTime != _element.currentTime) {
				_currentTime = Math.round(_element.currentTime * 25) / 25;
				dispatchEvent(new DataEvent(EVENT_TIME_CHANGED, _currentTime));
			}
		}
	}
}