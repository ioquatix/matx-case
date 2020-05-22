
use <bolts.scad>;
use <fan.scad>;
use <zcube.scad>;

depth = 20;

size = 140;
space = 2;

height = 2;

inset = 2;

gpu = [0, 240, 200, 230];

module duct_tube(offset = 0, thickness = 6) {
	translate([0, -120, 0])
	hull() {
		zcube([18+offset, 200+offset, thickness]);
		
		translate([0, 0, -18])
		zcube([22+offset, 200+offset, thickness]);
	}
}

module duct_cutout(thickness = 6) {
	translate([0, -120, -0.1]) {
		reflect([0, 1, 0]) translate([0, 200/2 + 6, 0]) hole(4, thickness);
		zcube([18, 200, thickness+0.2]);
	}
}

module duct() {
	render()
	union() {
		difference() {
			duct_tube();
			duct_tube(-2);
		}
	}
}
