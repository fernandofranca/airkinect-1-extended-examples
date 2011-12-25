/**
 *
 * User: Ross
 * Date: 12/3/11
 * Time: 1:17 PM
 */
package com.as3nui.airkinect.extended.demos {
	import com.as3nui.airkinect.extended.demos.core.BaseDemo;
	import com.as3nui.airkinect.extended.demos.manager.HistoryDemo;
	import com.as3nui.airkinect.extended.demos.manager.ManagerDemo;
	import com.as3nui.airkinect.extended.demos.manager.RegionsDemo;
	import com.as3nui.airkinect.extended.demos.manager.SwipeDemo;
	import com.as3nui.airkinect.extended.demos.pointcloud.PointCloudHelperDemo;
	import com.as3nui.airkinect.extended.demos.simulator.HistorySimulatorDemo;
	import com.as3nui.airkinect.extended.demos.simulator.HistorySimulatorHelperDemo;
	import com.as3nui.airkinect.extended.demos.simulator.NestedSimulatorHelperDemo;
	import com.as3nui.airkinect.extended.demos.simulator.SimulatorDemo;
	import com.as3nui.airkinect.extended.demos.simulator.SimulatorHelperDemo;
	import com.as3nui.airkinect.extended.demos.ui.UICrankHandleDemo;
	import com.as3nui.airkinect.extended.demos.ui.UIHandleDemo;
	import com.as3nui.airkinect.extended.demos.ui.UIHotSpotDemo;
	import com.as3nui.airkinect.extended.demos.ui.UIPushHandleDemo;
	import com.as3nui.airkinect.extended.demos.ui.UIRepeatHandleDemo;
	import com.as3nui.airkinect.extended.demos.ui.UISandboxDemo;
	import com.as3nui.airkinect.extended.demos.ui.UISlideHandleDemo;
	import com.as3nui.airkinect.extended.demos.ui.UITargetDemo;

	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.ui.Keyboard;

	[SWF(width='1024', height='768', backgroundColor='#ffffff', frameRate='30')]
	public class AIRKinectExtendedDemos extends Sprite {

		private var _devMode:Boolean = true;
		private var _currentDemoIndex:int;

		private var _demos:Vector.<Class>;
		private var _demoText:TextField;

		public function AIRKinectExtendedDemos() {
			this.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage)
		}

		private function onAddedToStage(event:Event):void {
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;

			if(_devMode) {
				loadDemo()
			}else{
				initDemos();
				_currentDemoIndex = 0;
				loadNextDemo();
			}
		}

		private function initDemos():void {
			_demoText = new TextField();
			_demoText.autoSize = TextFieldAutoSize.LEFT;
			_demoText.textColor = 0x000000;

			_demos = new <Class>[];

			//Manager Demos
			_demos.push(HistoryDemo);
			_demos.push(RegionsDemo);
			_demos.push(ManagerDemo);
			_demos.push(SwipeDemo);

			//UI Demos
			_demos.push(UISandboxDemo);
			_demos.push(UIHandleDemo);
			_demos.push(UISlideHandleDemo);
			_demos.push(UICrankHandleDemo);
			_demos.push(UITargetDemo);
			_demos.push(UIHotSpotDemo);
			_demos.push(UIRepeatHandleDemo);

			//Simulation Demos
			_demos.push(SimulatorDemo);
			_demos.push(SimulatorHelperDemo);
			_demos.push(HistorySimulatorHelperDemo);
			_demos.push(HistorySimulatorDemo);
			_demos.push(NestedSimulatorHelperDemo);

			//PointCloud Demos
			_demos.push(PointCloudHelperDemo);

			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp)
		}

		private function onKeyUp(event:KeyboardEvent):void {
			if(event.keyCode != Keyboard.RIGHT && event.keyCode != Keyboard.LEFT && (event.keyCode < 48 || event.keyCode >57)) return;

			if(event.keyCode == Keyboard.RIGHT){
				_currentDemoIndex++;
			}else if(event.keyCode == Keyboard.LEFT){
				_currentDemoIndex--;
			//Number Keys
			}else if(event.keyCode >= 48 && event.keyCode <= 57){

				_currentDemoIndex = event.keyCode - 48;
				if(_currentDemoIndex == 0) _currentDemoIndex = 10;
				_currentDemoIndex--;
				if(event.shiftKey) _currentDemoIndex += 10;
			}

			if(_currentDemoIndex < 0) _currentDemoIndex = _demos.length -1;
			if(_currentDemoIndex >= _demos.length) _currentDemoIndex = 0;

			loadNextDemo();
		}

		private function loadDemo():void {
			// Manager Demos
//			this.addChild(new HistoryDemo());
//			this.addChild(new RegionsDemo());
//			this.addChild(new ManagerDemo());
//			this.addChild(new SwipeDemo());

			// UI Demos
//			this.addChild(new UISandboxDemo());
//			this.addChild(new UIHandleDemo());
//			this.addChild(new UISlideHandleDemo());
//			this.addChild(new UICrankHandleDemo());
//			this.addChild(new UITargetDemo());
			this.addChild(new UIPushHandleDemo());
//			this.addChild(new UIHotSpotDemo());
//			this.addChild(new UIRepeatHandleDemo());

			// Simulation Demos
//			this.addChild(new SimulatorDemo());
//			this.addChild(new SimulatorHelperDemo());
//			this.addChild(new HistorySimulatorHelperDemo());
//			this.addChild(new HistorySimulatorDemo());
//			this.addChild(new NestedSimulatorHelperDemo());

			// Pointcloud Demo
//			this.addChild(new PointCloudHelperDemo());
		}

		private function loadNextDemo():void {
			this.removeChildren();
			var currentDemo:BaseDemo = new _demos[_currentDemoIndex]();
			this.addChild(currentDemo);

			this.addChild(_demoText);
			_demoText.text = currentDemo.demoName;
		}
	}
}