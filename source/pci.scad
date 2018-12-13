
use <zcube.scad>;

function inch(x) = x * 25.4;

pci_count = 4;
function pci_bracket_width() = inch(0.725);
function pci_tab_width() = inch(0.8);
function pci_tab_offset() = pci_bracket_width()/2 + inch(0.125) - pci_tab_width()/2;
function pci_tab_gap() = inch(4.356 - 4.32);

module pci_card() {
	// We translate the gtx card to the correct datum:
	//-7 + 3.65/2 + 8.25 - 4.85 - 7.25
	translate([1.6/2, 8/2 + 3.65 + 12.15, 3.1-8.25-3.85]) rotate([90, 0, -90]) import("gtx.stl", convexity=4);
}

module pci_connectors(inset = inch(-0.6), offset = inch(1.2), factor = 0.5, index = 0, count = pci_count) {
	// This is the position of pin 0 is given when factor is 0, otherwise when factor = 0.5 it's the midpoints.
	translate([-offset, inset, 0]) {
		for (x = [index:1:count-1])
			translate([inch(0.8*(x+factor)), 0, 0]) children();
	}
}

module pci_express_datum(offset = 3.85+16.15, index = 0, count = pci_count) {
	pci_connectors(inset = -46.94, offset = 13.67, index = index, count = count, factor = 0)
	translate([0, 0, offset]) children();
}

module pci_express_connector(length = 89.0) {
	translate([0, -length/2+14.5, 0]) zcube([7.5, length, 11.25]);
}

module pci_express_connectors(offset = 0) {
	pci_express_datum(0, index = offset, count = pci_count - offset) pci_express_connector();
}
