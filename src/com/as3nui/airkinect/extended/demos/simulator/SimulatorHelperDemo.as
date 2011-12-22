/**
 *
 * User: rgerbasi
 * Date: 12/6/11
 * Time: 4:03 PM
 */
package com.as3nui.airkinect.extended.demos.simulator {
	import com.as3nui.airkinect.extended.demos.core.BaseDemo;
	import com.as3nui.airkinect.extended.simulator.helpers.SkeletonSimulatorHelper;
	import com.as3nui.nativeExtensions.kinect.AIRKinect;
	import com.as3nui.nativeExtensions.kinect.data.AIRKinectSkeletonJoint;
	import com.as3nui.nativeExtensions.kinect.settings.AIRKinectFlags;
	import com.as3nui.nativeExtensions.kinect.data.AIRKinectSkeletonFrame;
	import com.as3nui.nativeExtensions.kinect.data.AIRKinectSkeleton;
	import com.as3nui.nativeExtensions.kinect.events.CameraFrameEvent;
	import com.as3nui.nativeExtensions.kinect.events.SkeletonFrameEvent;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Vector3D;

	public class SimulatorHelperDemo extends BaseDemo {
		private const KinectMaxDepthInFlash:Number = 200;


		private var _rgbCamera:Bitmap;
		private var _skeletonsSprite:Sprite;
		private var _currentSkeletons:Vector.<AIRKinectSkeleton>;
		private var _currentSimulatedSkeletons:Vector.<AIRKinectSkeleton>;

		public function SimulatorHelperDemo() {
			_demoName = "Basic Simulator Helper";
		}

		override protected function onAddedToStage(event:Event):void {
			super.onAddedToStage(event);
			AIRKinect.initialize(AIRKinectFlags.NUI_INITIALIZE_FLAG_USES_SKELETON | AIRKinectFlags.NUI_INITIALIZE_FLAG_USES_COLOR);

			initRGBCamera();
			initDemo();
		}

		override protected function onRemovedFromStage(event:Event):void {
			super.onRemovedFromStage(event);

			SkeletonSimulatorHelper.uninit();
			this.removeChildren();
			_rgbCamera.bitmapData.dispose();
			_rgbCamera = null;
			AIRKinect.shutdown();

			AIRKinect.removeEventListener(CameraFrameEvent.RGB, onRGBFrame);
			this.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
		}


		protected function initRGBCamera():void {
			AIRKinect.addEventListener(CameraFrameEvent.RGB, onRGBFrame);
			_rgbCamera = new Bitmap(new BitmapData(640, 480));
			_rgbCamera.scaleX = _rgbCamera.scaleY = .25;
			this.addChild(_rgbCamera);
			_rgbCamera.y = stage.stageHeight - _rgbCamera.height;
		}

		protected function onRGBFrame(event:CameraFrameEvent):void {
			_rgbCamera.bitmapData = event.frame;
		}

		override protected function onStageResize(event:Event):void {
			super.onStageResize(event);
		root.transform.perspectiveProjection.projectionCenter = new Point(stage.stageWidth / 2, stage.stageHeight / 2);
			if (_rgbCamera) _rgbCamera.y = stage.stageHeight - _rgbCamera.height;
		}

		protected function initDemo():void {
			SkeletonSimulatorHelper.init(stage);
			SkeletonSimulatorHelper.onSkeletonFrame.add(onSimulatedSkeletonFrame);

			_skeletonsSprite = new Sprite();
			this.addChild(_skeletonsSprite);

			this.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			AIRKinect.addEventListener(SkeletonFrameEvent.UPDATE, onSkeletonFrame);
		}

		private function onSkeletonFrame(e:SkeletonFrameEvent):void {
			_currentSkeletons = new <AIRKinectSkeleton>[];
			var skeletonFrame:AIRKinectSkeletonFrame = e.skeletonFrame;
			if (skeletonFrame.numSkeletons > 0) {
				for (var j:uint = 0; j < skeletonFrame.numSkeletons; j++) {
					_currentSkeletons.push(skeletonFrame.getSkeletonPosition(j));
				}
			}
		}

		private function onSimulatedSkeletonFrame(skeletonFrame:AIRKinectSkeletonFrame):void {
			_currentSimulatedSkeletons = new <AIRKinectSkeleton>[];
			if (skeletonFrame.numSkeletons > 0) {
				for (var j:uint = 0; j < skeletonFrame.numSkeletons; j++) {
					_currentSimulatedSkeletons.push(skeletonFrame.getSkeletonPosition(j));
				}
			}
		}

		//Enterframe
		private function onEnterFrame(event:Event):void {
			drawSkeletons();
		}

		private function drawSkeletons():void {
			while (_skeletonsSprite.numChildren > 0) _skeletonsSprite.removeChildAt(0);
			var allSkeletons:Vector.<AIRKinectSkeleton> = _currentSimulatedSkeletons ? _currentSkeletons.concat(_currentSimulatedSkeletons) : _currentSkeletons;
			var joint:AIRKinectSkeletonJoint;
			var scaler:Vector3D = new Vector3D(stage.stageWidth, stage.stageHeight, KinectMaxDepthInFlash);
			var jointSprite:Sprite;

			var color:uint;
			for each(var skeleton:AIRKinectSkeleton in allSkeletons) {
				for (var i:uint = 0; i < skeleton.numJoints; i++) {
					joint = skeleton.getJointScaled(i, scaler);

					jointSprite = new Sprite();
					color = (joint.z / (KinectMaxDepthInFlash * 4)) * 255 << 16 | (1 - (joint.z / (KinectMaxDepthInFlash * 4))) * 255 << 8 | 0;
					jointSprite.graphics.beginFill(color);
					jointSprite.graphics.drawCircle(0, 0, 15);
					jointSprite.x = joint.x;
					jointSprite.y = joint.y;
					jointSprite.z = joint.z;
					_skeletonsSprite.addChild(jointSprite);
				}
			}
		}
	}
}