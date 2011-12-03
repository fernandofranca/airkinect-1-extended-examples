/**
 *
 * User: Ross
 * Date: 11/19/11
 * Time: 7:39 PM
 */
package com.as3nui.airkinect.extended.demos.ui.display {
	import com.as3nui.airkinect.extended.ui.display.BaseSelectionTimer;

	public class SimpleSelectionTimer extends BaseSelectionTimer {
		private var _size:Number = 25;
		private var _color:uint;
		public function SimpleSelectionTimer(color:uint = 0xff0000) {
			_color = color;
			draw();
		}

		private function draw():void {
			this.graphics.clear();

			this.graphics.lineStyle(1);
			this.graphics.beginFill(0xffffff, .4);
			this.graphics.drawRect(0,0,_size, _size);

			this.graphics.lineStyle(0);
			this.graphics.beginFill(_color, 1);
			this.graphics.drawRect(0,_size, _size, -(_progress * _size));
		}

		override public function onProgress(progress:Number):void {
			super.onProgress(progress);
			draw();
		}
	}
}