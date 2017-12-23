
use <bolts.scad>;
use <zcube.scad>;

module fan(diameter = 140, thickness = 25) {
	translate([-diameter/2, -diameter/2, -thickness]) color("blue") cube([diameter, diameter, thickness]);
}

module fan_holes(diameter = 140, spacing = 124.5, z = 10) {
	outset = spacing / 2;
	
	translate([outset, outset, z]) children();
	translate([-outset, outset, z]) children();
	translate([-outset, -outset, z]) children();
	translate([outset, -outset, z]) children();
}

module fan_cutout(diameter = 140, thickness = 6, wall = 3, spacing = 124.5) {
	render() {
		translate([0, 0, -0.1]) cylinder_outer(thickness+0.2, diameter/2);
		
		translate([0, 0, wall]) zcorners() hull() {
			translate([-spacing/2, -spacing/2, 0]) cylinder_outer(thickness-wall+0.1, (diameter-spacing)/2);
			cylinder_outer(thickness-wall+0.1, diameter/5);
		}
		
		fan_holes(diameter, spacing) translate([0, 0, -35]) hole(3, 35);
	}
}

//color("brown") fan();
//#fan_holes() translate([0, 0, -35]) hole(3, 35);
fan_cutout(80, spacing=80-10);