/**
 *
 * User: Ross
 * Date: 11/26/11
 * Time: 8:32 PM
 */
package com.as3nui.airkinect.extended.demos.ui.display {
	import com.as3nui.airkinect.extended.ui.components.CrankHandle;
import com.as3nui.airkinect.extended.ui.events.UIEvent;

import flash.display.Sprite;

	public class ColoredCrankHandle extends CrankHandle {
		public function ColoredCrankHandle(color:uint = 0x0000ff, radius:uint = 20) {
			var circle:Sprite = new Sprite();
			circle.graphics.beginFill(color);
			circle.graphics.drawCircle(radius, radius, radius);

			var rotator:Sprite = new Sprite();
			rotator.graphics.beginFill(0x000000, .5);
			rotator.graphics.drawCircle(radius*2, radius*2, radius*2);

			super(circle, rotator);
		}
	}
}