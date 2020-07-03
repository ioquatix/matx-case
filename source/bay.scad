
use <bolts.scad>;
use <zcube.scad>;

bay_dimensions = [100+10, 50+10, 40];
button_clearance = 0.4;
button_dimensions = [38-(button_clearance*2), 14-(button_clearance*2)];
button_offset = bay_dimensions[1]/2 - (button_dimensions[1]+(button_clearance*2))/2;

module bay_interior_cutout(thickness = 6) {
	union() {
		hull() {
			half_button = button_dimensions[1]+(button_clearance*2);
			
			translate([0, 0, 6])
			zcube([bay_dimensions[0], bay_dimensions[1]-half_button, thickness*8]);
			
			translate([0, -bay_dimensions[1]/4, 6])
			zcube([bay_dimensions[0], bay_dimensions[1]/2, thickness], f=-1);
			
			translate([0, -bay_dimensions[1]/4, -10])
			zcube([bay_dimensions[0], bay_dimensions[1]/4, thickness/2]);
		}
	}
}

module bay_led_cutout(tolerance = 0) {
	#reflect() {
		translate([12, 0, 0]) {
			hull() {
				cylinder_outer(5, 5/2+tolerance);
				translate([0, 0, 8-5/2+tolerance]) sphere_outer(5/2);
				
				cylinder_outer(10, 5/2);
			}
		}
	}
}

module bay(thickness=6, tolerance=0.1) {
	difference() {
		union() {
			zcube([bay_dimensions[0]-tolerance*2, bay_dimensions[1]-tolerance*2, thickness]);
			zcube([bay_dimensions[0]+12*2, bay_dimensions[1]+6, thickness*2], f=-1);
		}
		
		// Avoids unprintable curves around back of button:
		translate([0, button_offset+2, 0])
		zcube([button_dimensions[0]+2, button_dimensions[1]+2, 6]);
		
		translate([0, button_offset, -9-3]) {
			button_cutout(tolerance=1);
			
			switch_cutout();
			
			bay_led_cutout();
		}
		
		bay_interior_cutout();
		
		translate([0, 8, -18])
		rotate([-61, 0, 0])
		bay_usb_cutout();
		
		reflect()
		mirror([0, 0, 1])
		translate([78/2, 5.5, 6])
		# threaded_hole(3, 6);
		
		bay_screws(thickness);
	}
	
	if ($preview) {
		bay_button();
		
		translate([0, button_offset, -9-3]) {
			switch_cutout();
		}
		
		translate([0, 8, -18])
		rotate([-61, 0, 0])
		bay_usb_pcb();
	}
}

module bay_button() {
	color("white")
	render()
	difference() {
		translate([0, button_offset, -9-3]) {
			difference() {
				button();
			}
		}
		
		bay_interior_cutout();
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

module bay_usb_pcb() {
	render()
	difference() {
		zcube([75, 21, 1.6]);
		reflect() {
			translate([75/2, -6/2, 0])
			zcube([4, 6, 1.6]);
		}
		
		// PCB:
		reflect()
		translate([69.8/2, 21/2 - 6, 1.6 - 6])
		screw_hole(3, 6, thickness=1.6, inset=4);
	}
	
	color("white")
	translate([0, 0, 1.6 + 7/2])
	rotate([90, 0, 0])
	reflect() {
		translate([14/2, 0.8, -21/2]) {
			cylinder(d=6, h=21+4);
			rcube([12, 11.1-1.6, 21]);
		}
		
		translate([46/2, 0, -21/2])
		rcube([14.5, 7, 21+4]);
	}
}

module bay_usb_cutout() {
	difference() {
		zcube([75, 21, 1.6]);
		
		// PCB:
		reflect()
		translate([70/2, 21/2 - 6, 1.6 - 6])
		hole(3.2, 6);
	}
	
	zcube([66, 21, 1.6], f=-1);
	zcube([66, 21, 11.1]);
	
	translate([0, 0, 1.6 + 7/2])
	rotate([90, 0, 0])
	reflect() {
		translate([14/2, 0.8, -21/2])
		cylinder(d=6+1, h=21+5);
		
		translate([46/2, 0, -21/2])
		rcube([14.5+1, 7+1, 21+5]);
	}
}

module button_cutout(dimensions = button_dimensions, tolerance = 0.0) {
	bottom = 11;
	top = 11+7;
	height = top - bottom;
	
	translate([0, 0, bottom])
	rcube([dimensions[0]+tolerance*2, dimensions[1]+tolerance*2, height]);
}

module button(dimensions = button_dimensions, tolerance = 0.0) {
	color("white")
	render()
	difference() {
		button_cutout(dimensions, tolerance);
		switch_cutout(tolerance = 0.1);
	}
	
	// switch_cutout(tolerance = 0.1);
}

module switch_cutout(tolerance = 0) {
	color("black") {
		zcube([8.5+tolerance*2, 8.5+tolerance*2, 9]);
		zcube([4, 4, 11]);
		zcube([3+tolerance*2, 2+tolerance*2, 13.7]);
	}
	
	mirror([0, 0, 1])
	translate([0, 6.5, -6])
	threaded_hole(3, 6);
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
