/**
 *
 * User: Ross
 * Date: 11/19/11
 * Time: 8:15 PM
 */
package com.as3nui.airkinect.extended.demos.ui.display {
import com.as3nui.airkinect.extended.ui.components.SelectableHandle;

import flash.display.Sprite;

public class ColoredHandle extends SelectableHandle {
		protected var _color:uint;
		protected var _radius:uint;

		public function ColoredHandle(color:uint, radius:uint = 20) {
			_color = color;
			_radius = radius;

			var circle:Sprite = new Sprite();
			circle.graphics.beginFill(_color);
			circle.graphics.drawCircle(_radius, _radius, _radius);
			
			var simpleSelectionTimer:SimpleSelectionTimer = new SimpleSelectionTimer();
			super(circle, simpleSelectionTimer);
		}
	}
}