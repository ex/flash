/* ========================================================================== */
/*   Main.as                                                                  */
/*   Copyright (c) 2010 Laurens Rodriguez Oscanoa.                            */
/* -------------------------------------------------------------------------- */
/*   This code is licensed under the MIT license:                             */
/*   http://www.opensource.org/licenses/mit-license.php                       */
/* -------------------------------------------------------------------------- */

package {
	
import flash.display.MovieClip;
import flash.events.Event;
	
public class Main extends MovieClip {

    private var mBoard:Board;
	
	public function Main():void {
        // Ensure that we are fully loaded.
		if (stage != null) {
            init();
        } else {
            addEventListener(Event.ADDED_TO_STAGE, init);
        }
	}
	
	private function init(event:Event = null):void {
		removeEventListener(Event.ADDED_TO_STAGE, init);

        // Create our game board.
        var layout:Array = [
            [2, 2, 2, 2, 1],
            [4, 4, 3, 1, 0],
            [4, 4, 3, 1, 0],
            [2, 2, 2, 2, 1]
        ];
        mBoard = new Board(this, layout);
	}
}
}
