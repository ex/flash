/* ========================================================================== */
/*   Board.as                                                                 */
/*   Class used to draw and solve sliding puzzles of the type found at:       */
/*   http://en.wikipedia.org/wiki/Klotski                                     */
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
import flash.events.KeyboardEvent;
import flash.filters.DropShadowFilter;
import flash.geom.Point;
import flash.ui.Keyboard;
import flash.utils.getTimer;

public class Board {

    private static const BORDER_SIZE:int = 4;
    private static const CORNER_SIZE:int = 12;
    private static const BACK_COLOR:uint = 0xF0F0C0;
    private static const BACK_BORDER_COLOR:uint = 0xCACAB0;

    private var mWidth:int;
    private var mHeight:int;
    private var mTimer:Number;
    private var mSelectedPiece:Piece;
    private var mTiles:Array;

    private var mBackground:Sprite;
    private var mShadowCanvas:Sprite;
    private var mCanvas:Sprite;
    private var mBorder:Sprite;
    private var mOldMouseX:int;
    private var mOldMouseY:int;
    private var mIsDragging:Boolean;
    private var mInitialLayout:Array;
    private var mBoardCanvas:MovieClip;

	public function Board(parentCanvas:MovieClip, initialBoardLayout:Array):void {
        mInitialLayout = initialBoardLayout;
        mBoardCanvas = parentCanvas;
        // Set board size in cells.
        mHeight =mInitialLayout.length;
        mWidth = mInitialLayout[0].length;

        // Create and center board background.
        var width:int = Piece.SIZE * mWidth + 2 * BORDER_SIZE;
        var height:int = Piece.SIZE * mHeight + 2 * BORDER_SIZE;
        mBackground = Graphics.getRoundedRect(width, height, CORNER_SIZE, CORNER_SIZE,
                                              BACK_COLOR, BACK_BORDER_COLOR, BORDER_SIZE);
        mBackground.x = (mBoardCanvas.stage.stageWidth - width) / 2;
        mBackground.y = (mBoardCanvas.stage.stageHeight - height) / 2;
        mBackground.filters = new Array(new DropShadowFilter(0, 0, 0x000000, 1, 14, 14));
        mBoardCanvas.addChild(mBackground);

        // Create canvas to draw pieces.
        mCanvas = new Sprite();
        mShadowCanvas = new Sprite();
        mShadowCanvas.x = mCanvas.x = mBackground.x + BORDER_SIZE;
        mShadowCanvas.y = mCanvas.y = mBackground.y + BORDER_SIZE;
        mBoardCanvas.addChild(mShadowCanvas);
        mBoardCanvas.addChild(mCanvas);

        // Create border.
        mBorder = Graphics.getRoundedRect(width, height, CORNER_SIZE, CORNER_SIZE,
                                          0, BACK_BORDER_COLOR, BORDER_SIZE, 0);
        mBorder.x = mBackground.x;
        mBorder.y = mBackground.y;
        mBoardCanvas.addChild(mBorder);

        // Create board buffer and mTiles.
        mTiles = new Array(mWidth * mHeight);
        createPieces(mInitialLayout);

        // Register events for mouse click detection.
        mBoardCanvas.stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown, false, 0, true);
        mBoardCanvas.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp, false, 0, true);
        mBoardCanvas.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown, false, 0, true);
        mBoardCanvas.stage.addEventListener(Event.ENTER_FRAME, onEnterFrame, false, 0, true);

        mTimer = getTimer();
        mSelectedPiece = null;
        mIsDragging = false;
    }

    private function createPieces(board:Array):void {
        for (var y:int = 0; y < mHeight; ++y) {
            for (var x:int = 0; x < mWidth; ++x) {
                if (mTiles[x + y * mWidth] == null && board[y][x] != Piece.ID_EMPTY) {
                    var piece:Piece = new Piece(mCanvas, mShadowCanvas, board[y][x], x, y);
                    addPieceToBoard(piece);
                }
            }
        }
    }

    private function removePieceFromBoard(piece:Piece):void {
        for (var x:int = 0; x < piece.width(); ++x) {
            for (var y:int = 0; y < piece.height(); ++y) {
                mTiles[piece.column + x + (piece.row + y) * mWidth] = null;
            }
        }
    }

    private function addPieceToBoard(piece:Piece):void {
        for (var x:int = 0; x < piece.width(); ++x) {
            for (var y:int = 0; y < piece.height(); ++y) {
                mTiles[piece.column + x + (piece.row + y) * mWidth] = piece;
            }
        }
        piece.setX(piece.column * Piece.SIZE);
        piece.setY(piece.row * Piece.SIZE);
    }

    private function getCellUnderMouse(mouseX:int, mouseY:int):Point {
        if (mouseX > mCanvas.x && mouseY > mCanvas.y) {
            var x:int = (mouseX - mCanvas.x) / Piece.SIZE;
            var y:int = (mouseY - mCanvas.y) / Piece.SIZE;
            if (x >= 0 && x < mWidth && y >= 0 && y < mHeight) {
                return new Point(x, y);
            }
        }
        return null;
    }

    private function canPieceGoUp(piece:Piece):Boolean {
        if (piece.row > 0) {
            for (var k:int = 0; k < piece.width(); ++k) {
                if (mTiles[piece.column + k + (piece.row - 1) * mWidth] != null) {
                    return false;
                }
            }
            return true;
        }
        return false;
    }

    private function canPieceGoDown(piece:Piece):Boolean {
        if (piece.row + piece.height() < mHeight) {
            for (var k:int = 0; k < piece.width(); ++k) {
                if (mTiles[piece.column + k + (piece.row + piece.height()) * mWidth] != null) {
                    return false;
                }
            }
            return true;
        }
        return false;
    }

    private function canPieceGoLeft(piece:Piece):Boolean {
        if (piece.column > 0) {
            for (var k:int = 0; k < piece.height(); ++k) {
                if (mTiles[piece.column - 1 + (piece.row + k) * mWidth] != null) {
                    return false;
                }
            }
            return true;
        }
        return false;
    }

    private function canPieceGoRight(piece:Piece):Boolean {
        if (piece.column + piece.width() < mWidth) {
            for (var k:int = 0; k < piece.height(); ++k) {
                if (mTiles[piece.column + piece.width() + (piece.row + k) * mWidth] != null) {
                    return false;
                }
            }
            return true;
        }
        return false;
    }

    private function onMouseDown(event:MouseEvent):void {
        var point:Point = getCellUnderMouse(event.stageX, event.stageY);
        if (point != null) {
            if (mSelectedPiece != null) {
                mSelectedPiece.select(false);
            }
            mSelectedPiece = mTiles[point.x + mWidth * point.y];
            if (mSelectedPiece != null) {
                mSelectedPiece.select(true);
                mOldMouseX = event.stageX;
                mOldMouseY = event.stageY;
                mIsDragging = true;
            }
        }
    }

    private function onMouseUp(event:MouseEvent):void {
        mIsDragging = false;
    }

    private function moveSelectedPieceLeft():void {
        if (canPieceGoLeft(mSelectedPiece)) {
            removePieceFromBoard(mSelectedPiece);
            --mSelectedPiece.column;
            addPieceToBoard(mSelectedPiece);
        }
    }

    private function moveSelectedPieceRight():void {
        if (canPieceGoRight(mSelectedPiece)) {
            removePieceFromBoard(mSelectedPiece);
            ++mSelectedPiece.column;
            addPieceToBoard(mSelectedPiece);
        }
    }

    private function moveSelectedPieceDown():void {
        if (canPieceGoDown(mSelectedPiece)) {
            removePieceFromBoard(mSelectedPiece);
            ++mSelectedPiece.row;
            addPieceToBoard(mSelectedPiece);
        }
    }

    private function moveSelectedPieceUp():void {
        if (canPieceGoUp(mSelectedPiece)) {
            removePieceFromBoard(mSelectedPiece);
            --mSelectedPiece.row;
            addPieceToBoard(mSelectedPiece);
        }
    }

    private function onKeyDown(event:KeyboardEvent):void {
        if (mSelectedPiece != null) {
            switch (event.keyCode) {
            case Keyboard.DOWN:
                moveSelectedPieceDown();
                break;
            case Keyboard.UP:
                moveSelectedPieceUp();
                break;
            case Keyboard.LEFT:
                moveSelectedPieceLeft();
                break;
            case Keyboard.RIGHT:
                moveSelectedPieceRight();
                break;
            }
        }
    }

    private function update(dt:int):void {
        if (mIsDragging && mSelectedPiece != null) {
            var dx:int = mCanvas.stage.mouseX - mOldMouseX;
            var dy:int = mCanvas.stage.mouseY - mOldMouseY;
            var adx:int = (dx < 0)? -dx : dx;
            var ady:int = (dy < 0)? -dy : dy;
            // Select the direction to move.
            if (adx > ady) {
                if (adx > Piece.SIZE / 2) {
                    if (dx > 0) {
                        moveSelectedPieceRight();
                    }
                    else {
                        moveSelectedPieceLeft();
                    }
                    mOldMouseX = mCanvas.stage.mouseX;
                    mOldMouseY = mCanvas.stage.mouseY;
                }
            }
            else {
                if (ady > Piece.SIZE / 2) {
                    if (dy > 0) {
                        moveSelectedPieceDown();
                    }
                    else {
                        moveSelectedPieceUp();
                    }
                    mOldMouseX = mCanvas.stage.mouseX;
                    mOldMouseY = mCanvas.stage.mouseY;
                }
            }
        }
    }

    private function onEnterFrame(event:Event):void {
        var timer:Number = getTimer();
        update(timer - mTimer);
        mTimer = timer;
    }

    public function free():void {
        mBoardCanvas.stage.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
        mBoardCanvas.stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
        mBoardCanvas.stage.removeEventListener(Event.ENTER_FRAME, onEnterFrame);

        mSelectedPiece = null;
        mBoardCanvas.removeChild(mBackground);
        mBackground = null;
        mBoardCanvas.removeChild(mShadowCanvas);
        mShadowCanvas = null;
        mBoardCanvas.removeChild(mCanvas);
        mCanvas = null;
        mBoardCanvas.removeChild(mBorder);
        mBorder = null;
        mBoardCanvas = null;
    }
}
}
