
use <bolts.scad>;
use <zcube.scad>;

sfx_dimensions = [125, 100, 63.5];

module sfx(dimensions = sfx_dimensions) {
	difference() {
		// http://silverstonetek.com/goods_cable_define/sx500-g-cable-define.pdf
		color("grey") translate([-dimensions[0]/2, 0, -dimensions[2]]) cube(dimensions);
		sfx_holes() rotate(90, [1, 0, 0]) hole(3, 10);
	}
}

module sfx_holes(inset = 6, dimensions = sfx_dimensions) {
	width = dimensions[0];
	height = dimensions[2];
	
	translate([-width/2+inset, 0, -inset]) children();
	translate([width/2-inset, 0, -inset]) children();
	
	// TODO I don't know if this is correct..
	translate([-width/2+inset, 0, -height/2]) children();
	translate([width/2-inset, 0, -height/2]) children();
	
	translate([-width/2+inset, 0, inset-height]) children();
	translate([width/2-inset, 0, inset-height]) children();
}

module sfx_cutout(thickness = 6, inset = 12, dimensions = sfx_dimensions) {
	difference() {
		color("grey") translate([0, 0.1, -dimensions[2]/2]) rotate([90, 0, 0]) zcube([dimensions[0]-inset, dimensions[2]-inset, thickness+0.2]);

		sfx_holes() rotate([90, 45, 0]) zcube([inset, inset, thickness*2], z=-thickness/2);
	}
	
	sfx_holes() translate([0, 30-thickness, 0]) rotate([90, 0, 0]) hole(3, 30);
}

module sfx_offset(x = 0, y = 0.5, dimensions = sfx_dimensions) {
	translate([dimensions[0]*x, 0, dimensions[2]*y]) children();
}

sfx_offset() {
	sfx();
	color("red") sfx_cutout();
}
