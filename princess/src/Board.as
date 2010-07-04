/* ========================================================================== */
/*   Board.as                                                                 */
/*   Class used to draw and solve sliding puzzles of the type found at:       */
/*   http://professorlaytonwalkthrough.blogspot.com/2008/02/puzzle097.html    */
/*   Copyright (c) 2010 Laurens Rodriguez Oscanoa.                            */
/* -------------------------------------------------------------------------- */
/*   This code is licensed under the MIT license:                             */
/*   http://www.opensource.org/licenses/mit-license.php                       */
/* -------------------------------------------------------------------------- */

package {
	
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.filters.DropShadowFilter;
import flash.geom.Point;
import flash.utils.getTimer;
	
public class Board {

    private static const BORDER_SIZE:int = 4;
    private static const CORNER_SIZE:int = 12;
    private static const BACK_COLOR:uint = 0xF0F0F0;
    private static const BACK_BORDER_COLOR:uint = 0xCACACA;

    private var mWidth:int;
    private var mHeight:int;
    private var mTimer:Number;
    private var mSelectedPiece:Piece;
    private var mTiles:Array;

    private var mBackground:Sprite;
    private var mCanvas:MovieClip;
    private var mBorder:Sprite;

	public function Board(parentCanvas:MovieClip, board:Array):void {
        // Set board size in cells.
        mHeight = board.length;
        mWidth = board[0].length;

        // Create and center board background.
        var width:int = Piece.SIZE * mWidth + 2 * BORDER_SIZE;
        var height:int = Piece.SIZE * mHeight + 2 * BORDER_SIZE;
        mBackground = Graphics.getRoundedRect(width, height, CORNER_SIZE, CORNER_SIZE,
                                              BACK_COLOR, BACK_BORDER_COLOR, BORDER_SIZE);
        mBackground.x = (parentCanvas.stage.stageWidth - width) / 2;
        mBackground.y = (parentCanvas.stage.stageHeight - height) / 2;
        mBackground.filters = new Array(new DropShadowFilter(0, 0, 0x000000, 1, 12, 12));
        parentCanvas.addChild(mBackground);

        // Create canvas to draw pieces.
        mCanvas = new MovieClip();
        mCanvas.x = mBackground.x + BORDER_SIZE;
        mCanvas.y = mBackground.y + BORDER_SIZE;
        parentCanvas.addChild(mCanvas);

        // Create border.
        mBorder = Graphics.getRoundedRect(width, height, CORNER_SIZE, CORNER_SIZE,
                                          0, BACK_BORDER_COLOR, BORDER_SIZE, 0);
        mBorder.x = mBackground.x;
        mBorder.y = mBackground.y;
        parentCanvas.addChild(mBorder);

        // Create board buffer and mTiles.
        mTiles = new Array(mWidth * mHeight);
        createPieces(board);

        // Register events for mouse click detection.
        parentCanvas.stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown, false, 0, true);
        parentCanvas.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp, false, 0, true);
        parentCanvas.stage.addEventListener(Event.ENTER_FRAME, onEnterFrame, false, 0, true);

        mTimer = getTimer();
        mSelectedPiece = null;
    }

    private function createPieces(board:Array):void {
        for (var y:int = 0; y < mHeight; ++y) {
            for (var x:int = 0; x < mWidth; ++x) {
                if (!mTiles[x + y * mWidth] && board[y][x]) {
                    var piece:Piece = new Piece(mCanvas, board[y][x], x, y);
                    addPieceToBoard(piece);
                }
            }
        }
    }

    private function addPieceToBoard(piece:Piece):void {
        for (var x:int = 0; x < piece.width(); ++x) {
            for (var y:int = 0; y < piece.height(); ++y) {
                mTiles[piece.column() + x + (piece.row() + y) * mWidth] = piece;
            }
        }
        piece.setX(piece.column() * Piece.SIZE);
        piece.setY(piece.row() * Piece.SIZE);
    }

    private function getCellUnderMouse(mouseX:int, mouseY:int):Point {
        var x:int = (mouseX - mCanvas.x) / Piece.SIZE;
        var y:int = (mouseY - mCanvas.y) / Piece.SIZE;
        if (x >= 0 && x < mWidth && y >= 0 && y < mHeight) {
            return new Point(x, y);
        }
        return null;
    }

    private function onMouseDown(event:MouseEvent):void {
        var point:Point = getCellUnderMouse(event.stageX, event.stageY);
        if (point) {
            if (mSelectedPiece) {
                mSelectedPiece.select(false);
            }
            mSelectedPiece = mTiles[point.x + mWidth * point.y];
            if (mSelectedPiece) {
                mSelectedPiece.select(true);
            }
        }
    }

    private function onMouseUp(event:MouseEvent):void {
        if (mSelectedPiece) {
            var point:Point = getCellUnderMouse(event.stageX, event.stageY);
            if (point) {
                // Cell must be empty.
                if (!mTiles[point.x + point.y * mWidth]) {
                    mSelectedPiece.moveTo(point.x, point.y);
                }
            }
        }
    }
    private function update(dt:int):void {
        trace(dt);
    }

    private function onEnterFrame(event:Event):void {
        var timer:Number = getTimer();
        //update(timer - mTimer);
        mTimer = timer;
    }

    public function free():void {
        mSelectedPiece = null;

        mCanvas.stage.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
        mCanvas.stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
        mCanvas.stage.removeEventListener(Event.ENTER_FRAME, onEnterFrame);

        mBackground.parent.removeChild(mBackground);
        mBackground = null;
        mCanvas.parent.removeChild(mCanvas);
        mCanvas = null;
        mBorder.parent.removeChild(mBorder);
        mBorder = null;
    }
}
}
