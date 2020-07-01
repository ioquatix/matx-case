
use <bolts.scad>;
use <zcube.scad>;

bay_dimensions = [100+10, 50+10, 40];

module bay(dimensions = bay_dimensions, thickness=6) {
	difference() {
		hull() {
			translate([0, 0, 0])
			zcube([dimensions[0]+12*2, dimensions[1]+12, thickness], f=-1);
			
			translate([0, 0, -20])
			zcube([dimensions[0]+6, dimensions[1]/2+6, thickness/2], f=-1);
		}
		
		bay_cutout();
		
		translate([0, 30, -20])
		rotate([-34, 0, 0])
		translate([0, 2, 0])
		#bay_usb_cutout();
	}
}

module bay_holes(outset = 6, dimensions = bay_dimensions) {
	width = dimensions[0];
	height = dimensions[1];
	
	for (offset = [-height/4:height/2:height/2]) {
		translate([-width/2-outset, offset, 0]) children();
		translate([width/2+outset, offset, 0]) children();
	}
}

module bay_usb_cutout() {
	difference() {
		union() {
			zcube([75, 21, 1.6]);
			
			translate([0, -21/2, 1.6 + 7/2])
			rotate([90, 0, 0])
			reflect() {
				translate([14/2, 0.8, -21/2])
				cylinder(d=6, h=21/2+4);
				
				translate([46/2, 0, -21/2])
				rcube([14.5, 7, 21/2+4]);
			}
		}
		
		// PCB:
		reflect()
		translate([69.8/2, 21/2 - 6, 1.6 - 6])
		screw_hole(3, 6, thickness=1.6, inset=4);
	}
}

module bay_cutout(thickness = 6, inset = 12, insert=6, dimensions = bay_dimensions) {
	color("grey")
	hull() {
		translate([0, 0, 0])
		zcube([dimensions[0], dimensions[1], thickness+0.2]);
		
		translate([0, 0, -20])
		zcube([dimensions[0], dimensions[1]/2, thickness+0.2]);
	}
	
	// The screw is M3, but we make the hole M4 so it won't hold a thread.
	bay_holes() translate([0, 0, -insert]) screw_hole(3, 12);
}

bay();
//color("red") bay_cutout();
