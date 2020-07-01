
use <bolts.scad>;
use <fan.scad>;
use <zcube.scad>;

depth = 20;

size = 140;
space = 2;

height = 2;

inset = 2;

duct_width = 180;

module duct_tube(offset = 0, thickness = 6) {
	translate([0, -116, 0])
	hull() {
		translate([0, 0, -thickness])
		zcube([20+offset, duct_width+offset + offset * 8, thickness]);
		
		translate([0, 0, -18])
		zcube([20+offset*4, duct_width+offset*4, thickness]);
	}
}

module duct_cutout(thickness = 6) {
	translate([0, -116, 0]) {
		reflect([0, 1, 0]) translate([0, duct_width/2 + 6, -thickness]) threaded_hole(3, 12);
		zcube([20, duct_width, thickness]);
	}
}

module duct() {
	color("orange")
	render()
	union() {
		difference() {
			duct_tube(2);
			duct_tube(0);
			
			duct_cutout();
		}
	}
}

duct();
