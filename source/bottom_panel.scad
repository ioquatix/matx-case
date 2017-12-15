
use <matx.scad>;
use <bolts.scad>;

//intersection() {
	//translate([0, 0, -150]) cube([300, 300, 300]);
	difference() {
		bottom_panel();
		
		for (dx = [-130:20:130]) {
			for (dy = [-130:20:130]) {
				color("green") translate([dx, dy, -4]) knurled_hole(3, 4, insert=4);
			}
		}
	}
//}
