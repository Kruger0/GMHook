
var _gw = display_get_gui_width()
var _gh = display_get_gui_height()

mxp = mx
myp = my
mx = device_mouse_x_to_gui(0)
my = device_mouse_y_to_gui(0)


if !(surface_exists(surf)) {
	surf = surface_create(_gw, _gh)
	surface_set_target(surf)
	draw_clear_alpha(bg, 1)
	surface_reset_target()	
}

stroke = clamp(stroke + (mouse_wheel_up() - mouse_wheel_down() * 2), 1, 64)

if (mouse_check_button(mb_left) && !is_mouse_over_debug_overlay()) {
	surface_set_target(surf)
		draw_circle_color(mxp, myp, stroke, color, color, false)
		draw_line_width_color(mx, my, mxp, myp, stroke*2, color, color)
		draw_circle_color(mx, my, stroke, color, color, false)
	surface_reset_target()	
}

draw_surface(surf, 0, 0)
draw_circle_color(mx, my, stroke, color, color, false)