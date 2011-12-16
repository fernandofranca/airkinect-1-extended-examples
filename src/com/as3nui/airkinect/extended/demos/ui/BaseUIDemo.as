/**
 *
 * User: Ross
 * Date: 12/3/11
 * Time: 3:29 PM
 */
package com.as3nui.airkinect.extended.demos.ui {
	import com.as3nui.airkinect.extended.demos.core.BaseDemo;
	import com.as3nui.nativeExtensions.kinect.AIRKinect;
	import com.as3nui.nativeExtensions.kinect.data.AIRKinectFlags;
	import com.as3nui.nativeExtensions.kinect.events.CameraFrameEvent;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.geom.Point;

	public class BaseUIDemo extends BaseDemo {
		protected var _rgbCamera:Bitmap;

		public function BaseUIDemo() {
		}

		override protected function onAddedToStage(event:Event):void {
			super.onAddedToStage(event);
			AIRKinect.initialize(AIRKinectFlags.NUI_INITIALIZE_FLAG_USES_SKELETON | AIRKinectFlags.NUI_INITIALIZE_FLAG_USES_COLOR);

			initRGBCamera();
			initDemo();
		}

		override protected function onRemovedFromStage(event:Event):void {
			super.onRemovedFromStage(event);

			uninitDemo();
			_rgbCamera.bitmapData.dispose();
			_rgbCamera = null;

			AIRKinect.removeEventListener(CameraFrameEvent.RGB, onRGBFrame);
			AIRKinect.shutdown();
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
		}

		protected function uninitDemo():void {

		}

	}
}