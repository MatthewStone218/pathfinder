/// @description Insert description here
// You can write your code in this editor

var _dirx = [0, 1, 0, -1, 0];
var _diry = [0, 0, -1, 0, 1];

var _modification = mouse_check_button(mb_left) - mouse_check_button(mb_right);

if(_modification != 0) {
	for(var i=0; i<5; i++) {
		var _yi = floor((mouse_y - surf_y)/surf_scale) + _diry[i],
			_xi = floor((mouse_x - surf_x)/surf_scale) + _dirx[i];
		if(isSafe(_xi, _yi)) {
			switch(global.mode) {
				case MODE.POS:
					if(_modification == 1) {
						startx = _xi;
						starty = _yi;
					} else {
						endx = _xi;
						endy = _yi;
					}
					shouldPathRedraw = true;
					break;
				case MODE.EDIT:
					costs[_yi*cnum + _xi] = max(costs[_yi*cnum + _xi] + _modification * 0.3, 0);
					shouldCostRedraw = true;
					global.isDirty = true;
					break;
			}
		}
	}
}

if(global.isTesting) {
	global.testcnt++;
	startx = irandom(cnum-1);
	starty = irandom(rnum-1);
	endx = irandom(cnum-1);
	endy = irandom(rnum-1);
	shouldPathRedraw = true;
	pathfind();
}

if(global.isRedrawingEnabled) {
	if(shouldCostRedraw) redraw_costsurf();
	if(shouldPathRedraw) redraw_pathsurf();
	shouldCostRedraw = false;
	shouldPathRedraw = false;
}