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
	import com.as3nui.airkinect.extended.demos.ui.display.ColoredHandle;
	import com.as3nui.airkinect.extended.demos.ui.display.ColoredSlideHandle;
	import com.as3nui.airkinect.extended.demos.ui.display.ColoredTarget;
	import com.as3nui.airkinect.extended.ui.components.Handle;
	import com.as3nui.airkinect.extended.ui.components.SlideHandle;
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

	public class UISandboxDemo extends BaseUIDemo {

		private var _container:Sprite;
		private var _leftHandCursor:Cursor;

		private var _info:TextField;
		private var _slideOutput:TextField;

		public function UISandboxDemo() {
			_demoName = "UI: Sandbox";
			_container = new Sprite();
			this.addChild(_container);
		}
		
		override protected function initDemo():void {
			UIManager.init(stage);
			MouseSimulator.init(stage);

			createCursor();
			createHandles();
			createSlideHandles();
			createTargets();
			createCrankHandles();

			AIRKinect.addEventListener(SkeletonFrameEvent.UPDATE, onSkeletonFrame);
		}

		override protected function uninitDemo():void {
			AIRKinect.removeEventListener(SkeletonFrameEvent.UPDATE, onSkeletonFrame);
			super.uninitDemo();

			this.removeChildren();
			UIManager.dispose();
			MouseSimulator.uninit();
		}

		private function createCrankHandles():void {
			var crankHandle:ColoredCrankHandle = new ColoredCrankHandle();
			crankHandle.x = 300;
			crankHandle.y = 300;
			this.addChild(crankHandle);

			crankHandle.addEventListener(UIEvent.MOVE, onCrankMove, false, 0, true);
			crankHandle.showCaptureArea();
			crankHandle.drawDebug = true;
		}

		private function createTargets():void {
			var target:ColoredTarget = new ColoredTarget();
			target.x = 10;
			target.y = 300;
			this.addChild(target);
		}

		private function createSlideHandles():void {
			var leftSlideHandle:ColoredSlideHandle = new ColoredSlideHandle(0x00ff00, 30, SlideHandle.LEFT);
			leftSlideHandle.x = 600;
			leftSlideHandle.y = 300;
			this.addChild(leftSlideHandle);
			leftSlideHandle.addEventListener(UIEvent.SELECTED, onLeftSlideSelected, false, 0, true);
//			leftSlideHandle.showCaptureArea();

			var rightSlideHandle:ColoredSlideHandle = new ColoredSlideHandle(0x00ff00, 30, SlideHandle.RIGHT);
			rightSlideHandle.x = 600;
			rightSlideHandle.y = 500;
			rightSlideHandle.addEventListener(UIEvent.SELECTED, onRightSlideSelected, false, 0, true);
			this.addChild(rightSlideHandle);
//			rightSlideHandle.showCaptureArea();

			_slideOutput = new TextField();
			_slideOutput.text = "Slide to change";
			_slideOutput.x = 600;
			_slideOutput.y = 400;
			this.addChild(_slideOutput);

		}

		private function createHandles():void {
			_info = new TextField();
			_info.y = 20;
			this.addChild(_info);

			var handle:Handle;
			var spacing:uint = 100;
			var totalHandles:int = 10;

			for (var i:uint = 0; i < totalHandles; i++) {
				handle = new ColoredHandle(Math.random() * 0xffffff, totalHandles + Math.round(Math.random() * 30));
				handle.x = 50+ (i * spacing);
				handle.y = 100;

				_container.addChild(handle);
				handle.addEventListener(UIEvent.SELECTED, onHandleSelected, false, 0, true);
				//handle.showCaptureArea();
			}
		}

		private function createCursor():void {
			var circle:Shape = new Shape();
			circle.graphics.lineStyle(2, 0x000000);
			circle.graphics.beginFill(0x00ff00);
			circle.graphics.drawCircle(0, 0, 20);

			_leftHandCursor = new Cursor("_kinect_", AIRKinectSkeleton.HAND_LEFT, circle);
			UIManager.addCursor(_leftHandCursor);
		}

		private function onCrankMove(event:UIEvent):void {
			trace(event.value * (180/Math.PI));
		}

		private function onRightSlideSelected(event:UIEvent):void {
			_slideOutput.text = "Right Slide";
		}

		private function onLeftSlideSelected(event:UIEvent):void {
			_slideOutput.text = "Left Slide";
		}

		private function onSkeletonFrame(event:SkeletonFrameEvent):void {
			if(event.skeletonFrame.numSkeletons >0){
				var skeleton:AIRKinectSkeleton = event.skeletonFrame.getSkeleton(0);


				//var leftHand:AIRKinectSkeletonJoint = skeleton.getJoint(AIRKinectSkeleton.HAND_LEFT);
				var leftHand:AIRKinectSkeletonJoint = skeleton.getJoint(AIRKinectSkeleton.WRIST_LEFT);
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

		private function onHandleSelected(event:UIEvent):void {
			_info.text = event.currentTarget.name + " Selected";
		}
	}
}