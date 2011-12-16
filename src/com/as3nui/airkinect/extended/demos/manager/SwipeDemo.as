/**
 *
 * User: rgerbasi
 * Date: 10/16/11
 * Time: 5:51 PM
 */
package com.as3nui.airkinect.extended.demos.manager {
	import com.as3nui.airkinect.extended.demos.core.BaseDemo;
	import com.as3nui.airkinect.extended.manager.AIRKinectManager;
	import com.as3nui.airkinect.extended.manager.gestures.AIRKinectGestureManager;
	import com.as3nui.airkinect.extended.manager.gestures.SwipeGesture;
	import com.as3nui.airkinect.extended.manager.regions.Region;
	import com.as3nui.airkinect.extended.manager.regions.RegionPlanes;
	import com.as3nui.airkinect.extended.manager.regions.TrackedRegion;
	import com.as3nui.airkinect.extended.manager.skeleton.Skeleton;
	import com.as3nui.nativeExtensions.kinect.data.AIRKinectFlags;
	import com.as3nui.nativeExtensions.kinect.data.SkeletonPosition;

	import flash.desktop.NativeApplication;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Vector3D;

	public class SwipeDemo extends BaseDemo {
		private var _kinectMaxDepthInFlash:uint = 200;
		private var _skeletonsSprite:Sprite;
		private var _regionsSprite:Sprite;
		private var _activeSkeleton:Skeleton;
		private var _trackedRegion:TrackedRegion;
		private var _rgbCamera:Bitmap;


		public function SwipeDemo() {
			_demoName = "Swipe Demo";
		}


		override protected function onAddedToStage(event:Event):void {
			super.onAddedToStage(event);
			initDemo();
		}

		override protected function onRemovedFromStage(event:Event):void {
			super.onRemovedFromStage(event);
			_rgbCamera.bitmapData.dispose();
			_rgbCamera = null;
			this.removeChildren();

			AIRKinectGestureManager.dispose();
			AIRKinectManager.shutdown();
			this.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
		}

		override protected function onStageResize(event:Event):void {
			super.onStageResize(event);
			root.transform.perspectiveProjection.projectionCenter = new Point(stage.stageWidth / 2, stage.stageHeight / 2);
			if (_rgbCamera) _rgbCamera.y = stage.stageHeight - _rgbCamera.height;
		}

		private function initDemo():void {
			_skeletonsSprite = new Sprite();
			this.addChild(_skeletonsSprite);

			_regionsSprite = new Sprite();
			this.addChild(_regionsSprite);

			NativeApplication.nativeApplication.addEventListener(Event.EXITING, onExiting);
			initKinect();
			initRGBCamera();
		}

		private function initRGBCamera():void {
			AIRKinectManager.onRGBFrameUpdate.add(onRGBFrame);

			_rgbCamera = new Bitmap(new BitmapData(640, 480));
			_rgbCamera.scaleX = _rgbCamera.scaleY = .25;
			this.addChild(_rgbCamera);
			_rgbCamera.y = stage.stageHeight - _rgbCamera.height;
		}

		private function onRGBFrame(bmpData:BitmapData):void {
			_rgbCamera.bitmapData = bmpData;
		}

		private function initKinect():void {
//			trace("initKinect");
			if (AIRKinectManager.initialize(AIRKinectFlags.NUI_INITIALIZE_FLAG_USES_SKELETON | AIRKinectFlags.NUI_INITIALIZE_FLAG_USES_COLOR)) {
				AIRKinectManager.onSkeletonAdded.add(onSkeletonAdded);
				AIRKinectManager.onSkeletonRemoved.add(onSkeletonRemoved);
				AIRKinectManager.onKinectDisconnected.add(onKinectDisconnected);
				AIRKinectManager.onKinectReconnected.add(onKinectReconnected);

				this.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			}
		}

		private function onKinectDisconnected():void {
//			trace("kinect was lost :(");
			this.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
		}

		private function onKinectReconnected(success:Boolean):void {
//			trace("kinect was found, reconnection success was :: "+ success);
			this.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}

		private function onEnterFrame(event:Event):void {
			drawSkeleton();
			drawRegions()
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

			//Swipe with no Region Restrictions
			//var leftSwipeGesture:SwipeGesture = new SwipeGesture(skeleton, SkeletonPosition.HAND_LEFT, null, true, false, false);
			//leftSwipeGesture.onGestureComplete.add(onSwipeComplete);

			//Swipe with Region Restrictions
			_trackedRegion = new TrackedRegion(_activeSkeleton, SkeletonPosition.SHOULDER_CENTER, -.1, -1, .1, 1, -4, 0);
			var leftSwipeGesture:SwipeGesture = new SwipeGesture(skeleton, SkeletonPosition.HAND_LEFT, new <Region>[_trackedRegion], true, false, false);
			leftSwipeGesture.onGestureComplete.add(onSwipeComplete);

			AIRKinectGestureManager.addGesture(leftSwipeGesture);
		}

		private function deactivateSkeleton():void {
			_activeSkeleton = null;

			if (_trackedRegion) _trackedRegion.dispose();
			_trackedRegion = null;
		}

		private function drawSkeleton():void {
			while (_skeletonsSprite.numChildren > 0) _skeletonsSprite.removeChildAt(0);
			if (!_activeSkeleton) return;

			var element:Vector3D;
			var scaler:Vector3D = new Vector3D(stage.stageWidth, stage.stageHeight, _kinectMaxDepthInFlash);
			var elementSprite:Sprite;

			var color:uint;
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

		private function drawRegions():void {
			_regionsSprite.graphics.clear();
			drawTrackedRegion();
		}

		private function drawTrackedRegion():void {
			if (!_trackedRegion)  return;
			drawRegion(_trackedRegion);
		}

		private function drawRegion(region:Region):void {
			var scaledRegion:Region = region.scale(stage.stageWidth, stage.stageHeight, _kinectMaxDepthInFlash);
			var kinectRegionPlanes:RegionPlanes = scaledRegion.local3DToGlobal(this);

			var alpha:Number = .35;
			if (_activeSkeleton) {
				var leftHand:Vector3D = _activeSkeleton.getElement(SkeletonPosition.HAND_LEFT);
				var rightHand:Vector3D = _activeSkeleton.getElement(SkeletonPosition.HAND_RIGHT);
				if (region.contains3D(leftHand) || region.contains3D(rightHand)) alpha = .75;
				_regionsSprite.graphics.beginFill(0x0000ff, alpha);
				_regionsSprite.graphics.drawRect(kinectRegionPlanes.back.x, kinectRegionPlanes.back.y, kinectRegionPlanes.back.width, kinectRegionPlanes.back.height);
				_regionsSprite.graphics.beginFill(0x00ff00, alpha);
				_regionsSprite.graphics.drawRect(kinectRegionPlanes.front.x, kinectRegionPlanes.front.y, kinectRegionPlanes.front.width, kinectRegionPlanes.front.height);
			}
		}

		private function onSwipeComplete(swipeGesture:SwipeGesture):void {
			trace(swipeGesture.currentSwipeDirection);
			switch (swipeGesture.currentSwipeDirection) {
				case SwipeGesture.DIRECTION_LEFT:
				case SwipeGesture.DIRECTION_RIGHT:
					break;
			}
		}
	}
}