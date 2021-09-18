
use <bolts.scad>;
use <fan.scad>;
use <zcube.scad>;

use <pci.scad>;

depth = 26-6;

size = 140;
space = 2;

height = 2;
inset = 2;

duct_width = pci_slot_spacing() * 9;

module duct_tube(offset = 0, thickness = 6) {
	translate([0, pci_slot_spacing() * -1.5 + -duct_width/2, 0])
	hull() {
		translate([0, 0, -thickness])
		zcube([pci_tab_width()-2+offset, duct_width+offset + offset * pci_tab_width(), thickness]);
		
		translate([0, 0, -depth])
		zcube([pci_tab_width()-2+offset, duct_width+offset*4, thickness]);
	}
}

module duct_cover(offset = 0, thickness = 6) {
	translate([0, pci_slot_spacing() * -1.5 + -duct_width/2, 0])
	hull() {
		translate([0, 0, -thickness])
		zcube([pci_tab_width()-2+offset, duct_width+offset + offset * pci_slot_spacing(), thickness]);
	}
}

module duct_cutout(thickness = 6) {
	/* #translate([0, -116, 0]) {
		reflect([0, 1, 0]) translate([0, duct_width/2 + 6, -thickness]) knurled_hole(3, 12, insert=6);
		zcube([20, duct_width, thickness]);
	} */
	
	size = pci_slot_spacing() / sqrt(3);
	
	for (x = [0:-1:-3]) {
		translate([0, (x % 2) * -size, 0]) {
			translate([x * sqrt(3) * size, size * -1 * 2, -thickness])
			knurled_hole(3, 12, insert=6);
			
			translate([x * sqrt(3) * size, size * -10 * 2, -thickness])
			knurled_hole(3, 12, insert=6);
			
			for (y = [-2:-1:-9]) {
				translate([x * sqrt(3) * size, y * 2 * size])
				cylinder_outer(thickness, size - 2, 6);
			}
		}
	}
}

module duct() {
	offset = pci_tab_width();
	
	color("orange")
	render()
	union() {
		difference() {
			duct_tube(2);
			duct_tube(0);
			
			duct_cutout();
		}
		
		translate([offset * -1, -0.5 * offset, 0])
		difference() {
			duct_cover(2);
			duct_cutout();
		}
	}
}

duct_cutout();
