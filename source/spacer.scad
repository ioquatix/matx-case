
$tolerance = 0.1;
$fn = $preview ? 12 : 32;

use <bolts.scad>;

module spacer(diameter, thickness, height, rim = 1) {
	difference() {
		cylinder_outer(height, diameter * rim);
		
		hole(diameter, thickness);
	}
}

//spacer(3, 2, 2);

spacer(3, 2, 6, 2);
