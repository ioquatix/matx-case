
use <bolts.scad>;

use <fan.scad>;

module h115i(diameter = 140, spacing = 124.5, offset = 20) {
	outset = (diameter - spacing) / 2;
	dy = (offset / 2) - outset;
	
	// Corsair H115i
	// Radiator dimensions: 140mm x 312mm x 26mm
	// Fan dimensions: 140mm x 25mm
	difference() {
		union() {
			color([0.1, 0.1, 0.1]) translate([-(26+25), -312/2, -140/2]) cube([26, 312, 140]);
			
			color("blue") {
				translate([0, -70-dy, 0]) rotate([0, 90, 0]) fan();
				translate([0, 70+dy, 0]) rotate([0, 90, 0]) fan();
			}
		}
		
		h115i_cutout();
	}
}

module h115i_cutout(diameter = 140, spacing = 124.5, offset = 20) {
	outset = (diameter - spacing) / 2;
	dy = (offset / 2) - outset;
	
	translate([0, -70-dy, 0]) rotate([0, 90, 0]) fan_cutout();
	translate([0, 70+dy, 0]) rotate([0, 90, 0]) fan_cutout();
}

h115i();
color("red") h115i_cutout();
