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

    private static const COLOR_1:uint = 0xCC1111;
    private static const COLOR_2:uint = 0x3333CC;
    private static const COLOR_3:uint = 0xAAAA11;
    private static const COLOR_4:uint = 0x22DD22;
    private static const COLORS:Array = [COLOR_1, COLOR_2, COLOR_3, COLOR_4];

    private static const BORDER_COLOR:uint = 0x2A2A2A;
    private static const CORNER_SIZE:int = 18;
    private static const BORDER_SIZE:int = 3;

    public function id():int { return mId; }
    public function width():int { return mWidth; }
    public function height():int { return mHeight; }
    public function column():int { return mColumn; }
    public function row():int { return mRow; }

    public function setX(val:int):void { mClip.x = val; }
    public function setY(val:int):void { mClip.y = val; }
    public function select(val:Boolean):void { mClip.alpha = val? 0.75 : 1; }

    private var mClip:Sprite;
    private var mId:int;
    private var mRow:int;
    private var mColumn:int;
    private var mWidth:int;
    private var mHeight:int;
	
	public function Piece(canvas:MovieClip, id:int, column:int, row:int):void {
        // Create our piece clip.
        mClip = new Sprite();
        mId = id;
        mColumn = column;
        mRow = row;

        switch (mId) {
        case 1:
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
        case 4:
            mHeight = mWidth = 2;
            break;
        default:
            throw new Error("[Piece]: Invalid id");
        }
        mClip = Graphics.getRoundedRect(mWidth * SIZE, mHeight * SIZE,
                                        CORNER_SIZE, CORNER_SIZE, COLORS[mId - 1],
                                        BORDER_COLOR, BORDER_SIZE);


        if (mId == 4) {
            Graphics.drawCircle(mClip, SIZE, SIZE, 0.6 * SIZE, 0, 0xFFFF00, 0, 4, 0.3);
            Graphics.drawCircle(mClip, SIZE, SIZE, 0.4 * SIZE, 0, 0xFFFF00, 0, 4, 0.3);
            Graphics.drawCircle(mClip, SIZE, SIZE, 0.2 * SIZE, 0, 0xFFFF00, 0, 4, 0.3);

        }
        mClip.filters = new Array(new DropShadowFilter(0, 0, 0x000000, 1, 8, 8));
        canvas.addChild(mClip);
    }

    public function moveTo(x:int, y:int):void {
    }

    public function free():void {
        mClip.parent.removeChild(mClip);
        mClip = null;
    }
}
}
