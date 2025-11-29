
draw_text(16, 16, $"GMHook v{GMHOOK_VERSION} - Demo Project"+
@"
[Q] - Send simple message
[W] - Send embed (raw struct)
[E] - Send embed (system methods)
[R] - Send poll
[T] - Send screen capture
[Y] - Send buffer file
[U] - Send log file example
")

var _s = 128;
var _t = current_time/10;
var _c1 = make_colour_hsv((_t + 0) mod 255, 255, 255);
var _c2 = make_colour_hsv((_t + 64) mod 255, 255, 255);
var _c3 = make_colour_hsv((_t + 128) mod 255, 255, 255);
var _c4 = make_colour_hsv((_t + 192) mod 255, 255, 255);

matrix_set(matrix_world, matrix_build(mouse_x, mouse_y, 0, 0, 0, _t, _s, _s, 1))
draw_rectangle_colour(-1, -1, 0, 0, _c1, _c2, _c3, _c4, false);
matrix_set(matrix_world, matrix_build_identity());