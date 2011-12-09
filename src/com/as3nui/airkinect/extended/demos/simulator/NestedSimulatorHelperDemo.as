/**
 *
 * User: rgerbasi
 * Date: 10/16/11
 * Time: 5:51 PM
 */
package com.as3nui.airkinect.extended.demos.simulator {
	import com.as3nui.airkinect.extended.demos.manager.HistoryDemo;
	import com.as3nui.airkinect.extended.demos.manager.ManagerDemo;
	import com.as3nui.airkinect.extended.demos.manager.RegionsDemo;
	import com.as3nui.airkinect.extended.demos.manager.SwipeDemo;
	import com.as3nui.airkinect.extended.simulator.helpers.SkeletonSimulatorHelper;

	import flash.display.Sprite;
	import flash.events.Event;

	public class NestedSimulatorHelperDemo extends Sprite {
		public function NestedSimulatorHelperDemo() {
			this.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage)
		}

		private function onAddedToStage(event:Event):void {
			initDemo();
		}

		private function initDemo():void {
			//Add any Demo that uses the AIRKinect Manager
//			this.addChild(new HistoryDemo());
//			this.addChild(new ManagerDemo());
//			this.addChild(new RegionsDemo());
			this.addChild(new SwipeDemo());


			SkeletonSimulatorHelper.init(stage);
		}
	}
}