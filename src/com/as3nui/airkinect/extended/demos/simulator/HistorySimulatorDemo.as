/*
 * Copyright (c) 2012 AS3NUI
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation the
 * rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is furnished to
 * do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all copies
 * or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
 * INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
 * PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
 * FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
 * OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 */

package com.as3nui.airkinect.extended.demos.simulator {
	import com.as3nui.airkinect.extended.demos.core.BaseDemo;
	import com.as3nui.airkinect.extended.manager.AIRKinectManager;
	import com.as3nui.airkinect.extended.manager.skeleton.ExtendedSkeleton;
	import com.as3nui.airkinect.extended.simulator.SkeletonPlayer;
	import com.as3nui.nativeExtensions.kinect.data.AIRKinectSkeleton;
	import com.as3nui.nativeExtensions.kinect.data.AIRKinectSkeletonJoint;
	import com.as3nui.nativeExtensions.kinect.settings.AIRKinectFlags;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	import flash.net.FileFilter;
	import flash.ui.Keyboard;

	public class HistorySimulatorDemo extends BaseDemo {
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

		//Recorded Playback
		private var _skeletonPlayer:SkeletonPlayer;

		public function HistorySimulatorDemo() {
			_demoName = "History with Manual Simulator";
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
			AIRKinectManager.shutdown();

			stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
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

			_historySprite = new Sprite();
			this.addChild(_historySprite);

			_skeletonPlayer = new SkeletonPlayer();

			initRGBCamera();
			initKinect();
			
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		}

		private function initKinect():void {
			// trace("initKinect");
			AIRKinectManager.initialize(AIRKinectFlags.NUI_INITIALIZE_FLAG_USES_SKELETON | AIRKinectFlags.NUI_INITIALIZE_FLAG_USES_COLOR);

			AIRKinectManager.onSkeletonAdded.add(onSkeletonAdded);
			AIRKinectManager.onSkeletonRemoved.add(onSkeletonRemoved);
			AIRKinectManager.onKinectDisconnected.add(onKinectDisconnected);
			AIRKinectManager.onKinectReconnected.add(onKinectReconnected);
			AIRKinectManager.onRGBFrameUpdate.add(onRGBFrame);

			//Recorded events dispatched into manager
			AIRKinectManager.addSkeletonDispatcher(_skeletonPlayer);

			this.addEventListener(Event.ENTER_FRAME, onEnterFrame);
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
			for (i = 0; i< _activeSkeleton.skeletonHistory.length;i++){
				for each(var jointID:uint in jointsToTrace){
					joint = _activeSkeleton.getPositionInHistory(jointID,i);
					joint.x *= scaler.x;
					joint.y *= scaler.y;
					joint.z *= scaler.z;
					var timeRatio:Number = Math.abs(1-(i/_activeSkeleton.skeletonHistory.length));
					_historySprite.graphics.beginFill(0xff0000, timeRatio/2);
					_historySprite.graphics.drawCircle(joint.x,  joint.y,  timeRatio * 15);

					//Maps 3d Position into 2d Space
//					var convertedPosition:Point = _skeletonsSprite.local3DToGlobal(new Vector3D(joint.x,  joint.y,  joint.z));
//					_historySprite.graphics.drawCircle(convertedPosition.x,  convertedPosition.y,  timeRatio * 15);
				}
			}
		}


		//----------------------------------
		// Playback
		//----------------------------------
		private function onKeyUp(event:KeyboardEvent):void {
			if(event.keyCode == Keyboard.L) loadXML();
			if(event.keyCode == Keyboard.S && _skeletonPlayer.playing) _skeletonPlayer.stop();
			if(event.keyCode == Keyboard.P && _skeletonPlayer.playing){
				_skeletonPlayer.pause();
			} else if(event.keyCode == Keyboard.P && _skeletonPlayer.paused) {
				_skeletonPlayer.resume();
			}
		}

		private function loadXML():void {
			var txtFilter:FileFilter = new FileFilter("XML", "*.xml");
			var file:File = new File();
			file.addEventListener(Event.SELECT, onXMLFileSelected);
			file.browseForOpen("Please select a file...",[txtFilter]);
		}

		private function onXMLFileSelected(event:Event):void {
			var fileStream:FileStream = new FileStream();
			try {
				fileStream.open(event.target as File, FileMode.READ);
				var xml:XML = XML(fileStream.readUTFBytes(fileStream.bytesAvailable));
				fileStream.close();
				_skeletonPlayer.play(xml, true);
			} catch(e:Error) {
				trace("Error loading Config : " + e.message);
			}
		}
	}
}