/*
 * Copyright (c) 2012 AS3NUI
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation the
 * rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is furnished to
 * do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all copies
 * or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
 * INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
 * PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
 * FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
 * OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 */

package com.as3nui.airkinect.extended.demos.ui {
	import com.as3nui.airkinect.extended.demos.ui.display.ColoredCrankHandle;
	import com.as3nui.airkinect.extended.ui.events.UIEvent;
	import com.as3nui.airkinect.extended.ui.helpers.MouseSimulator;
	import com.as3nui.airkinect.extended.ui.managers.UIManager;
	import com.as3nui.airkinect.extended.ui.objects.Cursor;
	import com.as3nui.nativeExtensions.kinect.AIRKinect;
	import com.as3nui.nativeExtensions.kinect.data.AIRKinectSkeleton;
	import com.as3nui.nativeExtensions.kinect.data.AIRKinectSkeletonJoint;
	import com.as3nui.nativeExtensions.kinect.events.SkeletonFrameEvent;

	import flash.display.Loader;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.net.URLRequest;

	public class UICrankHandleDemo extends BaseUIDemo {
		private var _leftHandCursor:Cursor;

		private var _imgUrl:String = "http://www.taramtamtam.com/wallpapers/Animal/M/Monkey/images/Monkey_2.jpg";

		//Handles
		private var _crankHandle:ColoredCrankHandle;
		private var _container:Sprite;
		private var _originalScale:Number;
		private var _imageLoader:Loader;

		public function UICrankHandleDemo() {
			_demoName = "UI: CrankHandle";
			_imageLoader= new Loader();
		}
		
		override protected function initDemo():void {
			UIManager.init(stage);
			MouseSimulator.init(stage);

			_container = new Sprite();
			this.addChild(_container);
			this.addChild(_rgbCamera);

			loadImage();
		}

		override protected function uninitDemo():void {
			AIRKinect.removeEventListener(SkeletonFrameEvent.UPDATE, onSkeletonFrame);
			_imageLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onImageLoadComplete);
			_imageLoader.unloadAndStop();
			super.uninitDemo();

			this.removeChildren();
			UIManager.dispose();
			MouseSimulator.uninit();
		}

		private function loadImage():void {
			_imageLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onImageLoadComplete);
			_imageLoader.load(new URLRequest(_imgUrl))
		}

		private function onImageLoadComplete(event:Event):void {
			_imageLoader.content.x -= _imageLoader.content.width/2;
			_imageLoader.content.y -= _imageLoader.content.height/2;
			_container.addChild(_imageLoader.content);
			
			_container.x = stage.stageWidth/2;
			_container.y = stage.stageHeight/2;
			_container.scaleX = _container.scaleY = .5;

			createCursor();
			createHandles();

			AIRKinect.addEventListener(SkeletonFrameEvent.UPDATE, onSkeletonFrame);
		}

		private function createHandles():void {
			_crankHandle = new ColoredCrankHandle();
			_crankHandle.x = 800;
			_crankHandle.y = 300;
			this.addChild(_crankHandle);

			_crankHandle.addEventListener(UIEvent.CAPTURE, onCrankCapture, false, 0, true);
			_crankHandle.addEventListener(UIEvent.MOVE, onCrankMove, false, 0, true);
			//_crankHandle.showCaptureArea();
			_crankHandle.drawDebug = true;
		}

		private function onCrankCapture(event:UIEvent):void {
			_originalScale = _container.scaleX;
		}

		private function onCrankMove(event:UIEvent):void {
			var ratio:Number = event.value / (Math.PI * 2);
			//trace(event.value * (180/Math.PI));
			_container.scaleX = _container.scaleY = _originalScale + ratio;
		}

		private function createCursor():void {
			var circle:Shape = new Shape();
			circle.graphics.lineStyle(2, 0x000000);
			circle.graphics.beginFill(0x00ff00);
			circle.graphics.drawCircle(0, 0, 20);

			_leftHandCursor = new Cursor("_kinect_", AIRKinectSkeleton.HAND_LEFT, circle);
			UIManager.addCursor(_leftHandCursor);
			_leftHandCursor.enabled = false;
		}

		private function onSkeletonFrame(event:SkeletonFrameEvent):void {
			if(event.skeletonFrame.numSkeletons >0){
				var skeleton:AIRKinectSkeleton = event.skeletonFrame.getSkeleton(0);
				var leftHand:AIRKinectSkeletonJoint = skeleton.getJoint(AIRKinectSkeleton.HAND_RIGHT);
				//var leftHand:AIRKinectSkeletonJoint = skeleton.getJoint(AIRKinectSkeleton.WRIST_LEFT);
				var pad:Number = .35;

				_leftHandCursor.enabled = true;
				if(leftHand.x < pad || leftHand.x > 1-pad) _leftHandCursor.enabled = false;
				if(leftHand.y < pad || leftHand.y > 1-pad) _leftHandCursor.enabled = false;

				if(!_leftHandCursor.enabled) return;
				
				leftHand.x -= pad;
				leftHand.x /= (1-pad) - pad;
				leftHand.y -= pad;
				leftHand.y /= (1-pad) - pad;

				_leftHandCursor.update(leftHand.x, leftHand.y, leftHand.z);
			}
		}
	}
}