/**
 *
 * User: rgerbasi
 * Date: 10/16/11
 * Time: 5:51 PM
 */
package com.as3nui.airkinect.extended.demos.ui {
	import com.as3nui.airkinect.extended.demos.ui.display.ColoredCrankHandle;
	import com.as3nui.airkinect.extended.demos.ui.display.ColoredHandle;
	import com.as3nui.airkinect.extended.demos.ui.display.ColoredSlideHandle;
	import com.as3nui.airkinect.extended.demos.ui.display.ColoredTarget;
	import com.as3nui.airkinect.extended.ui.components.Handle;
	import com.as3nui.airkinect.extended.ui.components.SlideHandle;
	import com.as3nui.airkinect.extended.ui.events.UIEvent;
	import com.as3nui.airkinect.extended.ui.helpers.MouseSimulator;
	import com.as3nui.airkinect.extended.ui.managers.UIManager;
	import com.as3nui.airkinect.extended.ui.objects.Cursor;
	import com.as3nui.nativeExtensions.kinect.AIRKinect;
	import com.as3nui.nativeExtensions.kinect.data.AIRKinectFlags;
	import com.as3nui.nativeExtensions.kinect.data.SkeletonPosition;
	import com.as3nui.nativeExtensions.kinect.events.CameraFrameEvent;
	import com.as3nui.nativeExtensions.kinect.events.SkeletonFrameEvent;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	import flash.text.TextField;

	public class AirKinectUIDemo extends Sprite {
		private var _mouseSimulator:MouseSimulator;
		private var _container:Sprite;
		private var _leftHandCursor:Cursor;

		private var _rgbCamera:Bitmap;
		private var _info:TextField;
		private var _slideOutput:TextField;

		public function AirKinectUIDemo() {
			this.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage)
		}

		private function onAddedToStage(event:Event):void {
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;

			AIRKinect.initialize(AIRKinectFlags.NUI_INITIALIZE_FLAG_USES_SKELETON | AIRKinectFlags.NUI_INITIALIZE_FLAG_USES_COLOR);
			
			_container = new Sprite();
			this.addChild(_container);

			initDemo();
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;

			stage.addEventListener(Event.RESIZE, onStageResize);
		}

		private function onStageResize(event:Event):void {
			root.transform.perspectiveProjection.projectionCenter = new Point(stage.stageWidth / 2, stage.stageHeight / 2);

			_container.x = (stage.stageWidth - _container.width)/2;
			_rgbCamera.y =  stage.stageHeight - _rgbCamera.height;
		}
		
		private function initDemo():void {
			UIManager.init(stage);

			_info = new TextField();
			this.addChild(_info);

			var circle:Shape = new Shape();
			circle.graphics.lineStyle(2,0x000000);
			circle.graphics.beginFill(0x00ff00);
			circle.graphics.drawCircle(0,0,20);

			_leftHandCursor = new Cursor("_kinect_", SkeletonPosition.HAND_LEFT, circle);
			UIManager.addCursor(_leftHandCursor);

			_mouseSimulator = new MouseSimulator(stage);

			var handle:Handle;
			var spacing:uint = 100;
			var totalHandles:int = 10;

			for (var i:uint = 0;i<totalHandles;i++){
				handle = new ColoredHandle(Math.random()*0xffffff, totalHandles + Math.round(Math.random() * 30));
				handle.x = i * spacing;
				handle.y = 100;
				
				_container.addChild(handle);
				handle.addEventListener(UIEvent.SELECTED, onHandleSelected);

				handle.showCaptureArea();
			}

			var leftSlideHandle:ColoredSlideHandle = new ColoredSlideHandle(0x00ff00, 30, SlideHandle.LEFT);
			leftSlideHandle.x = 600;
			leftSlideHandle.y = 300;
			this.addChild(leftSlideHandle);
			leftSlideHandle.addEventListener(UIEvent.SELECTED, onLeftSlideSelected);
//			leftSlideHandle.showCaptureArea();

			var rightSlideHandle:ColoredSlideHandle = new ColoredSlideHandle(0x00ff00, 30, SlideHandle.RIGHT);
			rightSlideHandle.x = 600;
			rightSlideHandle.y = 500;
			rightSlideHandle.addEventListener(UIEvent.SELECTED, onRightSlideSelected);
			this.addChild(rightSlideHandle);
//			rightSlideHandle.showCaptureArea();

			var target:ColoredTarget = new ColoredTarget();
			target.x = 10;
			target.y = 300;
			this.addChild(target);

			_slideOutput = new TextField();
			_slideOutput.text = "Slide to change";
			_slideOutput.x = 600;
			_slideOutput.y = 400;
			this.addChild(_slideOutput);


			var crankHandle:ColoredCrankHandle = new ColoredCrankHandle();
			crankHandle.x = 300;
			crankHandle.y = 300;
			this.addChild(crankHandle);
			
			crankHandle.addEventListener(UIEvent.MOVE, onCrankMove);
			crankHandle.showCaptureArea();
			crankHandle.drawDebug = true;

			AIRKinect.addEventListener(SkeletonFrameEvent.UPDATE, onSkeletonFrame);
			AIRKinect.addEventListener(CameraFrameEvent.RGB, onRGBFrame);

			_rgbCamera =new Bitmap(new BitmapData(640, 480));
			_rgbCamera.scaleX = _rgbCamera.scaleY = .25;
			this.addChild(_rgbCamera);
			_rgbCamera.y =  stage.stageHeight - _rgbCamera.height;
		}

		private function onCrankMove(event:UIEvent):void {
			trace(event.value * (180/Math.PI));
		}

		private function onRightSlideSelected(event:UIEvent):void {
			_slideOutput.text = "Right Slide";
		}

		private function onLeftSlideSelected(event:UIEvent):void {
			_slideOutput.text = "Left Slide";
		}

		private function onSkeletonFrame(event:SkeletonFrameEvent):void {
			if(event.skeletonFrame.numSkeletons >0){
				var skeletonPosition:SkeletonPosition = event.skeletonFrame.getSkeletonPosition(0);


				//var leftHand:Vector3D = skeletonPosition.getElement(SkeletonPosition.HAND_LEFT);
				var leftHand:Vector3D = skeletonPosition.getElement(SkeletonPosition.WRIST_LEFT);
				var pad:Number = .35;

				_leftHandCursor.enabled = true;
				if(leftHand.x < pad || leftHand.x > 1-pad) _leftHandCursor.enabled = false;
				if(leftHand.y < pad || leftHand.y > 1-pad) _leftHandCursor.enabled = false;

				if(!_leftHandCursor.enabled) return;
				
				leftHand.x -= pad;
				leftHand.x /= (1-pad) - pad;
				leftHand.y -= pad;
				leftHand.y /= (1-pad) - pad;

				_leftHandCursor.update(leftHand.x, leftHand.y, leftHand.z);
			}
		}

		private function onHandleSelected(event:UIEvent):void {
			_info.text = event.currentTarget.name + " Selected";
		}

		private function onRGBFrame(event:CameraFrameEvent):void {
			_rgbCamera.bitmapData = event.frame;
		}
	}
}