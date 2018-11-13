
use <bolts.scad>;
use <zcube.scad>;

bay_dimensions = [102, 100, 25];

module bay(dimensions = bay_dimensions) {
	difference() {
		// http://silverstonetek.com/goods_cable_define/sx500-g-cable-define.pdf
		color("grey") translate([-dimensions[0]/2, 0, -dimensions[2]]) cube(dimensions);
		bay_holes() rotate(90, [1, 0, 0]) hole(3, 10);
	}
}

module bay_holes(outset = 6, dimensions = bay_dimensions) {
	width = dimensions[0];
	height = dimensions[2];
	
	translate([-width/2-outset, 0, -height/2]) children();
	translate([width/2+outset, 0, -height/2]) children();
}

module bay_cutout(thickness = 10, inset = 12, dimensions = bay_dimensions) {
	color("grey") translate([0, 0.1, -dimensions[2]/2]) rotate([90, 0, 0]) zcube([dimensions[0], dimensions[2], thickness+0.2]);
	
	// The screw is M3, but we make the hole M4 so it won't hold a thread.
	bay_holes() translate([0, 30-thickness, 0]) rotate([90, 0, 0]) hole(4, 30);
}

module bay_offset(x = 0, y = 0.5, dimensions = bay_dimensions) {
	translate([dimensions[0]*x, 0, dimensions[2]*y]) children();
}

bay_offset() {
	bay();
	color("red") bay_cutout();
}
