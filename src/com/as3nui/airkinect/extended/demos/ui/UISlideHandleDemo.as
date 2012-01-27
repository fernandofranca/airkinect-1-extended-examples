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
	import com.as3nui.airkinect.extended.demos.ui.display.ColoredSlideHandle;
	import com.as3nui.airkinect.extended.demos.ui.display.SimpleSelectionTimer;
	import com.as3nui.airkinect.extended.ui.components.SlideHandle;
	import com.as3nui.airkinect.extended.ui.components.Target;
	import com.as3nui.airkinect.extended.ui.events.UIEvent;
	import com.as3nui.airkinect.extended.ui.helpers.MouseSimulator;
	import com.as3nui.airkinect.extended.ui.managers.UIManager;
	import com.as3nui.airkinect.extended.ui.objects.Cursor;
	import com.as3nui.nativeExtensions.kinect.AIRKinect;
	import com.as3nui.nativeExtensions.kinect.data.AIRKinectSkeleton;
	import com.as3nui.nativeExtensions.kinect.data.AIRKinectSkeletonJoint;
	import com.as3nui.nativeExtensions.kinect.events.SkeletonFrameEvent;
	import com.greensock.TweenLite;

	import flash.display.Shape;
	import flash.display.Sprite;

	public class UISlideHandleDemo extends BaseUIDemo {
		private var _gallery:Sprite;
		private var _leftHandCursor:Cursor;

		//Gallery
		private var _totalSections:uint;
		private var _totalRows:uint;
		private var _totalColumns:int;

		private var _totalSectionSize:Number;
		private var _currentSectionIndex:int;
		private var _sectionPadding:Number;

		//Sliders
		private var _rightSlideHandle:ColoredSlideHandle;
		private var _leftSlideHandle:ColoredSlideHandle;

		public function UISlideHandleDemo() {
			_demoName = "UI Slide Handle";
		}

		override protected function initDemo():void {
			UIManager.init(stage);
			MouseSimulator.init(stage);

			createCursor();
			createGallery();
			createHandles();
			AIRKinect.addEventListener(SkeletonFrameEvent.UPDATE, onSkeletonFrame);
		}

		override protected function uninitDemo():void {
			AIRKinect.removeEventListener(SkeletonFrameEvent.UPDATE, onSkeletonFrame);
			super.uninitDemo();

			_leftSlideHandle.removeEventListener(UIEvent.SELECTED, onLeftSlideSelected);
			_leftSlideHandle.removeEventListener(UIEvent.MOVE, onLeftMove);

			_rightSlideHandle.removeEventListener(UIEvent.SELECTED, onRightSlideSelected);
			_rightSlideHandle.removeEventListener(UIEvent.MOVE, onRightMove);


			this.removeChildren();
			UIManager.dispose();
			MouseSimulator.uninit();
		}

		private function createGallery():void {
			_gallery = new Sprite();
			this.addChild(_gallery);

			function getBox():Sprite {
				var s:Sprite = new Sprite();
				s.graphics.beginFill(Math.random() * 0xffffff);
				s.graphics.drawRect(0, 0, 200, 200);
				return s;
			}

			var box:Sprite = getBox();
			_totalSections = 4;
			_totalRows = 3;
			_totalColumns = 2;

			var rowSpacing:uint = 25;
			var colSpacing:uint = 25;
			_totalSectionSize = (_totalRows * box.width) + (_totalRows * rowSpacing);
			_sectionPadding = (stage.stageWidth - _totalSectionSize) / 2;

			var target:Target;
			for (var sectionIndex:uint = 0; sectionIndex < _totalSections; sectionIndex++) {
				for (var row:uint = 0; row < _totalRows; row++) {
					for (var col:uint = 0; col < _totalColumns; col++) {
						box = getBox();
						target = new Target(box, new SimpleSelectionTimer());
						target.x += ((sectionIndex + 1) * _sectionPadding);
						target.x += ((sectionIndex * _totalRows) * box.width);
						target.x += ((sectionIndex * _totalRows) * rowSpacing);
						target.x += (row * box.width);
						target.x += (row * rowSpacing);
						target.y = col * (box.height + colSpacing);
						_gallery.addChild(target);
					}
				}
			}

			_currentSectionIndex = Math.floor(_totalSections / 2);
			_gallery.x = -_currentSectionIndex * (_totalSectionSize + _sectionPadding);
			_gallery.y = (stage.stageHeight / 2) - (_gallery.height / 2);
		}

		private function createHandles():void {
			_leftSlideHandle = new ColoredSlideHandle(0x00ff00, 30, SlideHandle.LEFT);
			this.addChild(_leftSlideHandle);
			_leftSlideHandle.x = 930;
			_leftSlideHandle.y = (stage.stageHeight / 2) - 30;
			_leftSlideHandle.addEventListener(UIEvent.SELECTED, onLeftSlideSelected, false, 0, true);
			_leftSlideHandle.addEventListener(UIEvent.MOVE, onLeftMove, false, 0, true);
//			_leftSlideHandle.showCaptureArea();

			_rightSlideHandle = new ColoredSlideHandle(0x00ff00, 30, SlideHandle.RIGHT);
			_rightSlideHandle.x = 10;
			_rightSlideHandle.y = _leftSlideHandle.y;
			_rightSlideHandle.addEventListener(UIEvent.SELECTED, onRightSlideSelected, false, 0, true);
			_rightSlideHandle.addEventListener(UIEvent.MOVE, onRightMove, false, 0, true);
			this.addChild(_rightSlideHandle);
//			_rightSlideHandle.showCaptureArea();
		}

		private function onRightMove(event:UIEvent):void {
			if (_currentSectionIndex <= 0) return;
			var originalX:Number = -_currentSectionIndex * (_totalSectionSize + _sectionPadding);
			var destinationX:Number = originalX + (event.value * ((_totalSectionSize + _sectionPadding) / 2));
			TweenLite.to(_gallery, .3, {x:destinationX});
		}

		private function onLeftMove(event:UIEvent):void {
			if (_currentSectionIndex >= (_totalSections - 1)) return;
			var originalX:Number = -_currentSectionIndex * (_totalSectionSize + _sectionPadding);
			var destinationX:Number = originalX - (event.value * ((_totalSectionSize + _sectionPadding) / 2));
			TweenLite.to(_gallery, .3, {x:destinationX});
		}

		private function onRightSlideSelected(event:UIEvent):void {
			if (_currentSectionIndex <= 0) return;
			_currentSectionIndex--;
			TweenLite.to(_gallery, 1, {x:-_currentSectionIndex * (_totalSectionSize + _sectionPadding)});
			updateSliders();
		}


		private function onLeftSlideSelected(event:UIEvent):void {
			if (_currentSectionIndex >= (_totalSections - 1)) return;
			_currentSectionIndex++;
			TweenLite.to(_gallery, 1, {x:-_currentSectionIndex * (_totalSectionSize + _sectionPadding)});
			updateSliders();
		}

		private function updateSliders():void {
			if (_currentSectionIndex >= (_totalSections - 1)) {
				_leftSlideHandle.enabled = false;
			} else if (!_leftSlideHandle.enabled) {
				_leftSlideHandle.enabled = true;
			}

			if (_currentSectionIndex <= 0) {
				_rightSlideHandle.enabled = false;
			} else if (!_rightSlideHandle.enabled) {
				_rightSlideHandle.enabled = true;
			}
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
				var leftHand:AIRKinectSkeletonJoint = skeleton.getJoint(AIRKinectSkeleton.HAND_RIGHT);
				//var leftHand:AIRKinectSkeletonJoint = skeleton.getJoint(AIRKinectSkeleton.WRIST_LEFT);
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
	}
}