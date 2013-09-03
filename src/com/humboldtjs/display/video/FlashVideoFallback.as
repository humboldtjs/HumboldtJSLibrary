/*
* HumboldtJSLibrary
* http://humboldtjs.com/
*
* Copyright (c) 2012 Daniël Haveman
* Co-authored by Ruud op den Kelder
* Licensed under the MIT license
* http://humboldtjs.com/license.html
*/
package com.humboldtjs.display.video
{
	import com.humboldtjs.events.EventDispatcher;
	import com.humboldtjs.events.HJSEvent;
	import com.humboldtjs.system.InternalId;
	import com.humboldtjs.utility.EasyStyler;
	
	import dom.document;
	import dom.domobjects.HTMLElement;
	import dom.eventFunction;
	import dom.window;

	public class FlashVideoFallback extends EventDispatcher
	{
		public static var VIDEO_ENDED:String = "videoEnded";
		
		public function getIsAvailable():Boolean			{ return (mElement.load) ? true : false; }
		
		public function getUnscaledWidth():Number 			{ return getIsAvailable() ? mElement.getUnscaledWidth() : 0; }
		public function getUnscaledHeight():Number 			{ return getIsAvailable() ? mElement.getUnscaledHeight() : 0; }
		
		public function getDuration():Number 				{ return getIsAvailable() ? mElement.getDuration() : 0; }
		public function getCurrentTime():Number 			{ return getIsAvailable() ? mElement.getCurrentTime() : 0; }
		public function setCurrentTime(value:Number):void	{ if (getIsAvailable()) mElement.setCurrentTime(value); }
		
		public function setAutoPlay(value:Boolean):void		{ mAutoplay = value; if (mLoaded) mElement.play();}
		public function setLoop(value:Boolean):void			{ mLoop = value; if (getIsAvailable()) mElement.setLoop(mLoop); }
		public function getLoop():Boolean					{ return getIsAvailable() ? mElement.getLoop() : false; }
		public function getHasEnded():Boolean				{ return mEnded; }
		
		protected var mEnded:Boolean;
		protected var mLoaded:Boolean;
		protected var mSourceURL:String;
		protected var mInternalId:String;
		protected var mElement:HTMLElement;
		protected var mAutoplay:Boolean;
		protected var mLoop:Boolean;
		
		public function FlashVideoFallback(aHTMLElement:HTMLElement)
		{
			super(); 
			mElement = aHTMLElement;
			mInternalId = InternalId.generateInternalId("video");
		
			aHTMLElement["id"] = mInternalId; 
			aHTMLElement["type"] = "application/x-shockwave-flash";
			aHTMLElement["data"] = "SimpleVideoPlayer.swf";
			aHTMLElement["wmode"] = "transparent";
			aHTMLElement["flashvars"] = "id=" + mInternalId+ "&logEnabled=true";
			aHTMLElement.innerHTML = "<param name=\"movie\" value=\"SimpleVideoPlayer.swf\" />" +
				"<param name=\"quality\" value=\"high\" />" +
				"<param name=\"wmode\" value=\"transparent\" />" +
				"<param name=\"flashvars\" value=\"id=" + mInternalId + "&logEnabled=true\" />";
			
			aHTMLElement.style.position = "fixed";
			aHTMLElement.style.top = "0px";  
			aHTMLElement.style.left = "0px";
			aHTMLElement.style.width = "1px";  
			aHTMLElement.style.height = "1px";
		}
		
		public function stop():void
		{
			mElement.stop(); 
		}
	
		protected function isFLV(aURL:String):Boolean
		{
			return aURL.substr(aURL.length -4, 4) == ".flv";
		}		
		
		public function load(aSourceURL:String):void
		{
			mEnded = false; 
			mLoaded = false; 
			
			mSourceURL = aSourceURL;
			if (mSourceURL == "") {
				if (window.hasOwnProperty(mInternalId)) {
					delete window[mInternalId];
				}
			} else {
				window[mInternalId] = {
					"onVideoEnded":eventFunction(this, onVideoEnded),
					"onVideoLoadSuccess":eventFunction(this, onVideoLoadSuccess),
					"onVideoLoadFailed":eventFunction(this, onVideoLoadFailed)
				};
			}
			loadData();
		}
		
		
		/**
		 * Will try to load later if the video is not yet available
		 */
		private function loadData():void
		{
			if (getIsAvailable()) {
				if (mSourceURL != "") {
					var theLoadFLVAsMovieClip:Boolean  = isFLV(mSourceURL);	
					mElement.load(mSourceURL, theLoadFLVAsMovieClip);
				}
			} else {
				window.setTimeout(eventFunction(this, loadData), 10);
			}
		}
		
		/**
		 * Handle when loading of the video is complete
		 */
		protected function onVideoLoadSuccess():void
		{	
			mLoaded = true;
			mElement.setLoop(mLoop);
			
			if (mAutoplay == true) 			
				mElement.play(); 
			
			dispatchEvent( new HJSEvent(HJSEvent.COMPLETE)); 
		}
		
		/**
		 * Dispatch when loading of the video has failed
		 */
		protected function onVideoLoadFailed():void
		{
			dispatchEvent( new HJSEvent(HJSEvent.IO_ERROR)); 
		}
		
		/**
		 * Dispatch when the video ended
		 */
		protected function onVideoEnded():void
		{
			mEnded = true; 
			dispatchEvent( new HJSEvent(VIDEO_ENDED)); 
		}
			
	}
}