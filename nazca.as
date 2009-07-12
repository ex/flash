/* ========================================================================== */
/*   NAZCA - III                                                              */
/*   (Just a bit of fun based on: Springer - Chaos and Fractals)              */
/*   Original: http://exe-q-tor.deviantart.com/art/nazca-II-65104644          */
/* -------------------------------------------------------------------------- */
/*   Copyright (c) 2009 Laurens Rodriguez Oscanoa                             */
/*   This code is licensed under the MIT license:                             */
/*   http://www.opensource.org/licenses/mit-license.php                       */
/* -------------------------------------------------------------------------- */

package {

import flash.events.Event;
import flash.display.Sprite;
import flash.display.MovieClip;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.utils.clearInterval;
import flash.utils.setInterval;
import flash.utils.getTimer;
import flash.geom.Rectangle;
import flash.system.System;

// Compiled with Flex 3.2.0.
[SWF(backgroundColor="#FFFFFF", frameRate="30", width="401", height="401", frameRate = "30")]

public class nazca extends MovieClip {

    private static const AUTHOR:String = "Laurens Rodriguez Oscanoa";

    //--------------------------------------------------------------------------
    // For you to play :)
    private static const COLORS:Array = [
            0xFF0054CE, 0xFF0054CE, 0xFF0074F2, 0xFF007FF2, 0xFF00416B,
            0xFF005D83, 0xFF006698, 0xFF0080B1, 0xFF0087CD, 0xFF00A9D5,
            0xFF00B2FC, 0xFF00ECFF, 0xFF00BFF2, 0xFF00A2FF, 0xFF00A2E7,
            0xFF00A2C4, 0xFF00A2A4];

    private static const PRIMES:Array = [
            11,13,17,19,23,29,31,37,41,43,47,53,59,61,67,71,73,79,83,97,101,103,107,109,
            113,128,131,137,139,149,151,157,163,167,169,173,179,181,191,193,197,211];

    private static const TIME_SHOW:int = 750;
    private static const TIME_FADE:int = 100;
    private static const ALPHA_DEC:Number = 0.02;
    //--------------------------------------------------------------------------

    private static const ST_DRAW:int = 0;
    private static const ST_DELETE_CENTER:int = 1;
    private static const ST_SHOW:int = 2;
    private static const ST_FADE:int = 3;

    private var mState:int = ST_DRAW;

    private var mW:int = 0;
    private var mH:int = 0;
    private var mS:int = 0;
    private var mN:int = 0;
    private var mNC:int = 0;
    private var mZ:Array = null;

    private var mCanvas:MovieClip = null;

    private var mGpx1:Sprite = null;
    private var mGpx2:Sprite = null;
    private var mGpx3:Sprite = null;
    private var mGpx4:Sprite = null;

    private var mBmpData:BitmapData = null;
    private var mBmpDataLine:BitmapData = null;
    private var mBmpDataBack:BitmapData = null;

    private var mRow:int = 0;	// File to draw
    private var mColor:int = 0;	// Random index color

    private var mTimer:int;

    private var mFpsTime:int = 0;
    private var mFps:Number = 0;

    public function nazca() {
        // Clip setup
        stage.quality = "LOW";
        stage.addEventListener("enterFrame", update);
        drawPascal(3);
    }

    public function drawPascal(cellSize:int):void {
        mCanvas = this;
        mW = stage.stageWidth/2;
        mH = stage.stageHeight/2;
        mS = cellSize;
        mNC = mH/mS; // number of cells

        mGpx1 = new Sprite();
        mGpx1.rotation = 180;
        mGpx1.x = mW + 1;
        mGpx1.y = mH + 1;

        mGpx2 = new Sprite();
        mGpx2.rotation = -90;
        mGpx2.x = mW;
        mGpx2.y = mH + 1;

        mGpx3 = new Sprite();
        mGpx3.rotation = 90;
        mGpx3.x = mW + 1;
        mGpx3.y = mH;

        mGpx4 = new Sprite();
        mGpx4.x = mW;
        mGpx4.y = mH;

        mBmpData = new BitmapData(mW, mH, true, 0);
        mBmpDataLine = new BitmapData(mW, mH, true, 0);
        mBmpDataBack = new BitmapData(mW, mH, true, 0);

        for (var k:int = 1; k <= 4; k++) {
            // The depths are automatically set accordingly to the order of calls
            this["mGpx"+k].addChild(new Bitmap(mBmpDataBack));
            this["mGpx"+k].addChild(new Bitmap(mBmpData));
            this["mGpx"+k].addChild(new Bitmap(mBmpDataLine));
            // Adding sprite to canvas for displaying
            mCanvas.addChild(this["mGpx"+k]);
        }

        // Calculate next
        mN = getNextOrder();
        makeTriangle();
    }

    private function binaryFind(value:int, array:Array):int {
        var a:int = 0;
        var b:int = array.length - 1;
        var c:int;
        while (a <= b) {
            c = a + Math.floor((b - a)/2);
            if (array[c] == value) {
                return c;
            }
            else {
                if (array[c] > value) {
                    b = c - 1;
                } else {
                    a = c + 1;
                }
            }
        }
        return -1;
    }

    private function getNextOrder():int {
        var num:int = 2 + Math.floor(Math.random()*mNC);
        while ((num > 2) && ((num == mN) || (binaryFind(num, PRIMES) >= 0))) {
            num--;
        }
        return num;
    }

    private function makeTriangle():void {
        if (mZ != null) {
            mZ = null;
        }
        mZ = new Array();
        mZ[0] = new Array();
        mZ[0].push(1);
        for (var p:int = 1; p < mNC; p++) {
            mZ[p] = new Array();
            mZ[p].push(1);
            for (var q:int = 0; q < mZ[p-1].length - 1; q++) {
                mZ[p].push((mZ[p-1][q] + mZ[p-1][q+1]) % mN);
            }
            mZ[p].push(1);
        }
        for (p = mNC; p < 2*mNC - 1; p++) {
            mZ[p] = new Array();
            for (q = 0; q < mZ[p-1].length - 1; q++) {
                mZ[p].push((mZ[p-1][q] + mZ[p-1][q+1]) % mN);
            }
        }
    }

    private function drawWhiteSquare(x:int, y:int, size:int):void {
        mBmpDataLine.fillRect(new Rectangle(x, y, size, size), 0xFF9AC5FF);
    }

    private function drawBox(x:int, y:int, size:int, colorIndex:int, offsetColor:int):void {
        mBmpData.fillRect(new Rectangle(x, y, size+1, size+1), 0xDD6999FF);
        mBmpData.fillRect(new Rectangle(x+1, y+1, size-1, size-1),
                COLORS[(colorIndex + offsetColor) % COLORS.length])
    }

    public function onFade():void {
        clearInterval(mTimer);
        mState = ST_FADE;
        mTimer = setInterval(onRedraw, TIME_FADE);
    }

    public function onRedraw():void {
        clearInterval(mTimer);
        mN = getNextOrder();
        makeTriangle();
        mRow = 0;
        mColor = Math.floor(Math.random()*mZ.length);
        mState = ST_DRAW;
    }

    public function update(evt:Event):void {
        switch(mState) {
        case ST_DRAW:
            if(mRow >= mZ.length) {
                // Delete back bmp
                mBmpDataBack.dispose();
                mBmpDataBack = null;

                // Make back bitmap the last drawed canvas
                mGpx1.getChildAt(0).alpha = 1;
                mGpx2.getChildAt(0).alpha = 1;
                mGpx3.getChildAt(0).alpha = 1;
                mGpx4.getChildAt(0).alpha = 1;
                Bitmap(mGpx1.getChildAt(0)).bitmapData = mBmpData;
                Bitmap(mGpx2.getChildAt(0)).bitmapData = mBmpData;
                Bitmap(mGpx3.getChildAt(0)).bitmapData = mBmpData;
                Bitmap(mGpx4.getChildAt(0)).bitmapData = mBmpData;
                mBmpDataBack = mBmpData;

                // Create new bitmapData for draw
                mBmpData = new BitmapData(mW, mH, true, 0);
                Bitmap(mGpx1.getChildAt(1)).bitmapData = mBmpData;
                Bitmap(mGpx2.getChildAt(1)).bitmapData = mBmpData;
                Bitmap(mGpx3.getChildAt(1)).bitmapData = mBmpData;
                Bitmap(mGpx4.getChildAt(1)).bitmapData = mBmpData;

                mTimer = setInterval(onFade, TIME_SHOW);
                mState = ST_DELETE_CENTER;
            }
            else {
                redrawBmps();
                mRow++;
                if((mRow % 2) && (mGpx1.alpha > 0)) {
                    mGpx1.getChildAt(0).alpha -= ALPHA_DEC;
                    mGpx2.getChildAt(0).alpha -= ALPHA_DEC;
                    mGpx3.getChildAt(0).alpha -= ALPHA_DEC;
                    mGpx4.getChildAt(0).alpha -= ALPHA_DEC;
                }
            }
            break;

        case ST_DELETE_CENTER:
            mBmpDataLine.fillRect(mBmpDataLine.rect, 0);
            mState = ST_SHOW;
            break;

        case ST_FADE:
            mGpx1.getChildAt(0).alpha -= ALPHA_DEC;
            mGpx2.getChildAt(0).alpha -= ALPHA_DEC;
            mGpx3.getChildAt(0).alpha -= ALPHA_DEC;
            mGpx4.getChildAt(0).alpha -= ALPHA_DEC;
            break;
        }
    }

    public function redrawBmps():void {
        var p:int = mRow;
        mBmpDataLine.fillRect(mBmpDataLine.rect, 0);
        if (p < mNC) {
            for (var q:int = 0; q < mZ[p].length; q++) {
                if (mZ[p][q]) {
                    drawWhiteSquare(q*mS, (mZ[p].length-q-1)*mS, mS);
                    drawBox(q*mS, (mZ[p].length-q-1)*mS, mS, mZ[p][q], mColor);
                }
            }
        }
        else {
            for (q = 0; q < mZ[p].length; q++) {
                if (mZ[p][q]) {
                    drawWhiteSquare((p + q - mNC + 1)*mS, (mNC - q - 1)*mS, mS);
                    drawBox((p + q - mNC + 1)*mS, (mNC - q - 1)*mS, mS, mZ[p][q], mColor);
                }
            }
        }
    }
}
}
