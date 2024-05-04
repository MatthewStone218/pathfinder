/// @description Insert description here
// You can write your code in this editor

var _ofx = 1000;

if(uiBtn(_ofx, 100, 160, 60, global.modeStr[global.mode])) {
	global.mode = (global.mode + 1) mod MODE.LEN;
}


if(uiBtn(_ofx, 200, 160, 60, "Cache", global.isDirty)) {
	obj_pathfinder.updateCostmap();
}

if(uiToggle(_ofx, 280, 120, 30, "Heuristic", global.isHeuristicEnabled)) {
	global.isHeuristicEnabled = !global.isHeuristicEnabled;
	obj_pathfinder.shouldPathRedraw = true;
}
obj_pathfinder.astar.setCoeff(
	uiSlider(_ofx, 325, 120, 10, "Coeff", obj_pathfinder.astar.heuristicCoeff, 0, 3)
);

if(uiToggle(_ofx, 350, 120, 30, "Partial Query", global.isPartialQueryEnabled)) {
	global.isPartialQueryEnabled = !global.isPartialQueryEnabled;
	obj_pathfinder.shouldPathRedraw = true;
}
if(uiToggle(_ofx, 400, 120, 30, "Redrawing", global.isRedrawingEnabled)) {
	global.isRedrawingEnabled = !global.isRedrawingEnabled;
}

if(uiBtn(_ofx, 450, 160, 60, "FIND")) {
	obj_pathfinder.pathfind();
}

if(uiToggle(_ofx, 530, 120, 30, "TEST", global.isTesting)) {
	if(!global.isTesting) {
		global.queuecnt = 0;
		global.testcnt = 0;
	}
	global.isTesting = !global.isTesting;
}


draw_text(_ofx, 600, "Avg. Q operation : " + string(global.queuecnt/global.testcnt));