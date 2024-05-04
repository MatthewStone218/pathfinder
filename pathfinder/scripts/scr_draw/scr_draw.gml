// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function draw_box(_x, _y, _w, _h){
	draw_sprite_ext(spr_pixel, 0, _x, _y, _w, _h, 0, draw_get_color(), draw_get_alpha());
}

