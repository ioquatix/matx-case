
$projection = true;

include <../source/case.scad>;

size = internal_size + [18*2, 18*2, 0];
panel = [1200, 600, 6];
margin = [4, 4];

/* if ($preview) {
	color("black")
	translate([0, 0, -6-1])
	cube(panel);
} */

module wall_projection(index = 0) {
	projection(cut=true)
	intersection() {
		/* zcube([1000, 1000, 6]); */
		rotate([0, 90, 0])
		translate([internal_size[0]/2+3, 0, 0])
		rotate([0, 0, 90 * index])
		sides();
	}
}

translate([margin[0] + internal_size[0]*0.5, margin[1]*2 + size[1]*1, 0]) rotate([0, 0, 90]) wall_projection(0);

translate([margin[0]*2 + internal_size[0]*1.5, margin[1]*2 + size[1]*1, 0]) rotate([0, 0, 90]) wall_projection(1);

translate([margin[0]*3 + internal_size[0]*2.5, margin[1]*2 + size[1]*1, 0]) rotate([0, 0, 90]) wall_projection(2);

translate([margin[0]*3 + size[0]*2, margin[1]*1 + size[1]*0.5, 0]) rotate([0, 0, 0]) wall_projection(3);

projection(cut=true)
translate([margin[0] + size[0]*0.5, margin[1] + size[1]*0.5, -3]) rotate([180, 0, 0]) bottom_panel();

projection(cut=true)
translate([margin[0]*2 + size[0]*1.5, margin[1] + size[1]*0.5, -size[2]-3]) top_panel();
