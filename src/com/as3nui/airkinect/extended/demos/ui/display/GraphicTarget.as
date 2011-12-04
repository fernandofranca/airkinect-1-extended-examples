/**
 *
 * User: Ross
 * Date: 11/26/11
 * Time: 7:11 PM
 */
package com.as3nui.airkinect.extended.demos.ui.display {
	import com.as3nui.airkinect.extended.ui.components.Target;
	import com.as3nui.airkinect.extended.ui.events.CursorEvent;

	import flash.display.Sprite;
	import flash.filters.DropShadowFilter;
	import flash.geom.Point;

	public class GraphicTarget extends Target {

		[Embed('/../assets/embeded/swf/DemoGraphics.swf#AS3NUIIconGraphic')]
		private var IconGraphic:Class;

		private var _logo:Sprite;

		private var _dsf:DropShadowFilter = new DropShadowFilter();


		public function GraphicTarget() {
			super(new IconGraphic as Sprite,   new SimpleSelectionTimer(0x0000ff), null, 4);

			_logo = (_icon as Sprite).getChildByName("logo") as Sprite;
		}


		override protected function onAddedToStage():void {
			super.onAddedToStage();
		}


		override protected function onRemovedFromStage():void {
			super.onRemovedFromStage();
		}


		override protected function onCursorOver(event:CursorEvent):void {
			super.onCursorOver(event);
			_logo.z = -100;
			_logo.filters = [_dsf];
		}

		override protected function onSelected():void {
			super.onSelected();
			resetLogo();
		}

		override protected function onCursorOut(event:CursorEvent):void {
			super.onCursorOut(event);
			resetLogo();
		}

		private function resetLogo():void {
			var location:Point = new Point(_logo.x, _logo.y);
			_logo.transform.matrix3D = null;

			_logo.x = location.x;
			_logo.y = location.y;
			_logo.rotationY = 0;
			_logo.rotationX = 0;
			
			_logo.filters = [];
		}

		override protected function onCursorMove(event:CursorEvent):void {
			super.onCursorMove(event);
			var xRatio:Number = event.localX/this.width;
			xRatio -= .5;
			xRatio *= 2;
			
			var yRatio:Number = event.localY/this.height;
			yRatio -= .5;
			yRatio *= 2;

			_logo.rotationY = -xRatio * 20;
			_logo.rotationX = yRatio * 20;

			_dsf.distance = -xRatio * 20;
			_dsf.blurX = _dsf.blurY = 40;
			_dsf.strength = .4;
			_dsf.angle = 0;
			_logo.filters = [_dsf];
		}
	}
}