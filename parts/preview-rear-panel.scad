
include <../source/case.scad>;

margin = [40, 40];

module wall_projection(index = 0) {
	projection()
	render()
	intersection() {
		zcube([1000, 1000, 6]);
		rotate([0, 90, 0])
		translate([internal_size[0]/2+3, 0, 0])
		rotate([0, 0, 90 * index])
		render() sides();
	}
}

rotate([0, 0, 90]) wall_projection(1);
