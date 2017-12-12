
use <zcube.scad>;

function inch(x) = x * 25.4;

module pci_card() {
	translate([1.6/2, 19.8, 7.6+4]) rotate(-90, [0, 0, 1]) rotate(90, [1, 0, 0]) color("brown") import("gtx.stl", convexity=4);
}

module power_supply() {
	// http://silverstonetek.com/goods_cable_define/sx500-g-cable-define.pdf
	zcube([125, 100, 63]);
}

module radiator() {
	// Corsair H115i
	// Radiator dimensions: 140mm x 312mm x 26mm
	// Fan dimensions: 140mm x 25mm
	//scale([1, -1, 1]) cube([26+25, 312, 140]);
	scale([1, -1, 1]) cube([30+25, 276, 125]);
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

module pci_connectors(inset = inch(-0.6), factor = 0.5) {
	// This is the position of pin 0 is given when factor is 0, otherwise when factor = 0.5 it's the midpoints.
	translate([inch(-1.2), inset, 0]) {
		for (x = [0:1:3])
			translate([inch(0.8*(x+factor)), 0, 0]) children();
	}
}

module motherboard(thickness=1.6) {
	difference() {
		translate([inch(-1.35), inch(0.4-9.6), 0]) cube([inch(9.6), inch(9.6), thickness]);
		standoffs() color("white") cylinder(d=4, h=10, $fn=12);
	}
	
	
	translate([6.64, -46.94, 0]) pci_card();
	translate([47.28, -46.94, 0]) pci_card();
	
	color("grey") {
		pci_connectors() translate([0, 0, thickness]) scale([1.0, -1.0, 1.0]) cube([inch(0.4), inch(5), inch(0.4)]);
	}
}

module rear_io_cutout() {
	translate([inch(2.096), inch(0.483), inch(-0.088)]) cube([inch(6.25), 2, inch(1.75)]);
}

module rear_powersupply() {
	translate([inch(2.096+3), inch(0.483-2), inch(2)]) {
		power_supply();
	}
}

module top_radiator() {
	translate([inch(8.5), inch(0.483), 0]) {
		radiator();
	}
}

module rear_pci_cutout(width = 14) {
	pci_connectors(inch(0.483), 0.5) {
		translate([-width/2, 0, 0]) cube([width, 2, 100]);
	}
}

module tray(offset = 12) {
	translate([0, 0, offset]) {
		motherboard();
		
		color("purple") {
			// You need a small amount of clearance around this (0.1in)
			rear_io_cutout();
			
			rear_pci_cutout();
		}
		
		rear_powersupply();
	}
	
	standoffs() color("yellow") cylinder(d=4, h=offset, $fn=12);
}

tray();
//top_radiator();

//translate([inch(4.8), -120, 0]) zcube([320, 280, 140]);
