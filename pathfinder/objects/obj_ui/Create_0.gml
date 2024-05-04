/// @description Insert description here
// You can write your code in this editor

show_debug_overlay(1);

drawStateStk = ds_stack_create();
function drawState(_pc, _ph, _pv) constructor {
    pc = _pc;
	ph = _ph;
	pv = _pv;
}
function getCurrentState() {
	return new drawState(draw_get_color(), draw_get_halign(), draw_get_valign());
}
function pushCurrentState() {
	ds_stack_push(drawStateStk, getCurrentState());
}
function popCurrentState() {
	var _state = ds_stack_pop(drawStateStk);
	draw_set_color(_state.pc);
	draw_set_halign(_state.ph);
	draw_set_valign(_state.pv);
}

function uiBtn(_x, _y, _w, _h, _str, _enabled = true) {
	var _hover = (point_in_rectangle(mouse_x, mouse_y, _x, _y, _x+_w, _y+_h));
	var _pressing = (mouse_check_button(mb_left) && _hover) || !_enabled;
	var _clicked = (mouse_check_button_released(mb_left) && _hover) && _enabled;
	
	pushCurrentState();
	draw_set_color(_pressing ? #202530 : #3f494f);
	var _dy = _pressing ? 5 : 0;
	draw_box(_x, _y + _dy, _w, _h);
	draw_set_color(#efe8c4);
	draw_set_halign(1);
	draw_set_valign(1);
	draw_text(_x + _w/2, _y + _h/2 + _dy, _str);
	popCurrentState();
	
	return _clicked;
}

function uiToggle(_x, _y, _w, _h, _str, _flag) {
	var _hover = (point_in_rectangle(mouse_x, mouse_y, _x, _y, _x+_w, _y+_h));
	var _pressing = (mouse_check_button(mb_left) && _hover);
	var _clicked = (mouse_check_button_released(mb_left) && _hover);
	
	pushCurrentState();
	if(_w >= _h) {
		draw_set_color(#3f494f);
		var _r = _h/2 - 1;
		draw_circle(_x + _r, _y + _r, _r, false);
		draw_circle(_x + _w - _r, _y + _r, _r, false);
		draw_box(_x + _r, _y, _w - 2*_r, _h);
		draw_set_color(_flag ? #33aa66 : #202530);
		draw_circle(_flag ? (_x + _w - _r) : (_x + _r), _y + _r, _r*0.8, false);
		draw_set_color(#efe8c4);
	} else {
		draw_set_color(#3f494f);
		var _r = _w/2 - 1;
		draw_circle(_x + _r, _y + _r, _r, false);
		draw_circle(_x + _r, _y + _h - _r, _r, false);
		draw_box(_x, _y + _r, _w, _h - 2*_r);
		draw_set_color(_flag ? #33aa66 : #202530);
		draw_circle(_x + _r, _flag ? (_y + _h - _r) : (_y + _r), _r*0.8, false);
		draw_set_color(#efe8c4);
	}
	draw_set_halign(0);
	draw_set_valign(1);
	draw_text(_x + _w + 20, _y + _h/2, _str);
	popCurrentState();
	
	return _clicked;
}

function uiSlider(_x, _y, _w, _h, _str, _value, _min, _max) {
	var _bx = _x + _w*(_value - _min)/(_max - _min);
	var _bw = 10;
	var _hover = (point_in_rectangle(mouse_x, mouse_y, _x, _y, _x+_w, _y+_h));
	var _pressing = (mouse_check_button(mb_left) && _hover);
	var _clicked = (mouse_check_button_released(mb_left) && _hover);
	
	pushCurrentState();
	draw_set_color(#3f494f);
	draw_box(_x, _y + _h/2 - 2, _w, 4);
	draw_set_color(_pressing ? #202530 : #3f494f);
	draw_box(_bx - _bw/2, _y, _bw, _h);
	draw_set_color(#efe8c4);
	draw_set_halign(0);
	draw_set_valign(1);
	draw_text(_x + _w + 20, _y + _h/2, _str);
	draw_set_halign(1);
	draw_set_valign(0);
	draw_text(_x, _y + _h + 2, _min);
	draw_text(_x + _w, _y + _h + 2, _max);
	popCurrentState();
	
	return _pressing ? lerp(_min, _max, clamp((mouse_x - _x)/_w, 0, 1)) : _value;
}