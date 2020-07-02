
use <bolts.scad>;
use <zcube.scad>;

bay_dimensions = [100+10, 50+10, 40];
button_dimensions = [36, 12];

module bay(dimensions = bay_dimensions, thickness=6, tolerance=0.1) {
	button_offset = dimensions[1]/2 - (button_dimensions[1]+2)/2;
	
	difference() {
		union() {
			zcube([dimensions[0]-tolerance*2, dimensions[1]-tolerance*2, thickness]);
			zcube([dimensions[0]+12*2, dimensions[1]+12, thickness*2], f=-1);
		}
		
		// Avoids unprintable curves around back of button:
		translate([0, button_offset+2, 0])
		zcube([button_dimensions[0]+2, button_dimensions[1]+2, 6]);
		
		translate([0, button_offset, -9-3]) {
			button_cutout(tolerance=1);
			
			switch_cutout();
			
			reflect() {
				translate([12, 0, 0]) {
					hull() {
						cylinder_outer(5, 5/2);
						translate([0, 0, 8-5/2]) sphere_outer(5/2);
						
						cylinder_outer(10, 5/2);
					}
				}
			}
		}
		
		union() {
			hull() {
				half_button = button_dimensions[1]+2;
				
				translate([0, 0, 6])
				zcube([dimensions[0], dimensions[1]-half_button, thickness*8]);
				
				translate([0, -dimensions[1]/4, 6])
				zcube([dimensions[0], dimensions[1]/2, thickness], f=-1);
				
				translate([0, -dimensions[1]/4, -10])
				zcube([dimensions[0], dimensions[1]/4, thickness/2]);
			}
		}
		
		translate([0, 8, -18])
		rotate([-61, 0, 0])
		bay_usb_cutout();
		
		bay_screws(thickness);
	}
	
	if ($preview) {
		translate([0, button_offset, -9-3]) {
			button();
			switch_cutout();
		}
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
		zcube([75, 21, 1.6]);
		
		// PCB:
		reflect()
		translate([69.8/2, 21/2 - 6, 1.6 - 6])
		hole(3.2, 6);
	}
	
	zcube([66, 21, 1.6], f=-1);
	zcube([66, 21, 11.1]);
	
	translate([0, -21/2, 1.6 + 7/2])
	rotate([90, 0, 0])
	reflect() {
		translate([14/2, 0.8, -21/2])
		cylinder(d=6, h=21/2+4);
		
		translate([46/2, 0, -21/2])
		rcube([14.5, 7, 21/2+4]);
	}
	
	// PCB:
	reflect()
	translate([69.8/2, 21/2 - 6, 1.6 - 6])
	#screw_hole(3, 6, thickness=1.6, inset=4);
}

module button_cutout(dimensions = button_dimensions, tolerance = 0.0, offset = 3) {
	translate([0, 0, 9+3-offset-tolerance])
	rcube([dimensions[0]+tolerance*2, dimensions[1]+tolerance*2, (6+offset)+tolerance*2]);
}

module button(dimensions = button_dimensions, tolerance = 0.0) {
	color("white")
	render()
	difference() {
		button_cutout(dimensions, tolerance, 0);
	}
}

module switch_cutout() {
	color("black") {
		zcube([9, 9, 9]);
		zcube([3, 2, 9+6]);
	}
	
	mirror([0, 0, 1])
	translate([0, 6.5, -6])
	# threaded_hole(3, 6);
}

module bay_screws(thickness = 6) {
	// The screw is M3, but we make the hole M4 so it won't hold a thread.
	bay_holes() translate([0, 0, -thickness]) screw_hole(3, 12);
}

module bay_cutout(thickness = 6, dimensions = bay_dimensions) {
	color("grey")
	hull() {
		translate([0, 0, 0])
		zcube([dimensions[0], dimensions[1], thickness+0.2]);
		
		translate([0, 0, -22])
		zcube([dimensions[0], dimensions[1]/2, thickness+0.2]);
	}
	
	bay_screws(thickness);
	
	translate([0, 25, -9-3]) {
		switch_cutout();
	}
}

bay();
//color("red") bay_cutout();
