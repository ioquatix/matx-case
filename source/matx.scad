
$tolerance = 0.1;
$fn = 4*4;

use <bolts.scad>;
use <zcube.scad>;

use <h115i.scad>;
use <sfx.scad>;
use <bay.scad>;
use <ssd.scad>;
use <fan.scad>;
use <pci.scad>;

function inch(x) = x * 25.4;

internal_size = [320, 320, 160-12];

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

module motherboard(thickness=1.6) {
	color("green") render() difference() {
		translate([inch(-1.35), inch(0.4-9.6), 0]) cube([inch(9.6), inch(9.6), thickness]);
		standoffs() cylinder(d=4, h=10, $fn=12);
	}
	
	// A very rough approximation of where the CPU is likely to be.
	translate([inch(5), inch(-4.5), thickness]) color("silver") zcube([inch(3), inch(2.5), inch(1.5)]);
	
	// Origin the surface of the PCB.
	translate([0, 0, thickness]) {
		color("brown") translate([0, 0, 12*0]) pci_express_datum(index = 3, count = 4) pci_card();
		//color("brown") pci_express_datum(index = 1, count = 2) pci_card();
		
		color("grey") {
			pci_express_connectors();
		}
		
		rear_pci_bracket();
	}
}

module rear_io_cutout() {
	translate([inch(2.096), inch(0.483)-$tolerance, inch(-0.088)]) cube([inch(6.25), 20, inch(1.75)]);
	// This isn't strictly necessary and can't be easily laser cut :p
	// #translate([inch(2.096-0.1), inch(0.483+0.05)-$tolerance, inch(-0.088-0.1)]) cube([inch(6.25+0.2), 20, inch(1.75+0.2)]);
}

module rear_powersupply() {
	translate([inch(2.096+3), inch(0.483-2), inch(2)]) {
		power_supply();
	}
}

module rear_pci_cutout(width = 14, extension = inch(-0.088), outset = 20) {
	pci_connectors(inch(0.483), factor = 0.5) {
		// Main vertical cut-out:
		translate([-width/2, 0-$tolerance, extension]) difference() {
			cube([width, outset, 100+extension]);
			
			// This gives little corner cut-outs while allowing the bottom to be flush with the motherboard io cut-out which is not completely compliant with the PCI/ATX specification.
			translate([width/2, 0-$tolerance, 0]) reflect() translate([width/4, 0, 0]) rotate([0, 45, 0]) cube([width, outset+$tolerance*2, width]);
		}
		
		translate([-8, 0-$tolerance, 108.8+1]) cube([inch(0.8)+$tolerance, outset, 30]);
	}
}

module bottom_storage(dimensions) {
	offset = dimensions[1]/4;
	
	for (y = [-offset:80:offset])
		translate([-dimensions[0]/2, y, dimensions[2]/2]) rotate([-90, 0, -90]) children();
}

module rear_pci_bracket(width = 12, outset = 12) {
	hull() {
		pci_connectors(inch(0.483), factor = 0.5) {
			translate([-8, 0, 108+1]) cube([inch(0.8), 6, inch(1)]);
		}
	}
	
	hull() {
		pci_connectors(inch(0.483), factor = 0.5) {
			translate([-8-6, -6, 108+10]) cube([inch(0.8)+12, 6, inch(1)-9]);
		}
	}
	
	hull() {
		pci_connectors(inch(0.483), factor = 0.5) {
			translate([-8-6, 6, 108+1]) cube([inch(0.8)+12, 0.01, inch(1)]);
			translate([-8, +6, 108+1]) cube([inch(0.8), 6, 0.01]);
		}
	}
	
	color("white") pci_express_datum(100.36+7.9) {
		translate([2.84-1.57/2, 64.13, 0]) hole(4, 1, 0);
	}
}

module walls(dimensions = internal_size, thickness = 6) {
	color("white") render() difference() {
		difference() {
			zcube([dimensions[0]+thickness*2, dimensions[1]+thickness*2, dimensions[2]], d=20);
			zcube([dimensions[0]-1, dimensions[1], dimensions[2]+2]);
		}
		
		front_controls(dimensions) bay_cutout();
		front_fan(dimensions) fan_cutout();
		top_radiator(dimensions) h115i_cutout();
		back_power_supply(dimensions) sfx_cutout();
		bottom_storage(dimensions) ssd_cutout();
		
		bottom_tray(dimensions) {
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

module front_controls(dimensions) {
	translate([dimensions[0]/4, -dimensions[1]/2, dimensions[2]/2]) rotate([0, 90, 0]) bay_offset() children();
}

module back_power_supply(dimensions) {
	translate([20, dimensions[1]/2, dimensions[2]-4]) rotate([0, 0, 180]) children();
}

module bottom_tray(dimensions, offset = 12) {
	translate([inch(-4.8)+8, dimensions[1]/2-inch(0.483), offset]) children();
}

module case(dimensions = internal_size) {
	bottom_tray(dimensions) {
		motherboard();
	}

	top_radiator(dimensions) h115i();
	back_power_supply(dimensions) sfx();
	front_fan(dimensions) fan();
	bottom_storage(dimensions) ssd();
	
	walls(dimensions);
	
	render() difference() {
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
		vertical_inset = offset / 2;
		vertical_offset = (dimensions[2]-vertical_inset*2) / 3;
		
		for (dz = [vertical_inset:vertical_offset:dimensions[2]]) {
			// Requires knurled insert M3x8x5mm, flat M3x14mm scews.
			translate([bolt_length, -offset/2, dz]) rotate([0, -90, 0]) countersunk_knurled_hole(bolt_size, bolt_length, insert=offset-2);
			translate([-offset/2, bolt_length, dz]) rotate([90, 0, 0]) countersunk_knurled_hole(bolt_size, bolt_length, insert=offset-2);
		}
	}
}

module panel(dimensions = internal_size, thickness = 6, offset = 10) {
	sx = dimensions[0]+(thickness*2+offset*2);
	sy = dimensions[1]+(thickness*2+offset*2);
	
	difference() {
		intersection() {
			rcube([sx, sy, thickness], d=offset*2);
			
			ix = dimensions[0]/2+thickness;
			iy = dimensions[1]/2+thickness;
			
			zcorners() {
				translate([ix, iy, thickness/2]) rotate([0, 0, 45]) cube([offset*6, offset*6, thickness], true);
				
				cube([ix, iy, thickness]);
			}
		}
		
		/* for (dx = [-140:40:150]) {
			for (dy = [-140:40:150]) {
				%translate([dx, dy, -4]) color("green") knurled_hole(3, 4, insert=4);
			}
		} */
	}
}

module top_panel(dimensions = internal_size, thickness = 6, offset = 10) {
	difference() {
		translate([0, 0, dimensions[2]]) panel(dimensions, thickness, offset);
		
		zcorners() corner_cutout(dimensions);
	}
}

module bottom_panel(dimensions = internal_size, thickness = 6, offset = 10, inset = 2) {
	difference() {
		translate([0, 0, -thickness]) panel(dimensions, thickness, offset);
		
		zcorners() corner_cutout(dimensions);
		
		bottom_tray(dimensions, 0) {
			difference() {
				translate([0, 0, -6]) standoffs() color("yellow") hole(3, 6, 12);
			}
		}
	}
}

case();
bottom_panel();
//top_panel();
