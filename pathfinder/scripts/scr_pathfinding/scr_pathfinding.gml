// Some macros
#macro SHIFT 16						// Bitwise extracting X coordinate from pos
#macro MASK 65535					// Bitwise extracting Y coordinate from pos
#macro INF 987654321				// A very large number

function ASSERT(cond, msg) {
	if(!cond) show_error(msg, false);
}

function AStar(cols, rows, costArr) constructor {
	// Check the validity of the input
	ASSERT(0<cols<201, "col number too small or too big");
	ASSERT(0<rows<201, "col number too small or too big");
	ASSERT(is_array(costArr), "cost array is not actually an array");
	ASSERT(cols*rows == array_length(costArr), "cols*rows does not match with array size");
	
	// Initialize the variables
	COLS = cols;
	ROWS = rows;
	DIRX = [1, 0, -1, 0];
	DIRY = [0, -1, 0, 1];

	OPENQUEUE=ds_priority_create();	// A priority queue of candidate tiles to be analyzed by the algorithm
	COSTARR = costArr;
	DISTARR = array_create(rows*cols, INF);	 // The distance array
	VISITED = array_create(rows*cols, 0);	 // visited flag
	DIRFIELD = array_create(rows*cols, 0);	 // back trail
	
	static updateCost = function(costArr) {
		ASSERT(is_array(costArr), "cost array is not actually an array");
		ASSERT(ROWS*COLS == array_length(costArr), "array size does not match with previous one");
		COSTARR = costArr;
	}
	static reset = function() {
		ds_priority_clear(OPENQUEUE);
		for(var i=0; i<ROWS*COLS; i++) {
			DISTARR[i] = INF;
			VISITED[i] = 0;
			DIRFIELD[i] = 0;
		}
	}
	static destroy = function() {
		ds_priority_destroy(OPENQUEUE);
    }

	static auxfunc = function(startx, starty, goalx, goaly) {
		return undefined;
	}
	static hfunc = function(startx, starty, goalx, goaly) {
		return 0;
	}
	static pathfind = function(startx, starty, goalx, goaly, _hfunc = hfunc, _auxfunc = auxfunc) {
	
		var startp = startx<<SHIFT | starty,
			endp   = goalx <<SHIFT | goaly;
	
		if(startp==endp) return true;
	
		reset();

		// calculate auxiliary information for heuristic function
		var _aux = _auxfunc(startx, starty, goalx, goaly);
	
		// Add the starting point to the queue
		var price=0;
		DISTARR[starty*COLS + startx] = price;
		ds_priority_add(OPENQUEUE,startp,price);
   
		/* main loop */
		var cnt = 0;
		while(!ds_priority_empty(OPENQUEUE)) {
			cnt++;
			var curp = ds_priority_delete_min(OPENQUEUE);
			
			if(curp != endp) {  // not found the solution yet

				var curx = curp>>SHIFT,
					cury = curp &MASK;
				
				// if the current pos is already visited
				if(VISITED[cury*COLS + curx]) continue;
				VISITED[cury*COLS + curx] = true;
		
				// for each neighbor of 'current pos'
				for (var n=0;n<4;n++) {

					var nextx = curx + DIRX[n],
						nexty = cury + DIRY[n];
					var nextp = nextx<<SHIFT | nexty;
				
					// if the neighbor is out of the map or is already visited
					if(nextx<0 || nextx>=COLS || nexty<0 || nexty>=ROWS || (VISITED[nexty*COLS + nextx])) continue;
			
					price=DISTARR[cury*COLS + curx]+COSTARR[nexty*COLS + nextx];
			
					if(price < DISTARR[nexty*COLS + nextx]) {
						var heuristic = _hfunc(nextx, nexty, goalx, goaly, _aux);
						var priority = price+heuristic*1.3;
				
						ds_priority_add(OPENQUEUE,nextp,priority);
						DISTARR[nexty*COLS + nextx] = price;
						DIRFIELD[nexty*COLS + nextx] = ((n+2)%4);
					}
				}
			} else {  // found the solution
				global.queuecnt += cnt;
				return true;
			}
		}
		return false;
	}
}

function AStarIM(cols, rows, costArr, landmarkArr) : AStar(cols, rows, costArr) constructor {
	ASSERT(is_array(landmarkArr), "landmark array is not actually an array");
	landmarks = landmarkArr;
	landmarkSize = array_length(landmarks);
	for(var i=0; i<landmarkSize; i++) {
		ASSERT(is_struct(landmarks[i]), "landmark array contains non-struct elements");
		ASSERT(is_array(landmarks[i].DISTARR), "some landmark does not have a distance array");
		ASSERT(ROWS*COLS == array_length(landmarks[i].DISTARR), "some landmark's distance array size does not match with ROWS*COLS");
		landmarks[i].update(self);
	}

	heuristicCoeff = 1.3;
	
	static setCoeff = function(coeff) {
		heuristicCoeff = coeff;
	}
	static auxfuncNaive = function(startx, starty, goalx, goaly) {
		// calculate intersection of direction vector and rectangle boundary
		var _dx = goalx - startx,
			_dy = goaly - starty;
		
		var _x1 = 0,
			_y1 = 0,
			_x2 = COLS,
			_y2 = ROWS;
		
		var _t1 = (_x1 - startx)/_dx,
			_t2 = (_x2 - startx)/_dx,
			_t3 = (_y1 - starty)/_dy,
			_t4 = (_y2 - starty)/_dy;
		
		// calculate the intersection points. Find t such that 0<=t but smallest
		var _t = INF;
		if(_t1>=0 && _t1<_t) _t = _t1;
		if(_t2>=0 && _t2<_t) _t = _t2;
		if(_t3>=0 && _t3<_t) _t = _t3;
		if(_t4>=0 && _t4<_t) _t = _t4;

		// calculate the intersection point
		var _ix = startx + _dx*_t,
			_iy = starty + _dy*_t;
		
		// find the closest landmark
		var _idx = -1;
		var _minDist = INF;
		for(var i=0; i<landmarkSize; i++) {
			var _lm = landmarks[i];
			var _dist = (_lm.x - _ix)*(_lm.x - _ix) + (_lm.y - _iy)*(_lm.y - _iy);
			if(_dist < _minDist) {
				_minDist = _dist;
				_idx = i;
			}
		}
		return [_idx];
	}
	static hfunc = function(startx, starty, goalx, goaly, idxArr) {
		var _tmp = 0;
		if(idxArr == undefined) {
			for(var i=0; i<landmarkSize; i++) {
				var _lm = landmarks[i];
				_tmp = max(_tmp, _lm.DISTARR[starty*COLS + startx] - _lm.DISTARR[goaly*COLS + goalx]);
			}
		} else {
			for(var i=0; i<array_length(idxArr); i++) {
				var _lm = landmarks[idxArr[i]];
				_tmp = max(_tmp, _lm.DISTARR[starty*COLS + startx] - _lm.DISTARR[goaly*COLS + goalx]);
			}
		}
		return _tmp;
	}
	static updateCost = function(costArr) {
		ASSERT(is_array(costArr), "cost array is not actually an array");
		ASSERT(ROWS*COLS == array_length(costArr), "array size does not match with previous one");
		COSTARR = costArr;
		for(var i=0; i<landmarkSize; i++) {
			landmarks[i].update(self);
		}
	}
	static updateLandmark = function(idx) {
		ASSERT(idx>=0 && idx<landmarkSize, "landmark index out of range");
		landmarks[idx].update(self);
	}
}

function Landmark(_x, _y, cols, rows) constructor {
	x = _x;
	y = _y;
	COLS = cols;
	ROWS = rows;
	DISTARR = array_create(rows*cols, INF);
	
	static update = function(astar) {
		astar.pathfind(x, y, -1, -1, function(){return 0;}, function(){return 0;});
		for(var i=0; i<ROWS; i++) {
			for(var j=0; j<COLS; j++) {
				DISTARR[i*COLS + j] = astar.DISTARR[i*COLS + j] - astar.COSTARR[i*COLS + j] + astar.COSTARR[y*COLS + x];
			}
		}
	}
}

function initLandmarkArr(cols, rows, desiredNum) {
	var _horNum = floor(desiredNum*(cols-1)/((cols+rows-2)*2)),
		_verNum = floor(desiredNum*(rows-1)/((cols+rows-2)*2));
	
	_horNum = max(min(_horNum, (cols-1)/3), 1);
	_verNum = max(min(_verNum, (rows-1)/3), 1);

	var _num = 2*(_horNum + _verNum),
		_horStep = floor((cols-1)/_horNum),
		_verStep = floor((rows-1)/_verNum);
	
	var _arr = array_create(_num, noone);
	for(var i=0; i<_horNum; i++) {
		_arr[i] = new Landmark(i*_horStep, 0, cols, rows);
		_arr[i+_horNum] = new Landmark(cols - 1 - i*_horStep, rows - 1, cols, rows);
	}
	for(var i=0; i<_verNum; i++) {
		_arr[i+2*_horNum] = new Landmark(cols - 1, i*_verStep, cols, rows);
		_arr[i+2*_horNum+_verNum] = new Landmark(0, rows - 1 - i*_verStep, cols, rows);
	}
	return _arr;
}