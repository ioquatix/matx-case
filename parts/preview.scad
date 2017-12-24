
include <../source/case.scad>;

panel = [1200, 600, 6];
margin = [30, 30];

module wall_projection(index = 0) {
	projection(true)
	rotate([0, 90, 0])
	translate([internal_size[0]/2+3, 0, 0])
	rotate([0, 0, 90 * index])
	render() walls();
}

translate([margin[0] + internal_size[0]*0.5, margin[1]*2 + internal_size[1]*1, 0]) rotate([0, 0, 90]) wall_projection(0);

translate([margin[0] + internal_size[0]*1.5, margin[1]*2 + internal_size[1]*1, 0]) rotate([0, 0, 90]) wall_projection(1);

translate([margin[0] + internal_size[0]*2.5, margin[1]*2 + internal_size[1]*1, 0]) rotate([0, 0, 90]) wall_projection(2);

translate([margin[0]*3 + internal_size[0]*2, margin[1]*1 + internal_size[1]*0.5, 0]) rotate([0, 0, 0]) wall_projection(3);

projection()
translate([margin[0] + internal_size[0]*0.5, margin[1] + internal_size[1]*0.5, 0]) rotate([180, 0, 0]) bottom_panel();

projection()
translate([margin[0]*2 + internal_size[0]*1.5, margin[1] + internal_size[1]*0.5, 0]) top_panel();
