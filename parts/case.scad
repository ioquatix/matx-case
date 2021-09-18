
include <../source/case.scad>;

rotate([0, -90, 0]) {
	case();
	//corner();
	bottom_panel();
	top_panel();
}
