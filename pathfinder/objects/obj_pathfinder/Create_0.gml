/// @description Insert description here
// You can write your code in this editor

cnum = 200;
rnum = 121;
costs = array_create(rnum*cnum, 1);

landmarks = initLandmarkArr(cnum, rnum, 12);
astar = new AStarIM(cnum, rnum, costs, landmarks);

startx = 0;
starty = 0;
endx = 0;
endy = 0;

costsurf = surface_create(cnum, rnum);
pathsurf = surface_create(cnum, rnum);
surf_x = 60;
surf_y = 60;
surf_scale = min((1000-120)/cnum, (room_height-120)/rnum);
shouldCostRedraw = true;
shouldPathRedraw = true;

function isSafe(_x, _y) {
	return (0<=_x && _x<cnum && 0<=y && _y<rnum);
}
function cost2color(val) {
	return merge_color(c_black, merge_color(c_white, c_red, 1 - 1/(val+1)), 1 - 1/(val+1));
}
function redraw_costsurf() {
	// Existence check and some initialization
	if(!surface_exists(costsurf)) costsurf = surface_create(cnum, rnum);
	
	surface_set_target(costsurf);
	draw_clear_alpha(c_white, 0);
	
	// Draw the cost map
	for(var i=0; i<rnum; i++)
	for(var j=0; j<cnum; j++) {
		var _cost = costs[i*cnum + j];
		draw_set_color(cost2color(_cost));
		draw_box(j, i, 1, 1);
	}
	surface_reset_target();
}
function redraw_pathsurf() {
	// Existence check and some initialization
	if(!surface_exists(pathsurf)) pathsurf = surface_create(cnum, rnum);
	
	var _size = surface_get_width(pathsurf);
	
	surface_set_target(pathsurf);
	draw_clear_alpha(c_white, 0);
	
	// Draw the cost map, visited flag
	draw_set_color(c_orange);
	draw_set_alpha(0.4);
	for(var i=0; i<rnum; i++)
	for(var j=0; j<cnum; j++) {
		if(astar.VISITED[i*cnum + j])
			draw_box(j, i, 1, 1);
	}
	
	// Draw the trace
	draw_set_color(c_white);
	draw_set_alpha(1);
	var _x = endx, _y = endy;
	var cnt = 0;
	while(_x!=startx || _y!=starty) {
		if(!isSafe(_x, _y) || cnt++ >= rnum*cnum) break;
		draw_box(_x, _y, 1, 1);
		var _dir = astar.DIRFIELD[_y*cnum + _x];
		_x += astar.DIRX[_dir];
		_y += astar.DIRY[_dir];
	}
	
	// Draw Start/Endpoint
	draw_set_color(c_green);
	draw_box(startx, starty, 1, 1);
	draw_set_color(c_blue);
	draw_box(endx, endy, 1, 1);
	
	// Draw Landmarks
	draw_set_color((global.isPartialQueryEnabled || !global.isHeuristicEnabled) ? c_black : c_yellow);
	for(var i=0; i<astar.landmarkSize; i++) {
		draw_box(astar.landmarks[i].x, astar.landmarks[i].y, 1, 1);
	}
	
	// Draw activated Landmarks
	if(global.isPartialQueryEnabled) {
		var _activatedArr = astar.auxfuncNaive(startx, starty, endx, endy);
		draw_set_color(c_yellow);
		for(var i=0; i<array_length(_activatedArr); i++) {
			draw_box(astar.landmarks[_activatedArr[i]].x, astar.landmarks[_activatedArr[i]].y, 1, 1);
		}
	}

	
	draw_set_color(c_white);
	draw_set_alpha(1)
	surface_reset_target();
}
function updateCostmap() {
	astar.updateCost(costs);
	global.isDirty = false;
}
function pathfind() {
	var _succ = astar.pathfind(startx, starty, endx, endy,
		global.isHeuristicEnabled ? astar.hfunc : function(){return 0;},
		global.isPartialQueryEnabled ? astar.auxfuncNaive : function(){return undefined;});
	shouldPathRedraw = true;
	return _succ;
}