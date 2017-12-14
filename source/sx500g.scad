
use <bolts.scad>;
use <zcube.scad>;

module sx500g() {
	difference() {
		// http://silverstonetek.com/goods_cable_define/sx500-g-cable-define.pdf
		color("grey") translate([-125/2, 0, -63]) cube([125, 100, 63]);
		sx500g_holes() rotate(90, [1, 0, 0]) hole(3, 10);
	}
}

module sx500g_holes(inset = 6, width = 125, height = 63) {
	translate([-width/2+inset, 0, -inset]) children();
	translate([width/2-inset, 0, -inset]) children();
	
	// TODO I don't know if this is correct.. 
	translate([-width/2+inset, 0, -height/2]) children();
	translate([width/2-inset, 0, -height/2]) children();
	
	translate([-width/2+inset, 0, inset-height]) children();
	translate([width/2-inset, 0, inset-height]) children();
}

module sx500g_cutout(thickness = 10, inset = 10) {
	render() difference() {
		color("grey") translate([0, 0.1, -63/2]) rotate([90, 0, 0]) zcube([125-inset, 63-inset, thickness+0.2]);

		sx500g_holes() rotate([90, 0, 0]) cylinder(d=10, h=thickness+0.1);
	}
	
	sx500g_holes() translate([0, 30-thickness, 0]) rotate([90, 0, 0]) hole(3, 30);
}

sx500g();
color("red") sx500g_cutout();