/*
 * Copyright (c) 2012 AS3NUI
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation the
 * rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is furnished to
 * do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all copies
 * or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
 * INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
 * PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
 * FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
 * OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 */

package com.as3nui.airkinect.extended.demos.ui.display {
	import com.as3nui.airkinect.extended.ui.components.CrankHandle;

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