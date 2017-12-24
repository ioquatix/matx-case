
use <bolts.scad>;
use <zcube.scad>;

ssd_dimensions = [70, 100, 7];

module ssd(dimensions = ssd_dimensions) {
	color("silver") translate([0, -dimensions[1]/2, 0]) difference() {
		translate([-dimensions[0]/2, 0, 0]) cube(dimensions);
		
		// This is just an approximation for visual alignment.
		translate([-dimensions[0]/2 + dimensions[0]/6, -0.01, -0.01]) cube([dimensions[0]*0.5, dimensions[1]*0.1, dimensions[2]*0.8]);
		
		ssd_holes_bottom() translate([0, 0, -3]) hole(3, 6+3);
		ssd_holes_side() translate([0, 0, -3]) hole(3, 6+3);
	}
}

module ssd_holes_bottom(dimensions = ssd_dimensions, width = 61.71, inset = [14, 90.6]) {
	mirror([0, 0, 1]) {
		translate([-width/2, inset[0], 0]) children();
		translate([width/2, inset[0], 0]) children();
		
		translate([-width/2, inset[1], 0]) children();
		translate([width/2, inset[1], 0]) children();
	}
}

module ssd_holes_side(dimensions = ssd_dimensions, offset = 3, inset = [14, 90.6]) {
	translate([0, 0, offset]) {
		translate([dimensions[0]/2, inset[0], 0]) rotate([0, 90, 0]) children();
		translate([dimensions[0]/2, inset[1], 0]) rotate([0, 90, 0]) children();
		
		mirror([1, 0, 0]) {
			translate([dimensions[0]/2, inset[0], 0]) rotate([0, 90, 0]) children();
			translate([dimensions[0]/2, inset[1], 0]) rotate([0, 90, 0]) children();
		}
	}
}

module ssd_cutout(dimensions = ssd_dimensions, depth=6) {
	translate([0, -dimensions[1]/2, 0]) {
		// The screw is M3, but we make the hole M4 so it won't hold a thread.
		ssd_holes_bottom() translate([0, 0, -3]) hole(4, depth+3);
	}
}

module ssd_standoff_corner() {
	difference() {
		cylinder_outer(6, 4);
	}
}

module ssd_standoff(dimensions = ssd_dimensions, thickness = 6, width = 61.71, inset = [14, 90.6]) {
	translate([0, -dimensions[1]/2, 0]) {
		difference() {
			union() {
				ssd_holes_bottom() cylinder_outer(6, 4);
				
				hull() {
					translate([-width/2, inset[0], -3]) cylinder_outer(3);
					translate([width/2, inset[1], -3]) cylinder_outer(3);
				}
				
				hull() {
					translate([-width/2, inset[1], -3]) cylinder_outer(3);
					translate([width/2, inset[0], -3]) cylinder_outer(3);
				}
			}
			
			ssd_holes_bottom() hole(3, 6);
		}
	}
}

module ssd_with_standoff(thickness=6) {
	translate([0, 0, thickness]) {
		ssd_standoff(thickness=thickness);
		ssd();
	}
}
