
$fn = 32;

module wall(length, height=1, r=1) {
	translate([r, r, 0]) hull() {
		cylinder(r=r, h=height);
		translate([length, 0, 0]) cylinder(r=r, h=height);
	}
}

module clip(depth = 6.1, height = 2) {
	translate([0, 0, -1]) hull() {
		translate([0, height, 0]) wall(10, 1);
		mirror([0, 1, 0]) wall(10, 1);
	}
	
	translate([0, height, 0]) wall(10, depth);
	mirror([0, 1, 0]) wall(10, depth);
}

clip();
