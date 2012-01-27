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
	import com.as3nui.airkinect.extended.simulator.SkeletonPlayer;
	import com.as3nui.airkinect.extended.simulator.SkeletonRecorder;
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
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.utils.ByteArray;

	public class SimulatorDemo extends BaseDemo {
		protected const KinectMaxDepthInFlash:Number = 200;


		protected var _rgbCamera:Bitmap;
		protected var _skeletonsSprite:Sprite;
		protected var _currentSkeletons:Vector.<AIRKinectSkeleton>;
		protected var _currentSimulatedSkeletons:Vector.<AIRKinectSkeleton>;
		protected var _skeletonRecorder:SkeletonRecorder;
		protected var _skeletonPlayer:SkeletonPlayer;

		public function SimulatorDemo() {
			_demoName = "Basic Manual Simulator";
			_currentSkeletons = new <AIRKinectSkeleton>[];
		}

		override protected function onAddedToStage(event:Event):void {
			super.onAddedToStage(event);
			AIRKinect.initialize(AIRKinectFlags.NUI_INITIALIZE_FLAG_USES_SKELETON | AIRKinectFlags.NUI_INITIALIZE_FLAG_USES_COLOR);

			initRGBCamera();
			initDemo();
		}

		override protected function onRemovedFromStage(event:Event):void {
			super.onRemovedFromStage(event);

			this.removeChildren();
			_rgbCamera.bitmapData.dispose();
			_rgbCamera = null;
			AIRKinect.shutdown();

			AIRKinect.removeEventListener(CameraFrameEvent.RGB, onRGBFrame);
			_skeletonPlayer.removeEventListener(SkeletonFrameEvent.UPDATE, onSimulatedSkeletonFrame);
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
			_rgbCamera.y = stage.stageHeight - _rgbCamera.height;
		}

		protected function initDemo():void {
			_skeletonRecorder = new SkeletonRecorder();
			_skeletonPlayer = new SkeletonPlayer();
			_skeletonPlayer.addEventListener(SkeletonFrameEvent.UPDATE, onSimulatedSkeletonFrame, false, 0, true);

			_skeletonsSprite = new Sprite();
			this.addChild(_skeletonsSprite);

			this.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			AIRKinect.addEventListener(SkeletonFrameEvent.UPDATE, onSkeletonFrame);

			createUI();

		}

		protected function onSkeletonFrame(e:SkeletonFrameEvent):void {
			_currentSkeletons = new <AIRKinectSkeleton>[];
			var skeletonFrame:AIRKinectSkeletonFrame = e.skeletonFrame;
			if (skeletonFrame.numSkeletons > 0) {
				for (var j:uint = 0; j < skeletonFrame.numSkeletons; j++) {
					_currentSkeletons.push(skeletonFrame.getSkeleton(j));
				}
			}
		}

		protected function onSimulatedSkeletonFrame(e:SkeletonFrameEvent):void {
			_currentSimulatedSkeletons = new <AIRKinectSkeleton>[];
			var skeletonFrame:AIRKinectSkeletonFrame = e.skeletonFrame;
			if (skeletonFrame.numSkeletons > 0) {
				for (var j:uint = 0; j < skeletonFrame.numSkeletons; j++) {
					_currentSimulatedSkeletons.push(skeletonFrame.getSkeleton(j));
				}
			}
		}

		//Enterframe
		protected function onEnterFrame(event:Event):void {
			drawSkeletons();
		}

		protected function createUI():void {
			var recordButton:SimpleButton = new SimpleButton("Record", 0xeeeeee);
			recordButton.x = 10;
			recordButton.y = 20;
			this.addChild(recordButton);
			recordButton.addEventListener(MouseEvent.CLICK, onRecordClick, false, 0, true);

			var playButton:SimpleButton = new SimpleButton("Play", 0xeeeeee);
			playButton.x = 10;
			playButton.y = 60;
			this.addChild(playButton);
			playButton.addEventListener(MouseEvent.CLICK, onPlayClick, false, 0, true);

			var stopButton:SimpleButton = new SimpleButton("Stop", 0xeeeeee);
			stopButton.x = 70;
			stopButton.y = 20;
			this.addChild(stopButton);
			stopButton.addEventListener(MouseEvent.CLICK, onStopClick, false, 0, true);
		}

		protected function onRecordClick(event:MouseEvent):void {
			trace("recording");
			_skeletonRecorder.record();
		}

		protected function onStopClick(event:MouseEvent):void {
			if (!_skeletonRecorder.recording) return;

			trace("Stopped");
			_skeletonRecorder.stop();
			var ba:ByteArray = new ByteArray();
			ba.writeUTFBytes(_skeletonRecorder.currentRecordingXML);
			//ba.

			var fr:FileReference = new FileReference();
			fr.addEventListener(Event.SELECT, onSaveSuccess);
			fr.addEventListener(Event.CANCEL, onSaveCancel);
			fr.save(ba, "skeletonRecording.xml");
		}

		protected function onSaveSuccess(e:Event):void {

		}

		protected function onSaveCancel(e:Event):void {
		}


		protected function onPlayClick(event:MouseEvent):void {
			loadXML();
		}

		protected function loadXML():void {
			var txtFilter:FileFilter = new FileFilter("XML", "*.xml");
			var file:File = new File();
			file.addEventListener(Event.SELECT, onXMLFileSelected);
			file.browseForOpen("Please select a file...", [txtFilter]);
		}

		protected function onXMLFileSelected(event:Event):void {
			var fileStream:FileStream = new FileStream();
			try {
				fileStream.open(event.target as File, FileMode.READ);
				var xml:XML = XML(fileStream.readUTFBytes(fileStream.bytesAvailable));
				fileStream.close();
				_skeletonPlayer.play(xml, true);
			} catch (e:Error) {
				trace("Error loading Config : " + e.message);
			}
		}

		protected function drawSkeletons():void {
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

import flash.display.Sprite;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;

class SimpleButton extends Sprite {
	protected var _label:String;
	protected var _color:uint;
	protected var _text:TextField;

	public function SimpleButton(label:String, color:uint):void {
		this.mouseChildren = false;
		this.mouseEnabled = this.buttonMode = true;

		_label = label;
		_color = color;
		draw();
	}

	protected function draw():void {
		if (_text) {
			if (this.contains(_text))this.removeChild(_text);
			_text = null;
		}

		_text = new TextField();
		_text.text = _label;
		_text.autoSize = TextFieldAutoSize.LEFT;
		_text.x = 5;
		_text.y = 5;
		_text.selectable = false;
		this.addChild(_text);

		this.graphics.clear();
		this.graphics.beginFill(_color);
		this.graphics.drawRect(0, 0, _text.width + 10, _text.height + 10);
	}

	public function get label():String {
		return _label;
	}

	public function set label(value:String):void {
		_label = value;
		draw();
	}
}
	