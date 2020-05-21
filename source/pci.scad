
use <zcube.scad>;
use <bolts.scad>;

function inch(x) = x * 25.4;

function pci_count() = 4;
function atx_tray_offset() = 12;

// This information is taken from the PCI Electromechanical Specification:
function pci_bracket_width() = inch(0.725);
function pci_tab_width() = inch(0.75);
function pci_tab_offset() = inch(0.1) + (pci_tab_width() - pci_bracket_width()) / 2;
function pci_tab_outset() = inch(0.450);

// The distance fromt the origin to the back of the case (inside):
// This number is actually +/- inch(0.01). The PCI bracket won't be completely flush with the back of the case.
function pci_back_offset() = inch(0.483);

function pci_motherboard_thickness() = inch(0.062);

// This is the offset from the bottom of the motherboard to the bottom REF of the PCI card:
function pci_motherboard_offset() = pci_motherboard_thickness() + 7.90;

// This is the offset from the origin to datum A:
function pci_datum_A() = -46.94;

// This is the offset of the top of the motherboard to datum B:
function pci_datum_B() = 16.15 + 3.85;

// This is the offset from the origin to the first slot (closest to the CPU):
function pci_slot_offset() = inch(1.862);
function pci_slot_spacing() = inch(0.8);
function pci_slot_back() = inch(2.325);

function pci_tab_height() = pci_motherboard_offset() + 100.36;

// The distance between PCI slots:
function pci_spacing() = inch(0.8);
function pci_tab_spacing() = inch(0.8);

// The distance from the Z datum to the center of the PCI cutout.
function pci_center_from_datum() = inch(0.062/2) + inch(0.014) + inch(0.475/2);
function pci_datum_offset() = inch(-0.538) - pci_center_from_datum();

// The distance between cards:
function pci_center_spacing() = inch(0.8);
// Even thought this is 0.86mm, we make it 1mm to increase tolerance.
function pci_tab_gap() = 1; //inch(0.034);

// The offset from datum A to the screw.
function pci_screw_offset() = [inch(0.112) - inch(0.062), inch(2.525), 0];

// The offset of the notch:
function pci_notch_offset() = [inch(0.062)/2 - inch(0.675) + inch(0.550 + 0.430)/2, inch(0.365) + 0.33, pci_tab_height()];
// This is inset slightly from the spec:
function pci_notch_size() = [2.5, inch(0.450 - 0.285)+0.6, pci_tab_gap()];

module pci_card(offset = 0) {
	// We translate the gtx card to the correct datum:
	//-7 + 3.65/2 + 8.25 - 4.85 - 7.25
	// This seems to be short by 0.128 on the Z axis?
	translate([1.6/2, 8/2 + 3.65 + 12.15, 3.1-8.25-3.85+offset]) rotate([90, 0, -90]) import("gtx.stl", convexity=4);
}

module pci_connectors(inset = pci_back_offset(), offset = pci_center_from_datum(), index = 0, count = pci_count()) {
	// This is the position of pin 0 is given when factor is 0, otherwise when factor = 0.5 it's the midpoints.
	translate([pci_slot_offset()-offset, inset, 0]) {
		for (x = [index:1:count-1])
			translate([pci_slot_spacing() * -x, 0, 0]) children();
	}
}

// The offset is the the intersection of datums A & B from the PCI Express 
module pci_express_datum(offset = pci_datum_B(), index = 0, count = pci_count()) {
	pci_connectors(inset = pci_datum_A(), index = index, count = count, offset = 0)
	translate([0, 0, offset]) children();
}

module pci_express_connector(length = 89.0) {
	translate([0, -length/2+14.5, 0]) zcube([7.5, length, 11.25]);
}

module pci_express_connectors(offset = 0) {
	pci_express_datum(0, index = offset, count = pci_count() - offset) {
		cylinder(d=2, h=16.15);
		pci_express_connector();
	}
}

module pci_rear_bracket_screw() {
	translate(pci_screw_offset()) translate([0, 0, -3]) threaded_hole(3, pci_tab_gap() + 3, 4);
}

module pci_rear_bracket_top(outset = 6) {
	bottom = pci_tab_height();
	top = bottom + 14;
	size = top - bottom;
	
	color("purple") render() difference() {
		hull() pci_connectors() {
			translate([pci_tab_offset(), outset, bottom]) {
				rcube([pci_tab_spacing(), outset*2, 6], d=4);
				translate([0, -outset/2, 0]) zcube([pci_tab_spacing(), outset, size]);
			}
		}
		
		/* hull() pci_connectors() {
			translate([pci_tab_offset(), pci_tab_outset()/2-outset/2, bottom]) {
				rcube([pci_tab_width(), (pci_tab_outset()+outset), pci_tab_gap()], d=3);
			}
		} */
		
		hull() pci_connectors() {
			translate([pci_tab_offset(), outset, bottom]) {
				zcube([pci_tab_width(), outset*2, pci_tab_gap()]);
			}
		}
		
		pci_express_datum(bottom) {
			hull() {
				pci_rear_bracket_screw();
				translate([0, -outset, 0]) # pci_rear_bracket_screw();
			}
		}
	}
	
	color("purple") pci_connectors(offset=0) {
		translate(pci_notch_offset()) {
			zcube(pci_notch_size());
		}
	}
}

module pci_rear_bracket_bottom(outset = 6, bevel = 1) {
	bottom = pci_tab_height();
	top = bottom + 14;
	size = top - bottom;
	
	// This is an alignment guide which uses the PCI datum for aligning the metal braket against the back of the case.
	/* color("green") pci_express_datum() {
		translate([0, pci_slot_back(), 0]) cube(pci_slot_spacing(), 10, 100);
	}*/
	
	color("orange") render() difference() {
		hull() pci_connectors() {
			translate([pci_tab_offset(), outset, bottom-6]) {
				rcube([pci_tab_spacing(), outset*2, 6], d=4);
				translate([0, -outset/2, 3]) zcube([pci_tab_spacing(), outset, 3]);
			}
		}
		
		pci_connectors() {
			translate([pci_tab_offset(), outset, bottom-6]) {
				translate([0, -outset, 0]) zcube([pci_tab_spacing(), outset*2, 3]);
			}
		}
		
		pci_connectors() {
			translate([pci_tab_offset() - pci_tab_spacing()/2 - 1, 0, bottom-bevel]) {
				difference() {
					translate([0, -bevel, 0]) cube([pci_tab_spacing()+2, bevel*2, bevel*2]);
					translate([0, bevel, 0]) rotate([0, 90, 0]) cylinder(r=1, h=pci_tab_spacing()+2);
				}
			}
		}
		
		pci_express_datum(bottom) {
			pci_rear_bracket_screw();
		}
		
		// This makes a space for the notch:
		color("purple") pci_connectors(offset=0) {
			translate(pci_notch_offset()) {
				hull() {
					translate([0, -2, 0]) zcube([3.1, 1, 2]);
					translate([0, 5, -1.5]) zcube([12, 1, 2]);
				}
			}
		}
	}
	
	color("purple") pci_connectors(offset=0) {
		center = pci_notch_offset();
		size = pci_notch_size();
		
		translate([center[0], outset*1.5, center[2]]) {
			mirror([0, 0, 1]) zcube([size[0], outset, size[2]+2]);
		}
	}
}

module pci_rear_slots(thickness = 6, gap = 1.2, height = 8) {
	color("purple") difference() {
		difference() {
			hull() pci_connectors() {
				translate([2, -thickness/2, -atx_tray_offset()])
				zcube([pci_slot_spacing()-6, thickness, height]);
			}
			
			pci_connectors() {
				translate([0, -thickness/2, -atx_tray_offset()]) 
				translate([0, (thickness-gap)/2, 0]) zcube([12, gap, height]);
			}
		}
		
		pci_rear_cutout();
	}
}

module atx_io_cutout() {
	translate([inch(2.096), pci_back_offset()-$tolerance, inch(-0.088)]) cube([inch(6.25), 20, inch(1.75)]);
	// This isn't strictly necessary and can't be easily laser cut :p
	// #translate([inch(2.096-0.1), inch(0.483+0.05)-$tolerance, inch(-0.088-0.1)]) cube([inch(6.25+0.2), 20, inch(1.75+0.2)]);
}

module pci_rear_cutout(width = 14, extension = inch(-0.088), outset = 20) {
	pci_connectors() {
		// Main vertical cut-out:
		translate([-width/2, 0, extension]) difference() {
			cube([width, outset, 100+extension]);
			
			// This gives little corner cut-outs while allowing the bottom to be flush with the motherboard io cut-out which is not completely compliant with the PCI/ATX specification.
			translate([width/2, 0, 0]) reflect() translate([width/4, 0, 0]) rotate([0, 45, 0]) cube([width, outset, width]);
		}
	}
	
	hull() {
		bottom = pci_tab_height();
		top = bottom + 14;
		
		pci_connectors() {
			translate([-pci_tab_spacing()/2+pci_tab_offset(), 0, bottom]) cube([pci_tab_spacing(), outset, top-bottom]);
		}
		
		pci_connectors() {
			translate([-pci_tab_spacing()/2+pci_tab_offset(), 0, bottom-3]) cube([pci_tab_spacing(), outset, 3]);
		}
	}
	
	pci_connectors(index = 1) {
		// Bring the hole into alignment with the corner brackets.
		translate([inch(0.4), -6, -12 + (9/2)]) rotate([-90, 0, 0]) knurled_hole(3, 12);
	}
}

