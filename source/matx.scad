
$tolerance = 0.1;
$fn = 4*4;

use <bolts.scad>;
use <zcube.scad>;

use <h115i.scad>;
use <sx500g.scad>;

use <fan.scad>;

function inch(x) = x * 25.4;

internal_size = [308, 308, 140+5];

module pci_card() {
	translate([1.6/2, 19.8, 7.6+4]) rotate(-90, [0, 0, 1]) rotate(90, [1, 0, 0]) color("brown") import("gtx.stl", convexity=4);
}

module standoffs() {
	// DATUM B as per the microATX specification is the origin.
	children();
	translate([inch(1.8), 0, 0]) children();
	translate([inch(8), inch(-0.9), 0]) children();
	
	translate([0, inch(-6.1), 0]) {
		translate([inch(-0.8), 0, 0]) children();
		children();
		translate([inch(1.8), 0, 0]) children();
		translate([inch(8), 0, 0]) children();
	}
	
	translate([0, inch(-8.95), 0]) {
		translate([inch(1.8), 0, 0]) children();
		translate([inch(8), 0, 0]) children();
	}
}

module pci_connectors(inset = inch(-0.6), factor = 0.5, count = 4) {
	// This is the position of pin 0 is given when factor is 0, otherwise when factor = 0.5 it's the midpoints.
	translate([inch(-1.2), inset, 0]) {
		for (x = [0:1:count-1])
			translate([inch(0.8*(x+factor)), 0, 0]) children();
	}
}

module motherboard(thickness=1.6) {
	difference() {
		color("green") translate([inch(-1.35), inch(0.4-9.6), 0]) cube([inch(9.6), inch(9.6), thickness]);
		standoffs() color("white") cylinder(d=4, h=10, $fn=12);
	}
	
	//translate([6.64, -46.94, 0]) pci_card();
	translate([47.28, -46.94, 0]) pci_card();
	
	// A very rough approximation of where the CPU is likely to be.
	translate([inch(5), inch(-4.5), thickness]) color("silver") zcube([inch(3), inch(2.5), inch(1.5)]);
	
	color("grey") {
		pci_connectors() translate([0, 0, thickness]) scale([1.0, -1.0, 1.0]) cube([inch(0.4), inch(5), inch(0.4)]);
	}
}

module rear_io_cutout() {
	translate([inch(2.096), inch(0.483)-$tolerance, inch(-0.088)]) cube([inch(6.25), 20, inch(1.75)]);
	translate([inch(2.096-0.1), inch(0.483+0.05)-$tolerance, inch(-0.088-0.1)]) cube([inch(6.25+0.2), 20, inch(1.75+0.2)]);
}

module rear_powersupply() {
	translate([inch(2.096+3), inch(0.483-2), inch(2)]) {
		power_supply();
	}
}

module rear_pci_cutout(width = 14) {
	pci_connectors(inch(0.483), 0.5) {
		translate([-width/2, 0-$tolerance, 0]) cube([width, 20, 100]);
		translate([-inch(0.3), 0-$tolerance, 108.8]) cube([inch(0.8)+$tolerance, 20, 1]);
		translate([-inch(0.3), 0-$tolerance, 108.8]) cube([inch(0.8)+$tolerance, 20, 50]);
		
		// TODO Just eyeballed this.
		translate([9.215, 4.95, 108.8-5]) hole(3, 5);
		
		// TODO Just eyeballed this.
		translate([2.7, 8.95, 107]) zcube([8, 4, 6]);
	}
}

module rear_pci_bracket(width = 14) {
	pci_connectors(inch(0.483), 0.5) {
		translate([inch(0.1), 6, 108.8-6]) rcube([inch(0.9), 10, 6], 6);
	}
}

module walls(dimensions, thickness = 6) {
	render() difference() {
		union() {
			difference() {
				zcube([dimensions[0]+thickness*2, dimensions[1]+thickness*2, dimensions[2]], d=20);
				zcube(dimensions);
			}
			
			bottom_tray(dimensions) {
				rear_pci_bracket();
			}
		}
		
		front_fan(dimensions) fan_cutout();
		top_radiator(dimensions) h115i_cutout();
		back_power_supply(dimensions) sx500g_cutout();
		
		bottom_tray(dimensions) {
			// You need a small amount of clearance around this (0.1in)
			rear_io_cutout();
			rear_pci_cutout();
		}
		
		zcorners() corner(dimensions);
		zcorners() corner_cutout(dimensions);
	}
}

module front_fan(dimensions) {
	translate([-70-2.25, -dimensions[1]/2, dimensions[2]/2]) rotate([90, 0, 0]) children();
}

module top_radiator(dimensions) {
	translate([dimensions[0]/2, 0, dimensions[2]/2]) children();
}

module back_power_supply(dimensions) {
	translate([10, dimensions[1]/2, dimensions[2]-4]) rotate([0, 0, 180]) children();
}

module bottom_tray(dimensions, offset = 18) {
	translate([inch(-4.8)+8, dimensions[1]/2-inch(0.483), offset]) children();
}

module case(dimensions = internal_size, board_offset = 18) {
	bottom_tray(dimensions, board_offset) {
		motherboard();
	}

	top_radiator(dimensions) h115i();
	back_power_supply(dimensions) sx500g();
	front_fan(dimensions) fan();
	
	color("white") walls(dimensions);
	
	difference() {
		zcorners() corner();
		zcorners() corner_cutout();
	}
}

module corner_mask(dimensions, outset = 10, thickness = 6) {
	translate([dimensions[0]/2, dimensions[1]/2, 0]) {
		translate([-outset+thickness, -outset+thickness, 0]) cube([outset, outset, dimensions[2]]);

		translate([thickness/2, -outset, 0]) cube([thickness/2, outset, dimensions[2]]);
		translate([-outset, thickness/2, 0]) cube([outset, thickness/2, dimensions[2]]);
	}
}

module join_edge(length, width = 1, height = 10, count = 11, zig = 0.2) {
	step = (length / (count+0.5)) / 4;
	offset = step * zig;
	
	for (i = [0:1:count]) {
		translate([0, i*step*4, 0]) linear_extrude(height=height) polygon([
			[-width, 0],
			[-width, step+offset],
			[width, step-offset],
			[width, step*3+offset],
			[-width, step*3-offset],
			[-width, step*4],
		]);
	}
}

module join_mask(dimensions, thickness = 6, width = 1) {
	translate([0, 0, thickness]) {
		rotate([90, 0, 0]) join_edge(dimensions[2]-thickness*2, height=dimensions[1]/2+thickness+$tolerance, width=width);
		
		translate([-width, 0, 0]) rotate([0, 0, 180]) cube([dimensions[0]/2-width, dimensions[1]/2+thickness, dimensions[2]-thickness*2]);
	}
}

module corner(dimensions = internal_size, thickness = 6, offset = 10, inset = 10) {
	sx = dimensions[0]+(thickness*2+offset*2);
	sy = dimensions[1]+(thickness*2+offset*2);
	
	render() difference() {
		intersection() {
			rcube([sx, sy, dimensions[2]], d=offset*2);
			cube([sx/2, sy/2, dimensions[2]]);
		}
		
		zcube([dimensions[0]+thickness*2, dimensions[1], dimensions[2]]);
		zcube([dimensions[0], dimensions[1]+thickness*2, dimensions[2]]);
		
		zcube([sx, dimensions[1]-inset*2, dimensions[2]]);
		zcube([dimensions[0]-inset*2, sy, dimensions[2]]);
	}
}

module corner_cutout(dimensions = internal_size, thickness = 6, offset = 10, inset = 10, panel_thickness = 6, panel_bolt_insert = 12) {
	translate([dimensions[0]/2, dimensions[1]/2, 0]) {
		// Requires knurled insert M6x12x8
		translate([thickness, thickness, panel_bolt_insert]) mirror([0, 0, 1]) rotate([0, 0, 45+90]) knurled_hole(6, panel_bolt_insert+panel_thickness, insert=panel_bolt_insert);
		translate([thickness, thickness, dimensions[2]-panel_bolt_insert]) rotate([0, 0, 45+90]) knurled_hole(6, panel_bolt_insert+panel_thickness, insert=panel_bolt_insert);
		
		bolt_length = thickness+offset-2;
		
		bolt_size = 3;
		vertical_inset = bolt_size + 1;
		vertical_offset = (dimensions[2]-vertical_inset*2) / 3;
		
		for (dz = [vertical_inset:vertical_offset:dimensions[2]]) {
			// Requires knurled insert M3x8x5mm, flat M3x14mm scews.
			translate([bolt_length, -offset/2, dz]) rotate([0, -90, 0]) countersunk_knurled_hole(bolt_size, bolt_length, insert=offset-2);
			translate([-offset/2, bolt_length, dz]) rotate([90, 0, 0]) countersunk_knurled_hole(bolt_size, bolt_length, insert=offset-2);
		}
	}
}

module top_panel(dimensions = internal_size, thickness = 6, offset = 10) {
	sx = dimensions[0]+(thickness*2+offset*2);
	sy = dimensions[1]+(thickness*2+offset*2);
	
	translate([0, 0, dimensions[2]]) rcube([sx, sy, thickness], d=offset*2);
}

module bottom_panel(dimensions = internal_size, thickness = 6, offset = 10) {
	sx = dimensions[0]+(thickness*2+offset*2);
	sy = dimensions[1]+(thickness*2+offset*2);
	
	render() difference() {
		translate([0, 0, -thickness]) rcube([sx, sy, thickness], d=offset*2);
		
		render() for (dx = [-150:20:150]) {
			for (dy = [-150:20:150]) {
				color("green") translate([dx, dy, -4]) render() knurled_hole(3, 4, insert=4);
			}
		}
		
		// To assist with printing, we put ridges into the mesh (avoids warping/bending)
		render() for (dr = [20:20:150]) {
			translate([0, 0, -1]) difference() {
				rcube([dr*2+1, dr*2+1, 1], 20);
				rcube([dr*2-1, dr*2-1, 1], 20);
			}
		}
		
		zcorners() corner_cutout(dimensions);
	}
	
	/*bottom_tray(dimensions, 0) {
		render() difference() {
			standoffs() color("yellow") cylinder(d1=12, d2=8, h=6, $fn=12);
			standoffs() color("yellow") knurled_hole(3, 12, insert=6);
		}
	}*/
}
