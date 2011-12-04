/**
 *
 * User: rgerbasi
 * Date: 10/16/11
 * Time: 5:51 PM
 */
package com.as3nui.airkinect.extended.demos.manager {
	import com.as3nui.airkinect.extended.manager.AIRKinectManager;
	import com.as3nui.airkinect.extended.manager.regions.Region;
	import com.as3nui.airkinect.extended.manager.regions.RegionPlanes;
	import com.as3nui.airkinect.extended.manager.skeleton.Skeleton;
	import com.as3nui.nativeExtensions.kinect.data.AIRKinectFlags;
	import com.as3nui.nativeExtensions.kinect.data.SkeletonPosition;

	import flash.desktop.NativeApplication;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.utils.Dictionary;

	public class RegionsDemo extends Sprite {

		//RGB Camera Bitmap
		private var _rgbCamera:Bitmap;

		//Depth in Flash
		private var _kinectMaxDepthInFlash:uint = 200;

		//Drawing Skeletons
		private var _skeletonsSprite:Sprite;

		//Drawing Regions
		private var _regionsSprite:Sprite;

		//Current Active Skeleton
		private var _activeSkeleton:Skeleton;

		//Collection of regions that can be touched
		private var _touchRegions:Vector.<Region>;

		//Collection of regions current being touched
		private var _touchedRegions:Vector.<Region>;

		//Sound Stuff
		[Embed(source="/../assets/embeded/sounds/bass2.Gminor.90.mp3")]
		private var BassSound:Class;

		[Embed(source="/../assets/embeded/sounds/balladHihatopen.90.mp3")]
		private var DrumSound:Class;

		[Embed(source="/../assets/embeded/sounds/funk_guitar_A7_90.mp3")]
		private var GuitarSound:Class;

		[Embed(source="/../assets/embeded/sounds/wurlitzer_ambient_92.mp3")]
		private var KeyboardSound:Class;

		private var _bass:Sound;
		private var _drums:Sound;
		private var _guitar:Sound;
		private var _keyboard:Sound;
		private var _soundChannels:Dictionary;


		public function RegionsDemo() {
			this.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage)
		}

		private function onAddedToStage(event:Event):void {
			initDemo();

			_soundChannels = new Dictionary(true);
			_bass = new BassSound() as Sound;
			_drums = new DrumSound() as Sound;
			_guitar = new GuitarSound() as Sound;
			_keyboard = new KeyboardSound() as Sound;

			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.addEventListener(Event.RESIZE, onStageResize);
		}

		private function onStageResize(event:Event):void {
			root.transform.perspectiveProjection.projectionCenter = new Point(stage.stageWidth / 2, stage.stageHeight / 2);
			if (_rgbCamera) _rgbCamera.y = stage.stageHeight - _rgbCamera.height;
		}

		private function initDemo():void {
			_skeletonsSprite = new Sprite();
			this.addChild(_skeletonsSprite);

			_touchRegions = new <Region>[];
			_touchedRegions = new <Region>[];

			_regionsSprite = new Sprite();
			this.addChild(_regionsSprite);

			initKinect();
			initRGBCamera();
			initRegions();

			NativeApplication.nativeApplication.addEventListener(Event.EXITING, onExiting);
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

		private function onExiting(event:Event):void {
			AIRKinectManager.shutdown();
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

		private function initRegions():void {
			var frontTopLeft:Region = new Region(.3, .3, .4, .4, 1, 2, "ftl");
			var frontBottomLeft:Region = new Region(.3, .6, .4, .7, 1, 2, "fbl");

			var frontTopRight:Region = new Region(.6, .3, .7, .4, 1, 2, "ftr");
			var frontBottomRight:Region = new Region(.6, .6, .7, .7, 1, 2, "fbr");

			_touchRegions.push(frontTopLeft);
			_touchRegions.push(frontBottomLeft);
			_touchRegions.push(frontBottomRight);
			_touchRegions.push(frontTopRight);
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
			for each(var region:Region in _touchRegions) {
				drawRegion(region);
			}
		}

		private function drawRegion(region:Region):void {
			var scaledRegion:Region = region.scale(stage.stageWidth, stage.stageHeight, _kinectMaxDepthInFlash);
			var kinectRegionPlanes:RegionPlanes = scaledRegion.local3DToGlobal(this);

			var alpha:Number = .5;
			if (_activeSkeleton) {
				var leftHand:Vector3D = _activeSkeleton.getElement(SkeletonPosition.HAND_LEFT);
				var rightHand:Vector3D = _activeSkeleton.getElement(SkeletonPosition.HAND_RIGHT);
				if (region.contains3D(leftHand) || region.contains3D(rightHand)) {
					alpha = 1;
					if (_touchedRegions.indexOf(region) == -1) {
						_touchedRegions.push(region);
						onTouched(region);
					}
				} else {
					if (_touchedRegions.indexOf(region) != -1) {
						onReleased(region);
						_touchedRegions.splice(_touchedRegions.indexOf(region), 1);
					}
				}
			}

			_regionsSprite.graphics.beginFill(0x00ff00, alpha);
			_regionsSprite.graphics.drawRect(kinectRegionPlanes.front.x, kinectRegionPlanes.front.y, kinectRegionPlanes.front.width, kinectRegionPlanes.front.height);
			_regionsSprite.graphics.beginFill(0x0000ff, alpha);
			_regionsSprite.graphics.drawRect(kinectRegionPlanes.back.x, kinectRegionPlanes.back.y, kinectRegionPlanes.back.width, kinectRegionPlanes.back.height);
		}

		private function onTouched(region:Region):void {
			switch (region.id) {
				case "ftl":
					_soundChannels[_drums] = _drums.play(0, 999);
					break;
				case "ftr":
					_soundChannels[_guitar] = _guitar.play(0, 999);
					break;
				case "fbl":
					_soundChannels[_bass] = _bass.play(0, 999);
					break;
				case "fbr":
					_soundChannels[_keyboard] = _keyboard.play(0, 999);
					break;
			}
			trace("Touched region :: " + region.id);
		}

		private function onReleased(region:Region):void {
			trace("Released region :: " + region.id);
			switch (region.id) {
				case "ftl":
					if (_soundChannels[_drums]) (_soundChannels[_drums] as SoundChannel).stop();
					break;
				case "ftr":
					if (_soundChannels[_guitar]) (_soundChannels[_guitar] as SoundChannel).stop();
					break;
				case "fbl":
					if (_soundChannels[_bass]) (_soundChannels[_bass] as SoundChannel).stop();
					break;
				case "fbr":
					if (_soundChannels[_keyboard]) (_soundChannels[_keyboard] as SoundChannel).stop();
					break;
			}
		}
	}
}