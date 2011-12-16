/**
 *
 * User: rgerbasi
 * Date: 10/16/11
 * Time: 5:51 PM
 */
package com.as3nui.airkinect.extended.demos.simulator {
	import com.as3nui.airkinect.extended.demos.core.BaseDemo;
	import com.as3nui.airkinect.extended.demos.manager.SwipeDemo;
	import com.as3nui.airkinect.extended.simulator.helpers.SkeletonSimulatorHelper;

	import flash.events.Event;

	public class NestedSimulatorHelperDemo extends BaseDemo {
		public function NestedSimulatorHelperDemo() {
			_demoName = "Nested Manager Demo with SimulatorHelper";
		}

		override protected function onAddedToStage(event:Event):void {
			super.onAddedToStage(event);
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

		override protected function onRemovedFromStage(event:Event):void {
			super.onRemovedFromStage(event);

			SkeletonSimulatorHelper.uninit();
			this.removeChildren();
		}
	}
}