
use <bolts.scad>;
use <zcube.scad>;

$fn = 32;

bay_dimensions = [120, 80, 40];

bay_offset = [0, 5.3, 0.5];
bay_angle = -45;
bay_spacing = 22;

button_clearance = 0.5;
button_dimensions = [38-(button_clearance*2), 13-(button_clearance*2)];
button_offset = bay_dimensions[1]/2 - (button_dimensions[1]+(button_clearance*2))/2;

module bay_interior_cutout(thickness = 6) {
	inset = bay_dimensions[1];
	
	intersection() {
		for (i = [-1:1]) {
			translate([0, bay_spacing*i, 0])
			translate(bay_offset)
			rotate([bay_angle, 0, 0])
			translate([0, -inset/2, -7.5])
			zcube([bay_dimensions[0], inset, inset]);
		}
		
		translate([0, 0, -thickness*2])
		cylinder($fn=6, r1=bay_dimensions[1]*0.5, r2=bay_dimensions[1]*0.7, h=thickness*4);
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

module bay_form(thickness=6, tolerance=0.1) {
	intersection() {
		translate([0, 0, -thickness*2])
		zcube([bay_dimensions[0]-tolerance*2, bay_dimensions[1]-tolerance*2, thickness * 3]);
		
		translate([0, 0, -thickness*4])
		cylinder($fn=6, r=bay_dimensions[1]*0.7 + 4, h=thickness*5+0.2);
	}
	
	translate([0, 0, -thickness*2])
	zcube([bay_dimensions[0], bay_dimensions[1] + thickness*2, thickness * 2]);
}

module bay(thickness=6, tolerance=0.1) {
	difference() {
		bay_form(thickness, tolerance);
		
		// Avoids unprintable curves around back of button:
		translate([0, button_offset+2, 0])
		zcube([button_dimensions[0]+button_clearance*2, button_dimensions[1]+2, 6]);
		
		translate([0, button_offset, -9-3]) {
			button_cutout(tolerance=button_clearance);
			
			switch_cutout();
			
			bay_led_cutout();
		}
		
		bay_interior_cutout();
		
		translate(bay_offset)
		rotate([bay_angle, 0, 0])
		bay_usb_cutout();
		
		translate(bay_offset)
		translate([0, -bay_spacing, 0])
		rotate([bay_angle, 0, 0])
		bay_usbc_cutout();
		
		reflect()
		mirror([0, 0, 1])
		translate([78/2, 4, 3.8])
		translate(bay_offset)
		threaded_hole(3, 6);
		
		bay_screws(thickness);
	}
	
	/* if ($preview) {
		bay_button();
		
		translate([0, button_offset, -9-3]) {
			switch_cutout();
		}
		
		translate(bay_offset)
		rotate([bay_angle, 0, 0])
		bay_usb_pcb();
	} */
}

module bay_holes(outset = 8, dimensions = bay_dimensions) {
	reflect() {
		translate([-dimensions[0]/2 + outset, dimensions[1]/2 - outset, 0]) children();
		translate([-dimensions[0]/2 + outset, -dimensions[1]/2 + outset, 0]) children();
	}
}

module bay_usb_pcb() {
	render()
	translate([0, 15, -5]) {
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
}

module bay_usb_cutout() {
	translate([0, 15, -5]) {
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
}

module bay_usbc_cutout(extrude = 10) {
	translate([0, 11, -1])
	rotate([90, 0, 0]) {
		difference() {
			union() {
				translate([0, 0, -extrude]) {
					zcube([27.2 + 2, 8 + 2, 1.6 + extrude]);
					
					translate([0, -24/2, 0])
					zcube([14 + 2, 24, 1.6 + extrude]);
				}
				
				translate([0, 8/2 - 3, 1.6])
				zcube([10.5+2, 4.6, 2]);
			}
		}
		
		reflect()
		translate([19/2, 8/2 - 3, 6])
		rotate([180, 0, 0])
		/* hole(3.5, 6); */
		threaded_hole(3, 6);
		
		color("white")
		hull() {
			translate([0, 8/2 - 3, 1.6])
			rcube([10.5, 4.6, 10], 2);
		}
	}
}

module button_cutout(dimensions = button_dimensions, tolerance = 0.0, offset = 3) {
	bottom = 11 - offset;
	top = 11+7;
	height = top - bottom;
	
	translate([0, 0, bottom])
	rcube([dimensions[0]+tolerance*2, dimensions[1]+tolerance*2, height]);
}

module bay_button_form(dimensions = button_dimensions, tolerance = 0.0) {
	color("white")
	render()
	difference() {
		button_cutout(dimensions, tolerance, 0);
		switch_cutout(tolerance = 0.1);
	}
	
	// switch_cutout(tolerance = 0.1);
}

module bay_button() {
	color("white")
	render()
	difference() {
		translate([0, button_offset, -9-3])
		bay_button_form();
		bay_interior_cutout();
	}
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
	bay_form(thickness, 0);
	
	bay_screws(thickness);
	
	translate([0, 25, -9-3]) {
		switch_cutout();
	}
}

bay();
/* bay_usb_pcb(); */
/* bay_usb_cutout(); */
/* bay_usbc_cutout(); */
//color("red") bay_cutout();
