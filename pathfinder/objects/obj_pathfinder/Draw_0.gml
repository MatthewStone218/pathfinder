/// @description Insert description here
// You can write your code in this editor
if(!surface_exists(costsurf)) costsurf = surface_create(cnum, rnum);
if(!surface_exists(costsurf)) costsurf = surface_create(cnum, rnum);

draw_surface_ext(costsurf, surf_x, surf_y, surf_scale, surf_scale, 0, c_white, 1);
draw_surface_ext(pathsurf, surf_x, surf_y, surf_scale, surf_scale, 0, c_white, 1);