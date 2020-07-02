
$tolerance = 0.1;
$fn = $preview ? 24 : 128;

use <bolts.scad>;
use <zcube.scad>;

use <h115i.scad>;
use <sfx.scad>;
use <bay.scad>;
use <ssd.scad>;
use <fan.scad>;
use <pci.scad>;
use <cable.scad>;
use <duct.scad>;

function inch(x) = x * 25.4;

// The case is 12mm larger from the internal size on each edge, so 320+12+12
internal_size = [320, 320, 148];

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

module motherboard(thickness = pci_motherboard_thickness()) {
	color("green") render() difference() {
		translate([inch(-1.35), inch(0.4-9.6), 0]) cube([inch(9.6), inch(9.6), thickness]);
		standoffs() cylinder(d=4, h=10, $fn=8);
	}
	
	// A very rough approximation of where the CPU is likely to be.
	translate([inch(5), inch(-4.5), thickness]) color("silver") {
		zcube([inch(3), inch(2.5), 10]);
		translate([0, 0, 10]) fan_d9l();
	}
	
	// Origin the surface of the PCB.
	translate([0, 0, thickness]) {
		//color("brown") pci_express_datum(index = 2, count = 3) pci_card();
		color("brown") pci_express_datum(index = 0, count = 1) pci_card();
		
		color("grey") {
			pci_express_connectors();
		}
	}
	
	pci_rear_bracket_top();
	pci_rear_bracket_bottom();
}

module top_storage(dimensions) {
	translate([dimensions[0]/2, 0, dimensions[2]/2]) rotate([0, 90, 0]) rotate([0, 0, 90]) children();
}

module wall_cutout(dimensions = internal_size, thickness = 6, panel_bolt_insert = 12, tolerance = 0) {
	translate([dimensions[0]/2, dimensions[1]/2, 0]) {
		cube([thickness, thickness, dimensions[2]]);
		
		// Bottom cutout:
		zcube([12, 12, 9-tolerance]);
		translate([-15-tolerance, -15-tolerance, 0]) cube([15-tolerance, 15-tolerance, 9-tolerance]);
		
		// Top cutout:
		translate([0, 0, dimensions[2] - 9+tolerance]) {
			zcube([12, 12, 9-tolerance]);
			translate([-15-tolerance, -15-tolerance, 0]) cube([15-tolerance, 15-tolerance, 9-tolerance]);
		}
	}
}

module walls(dimensions = internal_size, thickness = 6) {
	//color("white") render() 
	difference() {
		zsides(dimensions, thickness, 0);
		
		zcorners() wall_cutout(dimensions);
	}
}

module sides(dimensions = internal_size, thickness = 6) {
	color("white") render() difference() {
		walls();
		
		top_controls(dimensions) bay_cutout();
		front_fan(dimensions) fan_cutout();
		// top_fan(dimensions) fan_cutout();
		
		back_power_supply(dimensions) sfx_cutout();
		back_fans(dimensions) fan_cutout(80);
		top_storage(dimensions) ssd_cage_cutout();
		
		bottom_tray(dimensions) {
			atx_io_cutout();
			pci_rear_cutout();
		}
		
		zcorners() corner_cutout(dimensions);
	}
}

module front_fan(dimensions) {
	translate([-70-2.25, -dimensions[1]/2, dimensions[2]/2]) rotate([90, 0, 0]) children();
	translate([+70+2.25, -dimensions[1]/2, dimensions[2]/2]) rotate([90, 0, 0]) children();
}

module top_fan(dimensions) {
	mirror([0, 1, 0]) {
		translate([dimensions[0]/2, -70-2.25, dimensions[2]/2]) rotate([90, 0, 90]) children();
		translate([dimensions[0]/2, +70+2.25, dimensions[2]/2]) rotate([90, 0, 90]) children();
	}
}

module side_fan(dimensions) {
	translate([dimensions[0]/14, -dimensions[1]/14, dimensions[2]]) children();
}

module side_duct(dimensions) {
	bottom_tray(dimensions, offset=dimensions[2]) {
		translate([-3, 0, 0]) {
			pci_connectors(index = 0, count = 1) children();
		}
	}
}

module top_controls(dimensions) {
	translate([dimensions[0]/2, -dimensions[1]*0.3, dimensions[2]/2]) {
		rotate([0, 90, 0]) {
			children();
		}
	}
}

module back_power_supply(dimensions) {
	translate([dimensions[0]/2-(64), dimensions[1]/2, dimensions[2]/2]) rotate([0, -90, 180]) children();
}

module back_fans(dimensions) {
	//translate([-25, dimensions[1]/2, dimensions[2]/3*2]) rotate([0, 90, 90]) children();
	//translate([55, dimensions[1]/2, dimensions[2]/3*2]) rotate([0, 90, 90]) children();
	translate([0, dimensions[1]/2, dimensions[2]/3*2]) rotate([0, 90, 90]) children();
}

module bottom_tray(dimensions, offset = atx_tray_offset()) {
	translate([inch(-9.6/2)+3.5, dimensions[1]/2-pci_back_offset(), offset]) children();
}

module case(dimensions = internal_size) {
	bottom_tray(dimensions) {
		if ($preview) {
			motherboard();
			pci_rear_slots();
			atx_io_support();
		}
	}
	
	if ($preview) {
		back_power_supply(dimensions) sfx();
		back_fans(dimensions) fan(80);
		front_fan(dimensions) fan();
		// top_fan(dimensions) fan();
		top_storage(dimensions) ssd_cage();
		top_controls(dimensions) bay();
	}
	
	sides(dimensions);
	
	render() difference() {
		zcorners() corner();
		zcorners() corner_cutout();
	}
}

module corner(dimensions = internal_size, thickness = 6) {
	render() intersection() {
		difference() {
			wall_cutout(tolerance=$tolerance);
			rcube([dimensions[0]-thickness*1.5, dimensions[0]-thickness*1.5, dimensions[2]], d=thickness*4, $fn=4);
		}
		
		rcube([dimensions[0]+thickness*3.5, dimensions[1]+thickness*3.5, dimensions[2]], d=thickness*4, $fn=4);
	}
}

module bolted_corner_cutout(dimensions = internal_size, thickness = 6) {
	bolt_length = 12;
	offset = -bolt_length+thickness;
	
	translate([dimensions[0]/2, dimensions[1]/2, 0]) {
		translate([0, 0, -offset]) mirror([0, 0, 1]) rotate([0, 0, 45+90])
		bolted_hole(3, bolt_length, nut_offset=0, shaft_length=2);
		
		translate([0, 0, dimensions[2]+offset]) rotate([0, 0, 45+90])
		bolted_hole(3, bolt_length, nut_offset=0, shaft_length=2);
		
		inset = (thickness*1.5)/2;
		vertical_offset = (dimoutsetensions[2]-inset*2);
		
		for (dz = [inset:vertical_offset:dimensions[2]]) {
			translate([offset, -thickness-inset, dz]) rotate([0, 90, 0]) 
			rotate([0, 0, 180]) bolted_hole(3, bolt_length, nut_offset=0);
			
			translate([-thickness-inset, offset, dz]) rotate([-90, 0, 0])
			rotate([0, 0, 90]) bolted_hole(3, bolt_length, nut_offset=0);
		}
	}
}

module corner_cutout(dimensions = internal_size, thickness = 6, side_bolt_insert = 8, panel_bolt_insert = 8) {
	translate([dimensions[0]/2, dimensions[1]/2, 0]) {
		translate([0, 0, panel_bolt_insert]) mirror([0, 0, 1]) rotate([0, 0, 45+90]) screw_hole(3, panel_bolt_insert+thickness);
		translate([0, 0, dimensions[2]-panel_bolt_insert]) rotate([0, 0, 45+90]) screw_hole(3, panel_bolt_insert+thickness);
		
		inset = (thickness*1.5)/2;
		vertical_offset = (dimensions[2]-inset*2);
		
		for (dz = [inset:vertical_offset:dimensions[2]]) {
			// Requires knurled insert M3x8x5mm, flat M3x14mm scews.
			translate([-side_bolt_insert, -thickness-inset, dz]) rotate([0, 90, 0]) screw_hole(3, side_bolt_insert+thickness);
			translate([-thickness-inset, -side_bolt_insert, dz]) rotate([-90, 0, 0]) screw_hole(3, side_bolt_insert+thickness);
		}
	}
}

module panel(dimensions = internal_size, thickness = 6) {
	sx = dimensions[0]+(thickness*2)+12*2;
	sy = dimensions[1]+(thickness*2)+12*2;
	
	difference() {
		intersection() {
			rcube([sx, sy, thickness], d=thickness*2, $fn=4);
			
			ix = dimensions[0]/2+thickness+6;
			iy = dimensions[1]/2+thickness+6;
			
			zcorners() {
				translate([ix, iy, thickness/2]) rotate([0, 0, 45]) cube([thickness*12, thickness*12, thickness], true);
				
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

module top_panel(dimensions = internal_size, thickness = 6) {
	render() difference() {
		translate([0, 0, dimensions[2]]) panel(dimensions, thickness);
		
		zcorners() corner_cutout(dimensions);
		
		side_duct(dimensions) {
			duct_cutout();
		}
	}
	
	if ($preview) {
		side_duct(dimensions) {
			duct();
		}
	}
}

module cable_clamps_top(dimensions = internal_size) {
	increment = dimensions[1]/4;
	
	translate([dimensions[0]/2-35, -increment/2, 0]) children();
	translate([dimensions[0]/2-35, increment/2, 0]) children();
}

module cable_clamps_front(dimensions = internal_size) {
	half = dimensions[0]/2;
	increment = dimensions[0]/4;
	
	for (offset = [-half+increment:increment:half-increment]) {
		translate([offset, -110, 0]) rotate([0, 0, 90]) children();
	}
}

module bottom_panel(dimensions = internal_size, thickness = 6, inset = 2) {
	if ($preview) {
		cable_clamps_top(dimensions) cable_clamp(48);
		cable_clamps_front(dimensions) cable_clamp(30);
		
		bottom_tray(dimensions, 0) {
			standoffs() standoff();
		}
	}
	
	render() difference() {
		translate([0, 0, -thickness]) panel(dimensions, thickness);
		
		cable_clamps_top(dimensions) cable_clamp_cutout(48);
		cable_clamps_front(dimensions) cable_clamp_cutout(30);
		
		zcorners() corner_cutout(dimensions);
		
		bottom_tray(dimensions, 0) {
			standoffs() standoff_hole();
		}
		
		bottom_tray(dimensions) {
			pci_rear_cutout();
		}
	}
}
