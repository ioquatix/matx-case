
use <zcube.scad>;
use <bolts.scad>;

function inch(x) = x * 25.4;

function pci_count() = 4;
function atx_tray_offset() = 12;
function atx_io_cutout_extension() = inch(0.088);

// This is taken from the internal case height.
function pci_wall_height() = 148;
function pci_connector_top() = pci_wall_height() - atx_tray_offset();

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
function pci_screw_offset() = [inch(0.112) - inch(0.062/2), inch(2.525), 0];

// In practice this seemed too big:
//function pci_screw_diameter() = inch(0.174);
function pci_screw_diameter() = inch(0.15);

// The offset of the notch:
function pci_notch_offset() = [inch(0.062)/2 - inch(0.675) + inch(0.550 + 0.430)/2, inch(0.365) + 0.33, pci_tab_height()-1];
// This is inset slightly from the spec:
function pci_notch_size() = [inch(0.550) - inch(0.430) - 0.8, inch(0.450 - 0.285) + 0.6, pci_tab_gap()+1];

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
	translate(pci_screw_offset())
	//translate([0, 0, -3])
	children();
	// threaded_hole(pci_screw_diameter(), pci_tab_gap() + 3, 4);
}

module pci_rear_bracket(outset = 6, bevel = 1) {
	bottom = pci_tab_height();
	top = bottom + 14;
	size = top - bottom;
	
	// This is an alignment guide which uses the PCI datum for aligning the metal braket against the back of the case.
	/* color("green") pci_express_datum() {
		translate([0, pci_slot_back(), 0]) cube(pci_slot_spacing(), 10, 100);
	}*/
	
	pci_express_datum(bottom) {
		pci_rear_bracket_screw() cylinder_inner(6, (pci_screw_diameter()/2) * 0.8);
	}
	
	gap = 4;
	
	color("orange") render() difference() {
		union() {
			hull() pci_connectors() {
				translate([pci_tab_offset(), outset, bottom]) {
					rcube([pci_tab_spacing(), outset*2, 6], d=4);
					// We take a little bit off the top so that it fits more easily:
					translate([0, -outset/2, 0]) zcube([pci_tab_spacing(), outset, size-0.4]);
				}
			}
			
			pci_connectors() {
				hull() {
					translate([3, -gap/2, bottom-2]) zcube([inch(1), gap, size+4]);
				}
			}
		}
		
		// Cut out gaps for the card PCBs.
		pci_connectors() {
			translate([8, -gap/2, bottom-2]) zcube([4, gap, 10]);
		}
		
		hull() pci_connectors() {
			translate([pci_tab_offset(), outset, bottom]) {
				rcube([pci_tab_spacing()-1, outset*2-1, 1], d=3);
				translate([0, -outset/2, 0]) zcube([pci_tab_spacing()-1, outset, 1]);
			}
			
			translate([pci_tab_offset(), 0, bottom]) {
				rotate([0, 90, 0])
				translate([0, -0.5, -inch(0.4)+0.5]) {
					cylinder(r=1, inch(0.8)-1);
					
					translate([5, 0, 0])
					cylinder(r=1, inch(0.8)-1);
				}
			}
		}
	}
	
	color("purple") pci_connectors(offset=0) {
		translate(pci_notch_offset()) {
			zcube(pci_notch_size());
		}
	}
}

module pci_rear_bracket_split(outset = 18) {
	bottom = pci_tab_height();
	top = bottom + 14;
	size = top - bottom;
	
	hull() pci_connectors() {
		translate([pci_tab_offset(), outset-5, bottom-6]) {
			translate([0, -outset/2, 0]) zcube([pci_tab_spacing()+8, outset, 12]);
		}
	}
}

module pci_rear_bracket_top() {
	color("brown")
	difference() {
		pci_rear_bracket();
		pci_rear_bracket_split();
	}
	
	bottom = pci_tab_height();
	top = bottom + 14;
	
	difference() {
		pci_connectors(index = 0) {
			hull() {
				translate([inch(0.4), -6, pci_connector_top() - 9/2]) rotate([-90, 0, 0]) zcube([9, 9, 6]);
				translate([inch(0.4), -2, bottom+6+3+1]) rotate([-90, 0, 0]) zcube([9, 4, 2]);
			}
		}
		
		pci_rear_cutout();
	}
}

module pci_rear_bracket_bottom() {
	color("blue")
	intersection() {
		pci_rear_bracket_split();
		pci_rear_bracket();
	}
}

module pci_rear_slots(thickness = 9, gap = 1.2, slot = 12, height = 9) {
	color("purple") difference() {
		union() {
			difference() {
				hull() pci_connectors() {
					translate([2, -thickness/2, -atx_tray_offset()])
					zcube([pci_slot_spacing()-6, thickness, height]);
				}
				
				pci_connectors() {
					translate([0, -thickness/2, -atx_tray_offset()])
					translate([0, (thickness-gap)/2, 0]) zcube([slot, gap, height]);
					
					translate([0, -thickness/2, -atx_tray_offset()+6])
					translate([0, (thickness-gap)/2, 0]) hull() {
						zcube([slot, gap, 3]);
						translate([0, 0, 3]) zcube([14, gap*4, 3]);
					}
				}
			}
			
			pci_connectors(index=0, count=1)
			hull() {
				translate([16, -thickness/2, -atx_tray_offset()])
				zcube([pci_slot_spacing()-6, thickness, height]);
				
				translate([16+155, -thickness/2, -atx_tray_offset()])
				zcube([pci_slot_spacing()-6, thickness, height]);
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

module atx_io_clearance() {
	translate([inch(2.096-0.1), 0, inch(-0.088-0.1)]) cube([inch(6.25+0.2), inch(0.483), inch(1.75+0.2)]);
}

module pci_rear_cutout(width = 18, outset = 20) {
	pci_connectors() {
		// Main vertical cut-out:
		translate([-width/2, 0, -atx_io_cutout_extension()]) difference() {
			cube([width, outset, 108]);
			
			// This gives little corner cut-outs while allowing the bottom to be flush with the motherboard io cut-out which is not completely compliant with the PCI/ATX specification.
			translate([width/2, 0, 0]) reflect() translate([width/4, 0, 0]) rotate([0, 45, 0]) cube([width, outset, width]);
		}
	}
	
	bottom = pci_tab_height();
	top = bottom + 14;
	
	hull() {
		pci_connectors() {
			translate([-pci_tab_spacing()/2+pci_tab_offset(), 0, bottom]) cube([pci_tab_spacing(), outset, top-bottom]);
		}
		
		pci_connectors() {
			translate([-pci_tab_spacing()/2+pci_tab_offset(), 0, bottom]) cube([pci_tab_spacing(), outset, 1]);
		}
	}
	
	// Bottom screws for mounting support bar:
	pci_connectors(index = 0) {
		// Bring the hole into alignment with the corner brackets.
		translate([inch(0.4), -6, -12 + (9/2)]) rotate([-90, 0, 0]) screw_hole(3, 12);
	}
	
	// Top screws for mounting top bracket:
	pci_connectors(index = 0) {
		// Bring the hole into alignment with the corner brackets.
		translate([inch(0.4), -6, pci_connector_top() - 9/2]) rotate([-90, 0, 0]) screw_hole(3, 12);
	}
	
	// Holes for mounting the cut outs:
	pci_connectors() {
		// Bring the hole into alignment with the corner brackets.
		translate([0, 0, -atx_io_cutout_extension()]) {
			rotate([-90, 0, 0]) threaded_hole(3, 6);
			translate([0, 0, 108]) rotate([-90, 0, 0]) threaded_hole(3, 6);
		}
	}
	
	// The mounting screws under the ATX io cutout:
	atx_io_clearance();
	
	translate([inch(2.096) + inch(6.25/2), pci_back_offset(), -atx_tray_offset()]) {
		translate([150/4, -6, 9/2]) rotate([-90, 0, 0]) screw_hole(3, 12);
		translate([-150/4, -6, 9/2]) rotate([-90, 0, 0]) screw_hole(3, 12);
		
		translate([0, -9/2, -6]) countersunk_screw_hole(3, 12, inset=4, thickness=6);
		translate([-150/2, -9/2, -6]) countersunk_screw_hole(3, 12, inset=4, thickness=6);
		translate([150/2, -9/2, -6]) countersunk_screw_hole(3, 12, inset=4, thickness=6);
	}
}

