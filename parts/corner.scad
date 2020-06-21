
include <../source/case.scad>;

render()
rotate([-90, 45, 0])
translate([-internal_size[0]/2, -internal_size[0]/2, 0])
difference() {
	corner();
	corner_cutout();
}
