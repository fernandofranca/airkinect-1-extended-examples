/**
 *
 * User: rgerbasi
 * Date: 10/16/11
 * Time: 5:51 PM
 */
package com.as3nui.airkinect.extended.demos.simulator {
	import com.as3nui.airkinect.extended.demos.core.BaseDemo;
	import com.as3nui.airkinect.extended.manager.AIRKinectManager;
	import com.as3nui.airkinect.extended.manager.skeleton.ExtendedSkeleton;
	import com.as3nui.airkinect.extended.simulator.helpers.SkeletonSimulatorHelper;
	import com.as3nui.nativeExtensions.kinect.data.AIRKinectSkeletonJoint;
	import com.as3nui.nativeExtensions.kinect.settings.AIRKinectFlags;
	import com.as3nui.nativeExtensions.kinect.data.AIRKinectSkeleton;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Vector3D;

	public class HistorySimulatorHelperDemo extends BaseDemo {
		//RGB Camera Bitmap
		private var _rgbCamera:Bitmap;

		//Depth in Flash
		private var _kinectMaxDepthInFlash:uint = 200;

		//Drawing Skeletons
		private var _skeletonsSprite:Sprite;

		//History Drawing
		private var _historySprite:Sprite;

		//Current Active Skeleton
		private var _activeSkeleton:ExtendedSkeleton;

		public function HistorySimulatorHelperDemo() {
			_demoName = "History with SimulatorHelper";
		}


		override protected function onAddedToStage(event:Event):void {
			super.onAddedToStage(event);
			initDemo();
		}

		override protected function onRemovedFromStage(event:Event):void {
			super.onRemovedFromStage(event);

			SkeletonSimulatorHelper.uninit();

			this.removeChildren();
			_rgbCamera.bitmapData.dispose();
			_rgbCamera = null;
			AIRKinectManager.shutdown();

			this.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
		}

		override protected function onStageResize(event:Event):void {
			super.onStageResize(event);
			root.transform.perspectiveProjection.projectionCenter = new Point(stage.stageWidth / 2, stage.stageHeight / 2);
			if (_rgbCamera) _rgbCamera.y = stage.stageHeight - _rgbCamera.height;
		}

		private function initDemo():void {
			SkeletonSimulatorHelper.init(stage);

			_skeletonsSprite = new Sprite();
			this.addChild(_skeletonsSprite);

			_historySprite = new Sprite();
			this.addChild(_historySprite);

			initRGBCamera();
			initKinect();
		}

		private function initKinect():void {
			// trace("initKinect");
			AIRKinectManager.initialize(AIRKinectFlags.NUI_INITIALIZE_FLAG_USES_SKELETON | AIRKinectFlags.NUI_INITIALIZE_FLAG_USES_COLOR);

			AIRKinectManager.onSkeletonAdded.add(onSkeletonAdded);
			AIRKinectManager.onSkeletonRemoved.add(onSkeletonRemoved);
			AIRKinectManager.onKinectDisconnected.add(onKinectDisconnected);
			AIRKinectManager.onKinectReconnected.add(onKinectReconnected);
			AIRKinectManager.onRGBFrameUpdate.add(onRGBFrame);
			this.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}

		private function onKinectDisconnected():void {
		}

		private function onKinectReconnected(success:Boolean):void {

		}

		private function initRGBCamera():void {
			_rgbCamera = new Bitmap(new BitmapData(640, 480));
			_rgbCamera.scaleX = _rgbCamera.scaleY = .25;
			this.addChild(_rgbCamera);
			_rgbCamera.y = stage.stageHeight - _rgbCamera.height;
		}

		private function onRGBFrame(bmpData:BitmapData):void {
			_rgbCamera.bitmapData = bmpData;
		}

		private function onEnterFrame(event:Event):void {
			drawSkeleton();
		}

		private function onSkeletonAdded(skeleton:ExtendedSkeleton):void {
			if (!_activeSkeleton) setActive(skeleton)
		}

		private function onSkeletonRemoved(skeleton:ExtendedSkeleton):void {
			if (_activeSkeleton == skeleton) {
				deactivateSkeleton();
				if (AIRKinectManager.numSkeletons() > 0) setActive(AIRKinectManager.getNextSkeleton());
			}
		}

		private function setActive(skeleton:ExtendedSkeleton):void {
			_activeSkeleton = skeleton;
		}

		private function deactivateSkeleton():void {
			_activeSkeleton = null;
		}

		private function drawSkeleton():void {
			while (_skeletonsSprite.numChildren > 0) _skeletonsSprite.removeChildAt(0);
			_historySprite.graphics.clear();
			if (!_activeSkeleton) return;

			var joint:AIRKinectSkeletonJoint;
			var scaler:Vector3D = new Vector3D(stage.stageWidth, stage.stageHeight, _kinectMaxDepthInFlash);
			var jointSprite:Sprite;

			var color:uint;
			for (var i:uint = 0; i < _activeSkeleton.numJoints; i++) {
				joint = _activeSkeleton.getJointScaled(i, scaler);
				jointSprite = new Sprite();
				color = (joint.z / (_kinectMaxDepthInFlash * 4)) * 255 << 16 | (1 - (joint.z / (_kinectMaxDepthInFlash * 4))) * 255 << 8 | 0;
				jointSprite.graphics.beginFill(color);
				jointSprite.graphics.drawCircle(0, 0, 15);
				jointSprite.x = joint.x;
				jointSprite.y = joint.y;
				jointSprite.z = joint.z;
				_skeletonsSprite.addChild(jointSprite);
			}

			//History Drawing
			var jointsToTrace:Vector.<uint> = new <uint>[AIRKinectSkeleton.HAND_RIGHT, AIRKinectSkeleton.HAND_LEFT];
			for (i = 0; i < _activeSkeleton.skeletonHistory.length; i++) {
				for each(var jointID:uint in jointsToTrace) {
					joint = _activeSkeleton.getPositionInHistory(jointID, i);
					joint.x *= scaler.x;
					joint.y *= scaler.y;
					joint.z *= scaler.z;
					var timeRatio:Number = Math.abs(1 - (i / _activeSkeleton.skeletonHistory.length));
					_historySprite.graphics.beginFill(0xff0000, timeRatio / 2);
					_historySprite.graphics.drawCircle(joint.x, joint.y, timeRatio * 15);

					//Maps 3d Position into 2d Space
//					var convertedPosition:Point = _skeletonsSprite.local3DToGlobal(new Vector3D(joint.x,  joint.y,  joint.z));
//					_historySprite.graphics.drawCircle(convertedPosition.x,  convertedPosition.y,  timeRatio * 15);
				}
			}
		}
	}
}