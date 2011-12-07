/**
 *
 * User: rgerbasi
 * Date: 12/6/11
 * Time: 4:03 PM
 */
package com.as3nui.airkinect.extended.demos.recorder {
	import com.as3nui.airkinect.extended.recorder.SkeletonPlayer;
	import com.as3nui.airkinect.extended.recorder.SkeletonRecorder;
	import com.as3nui.nativeExtensions.kinect.AIRKinect;
	import com.as3nui.nativeExtensions.kinect.data.AIRKinectFlags;
	import com.as3nui.nativeExtensions.kinect.data.SkeletonFrame;
	import com.as3nui.nativeExtensions.kinect.data.SkeletonPosition;
	import com.as3nui.nativeExtensions.kinect.events.CameraFrameEvent;
	import com.as3nui.nativeExtensions.kinect.events.SkeletonFrameEvent;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
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

	public class RecorderDemo extends Sprite {
		private const KinectMaxDepthInFlash:Number = 200;


		private var _rgbCamera:Bitmap;
		private var _skeletonsSprite:Sprite;
		private var _currentSkeletons:Vector.<SkeletonPosition>;
		private var _currentSimulatedSkeletons:Vector.<SkeletonPosition>;
		private var _skeletonRecorder:SkeletonRecorder;
		private var _skeletonPlayer:SkeletonPlayer;

		public function RecorderDemo() {
			this.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage)
		}

		protected function onAddedToStage(event:Event):void {
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;

			AIRKinect.initialize(AIRKinectFlags.NUI_INITIALIZE_FLAG_USES_SKELETON | AIRKinectFlags.NUI_INITIALIZE_FLAG_USES_COLOR);

			initRGBCamera();
			initDemo();
			stage.addEventListener(Event.RESIZE, onStageResize);
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

		protected function onStageResize(event:Event):void {
			root.transform.perspectiveProjection.projectionCenter = new Point(stage.stageWidth / 2, stage.stageHeight / 2);
			_rgbCamera.y = stage.stageHeight - _rgbCamera.height;
		}

		protected function initDemo():void {
			_skeletonRecorder = new SkeletonRecorder();
			_skeletonPlayer = new SkeletonPlayer();
			_skeletonPlayer.addEventListener(SkeletonFrameEvent.UPDATE, onSimulatedSkeletonFrame);

			_skeletonsSprite = new Sprite();
			this.addChild(_skeletonsSprite);

			this.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			AIRKinect.addEventListener(SkeletonFrameEvent.UPDATE, onSkeletonFrame);

			createUI();

		}

		private function onSkeletonFrame(e:SkeletonFrameEvent):void {
			_currentSkeletons = new <SkeletonPosition>[];
			var skeletonFrame:SkeletonFrame = e.skeletonFrame;
			if (skeletonFrame.numSkeletons > 0) {
				for (var j:uint = 0; j < skeletonFrame.numSkeletons; j++) {
					_currentSkeletons.push(skeletonFrame.getSkeletonPosition(j));
				}
			}
		}

		private function onSimulatedSkeletonFrame(e:SkeletonFrameEvent):void {
			_currentSimulatedSkeletons = new <SkeletonPosition>[];
			var skeletonFrame:SkeletonFrame = e.skeletonFrame;
			if (skeletonFrame.numSkeletons > 0) {
				for (var j:uint = 0; j < skeletonFrame.numSkeletons; j++) {
					_currentSimulatedSkeletons.push(skeletonFrame.getSkeletonPosition(j));
				}
			}
		}

		//Enterframe
		private function onEnterFrame(event:Event):void {
			drawSkeletons();
		}

		private function createUI():void {
			var recordButton:SimpleButton = new SimpleButton("Record", 0xeeeeee);
			recordButton.x = 10;
			recordButton.y = 10;
			this.addChild(recordButton);
			recordButton.addEventListener(MouseEvent.CLICK, onRecordClick);

			var playButton:SimpleButton = new SimpleButton("Play", 0xeeeeee);
			playButton.x = 10;
			playButton.y = 50;
			this.addChild(playButton);
			playButton.addEventListener(MouseEvent.CLICK, onPlayClick);

			var stopButton:SimpleButton = new SimpleButton("Stop", 0xeeeeee);
			stopButton.x = 70;
			stopButton.y = 10;
			this.addChild(stopButton);
			stopButton.addEventListener(MouseEvent.CLICK, onStopClick);
		}

		private function onRecordClick(event:MouseEvent):void {
			trace("recording");
			_skeletonRecorder.record();
		}

		private function onStopClick(event:MouseEvent):void {
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

		private function onSaveSuccess(e:Event):void {

		}

		private function onSaveCancel(e:Event):void {}


		private function onPlayClick(event:MouseEvent):void {
			loadXML();
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

		private function drawSkeletons():void {
			while (_skeletonsSprite.numChildren > 0) _skeletonsSprite.removeChildAt(0);
			if (!AIRKinect.skeletonEnabled) return;

			var allSkeletons:Vector.<SkeletonPosition> = _currentSimulatedSkeletons ? _currentSkeletons.concat(_currentSimulatedSkeletons) : _currentSkeletons;
			var element:Vector3D;
			var scaler:Vector3D = new Vector3D(stage.stageWidth, stage.stageHeight, KinectMaxDepthInFlash);
			var elementSprite:Sprite;

			var color:uint;
			for each(var skeleton:SkeletonPosition in allSkeletons) {
				for (var i:uint = 0; i < skeleton.numElements; i++) {
					element = skeleton.getElementScaled(i, scaler);

					elementSprite = new Sprite();
					color = (element.z / (KinectMaxDepthInFlash * 4)) * 255 << 16 | (1 - (element.z / (KinectMaxDepthInFlash * 4))) * 255 << 8 | 0;
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
}

import flash.display.Sprite;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;

class SimpleButton extends Sprite {
	private var _label:String;
	private var _color:uint;
	private var _text:TextField;

	public function SimpleButton(label:String, color:uint):void {
		this.mouseChildren = false;
		this.mouseEnabled = this.buttonMode = true;

		_label = label;
		_color = color;
		draw();
	}

	private function draw():void {
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
	