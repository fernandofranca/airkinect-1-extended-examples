package com.as3nui.airkinect.extended.demos.ui {
	import com.as3nui.airkinect.extended.demos.ui.display.SimpleSelectionTimer;
	import com.as3nui.airkinect.extended.ui.components.HotSpot;
	import com.as3nui.airkinect.extended.ui.components.RepeatingSelectableHandle;
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

	public class UIRepeatHandleDemo extends BaseUIDemo {
		private var _gallery:Sprite;
		private var _leftHandCursor:Cursor;

		//Gallery
		private var _totalSections:uint;
		private var _totalRows:uint;
		private var _totalColumns:int;

		private var _totalSectionSize:Number;
		private var _currentSectionIndex:int;
		private var _sectionPadding:Number;

		//Handles
		private var _leftHandle:RepeatingSelectableHandle;
		private var _rightHandle:RepeatingSelectableHandle;

		public function UIRepeatHandleDemo() {
			_demoName = "UI: Repeat Handle";
		}

		override protected function initDemo():void {
			UIManager.init(stage);
			MouseSimulator.init(stage);

			createCursor();
			createGallery();
			createHotSpots();
			AIRKinect.addEventListener(SkeletonFrameEvent.UPDATE, onSkeletonFrame);
		}

		override protected function uninitDemo():void {
			AIRKinect.removeEventListener(SkeletonFrameEvent.UPDATE, onSkeletonFrame);
			super.uninitDemo();

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
			_totalSections = 15;
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

		private function createHotSpots():void {
			function getHotSpotGraphic():Sprite {
				var s:Sprite = new Sprite();
				s.graphics.beginFill(Math.random() * 0xffffff);
				s.graphics.drawRect(0, 0, 100, 50);
				return s;
			}

			_leftHandle = new RepeatingSelectableHandle(getHotSpotGraphic(), new SimpleSelectionTimer(), new SimpleSelectionTimer(0x00ff00));
			_leftHandle.addEventListener(UIEvent.SELECTED, onLeftSelected, false, 0, true);

			_rightHandle = new RepeatingSelectableHandle(getHotSpotGraphic(), new SimpleSelectionTimer(), new SimpleSelectionTimer(0x00ff00));
			_rightHandle.addEventListener(UIEvent.SELECTED, onRightSelected, false, 0, true);

			_leftHandle.x = 30;
			_leftHandle.y = 30;

			_rightHandle.x = 870;
			_rightHandle.y = 30;


			this.addChild(_leftHandle);
			this.addChild(_rightHandle);
		}

		private function onLeftSelected(event:UIEvent):void {
			_currentSectionIndex--;
			changeSections();
		}

		private function onRightSelected(event:UIEvent):void {
			_currentSectionIndex++;
			changeSections();
		}

		private function onHotSpotOver(event:UIEvent):void {
			_currentSectionIndex = (event.currentTarget as HotSpot).data as uint;
			changeSections();
		}

		private function changeSections():void {
			TweenLite.to(_gallery, 1, {x:-_currentSectionIndex * (_totalSectionSize + _sectionPadding)});
			updateHandles();
		}

		private function updateHandles():void {

			//Right Handle
			if (_currentSectionIndex >= (_totalSections - 1)) {
				_rightHandle.enabled = false;
			} else if (!_rightHandle.enabled) {
				_rightHandle.enabled = true;
			}
			_rightHandle.alpha = _rightHandle.enabled ? 1 : .5;


			//Left Handle
			if (_currentSectionIndex <= 0) {
				_leftHandle.enabled = false;
			} else if (!_leftHandle.enabled) {
				_leftHandle.enabled = true;
			}

			_leftHandle.alpha = _leftHandle.enabled ? 1 : .5;
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