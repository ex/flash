/* ========================================================================== */
/*   Graphics.as                                                              */
/*   Some common functions to draw shapes.                                    */
/*   Copyright (c) 2010 Laurens Rodriguez Oscanoa.                            */
/* -------------------------------------------------------------------------- */
/*   This code is licensed under the MIT license:                             */
/*   http://www.opensource.org/licenses/mit-license.php                       */
/* -------------------------------------------------------------------------- */

package {
	
import flash.display.Sprite;
	
public class Graphics {
	
	// Return a rectangle sprite.
    public static function getRect(width:int,
                                   height:int,
                                   bodyColor:uint = 0xFFFFFF,
                                   borderColor:uint = 0,
                                   borderSize:Number = 0.5):Sprite {

        var rect:Sprite = new Sprite();
        rect.graphics.lineStyle(borderSize, borderColor);
        rect.graphics.beginFill(bodyColor);
        rect.graphics.drawRect(0, 0, width, height);
        rect.graphics.endFill();
        return rect;
	}

	// Return a rounded rectangle sprite.
    public static function getRoundedRect(width:int,
                                          height:int,
                                          roundWidth:int,
                                          roundHeight:int,
                                          bodyColor:uint = 0xFFFFFF,
                                          borderColor:uint = 0,
                                          borderSize:Number = 0.5,
                                          alpha:Number = 1):Sprite {

        var rect:Sprite = new Sprite();
        rect.graphics.lineStyle(borderSize, borderColor);
        rect.graphics.beginFill(bodyColor, alpha);
        rect.graphics.drawRoundRect(0, 0, width, height, roundWidth, roundHeight);
        rect.graphics.endFill();
        return rect;
	}

	// Draw a circle over canvas sprite.
    public static function drawCircle(canvas:Sprite,
                                      x:int,
                                      y:int,
                                      radius:Number,
                                      colorBody:Number,
                                      colorBorder:Number = 0,
                                      alpha:Number = 1,
                                      borderSize:Number = 0.5,
                                      borderAlpha:Number = 1):void {

        canvas.graphics.lineStyle(borderSize, colorBorder, borderAlpha);
        canvas.graphics.beginFill(colorBody, alpha);
        canvas.graphics.drawCircle(x, y, radius);
        canvas.graphics.endFill();
    }
}
}
