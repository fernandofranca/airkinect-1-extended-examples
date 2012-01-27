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
	import com.as3nui.airkinect.extended.ui.components.Handle;
	import com.as3nui.airkinect.extended.ui.components.PushHandle;
	import com.as3nui.airkinect.extended.ui.events.UIEvent;
	import com.as3nui.airkinect.extended.ui.helpers.MouseSimulator;
	import com.as3nui.airkinect.extended.ui.managers.UIManager;
	import com.as3nui.airkinect.extended.ui.objects.Cursor;
	import com.as3nui.nativeExtensions.kinect.AIRKinect;
	import com.as3nui.nativeExtensions.kinect.data.AIRKinectSkeleton;
	import com.as3nui.nativeExtensions.kinect.data.AIRKinectSkeletonJoint;
	import com.as3nui.nativeExtensions.kinect.events.SkeletonFrameEvent;

	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;

	public class UIPushHandleDemo extends BaseUIDemo {
		private var _container:Sprite;
		private var _leftHandCursor:Cursor;

		private var _info:TextField;
		private var _clickCount:uint;

		public function UIPushHandleDemo() {
			_demoName = "UI: Push Handle";
			_container = new Sprite();
			this.addChild(_container);
		}

		override protected function initDemo():void {
			UIManager.init(stage);
			MouseSimulator.init(stage);

			_clickCount = 0;
			createCursor();
			createHandles();
			AIRKinect.addEventListener(SkeletonFrameEvent.UPDATE, onSkeletonFrame);
		}

		override protected function uninitDemo():void {
			AIRKinect.removeEventListener(SkeletonFrameEvent.UPDATE, onSkeletonFrame);
			super.uninitDemo();

			this.removeChildren();
			MouseSimulator.uninit();
			UIManager.dispose();
		}

		private function createHandles():void {
			_info = new TextField();
			_info.y = 20;
			_info.autoSize = TextFieldAutoSize.LEFT;
			this.addChild(_info);

			var circle:Sprite = new Sprite();
			circle.graphics.beginFill(0x00ff00);
			circle.graphics.drawCircle(30,30,30);
			
			var handle:Handle = new PushHandle(circle);
			_container.addChild(handle);

			handle.x = 150;
			handle.y = 150;
			handle.addEventListener(UIEvent.SELECTED, onHandleSelected);
			handle.showCaptureArea();
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
			if (event.skeletonFrame.numSkeletons > 0) {
				var skeleton:AIRKinectSkeleton = event.skeletonFrame.getSkeleton(0);
				//var leftHand:AIRKinectSkeletonJoint = skeleton.getJoint(AIRKinectSkeleton.HAND_LEFT);
				var leftHand:AIRKinectSkeletonJoint = skeleton.getJoint(AIRKinectSkeleton.WRIST_LEFT);
				var pad:Number = .35;

				_leftHandCursor.enabled = true;
				if (leftHand.x < pad || leftHand.x > 1 - pad) _leftHandCursor.enabled = false;
				if (leftHand.y < pad || leftHand.y > 1 - pad) _leftHandCursor.enabled = false;

				if (!_leftHandCursor.enabled) return;

				leftHand.x -= pad;
				leftHand.x /= (1 - pad) - pad;
				leftHand.y -= pad;
				leftHand.y /= (1 - pad) - pad;

				_leftHandCursor.update(leftHand.x, leftHand.y, leftHand.z);
			}
		}

		private function onHandleSelected(event:UIEvent):void {
			_clickCount++;
			_info.text = event.currentTarget.name + " Selected :: " + _clickCount;
		}
	}
}