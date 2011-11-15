/**
 *
 * User: rgerbasi
 * Date: 10/16/11
 * Time: 5:51 PM
 */
package com.as3nui.airkinect.extended.demos {
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
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Vector3D;

	public class AirKinectExtendedDemos extends Sprite {
		private var _kinectMaxDepthInFlash:uint = 200;
		private var _skeletonsSprite:Sprite;
		private var _trackedRegionSprite:Sprite;
		private var _activeSkeleton:Skeleton;
		private var _trackedRegion:TrackedRegion;
		
		public function AirKinectExtendedDemos() {
			this.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage)
		}

		private function onAddedToStage(event:Event):void {
			initDemo();

			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;

			stage.addEventListener(Event.RESIZE, onStageResize);
		}

		private function onStageResize(event:Event):void {
			root.transform.perspectiveProjection.projectionCenter = new Point(stage.stageWidth / 2, stage.stageHeight / 2);
		}

		private function initDemo():void {
			_skeletonsSprite = new Sprite();
			this.addChild(_skeletonsSprite);

			_trackedRegionSprite = new Sprite();
			this.addChild(_trackedRegionSprite);

			NativeApplication.nativeApplication.addEventListener(Event.EXITING, onExiting);
			initKinect();
		}

		private function initKinect():void {
//			trace("initKinect");
			if(AIRKinectManager.initialize(AIRKinectFlags.NUI_INITIALIZE_FLAG_USES_SKELETON)){
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

		private function onExiting(event:Event):void {
			AIRKinectManager.shutdown();
		}

		private function onEnterFrame(event:Event):void {
			drawSkeleton();
			drawTrackedRegion();
		}

		private function onSkeletonAdded(skeleton:Skeleton):void {
			if(!_activeSkeleton) setActive(skeleton)
		}
		
		private function onSkeletonRemoved(skeleton:Skeleton):void {
			if(_activeSkeleton == skeleton) {
				deactivateSkeleton();
				if(AIRKinectManager.numSkeletons() > 0) setActive(AIRKinectManager.getNextSkeleton());
			}
		}

		private function setActive(skeleton:Skeleton):void {
			_activeSkeleton = skeleton;
			_trackedRegion = new TrackedRegion(_activeSkeleton, SkeletonPosition.SHOULDER_CENTER, -.1, -1, .1, 1, -4, 0);

			var leftSwipeGesture:SwipeGesture = new SwipeGesture(skeleton, SkeletonPosition.HAND_LEFT, new <Region>[_trackedRegion], true, false, false);
			leftSwipeGesture.onGestureComplete.add(onSwipeComplete);

			AIRKinectGestureManager.addGesture(leftSwipeGesture);
		}

		private function deactivateSkeleton():void {
			_activeSkeleton = null;
			
			_trackedRegion.dispose();
			_trackedRegion  = null;
		}

		private function drawSkeleton():void {
			while (_skeletonsSprite.numChildren > 0) _skeletonsSprite.removeChildAt(0);
			if(!_activeSkeleton) return;

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

		private function drawTrackedRegion():void {
			_trackedRegionSprite.graphics.clear();
			if (!_trackedRegion)  return;

			var scaledRegion:Region;
			var kinectRegionPlanes:RegionPlanes;
			scaledRegion = _trackedRegion.scale(stage.stageWidth, stage.stageHeight, _kinectMaxDepthInFlash);
			kinectRegionPlanes = scaledRegion.local3DToGlobal(this);
			_trackedRegionSprite.graphics.beginFill(0x00ff00, .5);
			_trackedRegionSprite.graphics.drawRect(kinectRegionPlanes.front.x, kinectRegionPlanes.front.y, kinectRegionPlanes.front.width, kinectRegionPlanes.front.height);
			_trackedRegionSprite.graphics.beginFill(0x0000ff, .5);
			_trackedRegionSprite.graphics.drawRect(kinectRegionPlanes.back.x, kinectRegionPlanes.back.y, kinectRegionPlanes.back.width, kinectRegionPlanes.back.height);
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