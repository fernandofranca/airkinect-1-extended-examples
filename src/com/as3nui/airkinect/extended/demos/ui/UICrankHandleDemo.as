package com.as3nui.airkinect.extended.demos.ui {
	import com.as3nui.airkinect.extended.demos.ui.display.ColoredCrankHandle;
	import com.as3nui.airkinect.extended.ui.events.UIEvent;
	import com.as3nui.airkinect.extended.ui.helpers.MouseSimulator;
	import com.as3nui.airkinect.extended.ui.managers.UIManager;
	import com.as3nui.airkinect.extended.ui.objects.Cursor;
	import com.as3nui.nativeExtensions.kinect.AIRKinect;
	import com.as3nui.nativeExtensions.kinect.data.SkeletonPosition;
	import com.as3nui.nativeExtensions.kinect.events.SkeletonFrameEvent;

	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Vector3D;
	import flash.net.URLRequest;

	public class UICrankHandleDemo extends BaseUIDemo {
		private var _mouseSimulator:MouseSimulator;
		private var _leftHandCursor:Cursor;

		private var _imgUrl:String = "http://www.taramtamtam.com/wallpapers/Animal/M/Monkey/images/Monkey_2.jpg";

		//Handles
		private var _crankHandle:ColoredCrankHandle;
		private var _container:Sprite;
		private var _originalScale:Number;

		public function UICrankHandleDemo() {

		}
		
		override protected function initDemo():void {
			UIManager.init(stage);
			_mouseSimulator = new MouseSimulator(stage);
			_container = new Sprite();
			this.addChild(_container);
			this.addChild(_rgbCamera);

			loadImage();
		}

		private function loadImage():void {
			var loader:Loader = new Loader()
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onImageLoadComplete);
			loader.load(new URLRequest(_imgUrl))
		}

		private function onImageLoadComplete(event:Event):void {
			var loader:Loader = (event.target as LoaderInfo).loader;
			loader.content.x -= loader.content.width/2;
			loader.content.y -= loader.content.height/2;
			_container.addChild(loader.content);
			
			_container.x = stage.stageWidth/2;
			_container.y = stage.stageHeight/2;
			_container.scaleX = _container.scaleY = .5;

			createCursor();
			createHandles();
			AIRKinect.addEventListener(SkeletonFrameEvent.UPDATE, onSkeletonFrame);
		}

		private function createHandles():void {
			_crankHandle = new ColoredCrankHandle();
			_crankHandle.x = 800;
			_crankHandle.y = 300;
			this.addChild(_crankHandle);

			_crankHandle.addEventListener(UIEvent.CAPTURE, onCrankCapture);
			_crankHandle.addEventListener(UIEvent.MOVE, onCrankMove);
			_crankHandle.showCaptureArea();
			_crankHandle.drawDebug = true;
		}

		private function onCrankCapture(event:UIEvent):void {
			_originalScale = _container.scaleX;
		}

		private function onCrankMove(event:UIEvent):void {
			var ratio:Number = event.value / (Math.PI * 2);
			//trace(event.value * (180/Math.PI));
			_container.scaleX = _container.scaleY = _originalScale + ratio;
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
			if(event.skeletonFrame.numSkeletons >0){
				var skeletonPosition:SkeletonPosition = event.skeletonFrame.getSkeletonPosition(0);
				var leftHand:Vector3D = skeletonPosition.getElement(SkeletonPosition.HAND_RIGHT);
				//var leftHand:Vector3D = skeletonPosition.getElement(SkeletonPosition.WRIST_LEFT);
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
	}
}