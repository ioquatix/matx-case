
$tolerance = 0.1;
$fn = 8*8;

use <bolts.scad>;
use <zcube.scad>;

use <h115i.scad>;
use <sfx.scad>;
use <bay.scad>;
use <ssd.scad>;
use <fan.scad>;
use <pci.scad>;

function inch(x) = x * 25.4;

// The case is 16mm larger from the internal size on each edge, so 320+16+16
internal_size = [324, 324, 144];

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
		standoffs() cylinder(d=4, h=10, $fn=12);
	}
	
	// A very rough approximation of where the CPU is likely to be.
	translate([inch(5), inch(-4.5), thickness]) color("silver") zcube([inch(3), inch(2.5), inch(1.5)]);
	
	// Origin the surface of the PCB.
	translate([0, 0, thickness]) {
		color("brown") pci_express_datum(index = 2, count = 3) pci_card();
		color("brown") pci_express_datum(index = 0, count = 1) pci_card();
		
		color("grey") {
			pci_express_connectors();
		}
	}
	
	//pci_rear_bracket_top();
	pci_rear_bracket_bottom();
}

module rear_powersupply() {
	translate([inch(2.096+3), inch(0.483-2), inch(2)]) {
		power_supply();
	}
}

module bottom_storage(dimensions) {
	offset = dimensions[1]/4;
	
	for (y = [-offset:80:offset])
		translate([-dimensions[0]/2, y, dimensions[2]/2]) rotate([-90, 180, -90]) children();
}

module walls(dimensions = internal_size, thickness = 6) {
	color("white") render() difference() {
		zsides(dimensions, thickness, 6);
		
		front_controls(dimensions) bay_cutout();
		front_fan(dimensions) fan_cutout();
		top_radiator(dimensions) h115i_cutout();
		back_power_supply(dimensions) sfx_cutout();
		bottom_storage(dimensions) ssd_cutout();
		
		bottom_tray(dimensions) {
			atx_io_cutout();
			pci_rear_cutout();
		}
		
		zcorners() corner_cutout(dimensions);
	}
}

module front_fan(dimensions) {
	translate([-70-2.25, -dimensions[1]/2, dimensions[2]/2]) rotate([90, 0, 0]) children();
}

module side_fan(dimensions) {
	translate([dimensions[0]/14, -dimensions[1]/14, dimensions[2]]) children();
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

module bottom_tray(dimensions, offset = atx_tray_offset()) {
	translate([inch(-4.8)+12, dimensions[1]/2-pci_back_offset(), offset]) children();
}

module case(dimensions = internal_size) {
	bottom_tray(dimensions) {
		motherboard();
		
		color("gold") standoffs() {
			mirror([0, 0, 1]) cylinder(d=5, h=12);
		}
		
		pci_rear_slots();
	}

	top_radiator(dimensions) h115i();
	back_power_supply(dimensions) sfx();
	front_fan(dimensions) fan();
	bottom_storage(dimensions) ssd_with_standoff();
	
	walls(dimensions);
	
	render() difference() {
		zcorners() corner();
		zcorners() corner_cutout();
	}
}

module corner(dimensions = internal_size, thickness = 6) {
	sx = dimensions[0]+thickness*2;
	sy = dimensions[1]+thickness*2;
	
	intersection() {
		union() {
			difference() {
				rcube([sx, sy, dimensions[2]], d=thickness*2);
				
				zcube([dimensions[0]+thickness*2, dimensions[1]-thickness*2, dimensions[2]]);
				zcube([dimensions[0]-thickness*2, dimensions[1]+thickness*2, dimensions[2]]);
			}
			
			difference() {
				zcube(dimensions);
				
				zcube([dimensions[0], dimensions[1]-thickness*5, dimensions[2]]);
				zcube([dimensions[0]-thickness*5, dimensions[1], dimensions[2]]);
				zcube([dimensions[0]-thickness*2, dimensions[1]-thickness*2, dimensions[2]]);
			}
		}
		
		cube(dimensions);
	}
}

module corner_cutout(dimensions = internal_size, thickness = 6, panel_thickness = 6, panel_bolt_insert = 12) {
	translate([dimensions[0]/2, dimensions[1]/2, 0]) {
		// Requires knurled insert M6x12x8
		translate([0, 0, panel_bolt_insert]) mirror([0, 0, 1]) rotate([0, 0, 45+90]) knurled_hole(6, panel_bolt_insert+panel_thickness, insert=panel_bolt_insert);
		translate([0, 0, dimensions[2]-panel_bolt_insert]) rotate([0, 0, 45+90]) knurled_hole(6, panel_bolt_insert+panel_thickness, insert=panel_bolt_insert);
		
		bolt_length = thickness*2;
		
		bolt_size = 3;
		inset = (thickness*1.5)/2;
		vertical_offset = (dimensions[2]-inset*2) / 3;
		
		for (dz = [inset:vertical_offset:dimensions[2]]) {
			// Requires knurled insert M3x8x5mm, flat M3x14mm scews.
			translate([-thickness, -thickness-inset, dz]) rotate([0, 90, 0]) knurled_hole(bolt_size, bolt_length, insert=thickness);
			translate([-thickness-inset, -thickness, dz]) rotate([-90, 0, 0]) knurled_hole(bolt_size, bolt_length, insert=thickness);
		}
	}
}

module panel(dimensions = internal_size, thickness = 6) {
	sx = dimensions[0]+(thickness*4);
	sy = dimensions[1]+(thickness*4);
	
	difference() {
		intersection() {
			rcube([sx, sy, thickness], d=thickness*2);
			
			ix = dimensions[0]/2+thickness;
			iy = dimensions[1]/2+thickness;
			
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

module top_panel(dimensions = internal_size, thickness = 6, offset = 10) {
	render() difference() {
		translate([0, 0, dimensions[2]]) panel(dimensions, thickness, offset);
		
		zcorners() corner_cutout(dimensions);
		
		side_fan(dimensions) fan_cutout();
	}
	
	side_fan(dimensions) fan();
}

module bottom_panel(dimensions = internal_size, thickness = 6, offset = 10, inset = 2) {
	render() difference() {
		translate([0, 0, -thickness]) panel(dimensions, thickness, offset);
		
		zcorners() corner_cutout(dimensions);
		
		bottom_tray(dimensions, 0) {
			difference() {
				translate([0, 0, -6]) standoffs() color("yellow") hole(3, 6, 12);
			}
		}
	}
}
