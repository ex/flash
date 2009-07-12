/* ========================================================================== */
/*   IMO 1959 Problem 04                                                      */
/*   Construct a right-angled triangle whose hypotenuse c is given            */
/*   if it is known that the median from the right angle equals the           */
/*   geometric mean of the remaining two sides of the triangle.               */
/* -------------------------------------------------------------------------- */
/*   Copyright (c) 2009 Laurens Rodriguez Oscanoa                             */
/*   This code is licensed under the MIT license:                             */
/*   http://www.opensource.org/licenses/mit-license.php                       */
/* -------------------------------------------------------------------------- */

package {

import flash.display.Sprite;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.events.Event;

// Compiled with Flex 3.2.0.
[SWF(backgroundColor="#FFFFFF", frameRate="30", width="480", height="240", frameRate = "60")]

public class imo59_04 extends Sprite {

    private static const OX:int = 240;
    private static const OY:int = 220;
    private static const R:int = 200;
    private static const INC:Number = 0.005;

    private var theta:Number;
    private var a:Number;
    private var b:Number;
    private var px:Number;
    private var py:Number;
    private var error:Number;
    private var tmp:Number;

    public function imo59_04() {
        theta = 0;
        error = getError(); // get initial error

        addEventListener(Event.ENTER_FRAME, update);
    }

    private function update(e:Event):void {
        if (theta < Math.PI) {
            graphics.clear();

            // Increment angle.
            theta += INC;

            // Draw stage.
            Graphics.drawCircle(this, OX, OY, R, 0xFFFFFF, 0xAAAAAA);
            Graphics.drawLine(this, OX - R, OY, OX + R, OY, 0xAAAAAA);

            // Draw posible triangle.
            px = OX + (R * Math.cos(theta));
            py = OY - (R * Math.sin(theta));
            Graphics.drawLine(this, OX - R, OY, px, py, 0xCA25FF, 1);
            Graphics.drawLine(this, px, py, OX + R, OY, 0xCA25FF, 1);

            // Check if we found answer
            tmp = getError();
            if (tmp * error < 0) {
                error = tmp;

                var triangle:Sprite = new Sprite();
                Graphics.drawLine(triangle, OX - R, OY, px, py, 0xFF00000, 1.5);
                Graphics.drawLine(triangle, px, py, OX + R, OY, 0xFF00000, 1.5);
                Graphics.drawLine(triangle, OX - R, OY, OX + R, OY, 0xFF00000, 1.5);

                var format:TextFormat = new TextFormat();
                format.font = "Verdana";
                format.color = 0x0000000;
                format.size = 11;

                var label:TextField = new TextField();
                label.selectable = false;
                label.defaultTextFormat = format;
                tmp = 180 * theta / Math.PI;
                label.text = "Θ: " + tmp.toPrecision(4);
                label.x = OX + (0.7 * R * Math.cos(theta));
                label.y = OY - (0.7 * R * Math.sin(theta));
                triangle.addChild(label);
                addChild(triangle);
            }
        }
    }

    private function getError():Number {
        a = 2 * R * Math.cos(0.5 * theta);
        b = 2 * R * Math.sin(0.5 * theta);
        // We want R == sqrt(a * b)
        return (R * R) - (a * b);   // Return quadratic error,
    }
}
}

import flash.display.Sprite;

class Graphics {

    // Draw a circle over [canvas].
    public static function drawCircle(canvas:Sprite,
                                      x:int,
                                      y:int,
                                      radius:Number,
                                      colorBody:Number,
                                      colorBorder:Number,
                                      borderSize:Number = 0.5):void {
        canvas.graphics.lineStyle(borderSize, colorBorder);
        canvas.graphics.beginFill(colorBody);
        canvas.graphics.drawCircle(x, y, radius);
        canvas.graphics.endFill();
    }

    // Draw a line over [canvas].
    public static function drawLine(canvas:Sprite,
                                    iniX:int, iniY:int,
                                    endX:int, endY:int,
                                    colorBorder:Number,
                                    borderSize:Number = 0.5):void {
        canvas.graphics.lineStyle(borderSize, colorBorder);
        canvas.graphics.beginFill(colorBorder);
        canvas.graphics.moveTo(iniX, iniY);
        canvas.graphics.lineTo(endX, endY);
        canvas.graphics.endFill();
    }
}

