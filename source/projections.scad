
include <case.scad>;

module wall_projection(index = 0) {
	projection(cut = true)
		rotate([0, 90, 0])
		translate([internal_size[0]/2+3, 0, 0])
		rotate([0, 0, 90 * index])
		walls();
}

wall_projection(3);