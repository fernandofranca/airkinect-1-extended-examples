package com.as3nui.airkinect.extended.demos.ui {
	import com.as3nui.airkinect.extended.demos.ui.display.GraphicTarget;
	import com.as3nui.airkinect.extended.ui.components.Target;
	import com.as3nui.airkinect.extended.ui.helpers.MouseSimulator;
	import com.as3nui.airkinect.extended.ui.managers.UIManager;
	import com.as3nui.airkinect.extended.ui.objects.Cursor;
	import com.as3nui.nativeExtensions.kinect.AIRKinect;
	import com.as3nui.nativeExtensions.kinect.data.SkeletonPosition;
	import com.as3nui.nativeExtensions.kinect.events.SkeletonFrameEvent;

	import flash.display.Shape;
	import flash.geom.Vector3D;

	public class UITargetDemo extends BaseUIDemo {
		private var _leftHandCursor:Cursor;
		private var _target:Target;

		public function UITargetDemo() {
			_demoName = "UI: Target Demo";

		}

		override protected function initDemo():void {
			UIManager.init(stage);
			MouseSimulator.init(stage);

			createCursor();
			createTarget();
			AIRKinect.addEventListener(SkeletonFrameEvent.UPDATE, onSkeletonFrame);
		}

		override protected function uninitDemo():void {
			AIRKinect.removeEventListener(SkeletonFrameEvent.UPDATE, onSkeletonFrame);
			super.uninitDemo();

			this.removeChildren();
			UIManager.dispose();
			MouseSimulator.uninit();
		}


		private function createTarget():void {
			_target = new GraphicTarget();
			this.addChild(_target);
			_target.x = (stage.stageWidth / 2) - (_target.width / 2);
			_target.y = (stage.stageHeight / 2) - (_target.height / 2);
		}

		private function createCursor():void {
			var circle:Shape = new Shape();
			circle.graphics.lineStyle(2, 0x000000);
			circle.graphics.beginFill(0x00ff00);
			circle.graphics.drawCircle(0, 0, 20);

			_leftHandCursor = new Cursor("_kinect_", SkeletonPosition.HAND_LEFT, circle);
			UIManager.addCursor(_leftHandCursor);
			_leftHandCursor.enabled = false;
		}

		private function onSkeletonFrame(event:SkeletonFrameEvent):void {
			if (event.skeletonFrame.numSkeletons > 0) {
				var skeletonPosition:SkeletonPosition = event.skeletonFrame.getSkeletonPosition(0);
				var leftHand:Vector3D = skeletonPosition.getElement(SkeletonPosition.HAND_RIGHT);
				//var leftHand:Vector3D = skeletonPosition.getElement(SkeletonPosition.WRIST_LEFT);
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