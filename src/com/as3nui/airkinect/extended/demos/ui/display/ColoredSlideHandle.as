/**
 *
 * User: Ross
 * Date: 11/19/11
 * Time: 8:15 PM
 */
package com.as3nui.airkinect.extended.demos.ui.display {
	import com.as3nui.airkinect.extended.ui.components.SlideHandle;

	import flash.display.Shape;

	public class ColoredSlideHandle extends SlideHandle {
		protected var _color:uint;
		protected var _radius:uint;

		public function ColoredSlideHandle(color:uint, radius:uint = 20, direction:String = SlideHandle.LEFT) {
			_color = color;
			_radius = radius;

			var circle:Shape = new Shape();
			circle.graphics.beginFill(_color);
			circle.graphics.drawCircle(_radius,_radius,_radius);

			var selectedCircle:Shape = new Shape();
			selectedCircle.graphics.beginFill(0x0000ff);
			selectedCircle.graphics.drawCircle(_radius,_radius,_radius);

			var disabledIcon:Shape = new Shape();
			disabledIcon.graphics.beginFill(0xeeeeee);
			disabledIcon.graphics.drawCircle(_radius,_radius,_radius);

			var track:Shape = new Shape();
			track.graphics.beginFill(0x0000ff, .5);

			switch(direction){
				case SlideHandle.RIGHT:
					track.graphics.drawRect(0,0, 300, _radius*2);
					break;
				case SlideHandle.LEFT:
					track.graphics.drawRect(0, 0, -300, _radius*2);
					break;
				case SlideHandle.UP:
					track.graphics.drawRect(0,0, _radius*2, -300);
					break;
				case SlideHandle.DOWN:
					track.graphics.drawRect(0,0, _radius*2, 300);
					break;

			}
			super(circle, track, null, disabledIcon, direction);
		}
	}
}