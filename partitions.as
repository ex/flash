/* ========================================================================== */
/*   Integer-partition demo:                                                  */
/*   http://en.wikipedia.org/wiki/Integer_partition                           */
/* -------------------------------------------------------------------------- */
/*   Copyright (c) 2009 Laurens Rodriguez Oscanoa                             */
/*   This code is licensed under the MIT license:                             */
/*   http://www.opensource.org/licenses/mit-license.php                       */
/* -------------------------------------------------------------------------- */

package {

import flash.display.Sprite;
import flash.text.TextField;
import flash.text.TextFormat;

// Compiled with Flex 3.2.0.
[SWF(backgroundColor="#FFFFFF", frameRate="30", width="640", height="280")]

public class partitions extends Sprite {

    private const N:int = 8;
    private var count:int = 0;

    public function partitions() {
        // Draw all the integer partitions of [N]
        listPartitions(N, new Array());
    }

    private function listPartitions(sum:int, list:Array):void {
        // Get minimum value we can add to the list, because the list is sorted
        // in ascending order this value would be the last array element.
        // In case the array is empty [min] would be 1.
        var min:int = (list.length > 0)? list[list.length - 1] : 1;

        for (var k:int = min; k <= sum; ++k) {
            // Create an array that is a copy of array [list]
            var mz:Array = list.concat();

            // Add [k] as last element to array copy.
            mz.push(k);

            // If we reached the target goal: (sum - k) == 0, draw the [list],
            // in other case continue recursion.
            if (sum - k == 0) {
                addChild(Graphics.node(25 + (28 * count), 20, 12, String(count + 1),
                         0xFFFFFF, 0xCCBB00, 0x887700));
                addChild(Graphics.strip(25 + (28 * count), 50, 28, 11, mz,
                         Graphics.warmColor(), 0x998800));
                ++count;
            }
            else {
                listPartitions(sum - k, mz);
            }
        }
    }
}
}

import flash.display.Sprite;
import flash.text.TextField;
import flash.text.TextFormat;

class Graphics {

    // Return a "warm" color.
    public static function warmColor():Number {
        var b:int = 192 + (16 * Math.random());
        var r:int = 240 + (16 * Math.random());
        var g:int = 224 + (16 * Math.random());
        return (r << 16 | g << 8 | b);
    }

    // Return a "strip", that is a list of nodes joined by a line.
    public static function strip(x:int,
                                 y:int,
                                 offset:int,
                                 radius:Number,
                                 list:Array,
                                 colorBody:Number,
                                 colorBorder:Number,
                                 vertical:Boolean = true,
                                 colorText:Number = 0,
                                 borderSize:Number = 0.5,
                                 font:String = "Verdana"):Sprite {

        var strip:Sprite = new Sprite();

        strip.graphics.lineStyle(3 * borderSize, colorBorder);
        strip.graphics.beginFill(colorBody);
        strip.graphics.moveTo(x, y);
        if (vertical) {
            strip.graphics.lineTo(x, y + (offset * (list.length - 1)));
        }
        else {
            strip.graphics.lineTo(x + (offset * (list.length - 1)), y);
        }
        strip.graphics.endFill();

        var node:Sprite;
        for (var k:int = 0; k < list.length; ++k) {
            if (vertical) {
                node = Graphics.node(x, y + (offset * k), radius,
                                     list[k], colorBody, colorBorder,
                                     colorText, borderSize, font);
            }
            else {
                node = Graphics.node(x + (offset * k), y, radius,
                                     list[k], colorBody, colorBorder,
                                     colorText, borderSize, font);
            }
            strip.addChild(node);
        }
        return strip;
    }

    // Return a "node", that is a circle with a label.
    public static function node(x:int,
                                y:int,
                                radius:Number,
                                caption:String,
                                colorBody:Number,
                                colorBorder:Number,
                                colorText:Number = 0,
                                borderSize:Number = 0.5,
                                font:String = "Verdana"):Sprite {
        var format:TextFormat = new TextFormat();
        format.font = font;
        format.color = colorText;
        format.size = 12;
        format.bold = true;

        var label:TextField = new TextField();
        label.selectable = false;
        label.defaultTextFormat = format;
        label.text = caption;
        label.x = -2*label.textWidth/3;     // need to fix this ad-hoc solution
        label.y = -2*label.textHeight/3;    // for centering text.

        var node:Sprite = new Sprite();
        node.graphics.lineStyle(borderSize, colorBorder);
        node.graphics.beginFill(colorBody);
        node.graphics.drawCircle(0, 0, radius);
        node.graphics.endFill();
        node.addChild(label);
        node.x = x;
        node.y = y;
        return node;
    }
}
