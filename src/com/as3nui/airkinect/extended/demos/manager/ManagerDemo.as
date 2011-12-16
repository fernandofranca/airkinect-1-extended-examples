/**
 *
 * User: rgerbasi
 * Date: 10/16/11
 * Time: 5:51 PM
 */
package com.as3nui.airkinect.extended.demos.manager {
	import com.as3nui.airkinect.extended.demos.core.BaseDemo;
	import com.as3nui.airkinect.extended.manager.AIRKinectManager;
	import com.as3nui.airkinect.extended.manager.skeleton.Skeleton;
	import com.as3nui.nativeExtensions.kinect.data.AIRKinectFlags;

	import flash.desktop.NativeApplication;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Vector3D;

	public class ManagerDemo extends BaseDemo {
		//RGB Camera Bitmap
		private var _rgbCamera:Bitmap;

		//Depth in Flash
		private var _kinectMaxDepthInFlash:uint = 200;

		//Drawing Skeletons
		private var _skeletonsSprite:Sprite;

		//Current Active Skeleton
		private var _activeSkeleton:Skeleton;

		public function ManagerDemo() {
			_demoName = "Skeleton Manager Demo";
		}

		override protected function onAddedToStage(event:Event):void {
			super.onAddedToStage(event);
			initDemo();
		}

		override protected function onRemovedFromStage(event:Event):void {
			super.onRemovedFromStage(event);

			this.removeChildren();
			_rgbCamera.bitmapData.dispose();
			_rgbCamera = null;

			this.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			AIRKinectManager.shutdown();
		}


		override protected function onStageResize(event:Event):void {
			super.onStageResize(event);
			root.transform.perspectiveProjection.projectionCenter = new Point(stage.stageWidth / 2, stage.stageHeight / 2);
			if (_rgbCamera) _rgbCamera.y = stage.stageHeight - _rgbCamera.height;
		}

		private function initDemo():void {
			_skeletonsSprite = new Sprite();
			this.addChild(_skeletonsSprite);

			initRGBCamera();
			initKinect();
		}

		private function initKinect():void {
			// trace("initKinect");
			if (AIRKinectManager.initialize(AIRKinectFlags.NUI_INITIALIZE_FLAG_USES_SKELETON | AIRKinectFlags.NUI_INITIALIZE_FLAG_USES_COLOR)) {
				AIRKinectManager.onSkeletonAdded.add(onSkeletonAdded);
				AIRKinectManager.onSkeletonRemoved.add(onSkeletonRemoved);
				AIRKinectManager.onKinectDisconnected.add(onKinectDisconnected);
				AIRKinectManager.onKinectReconnected.add(onKinectReconnected);
				AIRKinectManager.onRGBFrameUpdate.add(onRGBFrame);

				this.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			}
		}

		private function onKinectDisconnected():void {
			// trace("kinect was lost :(");
			this.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
		}

		private function onKinectReconnected(success:Boolean):void {
			// trace("kinect was found, reconnection success was :: "+ success);
			this.addEventListener(Event.ENTER_FRAME, onEnterFrame);
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

		private function onSkeletonAdded(skeleton:Skeleton):void {
			if (!_activeSkeleton) setActive(skeleton)
		}

		private function onSkeletonRemoved(skeleton:Skeleton):void {
			if (_activeSkeleton == skeleton) {
				deactivateSkeleton();
				if (AIRKinectManager.numSkeletons() > 0) setActive(AIRKinectManager.getNextSkeleton());
			}
		}

		private function setActive(skeleton:Skeleton):void {
			_activeSkeleton = skeleton;
		}

		private function deactivateSkeleton():void {
			_activeSkeleton = null;
		}

		private function drawSkeleton():void {
			while (_skeletonsSprite.numChildren > 0) _skeletonsSprite.removeChildAt(0);
			if (!_activeSkeleton) return;

			var element:Vector3D;
			var scaler:Vector3D = new Vector3D(stage.stageWidth, stage.stageHeight, _kinectMaxDepthInFlash);
			var elementSprite:Sprite;

			var color:uint;
			//Skeleton Drawing
			for (var i:uint = 0; i < _activeSkeleton.numElements; i++) {
				element = _activeSkeleton.getElementScaled(i, scaler);
				elementSprite = new Sprite();
				color = (element.z / (_kinectMaxDepthInFlash * 4)) * 255 << 16 | (1 - (element.z / (_kinectMaxDepthInFlash * 4))) * 255 << 8 | 0;
				elementSprite.graphics.beginFill(color);
				elementSprite.graphics.drawCircle(0, 0, 15);
				elementSprite.x = element.x;
				elementSprite.y = element.y;
				elementSprite.z = element.z;
				_skeletonsSprite.addChild(elementSprite);
			}
		}
	}
}