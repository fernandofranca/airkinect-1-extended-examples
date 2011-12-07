/**
 *
 * User: Ross
 * Date: 12/3/11
 * Time: 1:17 PM
 */
package com.as3nui.airkinect.extended.demos {
	import com.as3nui.airkinect.extended.demos.recorder.HistoryRecordedDemo;
	import com.as3nui.airkinect.extended.demos.manager.ManagerDemo;
	import com.as3nui.airkinect.extended.demos.manager.RegionsDemo;
	import com.as3nui.airkinect.extended.demos.manager.SwipeDemo;
	import com.as3nui.airkinect.extended.demos.recorder.RecorderDemo;
	import com.as3nui.airkinect.extended.demos.ui.UICrankHandleDemo;
	import com.as3nui.airkinect.extended.demos.ui.UIHandleDemo;
	import com.as3nui.airkinect.extended.demos.ui.UIHotSpotDemo;
	import com.as3nui.airkinect.extended.demos.ui.UIRepeatHandleDemo;
	import com.as3nui.airkinect.extended.demos.ui.UISandboxDemo;
	import com.as3nui.airkinect.extended.demos.ui.UISlideHandleDemo;
	import com.as3nui.airkinect.extended.demos.ui.UITargetDemo;

	import flash.display.Sprite;
	import flash.events.Event;

	[SWF(width='1024', height='768', backgroundColor='#ffffff', frameRate='30')]
	public class AIRKinectExtendedDemos extends Sprite {

		public function AIRKinectExtendedDemos() {
			this.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage)
		}

		private function onAddedToStage(event:Event):void {
			loadDemo()
		}

		private function loadDemo():void {
			//Manager Demos
//			this.addChild(new HistoryDemo());
//			this.addChild(new RegionsDemo());
//			this.addChild(new ManagerDemo());
//			this.addChild(new SwipeDemo());

			//UI Demos
//			this.addChild(new UISandboxDemo());
//			this.addChild(new UIHandleDemo());
//			this.addChild(new UISlideHandleDemo());
//			this.addChild(new UICrankHandleDemo());
//			this.addChild(new UITargetDemo());
//			this.addChild(new UIHotSpotDemo());
//			this.addChild(new UIRepeatHandleDemo());


			this.addChild(new RecorderDemo());
//			this.addChild(new HistoryRecordedDemo());


		}
	}
}