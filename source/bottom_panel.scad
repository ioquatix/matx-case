
use <matx.scad>;
use <zcube.scad>;
use <bolts.scad>;

module interlock(width = 20) {
	translate([-width/2, 0, -150]) rotate([0, 0, 45]) cube([10, 10, 300], true);
	translate([0, 0, -150]) cube([width, 5, 300], true);
	translate([width/2, 0, -150]) rotate([0, 0, 45]) cube([10, 10, 300], true);
}

render() difference() {
	intersection() {
		//translate([0, 0, -150]) cube([300, 300, 300]);
		
		bottom_panel();
	}
	
	/* for (r=[0:90:360]) {
		rotate([0, 0, r]) {
			translate([0, 30, 0]) interlock();
			translate([0, 30+50, 0]) interlock(80);
			translate([0, 30+100, 0]) interlock(160);
		}
	} */
}

case();
