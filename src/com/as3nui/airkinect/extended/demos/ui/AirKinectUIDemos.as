/**
 *
 * User: rgerbasi
 * Date: 10/16/11
 * Time: 5:51 PM
 */
package com.as3nui.airkinect.extended.demos.ui {
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.geom.Point;

	public class AirKinectUIDemos extends Sprite {

		public function AirKinectUIDemos() {
			this.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage)
		}

		private function onAddedToStage(event:Event):void {
			initDemo();
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;

			stage.addEventListener(Event.RESIZE, onStageResize);
		}

		private function onStageResize(event:Event):void {
			root.transform.perspectiveProjection.projectionCenter = new Point(stage.stageWidth / 2, stage.stageHeight / 2);
		}
		
		private function initDemo():void {

		}
	}
}