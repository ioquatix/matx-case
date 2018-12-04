
use <bolts.scad>;

use <fan.scad>;

h115i_platinum = [27, 322, 137];
h115i_pro = [29, 315, 143];

module h115i(diameter = 140, spacing = 124.5, offset = 20, radiator = h115i_platinum) {
	outset = (diameter - spacing) / 2;
	dy = (offset / 2) - outset;
	
	// Corsair H115i
	// Radiator dimensions: 140mm x 312mm x 26mm
	// Fan dimensions: 140mm x 25mm
	difference() {
		union() {
			color("white") translate([-(radiator[0]+25), -radiator[1]/2, -radiator[2]/2]) cube(radiator);
			
			translate([0, -70-dy, 0]) rotate([0, 90, 0]) fan();
			translate([0, 70+dy, 0]) rotate([0, 90, 0]) fan();
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
