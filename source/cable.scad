
use <bolts.scad>;
use <zcube.scad>;

module standoff(height = 12, inset = 6) {
	color("gold") {
		cylinder(d=5, h=height, $fn=6);
		mirror([0, 0, 1]) cylinder_inner(inset, 3/2);
	}
}

module standoff_hole() {
	color("yellow")
	translate([0, 0, -6]) 
	threaded_hole(3, 6, 12);
}

module cable_clamp(width = 48, height = 12) {
	difference() {
		union() {
			hull() {
				for (offset = [-width/2:width:width]) {
					translate([offset, 0, height]) cylinder_inner(4, 4);
				}
			}
			
			for (offset = [-width/2:width:width]) {
				translate([offset, 0, 0]) standoff();
			}
		}
		
		translate([width/2, 0, 0]) hole(3, 18);
		translate([-width/2, 0, 0]) hole(3, 18);
	}
}

module cable_clamp_cutout(width = 48, height = 12) {
	translate([width/2, 0, 0]) standoff_hole();
	translate([-width/2, 0, 0]) standoff_hole();
}

cable_clamp();
cable_clamp_cutout();
