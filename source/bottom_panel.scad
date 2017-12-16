
use <matx.scad>;
use <zcube.scad>;
use <bolts.scad>;

render() intersection() {
	translate([0, 0, -150]) cube([300, 300, 300]);
	bottom_panel();
}

//render() case();
