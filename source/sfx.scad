/*
	- Hole sizes confirmed.
	- Spacing sizes confirmed.
*/

use <bolts.scad>;
use <zcube.scad>;

sfx_dimensions = [125, 100, 63.5];
//sfx_dimensions = [150, 140, 86];

module sfx(dimensions = sfx_dimensions) {
	render()
	difference() {
		color("grey") translate([-dimensions[0]/2, 0, 0]) cube(dimensions);
		sfx_holes() rotate(90, [1, 0, 0]) hole(3, 10);
		
		translate([0, dimensions[1]/2, 0]) cylinder(d=92,h=5);
	}
	
	scale([0.9, 1.0, 0.9])
	translate([0, dimensions[1]+9, dimensions[2]/2])
	zcube([dimensions[0], 18, dimensions[2]/2]);
}

module sfx_holes(inset = 6, f = 1.0, dimensions = sfx_dimensions) {
	width = dimensions[0];
	height = dimensions[2];
	
	translate([-width/2+inset, 0, inset*f]) children();
	translate([width/2-inset, 0, inset*f]) children();
	
	translate([-width/2+inset, 0, height/2]) children();
	translate([width/2-inset, 0, height/2]) children();
	
	translate([-width/2+inset, 0, height-(inset*f)]) children();
	translate([width/2-inset, 0, height-(inset*f)]) children();
}

module sfx_cutout(thickness = 6, dimensions = sfx_dimensions) {
	render() difference() {
		color("grey") translate([0, 0.1, dimensions[2]/2]) rotate([90, 0, 0]) zcube([dimensions[0]-10-2, dimensions[2]-6-4, thickness+0.2]);
		
		sfx_holes(inset=2, f=3) rotate([90, 360/16, 0]) translate([0, 0, -1]) cylinder(h=thickness+2, r=9, $fn = 8);
		
		// These parts are non-standard to improve the strenght of the side panel, and may need to be adjusted according to the dimensions of the plug and switch on your power supply:
		translate([0, -3, 0])
		zcube([6, 8, dimensions[2]]);
		
		translate([0, 1, 0])
		rotate([90, 0, 0])
		cylinder(h=thickness+2, r=16, $fn = 4);
		
		translate([0, 1, dimensions[2]])
		rotate([90, 0, 0])
		cylinder(h=thickness+2, r=16, $fn = 4);
	}
	
	sfx_holes() translate([0, 30-thickness, 0]) rotate([90, 0, 0]) hole(3, 30);
}

module sfx_offset(x = 0, y = 0.5, dimensions = sfx_dimensions) {
	translate([dimensions[0]*x, 0, -dimensions[2]]) children();
}

//sfx_offset() {
	sfx();
	color("red") sfx_cutout();
//}
