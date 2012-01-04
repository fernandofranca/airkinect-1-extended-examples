package com.as3nui.airkinect.extended.demos.ui {
	import com.as3nui.airkinect.extended.demos.ui.display.SimpleSelectionTimer;
	import com.as3nui.airkinect.extended.ui.components.Handle;
	import com.as3nui.airkinect.extended.ui.components.SelectableHandle;
	import com.as3nui.airkinect.extended.ui.events.UIEvent;
	import com.as3nui.airkinect.extended.ui.helpers.MouseSimulator;
	import com.as3nui.airkinect.extended.ui.managers.UIManager;
	import com.as3nui.airkinect.extended.ui.objects.Cursor;
	import com.as3nui.nativeExtensions.kinect.AIRKinect;
	import com.as3nui.nativeExtensions.kinect.data.AIRKinectSkeleton;
	import com.as3nui.nativeExtensions.kinect.data.AIRKinectSkeletonJoint;
	import com.as3nui.nativeExtensions.kinect.events.SkeletonFrameEvent;

	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.text.TextField;

	public class UIHandleDemo extends BaseUIDemo {
		private var _container:Sprite;
		private var _leftHandCursor:Cursor;

		private var _info:TextField;

		//Image Stuff
		[Embed(source="/../assets/embeded/images/mel_idle.png")]
		private var IconIdle:Class;

		[Embed(source="/../assets/embeded/images/mel_selected.png")]
		private var IconSelected:Class;

		public function UIHandleDemo() {
			_demoName = "UI: Handle";
			_container = new Sprite();
			this.addChild(_container);
		}

		override protected function initDemo():void {
			UIManager.init(stage);
			MouseSimulator.init(stage);

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
			this.addChild(_info);

			var handle:Handle = new SelectableHandle(new IconIdle() as Bitmap, new SimpleSelectionTimer(), new IconSelected() as Bitmap, null, 1, .1, .1, .3);
			_container.addChild(handle);

			handle.x = (stage.stageWidth / 2) - (handle.width / 2);
			handle.y = (stage.stageHeight / 2) - (handle.height / 2);
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
			_info.text = event.currentTarget.name + " Selected";
		}
	}
}