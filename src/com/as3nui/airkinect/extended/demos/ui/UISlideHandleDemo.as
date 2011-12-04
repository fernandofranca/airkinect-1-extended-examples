package com.as3nui.airkinect.extended.demos.ui {
	import com.as3nui.airkinect.extended.demos.ui.display.ColoredSlideHandle;
	import com.as3nui.airkinect.extended.demos.ui.display.SimpleSelectionTimer;
	import com.as3nui.airkinect.extended.ui.components.SlideHandle;
	import com.as3nui.airkinect.extended.ui.components.Target;
	import com.as3nui.airkinect.extended.ui.events.UIEvent;
	import com.as3nui.airkinect.extended.ui.helpers.MouseSimulator;
	import com.as3nui.airkinect.extended.ui.managers.UIManager;
	import com.as3nui.airkinect.extended.ui.objects.Cursor;
	import com.as3nui.nativeExtensions.kinect.AIRKinect;
	import com.as3nui.nativeExtensions.kinect.data.SkeletonPosition;
	import com.as3nui.nativeExtensions.kinect.events.SkeletonFrameEvent;
	import com.greensock.TweenLite;

	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Vector3D;

	public class UISlideHandleDemo extends BaseUIDemo {
		private var _gallery:Sprite;
		private var _mouseSimulator:MouseSimulator;
		private var _leftHandCursor:Cursor;

		//Gallery
		private var _totalSections:uint;
		private var _totalRows:uint;
		private var _totalColumns:int;

		private var _totalSectionSize:Number;
		private var _currentSectionIndex:int;
		private var _sectionPadding:Number;

		//Sliders
		private var _rightSlideHandle:ColoredSlideHandle;
		private var _leftSlideHandle:ColoredSlideHandle;

		public function UISlideHandleDemo() {

		}
		
		override protected function initDemo():void {
			UIManager.init(stage);
			_mouseSimulator = new MouseSimulator(stage);

			createCursor();
			createGallery();
			createHandles();
			AIRKinect.addEventListener(SkeletonFrameEvent.UPDATE, onSkeletonFrame);
		}

		private function createGallery():void {
			_gallery = new Sprite();
			this.addChild(_gallery);

			function getBox():Sprite{
				var s:Sprite = new Sprite();
				s.graphics.beginFill(Math.random()*0xffffff);
				s.graphics.drawRect(0,0,200,200);
				return s;
			}

			var box:Sprite = getBox();
			_totalSections 	= 4;
			_totalRows 		= 3;
			_totalColumns 	= 2;

			var rowSpacing:uint = 25;
			var colSpacing:uint = 25;
			_totalSectionSize = (_totalRows * box.width) + (_totalRows*rowSpacing);
			_sectionPadding = (stage.stageWidth - _totalSectionSize)/2;

			var target:Target;
			for (var sectionIndex:uint = 0;sectionIndex<_totalSections;sectionIndex++){
				for (var row:uint = 0;row<_totalRows;row++){
					for (var col:uint = 0;col<_totalColumns;col++){
						box = getBox();
						target =  new Target(box, new SimpleSelectionTimer());
						target.x += ((sectionIndex +1) * _sectionPadding);
						target.x += ((sectionIndex *_totalRows) * box.width);
						target.x += ((sectionIndex*_totalRows) * rowSpacing);
						target.x += (row * box.width);
						target.x += (row * rowSpacing);
						target.y = col * (box.height + colSpacing);
						_gallery.addChild(target);
					}
				}
			}

			_currentSectionIndex = Math.floor(_totalSections/2);
			_gallery.x = -_currentSectionIndex * (_totalSectionSize + _sectionPadding);
			_gallery.y = (stage.stageHeight/2) - (_gallery.height/2);
		}

		private function createHandles():void {
			_leftSlideHandle = new ColoredSlideHandle(0x00ff00, 30, SlideHandle.LEFT);
			this.addChild(_leftSlideHandle);
			_leftSlideHandle.x = 930;
			_leftSlideHandle.y = (stage.stageHeight/2) - 30;
			_leftSlideHandle.addEventListener(UIEvent.SELECTED, onLeftSlideSelected);
			_leftSlideHandle.addEventListener(UIEvent.MOVE, onLeftMove);
//			_leftSlideHandle.showCaptureArea();

			_rightSlideHandle = new ColoredSlideHandle(0x00ff00, 30, SlideHandle.RIGHT);
			_rightSlideHandle.x = 10;
			_rightSlideHandle.y = _leftSlideHandle.y;
			_rightSlideHandle.addEventListener(UIEvent.SELECTED, onRightSlideSelected);
			_rightSlideHandle.addEventListener(UIEvent.MOVE, onRightMove);
			this.addChild(_rightSlideHandle);
//			_rightSlideHandle.showCaptureArea();
		}

		private function onRightMove(event:UIEvent):void {
			if(_currentSectionIndex <=0) return;
			var originalX:Number = -_currentSectionIndex * (_totalSectionSize + _sectionPadding);
			var destinationX:Number = originalX + (event.value * ((_totalSectionSize + _sectionPadding)/2));
			TweenLite.to(_gallery, .3, {x:destinationX});
		}

		private function onLeftMove(event:UIEvent):void {
			if(_currentSectionIndex >=(_totalSections-1)) return;
			var originalX:Number = -_currentSectionIndex * (_totalSectionSize + _sectionPadding);
			var destinationX:Number = originalX - (event.value * ((_totalSectionSize + _sectionPadding)/2));
			TweenLite.to(_gallery, .3, {x:destinationX});
		}

		private function onRightSlideSelected(event:UIEvent):void {
			if(_currentSectionIndex <=0) return;
			_currentSectionIndex--;
			TweenLite.to(_gallery, 1, {x:-_currentSectionIndex * (_totalSectionSize + _sectionPadding)});
			updateSliders();
		}


		private function onLeftSlideSelected(event:UIEvent):void {
			if(_currentSectionIndex >=(_totalSections-1)) return;
			_currentSectionIndex++;
			TweenLite.to(_gallery, 1, {x:-_currentSectionIndex * (_totalSectionSize + _sectionPadding)});
			updateSliders();
		}

		private function updateSliders():void {
			if(_currentSectionIndex >=(_totalSections-1)) {
				_leftSlideHandle.enabled = false;
			}else if(!_leftSlideHandle.enabled) {
				_leftSlideHandle.enabled = true;
			}

			if(_currentSectionIndex <=0) {
				_rightSlideHandle.enabled = false;
			} else if(!_rightSlideHandle.enabled) {
				_rightSlideHandle.enabled = true;
			}
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