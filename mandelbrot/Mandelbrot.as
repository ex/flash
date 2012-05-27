/* ========================================================================== */
/*   Mandelbrot.as                                                            */
/* -------------------------------------------------------------------------- */
/*   Copyright (c) 2012 Laurens Rodriguez Oscanoa.                            */
/*   This code is licensed under the MIT license:                             */
/*   http://www.opensource.org/licenses/mit-license.php                       */
/* -------------------------------------------------------------------------- */

package {

import flash.events.KeyboardEvent;
import flash.display.Sprite;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.geom.Rectangle;
import flash.ui.Keyboard;

public class Mandelbrot extends Sprite {

    public function Mandelbrot() {
        m_canvas = this;

        stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);

        m_width = m_canvas.stage.stageWidth;
        m_height = m_canvas.stage.stageHeight;

        m_bitmapBack = new BitmapData(m_width, m_height, true, 0);
        m_bitmapFront = new BitmapData(m_width, m_height, true, 0);

        // Adding bitmaps to canvas for displaying
        m_canvas.addChild(new Bitmap(m_bitmapBack));
        m_canvas.addChild(new Bitmap(m_bitmapFront));

        m_steps = INIT_STEPS;
        m_zoomIsVisible = false;
        m_zones = new Array();

        // Zoom zone init position
        m_zoomGridX = m_zoomGridY = (FRACTAL_GRID_CELLS - ZOOM_GRID_CELLS) / 2;

        // Initialize color data
        initializeColorData();
        setColors(COLOR_PALETTE);

        // Draw Mandelbrot fractal in default zone
        drawMandelbrot(true);
    }

    private function onKeyDown(evt:KeyboardEvent):void {
        switch(evt.keyCode) {
        case Keyboard.W:
        case Keyboard.UP:
            moveZoomUp();
            break;
        case Keyboard.S:
        case Keyboard.DOWN:
            moveZoomDown();
            break;
        case Keyboard.A:
        case Keyboard.LEFT:
            moveZoomLeft();
            break;
        case Keyboard.D:
        case Keyboard.RIGHT:
            moveZoomRight();
            break;
        case Keyboard.SPACE:
        case Keyboard.ENTER:
            redraw();
            break;
        case Keyboard.F4:
            setColors(COLOR_PALETTE);
            drawMandelbrot();
            break;
        case Keyboard.F5:
            setColors(COLOR_RANDOM);
            drawMandelbrot();
            break;
        case Keyboard.F6:
            setColors(COLOR_RED);
            drawMandelbrot();
            break;
        case Keyboard.F7:
            setColors(COLOR_GREEN);
            drawMandelbrot();
            break;
        case Keyboard.F8:
            setColors(COLOR_BLUE);
            drawMandelbrot();
            break;
        case Keyboard.F9:
            setColors(COLOR_GRAY);
            drawMandelbrot();
            break;
        case Keyboard.BACKSPACE:
            zoomOut();
            break;
        case Keyboard.ESCAPE:
        case Keyboard.CONTROL:
            toggleZoomZone();
            break;
        case Keyboard.HOME:
            drawMandelbrot(true);
            break;
        case Keyboard.PAGE_UP:
            increaseSteps(INCREMENT_STEPS);
            break;
        case Keyboard.PAGE_DOWN:
            increaseSteps(-INCREMENT_STEPS);
            break;
        }
    }

    private function redraw():void {
        if (m_zoomIsVisible) {
            // If the zoom grid is visible we want to redraw the zoom zone.
            var dx:Number = (m_fractalZoneX2 - m_fractalZoneX1) / FRACTAL_GRID_CELLS;
            var dy:Number = (m_fractalZoneY2 - m_fractalZoneY1) / FRACTAL_GRID_CELLS;

            if ((dx >= MINIMUM_CELL_SIZE) && (dy >= MINIMUM_CELL_SIZE)) {

                // Save actual zone position
                m_zones.push([m_fractalZoneX1, m_fractalZoneY1, m_fractalZoneX2, m_fractalZoneY2]);

                // Set new drawing zone. (x1,y1) bottom-left corner, (x2,y2) up-right corner
                m_fractalZoneX1 += (m_zoomGridX * dx);
                m_fractalZoneY1 += (m_zoomGridY * dy);
                m_fractalZoneX2 = m_fractalZoneX1 + ZOOM_GRID_CELLS * dx;
                m_fractalZoneY2 = m_fractalZoneY1 + ZOOM_GRID_CELLS * dy;

                drawMandelbrot();
            }
        }
        else {
            toggleZoomZone();
        }
    }

    private function increaseSteps(increment:int):void {
        if (m_steps + increment > 0) {
            m_steps += increment;
            drawMandelbrot();
        }
    }

    private function zoomOut():void {
        if (m_zoomIsVisible) {
            toggleZoomZone();
        }
        if (m_zones.length > 0) {
            var zone:Array = m_zones.pop() as Array;
            m_fractalZoneX1 = zone[0];
            m_fractalZoneY1 = zone[1];
            m_fractalZoneX2 = zone[2];
            m_fractalZoneY2 = zone[3];
        }
        else {
            var dx:Number = (m_fractalZoneX2 - m_fractalZoneX1)/2;
            var dy:Number = (m_fractalZoneY2 - m_fractalZoneY1)/2;
            m_fractalZoneX1 -= dx;
            m_fractalZoneY1 -= dy;
            m_fractalZoneX2 += dx;
            m_fractalZoneY2 += dy;
        }
        drawMandelbrot();
    }

    private function drawMandelbrot(initializeZone:Boolean = false):void {

        if (m_zoomIsVisible) {
            toggleZoomZone();
        }
        if (initializeZone) {
            m_fractalZoneX1 = -2.5;
            m_fractalZoneY1 = -1.2;
            m_fractalZoneX2 = 0.7;
            m_fractalZoneY2 = 1.2;
        }

        var dx:Number = (m_fractalZoneX2 - m_fractalZoneX1) / (m_width - 1);
        var dy:Number = (m_fractalZoneY2 - m_fractalZoneY1) / (m_height - 1);

        m_bitmapBack.fillRect(new Rectangle(0, 0, m_width, m_height), 0);

        // Draw fractal zone
        for (var x:int = 0; x < m_width; ++x) {
            for (var y:int = 0; y < m_height; ++y) {
                // Point in fractal zone
                var px:Number = m_fractalZoneX1 + x * dx;
                var py:Number = m_fractalZoneY2 - y * dy;

                // Iterate fractal computation.
                var steps:int = 0;
                var fx:Number = 0.0;
                var fy:Number = 0.0;
                var temp:Number;

                while (true) {
                    // Mandelbrot recurrence:
                    // ---------------------
                    // F(n+1) = F(n)*F(n) + (px + i*py)
                    temp = fx*fx - fy*fy + px;
                    fy = 2*fx*fy + py;
                    fx = temp;

                    steps++;

                    // F(z) belongs to Mandelbrot set if |F(z)| < 2
                    // We give up if we passed the limit of number of iterations.
                    if ((steps >= m_steps) || (fx*fx + fy*fy >= 4.0))  {
                        break;
                    }
                }

                if (steps < m_steps) {
                    // We found that: |F(z)| >= 2 (the point doesn't belong to the Mandelbrot set)
                    var indexColor:int = (steps - 1) % 28 + 1;
                    if (indexColor > 15) {
                        indexColor = 30 - indexColor;
                    }
                    var color:uint = (255 << 24) | (m_colors[indexColor][0] << 16)
                                                 | (m_colors[indexColor][1] << 8) | m_colors[indexColor][2];
                    m_bitmapBack.setPixel32(x, y, color);
                }
                else {
                    // We suspect this point belongs to the Mandelbrot set.
                    // We can't be sure because the point can belong to the set if the number
                    // of iteration steps is increased. Leave this pixel in black.
                }
            }
        }
    }

    private function setColors(opc:int):void {
        var k:int;
        m_colors = new Array();

        switch (opc) {
        case COLOR_GRAY:
            for (k = 0; k < 16; k++) {
                m_colors.push([4*m_colorSteps[k][1], 4*m_colorSteps[k][1], 4*m_colorSteps[k][1]]);
            }
            break;

        case COLOR_BLUE:
            for (k = 0; k < 16; k++) {
                m_colors.push([4*m_colorSteps[k][0], 4*m_colorSteps[k][1], 4*m_colorSteps[k][2]]);
            }
            break;

        case COLOR_RED:
            for (k = 0; k < 16; k++) {
                m_colors.push([4*m_colorSteps[k][2], 13 * k, 3*m_colorSteps[k][0]]);
            }
            break;

        case COLOR_GREEN:
            for (k = 0; k < 16; k++) {
                m_colors.push([14 * k, 4*m_colorSteps[k][2], 4*m_colorSteps[k][0]]);
            }
            break;

        case COLOR_RANDOM:
            var c1:int, c2:int, c3:int;
            do {
                c1 = COLOR_STEP * Math.random();
                c2 = COLOR_STEP * Math.random();
                c3 = COLOR_STEP * Math.random();

            } while ((c1 + c2 + c3) < MINIMUM_COLOR_STEP);

            m_colors.push([0, 0, 0]); // base color is black

            var a1:int = COLOR_RANGE * Math.random();
            var a2:int = COLOR_RANGE * Math.random();
            var a3:int = COLOR_RANGE * Math.random();

            // Fill color table.
            for (k = 1; k < 16; ++k) {
                var t1:int = (a1 + (k-1) * c1) % (COLOR_RANGE * 2);
                var t2:int = (a2 + (k-1) * c2) % (COLOR_RANGE * 2);
                var t3:int = (a3 + (k-1) * c3) % (COLOR_RANGE * 2);

                if (t1 >= COLOR_RANGE) {
                    t1 = (COLOR_RANGE * 2) - t1 - 1;
                }
                if (t2 >= COLOR_RANGE) {
                    t2 = (COLOR_RANGE * 2) - t2 - 1;
                }
                if (t3 >= COLOR_RANGE) {
                    t3 = (COLOR_RANGE * 2) - t3 - 1;
                }
                m_colors.push([4*t1, 4*t2, 4*t3]);
            }
            break;

        case COLOR_PALETTE:
            var palette:int = Math.random() * m_palette.length;
            m_colors.push([0, 0, 0]); // base color is black

            // Fill color table.
            for (k = 1; k < 16; ++k) {
                var p1:int = (m_palette[palette][0] + (k-1) * m_palette[palette][1]) % (COLOR_RANGE * 2);
                var p2:int = (m_palette[palette][2] + (k-1) * m_palette[palette][3]) % (COLOR_RANGE * 2);
                var p3:int = (m_palette[palette][4] + (k-1) * m_palette[palette][5]) % (COLOR_RANGE * 2);

                if (p1 >= COLOR_RANGE) {
                    p1 = (COLOR_RANGE * 2) - p1 - 1;
                }
                if (p2 >= COLOR_RANGE) {
                    p2 = (COLOR_RANGE * 2) - p2 - 1;
                }
                if (p3 >= COLOR_RANGE) {
                    p3 = (COLOR_RANGE * 2) - p3 - 1;
                }
                m_colors.push([4*p1, 4*p2, 4*p3]);
            }
            break;
        }
    }

    private function drawLine(ax:int, ay:int, bx:int, by:int, color:uint):void {
        var inc:int;
        if (ax == bx) {
            inc = (ay < by)? 1 : -1;
            for (var y:int = ay; y != by; y += inc) {
                m_bitmapFront.setPixel32(ax, y, color);
            }
        }
        if (ay == by) {
            inc = (ax < bx)? 1 : -1;
            for (var x:int = ax; x != bx; x += inc) {
                m_bitmapFront.setPixel32(x, ay, color);
            }
        }
    }

    private function drawRectangle(x1:int, y1:int, x2:int, y2:int, color:uint):void {
        drawLine(x1, y1, x1, y2, color);
        drawLine(x1, y2, x2, y2, color);
        drawLine(x2, y2, x2, y1, color);
        drawLine(x2, y1, x1, y1, color);
    }

    private function drawZoomZone():void {

        var cellWidth:int = m_width / FRACTAL_GRID_CELLS;
        var cellHeight:int = m_height / FRACTAL_GRID_CELLS;

        var x1:int = cellWidth * (m_zoomGridX) - 1;
        var x2:int = cellWidth * (m_zoomGridX + ZOOM_GRID_CELLS) - 1;

        var y1:int = cellHeight * (FRACTAL_GRID_CELLS - m_zoomGridY) - 1;
        var y2:int = cellHeight * (FRACTAL_GRID_CELLS - m_zoomGridY - ZOOM_GRID_CELLS) - 1;

        if (m_zoomIsVisible) {
            // Erase previous zoom grid.
            drawRectangle(m_zoomX1, m_zoomY2, m_zoomX2, m_zoomY1, 0);
        }
        drawRectangle(x1, y1, x2, y2, 0xFFFFFFFF);

        m_zoomX1 = x1;
        m_zoomY1 = y2;
        m_zoomX2 = x2;
        m_zoomY2 = y1;
    }

    private function toggleZoomZone():void {
        if (! m_zoomIsVisible) {
            drawZoomZone();
            m_zoomIsVisible = true;
        }
        else {
            drawRectangle(m_zoomX1, m_zoomY2, m_zoomX2, m_zoomY1, 0);
            m_zoomIsVisible = false;
        }
    }

    private function moveZoomLeft():void {
        if (! m_zoomIsVisible) {
            toggleZoomZone();
        }
        else {
            if (m_zoomGridX > 0) {
                --m_zoomGridX;
                drawZoomZone();
            }
        }
    }

    private function moveZoomRight():void {
        if (! m_zoomIsVisible) {
            toggleZoomZone();
        }
        else {
            if (m_zoomGridX < FRACTAL_GRID_CELLS - ZOOM_GRID_CELLS) {
                ++m_zoomGridX;
                drawZoomZone();
            }
        }
    }

    private function moveZoomUp():void {
        if (! m_zoomIsVisible) {
            toggleZoomZone();
        }
        else {
            if (m_zoomGridY < FRACTAL_GRID_CELLS - ZOOM_GRID_CELLS) {
                ++m_zoomGridY;
                drawZoomZone();
            }
        }
    }

    private function moveZoomDown():void {
        if (! m_zoomIsVisible) {
            toggleZoomZone();
        }
        else {
            if (m_zoomGridY > 0) {
                --m_zoomGridY;
                drawZoomZone();
            }
        }
    }

    private function initializeColorData():void {
        m_palette = [
            [0, 4, 62, 5, 31, 3],  [7, 4, 4, 4, 42, 5],   [8, 0, 55, 4, 4, 4],   [8, 5, 8, 4, 8, 1],    [12, 4, 44, 2, 46, 3],
            [17, 4, 35, 5, 41, 4], [20, 5, 43, 4, 57, 3], [20, 5, 58, 5, 21, 2], [21, 2, 35, 4, 59, 0], [24, 4, 53, 2, 54, 3],
            [25, 2, 36, 2, 50, 2], [25, 5, 52, 5, 0, 5],  [27, 3, 19, 3, 31, 5], [27, 3, 35, 4, 39, 2], [29, 5, 63, 2, 34, 2],
            [32, 5, 58, 5, 33, 2], [33, 5, 61, 5, 34, 3], [35, 2, 16, 5, 22, 0], [35, 4, 2, 0, 10, 3],  [36, 4, 43, 4, 35, 2],
            [38, 4, 63, 3, 55, 5], [39, 5, 8, 2, 48, 2],  [39, 5, 59, 3, 7, 2],  [40, 3, 6, 0, 61, 5],  [40, 5, 58, 5, 25, 2],
            [41, 2, 49, 5, 52, 3], [41, 5, 59, 5, 0, 3],  [43, 5, 56, 3, 43, 4], [44, 2, 11, 3, 54, 4], [44, 4, 61, 4, 13, 2],
            [45, 3, 61, 3, 10, 1], [45, 4, 63, 5, 6, 3],  [45, 5, 46, 5, 11, 0], [46, 3, 5, 5, 17, 3],  [47, 1, 30, 4, 14, 0],
            [48, 5, 58, 5, 17, 2], [48, 5, 63, 4, 6, 4],  [48, 5, 63, 5, 6, 4],  [49, 3, 17, 4, 38, 2], [50, 2, 63, 5, 57, 3],
            [51, 5, 62, 3, 37, 0], [53, 1, 56, 5, 13, 1], [53, 3, 57, 2, 49, 1], [53, 3, 56, 5, 44, 2], [54, 4, 1, 0, 33, 3],
            [54, 5, 53, 4, 45, 2], [55, 4, 13, 0, 4, 4],  [55, 4, 40, 5, 34, 2], [55, 5, 57, 2, 56, 2], [57, 2, 14, 3, 20, 0],
            [58, 1, 15, 5, 9, 2],  [58, 3, 38, 4, 13, 4], [59, 0, 48, 5, 6, 2],  [59, 3, 3, 0, 6, 3],   [59, 5, 4, 4, 60, 0],
            [59, 5, 52, 3, 5, 0],  [60, 1, 51, 5, 0, 3],  [60, 5, 14, 2, 24, 3], [61, 5, 42, 5, 24, 3], [63, 4, 14, 3, 0, 5],
        ];

        m_colorSteps = [[ 0,  0,  0], [10,  8, 23], [13, 16, 36], [15, 18, 41],
                        [17, 21, 46], [18, 23, 49], [20, 26, 50], [22, 29, 52],
                        [24, 35, 55], [22, 40, 58], [20, 45, 60], [17, 46, 61],
                        [16, 47, 62], [25, 52, 62], [38, 58, 63], [63, 63, 63]];
    }

    private const INIT_STEPS:int = 256;
    private const INCREMENT_STEPS:int = 64;

    private const MINIMUM_COLOR_STEP:int = 5;
    private const COLOR_RANGE:int = 64;
    private const COLOR_STEP:int = 6;

    private const COLOR_BLUE:int   = 1;
    private const COLOR_RED:int    = 2;
    private const COLOR_GREEN:int  = 3;
    private const COLOR_GRAY:int   = 4;
    private const COLOR_RANDOM:int = 5;
    private const COLOR_PALETTE:int = 6;

    private const MINIMUM_CELL_SIZE:Number = 9e-15;

    // The fractal zone and the zoom zone are divided in cells.
    private const FRACTAL_GRID_CELLS:int = 8;
    private const ZOOM_GRID_CELLS:int = 4;

    private var m_width:int;  // canvas width
    private var m_height:int; // canvas height

    private var m_canvas:Sprite;

    private var m_bitmapBack:BitmapData;
    private var m_bitmapFront:BitmapData;

    private var m_colors:Array;	// palette of colors
    private var m_colorSteps:Array;

    // Number of iterations for computing a pixel of the fractal.
    private var m_steps:int;

    // Fractal zone coordinates
    private var m_fractalZoneX1:Number;
    private var m_fractalZoneY1:Number;
    private var m_fractalZoneX2:Number;
    private var m_fractalZoneY2:Number;

    // Zoom zone position on screen
    private var m_zoomX1:int;
    private var m_zoomY1:int;
    private var m_zoomX2:int;
    private var m_zoomY2:int;

    // Zoom grid cell position
    private var m_zoomGridX:int;
    private var m_zoomGridY:int;

    private var m_zoomIsVisible:Boolean;

    // Fractal zones history.
    // Each element is an array with the zone coordinates: [x1, y1, x2, y2]
    private var m_zones:Array;

    // Some nice palette colors
    private var m_palette:Array
}
}
