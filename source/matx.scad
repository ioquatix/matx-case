
$tolerance = 0.1;

use <bolts.scad>;
use <zcube.scad>;

use <h115i.scad>;
use <sx500g.scad>;

use <fan.scad>;

function inch(x) = x * 25.4;

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
		translate([9.215, 4.95, 108.8-5]) #hole(3, 5);
		
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
		color([0.2, 0.2, 0.2, 0.7]) {
			render() difference() {
				translate([0, 0, 6]) rcube([dimensions[0]+thickness*2, dimensions[1]+thickness*2, dimensions[2]-12], d=20);
				zcube(dimensions);
			}
			
			bottom_tray(dimensions, 12) {
				rear_pci_bracket();
			}
		}
		
		front_fan(dimensions) fan_cutout();
		top_radiator(dimensions) h115i_cutout();
		back_power_supply(dimensions) sx500g_cutout();
		
		bottom_tray(dimensions, 12) {
			// You need a small amount of clearance around this (0.1in)
			rear_io_cutout();
			rear_pci_cutout();
		}
	}
}

module front_fan(dimensions) {
	translate([-70-2.25, -dimensions[1]/2, 140/2+10]) rotate([90, 0, 0]) children();
}

module top_radiator(dimensions) {
	translate([dimensions[0]/2, 0, dimensions[2]/2]) children();
}

module back_power_supply(dimensions) {
	translate([10, dimensions[1]/2, dimensions[2]-6-4]) rotate([0, 0, 180]) children();
}

module bottom_tray(dimensions, offset = 12) {
	translate([inch(-4.8)+8, dimensions[1]/2-inch(0.483), 6+offset]) children();
}

module case(dimensions = internal_size, board_offset = 12) {
	// TODO fix these arbitrary numbers:
	bottom_tray(dimensions, board_offset) {
		motherboard();
	}
	
	bottom_tray(dimensions, 0) {
		standoffs() color("yellow") cylinder(d=4, h=12, $fn=12);
	}

	top_radiator(dimensions) h115i();
	back_power_supply(dimensions) sx500g();

	// front fan:
	front_fan(dimensions) fan();

	// bottom and top of case
	color([0.8, 0.8, 1.0, 0.2]) {
		rcube([340, 340, 6], d=40);
	//	translate([0, 0, 154]) rcube([340, 340, 6], d=40);
	}

	walls();
}

case();
