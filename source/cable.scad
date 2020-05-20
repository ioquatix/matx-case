
use <bolts.scad>;
use <zcube.scad>;

module cable_clamp(width = 48, height = 12) {
	difference() {
		union() {
			hull() {
				for (offset = [-width/2:width:width]) {
					translate([offset, 0, height]) cylinder_inner(4, 4);
				}
			}
			
			for (offset = [-width/2:width:width]) {
				translate([offset, 0, 0]) cylinder_inner(12, 4);
			}
		}
		
		translate([width/2, 0, 0]) hole(3, 18);
		translate([-width/2, 0, 0]) hole(3, 18);
	}
}

module cable_clamp_cutout(width = 48, height = 12) {
	mirror([0, 0, 1]) {
		#translate([width/2, 0, 0]) hole(3, 6);
		#translate([-width/2, 0, 0]) hole(3, 6);
	}
}

cable_clamp();
cable_clamp_cutout();
