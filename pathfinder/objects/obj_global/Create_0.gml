/// @description Initialize global variables
// You can write your code in this editor

global.mode = 0;
global.isTesting = false;
global.isDirty = false;
global.isHeuristicEnabled = false;
global.isPartialQueryEnabled = false;
global.isRedrawingEnabled = true;
global.queuecnt = 0;
global.testcnt = 0;
enum MODE {
	POS,
	EDIT,
	LEN,
}
global.modeStr = ["POS", "EDIT", "LEN"];