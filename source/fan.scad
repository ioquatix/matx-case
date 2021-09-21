/*
	- Hole sizes confirmed.
	- Spacing sizes confirmed.
*/

use <bolts.scad>;
use <zcube.scad>;

SPACING = [
	[40, 32],
	[50, 40],
	[60, 50],
	[70, 60],
	[80, 71.5],
	[92, 82.5],
	[120, 105],
	[140, 124.5],
	[200, 154],
	[220, 170]
];

function screw_spacing(d) = lookup(d, SPACING);

module fan_nh_u9s() {
	zcube([95, 95, 125]);
}

module fan_nh_d15s() {
	zcube([150, 160, 160]);
}

module fan_nh_c14s() {
	zcube([140, 163, 115]);
}

module fan(diameter = 140, thickness = 25) {
	difference() {
		translate([-diameter/2, -diameter/2, -thickness]) color("blue") cube([diameter, diameter, thickness]);
		translate([0, 0, -thickness-1]) cylinder(d=diameter, h=thickness+2);
	}
}

module fan_holes(diameter = 140, z = 10) {
	spacing = screw_spacing(diameter);
	outset = spacing / 2;
	
	translate([outset, outset, z]) children();
	translate([-outset, outset, z]) children();
	translate([-outset, -outset, z]) children();
	translate([outset, -outset, z]) children();
}

module fan_cutout(diameter = 140, thickness = 6, inset = 2, spacing = 124.5) {
	render() {
		translate([0, 0, -0.1]) difference() {
			cylinder(h = thickness+0.2, r = (diameter - inset)/2);
			
			for (r = [45:90:180]) {
				rotate([0, 0, r]) zcube([diameter, 6, thickness+0.2]);
			}
			
			cylinder(h = thickness+0.2, r = diameter/10);
		}
		
		/* translate([0, 0, wall]) zcorners() hull() {
			translate([-spacing/2, -spacing/2, 0]) cylinder_outer(thickness-wall+0.1, (diameter-spacing)/2);
			cylinder_outer(thickness-wall+0.1, diameter/5);
		} */
		
		// The "standard hole" is inch(7/32) = 5.5mm, but most cases use M5 holes and as the heads of the screws OD=6mm, we prefer OD=5mm for the hole... better to be a little bit tight than a little bit loose... considering the accuracy of laser cutters can be around 0.3mm.
		fan_holes(diameter) translate([0, 0, -35]) hole(5, 35);
	}
}

function distance(x, y) = sqrt(x*x+y*y);
function hex_x(step_x, size) = step_x * sqrt(3) * size;
function hex_y(step_x, step_y, size) = step_y * 2 * size + (step_x % 2) * size;

module fan_cutout_hex(diameter = 140, thickness = 6, inset = 0, extra = []) {
	center = (70+2.25)*2;
	size = (center / 8) / sqrt(3);
	
	steps = ceil(diameter / size / 2) + 2;
	
	render()
	intersection() {
		cylinder(r=diameter/2, h=thickness);
		
		for (step_x = [-steps:steps]) {
			x = hex_x(step_x, size);
			
			for (step_y = [-steps:steps]) {
				y = hex_y(step_x, step_y, size);
				
				if (!(x == 0 && y == 0) && distance(x, y) < (diameter/2 + size)) {
					translate([x, y, 0])
					cylinder_outer(thickness, size - 2, 6);
				}
			}
		}
	}
	
	for (coordinate = extra) {
		x = hex_x(coordinate[0], size);
		y = hex_y(coordinate[0], coordinate[1], size);
		
		translate([x, y, 0])
		cylinder_outer(thickness, size - 2, 6);
	}
	
	// The "standard hole" is inch(7/32) = 5.5mm, but most cases use M5 holes and as the heads of the screws OD=6mm, we prefer OD=5mm for the hole... better to be a little bit tight than a little bit loose... considering the accuracy of laser cutters can be around 0.3mm.
	fan_holes(diameter) translate([0, 0, -35]) hole(5, 35);
}

// This is a bracket for spacing a filter 2mm away from the fan itself to prevent the fan blades hitting the filter. In practice, 1mm thick seems sufficient, but is not very strong or as easy to print.
module fan_bracket(diameter = 140, thickness = 2, inset = 1) {
	render()
	difference() {
		rcube([diameter, diameter, thickness], d=10, f=1);
		
		cylinder(d=diameter-inset*2, h=thickness);
		
		fan_holes(diameter) translate([0, 0, -35]) hole(5, 35);
	}
}

//color("brown") fan();
//#fan_holes() translate([0, 0, -35]) hole(3, 35);

fan_cutout_hex(80, extra=[
	[-1, 2], [0, 2], [1, 1],
	[-1, 2+1], [0, 2+1], [1, 1+1],
	[-1, -1], [0, -2], [1, -2],
	[-1, -1-1], [0, -2-1], [1, -2-1],
]);
//fan_bracket();