
use <bolts.scad>;
use <zcube.scad>;

bay_dimensions = [100+10, 50+10, 40];

module bay(dimensions = bay_dimensions) {
	difference() {
		// http://silverstonetek.com/goods_cable_define/sx500-g-cable-define.pdf
		color("grey")
		translate([0, 0.1, 0])
		zcube(dimensions, f=-1);
		
		bay_holes() rotate(90, [1, 0, 0]) hole(3, 10);
	}
}

module bay_holes(outset = 6, dimensions = bay_dimensions) {
	width = dimensions[0];
	height = dimensions[1];
	
	for (offset = [-height/4:height/2:height/2]) {
		translate([-width/2-outset, offset, 0]) children();
		translate([width/2+outset, offset, 0]) children();
	}
}

module bay_cutout(thickness = 6, inset = 12, insert=6, dimensions = bay_dimensions) {
	color("grey")
	translate([0, 0.1, 0])
	zcube([dimensions[0], dimensions[1], thickness+0.2]);
	
	// The screw is M3, but we make the hole M4 so it won't hold a thread.
	bay_holes() translate([0, 0, -insert]) knurled_hole(3, thickness+insert, insert=insert);
}

module bay_offset(x = 0, y = 0.5, dimensions = bay_dimensions) {
	translate([dimensions[0]*x, 0, dimensions[2]*y]) children();
}

//bay_offset() {
	bay();
	color("red") bay_cutout();
//}
