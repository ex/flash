/* ========================================================================== */
/*   Piece.as                                                                 */
/*   Copyright (c) 2010 Laurens Rodriguez Oscanoa.                            */
/* -------------------------------------------------------------------------- */
/*   This code is licensed under the MIT license:                             */
/*   http://www.opensource.org/licenses/mit-license.php                       */
/* -------------------------------------------------------------------------- */

package {
	
import flash.display.Sprite;
import flash.display.MovieClip;
import flash.filters.DropShadowFilter;
	
public class Piece {

    public static const SIZE:int = 70;

    // Piece ids.
    public static const ID_EMPTY:int = 0;
    public static const ID_TARGET:int = 4;
    public static const ID_STATIC:int = 5;
    public static const ID_EXIT:int = 9;

    private static const COLOR_1:uint = 0xEE2111;
    private static const COLOR_2:uint = 0x3344EE;
    private static const COLOR_3:uint = 0xDDDD11;
    private static const COLOR_TARGET:uint = 0x22EE22;
    private static const COLOR_STATIC:uint = 0xCACAB0;
    private static const COLORS:Array = [COLOR_1, COLOR_2, COLOR_3, COLOR_TARGET, COLOR_STATIC];

    private static const BORDER_COLOR:uint = 0x2A2A2A;
    private static const CORNER_SIZE:int = 18;
    private static const BORDER_SIZE:int = 3;

    public var column:int;
    public var row:int;

    public function id():int { return mId; }
    public function width():int { return mWidth; }
    public function height():int { return mHeight; }

    private var mClip:Sprite;
    private var mShadow:Sprite;
    private var mId:int;
    private var mWidth:int;
    private var mHeight:int;
	
	public function Piece(canvas:Sprite, shadowCanvas:Sprite,
                          id:int, initColumn:int, initRow:int):void {
        // Create our piece clip.
        mId = id;
        column = initColumn;
        row = initRow;

        switch (mId) {
        case 1:
        case ID_STATIC:
            mHeight = mWidth = 1;
            break;
        case 2:
            mWidth = 2;
            mHeight = 1;
            break;
        case 3:
            mWidth = 1;
            mHeight = 2;
            break;
        case ID_TARGET:
            mHeight = mWidth = 2;
            break;
        case ID_EXIT:
            // This piece doesn't have a visible image.
            return;
        default:
            throw new Error("[Piece]: Invalid id");
        }

        // Create piece body and shadow.
        mShadow = Graphics.getRoundedRect(mWidth * SIZE, mHeight * SIZE,
                                          CORNER_SIZE, CORNER_SIZE, 0xFFFFFF,
                                          BORDER_COLOR, BORDER_SIZE);
        mShadow.filters = new Array(new DropShadowFilter(0, 0, 0x000000, 1, 8, 8));
        shadowCanvas.addChild(mShadow);

        mClip = Graphics.getRoundedRect(mWidth * SIZE, mHeight * SIZE,
                                        CORNER_SIZE, CORNER_SIZE, COLORS[mId - 1],
                                        BORDER_COLOR, BORDER_SIZE);
        if (mId == 4) {
            Graphics.drawCircle(mClip, SIZE, SIZE, 0.5 * SIZE, 0, 0xFFFF00, 0, 3, 0.5);
            Graphics.drawCircle(mClip, SIZE, SIZE, 0.3 * SIZE, 0, 0xFFFF00, 0, 3, 0.5);
            Graphics.drawCircle(mClip, SIZE, SIZE, 0.1 * SIZE, 0, 0xFFFF00, 0, 3, 0.5);

        }
        canvas.addChild(mClip);
    }

    public function setX(val:int):void {
        if (mId != ID_EXIT) {
            mShadow.x = mClip.x = val;
        }
    }
    public function setY(val:int):void {
        if (mId != ID_EXIT) {
            mShadow.y = mClip.y = val;
        }
    }
    public function select(val:Boolean):void {
        if (mId != ID_STATIC && mId != ID_EXIT) {
            mClip.alpha = val? 0.75 : 1;
        }
    }

    public function free():void {
        mClip.parent.removeChild(mClip);
        mClip = null;
        mShadow.parent.removeChild(mShadow);
        mShadow = null;
    }
}
}
